--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageFairyLand.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/23
-- descrip:  境界盘相关【请求消息格式】
--===================================================
FairyLandCGMessage = {}

--查询境界盘相关信息
function FairyLandCGMessage:sendMessageSelectFairyInfo20600()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20600                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    -------------------------------------
    send(msg)
end

--镶嵌境界丹请求
function FairyLandCGMessage:sendMessageInlayFairyPill20602(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20602                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.pillIndex = nIndex
    -------------------------------------
    send(msg)
end

--卸下境界丹请求
function FairyLandCGMessage:sendMessageDropFairyPill20604(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20604                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.dishIndex = nIndex
    -------------------------------------
    send(msg)
end

--吞噬境界丹请求
function FairyLandCGMessage:sendMessageDevourFairyPill20606(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20606                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.dishIndex = nIndex
    -------------------------------------
    send(msg)
end

--刷新境界丹列表请求
function FairyLandCGMessage:sendMessagefreshFairyPill20608()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20608                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    -------------------------------------
    send(msg)
end

--一键吞噬请求
function FairyLandCGMessage:sendMessageAutoDevour20610()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20610                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    -------------------------------------
    send(msg)
end

--进阶请求
function FairyLandCGMessage:sendMessageUpgradeFairyDish20612()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20612                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    -------------------------------------
    send(msg)
end