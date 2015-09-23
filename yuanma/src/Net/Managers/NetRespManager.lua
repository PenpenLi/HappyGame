--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NetRespManager.lua
-- author:    liyuhang
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   网络回调监听Listener管理器
--===================================================

NetRespManager = {}

local instance = nil

-- 单例
function NetRespManager:getInstance()
    if not instance then
        instance = NetRespManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function NetRespManager:clearCache()
    print("NetRespManager cache")
    self.listeners_ = {}
end

-- 判断是否已经添加
function NetRespManager:checkAdded(eventName,host)
    if self.listeners_[eventName] == nil then
        return false
    end
    
    local isAdded = false
    for i=1,table.getn(self.listeners_[eventName]) do
        if self.listeners_[eventName][i]["hostObj"] == host then
    		isAdded = true
    	end
    end
    return isAdded
end

--添加时间监听
function NetRespManager:addEventListener(eventName, listener)
    if self.listeners_[eventName] == nil then
        self.listeners_[eventName] = {}
    end
    
    local isAdded = self:checkAdded(eventName,listener["hostObj"])
    
    if isAdded == false then
        table.insert(self.listeners_[eventName],listener)
    end
end

--发送事件，触发回调
function NetRespManager:dispatchEvent(cmdName, event)  
    if self.listeners_[cmdName] == nil then return end

    for handle, listener in pairs(self.listeners_[cmdName]) do
        listener["doHandle"](event)
    end
end

function NetRespManager:removeEventListener(handleToRemove)
    for eventName, listenersForEvent in pairs(self.listeners_) do
        for i=1, table.getn(listenersForEvent) do
            if listenersForEvent[i]["handle"] == handleToRemove then
                table.remove(listenersForEvent,i)
                break
            end
        end
    end
end

--清除 载体 所观察的所有事件
function NetRespManager:removeEventListenersByHost(host)
    for eventName, listenersForEvent in pairs(self.listeners_) do      
        for i=1, table.getn(listenersForEvent) do
            if listenersForEvent[i]["hostObj"] == host then
                table.remove(listenersForEvent,i)
                break
            end
        end
    end
end

function NetRespManager:removeEventListenersByEvent(eventName)
    self.listeners_[eventName] = nil
end

function NetRespManager:removeAllEventListeners()
    self.listeners_ = {}
end

function NetRespManager:hasEventListener(eventName)
    local t = self.listeners_[eventName]
    for _, __ in pairs(t) do
        return true
    end
    return false
end
