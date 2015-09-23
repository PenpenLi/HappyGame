--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChatCGMessage.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/6/24
-- descrip:  聊天的请求
--===================================================
ChatCGMessage = {}

--聊天发送
function ChatCGMessage:sendMessageChat21302(args)
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 21302                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    msg.body = {}
    msg.body.desRoleId = args[1]                            -- 对方的id
    msg.body.useHorn = args[2]                              -- 使用喇叭
    msg.body.chatType = args[3]                             -- 聊天频道
    msg.body.contentType = args[4]                          -- 内容类型
    msg.body.content = args[5]                              -- 聊天内容
    ------------------------------------
    send(msg)
end

--查询黑名单
function ChatCGMessage:sendMessageQueryBlackList21304()
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 21304                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    send(msg)
end

--设置黑名单
function ChatCGMessage:sendMessageSetBlackList21306(nRoleId)
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 21306                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    msg.body = {}
    msg.body.roleId = nRoleId                               -- 对方的id
    ------------------------------------
    send(msg)
end

