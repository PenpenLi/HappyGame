--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChatHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/6/24
-- descrip:  聊天的handler  
--===================================================
local ChatHandler = class("ChatHandler")

-- 构造函数
function ChatHandler:ctor()
    --服务器主动推送的聊天内容
    NetHandlersManager:registHandler(29519, self.handleChatNotice29519)
    -- 发送聊天回复
    NetHandlersManager:registHandler(21303, self.handleChat21303)
    -- 查询黑名单回复
    NetHandlersManager:registHandler(21305, self.handleQueryBlackList21305)
    -- 设置黑名单回复
    NetHandlersManager:registHandler(21307, self.handleSetBlackList21307)

end
-- 创建函数
function ChatHandler:create()
    print("ChatHandler create")
    local handler = ChatHandler.new()
    return handler
end

--服务器主动推送的聊天内容
function ChatHandler:handleChatNotice29519(msg)
    print("ChatHandler 29519")
    if msg.header.result == 0 then 
        ChatManager:getInstance():insertChat(msg["body"])
    else
        print("返回错误码："..msg.header.result)
    end
end

--发送聊天内容
function ChatHandler:handleChat21303(msg)
    print("ChatHandler 21303")
    if msg.header.result == 0 then
       -- release_print("Message Has Resp")
        ChatManager:getInstance():setSendChatResp(msg["body"])
    else
        print("返回错误码："..msg.header.result)
    end
end

--查询黑名单回复
function ChatHandler:handleQueryBlackList21305(msg)
    print("ChatHandler 21305")
    if msg.header.result == 0 then
        ChatManager:getInstance()._tBlacklist = msg["body"].blacklist
    else
        print("返回错误码："..msg.header.result)
    end
end

--设置黑名单回复
function ChatHandler:handleSetBlackList21307(msg)
    print("ChatHandler 21307")
    if msg.header.result == 0 then
       ChatManager:getInstance()._tBlacklist = msg["body"].blacklist
       NetRespManager:getInstance():dispatchEvent(kNetCmd.kSetBlackList)
    else
        print("返回错误码："..msg.header.result)
    end
end

return ChatHandler