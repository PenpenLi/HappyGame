--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSkillProcessState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/9
-- descrip:   战斗中技能执行状态
--===================================================
local BattleSkillProcessState = class("BattleSkillProcessState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleSkillProcessState:ctor()
    self._strName = "BattleSkillProcessState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleSkill.kProcess  -- 状态类型ID
end

-- 创建函数
function BattleSkillProcessState:create()
    local state = BattleSkillProcessState.new()
    return state
end

-- 进入函数
function BattleSkillProcessState:onEnter(args)
    --print(self._strName.." is onEnter!")
    if self:getMaster() then
        self:getMaster():onEnterProcessDo(self)
    end
    return
end

-- 退出函数
function BattleSkillProcessState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        self:getMaster():onExitProcessDo(self)
    end
    return
end

-- 更新逻辑
function BattleSkillProcessState:update(dt)
    if self:getMaster() then
        self:getMaster():onUpdateProcessDo(dt,self)
    end
    return
end

return BattleSkillProcessState
