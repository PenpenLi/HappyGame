--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSkillIdleState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/9
-- descrip:   战斗中技能空闲状态
--===================================================
local BattleSkillIdleState = class("BattleSkillIdleState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleSkillIdleState:ctor()
    self._strName = "BattleSkillIdleState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleSkill.kIdle  -- 状态类型ID
end

-- 创建函数
function BattleSkillIdleState:create()
    local state = BattleSkillIdleState.new()
    return state
end

-- 进入函数
function BattleSkillIdleState:onEnter(args)
    --print(self._strName.." is onEnter!")
    if self:getMaster() then
        self:getMaster():stopAllAnimationActions()  -- 停止skill的所有action
        self:getMaster():clearCurAttackFrameEventInfo()
        self:getMaster():reset()
        self:getMaster()._strFrameEventName = ""
        self:getMaster()._nSettledZorder = nil
        self:getMaster():onEnterIdleDo(self)
    end
    return
end

-- 退出函数
function BattleSkillIdleState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        self:getMaster():onExitIdleDo(self)
    end
    return
end

-- 更新逻辑
function BattleSkillIdleState:update(dt)
    if self:getMaster() then
        self:getMaster():onUpdateIdleDo(dt,self)
    end
    return
end

return BattleSkillIdleState
