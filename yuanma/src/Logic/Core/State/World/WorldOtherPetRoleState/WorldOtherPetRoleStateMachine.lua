--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldOtherPetRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/25
-- descrip:   世界中其他玩家宠物角色状态机
--===================================================
local WorldOtherPetRoleStateMachine = class("WorldOtherPetRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function WorldOtherPetRoleStateMachine:ctor()
    self._strName = "WorldOtherPetRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kWorldOtherPetRole  -- 状态类机型ID
    
end

-- 创建函数
function WorldOtherPetRoleStateMachine:create(master)
    local machine = WorldOtherPetRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function WorldOtherPetRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    
    self:setMaster(master)
    
    self:addState(require("WorldOtherPetRoleStandState"):create())  -- 加入站立状态到状态机
    self:addState(require("WorldOtherPetRoleRunState"):create())    -- 加入奔跑状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kWorldOtherPetRole.kStand)  -- 设置当前状态为站立状态
    
    return
end

-- 退出函数
function WorldOtherPetRoleStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function WorldOtherPetRoleStateMachine:update(dt)    
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

return WorldOtherPetRoleStateMachine
