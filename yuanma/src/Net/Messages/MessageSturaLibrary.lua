--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageSturaLibrary.lua
-- author:    wuqd
-- created:   2015/04/24
-- descrip:   藏经阁【请求消息格式】
--===================================================
SturaLibraryCGMessage = {}

-- 请求藏经阁信息
function SturaLibraryCGMessage:querySturaLibraryInfoReq22400()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22400                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 注入残页的请求
function SturaLibraryCGMessage:InsertPageReq22402(nBookId,nPageIndex)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22402                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.bookId = nBookId								-- 经书的编号
    msg.body.pageIndex = nPageIndex	- 1						-- 残页的索引
    send(msg)
end