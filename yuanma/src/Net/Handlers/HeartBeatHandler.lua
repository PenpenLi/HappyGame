--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  HeartBeatHandler.lua
-- author:    liyuhang
-- created:   2014/12/7
-- descrip:   心跳handler
--===================================================
local HeartBeatHandler = class("HeartBeatHandler")

-- 构造函数
function HeartBeatHandler:ctor()     
    -- 获取心跳
    NetHandlersManager:registHandler(21301, self.handleMsgHeartBeat)
end

-- 创建函数
function HeartBeatHandler:create()
    print("HeartBeatHandler create")
    local handler = HeartBeatHandler.new()
    return handler
end

-- 心跳
function HeartBeatHandler:handleMsgHeartBeat(msg)
    print("HeartBeatHandler 21300")
    if msg.header.result == 0 then 
        RolesManager._pMainRoleInfo.strength = msg["body"].strength
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, event)
        
        if msg["body"].shopFlag == true then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "商城按钮" , value = true})
        else
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "商城按钮" , value = false})
        end
        
        if msg["body"].fairyFlag == true then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "境界按钮" , value = true})
        end
        
        if msg["body"].wineryFlag == true then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "酒坊按钮" , value = true})
        end
        
        if msg["body"].fortuneFlag == true then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "寻宝按钮" , value = true})
        else
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "寻宝按钮" , value = false})
        end
        
        if msg["body"].experFlag == true then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "历练按钮" , value = true})
        else
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "历练按钮" , value = false})
        end
        
        if msg["body"].bladeFlag == true then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "剑灵按钮" , value = true})
        end
        
        if msg["body"].beautyFlag == true then
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "群芳阁按钮" , value = true})
        end
    else
        print("返回错误码："..msg.header.result)
    end
end

return HeartBeatHandler