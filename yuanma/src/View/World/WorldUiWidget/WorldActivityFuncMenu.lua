--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldActivityFuncMenu.lua
-- author:    liyuhang
-- created:   2015/10/27
-- descrip:   主UI 右上角活动功能菜单
--===================================================
local WorldActivityFuncMenu = class("WorldActivityFuncMenu",function()
	return cc.Layer:create()
end)

local STATE_ABLE = 1
local STATE_DISABLE = 2

-- 构造函数
function WorldActivityFuncMenu:ctor()
	self._strName = "WorldActivityFuncMenu" 
    self._pTouchListener = nil
	
	self._kState = STATE_DISABLE
	
	self._sKeyName = ""

    -- 活动按钮集合
    self._nActivityShowIndex = 0
    self._tActivityFuncMap = {}
    self._tActivityFuncBtnMap = {}

    self.leveldd = RolesManager:getInstance()._pMainRoleInfo.level

    self._pNewFuncOpenCCs = nil                 --新功能开启

    -- 二级菜单
    self._pWorldFuncListMenu = nil

end

-- 创建函数
function WorldActivityFuncMenu:create()
	local menu = WorldActivityFuncMenu.new()
    menu:dispose()
	return menu
end

function WorldActivityFuncMenu:dispose()
    -- 添加监听器
    --self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    --self._pTouchListener:setSwallowTouches(true)
    --self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    --self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    --self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    -- self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    self._pWorldFuncListMenu = require("WorldFuncListMenu"):create()
    self:addChild(self._pWorldFuncListMenu)
    self._pWorldFuncListMenu:setListMenuState(false)


    self:createFuncBtns()
    
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWorldActivityFuncMenu()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

function WorldActivityFuncMenu:refreshMenus(  )
    -- body
    self.leveldd = RolesManager:getInstance()._pMainRoleInfo.level
    self:createFuncBtns()
end

function WorldActivityFuncMenu:createActivityDatas()
    self._tActivityFuncMap = {}

    for i=1,table.getn(TableMainActivityFunc) do
        if TableMainActivityFunc[i].OpenConditions <= self.leveldd then
            -- 判断首充奖励是否已经领奖
            if not (ActivityManager:getInstance()._nFirstChargeState == 2 and TableMainActivityFunc[i].Desc == "首充按钮") then 
                table.insert(self._tActivityFuncMap,TableMainActivityFunc[i])
            end            
        end
    end

    table.sort(self._tActivityFuncMap,function(a,b)
        return a.ButtonOrder > b.ButtonOrder -- 从大到小排序
    end)

    self._nActivityShowIndex = 1

    for i=1,table.getn(self._tActivityFuncMap) do
        if self._tActivityFuncMap[i].InsideOrOut == 1 then
            self._nActivityShowIndex = self._nActivityShowIndex + 1
        else
            break
        end
    end
end

function WorldActivityFuncMenu:createFuncBtns()
    --初始化数据
    self:createActivityDatas()
    --初始化按钮集合
    local sScreen = mmo.VisibleRect:getVisibleSize()
    local disPointX = sScreen.width - 80      -- 隐藏点x坐标
    local disPointY = sScreen.height - 160     -- 隐藏点y坐标
    local ablePointX = sScreen.width - 100     -- 可视点点x坐标
    local ablePointY = sScreen.height - 180    -- 可视点点y坐标
    local offset = 104  
    local actionFunc = {}
    
    --------------------------------------------- 寻宝： 金钱+材料  --------------------------------------------------------------
    local goldStuffMazeCopysFunc = function() 
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[13].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("寻宝功能(内含： 金钱+材料）"..TableNewFunction[13].Level.."级开放")
            return 
        end
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return 
        end
        local posIndex = RolesManager:getInstance()._pMainPlayerRole:getPositionIndex()
        local npcID = self:getNpcIdByDesc("寻宝按钮")
        local npc = RolesManager:getInstance()._tNpcRoles[npcID]
        local targetPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(npc:getPositionX(), npc:getPositionY()))
        targetPosIndex.y = targetPosIndex.y + 1
        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
        local callBackFunc = function()
            MessageGameInstance:sendMessageQueryBattleList21000({kType.kCopy.kGold,kType.kCopy.kStuff})
        end
        RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun, true, {moveDirections = path, func = callBackFunc})
    end
    actionFunc["寻宝按钮"] = goldStuffMazeCopysFunc
    
    
    --------------------------------------------- 历练： 挑战+爬塔+地图BOSS副本 +迷宫 --------------------------------------------------------------        
    local challengeTowerMapBossCopysFunc = function() 
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[20].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("历练功能(内含： 挑战副本+迷宫副本+爬塔副本）"..TableNewFunction[20].Level.."级开放")
            return 
        end
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return 
        end
        local posIndex = RolesManager:getInstance()._pMainPlayerRole:getPositionIndex()
        local npcID = self:getNpcIdByDesc("历练按钮")
        local npc = RolesManager:getInstance()._tNpcRoles[npcID]
        local targetPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(npc:getPositionX(), npc:getPositionY()))
        targetPosIndex.y = targetPosIndex.y + 1
        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
        local callBackFunc = function()
            --MessageGameInstance:sendMessageQueryBattleList21000()
            DialogManager:getInstance():showDialog("CopysPortalDialog")
            
        end
        RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun, true, {moveDirections = path, func = callBackFunc})
    end
    actionFunc["历练按钮"] = challengeTowerMapBossCopysFunc
   
    
    --------------------------------------------- 历练： 剧情副本  --------------------------------------------------------------
    local storyCopysFunc = function() 
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[1].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("剧情副本"..TableNewFunction[1].Level.."级开放")
            return 
        end
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return 
        end
        local posIndex = RolesManager:getInstance()._pMainPlayerRole:getPositionIndex()
        local npcID = self:getNpcIdByDesc("剧情按钮")
        local npc = RolesManager:getInstance()._tNpcRoles[npcID]
        local targetPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(npc:getPositionX(), npc:getPositionY()))
        targetPosIndex.y = targetPosIndex.y + 1
        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
        local callBackFunc = function()
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(function() 
                   if DialogManager:getInstance():getDialogByName("StoryCopyDialog") == nil then
                      DialogManager:getInstance():showDialog("StoryCopyDialog")
                   end
                end)
            ))
        end
        RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun, true, {moveDirections = path, func = callBackFunc})
    end
    actionFunc["剧情按钮"] = storyCopysFunc
    
    
    --------------------------------------------- 竞技场： PVP  --------------------------------------------------------------
    local pvpHuashanCopysFunc = function() 
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[9].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("竞技场"..TableNewFunction[9].Level.."级开放")
            return 
        end
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return 
        end
        local posIndex = RolesManager:getInstance()._pMainPlayerRole:getPositionIndex()
        local npcID = self:getNpcIdByDesc("竞技场按钮")
        local npc = RolesManager:getInstance()._tNpcRoles[npcID]
        local targetPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(npc:getPositionX(), npc:getPositionY()))
        targetPosIndex.y = targetPosIndex.y + 1
        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
        local callBackFunc = function()
            ArenaCGMessage:queryArenaInfoReq21600()  
            --NewbieManager:showOutAndRemoveWithRunTime()
            --DialogManager:getInstance():showDialog("ArenaDialog")
        end
        
        RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun, true, {moveDirections = path, func = callBackFunc})
    end
    actionFunc["竞技场按钮"] = pvpHuashanCopysFunc
    
    
    --------------------------------------------- 华山论剑  --------------------------------------------------------------
    local huashanCopysFunc = function() 
        if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[25].Level then --等级不足
            NoticeManager:getInstance():showSystemMessage("斗神殿"..TableNewFunction[25].Level.."级开放")
            return 
        end
        if BagCommonManager:getInstance():isBagItemsEnough() then
            NoticeManager:getInstance():showSystemMessage("背包已满")
            return 
        end
        local posIndex = RolesManager:getInstance()._pMainPlayerRole:getPositionIndex()
        local npcID = self:getNpcIdByDesc("斗神殿按钮")
        local npc = RolesManager:getInstance()._tNpcRoles[npcID]
        local targetPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(npc:getPositionX(), npc:getPositionY()))
        targetPosIndex.y = targetPosIndex.y + 1
        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
        local callBackFunc = function()
            HuaShanCGMessage:queryHSInfoReq21900()
        end
        RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun, true, {moveDirections = path, func = callBackFunc})
    end
    actionFunc["斗神殿按钮"] = huashanCopysFunc
    --------------------------------------------- 首冲  --------------------------------------------------------------
    local firstChargeFunc = function() 
        DialogManager:showDialog("FirstChargeDialog")
    end
    actionFunc[5] = firstChargeFunc
    --------------------------------------------- 商城  --------------------------------------------------------------
    local function shopFunc() 
        DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop})
    end
    actionFunc[6] = shopFunc
    --------------------------------------------- 精彩活动  --------------------------------------------------------------
    local function activityFunc () 
        if #ActivityManager:getInstance()._tActivityStateInfoList <= 0 then 
            ActivityMessage:QueryActivityListReq22500() 
            return
        end
        DialogManager:getInstance():showDialog("ActivityDialog")
    end
    actionFunc[7] = activityFunc
    --------------------------------------------- 礼包  --------------------------------------------------------------

    --------------------------------------------- 修行  --------------------------------------------------------------
    local battleFunc = function() 
        DialogManager:showDialog("WorldFuncBtnSecondaryDialog")
    end
    actionFunc[9] = battleFunc
    ---------------------------------------------------------------------------------------------------------------------------------------
    for i=1,table.getn(self._tActivityFuncMap) do
        local funcBtn = self:getFuncBtnByDesc(self._tActivityFuncMap[i].Desc)
        if funcBtn == nil then
            funcBtn = require("WorldFuncBtn"):create( self._tActivityFuncMap[i] )
            self:addChild(funcBtn,0)
            table.insert(self._tActivityFuncBtnMap , funcBtn)
        end

        if self._nRightUpState == 1 then
            funcBtn:setStateAble()
        end

        funcBtn:setPoints(
            cc.p(disPointX - (i) * offset , disPointY), 
            (self._nActivityShowIndex > i) and cc.p(disPointX, disPointY) or cc.p(disPointX - (i-self._nActivityShowIndex+1)* offset, disPointY))
        funcBtn:setCallback(actionFunc[self._tActivityFuncBtnMap[i]._nFuncInfo.FuncId])
    end
end

function WorldActivityFuncMenu:showFuncListMenu( args )
    self._pWorldFuncListMenu:setListMenuState(true)
    self._pWorldFuncListMenu:setDataInfo(args)
end

function WorldActivityFuncMenu:getFuncBtnByDesc(FuncId)
    for i=1,table.getn(self._tActivityFuncBtnMap) do
        if self._tActivityFuncBtnMap[i]._nFuncInfo.FuncId == FuncId then
            return self._tActivityFuncBtnMap[i]
        end
    end
    
    return nil
end

-- 新开启功能提示动画
function WorldActivityFuncMenu:showNewFuncAni()
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(self._pIconSprite:getContentSize().width/2 , self._pIconSprite:getContentSize().height/2) 

    local batch = nil
    local _pIntensifyEffect = nil
    local actionOverCallBack = function()
        _pIntensifyEffect = nil
        batch:removeFromParent(true)
        batch = nil
    end
    ----------------
    if not _pIntensifyEffect then
        _pIntensifyEffect = cc.ParticleSystemQuad:create("ParticlesShiyonglaba.plist")
        _pIntensifyEffect:setPosition(pAniPostion)
        batch = cc.ParticleBatchNode:createWithTexture(_pIntensifyEffect:getTexture())
        batch:addChild(_pIntensifyEffect)
        self:addChild(batch,10)
    else
        _pIntensifyEffect:resetSystem()
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(actionOverCallBack))) 
end

function WorldActivityFuncMenu:setStateAble( )
	self._kState = STATE_ABLE
end

function WorldActivityFuncMenu:setStateDisable( )
	self._kState = STATE_DISABLE
end

function WorldActivityFuncMenu:setTouchAble(visible)
	self._bTouchAble = visible
end

function WorldActivityFuncMenu:getState( )
	return self._kState
end

function WorldActivityFuncMenu:setKeyPress(arg)
    if arg == true then
        self._bKeyPress = true
        self._pIconSpritePress:setVisible(true)
        self._pIconSprite:setVisible(false)
    else
        self._bKeyPress = false
        self._pIconSpritePress:setVisible(false)
        self._pIconSprite:setVisible(true)
	end
end

function WorldActivityFuncMenu:resetPos()
    if self._kState == STATE_ABLE then
        self:setVisible(true)
        self:setPosition(self._pAblePoint.x,self._pAblePoint.y)
        
    else
        self:setPosition(self._pDisablePoint.x,self._pDisablePoint.y)
        if self._bDisableShowOrNot == true then
            self:setVisible(false)
        end
	end
end

function WorldActivityFuncMenu:changeState(  )
    for i=1,table.getn(self._tActivityFuncBtnMap) do
        self._tActivityFuncBtnMap[i]:changeState()
    end
end

-- 退出函数
function WorldActivityFuncMenu:onExitWorldActivityFuncMenu()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return WorldActivityFuncMenu
