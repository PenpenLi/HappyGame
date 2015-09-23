--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessagePet.lua
-- author:    liyuhang
-- created:   2015/4/27
-- descrip:   宠物相关【请求消息格式】
--===================================================

PetCGMessage= {}
-- 请求宠物列表
function PetCGMessage:sendMessageGetPetsList21500()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21500                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 请求上阵宠物
function PetCGMessage:sendMessageField21502(petId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21502                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.petId = petId                                  -- 宠物id
    -------------------------------------
    send(msg)
end

-- 请求下阵宠物
function PetCGMessage:sendMessageunField21504(petId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21504                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.petId = petId                                  -- 宠物id
    -------------------------------------
    send(msg)
end

-- 请求合成宠物
function PetCGMessage:sendMessageCompound21506(chipId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21506                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.chipId = chipId                                -- 宠物碎片id
    -------------------------------------
    send(msg)
end

-- 请求进阶宠物
function PetCGMessage:sendMessageAdvance21508(petId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21508                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.petId = petId                                  -- 宠物id
    -------------------------------------
    send(msg)
end

-- 请求喂食宠物
function PetCGMessage:sendMessageFeed21510(petId,materialId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21510                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.petId = petId                                  -- 宠物id
    msg.body.materialId = materialId                        -- 食材id
    -------------------------------------
    send(msg)
end

