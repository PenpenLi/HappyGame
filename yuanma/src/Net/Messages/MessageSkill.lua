--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageSkill.lua
-- author:    liyuhang
-- created:   2015/3/12
-- descrip:   技能相关【请求消息格式】
--===================================================
-- 请求技能列表
SkillCGMessage= {}

function SkillCGMessage:sendMessageQuerySkillList21400()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21400                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 请求升级技能
function SkillCGMessage:sendMessageUpgradeSkill21402(skillId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21402                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.skillId = skillId                            -- 技能id
    -------------------------------------
    send(msg)
end

-- 请求出战技能
function SkillCGMessage:sendMessageMountSkill21404(skillId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21404                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.skillId = skillId                            -- 技能id
    -------------------------------------
    send(msg)
end


