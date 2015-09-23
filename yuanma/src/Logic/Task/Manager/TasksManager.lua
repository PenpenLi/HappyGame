--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TasksManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/6
-- descrip:   任务管理器（全局有效，不需要阶段性的清理）
--===================================================
TasksManager = {}

local instance = nil

-- 单例
function TasksManager:getInstance()
    if not instance then
        instance = TasksManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function TasksManager:clearCache()
    self._pMainTask = nil               -- 主线任务
    self._tBranchTasks = {}             -- 支线任务集合
    self._tDailyTasks = {}              -- 每日任务集合
    
    --任务状态，活跃度状态数据
    self._pVitalityInfo = nil           --VitalityInfo
    self._pTaskInfos = nil              --taskInfo
    self._pMainTaskInfo = nil           -- 主线任务
    self._pTaskSortInfos = {}              --taskInfo
    
    self._tTasks = {}                   --Task
    
    self._tTaskTableDatas = {}
    self._tTaskTableDatas[kTaskType.kMain] = TableTaskMain
    self._tTaskTableDatas[kTaskType.kSub] = TableTaskSub
    self._tTaskTableDatas[kTaskType.kBounty] = TableTaskBounty
    self._tTaskTableDatas[kTaskType.kDaily] = TableTaskDaily
    self._tTaskTableDatas[kTaskType.kFamily] = TableTaskFamily
    
    --是否需要滚到指定副本位置
    self._bNeedScroll = false
    self._nScrollCopyId = 0
    
    --是否受到所有数据
    self._bGetInitData = false
    --是否是打开剑灵面板及参数
    self._bOpenBladeSoul = false
    self._nOpenType = 0
    --剧情副本的数据
    self._tStoryCopyOpenId = {}
    self._bStoryDataInit = false
end

-- 循环处理
function TasksManager:update(dt)
    for k,v in pairs(self._tTasks) do
        v:update(dt)
    end
end

-- 根据任务列表信息创建任务对象
function TasksManager:createTaskWithTaskInfos(taskInfos)
    if taskInfos == nil then
    	return
    end

    for i=1,table.getn(taskInfos) do
        self:createTask(taskInfos[i])
	end
end

-- 根据id创建任务对象
function TasksManager:createTask(taskInfo)
    local task = require("Task"):create(taskInfo)       -- 操作队列id
    table.insert(self._tTasks, task)
end

-- 停止所有任务前往
function TasksManager:stopAllOperate()
    for k,v in pairs(self._tTasks) do
        v:resetOperateQueue()
    end
end

-- 根据id执行任务前往功能
function TasksManager:startOperateByTaskId(taskId)
    for k,v in pairs(self._tTasks) do
        if v._nTaskId == taskId and v._bActiveOperateQueue == false then
			v:startOperateQueue()
		end
	end
end

-- 是否有任务队列在播放状态
function TasksManager:getAllOperateBeOver()
    for k,v in pairs(self._tTasks) do
        if v._bActiveOperateQueue == true then
            return false
        end
    end
    
    return true
end

-- 根据id删除任务对象
function TasksManager:removeTaskByTaskId(taskId)
    for i=1,table.getn(self._tTasks) do
        if self._tTasks[i]._nTaskId == taskId then
            table.remove(self._tTasks,i)
            break
		end
	end
end

-- 根据任务列表信息刷新任务对象
function TasksManager:refreshTasksWithTaskInfos(taskInfos)
    self._tTasks = {}                   --Task.
    
    self:createTaskWithTaskInfos(taskInfos)
end

-- 设置自动滚动
function TasksManager:setAutoScrollById(taskId)
    self._bNeedScroll = true
    self._nScrollCopyId = taskId
end

-- 重置自动滚动
function TasksManager:setAutoScrollOver()
    self._bNeedScroll = false
    self._nScrollCopyId = 0
end

-- 设置任务列表
function TasksManager:setTaskInfos(taskInfos)
    self._pTaskInfos = taskInfos
    local overTaskInfos = {}
    local normalTaskInfos = {}
    
    self._pTaskSortInfos = {}
    
    for i=1,table.getn(self._pTaskInfos) do
        if self._pTaskInfos[i].state == 2 then
            table.insert(overTaskInfos,self._pTaskInfos[i])
            NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "任务按钮" , value = true})
        elseif self._pTaskInfos[i].state == 1 then
            table.insert(normalTaskInfos,self._pTaskInfos[i])
    	end
    	-- 提取主线任务
        local index,mov = math.modf(self._pTaskInfos[i].taskId/10000)
        if index == kTaskType.kMain then
            self._pMainTaskInfo = self._pTaskInfos[i]
            NetRespManager:dispatchEvent(kNetCmd.kMainTaskChange,{})
    	end
    end
    
    if table.getn(overTaskInfos) == 0 then
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "任务按钮" , value = false})
    end
    
    for i=1,table.getn(overTaskInfos) do
        table.insert(self._pTaskSortInfos,overTaskInfos[i])
    end
    
    for i=1,table.getn(normalTaskInfos) do
        table.insert(self._pTaskSortInfos,normalTaskInfos[i])
    end
end

--设置剑灵打开状态
function TasksManager:setAutoBladesoulType(type)
    self._bOpenBladeSoul = true
    self._nOpenType = type
end

--重置剑灵打开状态
function TasksManager:resetAutoBladesoulType()
    self._bOpenBladeSoul = false
    self._nOpenType = 0
end

--设置剧情副本的数据
function TasksManager:setStoryCopyInfo(tCopyInfo)
    local tOpenStoryId = {}
    for k,v in pairs(tCopyInfo) do
        for i=1,table.getn(v.btInfos) do
         table.insert(tOpenStoryId,v.btInfos[i].battleId)
        end
    end
	 self._tStoryCopyOpenId = tOpenStoryId
	 self._bStoryDataInit = true
end

--通过副本id来判断副本是否开启
function TasksManager:getCopyHasOpenByBattleId(nBattleId)
    for k,v in pairs(self._tStoryCopyOpenId) do
        if v == nBattleId then
        	return true
        end
	end
    return false
end



---------------------------------------数据表相关操作-------------------------------------

--通过id获取副本表数据
function TasksManager:getTaskInfoWithTaskInfo(taskInfo)
    local result = {}
    result.state = taskInfo.state
    result.progress = taskInfo.progress

    local index,mov = math.modf(taskInfo.taskId/10000)
    local temp = taskInfo.taskId % 10000
    if self._tTaskTableDatas[index][temp] ~= nil then
        result.data = self._tTaskTableDatas[index][temp]
        result.operateQueue = TableOperateQueues[result.data.OperateQueues].Queue
    end
    
    return result
end

