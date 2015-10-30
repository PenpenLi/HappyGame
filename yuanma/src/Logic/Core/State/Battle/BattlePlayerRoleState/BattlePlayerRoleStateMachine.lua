--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中玩家角色状态机
--===================================================
local BattlePlayerRoleStateMachine = class("BattlePlayerRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function BattlePlayerRoleStateMachine:ctor()
    self._strName = "BattlePlayerRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kBattlePlayerRole  -- 状态类机型ID
    self._fNoHurtTimeCounter = 0                           -- 未被攻击持续时间的计数器
    self._fIgnorHurtTimeCounter = -1                       -- 忽略攻击持续时间的计数器（默认为-1不进行计数，为0时开始计数）
    self._nAutoHealTimeCounter = 0                         -- 自动回血时间计数器
    self._fLifeCounter = 0                                 -- 生命时间计数器（每1s清空一次）
    self._nPetCooperateCDCounter = 0                       -- 宠物共鸣的CD计数器
    
end

-- 创建函数
function BattlePlayerRoleStateMachine:create(master)
    local machine = BattlePlayerRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattlePlayerRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    self:setMaster(master)
    
    self:addState(require("BattlePlayerRoleAppearState"):create())      -- 加入出场状态到状态机
    self:addState(require("BattlePlayerRoleStandState"):create())       -- 加入站立状态到状态机
    self:addState(require("BattlePlayerRoleRunState"):create())         -- 加入奔跑状态到状态机
    self:addState(require("BattlePlayerRoleGenAttackState"):create())   -- 加入普通攻击状态到状态机
    self:addState(require("BattlePlayerRoleBebeatedState"):create())    -- 加入受击状态到状态机
    self:addState(require("BattlePlayerRoleDeadState"):create())        -- 加入死亡状态到状态机
    self:addState(require("BattlePlayerRoleAngerAttackState"):create()) -- 加入怒气技能状态到状态机
    self:addState(require("BattlePlayerRoleDizzyState"):create())       -- 加入眩晕状态到状态机
    self:addState(require("BattlePlayerRoleFrozenState"):create())      -- 加入冻结状态到状态机
    self:addState(require("BattlePlayerRoleSkillAttackState"):create()) -- 加入技能状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kBattlePlayerRole.kAppear, true)  -- 设置当前状态为出场状态
    
    return
end

-- 退出函数
function BattlePlayerRoleStateMachine:onExit()
   -- print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function BattlePlayerRoleStateMachine:update(dt)    
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end

    if self:getMaster() then
        if self._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kDead and self:getMaster()._nCurHp > 0 then

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

            -- 考虑宠物共鸣技能CD
            if self:getMaster()._strCharTag == "pvp" then
                if self:getMaster()._pCurPetRole and self:getMaster()._pCurPetRole._pCooperateInfo and self:getMaster()._pCurPetRole._pCooperateInfo.CD and self:getMaster()._pCurPetRole._nCurHp > 0 then  -- 存在共鸣
                    self._nPetCooperateCDCounter = self._nPetCooperateCDCounter + dt
                end
            end
            
        end
    end

    return
end

-- 使用共鸣技能
function BattlePlayerRoleStateMachine:usePetCooperateSkill()
    if self:getMaster()._strCharTag == "pvp" then
        if self:getMaster()._pCurPetRole and self:getMaster()._pCurPetRole._pCooperateInfo and self:getMaster()._pCurPetRole._pCooperateInfo.CD and self:getMaster()._pCurPetRole._nCurHp > 0 then  -- 存在共鸣
            if self._nPetCooperateCDCounter >= self:getMaster()._pCurPetRole._pCooperateInfo.CD then
                self._nPetCooperateCDCounter = 0
                AIManager:getInstance():usePetCooperateSkillByCampType(kType.kCampType.kPvp)
                cclog("PVP释放宠物共鸣")
            end
        end
    end
end

return BattlePlayerRoleStateMachine
