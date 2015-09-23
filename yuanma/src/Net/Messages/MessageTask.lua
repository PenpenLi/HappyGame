--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageTask.lua
-- author:    liyuhang
-- created:   2015/5/12
-- descrip:   任务相关【请求消息格式】
--===================================================

TaskCGMessage= {}

-- 请求任务列表
function TaskCGMessage:sendMessageQueryTasks21700()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21700                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 领取任务奖励
function TaskCGMessage:sendMessageGainTaskAward21702(taskId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21702                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.taskId = taskId                            -- 任务id
    -------------------------------------
    send(msg)
end

-- 领取活跃度礼包
function TaskCGMessage:sendMessageGainVitalityAward21704(index)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21704                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.index = index                            -- 礼包index
    -------------------------------------
    send(msg)
end


