--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ShopItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/18
-- descrip:   在线礼包模板
--===================================================
local OnlineItemRender = class("OnlineItemRender",function () 
	return ccui.ImageView:create()
end)

function OnlineItemRender:ctor()
	self._strName = "OnlineItemRender"
	-- 挂载节点
	self._pCCS = nil
	-- 背景图片 
	self._pBg = nil 
	-- 达到时间
	self._pTimeInfoText = nil 
	-- 领取奖励按钮
	self._pGetGiftBtn = nil 
	-- 倒计时显示文本
	self._pTimeCountDownText = nil 
	-- 已经领取图标
	self._pCompleteImg = nil 
	-- 提示红点图标
	self._pWarnImg = nil 
	-- 奖励的图标集合
	self._tGiftItemRenderList = {}
	----------------------------
	-- 活动的管理类
	self._pActivityMgr = ActivityManager:getInstance()
	-- 
	self._pDataInfo = nil 
	-- 索引
	self._nIndex = 0
	-- 领奖剩余时间
	self._nRemainTime = 0
end

function OnlineItemRender:create()
	local imageView = OnlineItemRender.new()
	imageView:dispose()
	return imageView
end

function OnlineItemRender:dispose()
	local params = require("ActivityOnLineParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pOnLineBg
	self._pTimeInfoText = params._pTimeText1
	self._pTimeCountDownText = params._pTimeIng
	self._pGetGiftBtn = params._pOkButton
	self._pWarnImg = params._pTiShiPic
	self._pCompleteImg = params._pYlqPic
	self._tGiftItemRenderList = 
	{
		{img = params._pRewardIcon1, numText = params._pRewardNum1, dataInfo = nil },
		{img = params._pRewardIcon2, numText = params._pRewardNum2, dataInfo = nil },
		{img = params._pRewardIcon3, numText = params._pRewardNum3, dataInfo = nil },
	}
	self:addChild(self._pCCS)

	------------------ 节点事件 -----------------------------
	local function onNodeEvent(event)
		if event == "exit" then 
			self:onExitOnlineItemRender()
		end
	end
	self:registerScriptHandler(onNodeEvent)

end

-- 设置在线礼包的数据
function OnlineItemRender:setData(pDataInfo)
	if not pDataInfo then 
		return
	end
	self._pDataInfo = pDataInfo
    self._pTimeInfoText:setString(pDataInfo.Text)
    -- 设置奖励物品的图标
    self:initTouches()
    -- 领取奖励
    local function touchEvent(sender,eventType)
		if eventType == ccui.ccui.TouchEventType.began then
			AudioManager:getInstance():playEffect("ButtonClick")
		elseif eventType == ccui.ccui.TouchEventType.ended then 
			ActivityMessage:GainOnlineAwardReq22508(self._nIndex)
		end	
	end
	self._pGetGiftBtn:addTouchEventListener(touchEvent)
end

-- 设置点击事件
function OnlineItemRender:initTouches()
	-- 奖励物品图标点击事件
	local function onTouchGoodsIcon(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pTipDialog = nil
            if self._pGoodsDataInfo.itemInfo.baseType ~= kItemType.kEquip then            
                DialogManager:getInstance():showDialog("BagCallOutDialog",{self._tGiftItemRenderList[sender:getTag() - 10000].dataInfo ,nil,nil,false,false})
			else
                DialogManager:getInstance():showDialog("NeverGetEquipCallOutDialog",{self._tGiftItemRenderList[sender:getTag() - 10000].dataInfo})
			end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

	for i,v in ipairs(self._tGiftItemRenderList) do
		if v.isBaseItem == false then 
			--　表示奖励物品是货币
			v.img:loadTexture(v.dataInfo.filename,v.dataInfo.financeIconInfo)
		else
			-- 表示奖励的是普通物品
			v.img:loadTexture(v.dataInfo.templeteInfo.Icon .. ".png",ccui.TextureResType.plistType)
			v.img:setTouchEnabled(true)
			v.img:setTag(i + 10000)
			v.img:addTouchEventListener(onTouchGoodsIcon)
		end
		v.numText:setString(v.dataInfo.value)
	end
end

-- 设置在线活动的状态
function OnlineItemRender:setOnlineGiftState()
 	-- 设置领奖的状态
    self._pWarnImg:setVisible(false)
    self._pGetGiftBtn:setVisible(false)
    self._pTimeCountDownText:setVisible(false)
    self._pCompleteImg:setVisible(false)
    -- 活动还没开始
    --if self._nIndex > self._pActivityMgr._nCurOnlineGiftIndex then
	--	
	--end
	-- 表示活动正在进行中
	if self._nIndex == self._pActivityMgr._nCurOnlineGiftIndex then
    	self._pTimeCountDownText:setVisible(true)
	end
	-- 表示活动已经可以领奖
	if self._nIndex < self._pActivityMgr._nCurOnlineGiftIndex then 
		self._pGetGiftBtn:setVisible(true)
	end
    -- 表示已经领奖
    if self._pActivityMgr:isOnlineGiftIsComplete(self._nIndex) == true then 
    	self._pCompleteImg:setVisible(true)
    end

end

-- 奖励物品的详细数据
function OnlineItemRender:initGiftItemInfo()
	
	for i,pReward in ipairs(self._pItemInfo.Reward) do
		if pReward[1] > kFinance.kNone and pReward[1] < kFinance.kFC then 
			-- 表示金融货币
			self._tGiftItemRenderList[i].dataInfo = FinanceManager:getInstance():getIconByFinanceType(pReward[1])
			self._tGiftItemRenderList[i].dataInfo.value = pReward[2]
			self._tGiftItemRenderList[i].isBaseItem = false
		else -- 物品
			local temp = {id = pReward[1], baseType = pReward[3], value = pReward[2]}
			self._tGiftItemRenderList[i].dataInfo = GetCompleteItemInfo(temp)
			self._tGiftItemRenderList[i].isBaseItem = true
		end
	end
end

--  退出函数
function OnlineItemRender:onExitOnlineItemRender()
	-- cleanup
end

return OnlineItemRender