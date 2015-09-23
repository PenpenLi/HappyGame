--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageFriend.lua
-- author:    liyuhang
-- created:   2015/5/22
-- descrip:   好友相关【请求消息格式】
--===================================================

FriendCGMessage= {}
-- 获取好友列表
function FriendCGMessage:sendMessageQueryFriendList22000()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22000                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 获取好友申请列表
function FriendCGMessage:sendMessageQueryApplyFriendList22002()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22002                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    
    -------------------------------------
    send(msg)
end

-- 获取礼物列表
function FriendCGMessage:sendMessageQueryGiftList22004()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22004                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    send(msg)
end

-- 查找角色请求
function FriendCGMessage:sendMessageQueryRoleInfoReq22006(name)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22006                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.name = name                                -- 宠物碎片id
    -------------------------------------
    send(msg)
end

-- 获取推荐好友请求
function FriendCGMessage:sendMessageRecommendList22008()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22008                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    send(msg)
end

-- 添加好友
function FriendCGMessage:sendMessageApplyFriend22010(roleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22010                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.roleId = roleId                                  -- 宠物id
    -------------------------------------
    send(msg)
end

-- 处理好友请求
function FriendCGMessage:sendMessageReplyApplicationReqBody22012(roleId,isAgree)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22012                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.roleId = roleId                                  -- 宠物id
    msg.body.isAgree = isAgree                                  -- 宠物id
    -------------------------------------
    send(msg)
end

-- 赠送礼物
function FriendCGMessage:sendMessageGiftFriend(roleId,itemId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22014                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.roleId = roleId                                  -- 宠物id
    msg.body.itemId = itemId                                  -- 物品id
    -------------------------------------
    send(msg)
end

-- 删除好友
function FriendCGMessage:sendMessageRemoveFriend(roleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22016                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.roleId = roleId                                  -- 宠物id
    -------------------------------------
    send(msg)
end

-- 请求人物详情
function FriendCGMessage:sendMessageQueryRoleInfoFriend22018(roleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22018                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.roleId = roleId                                  -- 宠物id
    -------------------------------------
    send(msg)
end

-- 请求好友技能
function FriendCGMessage:sendMessageQueryFriendSkill()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22020                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    -------------------------------------
    send(msg)
end

-- 配置好友技能
function FriendCGMessage:sendMessageMountFriendSkill22022(roleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22022                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段

    msg.body = {} 
    msg.body.roleId = roleId                                  -- 宠物id
    -------------------------------------
    send(msg)
end
