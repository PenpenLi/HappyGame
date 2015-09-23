--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BuffSystemCGMessage.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/14
-- descrip:   午夜惊魂的请求
--===================================================
BuffSystemCGMessage = {}

--请求buff
function BuffSystemCGMessage:sendMessageGetBuff23100()
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 23100                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    send(msg)
end
