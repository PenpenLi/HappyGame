--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPlayerRoleGenAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/8
-- descrip:   战斗中其他玩家角色普通攻击状态
--===================================================
local BattleOtherPlayerRoleGenAttackState = class("BattleOtherPlayerRoleGenAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPlayerRoleGenAttackState:ctor()
    self._strName = "BattleOtherPlayerRoleGenAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPlayerRole.kGenAttack  -- 状态类型ID
    
end

-- 创建函数
function BattleOtherPlayerRoleGenAttackState:create()
    local state = BattleOtherPlayerRoleGenAttackState.new()
    return state
end

-- 进入函数
function BattleOtherPlayerRoleGenAttackState:onEnter(args)
    mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:GenAttack")
    if self:getMaster() then
        --print(self:getMaster()._strCharTag.."角色普通攻击状态")
        -- 将当前技能的防御等级赋给当前的防御等级
        self:getMaster()._pCurDefLevel = self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack]._pSkillInfo.DefenseLevel
        
        -- 角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
        
        -- 开始使用技能
        self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack]:onUse()
        
        -- 检测遮挡
        self:getMaster():checkCover()

    end
    return
end

-- 退出函数
function BattleOtherPlayerRoleGenAttackState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        -- 将当前当前的防御等级为默认自身的防御等级
        self:getMaster()._pCurDefLevel = TableTempleteCareers[self:getMaster()._pRoleInfo.roleCareer].DefenseLevel
    end
    return
end

-- 更新逻辑
function BattleOtherPlayerRoleGenAttackState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattleOtherPlayerRoleGenAttackState
