--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PhysicalGiftPanel.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/10/15
-- descrip:   体力赠送
--===================================================
local PhysicalGiftPanel = class("PhysicalGiftPanel",function () 
	return ccui.ImageView:create()
end)

function PhysicalGiftPanel:ctor()
	self._strName = "PhysicalGiftPanel"
	self._pCCS = nil 
	-- 体力奖品1
	self._pGiftOneTimeText = nil  
	self._pGiftOneBtn = nil 
	self._pGiftOneNumText = nil
	self._pGiftOneRedImg = nil 
	self._pGiftOneIcon = nil 
	-- 体力奖品2
	self._pGiftTwoTimeText = nil 
	self._pGiftTwoBtn = nil 
	self._pGiftTwoNumText = nil 
	self._pGiftTwoRedImg = nil 
	self._pGiftTwoIcon = nil 
	-- 提示文字
	self._pTipText = nil 
	---------------------------
	self._tempTip = {
		"施主斋饭还没准备好，请稍后再来！",
		"施主斋饭已好，请记得吃哦！",
		"施主，记得下次再来！"
	}
	self._pDataInfo = nil 
	self._tGiftBtn = {}
end

function PhysicalGiftPanel:create()
	local imageView = PhysicalGiftPanel.new()
	imageView:dispose()
	return imageView
end

function PhysicalGiftPanel:dispose()
	local params = require("PowerGiftParams"):create()
	self._pCCS = params._pCCS
	self._pGiftOneTimeText = params._pPowerTextTime1
	self._pGiftOneNumText = params._pPowerTextNum1
	self._pGiftOneBtn = params._pLQButton1
	self._pGiftOneRedImg = params._pRedPics1
	self._pGiftTwoTimeText = params._pPowerTextTime1_Copy
	self._pGiftTwoNumText = params._pPowerTextNum2
	self._pGiftTwoBtn = params._pLQButton1_Copy
	self._pGiftTwoRedImg = params._pRedPics2
	self._pTipText = params._ptishiText1
	self._pGiftOneIcon = params._pGift1Icon
	self._pGiftTwoIcon = params._pGift2Icon
	self:addChild(self._pCCS)

	self._tGiftBtn[1] = {button = self._pGiftOneBtn, warnIcon = self._pGiftOneRedImg, icon = self._pGiftOneIcon}
	self._tGiftBtn[2] = {button = self._pGiftTwoBtn, warnIcon = self._pGiftTwoRedImg, icon = self._pGiftTwoIcon} 

	-- 领取奖励
    local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			AudioManager:getInstance():playEffect("ButtonClick")
		elseif eventType == ccui.TouchEventType.ended then 
			local giftIndex = sender:getTag() - 5000
			if self._pDataInfo[giftIndex + 1] ~= 1 then 
				NoticeManager:getInstance():showSystemMessage(self._tempTip[self._pDataInfo[giftIndex + 1] + 1])
				return
			end
			-- 领取体力
			ActivityMessage:GainPowerReq22512(sender:getTag() - 5000)
		end	
	end
	self._pGiftOneBtn:addTouchEventListener(touchEvent)
	self._pGiftOneBtn:setTag(5000)
	self._pGiftTwoBtn:addTouchEventListener(touchEvent)
	self._pGiftTwoBtn:setTag(5001)

	NetRespManager:getInstance():addEventListener(kNetCmd.kGainPowerResp,handler(self,self.handleMsgGainPowerResp22513))  

	------------------ 节点事件 -----------------------------
	local function onNodeEvent(event)
		if event == "exit" then 
			self:onExitPhysicalGiftPanel()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	-- 读表显示体力可以领取的时间和增加的体力值
	for  i ,v in ipairs(TableGivePowerNum) do
		if i == 1 then 
		   local strTime = string.format("每天%s-%s领取",v.StartTime,v.EndTime)
		   self._pGiftOneTimeText:setString(strTime)
		   self._pGiftOneNumText:setString(v.PowerNum)
		elseif i == 2 then 
			local strTime = string.format("每天%s-%s领取",v.StartTime,v.EndTime)
		    self._pGiftTwoTimeText:setString(strTime)
		    self._pGiftTwoNumText:setString(v.PowerNum)
		end
	end

end

-- 设置体力赠送的状态
-- 0 表示不可领取，1：表示可以领取，2表示已经领取
-- dataFormat {0,1}
function PhysicalGiftPanel:setData(pDataInfo)
	self._pDataInfo = pDataInfo
	local activityState = 0
	local tempStr = {"未开启","领取","已领取"}
	for i,state in ipairs(pDataInfo) do
		self._tGiftBtn[i].button:setTitleText(tempStr[state + 1])
		self._tGiftBtn[i].warnIcon:setVisible(state == 1)
		activityState = state > activityState and state or activityState
		if state == 1 then 
			unDarkNode(self._tGiftBtn[i].icon:getVirtualRenderer():getSprite())
		else
			darkNode(self._tGiftBtn[i].icon:getVirtualRenderer():getSprite())
		end
	end

	self._pTipText:setString(self._tempTip[activityState + 1])
end

function PhysicalGiftPanel:onExitPhysicalGiftPanel()

end

function PhysicalGiftPanel:handleMsgGainPowerResp22513(event)
	-- 更新体力礼包的领取状态
	self:setData(ActivityManager:getInstance()._tPhysicalGiftState)
end

return PhysicalGiftPanel