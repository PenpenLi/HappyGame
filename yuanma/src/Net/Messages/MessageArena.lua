--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageArena.lua
-- author:    wuqd
-- created:   2015/04/24
-- descrip:   竞技场相关【请求消息格式】
--===================================================
ArenaCGMessage = {}

-- 请求竞技场信息
function ArenaCGMessage:queryArenaInfoReq21600()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21600                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 挑战请求
function ArenaCGMessage:fightReq21602(roleId)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21602                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.roleId = roleId
    -------------------------------------
    send(msg)
end

-- 请求上传挑战结果
function ArenaCGMessage:fightResultReq21604(isWin)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21604                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.isWin = isWin
    -------------------------------------
    send(msg)
end

-- 获取排行榜请求
function ArenaCGMessage:queryArenaRankReq21606(nBeginPos,nEndPos)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21606                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.beginPos = nBeginPos
    msg.body.endPos = nEndPos
    -------------------------------------
    send(msg)
end	

-- 刷新对手请求
function ArenaCGMessage:refreshEnemyReq21608()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21608                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end	

-- 请求获取竞技场礼包
function ArenaCGMessage:drawArenaBoxReq21610()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21610                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end