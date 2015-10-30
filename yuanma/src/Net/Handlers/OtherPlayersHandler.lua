--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OtherPlayersHandler.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/25
-- descrip:   其他玩家角色相关网络handler
--===================================================
local OtherPlayersHandler = class("OtherPlayersHandler")

-- 构造函数
function OtherPlayersHandler:ctor() 
    -- 其他玩家角色信息返回的handler
    NetHandlersManager:registHandler(20015, self.handleMsgOtherPlayerInfo20015)
end

-- 创建函数
function OtherPlayersHandler:create()
    local handler = OtherPlayersHandler.new()
    return handler
end

-- 获取其他玩家信息的结果
function OtherPlayersHandler:handleMsgOtherPlayerInfo20015(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        RolesManager:getInstance()._tOtherPlayerRolesInfosOnWorldMap = event.roleInfos
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kOtherPlayerInfos, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

return OtherPlayersHandler