--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NightHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/14
-- descrip:   午夜惊魂的handler  
--===================================================
local NightHandler = class("NightHandler")

-- 构造函数
function NightHandler:ctor()
    -- 使用免死符
    NetHandlersManager:registHandler(21801, self.handleUseUnDead21801)
    -- 答题正确
    NetHandlersManager:registHandler(21803, self.handleAnswerRight21803)

end
-- 创建函数
function NightHandler:create()
    print("EquipmentHandler create")
    local handler = NightHandler.new()
    return handler
end

--使用免死符
function NightHandler:handleUseUnDead21801(msg)
    print("NightHandler 21801")
    if msg.header.result == 0 then
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUseUnDeadResp)
    else
        print("返回错误码："..msg.header.result)
    end
end

--答题正确
function NightHandler:handleAnswerRight21803(msg)
    print("NightHandler 21801")
    if msg.header.result == 0 then
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kAnswerRightResp)
    else
        print("返回错误码："..msg.header.result)
    end
end

return NightHandler