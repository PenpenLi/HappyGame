--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Task.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/6
-- descrip:   任务对象基类
--===================================================
local Task = class("Task")

-- 构造函数
function Task:ctor()
    self._strName = "Task"                  -- 任务名称
    self._bActiveOperateQueue = false       -- 是否已经激活操作队列
    self._nCurOperateIndex = 1              -- 当前操作在操作队列中的index
    self._tOperateQueue = {}                -- 操作队列

    self._nTaskId = 0                       -- 任务id
    self._pTaskData = nil                   -- 当前任务数据
end

-- 创建函数
function Task:create(taskInfo)
    local task = Task.new()
    task:dispose(taskInfo)
    return task
end

-- 初始化
function Task:dispose(taskInfo)
    self._nTaskId = taskInfo.taskId
    
    self._pTaskData = TasksManager:getInstance():getTaskInfoWithTaskInfo(taskInfo)

    -- 解析args中逻辑单元的id
    local queue = self._pTaskData.operateQueue
    
    -- 给任务中的操作队列添加操作
    for kOperate, vOperate in pairs(queue) do
        if vOperate.id == 1.0 then -- 剧情对话
            table.insert(self._tOperateQueue,require("OperateTalk"):create(vOperate.args))
        elseif vOperate.id == 2.0 then -- 引导至NPC
            table.insert(self._tOperateQueue,require("OperateSearchPath"):create(vOperate.args))
        elseif vOperate.id == 3.0 then -- 跳转到xx副本界面（可选：选定对应关卡）
            table.insert(self._tOperateQueue,require("OperateBattleCopy"):create(vOperate.args))
        elseif vOperate.id == 4.0 then -- 弹出系统面板
            table.insert(self._tOperateQueue,require("OperateSystemSkip"):create(vOperate.args))
        end
        
        
        
    end
    
end

-- 循环更新
function Task:update(dt)

    -- 已经激活了操作队列时，开始更新当前操作的update
    if self._bActiveOperateQueue == true then
        if self._nCurOperateIndex <= table.getn(self._tOperateQueue) then
            self._tOperateQueue[self._nCurOperateIndex]:onUpdate(dt)
            -- 如果中途发生了异常中断，则复位操作队列数据
            if self._tOperateQueue[self._nCurOperateIndex]._bException == true then
                self:resetOperateQueue()
                return
            end
            -- 检测是否已经操作结束
            self._tOperateQueue[self._nCurOperateIndex]:checkOver(dt)
            --  当前操作已经执行结束，则切换到下一个操作
            if self._tOperateQueue[self._nCurOperateIndex]._bIsOver == true then
                self._nCurOperateIndex = self._nCurOperateIndex + 1
                -- 合法则切换到下一个操作，否则操作队列结束
                if self._nCurOperateIndex <= table.getn(self._tOperateQueue) then
                    self._tOperateQueue[self._nCurOperateIndex]:onEnter()
                else
                    self._bActiveOperateQueue = false       -- 操作队列全部执行完毕
                    print("任务操作队列执行全部结束！")
                end
            end
        end
    end

    return
end

-- 设置激活操作队列（前往）（使用操作队列的入口调用）
function Task:startOperateQueue()
    
    -- 复位操作队列
    self:resetOperateQueue()
    
    -- 激活操作队列
    self._bActiveOperateQueue = true
    
    -- 从第一个操作开始
    self._nCurOperateIndex = 1
    self._tOperateQueue[self._nCurOperateIndex]:onEnter()
    
end

-- 复位操作队列
function Task:resetOperateQueue()
    -- 所有操作复位
    for k, v in pairs(self._tOperateQueue) do 
        v:reset()
    end
    -- 操作队里的激活关闭
    self._bActiveOperateQueue = false
end

return Task
