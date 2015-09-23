--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DrunkeryHandler.lua
-- author:    wuqd
-- created:   2015/06/29
-- descrip:   酒馆handler
--===================================================
local DrunkeryHandler = class("DrunkeryHandler")

-- 构造函数
function DrunkeryHandler:ctor()
	-- 获取酒坊信息
	NetHandlersManager:registHandler(22101, self.handleMsgOpenDrunkeryDialog22101)
	-- 获取酒坊领奖信息
	NetHandlersManager:registHandler(22103, self.handleMsgGetRewardResp22103)
	-- 获取酒坊立刻完成信息
	NetHandlersManager:registHandler(22105, self.handleMsgOnceCompleteResp22105)
	-- 获取好友酒坊信息
	NetHandlersManager:registHandler(22109, self.handleMsgGetFriendWineryResp22109)
	-- 售卖酒品的回复
    NetHandlersManager:registHandler(22107, self.handleMsgSellWineResp22107)
    -- 喝个痛快回复                                                                              
	NetHandlersManager:registHandler(22111, self.hadleMsgDrinkResp22111)
	-- 一键喝光回复
	NetHandlersManager:registHandler(22113, self.handleMsgAllDrinkResp22113)
end

-- 创建函数
function DrunkeryHandler:create()
	local handler = DrunkeryHandler.new()
	return handler
end

-- 获取酒坊信息回复
function DrunkeryHandler:handleMsgOpenDrunkeryDialog22101(msg)
	print("DrunkeryHandler 22101")
	if msg.header.result == 0 then
		local event = 
		{
			visitors = msg.body.visitors,
			wineId = msg.body.wineId,
			remainSec = msg.body.remainTime,
			visitorCount = msg.body.visitorCount,
			remainDrinkNum = msg.body.remainDrink,
		}
		-- 设置拥有美人的信息
		local beautyModels = BeautyManager:getInstance()._tBeautyModelList
		for k,v in pairs(msg.body.girls) do
			local beauytModel = beautyModels[v.id]
			beauytModel.num = v.num
			beauytModel.level = v.level
			beauytModel.expValue = v.expValue
			beauytModel.haveSeen = true
		end
		DialogManager:getInstance():showDialog("DrunkeryDialog",event) 
	else
		print("返回错误码： "..msg.header.result)
	end
end

-- 领取奖励回复
function DrunkeryHandler:handleMsgGetRewardResp22103(msg)
	print("DrunkeryHandler 22103")
	if msg.header.result == 0 then
		local event = 
		{
			visitorCount = msg.body.visitCount
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kGetWineryRewardResp,event)
		-- 更新玩家的当前经验
		RolesManager:getInstance()._pMainRoleInfo.exp = msg.body.curExp
		-- 更新角色的属性
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
	else
		print("返回错误码： "..msg.header.result)
	end	
end

-- 立即完成回复
function DrunkeryHandler:handleMsgOnceCompleteResp22105(msg)
	print("DrunkeryHandler 22105")
	if msg.header.result == 0 then
		local event = 
		{
           visitorCount = msg.body.visitCount
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kWineryOnceCompleteResp,event)
		-- 更新玩家的当前经验
		RolesManager:getInstance()._pMainRoleInfo.exp = msg.body.curExp
		-- 更新角色的属性
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
	else
		print("返回错误码：".. msg.header.result)
	end
end

-- 获取好友酒坊信息回复
function DrunkeryHandler:handleMsgGetFriendWineryResp22109(msg)
	print("DrunkeryHandler 22109")
	if msg.header.result == 0 then
		local event = 
		{
			friends = msg.body.wineryList,
            remainDrinkNum = msg.body.remainDrink,
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kGetFriendWineryInfoResp,event)
		DialogManager:getInstance():showDialog("FriendDrunkeryDialog",{remainDrinkNum = event.remainDrinkNum,friends = event.friends})		
	else
		print("返回错误码：".. msg.header.result)
	end
end

-- 售卖酒品的回复
function DrunkeryHandler:handleMsgSellWineResp22107(msg)
	print("DrunkeryHandler 22107")
    NewbieManager:showOutAndRemoveWithRunTime()
	if msg.header.result == 0 then
		local event = 
		{
			wineId = msg.body.argsBody.id
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kSellWineResp,event)
	else
		print("返回错误码：".. msg.header.result)
	end	
end

-- 喝个痛快回复
function DrunkeryHandler:hadleMsgDrinkResp22111(msg)
	print("DrunkeryHandler 22111")
	if msg.header.result == 0 then
		local event = 
		{
			friendId = msg.body.argsBody.friendId
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kDrinkResp,event)
		-- 更新玩家的当前经验
		RolesManager:getInstance()._pMainRoleInfo.exp = msg.body.curExp	
		-- 更新角色的属性
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})			
	else
		print("返回错误码：".. msg.header.result)
	end	
end	

-- 一键喝光回复
function DrunkeryHandler:handleMsgAllDrinkResp22113(msg)
	print("DrunkeryHandler 22113")
	if msg.header.result == 0 then
		local event = 
		{	
			drinkIds = msg.body.argsBody.friendIds,
			friendList = msg.body.friendList,
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kAllDrinkResp,event)
		-- 更新玩家的当前经验
		RolesManager:getInstance()._pMainRoleInfo.exp = msg.body.curExp
		-- 更新角色的属性
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})		
	else
		print("返回错误码：".. msg.header.result)
	end	
end	

return DrunkeryHandler