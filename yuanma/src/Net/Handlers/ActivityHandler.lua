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
	-- 获取在线奖励回复22507
	NetHandlersManager:registHandler(22507, self.handleMsgQueryOnlineAwardResp22507)
	-- 领取在线奖励回复22509
	NetHandlersManager:registHandler(22509, self.handleMsgGainOnlineAwardResp22509)
end

-- 创建函数
function ActivityHandler:create()
	local handler = ActivityHandler.new()
	return handler
end

-- 获取在线奖励的回复
function ActivityHandler:handleMsgQueryOnlineAwardResp22507(msg)
	print("ActivityHandler 22507")
	if msg.header.result == 0 then 
		-- 已经领取过奖励的列表
		ActivityManager:getInstance()_tCompleteOnlineGiftList = msg.body.getAwardList
		-- 在线时长
		ActivityManager:getInstance():setOnlineTime(msg.body.onlineTime)
		-- 获取与当前记时礼包索引
		ActivityManager:getInstance():getCurOnlineGiftIndex()
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryOnlineAwardResp,{})
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 领取在线奖励的礼包的回复
function ActivityHandler:handleMsgGainOnlineAwardResp22509(msg)
	print("ActivityHandler 22509")
	if msg.header.result == 0 then 
		NoticeManager:getInstance():showSystemMessage("领取奖励成功")
		local nIndex = msg.body.argsBody.index
		table.insert(ActivityManager:getInstance()._tCompleteOnlineGiftList, nIndex)
		local event = 
		{
			index = nIndex
		}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainOnlineAwardResp,event)
	else
		print("返回错误码："..msg.header.result)
	end

end

return ActivityHandler