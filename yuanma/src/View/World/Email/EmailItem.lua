--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EmailItem.lua
-- author:    taoye
-- e-mail:    365667276@qq.com
-- created:   2015/05/14
-- descrip:   邮件系统项
--===================================================
local EmailItem = class("EmailItem",function()
	return cc.Node:create()
end)

-- 构造函数
function EmailItem:ctor()
    self._strName = "EmailItem"               -- 名字
    self._fNormalScale = 1.0                  -- 正常大小尺寸
    self._fBigScale = 1.04                    -- 按下时的放大尺寸
    self._pInfo = nil                         -- 具体信息
    self._pItemBg = nil                       -- 邮件背景板
    self._pTypeLabel = nil                    -- 邮件类型label
    self._pTitleLabel = nil                   -- 邮件标题label
    self._pDateLabel = nil                    -- 邮件日期label
    self._pDeleteButton = nil                 -- 邮件删除按钮
    self._pUnReadImage = nil                  -- 邮件未读图标
    self._pReadedImage = nil                  -- 邮件已读图标
    self._pGoodsFlag = nil                    -- 邮件带有附件的图标 
    self._fMoveDis = 0                        -- 每次点击emailItem项时的位移
    
end

-- 创建函数
function EmailItem:create(args)
    local item = EmailItem.new()
	item:dispose(args)
	return item
end

-- 处理函数
function EmailItem:dispose(args)

    NetRespManager:getInstance():addEventListener(kNetCmd.kMailInfo, handler(self,self.handleMsgMailDetailInfo))
    NetRespManager:getInstance():addEventListener(kNetCmd.kMailDeleteSuccess, handler(self,self.handleMsgMailDelete))
    
	-- 初始化界面相关
	self:initUI(args)

	------------------节点事件------------------------------------
	local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEmailItem()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function EmailItem:initUI(args)
    -- 加载组件
    local params = require("EmailItemParams"):create()
    self._pCCS = params._pCCS
    self._pItemBg = params._pItemBg
    self._pTypeLabel = params._pTypeLabel
    self._pTitleLabel = params._pTitleLabel
    self._pDateLabel = params._pDateLabel
    self._pUnReadImage = params._pUnReadImage
    self._pReadedImage = params._pReadedImage
    self._pDeleteButton = params._pDeleteButton
    self._pGoodsFlag = params._pGoodsFlag
    self:addChild(self._pCCS)
    
    self._pUnReadImage:setVisible(false)
    self._pReadedImage:setVisible(false)
    self._pGoodsFlag:setVisible(false)
    
    -- 底板被按下时的处理
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self:toBigScale()
            self._fMoveDis = 0
        elseif eventType == ccui.TouchEventType.moved then
            self._fMoveDis = self._fMoveDis + 1
            if self._fMoveDis >= 5 then
                self:toNormalScale()
            end
        elseif eventType == ccui.TouchEventType.ended then
            if self:getScale() > self._fNormalScale then
                -- 请求邮件详情
                EmailCGMessage:sendMessageGetMailInfo22202(self._pInfo.index)
            end
            self:toNormalScale()
            self._fMoveDis = 0
        end
    end
    self._pItemBg:setSwallowTouches(false)
    self._pItemBg:addTouchEventListener(onTouchBg)
    
    local  onDeleteButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- 删除邮件
            local indexOfList = EmailManager:getInstance():getIndexOfListByInfo(self._pInfo)
            if EmailManager:getInstance():hasGoods(indexOfList) == true then    -- 有附件未领取时，要弹出提示
                DialogManager:getInstance():showAlertDialog("您有附件未领取，无法删除，亲！")
            else    -- 无附件时，可以删除
                -- 请求邮件删除
                EmailCGMessage:sendMessageDeleteMailInfo22204({self._pInfo.index})
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pDeleteButton:addTouchEventListener(onDeleteButton)
    
    -- 记录信息
    self._pInfo = args
    -- 标记是否已读
    self:setIsRead(self._pInfo.isRead)
    -- 标记是否显示附件图标
    self:refreshGoodsFlagVisible()
    -- 设置邮件类型
    self._pTypeLabel:setString(self._pInfo.type)
    -- 设置邮件标题
    self._pTitleLabel:setString(self._pInfo.title)
    -- 设置邮件日期
    local tDate = os.date("*t",self._pInfo.date)
    self._pDateLabel:setString(tDate.year.."年"..tDate.month.."月"..tDate.day.."日")

end

-- 退出函数
function EmailItem:onExitEmailItem()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 获取尺寸
function EmailItem:getContentSize()
    return self._pItemBg:getContentSize()
end

-- 整体到放大尺寸
function EmailItem:toBigScale()
    self:setScale(self._fBigScale)
end

-- 整体到正常尺寸
function EmailItem:toNormalScale()
    self:setScale(self._fNormalScale)
end

-- 设置为未读/已读
function EmailItem:setIsRead(isRead)
    self._pInfo.isRead = isRead     -- 相当于也同时修改了EmailManager中的数据
    self._pUnReadImage:setVisible(not isRead)
    self._pReadedImage:setVisible(isRead)
end

-- 显示/隐藏 附件图标
function EmailItem:refreshGoodsFlagVisible()
    local indexOfList = EmailManager:getInstance():getIndexOfListByInfo(self._pInfo)
    local visible = EmailManager:getInstance():hasGoods(indexOfList)
    self._pGoodsFlag:setVisible(visible)
end

---------------------------------------------------- 网络回调相关 --------------------------------------------------
-- 收到邮件详情信息的处理
function EmailItem:handleMsgMailDetailInfo(event)
    if event.argsBody.index == self._pInfo.index then
        -- 显示邮件内容弹框
        self:setIsRead(true)
        local indexOfList = EmailManager:getInstance():getIndexOfListByInfo(self._pInfo)
        self._pInfo = EmailManager:getInstance()._tEmailInfos[indexOfList]
        DialogManager:getInstance():showDialog("EmailItemContentDialog",self._pInfo)    
    end

end

-- 删除邮件
function EmailItem:handleMsgMailDelete(event)
    for k,v in pairs(event.argsBody.index) do 
        if v == self._pInfo.index then
            -- 先确定下来indexOfList
            local indexOfList = EmailManager:getInstance():getIndexOfListByInfo(self._pInfo)
            if indexOfList ~= 0 then
                DialogManager:getInstance():getDialogByName("EmailDialog"):deleteItem(indexOfList)
            end
            break
        end
    end
    
end

return EmailItem