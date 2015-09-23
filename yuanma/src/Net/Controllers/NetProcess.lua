--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NetProcess.lua
-- author:    liyuhang
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   网络基本操作
--===================================================

-- 断线后需要重连的次数
nSocketReconnectNum = 10

-- 网络交互次数计数器（全局计数）
nSeqNum = 1

-- 网络收发引用缓存，用于控制网络等待菊花显示的时机（发送时：seqNum计入缓存； 对应接收时：seqNum从缓存清除）
tCountSeq = {}

-- socket连接服务器
function connectTo(ip,port)
    -- body
    print("----- 连接到IP地址 : " .. ip.." 端口："..port.." -----")
    net.connectToServer(ip,port)
end

--断开链接
function disconnect()
    net.disconnect()
end

function isConnect()
	return mmo.HelpFunc:isSocketConnect()
end

-- socket发送协议
function send(msg)
    -- 断线续连
    --[[
    if isConnect() == false then
        local info = LoginManager:getInstance()._tLastServer
        connectTo(info.ipAddr,info.port)
        LoginCGMessage:sendMessageLoginGame20000()
    end
    ]]
    
    if isConnect() == false then
        return
    end
    
    print("----- 发送协议："..msg.header.cmdNum.." -----")
    net.send(msg)
    
    -- 添加seqNum到缓存
    local argsBody = nil
    if msg.body ~= nil then
        argsBody = msg.body
    else
        argsBody = {}
    end
    table.insert(tCountSeq, {seqNum = nSeqNum , args = argsBody})
    
    -- 设置网络等待中...
    cc.Director:getInstance():getRunningScene()._bNetWaiting = true
    
    -- 发送完毕后 seqNum 需要自加
    nSeqNum = nSeqNum + 1
    
end

-- socket收到消息后的回调处理
function executeData(msgname)
    local Messagetable = _G[msgname]

    for k,v in pairs(tCountSeq) do
        if v.seqNum == Messagetable.header.cmdSeq then
            -- 将seqNum从缓存中清除
            Messagetable["body"]["argsBody"] = v.args
            table.remove(tCountSeq,k)
            break
        end
    end
    
    -- 如果缓存中的seqNum已经全部被移除，则设置网络无等待
    if table.getn(tCountSeq) == 0 then
        cc.Director:getInstance():getRunningScene()._bNetWaiting = false
    end

    if Messagetable.header.result ~= 0 then --如果返回错误码直接调用全局函数统一处理
        setNetErrorShow(Messagetable.header.result,Messagetable.header.reserve) 
    end

    NetHandlersManager:getInstance():executeHandler(msgname)
    return 0
end

-- socket更新回调
function socketUpdate()
    net.update()
end

--读取协议文件
function loadMessageProcotolFiles()
	
    net.loadMessageFile()  
	
end

--验证socket是否连接
function getSocketIsOpen()
    return mmo.HelpFunc:isSocketConnect()
end

--回复socket连接状态
function respConnectedStatus(isOpen)
    print("socket is " .. tostring(isOpen))
end

--连接断开，超时，异常状态回调函数
function socketOnEventCallback(event)
    DialogManager:getInstance():showAlertDialog(event)
end

-- 收到 socket 链接中断的事件处理
function socketDisconnected(event)
    cclog("服务器链接断开！")
    local info = LoginManager:getInstance()._tLastServer
    local isReconnected = false
    tCountSeq = {}
    cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = true
    
    if info == nil then
        if LayerManager:getCurSenceLayerSessionId() == kSession.kLogin then
            DialogManager:showAlertDialog("网络未连接，请检查网络设置。")
        	return
        end
        
        cc.Director:getInstance():showNetErrorDialog()
    
        --DialogManager:getInstance():showNetErrorDialog("与服务器断开连接,是否重试?",
        --    function() socketDisconnected("disconnect") end,
        --    function() LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER) end)
        cc.Director:getInstance():getRunningScene()._bNetWaiting = false
    	return
    end
    
    -- 开始重联
    cc.Director:getInstance():getRunningScene():reconnectHandle(info)
    
end

-- 收到 socket 通讯超时的事件处理
function socketTimeOut(event)
    cclog("服务器超时！")
    if isConnect() == true then
        disconnect()
    end
    
    local info = LoginManager:getInstance()._tLastServer
    local isReconnected = false
    tCountSeq = {}
    cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = true

    if info == nil then
        if LayerManager:getCurSenceLayerSessionId() == kSession.kLogin then
            DialogManager:showAlertDialog("网络未连接，请检查网络设置。")
            return
        end
        
        cc.Director:getInstance():showNetErrorDialog()
    
        --DialogManager:getInstance():showNetErrorDialog("与服务器断开连接,是否重试?",
        --    function() socketDisconnected("disconnect") end,
        --    function() LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER) end)
        cc.Director:getInstance():getRunningScene()._bNetWaiting = false
        return
    end

    for i=1 ,nSocketReconnectNum do
        cclog("第"..i.. "次重连")
        connectTo(info.ipAddr,info.port)
        if isConnect() == true then
            isReconnected = true
            cclog("服务器重新连接成功！")
            if LoginManager:getInstance()._nRoleId ~= 0 then
                LoginCGMessage:sendMessageReconnect(LoginManager:getInstance()._nRoleId)
            end
            cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = false
            break
        end
    end

    if isReconnected == false then
        cc.Director:getInstance():getRunningScene():showNetErrorDialog()
        cc.Director:getInstance():getRunningScene()._bNetWaiting = false
    end
end

