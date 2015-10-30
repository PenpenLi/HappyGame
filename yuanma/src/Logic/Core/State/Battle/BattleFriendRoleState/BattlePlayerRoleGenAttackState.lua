--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleGenAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中玩家角色普通攻击状态
--===================================================
local BattlePlayerRoleGenAttackState = class("BattlePlayerRoleGenAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleGenAttackState:ctor()
    self._strName = "BattlePlayerRoleGenAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kGenAttack  -- 状态类型ID
    
end

-- 创建函数
function BattlePlayerRoleGenAttackState:create()
    local state = BattlePlayerRoleGenAttackState.new()
    return state
end

-- 进入函数
function BattlePlayerRoleGenAttackState:onEnter(args)
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
        
        -- 检测和触发器的停留碰撞
        if self:getMaster()._strCharTag == "main" then
            self:getMaster():checkCollisionOnTriggerWithRuntime(false)
        end
        
        if NewbieManager:getInstance()._bSkipGuide == false and NewbieManager:getInstance()._nCurID == "Guide_1_2" then
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._bStickDisabled = false        -- 恢复摇杆禁用
            NewbieManager:getInstance():showOutAndRemoveWithRunTime()
        end
    end
    return
end

-- 退出函数
function BattlePlayerRoleGenAttackState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        -- 将当前当前的防御等级为默认自身的防御等级
        self:getMaster()._pCurDefLevel = TableTempleteCareers[self:getMaster()._pRoleInfo.roleCareer].DefenseLevel
    end
    return
end

-- 更新逻辑
function BattlePlayerRoleGenAttackState:update(dt)
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

return BattlePlayerRoleGenAttackState
