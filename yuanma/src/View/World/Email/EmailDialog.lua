--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EmailDialog.lua
-- author:    taoye
-- e-mail:    365667276@qq.com
-- created:   2015/05/14
-- descrip:   邮件系统弹框
--===================================================
local EmailDialog = class("EmailDialog",function()
	return require("Dialog"):create()
end)

-- 构造函数
function EmailDialog:ctor()
    self._strName = "EmailDialog"               -- 名字
    self._pScrollView = nil                     -- 邮箱的滚动板子
    self._pEmailNum = nil                       -- 邮件数
    self._pDeleteAllReadButton = nil            -- 删除已读按钮
    self._pGetAllGoodsButton = nil              -- 一键领取按钮
    self._tItems = {}                           -- 邮箱条目集合
    self._nInterval = 3                         -- 邮箱滚动容器内信息项之间的像素间隔
    self._nItemHeight = 150                     -- 邮箱中Item的高度

end

-- 创建函数
function EmailDialog:create()
    local layer = EmailDialog.new()
	layer:dispose()
	return layer
end

-- 处理函数
function EmailDialog:dispose()
	-- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kMailDeleteSuccess, handler(self,self.handleMsgMailDelete))
    NetRespManager:getInstance():addEventListener(kNetCmd.kMailGetGoodsSuccess, handler(self,self.handleMsgGetGoodsSuccess))
    
	-- 加载邮箱ui的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("Email.plist")
    ResPlistManager:getInstance():addSpriteFrames("EmailItem.plist")
    ResPlistManager:getInstance():addSpriteFrames("EmailItemContentDialog.plist")

	-- 初始化界面相关
	self:initUI()
    
    -- 初始化邮件项
    self:initItems()
    
	-- 初始化触摸相关
	self:initTouches()
	------------------节点事件------------------------------------
	local function onNodeEvent(event)
	    if event == "exit" then
            self:onExitEmailDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI
function EmailDialog:initUI()
	-- 加载组件
	local params = require("EmailParams"):create()
	self._pCCS = params._pCCS
    self._pBg = params._pBackground
    self._pCloseButton = params._pCloseButton
    self._pScrollView = params._pScrollView
    self._pEmailNum = params._pEmailNum
    self._pDeleteAllReadButton = params._pDeleteAllReadButton
    self._pGetAllGoodsButton = params._pGetAllGoodsButton
	self:disposeCSB()
	
    local  onDeleteAllRead = function (sender, eventType)
        -- 删除已读
        if eventType == ccui.TouchEventType.ended then
            local indexOfList = 1       -- 从列表中的第一项开始
            local needTip = false
            local tDeleteItemsIndex = {}
            while true do
                if self._tItems[indexOfList] == nil then
                    break
                end
                if self._tItems[indexOfList]._pInfo.isRead == true then
                    if self:getEmailManager():hasGoods(indexOfList) == false then
                        table.insert(tDeleteItemsIndex, self:getEmailManager()._tEmailInfos[indexOfList].index)
                    else    -- 发现遍历过程中存在有附件的邮件，则需要给出提示
                        needTip = true
                    end
                end
                indexOfList = indexOfList + 1
            end
            if needTip == true then
                DialogManager:getInstance():showAlertDialog("发现您有未领取附件的已读邮件，暂时帮您保存，亲~")
            end
            -- 请求邮件删除
            if table.getn(tDeleteItemsIndex) ~= 0 then
                EmailCGMessage:sendMessageDeleteMailInfo22204(tDeleteItemsIndex)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            
        end
    end
    self._pDeleteAllReadButton:addTouchEventListener(onDeleteAllRead)
    
    local  onGetAllGoods = function (sender, eventType)
        -- 一键领取
        if eventType == ccui.TouchEventType.ended then
            local indexOfList = 1       -- 从列表中的第一项开始
            local tHasGoodsItemsIndex = {}
            while true do
                if self._tItems[indexOfList] == nil then
                    break
                end
                if self:getEmailManager():hasGoods(indexOfList) == true then
                    table.insert(tHasGoodsItemsIndex, self:getEmailManager()._tEmailInfos[indexOfList].index)
                end
                indexOfList = indexOfList + 1
            end

            -- 请求领取所有附件
            if table.getn(tHasGoodsItemsIndex) ~= 0 then
                if BagCommonManager:getInstance():isBagItemsEnough() then
                    NoticeManager:getInstance():showSystemMessage("背包已满")
                    return 
                end
                EmailCGMessage:sendMessageGetMailGoods22206(tHasGoodsItemsIndex)
            end
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pGetAllGoodsButton:addTouchEventListener(onGetAllGoods)

end

-- 初始化邮件项
function EmailDialog:initItems()
    local itemNum = table.getn(self:getEmailManager()._tEmailInfos)            -- 一共信息条目
    -- 邮件数
    self._pEmailNum:setString("邮件数："..itemNum.."/"..TableConstants.MailMax.Value)
    -- 设置scrollview的滚动尺寸
    self._pScrollView:setInnerContainerSize(cc.size(self._pScrollView:getInnerContainerSize().width,itemNum*(self._nItemHeight+self._nInterval)))
    local scrollViewDisplaySize = self._pScrollView:getContentSize()                -- 滚动容器显示尺寸
    local scrollViewInnerSize = self._pScrollView:getInnerContainerSize()           -- 滚动容器内部滚动尺寸
    -- 初始化所有的条目
    for i = 1, itemNum do
        local item = require("EmailItem"):create(self:getEmailManager()._tEmailInfos[i])
        item:setPositionX(scrollViewDisplaySize.width/2)
        item:setPositionY(scrollViewInnerSize.height - i*(item:getContentSize().height/2 + self._nInterval) - (i-1)*item:getContentSize().height/2)
        self._pScrollView:addChild(item)
        table.insert(self._tItems,item)
    end
    
end

-- 初始化触摸相关
function EmailDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        --self:deleteItem(1)
        --self:deleteAllItems()
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
function EmailDialog:onExitEmailDialog()
    self:onExitDialog()
	-- 释放网络监听事件
	NetRespManager:getInstance():removeEventListenersByHost(self)
	-- 释放掉shop合图资源
    ResPlistManager:getInstance():removeSpriteFrames("Email.plist")
    ResPlistManager:getInstance():removeSpriteFrames("EmailItem.plist")
    ResPlistManager:getInstance():removeSpriteFrames("EmailItemContentDialog.plist")
    
end

-- 删除条目
function EmailDialog:deleteItem(indexOfList)
    self._pScrollView:removeChild(self._tItems[indexOfList], true)
    table.remove(self._tItems, indexOfList)
    self:getEmailManager():deleteEmail(indexOfList)
    self._pEmailNum:setString("邮件数："..table.getn(self:getEmailManager()._tEmailInfos).."/"..TableConstants.MailMax.Value)
    self._pScrollView:setInnerContainerSize(cc.size(self._pScrollView:getInnerContainerSize().width, table.getn(self._tItems)*(self._nItemHeight+self._nInterval)))
    -- 位置刷新动画开始
    for i = 1, table.getn(self._tItems) do
        self._tItems[i]:setPositionY(self._pScrollView:getInnerContainerSize().height - i*(self._tItems[i]:getContentSize().height/2 + self._nInterval) - (i-1)*self._tItems[i]:getContentSize().height/2)
    end
    local hasNewEmail = EmailManager:getInstance():hasNewEmail()
    cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer"):showNewEmail(hasNewEmail)
end

-- 删除所有条目
function EmailDialog:deleteAllItems()
    self._pScrollView:removeAllChildren(true)
    self._tItems = {}
    self:getEmailManager():deleteAllEmails()
    self._pEmailNum:setString("邮件数："..table.getn(self:getEmailManager()._tEmailInfos).."/"..TableConstants.MailMax.Value)
    self._pScrollView:setInnerContainerSize(cc.size(self._pScrollView:getInnerContainerSize().width, table.getn(self._tItems)*(self._nItemHeight+self._nInterval)))
    local hasNewEmail = EmailManager:getInstance():hasNewEmail()
    cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer"):showNewEmail(hasNewEmail)
end

--------------------------------------------------网络回调相关--------------------------------------------------------------------
-- 一键删除已读邮件
function EmailDialog:handleMsgMailDelete(event)
    for k,v in pairs(event.argsBody.index) do 
        local indexOfList = EmailManager:getInstance():getIndexOfListByIndex(v)
        if indexOfList ~= 0 then
            self:deleteItem(indexOfList)
        end
    end
    local hasNewEmail = EmailManager:getInstance():hasNewEmail()
    cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer"):showNewEmail(hasNewEmail)
end

-- 一键领取附件
function EmailDialog:handleMsgGetGoodsSuccess(event)
   local tInfo = {["finances"]={},["items"]={}}
    for k,v in pairs(event.argsBody.index) do 
        local indexOfList = EmailManager:getInstance():getIndexOfListByIndex(v)
        if indexOfList ~= 0 then
            local tGoods = self:getEmailManager()._tEmailInfos[indexOfList].goods
            self:getGetGoodsItemInfo(tInfo,tGoods)
            self:getEmailManager():getGoodsInEmail(indexOfList)
            self._tItems[indexOfList]:refreshGoodsFlagVisible()
            self._tItems[indexOfList]:setIsRead(true)
        end
    end
    local hasNewEmail = EmailManager:getInstance():hasNewEmail()
    cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer"):showNewEmail(hasNewEmail)
    --弹出活儿物品界面
    DialogManager:getInstance():showDialog("GetItemsDialog",tInfo)
end

--添加可以获得物品
function EmailDialog:getGetGoodsItemInfo(tInfo,tGoods)

    if tGoods.finances ~= nil and table.getn(tGoods.finances) ~= 0 then
        for k,v in pairs(tGoods.finances) do
    	  table.insert(tInfo.finances,v)  
        end
    	
    end
    
    if tGoods.items ~= nil and table.getn(tGoods.items) ~= 0 then
        for k,v in pairs(tGoods.items) do
            table.insert(tInfo.items,v)
        end

    end

end


return EmailDialog
