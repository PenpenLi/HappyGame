--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageEmail.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/26
-- descrip:   邮件相关【请求消息格式】
--===================================================
EmailCGMessage = {}

-- 请求邮件列表
function EmailCGMessage:sendMessageGetMailList22200()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22200                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)
end

-- 请求邮件详情
function EmailCGMessage:sendMessageGetMailInfo22202(index)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22202                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.index = index                                  -- 邮件index
    -------------------------------------
    send(msg)
end

-- 删除指定的邮件数据
function EmailCGMessage:sendMessageDeleteMailInfo22204(indexArray)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22204                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.index = indexArray                             -- 邮件index数组
    -------------------------------------
    send(msg)
end

-- 获取指定邮件中的附件
function EmailCGMessage:sendMessageGetMailGoods22206(indexArray)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22206                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.index = indexArray                             -- 邮件index数组
    -------------------------------------
    send(msg)
end
