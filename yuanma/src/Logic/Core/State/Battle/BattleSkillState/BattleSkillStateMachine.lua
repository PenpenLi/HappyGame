--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSkillStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/9
-- descrip:   战斗中技能状态机
--===================================================
local BattleSkillStateMachine = class("BattleSkillStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function BattleSkillStateMachine:ctor()
    self._strName = "BattleSkillStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kBattleSkill  -- 状态类机型ID
end

-- 创建函数
function BattleSkillStateMachine:create(master)
    local machine = BattleSkillStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattleSkillStateMachine:onEnter(master)
   -- print(self._strName.." is onEnter!")
    self:setMaster(master)
    self:addState(require("BattleSkillIdleState"):create())      -- 加入空闲状态到状态机
    self:addState(require("BattleSkillChantState"):create())     -- 加入吟唱状态到状态机
    self:addState(require("BattleSkillProcessState"):create())   -- 加入执行状态到状态机
    self:addState(require("BattleSkillReleaseState"):create())   -- 加入释放状态到状态机
    self:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)    -- 设置当前状态为空闲
    return
end

-- 退出函数
function BattleSkillStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function BattleSkillStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

return BattleSkillStateMachine
