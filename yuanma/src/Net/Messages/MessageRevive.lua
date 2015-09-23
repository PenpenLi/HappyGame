--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageRevive.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/18
-- descrip:   战斗复活【请求消息格式】
--===================================================
MessageRevive = {}

-- 请求复活
function MessageRevive:sendMessageRevive21014()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21014                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)
    
end
