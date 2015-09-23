--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TaskHandler.lua
-- author:    liyuhang
-- created:   2015/5/12
-- descrip:   任务相关handler
--===================================================
local TaskHandler = class("TaskHandler")

-- 构造函数
function TaskHandler:ctor()     
    -- 获取任务列表
    NetHandlersManager:registHandler(21701, self.handleMsgQueryTasks)
    -- 领取任务奖励
    NetHandlersManager:registHandler(21703, self.handleMsgGainTaskAward)
    -- 领取活跃度礼包
    NetHandlersManager:registHandler(21705, self.handleMsgGainVitalityAward)
    -- 任务数据刷新返回的handler
    NetHandlersManager:registHandler(29507, self.handleTaskRefreshNotice29507)
end

-- 创建函数
function TaskHandler:create()
    print("TaskHandler create")
    local handler = TaskHandler.new()
    return handler
end

-- 获取任务列表
function TaskHandler:handleMsgQueryTasks(msg)
    print("TaskHandler 21401")
    if msg.header.result == 0 then 
        TasksManager:getInstance()._pVitalityInfo = msg.body.vitalityInfo           --VitalityInfo
        --TasksManager:getInstance()._pTaskInfos = msg.body.tasks              --taskInfo
        TasksManager:setTaskInfos(msg.body.tasks)
        TasksManager:getInstance()._bGetInitData = true
        TasksManager:getInstance():refreshTasksWithTaskInfos(msg.body.tasks)
        
        --DialogManager:getInstance():showDialog("TaskDialog",{msg.body})
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryTasksResp, msg.body)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 领取任务奖励
function TaskHandler:handleMsgGainTaskAward(msg)
    print("TaskHandler 21403")
    if msg.header.result == 0 then 
        TasksManager:getInstance()._pVitalityInfo.vitality =  msg.body.vitality
        --TasksManager:getInstance()._pTaskInfos = msg.body.tasks              --taskInfo
        TasksManager:setTaskInfos(msg.body.tasks)

        TasksManager:getInstance():refreshTasksWithTaskInfos(msg.body.tasks)

        NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainTaskAwardResp, msg.body)
        
        RolesManager._pMainRoleInfo.exp = msg.body.addexp + RolesManager._pMainRoleInfo.exp
        -- 更新角色的属性
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
        
        NewbieManager:showOutAndRemoveWithRunTime()
        
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

-- 领取活跃度礼包
function TaskHandler:handleMsgGainVitalityAward(msg)
    print("TaskHandler 21405")
    if msg.header.result == 0 then 
        TasksManager:getInstance()._pVitalityInfo = msg.body.vitalityInfo           --VitalityInfo
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kGainVitalityAward, msg.body)
    else
        print("返回错误码："..msg.header.result)
    end
end

function TaskHandler:handleTaskRefreshNotice29507(msg)
    print("TaskHandler 29507")
    if msg.header.result == 0 then 
        local tasks = msg.body.tasks
        
        local beFinishTask = false
        for i=1,table.getn(tasks) do
            if tasks[i].state == kTaskState.kFinish then
                beFinishTask = true
                TaskCGMessage:sendMessageQueryTasks21700()
            end   
        end
        
    else
        print("返回错误码："..msg.header.result)
    end
end

return TaskHandler