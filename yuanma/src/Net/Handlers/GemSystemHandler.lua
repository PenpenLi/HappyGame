--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GemSystemHandler.lua
-- author:    liyuhang
-- created:   2014/12/7
-- descrip:   宝石系统相关网络handler
--===================================================
local GemSystemHandler = class("GemSystemHandler")

-- 构造函数
function GemSystemHandler:ctor()
    -- 宝石系统宝石合成返回的Handler
    NetHandlersManager:registHandler(20115, self.handleMsgGemSynthesis20115)
    -- 宝石系统宝石合成背包里装备上的宝石
    NetHandlersManager:registHandler(20117, self.handleMsgGemSynthesis20117)
    -- 宝石系统宝石合成身上装备上的宝石
    NetHandlersManager:registHandler(20119, self.handleMsgGemSynthesis20119)
    -- 宝石系统镶嵌背包装备
    NetHandlersManager:registHandler(20121, self.handleMsgInlayBagEquip20121)
    -- 宝石系统镶嵌身上装备
    NetHandlersManager:registHandler(20123, self.handleMsgInlayRoleEquip20123)
end

-- 创建函数
function GemSystemHandler:create()
	print("GemSystemHandler create")
	local handler = GemSystemHandler.new()
	return handler
end

-- 获取宝石合成服务器返回的结果
function GemSystemHandler:handleMsgGemSynthesis20115(msg)
	print ("GemSystemHandler 20115")
	if msg.header.result == 0 then         
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kGemSynthesis,nil)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kEquipWarning, {})    
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 获取合成背包里装备上宝石返回结果
function GemSystemHandler:handleMsgGemSynthesis20117(msg)
    print("GemSystemHandler 20117")
    if msg.header.result == 0 then
        --BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        local event = {index = msg.body.argsBody.index}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kBagEqpStoneSynthesis,event)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kEquipWarning, {})
    else
        print("返回错误码："..msg.header.result) 
    end
end

-- 获取合成身上装备上宝石返回结果
function GemSystemHandler:handleMsgGemSynthesis20119(msg)
    print("GemSystemHandler 20119")
    if msg.header.result == 0 then
        --BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        -- 玩家战斗力变化的值 
        local fightResiveValue = msg["body"].roleInfo.roleAttrInfo.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        NoticeManager:getInstance():showFightStrengthChange(fightResiveValue)
        --装备穿戴的存储
        RolesManager:getInstance():setMainRole(msg["body"].roleInfo)
        local event = {loction = msg.body.argsBody.loction}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kRoleEqpStoneSynthesis,event)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kEquipWarning, {})
    else
        print("返回错误码："..msg.header.result) 
    end
end

-- 获取镶嵌背包装备
function GemSystemHandler:handleMsgInlayBagEquip20121(msg)
    print("GemSystemHandler 20121")
    if msg.header.result == 0 then
        --BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        local event = {index = msg.body.argsBody.eqpIndex,stoneId = msg.body.argsBody.stoneId}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kInlayBagEquip,event)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
    else
        print("返回错误码："..msg.header.result) 
    end
end

-- 获取镶嵌身上装备
function GemSystemHandler:handleMsgInlayRoleEquip20123(msg)
    print("GemSystemHandler 20123")
    if msg.header.result == 0 then
        -- 玩家战斗力变化的值 
        local fightResiveValue = msg["body"].roleInfo.roleAttrInfo.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        NoticeManager:getInstance():showFightStrengthChange(fightResiveValue)
        --装备穿戴的存储
        RolesManager:getInstance():setMainRole(msg["body"].roleInfo)
        local event = {loction = msg.body.argsBody.loction,stoneId = msg.body.argsBody.stoneId}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kInlayRoleEquip,event)
        -- 可镶嵌装备检查
        BagCommonManager:getInstance()._tCanInlayEquips = BagCommonManager:getInstance():getCanInlayWearEquipIndexArry()
        if table.getn(BagCommonManager:getInstance()._tCanInlayEquips) > 0 or table.getn(BagCommonManager:getInstance()._tCanIntensifyEquips) > 0 then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "装备按钮" , value = true})
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "背包按钮" , value = true})
        else
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "装备按钮" , value = false})
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "背包按钮" , value = false})
        end
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kEquipWarning, {})
    else
        print("返回错误码："..msg.header.result) 
    end
end

return GemSystemHandler

