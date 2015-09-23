--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GemSystemHandler.lua
-- author:    wuquandong
-- created:   2015/01/24
-- descrip:   商城系统相关网络handler
--===================================================
local ShopSystemHandler = class("ShopSystemHandler")

-- 构造函数
function ShopSystemHandler:ctor()
	-- 打开商城返回的handler
	NetHandlersManager:registHandler(20501, self.handleMsgQueryShopInfo20501)
	-- 根据标签请求商品列表返回的handler
	NetHandlersManager:registHandler(20503,self.handleMsgQueryShopInfoByTag20503)
	-- 购买物品返回的handler
	NetHandlersManager:registHandler(20505,self.handleMsgBuyGoods20505)
	-- 请求充值列表 返回的handler 
	NetHandlersManager:registHandler(20507,self.handlerMsgQueryChargeList20507)
	-- 领取vip 对应礼包的回复
	NetHandlersManager:registHandler(20509,self.handlerMsgGainVipBox20509)
    -- 生成订单 的回复
    NetHandlersManager:registHandler(20511,self.handlerMsgGenerateOrder20511)
end

-- 创建函数
function ShopSystemHandler:create()
	local handler = ShopSystemHandler.new()
	return handler
end

-- 获取请求商城
function ShopSystemHandler:handleMsgQueryShopInfo20501(msg)
	print("ShopSystemHandler 20501")
	if msg.header.result == 0 then
		local event = {shopType = msg.body.argsBody.shopType,tags = msg.body.tags,goodsInfo = msg.body.goods}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryShopInfo,event)
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 根据商城的标签查询物品的列表
function ShopSystemHandler:handleMsgQueryShopInfoByTag20503(msg)
	print("ShopSystemHandler 20503")
	if msg.header.result == 0 then
		local event = {tagId = msg.body.argsBody.tagId,goodsArry = msg.body.goods}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryShopInfoByTag,event)
    else
    	print("返回错误码："..msg.header.result)
	end  		
end

-- 购买物品
function ShopSystemHandler:handleMsgBuyGoods20505(msg)
	print("ShopSystemHandler 20505")
	if msg.header.result == 0 then
        NoticeManager:getInstance():showSystemMessage("购买成功")
		--BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
		local event = {goodsId = msg.body.argsBody.goodsId,goodsInfo = msg.body.currentGoods}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kBuyGoods,event)
	else
        NoticeManager:getInstance():showSystemMessage("购买失败")
		print("返回错误码："..msg.header.result)
	end	
end

-- 查询充值列表
function ShopSystemHandler:handlerMsgQueryChargeList20507(msg)
	print("ShopSystemHandler 20507")
	if msg.header.result == 0 then 
		DialogManager:getInstance():showDialog("ChargeDialog",msg.body.chargeLists)
		--local event = {chareList = msg.body.chargeLists}
		--NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryChargeList,event) 
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 领取Vip 对应的礼包
function ShopSystemHandler:handlerMsgGainVipBox20509(msg)
	print("ShopSystemHandler 20509")
	if msg.header.result == 0 then 
		local event = {vipLevel = msg.body.argsBody.vipLevel}
		NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainVipBox) 
	else
		print("返回错误码："..msg.header.result)
	end
end

-- 生成订单
function ShopSystemHandler:handlerMsgGenerateOrder20511(msg)
    print("ShopSystemHandler 20511")
    if msg.header.result == 0 then 
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kGenerateOrderSussess, msg) 
    else
        print("返回错误码："..msg.header.result)
    end
end

return ShopSystemHandler
