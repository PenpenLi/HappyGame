--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  LevelGiftItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/10/09
-- descrip:   等级礼包模板
--===================================================
local LevelGiftItemRender = class("LevelGiftItemRender",function () 
	return ccui.ImageView:create()
end)

function LevelGiftItemRender:ctor()
	self._strName = "LevelGiftItemRender"
	-- 挂载节点
	self._pCCS = nil
	-- 背景图片 
	self._pBg = nil 
	-- 领取奖励按钮
	self._pGetGiftBtn = nil 
	-- 已经领取图标
	self._pCompleteImg = nil 
	-- 提示红点图标
	self._pWarnImg = nil 
	-- 奖励的图标集合
	self._tGiftItemRenderList = {}
	-- 等级信息 
	self._pLevelText = nil 
	----------------------------
	-- 活动的管理类
	self._pActivityMgr = ActivityManager:getInstance()
	-- 
	self._pDataInfo = nil 
	-- 索引
	self._nIndex = 0
	
end

function LevelGiftItemRender:create()
	local imageView = LevelGiftItemRender.new()
	imageView:dispose()
	return imageView
end

function LevelGiftItemRender:dispose()
	local params = require("ActivityLvUpParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pOnLineBg
	self._pLevelText = params._pLevelText
	self._pGetGiftBtn = params._pOkButton
	self._pWarnImg = params._pTiShiPic
	self._pCompleteImg = params._pYlqPic
	self._tGiftItemRenderList = 
	{
		{bg = params._pRewardBg1, img = params._pRewardIcon1, numText = params._pRewardNum1, dataInfo = nil },
		{bg = params._pRewardBg2, img = params._pRewardIcon2, numText = params._pRewardNum2, dataInfo = nil },
		{bg = params._pRewardBg3, img = params._pRewardIcon3, numText = params._pRewardNum3, dataInfo = nil },
	}
	self:addChild(self._pCCS)

	------------------ 节点事件 -----------------------------
	local function onNodeEvent(event)
		if event == "exit" then 
			self:onExitLevelGiftItemRender()
		end
	end
	self:registerScriptHandler(onNodeEvent)

end

-- 设置等级礼包的数据
function LevelGiftItemRender:setData(pDataInfo)
	if not pDataInfo then 
		return
	end
	self._pDataInfo = pDataInfo
	self:initGiftItemInfo()
    self._pLevelText:setString("玩家等级达到".. pDataInfo.Level .."级")
    -- 设置奖励物品的图标
    self:initTouches()
    -- 领取奖励
    local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			AudioManager:getInstance():playEffect("ButtonClick")
		elseif eventType == ccui.TouchEventType.ended then 
			ActivityMessage:GainLevelGiftReq22506(self._nIndex)
		end	
	end
	self._pGetGiftBtn:addTouchEventListener(touchEvent)
	self:setGiftState()
end

-- 设置点击事件
function LevelGiftItemRender:initTouches()
	-- 奖励物品图标点击事件
	local function onTouchGoodsIcon(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._tGiftItemRenderList[sender:getTag() - 10000].dataInfo.baseType ~= kItemType.kEquip then            
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
			v.img:loadTexture(v.dataInfo.filename,ccui.TextureResType.plistType)
            v.numText:setString(v.dataInfo.value)
		else
		    if v.dataInfo == nil then 
		        v.img:setVisible(false)
		        v.numText:setVisible(false)
		        v.bg:setVisible(false)
		    else
    			-- 表示奖励的是普通物品
    			v.img:loadTexture(v.dataInfo.templeteInfo.Icon .. ".png",ccui.TextureResType.plistType)
    			v.img:setTouchEnabled(true)
    			v.img:setTag(i + 10000)
    			v.img:addTouchEventListener(onTouchGoodsIcon)
                v.numText:setString(v.dataInfo.value)
			end
		end
		
	end
end

-- 设置等级礼包的状态
function LevelGiftItemRender:setGiftState()
 	-- 设置领奖的状态
    self._pWarnImg:setVisible(false)
    self._pGetGiftBtn:setVisible(false)
    self._pCompleteImg:setVisible(false)
    -- 角色的等级
  	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level 	
  	if self._pDataInfo.Level <= roleLevel then 
  		self._pWarnImg:setVisible(true)
    	self._pGetGiftBtn:setVisible(true)
    end
    if self._pActivityMgr:isLevelGiftIsComplete(self._nIndex) == true then 
    	self._pWarnImg:setVisible(false)
    	self._pGetGiftBtn:setVisible(false)
    	self._pCompleteImg:setVisible(true)
    end
end

-- 奖励物品的详细数据
function LevelGiftItemRender:initGiftItemInfo()
	
	for i,pReward in ipairs(self._pDataInfo.Reward) do
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
function LevelGiftItemRender:onExitLevelGiftItemRender()
	-- cleanup
end

return LevelGiftItemRender