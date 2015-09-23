--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleSkillAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/24
-- descrip:   战斗中玩家角色技能攻击状态
--===================================================
local BattlePlayerRoleSkillAttackState = class("BattlePlayerRoleSkillAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleSkillAttackState:ctor()
    self._strName = "BattlePlayerRoleSkillAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kSkillAttack  -- 状态类型ID
    self._nSkillWayIndex = kType.kSkill.kWayIndex.kNone            -- 角色技能序列

end

-- 创建函数
function BattlePlayerRoleSkillAttackState:create()
    local state = BattlePlayerRoleSkillAttackState.new()
    return state
end

-- 进入函数
function BattlePlayerRoleSkillAttackState:onEnter(args)
    if self:getMaster() then
        mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:SkillAttack "..self:getMaster()._tSkills[args]._strName)
        --print(self:getMaster()._strCharTag.."角色技能攻击状态")
        -- 角色技能序列
        self._nSkillWayIndex = args
        
        -- 角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[self._nSkillWayIndex])
        
        -- 复位有可能存在的普通攻击动作
        self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack]._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        
        -- 开始使用技能
        self:getMaster()._tSkills[self._nSkillWayIndex]:onUse()
        
        -- 将当前技能的防御等级赋给当前的防御等级
        self:getMaster()._pCurDefLevel = self:getMaster()._tSkills[self._nSkillWayIndex]._pSkillInfo.DefenseLevel
    end
    return
end

-- 退出函数
function BattlePlayerRoleSkillAttackState:onExit()
    if self:getMaster() then
        -- 将当前当前的防御等级为默认自身的防御等级
        self:getMaster()._pCurDefLevel = TableTempleteCareers[self:getMaster()._pRoleInfo.roleCareer].DefenseLevel
        -- 如果【等待人物技能动作结束时的引用计数自减操作的次数】不为0，
        -- 则说明存在因强制stopAllActions或人物吟唱时间早于人物动作时间而导致的引用计数自检操作没有被执行而无法操作摇杆的问题，所以这里要强制执行制定次数的自减操作
        for i = 1, self:getMaster()._refStick._nWaitingSkillActOverToSubCount do
            self:getMaster()._refStick:sub()
        end
	self._nSkillWayIndex = kType.kSkill.kWayIndex.kNone
    end
    return
end

-- 更新逻辑
function BattlePlayerRoleSkillAttackState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 检测和触发器的实时碰撞
        if self:getMaster()._strCharTag == "main" then
            self:getMaster():checkCollisionOnTriggerWithRuntime(true)
        end
        -- 检测玩家是否已经离开了入场传送门
        self:getMaster():checkLeavingFromEnterDoor()
    end
    return
end

return BattlePlayerRoleSkillAttackState
