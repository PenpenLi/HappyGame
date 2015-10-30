--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  LoginHandler.lua
-- author:    liyuhang
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   登录相关网络handler
--===================================================
local LoginHandler = class("LoginHandler")

-- 构造函数
function LoginHandler:ctor() 
    -- 注册登录账户返回的handler
    NetHandlersManager:registHandler(10001, self.handleMsgLoginAccount10001)
    -- 注册服务器列表返回的handler
    NetHandlersManager:registHandler(10003, self.handleMsgServerList10003)
    -- 注册母包登录账户返回的handler
    NetHandlersManager:registHandler(10005, self.handleMsgLoginAccountMother10005)
    -- 注册登录游戏返回的handler
    NetHandlersManager:registHandler(20001, self.handleMsgLoginGame20001)
    -- 注册随机名字返回的handler
    NetHandlersManager:registHandler(20003, self.handleMsgRandomName20003)
    -- 注册创建角色返回的handler
    NetHandlersManager:registHandler(20005, self.handleMsgCreateRole20005)
    -- 注册断线重连返回的handler
    NetHandlersManager:registHandler(20013, self.handleMsgReconnect20013)
    --注册获取公告连接的handler
    NetHandlersManager:registHandler(10007, self.handleMsgGetNoticeTagList10007)
    -- 注册获取公告里面某一个标签的handler
    NetHandlersManager:registHandler(10009, self.handleMsgGetNoticeDescResp10009)
    -- 注册选择分区的handler
    NetHandlersManager:registHandler(10011, self.handleMsgSelectZoneResp10011)
    -- 注册选择分区的handler
    NetHandlersManager:registHandler(10013, self.handleMsgQueryRankResp10013)
    -- 注册取消排队的handler
    NetHandlersManager:registHandler(10015, self.handleMsgCancelRankResp10015)
end

-- 创建函数
function LoginHandler:create()
    local handler = LoginHandler.new()
    return handler
end

-- 获取登录账户的结果
function LoginHandler:handleMsgLoginAccount10001(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kLoginAccount, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

-- 获取服务器列表的结果
function LoginHandler:handleMsgServerList10003(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kServerList, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

-- 获取母包登录账户的结果
function LoginHandler:handleMsgLoginAccountMother10005(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kLoginAccountMother, event)
        
        --mmo.HelpFunc:onRegitster(tostring(msg["body"].userId))
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

-- 登录游戏的结果
function LoginHandler:handleMsgLoginGame20001(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        LoginManager:getInstance()._tCurSessionId = msg["body"].sessionId
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kLoginGame, event)
        
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

-- 获取随机名字
function LoginHandler:handleMsgRandomName20003(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kRandomName, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

-- 创建角色回调
function LoginHandler:handleMsgCreateRole20005(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kCreateRole, event)
        
        LoginManager:getInstance()._nRoleId = msg["body"]["roleInfo"].roleId
        PetCGMessage:sendMessageGetPetsList21500()
        BagCommonCGMessage:sendMessageGetBagList20100()
        SkillCGMessage:sendMessageQuerySkillList21400()
        
        FriendCGMessage:sendMessageQueryFriendList22000()
        
        
        TaskCGMessage:sendMessageQueryTasks21700()
        MessageCommonUtil:sendMessageQueryNewerPro21310()
        
        --请求剧情副本信息
        MessageGameInstance:sendMessageQueryStoryBattleList21008(0)
        
        ActivityMessage:QueryActivityListReq22500()
       
        TDGAAccount:setAccount(tostring(msg["body"]["roleInfo"].roleId))
        --mmo.HelpFunc:onLogin(tostring(msg["body"]["roleInfo"].roleName))
        
    end 
end

-- 断线重连回调
function LoginHandler:handleMsgReconnect20013(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
         
        RolesManager:getInstance()._pMainRoleInfo = msg["body"].roleInfo[1]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetReconnected, {})
        
        BagCommonCGMessage:sendMessageGetBagList20100()
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

--获取公告的请求
function LoginHandler:handleMsgGetNoticeTagList10007(msg)
     if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNoticeTagListResp, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

--获取公告的请求
function LoginHandler:handleMsgGetNoticeDescResp10009(msg)
     if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNoticeDescResp, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

--选择分区回复
function LoginHandler:handleMsgSelectZoneResp10011(msg)
     if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kSelectZoneResp, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

--选择分区数据回复
function LoginHandler:handleMsgQueryRankResp10013(msg)
     if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryRankResp, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end

--选择分区回复
function LoginHandler:handleMsgCancelRankResp10015(msg)
     if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kCancelRankResp, event)
    else
        local strError = "返回错误码："..msg.header.result
        print(strError)
    end
end



return LoginHandler