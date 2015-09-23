--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageGemSystem.lua
-- author:    wuquandong
-- created:   2014/01/08
-- descrip:   宝石系统相关【请求消息格式】
--===================================================

GemSystemCGMessage = {}

-- 宝石合成请求
function GemSystemCGMessage:sendMessageGemSynthesis20114(nGemId)
	local msg = {}
	----------------------------------

	msg.header = {}
	msg.header.cmdNum = 20114								-- 消息协议号
	msg.header.cmdSeq = nSeqNum								-- 消息序列号（每次加1）
	msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {} 
    msg.body.stoneId = nGemId                               -- 宝石ID 
    -------------------------------------
    send(msg)
end

-- 合成背包中装备上的宝石请求
function GemSystemCGMessage:sendMessageGemSynThesis20116(nIndex,nGemId)
    local msg = {}
    ----------------------------------

    msg.header = {}
    msg.header.cmdNum = 20116                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {} 
    msg.body.index = nIndex                                 -- 装备在背包中的位置
    msg.body.stoneId = nGemId                               -- 宝石Id
    -------------------------------------
    send(msg)
end

-- 合成玩家身上装备上的宝石请求
function GemSystemCGMessage:sendMessageGemSynthesis20118(nLocation,nStoneId)
   local msg = {}
    ----------------------------------

    msg.header = {}
    msg.header.cmdNum = 20118                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {} 
    msg.body.loction = nLocation                           -- 装备位
    msg.body.stoneId = nStoneId                             -- 宝石
    -------------------------------------
    send(msg) 
end

-- 镶嵌背包中装备的请求
function GemSystemCGMessage:sendMessageInlayBagEquipReq20120(isUnload,nIndex,nStoneId,stoneIndex)
local msg = {}
    ----------------------------------

    msg.header = {}
    msg.header.cmdNum = 20120                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {} 
    msg.body.opposite = isUnload                            -- 卸下标志(如果是镶嵌为false, 如果为卸下为true)
    msg.body.eqpIndex = nIndex                              -- 装备背包位置
    msg.body.stoneId = nStoneId                             -- 宝石Id
    msg.body.stoneIndex = stoneIndex                        -- 宝石的索引
    -------------------------------------
    send(msg) 
end

-- 镶嵌人物身上装备请求
function GemSystemCGMessage:sendMessageInlayRoleEquipReq20122(isUnload,nLocation,nStoneId,stoneIndex)
local msg = {}
    ----------------------------------

    msg.header = {}
    msg.header.cmdNum = 20122                             -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {} 
    msg.body.opposite = isUnload                            -- 卸下标志(如果是镶嵌为false, 如果为卸下为true)
    msg.body.loction = nLocation                           -- 装备位
    msg.body.stoneId = nStoneId                             -- 宝石Id
    msg.body.stoneIndex = stoneIndex                        -- 宝石的索引
    -------------------------------------
    send(msg) 
end