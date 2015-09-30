--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePetRoleSkillAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   战斗中玩家宠物角色技能攻击状态
--===================================================
local BattlePetRoleSkillAttackState = class("BattlePetRoleSkillAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePetRoleSkillAttackState:ctor()
    self._strName = "BattlePetRoleSkillAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePetRole.kSkillAttack  -- 状态类型ID
    self._nSkillWayIndex = kType.kSkill.kWayIndex.kNone       -- 宠物角色技能序列

end

-- 创建函数
function BattlePetRoleSkillAttackState:create()
    local state = BattlePetRoleSkillAttackState.new()
    return state
end

-- 进入函数
function BattlePetRoleSkillAttackState:onEnter(args)
    --cclog("宠物攻击")
    --print(self:getMaster()._strCharTag.."宠物角色技能攻击状态")
    -- mmo.DebugHelper:showJavaLog("--STATE--PET--:SkillAttack "..self:getMaster()._tSkills[args.skillIndex]._strName)
    if self:getMaster() then
        -- 角色技能序列
        self._nSkillWayIndex = args.skillIndex
        
        -- 角色搜索警戒范围内的目标，并根据目标的方位自动转向
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[self._nSkillWayIndex])
    
        -- 开始使用技能
        self:getMaster()._tSkills[self._nSkillWayIndex]:onUse()
        
        -- 将当前技能的防御等级赋给当前的防御等级
        self:getMaster()._pCurDefLevel = self:getMaster()._tSkills[self._nSkillWayIndex]._pSkillInfo.DefenseLevel
    end
    return
end

-- 退出函数
function BattlePetRoleSkillAttackState:onExit()
    self._nSkillWayIndex = kType.kSkill.kWayIndex.kNone
    if self:getMaster() then
        -- 将当前当前的防御等级为默认自身的防御等级
        self:getMaster()._pCurDefLevel = self:getMaster()._pTempleteInfo.DefenseLevel
    end
    return
end

-- 更新逻辑
function BattlePetRoleSkillAttackState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattlePetRoleSkillAttackState
