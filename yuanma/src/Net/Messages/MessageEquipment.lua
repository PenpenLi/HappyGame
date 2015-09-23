--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageEquipment.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2014/12/29
-- descrip:   装备相关【请求消息格式】
--===================================================
--穿戴装备协议
EquipmentCGMessage = {}

function EquipmentCGMessage:sendMessageWareEquipment20106(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20106                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    
    msg.body = {}
    msg.body.index = nIndex                                 -- 格子下表
    -------------------------------------
    send(msg)
end

--时装是否显示
function EquipmentCGMessage:sendMessageFashionOpt20110(nIndex,bHasVisable)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20110                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    
    msg.body = {}
    msg.body.loction = 7+nIndex                             -- 时装type
    msg.body.optionValue = bHasVisable                      -- 时装是否显示
    -------------------------------------
    send(msg)
end

--分解装备
function EquipmentCGMessage:sendMessageResolveEquipment20112(tIndexArray)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20112                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.indexes = tIndexArray                          -- 时装type
    -------------------------------------
    send(msg)
end

-- 强化背包装备请求
function EquipmentCGMessage:sendMessageBagIntensifyEquipment20124(bAuto,nIndex)
     local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20124                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.auto = bAuto                                   -- true为一键强化
    msg.body.index = nIndex                                 --背包中位置
    -------------------------------------
    send(msg)

end

-- 强化人物装备请求
function EquipmentCGMessage:sendMessageRoleIntensifyEquipment20126(bAuto,nLocation)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20126                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.auto = bAuto                                   -- true为一键强化
    msg.body.location = nLocation                           --背包中位置
    -------------------------------------
    send(msg)

end

-- 强化人物装备请求
function EquipmentCGMessage:sendMessageRoleIntensifyEquipment20126(bAuto,nLocation)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20126                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.auto = bAuto                                   -- true为一键强化
    msg.body.location = nLocation                           --背包中位置
    -------------------------------------
    send(msg)

end

-- 修改昵称请求
function EquipmentCGMessage:sendMessageRoleChangeName20010(strName)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20010                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.name = strName                                 -- 修改后的名字
    -------------------------------------
    send(msg)

end

--出售请求
function EquipmentCGMessage:sendMessageSellItem20128(nIndex,nCount)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20128                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.index = nIndex                                 -- 物品下标
    msg.body.count = nCount                                 -- 物品个数
    -------------------------------------
    send(msg)

end

--锻造装备请求
function EquipmentCGMessage:sendMessageFoundryEquipment20130(nChipId,nMapId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20130                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {}
    msg.body.chipId = nChipId                               -- 材料碎片id
    msg.body.mapId = nMapId                                 -- 图谱id
    -------------------------------------
    send(msg)

end

-- 一键出售白绿装备
function EquipmentCGMessage:sellCheapItemByAutoReq20136()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20136                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)

end