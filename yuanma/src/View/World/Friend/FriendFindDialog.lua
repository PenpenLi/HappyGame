--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendsFindDialog.lua
-- author:    liyuhang
-- created:   2015/5/18
-- descrip:   好有查找系统面板
--===================================================
local FriendsFindDialog = class("FriendsFindDialog",function()
    return require("Dialog"):create()
end)

local FriendsFindTabTypes = {
    FriendsAdd = 1,
    FriendsRecommend = 2,
}

-- 构造函数
function FriendsFindDialog:ctor()
    -- 层名字
    self._strName = "FriendsFindDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self._pTabBtn = {}
    self._nTabType = FriendsFindTabTypes.FriendsAdd


    self.params = nil
    self._pScheduler = nil
    self._nTime = TableConstants.RecommendFriendsCD.Value

    self._pCells = {}
end

-- 创建函数
function FriendsFindDialog:create(args)
    local layer = FriendsFindDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function FriendsFindDialog:dispose(args)
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateRecommendFriendDatas, handler(self,self.handleMsgUpdateRecommendFriendDatas))
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFriendRoleInfo, handler(self,self.handleMsgkQueryFriendRoleInfo))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetUnFieldPet, handler(self,self.handleMsgUnFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("FindFriendsDialog.plist")

    --self._tPets = args[1]

    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFriendsFindDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function FriendsFindDialog:initUI()
    -- 加载组件
    local params = require("FindFriendsDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    self._pTabBtn[1] = params._pFindButton
    self._pTabBtn[2] = params._pGroomButton

    self._pTabBtn[1]:setTag(1)
    self._pTabBtn[2]:setTag(2)
    self:tabSelectAction(1)

    local function tabButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            self:tabSelectAction(tag)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self.params["_pFindFriendButton"]:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            FriendCGMessage:sendMessageQueryRoleInfoReq22006(self.params._pFindName:getString())
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self.params["_pRefurbishButton"]:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            FriendCGMessage:sendMessageRecommendList22008()
            self:startRefreshCD()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    self._pTabBtn[1]:addTouchEventListener(tabButton)
    self._pTabBtn[2]:addTouchEventListener(tabButton)
    
    self:updateRecommendListData()

    self:disposeCSB()
end

function FriendsFindDialog:tabSelectAction(type)
    self._pTabBtn[1]:loadTextures(
        type == 1 and "FindFriendsDialog/hyjm10.png" or "FindFriendsDialog/hyjm9.png",
        "FindFriendsDialog/hyjm10.png",
        "FindFriendsDialog/hyjm9.png",
        ccui.TextureResType.plistType)
    self._pTabBtn[2]:loadTextures(
        type == 2 and "FindFriendsDialog/hyjm10.png" or "FindFriendsDialog/hyjm9.png",
        "FindFriendsDialog/hyjm10.png",
        "FindFriendsDialog/hyjm9.png",
        ccui.TextureResType.plistType)
        
    if self._nTabType == type then
        --return
    end

    self._nTabType = type
    local action = {
        [FriendsFindTabTypes.FriendsAdd] = function()
            self.params._pFindNode:setVisible(true)
            self.params._pGroomNode:setVisible(false)
        end,
        [FriendsFindTabTypes.FriendsRecommend] = function()
            self.params._pFindNode:setVisible(false)
            self.params._pGroomNode:setVisible(true)
            NewbieManager:showOutAndRemoveWithRunTime()
            
        end,
    }

    action[type]()
end

-- 初始化触摸相关
function FriendsFindDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

function FriendsFindDialog:updateRecommendListData()
    local nUpAndDownDis = 38                             --装备上下与框的间隔
    local nLeftAndReightDis = 3                         --装备左右与框的间隔
    local nSize = 90
    if table.getn(self._pCells) == 0 then
    	for i=1,5 do
            self._pCells[i] = require("FriendGroomCell"):create()
            self._pCells[i]:setPosition(0+nLeftAndReightDis, 250-(100+nUpAndDownDis)*i  )
            self._pCells[i]:setAnchorPoint(cc.p(0,0))
            self._pCells[i]:setVisible(false)
            self.params._pGroomNode:addChild(self._pCells[i])
    	end
    else
        for i=1,5 do
            self._pCells[i]:setVisible(false)
        end
    end

    local rowCount = FriendManager:getInstance()._pRecommendList == nil and 0 or table.getn(FriendManager:getInstance()._pRecommendList)
    local count = rowCount > 3 and 3 or rowCount

    for i = 1,count do
        -- 按照宠物索引 取宠物数据
        local info = FriendManager:getInstance()._pRecommendList[i]
        --local info = nil
        -- 按照宠物索引 取宠物数据
        if info ~= nil then
            self._pCells[i]:setVisible(true)
        end

        self._pCells[i]:setInfo(info)
        --cell:setDelegate(self)
    end
end

function FriendsFindDialog:startRefreshCD()
    self._nTime = TableConstants.RecommendFriendsCD.Value
    self.params["_pRefurbishButton"]:setTouchEnabled(false)
    self.params["_pRefurbishButton"]:setTitleText(self._nTime.."秒")
    local timeUpdate = function (dt)
        self._nTime = self._nTime - 1
        self.params["_pRefurbishButton"]:setTitleText(self._nTime.."秒")
        if self._nTime <= 0 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduler)
            self.params["_pRefurbishButton"]:setTitleText("刷新")
            self.params["_pRefurbishButton"]:setTouchEnabled(true)
            
        end
        
    end
    
    self._pScheduler =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(timeUpdate,1,false)
end

-- 退出函数
function FriendsFindDialog:onExitFriendsFindDialog()
    if self._pScheduler~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduler)
    end
    
    --self.params["_pRefurbishButton"]:setTitleText("刷新")

    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FindFriendsDialog.plist")
end

function FriendsFindDialog:handleMsgUpdateRecommendFriendDatas(event)
    self:updateRecommendListData()
end

function FriendsFindDialog:handleMsgkQueryFriendRoleInfo(event)
    DialogManager:getInstance():showDialog("FriendFindInfoDialog",{event[1]}) 
end



return FriendsFindDialog