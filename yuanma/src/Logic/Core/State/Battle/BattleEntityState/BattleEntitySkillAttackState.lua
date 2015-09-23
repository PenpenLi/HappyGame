--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleEntitySkillAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/4
-- descrip:   战斗中实体技能攻击状态
--===================================================
local BattleEntitySkillAttackState = class("BattleEntitySkillAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleEntitySkillAttackState:ctor()
    self._strName = "BattleEntitySkillAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleEntity.kSkillAttack  -- 状态类型ID

end

-- 创建函数
function BattleEntitySkillAttackState:create()
    local state = BattleEntitySkillAttackState.new()
    return state
end

-- 进入函数
function BattleEntitySkillAttackState:onEnter(args)
    --print(self._strName.." is onEnter!")
    
    if self:getMaster() then
        -- 开始使用技能
        -- mmo.DebugHelper:showJavaLog("mmo:BattleEntitySkillAttackState")
        self:getMaster()._pSkill:onUse(args)
    end
    return
end

-- 退出函数
function BattleEntitySkillAttackState:onExit()
    return
end

-- 更新逻辑
function BattleEntitySkillAttackState:update(dt)
    return
end

return BattleEntitySkillAttackState
