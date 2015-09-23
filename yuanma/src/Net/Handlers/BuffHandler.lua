--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BuffHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/22
-- descrip:  buff的handler  
--===================================================
local BuffHandler = class("BuffHandler")

-- 构造函数
function BuffHandler:ctor()
    -- 得到buff
    NetHandlersManager:registHandler(23101, self.handleGetBuff23101)
    --服务器主动推送的buff
    NetHandlersManager:registHandler(29509, self.handleBuffNoticeGet29509)
end
-- 创建函数
function BuffHandler:create()
    print("BuffHandler create")
    local handler = BuffHandler.new()
    return handler
end

--得到buff
function BuffHandler:handleGetBuff23101(msg)
    print("BuffHandler 23101")
    if msg.header.result == 0 then
        BuffManager:getInstance():insertBuff(msg["body"].buffs)
    else
        print("返回错误码："..msg.header.result)
    end
end

--服务器主动推送的buff
function BuffHandler:handleBuffNoticeGet29509(msg)
    print("BuffHandler 29509")
    if msg.header.result == 0 then
        BuffManager:getInstance():insertBuff(msg["body"].buffs)
    else
        print("返回错误码："..msg.header.result)
    end
end


return BuffHandler