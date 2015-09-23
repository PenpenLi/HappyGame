--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageHeartBeat.lua
-- author:    liyuhang
-- created:   2014/12/23
-- descrip:   背包相关【请求消息格式】
--===================================================

HeartBeatMessage = {}

function HeartBeatMessage:sendMessageHeartBeat21300()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21300                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end


