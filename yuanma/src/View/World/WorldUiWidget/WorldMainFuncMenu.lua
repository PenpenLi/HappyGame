--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldMainFuncMenu.lua
-- author:    liyuhang
-- created:   2015/10/19
-- descrip:   主UI 右下角主功能菜单
--===================================================
local WorldMainFuncMenu = class("WorldMainFuncMenu",function()
	return cc.Layer:create()
end)

-- 各个功能按钮回调
mainActionFunc = {
        [9] = function() DialogManager:getInstance():showDialog("OptionDialog",{kOptionType.MainOption}) end,
        [10] = function() DialogManager:showDialog("FriendsDialog",{}) end, 
        [4] = function() 
            if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[1].Level then --等级不足
                NoticeManager:getInstance():showSystemMessage("剧情副本"..TableNewFunction[1].Level.."级开放")
                return 
            end
            if BagCommonManager:getInstance():isBagItemsEnough() then
                NoticeManager:getInstance():showSystemMessage("背包已满")
                return 
            end
            local posIndex = RolesManager:getInstance()._pMainPlayerRole:getPositionIndex()
            local npcID = 1
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
            if DialogManager:getInstance():getDialogByName("StoryCopyDialog") == nil then
                          DialogManager:getInstance():showDialog("StoryCopyDialog")
                       end
            RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun, true, {moveDirections = path, func = callBackFunc})  end,
            ["宠物按钮"] = function()
                DialogManager:showDialog("PetDialog",{})
        end,
        [3] = function()
            DialogManager:getInstance():showDialog("SkillDialog",{}) end,
        [1] = function() DialogManager:getInstance():showDialog("RolesInfoDialog",{RoleDialogTabType.RoleDialogTypeBag}) end,
        [5] = function()
            if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[8].Level then
                NoticeManager:getInstance():showSystemMessage("分解功能"..TableNewFunction[8].Level.."级开放")
                return
            end
            DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeResolve,nil}) 
        end,
        ["任务按钮"] = function() 
            DialogManager:getInstance():showDialog("TaskDialog",{false})
        end,
        [11] = function() 
            DialogManager:getInstance():showDialog("EmailDialog")
        end,
        ["剑灵按钮"] = function() 
            if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[15].Level then --等级不足
                NoticeManager:getInstance():showSystemMessage("剑灵"..TableNewFunction[15].Level.."级开放")
                return 
            end
            BladeSoulCGMessage:sendMessageSelectBladeSoulInfo20700()end,
        ["境界按钮"] = function()
            if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[10].Level then --等级不足
                NoticeManager:getInstance():showSystemMessage("境界"..TableNewFunction[10].Level.."级开放")
                return 
            end
            FairyLandCGMessage:sendMessageSelectFairyInfo20600() end, 
        ["商城按钮"] = function() DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop}) end,
        [7] = function() 
            SturaLibraryCGMessage:querySturaLibraryInfoReq22400()
        end,
        ["酒坊按钮"] = function ()
            if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[18].Level then --等级不足
                NoticeManager:getInstance():showSystemMessage("酒坊系统"..TableNewFunction[11].Level.."级开放")
                return 
            end
            DrunkeryCGMessage:openDrunkeryDialog22100()
        end,
        [2] = function ()
            if  FamilyManager:getInstance()._bOwnFamily == true then --有家族
                DialogManager:getInstance():showDialog("FamilyDialog")
            else
                DialogManager:getInstance():showDialog("FamilyRegisterDialog")  
                FamilyCGMessage:queryFamilyListReq22300(0,8)
            end
        end,
        [6] = function ()
             DialogManager:showDialog("RankDialog")
             --
        end,
        [8] = function ()
             self._pWorldFuncListMenu:setListMenuState(true)
        end
    }

local STATE_ABLE = 1
local STATE_DISABLE = 2

-- 构造函数
function WorldMainFuncMenu:ctor()
	self._strName = "WorldMainFuncMenu" 
    self._pTouchListener = nil
	
	self._kState = STATE_DISABLE
	
	self._sKeyName = ""

    -- cocos studio 功能按钮对应的容器 
    self._tHorizontalMainMap = {}
    self._tHorizontalMoreMap = {}
    self._tVerticalMainMap = {}
    self._tVerticalMoreMap = {}
    self._tHorizontalMainFuncBtnMap = {}
    self._tHorizontalMoreFuncBtnMap = {}
    self._tVerticalMainFuncBtnMap = {}
    self._tVerticalMoreFuncBtnMap = {}

    -- 活动按钮集合
    self._nActivityShowIndex = 0
    self._tActivityFuncMap = {}
    self._tActivityFuncBtnMap = {}

    --需要播放特效的功能开启集合
    self._tMainFuncOpenArray = {}

    self.leveldd = RolesManager:getInstance()._pMainRoleInfo.level

    self._pNewFuncOpenCCs = nil                 --新功能开启

    -- 二级菜单
    self._pWorldFuncListMenu = nil

end

-- 创建函数
function WorldMainFuncMenu:create()
	local menu = WorldMainFuncMenu.new()
    menu:dispose()
	return menu
end

function WorldMainFuncMenu:dispose()
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
            self:onExitWorldMainFuncMenu()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end


function WorldMainFuncMenu:createFuncDataArray()
    self._tHorizontalMainMap = {}
    self._tHorizontalMoreMap = {}
    self._tVerticalMainMap = {}
    self._tVerticalMoreMap = {}
   
    for i=1,table.getn(TableMainUIFunc) do
        if TableMainUIFunc[i].OpenConditions <= self.leveldd then
            if TableMainUIFunc[i].ButtonPos == 1 then
                table.insert(self._tHorizontalMainMap,TableMainUIFunc[i])
            elseif TableMainUIFunc[i].ButtonPos == 2 then
                table.insert(self._tHorizontalMoreMap,TableMainUIFunc[i])
            elseif TableMainUIFunc[i].ButtonPos == 3 then
                table.insert(self._tVerticalMainMap,TableMainUIFunc[i])
            elseif TableMainUIFunc[i].ButtonPos == 4 then
                table.insert(self._tVerticalMoreMap,TableMainUIFunc[i])
            end
        end
    end
    
    table.sort(self._tHorizontalMainMap,function(a,b)
        return a.ButtonOrder > b.ButtonOrder -- 从大到小排序
    end)
    table.sort(self._tHorizontalMoreMap,function(a,b)
        return a.ButtonOrder > b.ButtonOrder -- 从大到小排序
    end)
    table.sort(self._tVerticalMainMap,function(a,b)
        return a.ButtonOrder > b.ButtonOrder -- 从大到小排序
    end)
    table.sort(self._tVerticalMoreMap,function(a,b)
        return a.ButtonOrder > b.ButtonOrder -- 从大到小排序
    end)
end

function WorldMainFuncMenu:showFuncListMenu( args )
    self._pWorldFuncListMenu:setListMenuState(true)
    self._pWorldFuncListMenu:setDataInfo(args)
end

function WorldMainFuncMenu:refreshMenus(  )
    -- body
    self.leveldd = RolesManager:getInstance()._pMainRoleInfo.level
    self:createFuncBtns()
end

--创建背包按钮
function WorldMainFuncMenu:createFuncBtns()
    local sScreen = mmo.VisibleRect:getVisibleSize()
    self:createFuncDataArray()

    local disPointX = sScreen.width - 100      -- 隐藏点x坐标
    local disPointY = 30                      -- 隐藏点y坐标

    local ablePointX = sScreen.width - 100     -- 可视点点x坐标
    local ablePointY = 125                     -- 可视点点y坐标

    local offset = 104                         --图标间距
    -- 水平主菜单
    for i=1,table.getn(self._tHorizontalMainMap) do
        local funcBtn = self:getFuncBtnByDesc(self._tHorizontalMainMap[i].FuncId)
        if funcBtn == nil then
            funcBtn = require("WorldFuncBtn"):create( self._tHorizontalMainMap[i] )
            self:addChild(funcBtn,0)
            table.insert(self._tHorizontalMainFuncBtnMap , funcBtn)
        end 
        if self._kState == 2 then
            funcBtn:setStateAble()
        end
        funcBtn:setDelegate(self)
        funcBtn:setPoints(
            cc.p(disPointX - (i) * offset - 10, disPointY), 
            cc.p(disPointX, disPointY)
        )
        funcBtn:setCallback(mainActionFunc[self._tHorizontalMainMap[i].FuncId])
    end

    -- 水平更多菜单
    for i=1,table.getn(self._tHorizontalMoreMap) do
        local funcBtn = self:getFuncBtnByDesc(self._tHorizontalMoreMap[i].FuncId)
        if funcBtn == nil then
            funcBtn = require("WorldFuncBtn"):create( self._tHorizontalMoreMap[i] )
            self:addChild(funcBtn,0)
            table.insert(self._tHorizontalMoreFuncBtnMap , funcBtn)
        end 
        if self._kState == 2 then
            funcBtn:setStateDisable()
        end
        funcBtn:setDelegate(self)
        funcBtn:setPoints(
            cc.p(disPointX - (i) * offset - 10, disPointY), 
            cc.p(disPointX, disPointY)
        )
        funcBtn:setCallback(mainActionFunc[self._tHorizontalMoreMap[i].FuncId])
    end

    -- 竖直主菜单
    for i=1,table.getn(self._tVerticalMainMap) do
        local funcBtn = self:getFuncBtnByDesc(self._tVerticalMainMap[i].FuncId)
        if funcBtn == nil then
            funcBtn = require("WorldFuncBtn"):create( self._tVerticalMainMap[i] )
            self:addChild(funcBtn,0)
            table.insert(self._tVerticalMainFuncBtnMap , funcBtn)
        end
        
        if self._kState == 1 then
            funcBtn:setStateAble()
        end
        funcBtn:setDelegate(self)
        funcBtn:setPoints(
            cc.p(disPointX+10, ablePointY + (i-1)* offset + 30), 
            cc.p(disPointX+10, disPointY)
        )
        
        funcBtn:setCallback(mainActionFunc[self._tVerticalMainMap[i].FuncId])
    end

    -- 竖直更多菜单
    for i=1,table.getn(self._tVerticalMoreMap) do
        local funcBtn = self:getFuncBtnByDesc(self._tVerticalMoreMap[i].FuncId)
        if funcBtn == nil then
            funcBtn = require("WorldFuncBtn"):create( self._tVerticalMoreMap[i] )
            self:addChild(funcBtn,0)
            table.insert(self._tVerticalMoreFuncBtnMap , funcBtn)
        end
        
        if self._kState == 1 then
            funcBtn:setStateDisable()
        end
        funcBtn:setDelegate(self)
        funcBtn:setPoints(
            cc.p(disPointX+10, ablePointY + (i-1)* offset + 30), 
            cc.p(disPointX+10, disPointY)
        )
        funcBtn:setCallback(mainActionFunc[self._tVerticalMoreMap[i].FuncId])
    end
end

function WorldMainFuncMenu:getNpcIdByFuncId( funcId )
    for i=1,table.getn(self._tHorizontalMainFuncBtnMap) do
        if self._tHorizontalMainFuncBtnMap[i]._nFuncInfo.FuncId == funcId then
            return self._tHorizontalMainFuncBtnMap[i]
        end
    end 

    for i=1,table.getn(self._tHorizontalMoreFuncBtnMap) do
        if self._tHorizontalMoreFuncBtnMap[i]._nFuncInfo.FuncId  == funcId then
            return self._tHorizontalMoreFuncBtnMap[i]
        end
    end 

    for i=1,table.getn(self._tVerticalMainFuncBtnMap) do
        if self._tVerticalMainFuncBtnMap[i]._nFuncInfo.FuncId  == funcId then
            return self._tVerticalMainFuncBtnMap[i]
        end
    end 

    for i=1,table.getn(self._tVerticalMoreFuncBtnMap) do
        if self._tVerticalMoreFuncBtnMap[i]._nFuncInfo.FuncId  == funcId then
            return self._tVerticalMoreFuncBtnMap[i]
        end
    end 
    
    return nil
end

function WorldMainFuncMenu:getFuncBtnByDesc(funcId)
    for i=1,table.getn(self._tHorizontalMainFuncBtnMap) do
        if self._tHorizontalMainFuncBtnMap[i]._nFuncInfo.FuncId  == funcId then
            return self._tHorizontalMainFuncBtnMap[i]
        end
    end 

    for i=1,table.getn(self._tHorizontalMoreFuncBtnMap) do
        if self._tHorizontalMoreFuncBtnMap[i]._nFuncInfo.FuncId  == funcId then
            return self._tHorizontalMoreFuncBtnMap[i]
        end
    end 

    for i=1,table.getn(self._tVerticalMainFuncBtnMap) do
        if self._tVerticalMainFuncBtnMap[i]._nFuncInfo.FuncId  == funcId then
            return self._tVerticalMainFuncBtnMap[i]
        end
    end 

    for i=1,table.getn(self._tVerticalMoreFuncBtnMap) do
        if self._tVerticalMoreFuncBtnMap[i]._nFuncInfo.FuncId  == funcId then
            return self._tVerticalMoreFuncBtnMap[i]
        end
    end 
    
    return nil
end

-- 新开启功能提示动画
function WorldMainFuncMenu:showNewFuncAni()
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

function WorldMainFuncMenu:setStateAble( )
	self._kState = STATE_ABLE
end

function WorldMainFuncMenu:setStateDisable( )
	self._kState = STATE_DISABLE
end

function WorldMainFuncMenu:setTouchAble(visible)
	self._bTouchAble = visible
end

function WorldMainFuncMenu:getState( )
	return self._kState
end

function WorldMainFuncMenu:setKeyPress(arg)
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

function WorldMainFuncMenu:resetPos()
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

function WorldMainFuncMenu:changeState(  )
    if self._kState == STATE_ABLE then
        self._kState = STATE_DISABLE
    else
        self._kState = STATE_ABLE
    end

	for i=1,table.getn(self._tHorizontalMainFuncBtnMap) do
        self._tHorizontalMainFuncBtnMap[i]:changeState()
    end

    for i=1,table.getn(self._tHorizontalMoreFuncBtnMap) do
        self._tHorizontalMoreFuncBtnMap[i]:changeState()
    end

    for i=1,table.getn(self._tVerticalMainFuncBtnMap) do
        self._tVerticalMainFuncBtnMap[i]:changeState()
    end

    for i=1,table.getn(self._tVerticalMoreFuncBtnMap) do
        self._tVerticalMoreFuncBtnMap[i]:changeState()
    end
end

-- 退出函数
function WorldMainFuncMenu:onExitWorldMainFuncMenu()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return WorldMainFuncMenu
