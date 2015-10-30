local CumulativeRechargePanel = class("CumulativeRechargePanel", require("BasePanel"))

-- 创建函数
function CumulativeRechargePanel:create()
    local instance = CumulativeRechargePanel.new()
    instance:initialize()
    return instance
end

function CumulativeRechargePanel:initialize()
	CumulativeRechargePanel.super.dispose(self)

	-- [UI部分]
	local params = require("CumulativeRechargeBgParams"):create()
	self._pCCS = params._pCCS
    -- 说明
    self._pIntroductionText = params._pIntroductionText
    -- 活动时间
    self._pTimeText = params._pTimeText
    -- 前往充值按钮
    self._pRechargeButton = params._pRechargeButton
    -- 滚动条
    self._pRechargeScrollView = params._pRechargeScrollView
	self:addChild(self._pCCS)


	-- [逻辑部分]
	self._pRechargeButton:addTouchEventListener(function(sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioManager:getInstance():playEffect("FunctionButton")
	        elseif eventType == ccui.TouchEventType.ended then
	            ShopSystemCGMessage:queryChargeListReq20506()
	            -- 很LOW的关闭方法
				if self.father ~= nil then self.father:close() end
	        end
		end)

	local manager = ActivityManager:getInstance()
	-- 更新时间
	self._pTimeText:setString(manager:getCumulativeRechargeTime())

	-- 已经领过的列表
	self._tGainAwards = manager.tAmassAward.gainAwards
	local gainDict = {}
	for i=1,#self._tGainAwards,1 do
		local id = self._tGainAwards[i]
		gainDict[id] = id
	end
	self._tCells = {}
	-- 设置元素
	local classCell = require("CumulativeRechargeCell")
	if #TableCumulateRecharge > 0 then
        local posY = 0
        for i=1,#TableCumulateRecharge,1 do
    		local cell = classCell.create()
    		local isReceived = false
    		--设置领奖状态
    		if gainDict[TableCumulateRecharge[i].Id] ~= nil then
    			isReceived = true
    		end
    		--设置数据
            cell:setData(TableCumulateRecharge[i],isReceived)
    		local size = cell._pRechargerRewardBg:getContentSize()
    		cell:setPosition(size.width/2, posY - size.height/2)
    		posY = posY - size.height
    		self._pRechargeScrollView:addChild(cell)
    		self._tCells[i] = cell
    	end
        self._pRechargeScrollView:setInnerContainerSize(cc.size(629, math.abs(posY)))
    	for i=1,#self._tCells,1 do
            local cell = self._tCells[i]
            cell:setPositionY(cell:getPositionY() + math.abs(posY))
    	end
    end
    -- 监听获得奖励
    NetRespManager:getInstance():addEventListener(kNetCmd.kAmassAwardResp ,handler(self, self.amassAwardResp))
end

-- 弹出获得金钱和物品
function CumulativeRechargePanel:amassAwardResp()
	local id = ActivityManager:getInstance().nCurrentAward
	if id ~= -1 then
		local pArgs = {["finances"] = {},["items"] = {}}
		for i=1,#self._tCells,1 do
			local cell = self._tCells[i]
			if cell.tData.Id == id then
				local rewards = cell.tData.Reward
				-- 组装数据				
				for i,pReward in ipairs(rewards) do
					if pReward[1] > kFinance.kNone and pReward[1] < kFinance.kFC then 
						-- 表示金融货币
						table.insert(pArgs.finances,{finance = pReward[1], amount = pReward[2]})
					else -- 物品
						local temp = {id = pReward[1], baseType = pReward[3], value = pReward[2]}
						table.insert(pArgs.items, GetCompleteItemInfo(temp))	
					end
				end
				-- 弹出奖励
				DialogManager:getInstance():showDialog("GetItemsDialog", pArgs)
				-- 设置按钮
				cell:setReceived(true)
				break		
			end
		end
	end
	ActivityManager:getInstance().nCurrentAward = -1
end

function CumulativeRechargePanel:onExitPanel()
	self.father = nil
    self:stopAllActions()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return CumulativeRechargePanel
