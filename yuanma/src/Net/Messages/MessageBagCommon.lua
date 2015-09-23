--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageBagCommon.lua
-- author:    liyuhang
-- created:   2014/12/23
-- descrip:   背包相关【请求消息格式】
--===================================================
-- 请求角色背包信息
BagCommonCGMessage = {}

function BagCommonCGMessage:sendMessageGetBagList20100()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20100                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 请求购买背包格子
function BagCommonCGMessage:sendMessageOpenPackageCell20102()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20102                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 整理背包
function BagCommonCGMessage:sendMessageTidyPackage20104()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20104                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

