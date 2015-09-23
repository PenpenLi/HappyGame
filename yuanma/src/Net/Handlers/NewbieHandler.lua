--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NewbieHandler.lua
-- author:    liyuhang
-- created:   2015/7/10
-- descrip:   新手引导的handler  
--===================================================
local NewbieHandler = class("NewbieHandler")

-- 构造函数
function NewbieHandler:ctor()
    -- 使用免死符
    NetHandlersManager:registHandler(21309, self.handleSaveNewerPro21309)
    -- 答题正确
    NetHandlersManager:registHandler(21311, self.handleQueryNewerPro21311)

end
-- 创建函数
function NewbieHandler:create()
    print("NewbieHandler create")
    local handler = NewbieHandler.new()
    return handler
end

--新手存档
function NewbieHandler:handleSaveNewerPro21309(msg)
    print("NewbieHandler 21309")
    if msg.header.result == 0 then
        
    else
        print("返回错误码："..msg.header.result)
    end
end

--获取新手存档
function NewbieHandler:handleQueryNewerPro21311(msg)
    print("NewbieHandler 21311")
    if msg.header.result == 0  and msg.body.progress ~= "" then
       cc.UserDefault:getInstance():setStringForKey("NewbieMainID_"..RolesManager:getInstance()._pMainRoleInfo.roleId, msg.body.progress)
       cc.UserDefault:getInstance():flush()
    else
        print("返回错误码："..msg.header.result)
    end
end

return NewbieHandler