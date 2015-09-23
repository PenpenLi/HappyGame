--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StateMachineDelegate.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   状态机代理器
--===================================================
local StateMachineDelegate = class("StateMachineDelegate")

-- 构造函数
function StateMachineDelegate:ctor()
    self._strName = "StateMachineDelegate"              -- 状态机组名称
    self._tStateMachines = {}                           -- 状态机集合(格式：键：状态机typeID  值：状态机)
end

-- 创建函数
function StateMachineDelegate:create()
    local delegate = StateMachineDelegate.new()
    return delegate
end

-- 退出所有状态机
function StateMachineDelegate:onExitAllStateMachines()
    for k,v in pairs(self._tStateMachines) do
        v:onExit()
    end
    return
end

-- 更新逻辑
function StateMachineDelegate:procAllStateMachines(dt)
    for k,v in pairs(self._tStateMachines) do
        v:update(dt)
    end
    return
end

-- 根据typeID获取状态机
function StateMachineDelegate:getStateMachineByTypeID(id)
    return self._tStateMachines[id]
end

-- 添加状态机
function StateMachineDelegate:addStateMachine(pMachine)
    local kMachineID = pMachine._kTypeID
    if self._tStateMachines[kMachineID] == nil then
        print(pMachine._strName .. " add success!")
        self._tStateMachines[kMachineID] = pMachine
    else
        print(pMachine._strName .. " has already exists!")
    end
    return
end

return StateMachineDelegate
