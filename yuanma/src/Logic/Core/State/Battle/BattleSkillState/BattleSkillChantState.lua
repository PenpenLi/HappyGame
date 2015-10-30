--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSkillChantState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/9
-- descrip:   战斗中技能吟唱状态
--===================================================
local BattleSkillChantState = class("BattleSkillChantState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleSkillChantState:ctor()
    self._strName = "BattleSkillChantState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleSkill.kChant  -- 状态类型ID
end

-- 创建函数
function BattleSkillChantState:create()
    local state = BattleSkillChantState.new()
    return state
end

-- 进入函数
function BattleSkillChantState:onEnter(args)
    --print(self._strName.." is onEnter!")

    -- 开始吟唱，技能开始
    if self:getMaster() then        
        self:getMaster():onEnterChantDo(self)
    end
    return
end

-- 退出函数
function BattleSkillChantState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        self:getMaster():onExitChantDo(self)
    end
    return
end

-- 更新逻辑
function BattleSkillChantState:update(dt)
    if self:getMaster() then
        self:getMaster():onUpdateChantDo(dt,self)
    end
    return
end

return BattleSkillChantState
