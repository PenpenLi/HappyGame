--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CopysItem.lua
-- author:    liyuhang
-- created:   2015/2/3
-- descrip:   副本itemcell
--===================================================
local CopysItem = class("CopysItem",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function CopysItem:ctor()
    self._strName = "CopysItem"        -- 层名称

    self._pDataInfo = nil               -- 副本数据信息
    self._pFirstMapInfo = nil           -- 副本中第一张地图信息
    -- 副本总次数
    self._nTotalCount = 0
    -- 副本当前剩余次数
    self._nCurCount = 0
    -- 副本所需藏宝图的数量
    self._nCastItemNum = 0
    -- 当前所剩藏宝图的数量
    self._nRemainItemNum = 0
    self._pBg = nil
    self._pBgFrame = nil
    self._pEntryBtn = nil
    self._pEntryBtnText = nil
    -- 副本进入次数
    self._pTotalCountText = nil
    -- 消耗体力
    self._pCastCountText = nil
    -- 副本的名字
    self._pInstanceNmaeText = nil
    -- 副本所需藏宝图
    self._pCostItemText = nil 
    self._recBg = nil
    
    self._beLocked = false
    
    self._fClickCallback = nil
    self._fUpdateCallback = nil
    self._nIndex = 0
end

-- 创建函数
function CopysItem:create(dataInfo, mapInfo)
    local dialog = CopysItem.new()
    dialog:dispose(dataInfo, mapInfo)
    return dialog
end

function CopysItem:setBtnVisible(args)
    self._pEntryBtn:setVisible(args)
end

-- 处理函数
function CopysItem:dispose(dataInfo, mapInfo)
    --注册
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryBattleList, handler(self, self.updateQueryBattleList))
    --加载资源
    ResPlistManager:getInstance():addSpriteFrames("MoneyCopysDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("CopysBgLock.plist")

    self._pDataInfo = dataInfo
    self._pFirstMapInfo = mapInfo
    
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:setSelfScaleNormal()
            self._pEntryBtn:setVisible(true)
        elseif eventType == ccui.TouchEventType.moved then
            self:setSelfScaleNormal()
            if self._fUpdateCallback ~= nil then
                self._fUpdateCallback()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self:setSelfScaleSmall()
            if self._fUpdateCallback ~= nil then
                self._fUpdateCallback()
            end
        end
    end

    self._pBgFrame = nil
    self._pBgFrame = ccui.ImageView:create("MoneyCopysDialogRes/tytck1.png",ccui.TextureResType.plistType)
    
    self._pBgFrame:setScale9Enabled(true)
     --   ccui.TextureResType.plistType)
    self._pBgFrame:setPosition(0,0)
    self._pBgFrame:setAnchorPoint(cc.p(0.0, 0.0))
    self:addChild(self._pBgFrame)
    
    self._pBg = nil
    self._pBg = ccui.Button:create(
        "MoneyCopysDialogRes/" .. self._pDataInfo.MapIcon .. ".png",
        "MoneyCopysDialogRes/" .. self._pDataInfo.MapIcon .. ".png",
        "MoneyCopysDialogRes/" .. self._pDataInfo.MapIcon .. ".png",
        ccui.TextureResType.plistType)
    self._pBg:setTouchEnabled(true)
    local size = self._pBg:getContentSize()
    self._pBg:setPosition(17,17)
    self._pBg:setAnchorPoint(cc.p(0.0, 0.0))
   -- self._pBg:setZoomScale(-0.1)
   -- self._pBg:setPressedActionEnabled(true)
    self:addChild(self._pBg)
    self._pBg:addTouchEventListener(onTouchButton)
   
    self._pBgFrame:setContentSize(size.width + 34 , size.height + 34)

    local x,y = self:getPosition()
    local size = self._pBgFrame:getContentSize()
    self._recBg = cc.rect(x,y,size.width,size.height)

    self:initUI()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,pLocal) == false then
            self._pEntryBtn:setVisible(false)
        end
       
        return false
    end
    local function onTouchMoved(touch,event)
        local location = self._pBg:convertTouchToNodeSpace(touch)

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
       
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
            self:onExitInstanceItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function CopysItem:setSelfPos(x, y)
	self._recBg.x = x
    self._recBg.y = y
    
    
end

function CopysItem:setSelfScaleNormal()
    self:setScale(1.0)
    
    self:setPosition(self._recBg.x,self._recBg.y)
end

function CopysItem:setSelfScaleSmall()
    self:setScale(0.9)

    self:setPosition(self._recBg.x+20,self._recBg.y+20)
end

function CopysItem:setCounts(totalCount , curCount)
	self._nTotalCount = totalCount
    self._nCurCount = curCount

    if self._pCurCountTextNum ~= nil then
        self._pCurCountTextNum:setString(self._nCurCount.."/"..self._nTotalCount)
    end

    if curCount == 0 then

        self._pCurCountTextNum:setColor(cRed)
    else

        self._pCurCountTextNum:setColor(cWhite)
    end
end

-- 设置副本
function CopysItem:setNeedItemInfo(nItemId)
    if not nItemId then
        --self._pCostItemText:setVisible(false)
        self._pCostItemText:setString("所需物品:无")
        self._pCostItemTextNum:setString("")
    else 
        self._pCostItemText:setVisible(true)
        self._pCostItemText:setString("宝图：")
        local strMsg = string.format("%d/%d",BagCommonManager:getInstance():getItemNumById(nItemId),self._pDataInfo.ItemNum)
        self._pCostItemTextNum:setString(strMsg)
    end
end

function CopysItem:initUI()
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if RolesManager:getInstance()._pMainRoleInfo.level < self._pDataInfo.RequiredLevel then --等级不足
                NoticeManager:getInstance():showSystemMessage("需玩家等级达到"..self._pDataInfo.RequiredLevel.."级!")
                return
            end
            if self._nCurCount <= 0 then 
                NoticeManager:getInstance():showSystemMessage("今日已无副本次数！")
                return
            end
            if self._pDataInfo.CopysType == kType.kCopy.kStuff and self._pDataInfo.Items ~= nil and
                (BagCommonManager:getInstance():getItemNumById(self._pDataInfo.Items) < self._pDataInfo.ItemNum) then
                NoticeManager:getInstance():showSystemMessage("无藏宝图无法进入！")
                return
            end
            if self._fClickCallback ~= nil then
                self._fClickCallback(self._pDataInfo, self._pFirstMapInfo)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            
        end
    end

    self._pEntryBtn = ccui.Button:create(
        "MoneyCopysDialogRes/common001.png",
        "MoneyCopysDialogRes/common001.png",
        "MoneyCopysDialogRes/common001.png",
        ccui.TextureResType.plistType)
    self._pEntryBtn:setTouchEnabled(true)
    self._pEntryBtn:setPosition(self._recBg.width/2, 60)
    self._pEntryBtn:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self._pEntryBtn)
    self._pEntryBtn:setZoomScale(nButtonZoomScale)
    self._pEntryBtn:setPressedActionEnabled(true)
    self._pEntryBtn:addTouchEventListener(onTouchButton)
    self._pEntryBtn:setVisible(false)
    self._pEntryBtn:setTitleText("进入副本")
    self._pEntryBtn:setTitleFontSize(24)

   -- self._pEntryBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pEntryBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    self._pDescBg = ccui.ImageView:create("MoneyCopysDialogRes/fbjm14.png",ccui.TextureResType.plistType)
    self._pDescBg:setScale9Enabled(true)
    self._pDescBg:setPosition(17,100)
    self._pDescBg:setAnchorPoint(cc.p(0.0, 0.0))
    self:addChild(self._pDescBg)
    
    self._pCastCountText = ccui.Text:create()
    self._pCastCountText:setFontName(strCommonFontName)
    self._pCastCountText:setString("消耗体力:")
    self._pCastCountText:setPosition(self._recBg.width/2-10 ,45)
    self._pCastCountText:setFontSize(20)
    self._pCastCountText:setColor(cWhite)
    --self._pCastCountText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pCastCountText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pCastCountText:setAnchorPoint(cc.p(0.0, 0.0))
    self._pDescBg:addChild(self._pCastCountText)
    
    self._pCastCountTextNum = ccui.Text:create()
    self._pCastCountTextNum:setFontName(strCommonFontName)
    self._pCastCountTextNum:setString(self._pDataInfo.PowerNum)
    self._pCastCountTextNum:setPosition(self._recBg.width/2 + 80 ,45)
    self._pCastCountTextNum:setFontSize(20)
    self._pCastCountTextNum:setColor(cGreen)
    --self._pCastCountTextNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pCastCountTextNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pCastCountTextNum:setAnchorPoint(cc.p(0.0, 0.0))
    --self._pCastCountTextNum:setFontName(strCommonFontName)
    self._pDescBg:addChild(self._pCastCountTextNum)
    
    self._pCurCountText = ccui.Text:create()
    self._pCurCountText:setFontName(strCommonFontName)
    self._pCurCountText:setString("剩余次数:")
    self._pCurCountText:setPosition(5,45)
    self._pCurCountText:setAnchorPoint(cc.p(0.0, 0.0))
    self._pCurCountText:setFontSize(20)
    self._pCurCountText:setColor(cWhite)
    --self._pCurCountText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pCurCountText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pDescBg:addChild(self._pCurCountText)
    
    self._pCurCountTextNum = ccui.Text:create()
    self._pCurCountTextNum:setFontName(strCommonFontName)
    self._pCurCountTextNum:setString("0/0")
    self._pCurCountTextNum:setPosition(5 + 90,45)

    --self._pCurCountTextNum:setFontName(strCommonFontName)
    self._pCurCountTextNum:setAnchorPoint(cc.p(0.0, 0.0))
    self._pCurCountTextNum:setFontSize(20)
    self._pCurCountTextNum:setColor(cGreen)
    --self._pCurCountTextNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pCurCountTextNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pDescBg:addChild(self._pCurCountTextNum)

    self._pCostItemText = ccui.Text:create()
    self._pCostItemText:setFontName(strCommonFontName)
    self._pCostItemText:setPosition(cc.p(5,10))
    self._pCostItemText:setFontSize(20)
    self._pCostItemText:setAnchorPoint(cc.p(0.0, 0.0))
    self._pCostItemText:setColor(cWhite)
    --self._pCostItemText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pCostItemText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pCostItemText:setString("所需物品:无")
    self._pDescBg:addChild(self._pCostItemText)
    
    self._pCostItemTextNum = ccui.Text:create()
    self._pCostItemTextNum:setFontName(strCommonFontName)
    self._pCostItemTextNum:setPosition(cc.p(65,10))
    self._pCostItemTextNum:setFontSize(20)

    --self._pCostItemTextNum:setFontName(strCommonFontName)
    self._pCostItemTextNum:setAnchorPoint(cc.p(0.0, 0.0))
    self._pCostItemTextNum:setColor(cBlue)
    --self._pCostItemTextNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pCostItemTextNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pCostItemTextNum:setString("")
    self._pDescBg:addChild(self._pCostItemTextNum)
    
    self._pNameBg = ccui.ImageView:create("MoneyCopysDialogRes/fbjm3.png",ccui.TextureResType.plistType)
    self._pNameBg:setPosition(self._recBg.width/2,self._recBg.height - 55)
    self._pNameBg:setAnchorPoint(cc.p(0.5, 0.5))
    self._pNameBg:setScale9Enabled(true)
    self._pNameBg:setContentSize(236,57)
    self:addChild(self._pNameBg)

    self._pInstanceNmaeText = ccui.Text:create()
    self._pInstanceNmaeText:setString(self._pDataInfo.Name)
    self._pInstanceNmaeText:setPosition(self._recBg.width/2,self._recBg.height - 55)
    self._pInstanceNmaeText:setFontSize(24)
    self._pInstanceNmaeText:setFontName(strCommonFontName)
    self._pInstanceNmaeText:setColor(cWhite)
    --self._pInstanceNmaeText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pInstanceNmaeText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pInstanceNmaeText:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self._pInstanceNmaeText)

    self:setNeedItemInfo(self._pDataInfo.Items)
    
     
end


-- 退出函数
function CopysItem:onExitInstanceItem()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("MoneyCopysDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("CopysBgLock.plist")
end

function CopysItem:setClickCallback(func)
	self._fClickCallback = func
end

function CopysItem:setUpdateCallback(func)
    self._fUpdateCallback = func
end

function CopysItem:updateQueryBattleList(event)
    local battleList = event.battleExts
    
    local isLocked = true 
    
    for i=1,table.getn(battleList) do
        if battleList[i].battleId == self._pDataInfo.ID then
            self:setCounts(battleList[i].extCount + self._pDataInfo.Times, battleList[i].currentCount)
            self:setNeedItemInfo(self._pDataInfo.Items)
            isLocked = false
    	end
    end
    
    if isLocked == true then
    	self._beLocked = true
    	
    	self._pDescBg:setVisible(false)
    	self._pCastCountText:setVisible(false)
    	self._pCastCountTextNum:setVisible(false)
    	self._pCurCountText:setVisible(false)
    	self._pCurCountTextNum:setVisible(false)
    	self._pCostItemText:setVisible(false)
    	self._pCostItemTextNum:setVisible(false)
    	
    	self._pCopysLock = cc.CSLoader:createNode("CopysBgLock.csb")
        self._pCopysLock:setPosition(self._recBg.width/2,self._recBg.height/2)
        self:addChild(self._pCopysLock)
        local pCopysLockAct = cc.CSLoader:createTimeline("CopysBgLock.csb")
        pCopysLockAct:gotoFrameAndPlay(0, pCopysLockAct:getDuration(),true)
        pCopysLockAct:setTimeSpeed(0.3)
        self._pCopysLock:runAction(pCopysLockAct)
        
        self._pLock= ccui.ImageView:create("MoneyCopysDialogRes/lock.png",ccui.TextureResType.plistType)
        self._pLock:setScale9Enabled(true)
        self._pLock:setPosition(self._recBg.width/2,self._recBg.height/2)
        self._pLock:setAnchorPoint(cc.p(0.5, 0.5))
        self:addChild(self._pLock)
        
        
        self._pLockTextBg = ccui.ImageView:create("MoneyCopysDialogRes/fbjm14.png",ccui.TextureResType.plistType)
        self._pLockTextBg:setPosition(self._recBg.width/2,100)
        self._pLockTextBg:setScaleY(0.38)
        self._pLockTextBg:setAnchorPoint(cc.p(0.5, 0.5))
        self:addChild(self._pLockTextBg)
        
        
        self._pLockText = ccui.Text:create()
        self._pLockText:setPosition(cc.p(self._recBg.width*0.57,100))
        self._pLockText:setFontSize(25)
        self._pLockText:setAnchorPoint(cc.p(0.9,0.5))
        self._pLockText:setColor(cRed)
        --self._pLockText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        --self._pLockText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        self._pLockText:setString("达到"..self._pDataInfo.RequiredLevel .. "级")
        self._pLockText:setFontName(strCommonFontName)
        self:addChild(self._pLockText)
        
        --解锁字
        self._pLockTextLable = ccui.Text:create()
        self._pLockTextLable:setPosition(cc.p(self._recBg.width*0.65,100))
        self._pLockTextLable:setFontSize(25)
        self._pLockTextLable:setAnchorPoint(cc.p(0, 0.5))
        self._pLockTextLable:setString("解锁")
        self._pLockTextLable:setFontName(strCommonFontName)
        self:addChild(self._pLockTextLable)
        
        self._pBg:setTouchEnabled(false)
        darkNode(self._pBg:getVirtualRenderer():getSprite())
    end
end 

-- 循环更新
function CopysItem:update(dt)
    return
end

-- 显示结束时的回调
function CopysItem:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function CopysItem:doWhenCloseOver()
    return
end

return CopysItem
