--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CDManager.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   时间刷新管理器
--===================================================
CDManager = {}

local instance = nil

-- 单例
function CDManager:getInstance()
    if not instance then
        instance = CDManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function CDManager:clearCache()
    self._tAllCdTime = {}
    self._pScheduler = nil
    
end

--添加一个cd{1:cd的Key，2：cd的时间,3回调函数(获取当前cd时间),}
function CDManager:insertCD(args)
    for k,v in pairs(self._tAllCdTime) do
        if v.key == args[1] then --说明是cd队列里面有该key的cd了 直接覆盖
           self._tAllCdTime[k] = {key = args[1],value = args[2],func = args[3]}  
           return 
        end
    end
    if table.getn(self._tAllCdTime) == 0 then
      self:startScheduler()
    end    
    table.insert(self._tAllCdTime,{key = args[1],value = args[2],func = args[3]})
end

--删除某个cd通过该cd的Key
function CDManager:deleteOneCdByKey(nKey)
    for k,v in pairs(self._tAllCdTime) do
        if v.key== nKey then --找到后直接删除
            table.remove(self._tAllCdTime,k)  
            if table.getn( self._tAllCdTime) == 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduler)
                return
            end
            return true
        end
    end
    return false --没有找到
end

--得到某个key的时间
function CDManager:getOneCdTimeByKey(nKey)
    for k,v in pairs(self._tAllCdTime) do
        if v.key == nKey then 
            return v.value,v.func
        end
    end
    return 0
end


--开始定时器
function CDManager:startScheduler()
    local timeUpdate = function (dt)
            for k,v in pairs(self._tAllCdTime) do
                v.value = v.value - 1
                if v.value <= 0 then
                    v.value =  0
                    table.remove(self._tAllCdTime,k)
                end
                if v.func ~= nil then
                    v.func(v.value,v.key)
                end
                if table.getn( self._tAllCdTime) == 0 then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduler)
                    return
                end
            end
    	
    end
    self._pScheduler =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(timeUpdate,1,false)
end



-- 循环处理
function CDManager:update(dt)
  
end


