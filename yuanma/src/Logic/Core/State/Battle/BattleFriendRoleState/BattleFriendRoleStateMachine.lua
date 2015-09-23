--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/12
-- descrip:   战斗中好友角色状态机
--===================================================
local BattleFriendRoleStateMachine = class("BattleFriendRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function BattleFriendRoleStateMachine:ctor()
    self._strName = "BattleFriendRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kBattleFriendRole  -- 状态类机型ID
    
end

-- 创建函数
function BattleFriendRoleStateMachine:create(master)
    local machine = BattleFriendRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattleFriendRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    -- mmo.DebugHelper:showJavaLog("mmo:BattleFriendRoleStateMachine")
    self:setMaster(master)
    
    self:addState(require("BattleFriendRoleSuspendState"):create())     -- 加入挂起状态到状态机
    self:addState(require("BattleFriendRoleAppearState"):create())      -- 加入出场状态到状态机
    self:addState(require("BattleFriendRoleStandState"):create())       -- 加入站立状态到状态机
    self:addState(require("BattleFriendRoleSkillAttackState"):create()) -- 加入技能攻击状态到状态机
    self:addState(require("BattleFriendRoleDisAppearState"):create())   -- 加入消失状态到状态机
    self:setCurStateByTypeID(kType.kState.kBattleFriendRole.kSuspend)   -- 设置当前状态为挂起状态
    
    return
end

-- 退出函数
function BattleFriendRoleStateMachine:onExit()
   -- print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function BattleFriendRoleStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
        
    return
end

return BattleFriendRoleStateMachine
