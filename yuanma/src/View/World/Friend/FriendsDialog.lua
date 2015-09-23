--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendsDialog.lua
-- author:    liyuhang
-- created:   2015/4/22
-- descrip:   好有系统面板
--===================================================
local FriendsDialog = class("FriendsDialog",function()
    return require("Dialog"):create()
end)

local FriendsTabTypes = {
    FriendsList = 1,
    FriendsAddRequests = 2,
    FriendsAward = 3,
}

-- 构造函数
function FriendsDialog:ctor()
    -- 层名字
    self._strName = "FriendsDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self._pTabBtn = {}
    self._nTabType = FriendsTabTypes.FriendsList


    self.params = nil

    self._pItems = {}
    
    self._pWarningSpriteFriendList = nil
    self._pWarningSpriteApplyList = nil
    self._pWarningSpriteGiftList = nil
end

-- 创建函数
function FriendsDialog:create(args)
    local layer = FriendsDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function FriendsDialog:dispose(args)
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFriendDatas, handler(self,self.handleMsgkUpdateFriendDatas))
    NetRespManager:getInstance():addEventListener(kNetCmd.kFriendWarning, handler(self,self.handleMsgFriendWarning))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetUnFieldPet, handler(self,self.handleMsgUnFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("FriendListDialog.plist")

    self._tPets = args[1]

    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFriendsDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function FriendsDialog:initUI()
    -- 加载组件
    local params = require("FriendListDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    --self.params._pFriendListScrollView:setInnerContainerSize(self.params._pScrollView:getContentSize())
    --self.params._pFriendListScrollView:setTouchEnabled(true)
    --self.params._pFriendListScrollView:setBounceEnabled(true)
    --self.params._pFriendListScrollView:setClippingEnabled(true)
    
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "好友按钮" , value = false})  

    self._pTabBtn[1] = params._pMyFriendButton
    self._pTabBtn[2] = params._pFriendMessageButton
    self._pTabBtn[3] = params._pGiftsInfoButton

    self._pTabBtn[1]:setTag(1)
    self._pTabBtn[2]:setTag(2)
    self._pTabBtn[3]:setTag(3)
    self:tabSelectAction(1)
    FriendCGMessage:sendMessageQueryFriendList22000()

    self._pWarningSpriteFriendList = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSpriteFriendList:setPosition(0,30)
    self._pWarningSpriteFriendList:setScale(0.6)
    self._pWarningSpriteFriendList:setVisible(false)
    self._pWarningSpriteFriendList:setAnchorPoint(cc.p(0, 0))
    self._pTabBtn[1]:addChild(self._pWarningSpriteFriendList)
    
    self._pWarningSpriteApplyList = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSpriteApplyList:setPosition(0,30)
    self._pWarningSpriteApplyList:setScale(0.6)
    self._pWarningSpriteApplyList:setVisible(false)
    self._pWarningSpriteApplyList:setAnchorPoint(cc.p(0, 0))
    self._pTabBtn[2]:addChild(self._pWarningSpriteApplyList)
    
    self._pWarningSpriteGiftList = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSpriteGiftList:setPosition(0,30)
    self._pWarningSpriteGiftList:setScale(0.6)
    self._pWarningSpriteGiftList:setVisible(false)
    self._pWarningSpriteGiftList:setAnchorPoint(cc.p(0, 0))
    self._pTabBtn[3]:addChild(self._pWarningSpriteGiftList)
    
    if FriendManager:getInstance().friendListFlag == true then
        self._pWarningSpriteFriendList:setVisible(true)
    end
    
    if FriendManager:getInstance().applyListFlag == true then
        self._pWarningSpriteApplyList:setVisible(true)
    end
    
    if FriendManager:getInstance().giftListFlag == true then
        self._pWarningSpriteGiftList:setVisible(true)
    end

    local function tabButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()

            self:tabSelectAction(tag)
            
            if tag == 1 then
                self._pWarningSpriteFriendList:setVisible(false)
                FriendManager:getInstance().friendListFlag = false
            elseif tag == 2 then
                self._pWarningSpriteApplyList:setVisible(false)
                FriendManager:getInstance().applyListFlag = false
            else
                self._pWarningSpriteGiftList:setVisible(false)
                FriendManager:getInstance().giftListFlag = false
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self.params["_pAddFriendButton"]:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            DialogManager:getInstance():showDialog("FriendFindDialog") 
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            
        end
     end)


    self._pTabBtn[1]:addTouchEventListener(tabButton)
    self._pTabBtn[2]:addTouchEventListener(tabButton)
    self._pTabBtn[3]:addTouchEventListener(tabButton)

    self:disposeCSB()
    
    self:updateFriendListData()
    self:updateFriendAwardsData()
    self:updateFriendRequestData()
end

function FriendsDialog:tabSelectAction(type)
    self._pTabBtn[1]:loadTextures(
        type == 1 and "FriendListDialog/hyjm1.png" or "FriendListDialog/hyjm2.png",
        "FriendListDialog/hyjm1.png",
        "FriendListDialog/hyjm2.png",
        ccui.TextureResType.plistType)
    self._pTabBtn[2]:loadTextures(
        type == 2 and "FriendListDialog/hyjm3.png" or "FriendListDialog/hyjm4.png",
        "FriendListDialog/hyjm3.png",
        "FriendListDialog/hyjm4.png",
        ccui.TextureResType.plistType)
    self._pTabBtn[3]:loadTextures(
        type == 3 and "FriendListDialog/hyjm5.png" or "FriendListDialog/hyjm6.png",
        "FriendListDialog/hyjm5.png",
        "FriendListDialog/hyjm6.png",
        ccui.TextureResType.plistType)

    if self._nTabType == type then
        return
    end

    self._nTabType = type
    local action = {
        [FriendsTabTypes.FriendsAddRequests] = function()
            self.params._pFriendListNode:setVisible(false)
            self.params._pFriendMessageNode:setVisible(true)
            self.params._pGiftsInfoNode:setVisible(false)
            
            self.params._pFriendListScrollView:setVisible(false)
            self.params._pFriendMessageScrollView:setVisible(true)
            self.params._pGiftsInfoScrollView:setVisible(false)
            self.params._pListNum:setVisible(false)
            
            --FriendCGMessage:sendMessageQueryApplyFriendList22002()
        end,
        [FriendsTabTypes.FriendsAward] = function()
            self.params._pFriendListNode:setVisible(false)
            self.params._pFriendMessageNode:setVisible(false)
            self.params._pGiftsInfoNode:setVisible(true)
            
            self.params._pFriendListScrollView:setVisible(false)
            self.params._pFriendMessageScrollView:setVisible(false)
            self.params._pGiftsInfoScrollView:setVisible(true)
            self.params._pListNum:setVisible(false)
            
            --FriendCGMessage:sendMessageQueryGiftList22004()
        end,
        [FriendsTabTypes.FriendsList] = function()
            self.params._pFriendListNode:setVisible(true)
            self.params._pFriendMessageNode:setVisible(false)
            self.params._pGiftsInfoNode:setVisible(false)
            
            self.params._pFriendListScrollView:setVisible(true)
            self.params._pFriendMessageScrollView:setVisible(false)
            self.params._pGiftsInfoScrollView:setVisible(false)
            
            self.params._pListNum:setVisible(true)
            --FriendCGMessage:sendMessageQueryFriendList22000()
        end,
    }
    
    

    action[type]()
end

function FriendsDialog:updateFriendListData()
    self.params._pFriendListScrollView:removeAllChildren()
    self._pCells = {}

    local rowCount = FriendManager:getInstance()._pFriendList == nil and 0 or table.getn(FriendManager:getInstance()._pFriendList)
    self.params._pListNum:setString(rowCount.."/"..TableConstants.FriendLimit.Value)
    
    local nUpAndDownDis = 2                             --装备上下与框的间隔
    local nLeftAndReightDis = 3                         --装备左右与框的间隔
    local nSize = 90
    local nViewWidth  = self.params._pFriendListScrollView:getContentSize().width
    local nViewHeight = self.params._pFriendListScrollView:getContentSize().height
    local scrollViewHeight =((nUpAndDownDis+160)*(rowCount) > nViewHeight) and (nUpAndDownDis+160)*(rowCount)   or nViewHeight
    self.params._pFriendListScrollView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))

    for i = 1,rowCount do
        -- 按照宠物索引 取宠物数据
        local info = FriendManager:getInstance()._pFriendList[i]
        --local info = nil
        -- 按照宠物索引 取宠物数据
        local cell = self._pCells[i]
        if not self._pCells[i] then
            cell = require("FriendListInfoCell"):create(info)
        end

        cell:setPosition(304+nLeftAndReightDis, scrollViewHeight-(160+nUpAndDownDis)*i +80 )
        cell:setAnchorPoint(cc.p(0,0))
        self.params._pFriendListScrollView:addChild(cell)
        self._pCells[i] = cell

        --cell:setInfo(info)
        --cell:setDelegate(self)
    end
end

function FriendsDialog:updateFriendRequestData()
    self.params._pFriendMessageScrollView:removeAllChildren()
    self._pCells = {}

    local rowCount = FriendManager:getInstance()._pApplyFriendList == nil and 0 or table.getn(FriendManager:getInstance()._pApplyFriendList) 

    local nUpAndDownDis = 2                             --装备上下与框的间隔
    local nLeftAndReightDis = 3                         --装备左右与框的间隔
    local nSize = 90
    local nViewWidth  = self.params._pFriendMessageScrollView:getContentSize().width
    local nViewHeight = self.params._pFriendMessageScrollView:getContentSize().height
    local scrollViewHeight =((nUpAndDownDis+160)*(rowCount) > nViewHeight) and (nUpAndDownDis+160)*(rowCount)   or nViewHeight
    self.params._pFriendMessageScrollView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))

    for i = 1,rowCount do
        -- 按照宠物索引 取宠物数据
        local info = FriendManager:getInstance()._pApplyFriendList[i]
        
        -- 按照宠物索引 取宠物数据
        local cell = self._pCells[i]
        if not self._pCells[i] then
            cell = require("FriendRequestCell"):create(info)
        end

        cell:setPosition(304+nLeftAndReightDis, scrollViewHeight-(160+nUpAndDownDis)*i +80 )
        cell:setAnchorPoint(cc.p(0,0))
        self.params._pFriendMessageScrollView:addChild(cell)
        self._pCells[i] = cell

        --cell:setInfo(info)
        --cell:setDelegate(self)
    end
end

function FriendsDialog:updateFriendAwardsData()
    self.params._pGiftsInfoScrollView:removeAllChildren()
    self._pCells = {}

    local rowCount = FriendManager:getInstance()._pGiftList == nil and 0 or table.getn(FriendManager:getInstance()._pGiftList) 

    local nUpAndDownDis = 2                             --装备上下与框的间隔
    local nLeftAndReightDis = 3                         --装备左右与框的间隔
    local nSize = 90
    local nViewWidth  = self.params._pGiftsInfoScrollView:getContentSize().width
    local nViewHeight = self.params._pGiftsInfoScrollView:getContentSize().height
    local scrollViewHeight =((nUpAndDownDis+50)*(rowCount) > nViewHeight) and (nUpAndDownDis+50)*(rowCount)   or nViewHeight
    self.params._pGiftsInfoScrollView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))

    for i = 1,rowCount do
        -- 按照宠物索引 取宠物数据
        local info = FriendManager:getInstance()._pGiftList[i]

        -- 按照宠物索引 取宠物数据
        local cell = self._pCells[i]
        if not self._pCells[i] then
            cell = require("FriendGiftMessageCell"):create(info)
        end

        cell:setPosition(nLeftAndReightDis, scrollViewHeight-(50+nUpAndDownDis)*i  )
        cell:setAnchorPoint(cc.p(0,0))
        self.params._pGiftsInfoScrollView:addChild(cell)
        self._pCells[i] = cell

        --cell:setInfo(info)
        --cell:setDelegate(self)
    end
end

-- 初始化触摸相关
function FriendsDialog:initTouches()
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

-- 退出函数
function FriendsDialog:onExitFriendsDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FriendListDialog.plist")
end

function FriendsDialog:handleMsgkUpdateFriendDatas(event)
    local action = {
        [FriendsTabTypes.FriendsAddRequests] = function()
            self:updateFriendRequestData()
        end,
        [FriendsTabTypes.FriendsAward] = function()
            self:updateFriendAwardsData()
        end,
        [FriendsTabTypes.FriendsList] = function()
            self:updateFriendListData()
            
        end,
    }
    
    if table.getn(event) ~= 0 then
        for i=1,table.getn(event) do
            action[event[i]]()
        end
    end
end

-- 处理上阵
function FriendsDialog:handleMsgFieldPet(event)
    self:updateTeamDatas()
end 

-- 处理下阵
function FriendsDialog:handleMsgUnFieldPet(event)
    self:updateTeamDatas()
end


function FriendsDialog:handleMsgFriendWarning(event)
    if self._nTabType ~= event.tag then
        if event.tag == 1 then
            self._pWarningSpriteFriendList:setVisible(true)
        elseif event.tag == 2 then
            self._pWarningSpriteApplyList:setVisible(true)
        else
            self._pWarningSpriteGiftList:setVisible(true)
        end
    end
end


return FriendsDialog