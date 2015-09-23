--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePetRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   战斗中玩家宠物角色状态机
--===================================================
local BattlePetRoleStateMachine = class("BattlePetRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function BattlePetRoleStateMachine:ctor()
    self._strName = "BattlePetRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kBattlePetRole  -- 状态类机型ID
    self._fNoHurtTimeCounter = 0                        -- 未被攻击持续时间的计数器
    self._fIgnorHurtTimeCounter = -1                    -- 忽略攻击持续时间的计数器（默认为-1不进行计数，为0时开始计数）
    self._nAutoHealTimeCounter = 0                      -- 自动回血时间计数器
    self._fLifeCounter = 0                              -- 生命时间计数器（每1s清空一次）
    
end

-- 创建函数
function BattlePetRoleStateMachine:create(master)
    local machine = BattlePetRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattlePetRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    self:setMaster(master)
    
    self:addState(require("BattlePetRoleAppearState"):create())      -- 加入出场状态到状态机
    self:addState(require("BattlePetRoleStandState"):create())       -- 加入站立状态到状态机
    self:addState(require("BattlePetRoleRunState"):create())         -- 加入奔跑状态到状态机
    self:addState(require("BattlePetRoleSkillAttackState"):create()) -- 加入技能攻击状态到状态机
    self:addState(require("BattlePetRoleBebeatedState"):create())    -- 加入受击状态到状态机
    self:addState(require("BattlePetRoleDeadState"):create())        -- 加入死亡状态到状态机
    self:addState(require("BattlePetRoleDizzyState"):create())       -- 加入眩晕状态到状态机
    self:addState(require("BattlePetRoleFrozenState"):create())      -- 加入冻结状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kBattlePetRole.kAppear)  -- 设置当前状态为出场状态
    
    return
end

-- 退出函数
function BattlePetRoleStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function BattlePetRoleStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end

    if self:getMaster() then
        if self._pCurState._kTypeID ~= kType.kState.kBattlePetRole.kDead and self:getMaster()._nCurHp > 0 then
            -- 角色本身未被攻击时间的累积计算，一旦被打，则在相应状态中需要清空_fNoHurtTimeCounter，一旦累积时间到了可以恢复保户值的时间，则立即恢复连击保户值
            self._fNoHurtTimeCounter = self._fNoHurtTimeCounter + dt
            if self._fNoHurtTimeCounter >= self:getMaster()._pRoleInfo.ComboInteruptRecover then  -- 未被攻击时间到，立即恢复连击保户值
                self:getMaster()._nCurComboInterupt = self:getMaster()._pRoleInfo.ComboInterupt
            end
            -- 角色本身未被攻击时间一旦超过了LifeRecoverTime秒，每秒触发一次，恢复”每秒恢复的血量”的值
            if self._fNoHurtTimeCounter >= TableConstants.LifeRecoverTime.Value then  -- 一旦超过了LifeRecoverTime秒，每秒触发一次，恢复”每秒恢复的血量”的值
                self._nAutoHealTimeCounter = self._nAutoHealTimeCounter + dt
                if self._nAutoHealTimeCounter >= 1.0 then
                    self._nAutoHealTimeCounter = 0
                    local healHpValue = ((self:getMaster():getAttriValueByType(kAttribute.kLifePerSecond)*TableConstants.LifeperSecondMax.Value)/(self:getMaster():getAttriValueByType(kAttribute.kLifePerSecond)+TableConstants.LifeperSecondReduce.Value))*self:getMaster()._nHpMax
                    self:getMaster():addHp(healHpValue)
                end
            else
                self._nAutoHealTimeCounter = 0
            end
    
            -- 角色持续一段时间忽略攻击
            if self._fIgnorHurtTimeCounter == 0 then        -- 刚刚被设置为0，开始忽略所有攻击
                self:getMaster()._pRefRoleIgnoreHurt:add()
                self._fIgnorHurtTimeCounter = self._fIgnorHurtTimeCounter + dt
            elseif self._fIgnorHurtTimeCounter > 0 then
                self._fIgnorHurtTimeCounter = self._fIgnorHurtTimeCounter + dt
                if self._fIgnorHurtTimeCounter >= self:getMaster()._pTempleteInfo.IgnorHurtDelayTimeForBeaten then  -- 忽略攻击的时间已到， 忽略攻击失效
                    self._fIgnorHurtTimeCounter = -1
                    self:getMaster()._pRefRoleIgnoreHurt:sub()
                end
            end
    
            -- 实时监控角色属性积蓄值是否达到上限
            local pMaster = self:getMaster()
            if pMaster._nCurFireSaving >= pMaster._nFireSavingMax then
                pMaster._nCurFireSaving = 0
                pMaster._nFireSavingMax = pMaster._nFireSavingMax* pMaster._fSavingPatience
                pMaster:addBuffByID(1)  -- 加入灼烧状态到控制机
            end
            if pMaster._nCurIceSaving >= pMaster._nIceSavingMax then
                pMaster._nCurIceSaving = 0
                pMaster._nIceSavingMax = pMaster._nIceSavingMax* pMaster._fSavingPatience
                pMaster:addBuffByID(2) -- 加入寒冷状态到控制机
            end
            if pMaster._nCurThunderSaving >= pMaster._nThunderSavingMax then
                pMaster._nCurThunderSaving = 0
                pMaster._nThunderSavingMax = pMaster._nThunderSavingMax* pMaster._fSavingPatience
                pMaster:addBuffByID(3) -- 加入雷状态到控制机
            end
            
            -- 角色属性积蓄值每秒钟的自动恢复逻辑
            self._fLifeCounter = self._fLifeCounter + dt
            if self._fLifeCounter >= 1.0 then
    
                self._fLifeCounter = 0
    
                pMaster._nCurFireSaving = pMaster._nCurFireSaving - pMaster._nFireSavingRecover
                if pMaster._nCurFireSaving <= 0 then
                    pMaster._nCurFireSaving = 0
                end
    
                pMaster._nCurIceSaving = pMaster._nCurIceSaving - pMaster._nIceSavingRecover
                if pMaster._nCurIceSaving <= 0 then
                    pMaster._nCurIceSaving = 0
                end
    
                pMaster._nCurThunderSaving = pMaster._nCurThunderSaving - pMaster._nThunderSavingRecover
                if pMaster._nCurThunderSaving <= 0 then
                    pMaster._nCurThunderSaving = 0
                end
    
            end
            
         end
    end
    
    return
end

return BattlePetRoleStateMachine
