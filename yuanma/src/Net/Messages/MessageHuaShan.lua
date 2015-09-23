--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageHuaShan.lua
-- author:    wuqd
-- created:   2015/05/18
-- descrip:   华山论剑【请求消息格式】
--===================================================
HuaShanCGMessage = {}

-- 请求获取华山对手列表
function HuaShanCGMessage:queryHSInfoReq21900()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21900                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 查看华山对手详细信息 
function HuaShanCGMessage:fightReq21902(rank)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21902                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.rank = rank									-- 排名
    -------------------------------------
    send(msg)
end

-- 挑战对手请求
function HuaShanCGMessage:fightReq21904(rank)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21904                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.rank = rank									-- 排名
    -------------------------------------
    send(msg)
end

-- 上传挑战结果(只有成功时才和服务器通信)
function HuaShanCGMessage:fightHSResultReq21906(isWin)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21906                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.isWin = isWin									-- 是否挑战成功
    -------------------------------------
    send(msg)
end

-- 增加鼓舞Buf 请求
function HuaShanCGMessage:addBuffReq21908(isDiamond)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21908                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.isDiamond = isDiamond							-- 消耗的是否是钻石
    -------------------------------------
    send(msg)
end