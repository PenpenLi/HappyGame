--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ActivityHandler.lua
-- author:    wuqd
-- created:   2015/04/23
-- descrip:   活动handler
--===================================================
local ActivityHandler = class("ActivityHandler")

-- 构造函数
function ActivityHandler:ctor()
	-- 获取活动列表回复22501
	NetHandlersManager:registHandler(22501, self.handleMsgQueryActivityListResp22501)
	-- 领取累积充值回复22503
	NetHandlersManager:registHandler(22503, self.handleMsgAmassAwardResp22503)
	-- 领取在线奖励回复22505
	NetHandlersManager:registHandler(22505, self.handleMsgGainOnlineAwardResp22505)
	-- 领取兑换码的奖励回复21319
	NetHandlersManager:registHandler(21319, self.handleMsgExchangeCodeResp21319)
	-- 领取等级礼包的回复22507
	NetHandlersManager:registHandler(22507, self.handleMsgGainLevelGiftResp22507)
	-- 领取首充的回复22509
	NetHandlersManager:registHandler(22509, self.handleMsgGainFCGiftResp22509) 
    -- 月签到
    NetHandlersManager:registHandler(22511, self.handleMsgMonthSignResp22511) 
    -- 领取体力礼包
    NetHandlersManager:registHandler(22513, self.handleMsgGainPowerResp22513)
end

-- 创建函数
function ActivityHandler:create()
	local handler = ActivityHandler.new()
	return handler
end

-- 获取活动状态列表回复
function ActivityHandler:handleMsgQueryActivityListResp22501(msg)
	print("ActivityHandler 22501")
	if msg.header.result == 0 then
		local  manager =  ActivityManager:getInstance()
		-- 已经领取过奖励的列表
		manager._tActivityStateInfoList = msg.body.actList
		---------- 【在线奖励的状态信息】---------------------------------------
		local tOnlineGiftState = msg.body.onlineAward
		-- 已经领取过奖励的列表
		manager._tCompleteOnlineGiftList = tOnlineGiftState.getAwardList
		-- 在线时长
		manager:setOnlineTime(tOnlineGiftState.onlineTime)
		-- 获取与当前记时礼包索引
		manager:getCurOnlineGiftIndex()
		-- NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryOnlineAwardResp,{})
		----------- 【等级礼包的状态信息】----------------------------------------------
		local tLevelGift = msg.body.levelAward
		-- 等级礼包的领取状态
		manager._tCompleteLevelGiftList = tLevelGift.getAwardList
		-------------【首充奖励状态信息】----------------------------------------------
		manager._nFirstChargeState = msg.body.firstAward.state
		-------------【体力赠送状态信息】----------------------------------------------
		manager._tPhysicalGiftState = msg.body.powerGiveAward.stateList
        --月签到
        manager._pMonthSignAward = msg.body.monthSignAward.monthSignAward
        manager._nMonth = msg.body.monthSignAward.month
        manager._nMonthDayCount = msg.body.monthSignAward.monthDays
        manager._nTheDay = msg.body.monthSignAward.theDay
        manager._nSignCount = msg.body.monthSignAward.signCount
        manager._nSignVip = msg.body.monthSignAward.daySign
        manager._nReSignCount = msg.body.monthSignAward.addSignCount

        --累积充值奖励 lzx
        manager.tAmassAward = msg.body.amassAward
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 领取在线奖励的礼包的回复
function ActivityHandler:handleMsgGainOnlineAwardResp22505(msg)
	print("ActivityHandler 22505")
	if msg.header.result == 0 then 
		--NoticeManager:getInstance():showSystemMessage("领取奖励成功")
        table.insert(ActivityManager:getInstance()._tCompleteOnlineGiftList, msg.body.argsBody.index)
		local nIndex = msg.body.argsBody.index + 1		
		local event = 
		{
			index = nIndex
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainOnlineAwardResp,event)

		-- 获得物品弹框
		local pOnlineRewardInfo = ActivityManager:getInstance()._tOnlineGiftLocalList[nIndex]
		-- 组装数据
		local pArgs = {["finances"] = {},["items"] = {}}
		for i,pReward in ipairs(pOnlineRewardInfo.Reward) do
			if pReward[1] > kFinance.kNone and pReward[1] < kFinance.kFC then 
				-- 表示金融货币
				table.insert(pArgs.finances,{finance = pReward[1], amount = pReward[2]})
			else -- 物品
				local temp = {id = pReward[1], baseType = pReward[3], value = pReward[2]}
				table.insert(pArgs.items, GetCompleteItemInfo(temp))	
			end
		end

    	DialogManager:getInstance():showDialog("GetItemsDialog",pArgs)
	else
		print("返回错误码："..msg.header.result)
	end

end

-- 领取兑换码的网络回复 
function ActivityHandler:handleMsgExchangeCodeResp21319(msg)
	print("ActivityHandler 21319")
	if msg.header.result == 0 then 
		DialogManager:getInstance():showDialog("GetItemsDialog",msg.body.awards)
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 领取等级礼包的回复
function ActivityHandler:handleMsgGainLevelGiftResp22507(msg)
	print("ActivityHandler 22507")
	if msg.header.result == 0 then 
		table.insert(ActivityManager:getInstance()._tCompleteLevelGiftList, msg.body.argsBody.index)
		local nIndex = msg.body.argsBody.index + 1		
		local event = 
		{
			index = nIndex
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainLevelGiftResp,event)

		-- 获得物品弹框
		local pLevelRewardInfo = TableLevelGift[nIndex]
		-- 组装数据
		local pArgs = {["finances"] = {},["items"] = {}}
		for i,pReward in ipairs(pLevelRewardInfo.Reward) do
			if pReward[1] > kFinance.kNone and pReward[1] < kFinance.kFC then 
				-- 表示金融货币
				table.insert(pArgs.finances,{finance = pReward[1], amount = pReward[2]})
			else -- 物品
				local temp = {id = pReward[1], baseType = pReward[3], value = pReward[2]}
				table.insert(pArgs.items, GetCompleteItemInfo(temp))	
			end
		end

    	DialogManager:getInstance():showDialog("GetItemsDialog",pArgs)
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 领取首充的回复
function ActivityHandler:handleMsgGainFCGiftResp22509(msg)
	print("ActivityHandler 22509")
	if msg.header.result == 0 then 
		ActivityManager:getInstance()._nFirstChargeState = msg.body.frinfo.state
		-- 组装数据
		local pArgs = {finances = {}, items = {}}
		for i,pReward in ipairs(TableFirstRecharge[1].Reward) do
			if pReward[1] > kFinance.kNone and pReward[1] < kFinance.kFC then 
				-- 表示金融货币
				table.insert(pArgs.finances,{finance = pReward[1], amount = pReward[2]})
			else -- 物品
				local temp = {id = pReward[1], baseType = pReward[3], value = pReward[2]}
				table.insert(pArgs.items, GetCompleteItemInfo(temp))	
			end
		end
    	DialogManager:getInstance():showDialog("GetItemsDialog",pArgs)
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainFCGiftResp,event)
	else
		print("返回错误码："..msg.header.result)
	end
end

function ActivityHandler:handleMsgMonthSignResp22511(msg)
    print("ActivityHandler 22511")
    if msg.header.result == 0 then 
        if msg.body.signVip == true then
            ActivityManager:getInstance()._nSignVip = kSignState.kVip
        else
            ActivityManager:getInstance()._nSignVip = kSignState.kNormal
        end

        ----------------------------------弹出获得物品界面------------------------------------------
        local tInfo = {["finances"]={},["items"]={}}
	    for i = ActivityManager:getInstance()._nSignCount+1 ,msg.body.signCount do 
	        local monthsSignInfo = TableMonthSign[i]
	        if monthsSignInfo ~= nil then
	            local vipDoubleLevel = monthsSignInfo.VipLevel
	            local Rewards = monthsSignInfo.Reward
	            for i=1,table.getn(monthsSignInfo.Reward) do
	            	if monthsSignInfo.Reward[i][1] <99 then
	            		local beExist = false
	            	    for j=1,table.getn(tInfo.finances) do
	            	    	if tInfo.finances[j].finance == monthsSignInfo.Reward[i][1] then
	            	    		tInfo.finances[j].amount = tInfo.finances[j].amount + ((vipDoubleLevel <= RolesManager._pMainRoleInfo.vipInfo.vipLevel) and monthsSignInfo.Reward[i][2] * 2 or monthsSignInfo.Reward[i][2])
	            	    		beExist = true
	            	    	end
	            	    end
	            	  	
	            	  	if beExist == false then
	            	  		table.insert(tInfo.finances , {finance = monthsSignInfo.Reward[i][1] , 
	            			amount = (vipDoubleLevel <= RolesManager._pMainRoleInfo.vipInfo.vipLevel) and monthsSignInfo.Reward[i][2] * 2 or monthsSignInfo.Reward[i][2]})
	            	  	end
	            	else
	            		local beExist = false
	            		for j=1,table.getn(tInfo.items) do
	            	    	if tInfo.items[j].id == monthsSignInfo.Reward[i][1] then
	            	    		tInfo.items[j].value = tInfo.items[j].value + ((vipDoubleLevel <= RolesManager._pMainRoleInfo.vipInfo.vipLevel) and monthsSignInfo.Reward[i][2] * 2 or monthsSignInfo.Reward[i][2])
	            	    		beExist = true
	            	    	end
	            	    end
	            	    if beExist == false then
	            	  		table.insert(tInfo.items , {baseType = monthsSignInfo.Reward[i][3], id = monthsSignInfo.Reward[i][1], 
	            			value = (vipDoubleLevel <= RolesManager._pMainRoleInfo.vipInfo.vipLevel) and monthsSignInfo.Reward[i][2] * 2 or monthsSignInfo.Reward[i][2]})
	            	  	end
	            	end
	            end
	        end
	    end
	    -- 如果是补充vip等级提升的签到
	    if ActivityManager:getInstance()._nSignCount == msg.body.signCount and ActivityManager:getInstance()._nSignVip == kSignState.kVip then
	    	local monthsSignInfo = TableMonthSign[ActivityManager:getInstance()._nSignCount]
	    	if monthsSignInfo ~= nil then
	    		local Rewards = monthsSignInfo.Reward
	    		for i=1,table.getn(monthsSignInfo.Reward) do
	            	if monthsSignInfo.Reward[i][1] <99 then
	            		
	            	  		table.insert(tInfo.finances , {finance = monthsSignInfo.Reward[i][1] , 
	            			amount = monthsSignInfo.Reward[i][2]})
	            	  	
	            	else
	            		
	            	  		table.insert(tInfo.items , {baseType = monthsSignInfo.Reward[i][3], id = monthsSignInfo.Reward[i][1], 
	            			value = monthsSignInfo.Reward[i][2]})
	            	  	
	            	end
	            end
	    	end
	    end

	    DialogManager:getInstance():showDialog("GetItemsDialog",tInfo)
	    ------------------------------------------------------------------------------------------
        
        ActivityManager:getInstance()._nSignCount = msg.body.signCount
        ActivityManager:getInstance()._nReSignCount = msg.body.addSignCount
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kMonthSign,{})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 领取体力礼包的回复
function ActivityHandler:handleMsgGainPowerResp22513(msg)
	print("ActivityHandler 22512")
    if msg.header.result == 0 then 
       	ActivityManager:getInstance()._tPhysicalGiftState[msg.body.argsBody.index + 1] = 2
       	-- 更新玩家的体力
       	RolesManager._pMainRoleInfo.strength = msg.body.rolePower  
      	-- 更新玩家的体力 
       	NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo,{})
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainPowerResp,{})
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 累积充值奖励
function ActivityHandler:handleMsgAmassAwardResp22503(msg)
	print("ActivityHandler 22502")
	local manager = ActivityManager:getInstance()
	if msg.header.result == 0 then
		--更新本地已经领过的累积奖励数据
		local list = manager.tAmassAward.gainAwards
		list[#list + 1] = manager.nCurrentAward
		
		print("累积充值奖励,领奖成功,打印已经领奖的ID")
		print_lua_table(list)
		
		--向界面发送显示效果
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kAmassAwardResp,{})
    else
    	manager.nCurrentAward = -1
        print("返回错误码："..msg.header.result)
    end
end

return ActivityHandler