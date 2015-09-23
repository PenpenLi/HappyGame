--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageOpenItem.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/6/8
-- descrip:  打开物品的请求
--===================================================
OpenItemSystemCGMessage = {}

--请求宝箱
function OpenItemSystemCGMessage:sendMessageOpenBox20132(nIndex,nCount)
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 20132                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    msg.body = {}
    msg.body.index = nIndex                                 -- 背包中的位置
    msg.body.count = nCount                                 -- 宝箱的数量
    -------------------------------------
    send(msg)
end

--请求经验丹
function OpenItemSystemCGMessage:sendMessageEatPills20134(nIndex,nCount)
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 20134                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    msg.body = {}
    msg.body.index = nIndex                                 -- 背包中的位置
    msg.body.count = nCount                                 -- 宝箱的数量
    -------------------------------------
    send(msg)
end