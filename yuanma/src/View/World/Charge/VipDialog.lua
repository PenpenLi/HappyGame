--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  VipDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/06
-- descrip:   Vip弹框
--===================================================
local VipDialog = class("VipDialog",function() 
	return require("Dialog"):create()
end)

function VipDialog:ctor()
	self._strName = "VipDialog"
	self._pVipFntText = nil 
	self._pVipLoadingBar = nil 
	self._pChargeBtn = nil 
	self._pVipPageView = nil 
	self._pPrevPageBtn = nil 
	self._pNextPageBtn = nil 
	self._pVipGifBoxBtn = nil 
	-- eg 400/500
	self._pLoadingText = nil 
	-- eg 还差100即可升级
	self._pLoadingTip = nil 
	-------------------------
	self._tVipBoxState = {}
	self._pVipInfo = nil 
end

function VipDialog:create()
	local dialog = VipDialog.new()
	dialog:dispose()
	return dialog
end

function VipDialog:dispose()
	ResPlistManager:getInstance():addSpriteFrames("VipBG.plist")
	ResPlistManager:getInstance():addSpriteFrames("VipExplain.plist")
	NetRespManager:getInstance():addEventListener(kNetCmd.kGainVipBox, handler(self,self.handlerMsgGainVipBox20509))
	self:initUI()
	self:initTouches()
	----------------节点事件-----------------------------------------------
	local function onNodeEvent()
		if event == "exit" then 
			self:onExitVipDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

function VipDialog:initUI()
	local params = require("VipBGParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pVipLoadingBar = params._pLoadingBar
	self._pVipFntText = params._pVipFnt
	self._pChargeBtn = params._pBackButton
	self._pChargeBtn:setName("backCharge")
	self._pVipPageView = params._pPageView
	self._pVipGifBoxBtn = params._pChestButton
	self._pVipGifBoxBtn:setName("gifBox")
	self._pPrevPageBtn = params._pLeftButton
	self._pPrevPageBtn:setName("prev")
	self._pNextPageBtn = params._pRightButton
	self._pNextPageBtn:setName("next")
	self._pLoadingText = params._pVipText01
	self._pLoadingTip = params._pVipText02
	self:disposeCSB()

	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then 
			if sender:getName() == "prev" then 
				local pageIndex = self._pVipPageView:getCurPageIndex()
				if pageIndex < 1 then 
					return
				end
				self._pVipPageView:scrollToPage(pageIndex - 1)
			end
			if sender:getName() == "next" then 
				local pageIndex = self._pVipPageView:getCurPageIndex()
				self._pVipPageView:scrollToPage(pageIndex + 1)
			end
			if sender:getName() == "gifBox" then 
				local vipLevel = self._pVipPageView:getCurPageIndex() 
				DialogManager:getInstance():showDialog("BoxInfoDialog",{TableVIP[vipLevel + 1].Box,true,boxInfoShowType.kVipDialog,{self._pVipInfo.vipLevel,vipLevel}})
			end
			if sender:getName() == "backCharge" then 
				ShopSystemCGMessage:queryChargeListReq20506()
				self:close()
			end
	    elseif eventType == ccui.TouchEventType.began then
     	    AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pPrevPageBtn:addTouchEventListener(touchEvent)
	self._pNextPageBtn:addTouchEventListener(touchEvent)
    self._pVipGifBoxBtn:addTouchEventListener(touchEvent)
	self._pChargeBtn:addTouchEventListener(touchEvent)
	self:initPageInfoData()
	self:UpdateVipInfo()
end


-- 初始化触摸相关
function VipDialog:initTouches()
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

function VipDialog:initPageInfoData()
	for i,pVipInf in ipairs(TableVIP) do
		local pageView = require("VipItemRender"):create()
		pageView:setDataSource(pVipInf)
		self._pVipPageView:addPage(pageView)
	end
end

function VipDialog:handlerMsgGainVipBox20509(event)
	self._tVipBoxState[event.vipLevel + 1] = true
end

function VipDialog:UpdateVipInfo()
	self._pVipInfo = RolesManager:getInstance()._pMainRoleInfo.vipInfo
	self._tVipBoxState = self._pVipInfo.gainBox
	self._pVipFntText:setString(self._pVipInfo.vipLevel)
	local needReachNum = TableVIP[self._pVipInfo.vipLevel + 1].RechargeNum
	-- 判断Vip 等级是否达到最高级
	if not TableVIP[self._pVipInfo.vipLevel + 1] or TableVIP[self._pVipInfo.vipLevel + 1].RechargeNum == 0 then 
		self._pLoadingText:setString(self._pVipInfo.totalCharge.."/"..self._pVipInfo.totalCharge)
		self._pLoadingTip:setString("Vip以达到满级")
		self._pVipLoadingBar:setPercent(100)
	else
		self._pLoadingText:setString(self._pVipInfo.totalCharge.."/"..needReachNum)
		self._pLoadingTip:setString("还差"..needReachNum - self._pVipInfo.totalCharge.."即可升级")
		self._pVipLoadingBar:setPercent(self._pVipInfo.totalCharge / needReachNum * 100)	
	end	
end


function VipDialog:closeWithAni()
	self:stopAllActions()
    if self._pTouchListener then
        self._pTouchListener:setEnabled(false)
        self._pTouchListener:setSwallowTouches(false)
    end
    self:setTouchEnableInDialog(true)
    self:doWhenCloseOver()
    self:removeAllChildren(true)
    self:removeFromParent(true)
end

function VipDialog:onExitVipDialog()
	self:onExitDialog()
	ResPlistManager:getInstance():removeSpriteFrames("VipBG.plist") 
	ResPlistManager:getInstance():removeSpriteFrames("VipExplain.plist") 
end

return VipDialog