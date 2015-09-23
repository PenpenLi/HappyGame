--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ReviveHandler.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/18
-- descrip:   复活的handler
--===================================================
local ReviveHandler = class("ReviveHandler")

-- 构造函数
function ReviveHandler:ctor()
    -- 获取复活回复
    NetHandlersManager:registHandler(21015, self.handleRevive21015)
    
end

-- 创建函数
function ReviveHandler:create()
    local handler = ReviveHandler.new()
    return handler
end

-- 获取复活回复
function ReviveHandler:handleRevive21015(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kReviveResp, event)
    else
        local strError = "返回错误码："..msg.header.result
    end
end

return ReviveHandler