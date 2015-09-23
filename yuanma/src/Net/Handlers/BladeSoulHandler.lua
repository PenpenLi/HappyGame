--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BladeSoulHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/2/2
-- descrip:  剑灵相关handler
--===================================================
local BladeSoulHandler = class("BladeSoulHandler")

-- 构造函数
function BladeSoulHandler:ctor()
    -- 获取剑灵信息
    NetHandlersManager:registHandler(20701, self.handleQueryBladeSoul20701)
    -- 炼化
    NetHandlersManager:registHandler(20703, self.handleQueryRefineItem20703)
    -- 收取
    NetHandlersManager:registHandler(20705, self.handleQueryCancelRefine20705)
    -- 取消
    NetHandlersManager:registHandler(20707, self.handleQueryBoostRefine20707)
    -- 加速
    NetHandlersManager:registHandler(20709, self.handleQueryBoostRefine20709)
    -- 吞噬剑魂
    NetHandlersManager:registHandler(20711, self.handleQueryDevourBladeul20711)
    -- 出售剑魂
    NetHandlersManager:registHandler(20713, self.handleQuerySellBladeSoul20713)
    -- 一键炼化回复
    NetHandlersManager:registHandler(20715, self.handleAutoRefineItem20715)
    -- 一键吞噬剑魂回复
    NetHandlersManager:registHandler(20717, self.handleAutoDevourBladeSoul20717)
end
-- 创建函数
function BladeSoulHandler:create()
    print("EquipmentHandler create")
    local handler = BladeSoulHandler.new()
    return handler
end

--查询剑灵信息
function BladeSoulHandler:handleQueryBladeSoul20701(msg)
    print("bagCommoneHandler 20701")
    if msg.header.result == 0 then
        local event = msg["body"]
       -- cc.Director:getInstance():getRunningScene():showDialog(require("BladeSoulDialog"):create(event))
         DialogManager:getInstance():showDialog("BladeSoulDialog",event)
        
        if TasksManager:getInstance()._bOpenBladeSoul == true then
            if DialogManager:getInstance():getDialogByName("BladeSoulDialog") ~= nil then
                DialogManager:getInstance():getDialogByName("BladeSoulDialog"):JumpUiByType(TasksManager:getInstance()._nOpenType)
                TasksManager:getInstance():resetAutoBladesoulType()
        	end
        end
    else
        print("返回错误码："..msg.header.result)
    end
end

--炼化
function BladeSoulHandler:handleQueryRefineItem20703(msg)
    print("bagCommoneHandler 20703")
    if msg.header.result == 0 then
        local event = msg["body"]
        local pItemInfo = BagCommonManager:getItemInfoByPosition(event["argsBody"].index)
        if pItemInfo.baseType ==kItemType.kEquip and #pItemInfo.equipment[1].stones >0  then --如果是装备且有宝石
            NoticeManager:getInstance():showSystemMessage("装备上的宝石已卸下存入背包内")
        end  
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kRefineItem,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

 -- 收取剑灵丹[回复]
function BladeSoulHandler:handleQueryCancelRefine20705(msg)
    print("bagCommoneHandler 20705")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kCollectBladeSoul,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 取消剑灵丹[回复]
function BladeSoulHandler:handleQueryBoostRefine20707(msg)
    print("bagCommoneHandler 20707")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kCancelRefine,event)
    else
        print("返回错误码："..msg.header.result)
    end
end


-- 加速请求[回复]
function BladeSoulHandler:handleQueryBoostRefine20709(msg)
    print("bagCommoneHandler 20709")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kBoostRefine,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 吞噬剑魂[回复]
function BladeSoulHandler:handleQueryDevourBladeul20711(msg)
    print("bagCommoneHandler 20711")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kDevourBladeSoul,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 出售剑魂[回复]
function BladeSoulHandler:handleQuerySellBladeSoul20713(msg)
    print("bagCommoneHandler 20713")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kSellBladeSoul,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 一键炼化回复
function BladeSoulHandler:handleAutoRefineItem20715(msg)
    print("bagCommoneHandler 20715")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kAutoRefineItem,event)
    else
        print("返回错误码："..msg.header.result)
    end
end


-- 一键吞噬剑魂回复
function BladeSoulHandler:handleAutoDevourBladeSoul20717(msg)
    print("bagCommoneHandler 20717")
    if msg.header.result == 0 then
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kAutoDevourBladeSoul,event)
    else
        print("返回错误码："..msg.header.result)
    end
end


return BladeSoulHandler