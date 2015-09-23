--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EmailItemContentDialog.lua
-- author:    taoye
-- e-mail:    365667276@qq.com
-- created:   2015/05/14
-- descrip:   邮件内容弹框
--===================================================
local EmailItemContentDialog = class("EmailItemContentDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function EmailItemContentDialog:ctor()
    self._strName = "EmailItemContentDialog"               -- 名字
    self._pInfo = nil                                      -- 具体信息
    self._pSenderLabel = nil                               -- 发件人标签
    self._pTitleLabel = nil                                -- 标题标签
    self._pContentLabel = nil                              -- 内容标签
    self._pSenderNameLabel = nil                           -- 发件人姓名
    self._pTitleNameLabel = nil                            -- 标题名称
    self._pMainScrollView = nil                            -- 主要滚动板
    self._pContentsPanel = nil                             -- 文本显示区域
    self._pGoodsPanel = nil                                -- 物品栏基础容器
    self._pGetButton = nil                                 -- 获取按钮
    self._pGoodsScrollView = nil                           -- 物品滚动板

end

-- 创建函数
function EmailItemContentDialog:create(args)
    local layer = EmailItemContentDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数
function EmailItemContentDialog:dispose(args)

    NetRespManager:getInstance():addEventListener(kNetCmd.kMailGetGoodsSuccess, handler(self,self.handleMsgGetGoodsSuccess))

    -- 初始化界面相关
    self:initUI()
    
    -- 记录信息
    self:initInfo(args)
    
    -- 触摸处理
    self:initTouches()
    
    local hasNewEmail = EmailManager:getInstance():hasNewEmail()
    cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer"):showNewEmail(hasNewEmail)

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEmailItemContentDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI
function EmailItemContentDialog:initUI()
    -- 加载组件
    local params = require("EmailItemContentDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackground
    self._pCloseButton = params._pCloseButton
    self._pSenderLabel = params._pSenderLabel
    self._pTitleLabel = params._pTitleLabel
    self._pContentLabel = params._pContentLabel
    self._pSenderNameLabel = params._pSenderNameLabel
    self._pTitleNameLabel = params._pTitleNameLabel
    self._pMainScrollView = params._pMainScrollView
    self._pContentsPanel = params._pContentsPanel
    self._pGoodsPanel = params._pGoodsPanel
    self._pGetButton = params._pGetButton
    self._pGoodsScrollView = params._pGoodsScrollView
    self:disposeCSB()

end

-- 初始化界面UI
function EmailItemContentDialog:initInfo(args)
    self._pInfo = args
    self._pSenderNameLabel:setString(self._pInfo.sender)
    self._pTitleNameLabel:setString(self._pInfo.title)
    self._pContentsPanel:setString(self._pInfo.contents)

    local rowNum = self._pContentsPanel:getVirtualRendererSize().width / self._pContentsPanel:getContentSize().width + 2
    local height = rowNum*(self._pContentsPanel:getFontSize())
    
    local indexOfList = self:getEmailManager():getIndexOfListByInfo(self._pInfo)
    if self:getEmailManager():hasGoods(indexOfList) == true then    -- 有附件
        self._pContentsPanel:setContentSize(cc.size(self._pContentsPanel:getContentSize().width,height))
        self._pMainScrollView:setInnerContainerSize(cc.size(self._pMainScrollView:getInnerContainerSize().width, self._pContentsPanel:getContentSize().height))
        self._pContentsPanel:setPositionY(self._pMainScrollView:getInnerContainerSize().height - (self._pContentsPanel:getContentSize().height/2))

        -- 初始化物品列表
        local scrollviewLength = 0      -- scrollview的长度
        if self._pInfo.goods.finances then
            for kFinance, vFinance in pairs(self._pInfo.goods.finances) do
                local iconInfo = FinanceManager:getInstance():getIconByFinanceType(vFinance.finance)
                local pCell = require("BattleItemCell"):create()
                local info = {}
                info.finance = vFinance.finance
                info.amount = vFinance.amount
                info.fileBigName = iconInfo.fileBigName
                pCell:setFinanceInfo(info)
                pCell:setPosition(cc.p(scrollviewLength-(kFinance-1)*20,35))
                pCell:setScale(0.7)
                self._pGoodsScrollView:addChild(pCell)
                scrollviewLength = scrollviewLength + pCell:getContentSize().width
            end
        end
        if self._pInfo.goods.items then
            for kItem, vItem in pairs(self._pInfo.goods.items) do
                local pCell = require("BattleItemCell"):create()
                local info = GetCompleteItemInfo(vItem)
                pCell:setItemInfo(info)
                pCell:setPosition(cc.p(scrollviewLength-(kItem-1)*20,35))
                pCell:setScale(0.7)
                self._pGoodsScrollView:addChild(pCell)
                scrollviewLength = scrollviewLength + pCell:getContentSize().width
            end
        end
        self._pGoodsScrollView:setInnerContainerSize(cc.size(scrollviewLength, self._pGoodsScrollView:getInnerContainerSize().height))
        
        -- 点击领取物品处理
        local onGetGoods = function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if BagCommonManager:getInstance():isBagItemsEnough() then
                    NoticeManager:getInstance():showSystemMessage("背包已满")
                else
                    EmailCGMessage:sendMessageGetMailGoods22206({self._pInfo.index})
                end
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end
        self._pGetButton:addTouchEventListener(onGetGoods)

    else -- 无附件
        self._pContentsPanel:setContentSize(cc.size(self._pContentsPanel:getContentSize().width,height))
        self._pMainScrollView:setInnerContainerSize(cc.size(self._pMainScrollView:getInnerContainerSize().width, self._pContentsPanel:getContentSize().height))
        self._pContentsPanel:setPositionY(self._pMainScrollView:getInnerContainerSize().height - (self._pContentsPanel:getContentSize().height/2))
        self._pGoodsPanel:removeFromParent(true)
    end

end

-- 初始化触摸相关
function EmailItemContentDialog:initTouches()
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
function EmailItemContentDialog:onExitEmailItemContentDialog()
    self:onExitDialog()
    
    NetRespManager:getInstance():removeEventListenersByHost(self)

end

------------------------------------------网络回调---------------------------------------------------------
-- 领取邮件中附件成功回调
function EmailItemContentDialog:handleMsgGetGoodsSuccess(event)
    for k,v in pairs(event.argsBody.index) do 
        if v == self._pInfo.index then
            -- 获取物品到背包
            local indexOfList = self:getEmailManager():getIndexOfListByInfo(self._pInfo)
            if indexOfList ~= 0 then
                self:getEmailManager():getGoodsInEmail(indexOfList)
            end
            -- 没有异常时，重新调整控件的位置和尺寸，然后物品栏直接消失掉
            self._pMainScrollView:setInnerContainerSize(cc.size(self._pMainScrollView:getInnerContainerSize().width, self._pContentsPanel:getContentSize().height))
            self._pContentsPanel:setPositionY(self._pMainScrollView:getInnerContainerSize().height - (self._pContentsPanel:getContentSize().height/2))
            self._pGoodsPanel:removeFromParent(true)
            -- 刷新ui
            DialogManager:getInstance():getDialogByName("EmailDialog")._tItems[indexOfList]:refreshGoodsFlagVisible()
            break
        end
    end
 
end

return EmailItemContentDialog