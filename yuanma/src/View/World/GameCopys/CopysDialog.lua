--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CopysDialog.lua
-- author:    liyuhang
-- created:   2015/2/3
-- descrip:   副本
--===================================================
local CopysDialog = class("CopysDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function CopysDialog:ctor()
    self._strName = "CopysDialog"               -- 层名称

    self._pBg = nil
    self._pCloseButton = nil
    self._pPowerBar = nil
    self._pFrameTitle = nil
     
    self._sBgContSize = nil                     --背景框的size
    self._recBg = nil
    
    self._pSelectedCopysDataInfo = nil          -- 已经选中的副本关卡的数据信息
    self._pSelectedCopysFirstMapInfo = nil      -- 已经选中的副本关卡的第一张地图信息
    
    self._pItems = {}
    self._pCopysType = {}                       -- 副本类型
    
end

-- 创建函数
function CopysDialog:create(args)
    local dialog = CopysDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function CopysDialog:dispose(args)
    
    NetRespManager:getInstance():addEventListener(kNetCmd.kEntryBattle ,handler(self, self.entryBattleCopy))
    NetRespManager:getInstance():addEventListener(kNetCmd.kGameCopysScroll ,handler(self, self.scrollToCopyById))
    ResPlistManager:getInstance():addSpriteFrames("MoneyCopysDialog.plist")

    self._pCopysType = args[1]
    -- 加载dialog组件
    local params = require("MoneyCopysDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround                              --一个装备框的大小
    self._pScrollView = params._pBgScrollView
    self._pCloseButton = params._pCloseButton
    self._pPowerBar = params._pPowerBar                          --体力进度条
    self._pCurPower = params._pPowerText1                        --当前体力值
    self._pMaxPower = params._pPowerText2                        --最大体力值
    self._pBuyPowerButton = params._pBuyButton                   --体力购买
    self._pFrameTitle = params._pFrameTitleText
    self:disposeCSB()
    
    --设置体力值
    local roleInfo = RolesManager:getInstance()._pMainRoleInfo
    self._pPowerBar:setPercent(roleInfo.strength/TableConstants.PowerNumLimit.Value * 100)
    self._pCurPower:setString(roleInfo.strength)
    self._pMaxPower:setString("/"..TableConstants.PowerNumLimit.Value)
    --self._pCurPower:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._pMaxPower:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
     
     local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           print("power Buy Button")
            local callback = function()
                --self._pScrollView:jumpToPercentHorizontal(percent)
                self:scrollToCopyById(args[2])
            end

            local action = cc.Sequence:create(cc.DelayTime:create(3.3),cc.CallFunc:create(callback))

            --self:runAction(action)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
      end
    
    self._pBuyPowerButton:addTouchEventListener(onTouchButton)
    

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    self._recBg = cc.rect(x,y,size.width,size.height)


    local switchTabCopys = {}
    switchTabCopys[kType.kCopy.kGold] = TableGoldCopys
    switchTabCopys[kType.kCopy.kStuff] = TableStuffCopys
    switchTabCopys[kType.kCopy.kMaze] = TableMazeCopys
    switchTabCopys[kType.kCopy.kChallenge] = TableChallengeCopys
    switchTabCopys[kType.kCopy.kTower] = TableTowerCopys
    switchTabCopys[kType.kCopy.kMapBoss] = TableMapBossCopys
    local goldAndMaterialCopys = {}
    for i=1, #self._pCopysType do
      goldAndMaterialCopys = joinWithTables(goldAndMaterialCopys,switchTabCopys[self._pCopysType[i]])
    end
  
    -- 根据副本类型查找对应的地图信息
    local switchMapInfoAction = {}
    switchMapInfoAction[kType.kCopy.kGold] = TableGoldCopysMaps
    switchMapInfoAction[kType.kCopy.kStuff] = TableStuffCopysMaps
    switchMapInfoAction[kType.kCopy.kMaze] = TableMazeCopysMaps
    switchMapInfoAction[kType.kCopy.kChallenge] = TableChallengeCopysMaps
    switchMapInfoAction[kType.kCopy.kTower] = TableTowerCopysMaps
    switchMapInfoAction[kType.kCopy.kMapBoss] = TableMapBossCopysMaps
    local nViewWidth  = 330 + (table.getn(goldAndMaterialCopys)-1)*340
    local nViewHeight = self._pScrollView:getContentSize().height
    self._pScrollView:setInnerContainerSize(cc.size(nViewWidth,nViewHeight))

    for i=1,table.getn(goldAndMaterialCopys) do
        local item = require("CopysChallengeItem"):create(goldAndMaterialCopys[i], switchMapInfoAction[goldAndMaterialCopys[i].CopysType][goldAndMaterialCopys[i].MapID])
        item:setPosition((i-1) * 340 , 0)
        item:setSelfPos((i-1) * 340, 0)
        item:setAnchorPoint(cc.p(0.5, 0.5))
        item:setCounts(0, 0)
        item._nIndex = i
        self._pScrollView:addChild(item)
        table.insert(self._pItems,item)
        
        item:setClickCallback(function(dataInfo, mapInfo)
            self._pSelectedCopysDataInfo = dataInfo
            self._pSelectedCopysFirstMapInfo = mapInfo
            MessageGameInstance:sendMessageEntryBattle21002(self._pSelectedCopysDataInfo.ID,0) 
         end)
         
        item:setUpdateCallback(function()
            for i=1,table.getn(self._pItems) do
                self._pItems[i]:setBtnVisible(false)
            end
        end)
        
        
    end
        
    if self._pCopysType[1] ~= nil and self._pCopysType[1] == kType.kCopy.kChallenge then
        self._pFrameTitle:loadTexture("MoneyCopysDialogRes/tzjm1.png",
        ccui.TextureResType.plistType)
    elseif self._pCopysType[1] ~= nil and self._pCopysType[1] == kType.kCopy.kTower then
        self._pFrameTitle:loadTexture("MoneyCopysDialogRes/ptjm25.png",
            ccui.TextureResType.plistType)
    elseif self._pCopysType[1] ~= nil and self._pCopysType[1] == kType.kCopy.kMaze then
        self._pFrameTitle:loadTexture("MoneyCopysDialogRes/mgjm1.png",
            ccui.TextureResType.plistType)
    end
    --[[if args[2] ~= nil then
        local callback = function()
            --self._pScrollView:jumpToPercentHorizontal(percent)
            self:scrollToCopyById(args[2])
        end

        local action = cc.Sequence:create(cc.DelayTime:create(3.3),cc.CallFunc:create(callback))
        
       -- self:scrollToCopyById(args[2])
        self:runAction(action)
    --end]]

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)

        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
        end
        return true
    end
    local function onTouchMoved(touch,event)
        local location = self._pBg:convertTouchToNodeSpace(touch)

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        
    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitInstanceDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function CopysDialog:onExitInstanceDialog()
    self:onExitDialog()

    NetRespManager:getInstance():removeEventListenersByHost(self)
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("MoneyCopysDialog.plist")
end

-- 循环更新
function CopysDialog:update(dt)
    return
end

function CopysDialog:entryBattleCopy()
    if self._pSelectedCopysDataInfo ~= nil and self._pSelectedCopysFirstMapInfo ~= nil then
        --战斗数据组装
        -- 【战斗数据对接】
        local args = {}
        args._strNextMapName = self._pSelectedCopysFirstMapInfo.MapsName
        args._strNextMapPvrName = self._pSelectedCopysFirstMapInfo.MapsPvrName
        args._nNextMapDoorIDofEntity = self._pSelectedCopysFirstMapInfo.Doors[1][1]
        --require("TestMainRoleInfo")    --roleInfo  
        args._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo
        args._nMainPlayerRoleCurHp = nil      -- 从副本进入时，这里为无效值
        args._nMainPlayerRoleCurAnger = nil   -- 从副本进入时，这里为无效值
        args._nMainPetRoleCurHp = nil         -- 从副本进入时，这里为无效值
        args._nCurCopyType =self._pSelectedCopysDataInfo.CopysType
        args._nCurStageID = self._pSelectedCopysDataInfo.ID
        args._nCurStageMapID = self._pSelectedCopysDataInfo.MapID
        args._nBattleId = self._pSelectedCopysDataInfo.ID
        args._fTimeMax = self._pSelectedCopysDataInfo.Timeing
        args._bIsAutoBattle = false
        args._tMonsterDeadNum = {}
        args._nIdentity = 0
        args._tTowerCopyStepResultInfos = {}
        args._pPvpRoleInfo = nil
        args._tPvpRoleMountAngerSkills = {}
        args._tPvpRoleMountActvSkills = {}
        args._tPvpPasvSkills = {}
        args._tPvpPetRoleInfosInQueue = {}
        
        --关闭当前打开的Dialog
 		self:getGameScene():closeDialogByNameWithNoAni("CopysPortalDialog")
        self:getGameScene():closeDialogByNameWithNoAni("CopysDialog")
      
        --切换战斗场景
        LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
        
    end
end

function CopysDialog:scrollToCopyById(event)
    for i=1,table.getn(self._pItems) do
        if self._pItems[i]._pDataInfo.ID == event.id then
            local rect = self._pItems[i]._recBg
            local percent = (rect.x-170)/((table.getn(self._pItems) ) * 340)*100
            self._pScrollView:jumpToPercentHorizontal(percent)
		end
	end
end

-- 显示结束时的回调
function CopysDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function CopysDialog:doWhenCloseOver()
    return
end

return CopysDialog
