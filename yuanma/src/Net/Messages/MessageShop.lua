--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ShopSystemCGMessage.lua
-- author:    wuquandong
-- created:   2014/01/24
-- descrip:   商城相关系统【请求消息格式】
--===================================================
ShopSystemCGMessage = {}

-- 请求商店信息
function ShopSystemCGMessage:QueryShopInfoReq20500(shopType)
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 20500                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.shopType = shopType							-- 商城的类型
    -------------------------------------
    send(msg)
end

-- 分标签请求商品的信息
function ShopSystemCGMessage:QueryShopInfoByTagReq20502(shopType,shopTag)
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 20502                            -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.shopType = shopType							-- 商城的类型
    msg.body.tagId = shopTag 								-- 商城标签类型
    -------------------------------------
    send(msg)
end

-- 请求购买商品
function ShopSystemCGMessage:buyGoodsReq20504(shopType,goodsId,count)
	local msg = {}
	------------------------
    msg.header = {}
    msg.header.cmdNum = 20504                            -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.shopType = shopType                        -- 商城的类型
    msg.body.goodsId = goodsId							-- 物品ID
    msg.body.count = count 								-- 物品的数量
    -------------------------------------
    send(msg)
end

-- 获取充值列表请求
function ShopSystemCGMessage:queryChargeListReq20506()
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 20506                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)    
end

-- 领取礼包对应的请求 
function ShopSystemCGMessage:gainVipBoxReq20508(vipLevel)
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 20508                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.vipLevel = vipLevel
    -------------------------------------
    send(msg)    
end

-- 生成订单
function ShopSystemCGMessage:GenerateOrder(channelId,rechargeId)
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 20510                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.channelId = channelId
    msg.body.rechargeId = rechargeId
    -------------------------------------
    send(msg)
end

-- 购买体力
function ShopSystemCGMessage:BuyStrengthReq21314()
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 21314                              -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)
end

-- 购买战斗次数
function ShopSystemCGMessage:BuyBattleReq21316 (kCopyType,nCopyId)
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 21316                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.copyTp = kCopyType                             -- 购买次数副本的类型
    msg.body.copyId = nCopyId                               -- 购买次数副本的Id
    -------------------------------------
    send(msg)    
end

--请求摇钱树信息回复
function ShopSystemCGMessage:QueryGoldTreeInfo21322 ()
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 21322                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    -------------------------------------
    send(msg)    
end

--玉璧购买铜钱请求
function ShopSystemCGMessage:QueryGoldTreeInfo21324 (buyCount)
    local msg = {}
    ------------------------
    msg.header = {}
    msg.header.cmdNum = 21324                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
     msg.body = {}
    msg.body.buyCount = buyCount                             -- 购买次数
    -------------------------------------
    send(msg)    
end
