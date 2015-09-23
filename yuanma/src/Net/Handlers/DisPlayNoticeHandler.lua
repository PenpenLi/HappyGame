--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DisPlayNoticeHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/8
-- descrip:   跑马灯数据通知的handler
--===================================================
local DisPlayNoticeHandler = class("DisPlayNoticeHandler")

-- 构造函数
function DisPlayNoticeHandler:ctor()     
    -- 跑马灯数据返回的handler
    NetHandlersManager:registHandler(29503, self.handleDisPlayNotice29503)
end

-- 创建函数
function DisPlayNoticeHandler:create()
    local handler = DisPlayNoticeHandler.new()
    return handler
end

-- 网络关于跑马灯数据的通知结果
function DisPlayNoticeHandler:handleDisPlayNotice29503(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kDisPlayNotice,event)
    else
        local strError = "返回错误码："..msg.header.result
    end
end

return DisPlayNoticeHandler