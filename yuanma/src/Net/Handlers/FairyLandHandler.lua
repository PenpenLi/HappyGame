--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FairyLandHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/23
-- descrip:   境界盘相关handler
--===================================================
local FairyLandHandler = class("FairyLandHandler")

-- 构造函数
function FairyLandHandler:ctor()
    --查询境界盘信息
    NetHandlersManager:registHandler(20601, self.handleSelectFairyInfo20601)
    -- 镶嵌境界丹
    NetHandlersManager:registHandler(20603, self.handleInlayFairyPill20603)
    --卸下境界丹
    NetHandlersManager:registHandler(20605, self.handleDropFairyPill20605)
    --吞噬境界丹
    NetHandlersManager:registHandler(20607, self.handleDevourFairyPill20607)
    --刷新境界丹列表
    NetHandlersManager:registHandler(20609, self.handleRefreshFairyPill20609)
    --一键吞噬
    NetHandlersManager:registHandler(20611, self.handleAutoDevour20611)
    --境界丹镶嵌
    NetHandlersManager:registHandler(20613, self.handleUpgradeFairyDish20613)
end

-- 创建函数
function FairyLandHandler:create()
    local handler = FairyLandHandler.new()
    return handler
end

--查询境界盘信息
function FairyLandHandler:handleSelectFairyInfo20601(msg)
    print("handleSelectFairyInfo 20601")
    if msg.header.result == 0 then
        local event = msg["body"]
        --cc.Director:getInstance():getRunningScene():showDialog(require("FairyLandDialog"):create(event))
        DialogManager:getInstance():showDialog("FairyLandDialog",event)
        
        
    end
end

--境界丹镶嵌
function FairyLandHandler:handleInlayFairyPill20603(msg)
    print("handleSelectFairyInfo 20603")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kInlayFairyPill,event)
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

--卸下境界丹
function FairyLandHandler:handleDropFairyPill20605(msg)
    print("handleSelectFairyInfo 20605")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kDropFairyPill,event)
    end
end

--吞噬境界丹
function FairyLandHandler:handleDevourFairyPill20607(msg)
    print("handleSelectFairyInfo20607")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kDevourFairyPill,event)
    end
end

--刷新境界丹列表
function FairyLandHandler:handleRefreshFairyPill20609(msg)
    print("handleSelectFairyInfo 20609")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kRefreshFairyPill,event)
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

--一键吞噬
function FairyLandHandler:handleAutoDevour20611(msg)
    print("handleSelectFairyInfo 20611")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kAutoDevour,event)
    end
end

--境界丹镶嵌
function FairyLandHandler:handleUpgradeFairyDish20613(msg)
    print("handleSelectFairyInfo 20613")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpgradeFairyDish,event)
    end
end

return FairyLandHandler