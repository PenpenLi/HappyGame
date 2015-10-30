--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageActivity.lua
-- author:    wuqd
-- created:   2015/04/24
-- descrip:   活动【请求消息格式】
--===================================================
ActivityMessage = {}

-- 获取活动列表请求
function ActivityMessage:QueryActivityListReq22500()
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22500                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 领取累计充值请求
function ActivityMessage:GainAmassAwardReq22502(nAwardId)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22502                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.awardId = nAwardId								-- 奖品Id
    -------------------------------------
    send(msg)	
end

-- 领取在线奖励请求
function ActivityMessage:GainOnlineAwardReq22504(nIndex)
	local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22504                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.index = nIndex - 1									-- 领取第几个奖励(服务器下标从零开始)
    -------------------------------------
    send(msg)		
end

-- 领取激活码奖励的请求 
function ActivityMessage:ExchangeCodeReq21318(strExCode)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21318                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.excode = strExCode                                 -- 领取第几个奖励(服务器下标从零开始)
    -------------------------------------
    send(msg)           
end

-- 月签到
function ActivityMessage:SignIn(autoSign,isResignIn)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22510                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.autoSign = autoSign                            -- 是否全部补签
    msg.body.addSign = isResignIn                            -- 是否是补签
    -------------------------------------
    send(msg)   
end
   
-- 领取等级礼包奖励请求
function ActivityMessage:GainLevelGiftReq22506(index)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22506                           -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.index = index - 1                              -- 领取奖励的索引（服务器从零开始）
    -------------------------------------
    send(msg)    
end

-- 领取首充奖励请求
function ActivityMessage:GainFRAwardReq22508()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22508                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)    
end

-- 领取体力礼包的请求
function ActivityMessage:GainPowerReq22512(index)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22512                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.index = index                                  -- 礼包的下标（从零开始）
    send(msg)    
end