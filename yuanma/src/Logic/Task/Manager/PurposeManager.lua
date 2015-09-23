--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PurposeManager.lua
-- author:    liyuhang
-- created:   2015/7/28
-- descrip:   目标管理器（全局有效，不需要阶段性的清理）
--===================================================
PurposeManager = {}

local instance = nil

-- 单例
function PurposeManager:getInstance()
    if not instance then
        instance = PurposeManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function PurposeManager:clearCache()
    self._tPurposes = {}
    self._pFaildGruidId = nil
end

-- 循环处理
function PurposeManager:update(dt)
    for k,v in pairs(self._tPurposes) do
        v:update(dt)
    end
end

-- 根据id创建任务对象
function PurposeManager:createPurpose(queueId)
    local temp = self:getPurposeWithId(queueId)
    if temp ~= nil then
    	return
    end

    local purpose = require("Purpose"):create(queueId)       -- 操作队列id
    table.insert(self._tPurposes, purpose)
end

function PurposeManager:getPurposeWithId(queueId)
    for i=1,table.getn(self._tPurposes) do
        if self._tPurposes[i]._nOperateQueueId == queueId then
            return self._tPurposes[i] 
		end
	end
	
    return nil
end

-- 目的执行
function PurposeManager:startOperateByTaskId(queueId)
    DialogManager:getInstance():closeAllDialogs()

    for k,v in pairs(self._tPurposes) do
        if v._nOperateQueueId == queueId then
            v:startOperateQueue()
        end
    end
end

-- 根据id删除目标对象
function PurposeManager:removeTaskByTaskId(queueId)
    for i=1,table.getn(self._tPurposes) do
        if self._tPurposes[i]._nOperateQueueId == queueId then
            table.remove(self._tPurposes,i)
            break
        end
    end
end

function PurposeManager:getFaildGruidId()
    local pId = self._pFaildGruidId
    self._pFaildGruidId = nil
    return pId
end
