--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BagCommonHandler.lua
-- author:    liyuhang
-- created:   2014/12/7
-- descrip:   登录相关网络handler
--===================================================
local BagCommonHandler = class("BagCommonHandler")

-- 构造函数
function BagCommonHandler:ctor()     
    -- 获取背包列表
    NetHandlersManager:registHandler(20101, self.handleMsgQueryPackageList)
    -- 购买背包格子
    NetHandlersManager:registHandler(20103, self.handleMsgOpenPackageCell)
    -- 整理背包格子
    NetHandlersManager:registHandler(20105, self.handleMsgTidyPackage)
end

-- 创建函数
function BagCommonHandler:create()
    print("bagCommonHandler create")
    local handler = BagCommonHandler.new()
    return handler
end

-- 获取背包列表的结果
function BagCommonHandler:handleMsgQueryPackageList(msg)
    print("bagCommoneHandler 20101")
    if msg.header.result == 0 then 
        BagCommonManager:getInstance()._bGetInitData = true
        BagCommonManager:getInstance():setOpenCellCount(msg["body"].openCount)
        BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        

        local event = {maxCount = msg["body"].openCount , itemCount = #msg["body"].itemList}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, event)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 获取购买格子的结果
function BagCommonHandler:handleMsgOpenPackageCell(msg)
    print("bagCommoneHandler 20103")
    if msg.header.result == 0 then 
        BagCommonManager:getInstance():setOpenCellCount(msg["body"].tootle)
        
        local event = {maxCount = msg["body"].tootle , isBuy = 1}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, event)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 整理格子的结果
function BagCommonHandler:handleMsgTidyPackage(msg)
    print("bagCommoneHandler 20105")
    if msg.header.result == 0 then 
        BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, {})
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

return BagCommonHandler