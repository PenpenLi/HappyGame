--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageActivity.lua
-- author:    wuqd
-- created:   2015/04/24
-- descrip:   活动【请求消息格式】
--===================================================
ActivityMessage = {}

-- 获取活动列表请求
function ActivityMessage:QueryActivityListReq22500()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22500                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 获取累计充值请求
function ActivityMessage:QueryAmassPayReq22502()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22502                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end	

-- 领取累计充值请求
function ActivityMessage:GainAmassAwardReq22504(nAwardId)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22504                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.awardId = nAwardId								-- 奖品Id
    -------------------------------------
    send(msg)	
end

-- 获取在线奖励的详细信息
function ActivityMessage:QueryOnlineAwardReq22506()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22506                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)	
end

-- 领取在线奖励请求
function ActivityMessage:GainOnlineAwardReq22508(nIndex)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22504                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.index = nIndex									-- 领取第几个奖励
    -------------------------------------
    send(msg)		
end