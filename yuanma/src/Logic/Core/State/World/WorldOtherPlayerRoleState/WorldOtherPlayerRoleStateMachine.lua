--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldOtherPlayerRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/25
-- descrip:   世界中其他玩家角色状态机
--===================================================
local WorldOtherPlayerRoleStateMachine = class("WorldOtherPlayerRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function WorldOtherPlayerRoleStateMachine:ctor()
    self._strName = "WorldOtherPlayerRoleStateMachine"    -- 状态机名称
    self._kTypeID = kType.kStateMachine.kWorldOtherPlayerRole  -- 状态类机型ID
end

-- 创建函数
function WorldOtherPlayerRoleStateMachine:create(master)
    local machine = WorldOtherPlayerRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function WorldOtherPlayerRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    
    self:setMaster(master)
    
    self:addState(require("WorldOtherPlayerRoleStandState"):create())    -- 加入站立状态到状态机
    self:addState(require("WorldOtherPlayerRoleRunState"):create())      -- 加入奔跑状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kWorldOtherPlayerRole.kStand)  -- 设置当前状态为站立状态
    
    return
end

-- 退出函数
function WorldOtherPlayerRoleStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function WorldOtherPlayerRoleStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

return WorldOtherPlayerRoleStateMachine
