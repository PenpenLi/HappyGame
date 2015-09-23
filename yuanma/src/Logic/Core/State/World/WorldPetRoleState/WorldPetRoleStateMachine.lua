--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldPetRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   世界中玩家宠物角色状态机
--===================================================
local WorldPetRoleStateMachine = class("WorldPetRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function WorldPetRoleStateMachine:ctor()
    self._strName = "WorldPetRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kWorldPetRole  -- 状态类机型ID
    
end

-- 创建函数
function WorldPetRoleStateMachine:create(master)
    local machine = WorldPetRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function WorldPetRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    
    self:setMaster(master)
    
    self:addState(require("WorldPetRoleStandState"):create())  -- 加入站立状态到状态机
    self:addState(require("WorldPetRoleRunState"):create())    -- 加入奔跑状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kWorldPetRole.kStand)  -- 设置当前状态为站立状态
    
    return
end

-- 退出函数
function WorldPetRoleStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function WorldPetRoleStateMachine:update(dt)    
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

return WorldPetRoleStateMachine
