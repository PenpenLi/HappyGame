--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageCommonUtil.lua
-- author:    liyuhang
-- created:   2015/7/10
-- descrip:   基本通用功能借口
--===================================================
MessageCommonUtil = {}

-- 请求新手引导存档
function MessageCommonUtil:sendMessageQueryNewerPro21310()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21310                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)

end

-- 存档新手引导存档
function MessageCommonUtil:sendMessageSaveNewerPro21308(mainId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21308                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.progress = mainId
    -------------------------------------
    send(msg)

end
