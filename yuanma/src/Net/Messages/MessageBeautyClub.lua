--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BeautyClubSystemCGMessage.lua
-- author:    wuquandong
-- created:   2014/02/06
-- descrip:   群芳阁系统【请求消息格式】
--===================================================
BeautyClubSystemCGMessage = {}

-- 请求群芳阁信息
function BeautyClubSystemCGMessage:queryBeautyInfoReq20800()
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 20800                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
  
    -------------------------------------
    send(msg)
end

-- 请求和美人互动
function BeautyClubSystemCGMessage:kissBeutyReq20802(beautyId)
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 20802                            -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.id = beautyId							        -- 美人Id

    -------------------------------------
    send(msg)
end

-- 请求镶嵌（唤醒）美人
function BeautyClubSystemCGMessage:beautyAwakeReq20804(groupId,index)
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 20804                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.groupId = groupId							    -- 组合Id
    msg.body.index = index 								    -- 美人所在的索引 
    -------------------------------------
    send(msg)
end