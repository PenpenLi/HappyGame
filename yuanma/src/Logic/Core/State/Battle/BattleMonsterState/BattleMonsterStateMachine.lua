--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中怪物角色状态机
--===================================================
local BattleMonsterStateMachine = class("BattleMonsterStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function BattleMonsterStateMachine:ctor()
    self._strName = "BattleMonsterStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kBattleMonster  -- 状态类机型ID
    self._fNoHurtTimeCounter = 0                        -- 未被攻击持续时间计数器
    self._nAutoHealTimeCounter = 0                      -- 自动回血时间计数器
    self._fLifeCounter = 0                              -- 生命时间计数器（每1s清空一次）
    
end

-- 创建函数
function BattleMonsterStateMachine:create(master)
    local machine = BattleMonsterStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattleMonsterStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    self:setMaster(master)
    
    self:addState(require("BattleMonsterSuspendState"):create())     -- 加入出场状态到状态机
    self:addState(require("BattleMonsterAppearState"):create())      -- 加入出场状态到状态机
    self:addState(require("BattleMonsterStandState"):create())       -- 加入站立状态到状态机
    self:addState(require("BattleMonsterRunState"):create())         -- 加入奔跑状态到状态机
    self:addState(require("BattleMonsterSkillAttackState"):create()) -- 加入技能攻击状态到状态机
    self:addState(require("BattleMonsterBebeatedState"):create())    -- 加入普通攻击状态到状态机
    self:addState(require("BattleMonsterDeadState"):create())        -- 加入死亡状态到状态机
    self:addState(require("BattleMonsterFrozenState"):create())      -- 加入冰冻状态到状态机
    self:addState(require("BattleMonsterDizzyState"):create())       -- 加入眩晕状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kBattleMonster.kSuspend)   -- 设置当前状态为挂起状态

    return
end

-- 退出函数
function BattleMonsterStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function BattleMonsterStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    
    if self:getMaster() then
        if self._pCurState._kTypeID ~= kType.kState.kBattleMonster.kDead and self:getMaster()._nCurHp > 0 then
            -- 每秒连击保户值的恢复(前提是：没有破甲buff的前提下)
            if self:getMaster():getBuffControllerMachine():isBuffExist(kType.kController.kBuff.kBattleSunderArmorBuff) == false then
                self:getMaster()._nCurComboInterupt = self:getMaster()._nCurComboInterupt + dt * self:getMaster()._pRoleInfo.ComboInteruptRecover
                if self:getMaster()._nCurComboInterupt >= self:getMaster()._pRoleInfo.ComboInterupt then
                    self:getMaster()._nCurComboInterupt = self:getMaster()._pRoleInfo.ComboInterupt
                end
            end
            self._fNoHurtTimeCounter = self._fNoHurtTimeCounter + dt
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

return BattleMonsterStateMachine
