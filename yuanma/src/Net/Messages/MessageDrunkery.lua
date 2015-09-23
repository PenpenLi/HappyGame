--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageDrunkery.lua
-- author:    wuqd
-- created:   2015/06/29
-- descrip:   酒馆相关【请求消息格式】
--===================================================
DrunkeryCGMessage = {}

-- 获取酒坊信息请求
function DrunkeryCGMessage:openDrunkeryDialog22100()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22100                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 领取营业奖励请求
function DrunkeryCGMessage:getRewardReq22102()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22102                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 立刻完成请求
function DrunkeryCGMessage:OnceCompleteReq22104()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22104                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 获取好友酒坊信息请求
function DrunkeryCGMessage:getFriendWineryReq22108()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22108                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)    
end

-- 售卖酒品请求
function DrunkeryCGMessage:sellWineReq22106(nWineId)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22106                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.id = nWineId
    -------------------------------------
    send(msg)
end

-- 喝个痛快请求
function DrunkeryCGMessage:drinkReq22110(nFriendId)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22110                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.friendId = nFriendId
    -------------------------------------
    send(msg)
end

-- 一键喝光请求
function DrunkeryCGMessage:autoDrinkReq22112(friendIds)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22112                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.friendIds = friendIds
    -------------------------------------
    send(msg)
end