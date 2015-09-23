--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageOtherPlayers.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/25
-- descrip:   其他玩家相关【请求消息格式】
--===================================================
-- 请求登录账户

OtherPlayersCGMessage = {}

function OtherPlayersCGMessage:sendMessageOtherPlayers(args)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20014                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.count = args.count                             -- 验证码(根据设备ID加密生成)
    -------------------------------------
    send(msg)
end
