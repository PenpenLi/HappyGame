--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageGameInstance.lua
-- author:    liyuhang
-- created:   2015/2/6
-- descrip:   游戏副本相关【请求消息格式】
--===================================================
-- 请求游戏副本列表
MessageGameInstance = {}

function MessageGameInstance:sendMessageQueryBattleList21000(tCopyTypes)
    local msg = {}  
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21000                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
     msg.body = {} 
    msg.body.copyTypes = tCopyTypes                            -- 副本id
    send(msg)
end

-- 请求进入副本战斗
function MessageGameInstance:sendMessageEntryBattle21002(battleId,identity,friendId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21002                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.battleId = battleId                            -- 副本id
    msg.body.identity = identity                            -- 标识id
    if friendId ~= nil then
        msg.body.friendId = friendId
    else
        msg.body.friendId = 0
    end
    -------------------------------------
    send(msg)
end

-- 上传战斗结果数据
function MessageGameInstance:sendMessageUploadBattleResult21004(battleId, winData)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21004                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.battleId = battleId                            -- 副本id
    msg.body.winData = winData                              -- 副本战况
    -------------------------------------
    send(msg)
end

-- 上传请求选卡数据
function MessageGameInstance:sendMessagePickCard21006(index)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21006                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.index = index                                  -- 卡牌索引
    -------------------------------------
    send(msg)
end

-- 获取剧情副本请求（参数0：全部章节返回  非0：返回指定的章节）
function MessageGameInstance:sendMessageQueryStoryBattleList21008(storyId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21008                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.storyId = storyId                              -- 章节id
    -------------------------------------
    send(msg)
end

-- 领奖宝箱请求
function MessageGameInstance:sendMessageDrawStoryBox21010(storyId,index)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21010                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.storyId = storyId                              -- 章节id
    msg.body.index = index                                  -- 章节id
    -------------------------------------
    send(msg)
end

-- 获取爬塔副本请求
function MessageGameInstance:sendMessageQueryTowerBattleList21012()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21012                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    send(msg)
end

-- 请求翻卡数据
function MessageGameInstance:sendMessagePickCardState21016()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21016                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    send(msg)
end

-- 请求副本数据
function MessageGameInstance:sendMessageQueryBattleInfo21018(battleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21018                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.battleId = battleId                            -- 副本id
    -------------------------------------
    send(msg)
end

-- 获取排行榜的请求(服务器下标从零开始)
function MessageGameInstance:QueryRankListReq21320(rankType,starPos,endPos)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21320                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.rankType = rankType                            -- 排行榜的类型
    msg.body.beginIndex = starPos                           -- 开始位置（包含）
    msg.body.endIndex = endPos                              -- 结束位置（不包含）
    -------------------------------------
    send(msg)
end

-- 请求组队数据
function MessageGameInstance:sendMessageFormTeam21020(battleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 21020                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.battleId = battleId                            -- 副本id
    -------------------------------------
    send(msg)
end