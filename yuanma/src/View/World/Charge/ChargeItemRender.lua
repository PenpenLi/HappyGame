--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChargeItemRender.lua
-- author:    wuquandong
-- created:   2015/08/06
-- descrip:   充值面板格子
--===================================================
local ChargeItemRender = class("ChargeItemRender",function () 
	return ccui.ImageView:create()
end)

function ChargeItemRender:ctor()
	self._strName = "ChargeItemRender"
	self._pBg = nil 
	self._pCCS = nil 
	self._pBuyBtn = nil 
	self._pNumText = nil 
	-------------------
	self._pDataInfo = nil 
end

function ChargeItemRender:create(chargeItem)
	local render = ChargeItemRender.new()
	render:dispose(chargeItem)
	return render
end

function ChargeItemRender:dispose(chargeItem)	
    NetRespManager:getInstance():addEventListener(kNetCmd.kGenerateOrderSussess, handler(self,self.handlerMsgGenerateOrderSussess))

	local params = require("RmbBGParams"):create()
	self._pBuyBtn = params._pBuyButton
	self._pBg = params._pBG
	self._pCCS = params._pCCS
	self._pNumText = params._pText
	self:addChild(self._pCCS)

	self._pDataInfo = chargeItem
	local function touchEvent (sender,eventType)
	   if eventType == ccui.TouchEventType.ended then
			-- 充值
            local channelId = 1 -- mmo.HelpFunc:getPlatform()
            ShopSystemCGMessage:GenerateOrder(channelId,self._pDataInfo.productId)
       elseif eventType == ccui.TouchEventType.began then
     	    AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pBuyBtn:addTouchEventListener(touchEvent)
	self:updateUI()
	
    ------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitChargeItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function ChargeItemRender:updateUI()
	self._pNumText:setString(self._pDataInfo.diamond)
	self._pBuyBtn:setTitleText(self._pDataInfo.rmb)
end

function ChargeItemRender:onExitChargeItemRender()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

function ChargeItemRender:setData(dataInfo)
	self._pDataInfo = dataInfo
	self:updateUI()
end

function ChargeItemRender:handlerMsgGenerateOrderSussess(event)
    if self._pDataInfo.productId == event.body.argsBody.rechargeId then
        mmo.HelpFunc:payZTGame(self._pDataInfo.moneyName,self._pDataInfo.productName,self._pDataInfo.productId,
            self._pDataInfo.rmb,self._pDataInfo.exchageRate,self._pDataInfo.isMonthCard,event.body.extraData)
    end
end

return ChargeItemRender