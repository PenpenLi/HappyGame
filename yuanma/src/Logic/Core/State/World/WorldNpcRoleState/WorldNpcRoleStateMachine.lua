--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldNpcRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   世界中玩家角色状态机
--===================================================
local WorldNpcRoleStateMachine = class("WorldNpcRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function WorldNpcRoleStateMachine:ctor()
    self._strName = "WorldNpcRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kWorldNpcRole  -- 状态类机型ID
end

-- 创建函数
function WorldNpcRoleStateMachine:create(master)
    local machine = WorldNpcRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function WorldNpcRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    
    self:setMaster(master)
    
    self:addState(require("WorldNpcRoleStandState"):create())  -- 加入站立状态到状态机
    self:setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand)  -- 设置当前状态为站立状态
    return
end

-- 退出函数
function WorldNpcRoleStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function WorldNpcRoleStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

return WorldNpcRoleStateMachine
