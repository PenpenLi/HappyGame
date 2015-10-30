--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPlayerRoleAngerAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/8
-- descrip:   战斗中其他玩家角色怒气技能攻击状态
--===================================================
local BattleOtherPlayerRoleAngerAttackState = class("BattleOtherPlayerRoleAngerAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPlayerRoleAngerAttackState:ctor()
    self._strName = "BattleOtherPlayerRoleAngerAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPlayerRole.kAngerAttack  -- 状态类型ID

end

-- 创建函数
function BattleOtherPlayerRoleAngerAttackState:create()
    local state = BattleOtherPlayerRoleAngerAttackState.new()
    return state
end

-- 进入函数
function BattleOtherPlayerRoleAngerAttackState:onEnter(args)
    mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:AngerAttack")
    if self:getMaster() then
        --print(self:getMaster()._strCharTag.."角色怒气技能攻击状态")
        -- 清空所有debuff状态
        self:getMaster():getBuffControllerMachine():cancelAllDebuffs()
        
        -- 怒气清零
        self:getMaster():clearAnger()
        
        -- 角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack])
        
        -- 复位有可能存在的所有技能
        for k,v in pairs(self:getMaster()._tSkills) do
            v:stopAllActionNodes()
            v._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
        
        -- 速度恢复
        self:getMaster():resetSpeed()
        
        -- 开始使用技能
        self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack]:onUse()
        
        -- 将当前技能的防御等级赋给当前的防御等级
        self:getMaster()._pCurDefLevel = self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack]._pSkillInfo.DefenseLevel
    end
    return
end

-- 退出函数
function BattleOtherPlayerRoleAngerAttackState:onExit()
    if self:getMaster() then
        -- 将当前当前的防御等级为默认自身的防御等级
        self:getMaster()._pCurDefLevel = TableTempleteCareers[self:getMaster()._pRoleInfo.roleCareer].DefenseLevel
        -- 如果【等待人物技能动作结束时的引用计数自减操作的次数】不为0，
        -- 则说明存在因强制stopAllActions或人物吟唱时间早于人物动作时间而导致的引用计数自检操作没有被执行而无法操作摇杆的问题，所以这里要强制执行制定次数的自减操作
        for i = 1, self:getMaster()._refStick._nWaitingSkillActOverToSubCount do
            self:getMaster()._refStick:sub()
        end
    end
    return
end

-- 更新逻辑
function BattleOtherPlayerRoleAngerAttackState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattleOtherPlayerRoleAngerAttackState
