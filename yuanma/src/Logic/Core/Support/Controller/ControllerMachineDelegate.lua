--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ControllerMachineDelegate.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   控制机代理器
--===================================================
local ControllerMachineDelegate = class("ControllerMachineDelegate")

-- 构造函数
function ControllerMachineDelegate:ctor()
    self._strName = "ControllerMachineDelegate"         -- 控制机组名称
    self._tControllerMachines = {}                      -- 控制机集合(格式：键：控制机typeID  值：控制机)
end

-- 创造函数
function ControllerMachineDelegate:create()
    local delegate = ControllerMachineDelegate.new()
    return delegate
end

-- 退出所有控制机
function ControllerMachineDelegate:onExitAllControllerMachines()
    for k,v in pairs(self._tControllerMachines) do
        v:onExit()
    end
    return
end

-- 逻辑更新
function ControllerMachineDelegate:procAllControllerMachines(dt)
    for k,v in pairs(self._tControllerMachines) do
        v:update(dt)
    end
    return
end

-- 更具typeId获取控制机
function ControllerMachineDelegate:getControllerMachineByTypeID(id)
    return self._tControllerMachines[id]
end

-- 添加控制机
function ControllerMachineDelegate:addControllerMachine(pMachine)
    local kMachineID = pMachine._kTypeID
    if self._tControllerMachines[kMachineID] == nil then
        print(pMachine._strName .. " add success!")
        self._tControllerMachines[kMachineID] = pMachine
    else
        print(pMachine._strName .. " has already exists!")
    end
    return
end

return ControllerMachineDelegate
