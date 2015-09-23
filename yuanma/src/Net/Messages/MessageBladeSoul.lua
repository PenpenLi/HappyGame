--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageFairyLand.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/2/2
-- descrip:  剑灵相关【请求消息格式】
--===================================================
BladeSoulCGMessage = {}

--查询剑灵相关信息
function BladeSoulCGMessage:sendMessageSelectBladeSoulInfo20700()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20700                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    -------------------------------------
    send(msg)
end

--炼化请求
function BladeSoulCGMessage:sendMessageRefineItem20702(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20702                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.index = nIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end

--收取请求
function BladeSoulCGMessage:sendMessageCollectBladeSoul20704(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20704                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.index = nIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end

--取消请求
function BladeSoulCGMessage:sendMessageCancelRefine20706(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20706                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.index = nIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end

--加速请求
function BladeSoulCGMessage:sendMessageBoostRefine20708(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {} 
    msg.header.cmdNum = 20708                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.index = nIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end

--吞噬剑魂请求
function BladeSoulCGMessage:sendMessageDevourBladeSoul20710(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {} 
    msg.header.cmdNum = 20710                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.index = nIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end

--卖出剑魂请求
function BladeSoulCGMessage:sendMessageSellBladeSoul20712(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {} 
    msg.header.cmdNum = 20712                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.index = nIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end

--一键炼化请求
function BladeSoulCGMessage:sendMessageAutoRefineItem20714(tIndex)
    local msg = {}
    -------------------------------------
    msg.header = {} 
    msg.header.cmdNum = 20714                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.indexs = tIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end


--一键吞噬剑魂请求
function BladeSoulCGMessage:sendMessageAutoDevourBladeSoul20716()
    local msg = {}
    -------------------------------------
    msg.header = {} 
    msg.header.cmdNum = 20716                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end