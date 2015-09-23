--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleBuffControllerMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/12
-- descrip:   战斗Buff控制机
--===================================================
local BattleBuffControllerMachine = class("BattleBuffControllerMachine",function()
    return require("ControllerMachine"):create()
end)

-- 构造函数
function BattleBuffControllerMachine:ctor()
    self._strName = "BattleBuffControllerMachine"           -- 控制机名称
    self._kTypeID = kType.kControllerMachine.kBattleBuff    -- 控制类机型ID
    self._tBuffRefs = {}                                    -- 所有buff的引用计数

end

-- 创建函数
function BattleBuffControllerMachine:create(master)
    local machine = BattleBuffControllerMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattleBuffControllerMachine:onEnter(master)
    print(self._strName.." is onEnter!")
    self:setMaster(master)
    
    for k=1, kType.kController.kBuff.kBattleBuffTotalNum do
        table.insert(self._tBuffRefs, require("BuffRef"):create(master))
    end

    return
end

-- 退出函数
function BattleBuffControllerMachine:onExit()
    print(self._strName.." is onExit!")
    for k,v in pairs(self._tControllers) do
        if v._bEnable == true then
            v:cancel()
            v:onExit()
        end
    end
    return   
end

-- 更新逻辑
function BattleBuffControllerMachine:update(dt)
    -- buff移除逻辑
    for k,v in pairs(self._tControllers) do
        if v._bEnable == false then
            self:removeControllerByIndex(k)
            break
        end
    end 

    -- buff正常逻辑
    for k,v in pairs(self._tControllers) do
        if v._bEnable == true then
            v:update(dt)
        end
    end 
    
    return
end

-- 添加控制到控制机
function BattleBuffControllerMachine:addController(pController)
    if self:getBattleManager()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    if self._pMaster._nCurHp <= 0 then
        return
    end
    -- 如果当前存在异常免疫buff，则视所有debuff的添加为无效
    if self:isBuffExist(kType.kController.kBuff.kBattleClearAndImmuneBuff) == true then
        if pController._kTypeID == kType.kController.kBuff.kBattleFireBuff or 
           pController._kTypeID == kType.kController.kBuff.kBattleColdBuff or 
           pController._kTypeID == kType.kController.kBuff.kBattleThunderBuff or
           pController._kTypeID == kType.kController.kBuff.kBattleDizzyBuff or 
           pController._kTypeID == kType.kController.kBuff.kBattlePoisonBuff or 
           pController._kTypeID == kType.kController.kBuff.kBattleAttriDownBuff or
           pController._kTypeID == kType.kController.kBuff.kBattleSpeedDownBuff or
           pController._kTypeID == kType.kController.kBuff.kBattleSunderArmorBuff then
            return 
        end
    end
    
    -- 如果新添加的buff是debuff类型，则激活【受到异常buff的passive】
    if pController._kTypeID == kType.kController.kBuff.kBattleFireBuff or 
       pController._kTypeID == kType.kController.kBuff.kBattleColdBuff or 
       pController._kTypeID == kType.kController.kBuff.kBattleThunderBuff or
       pController._kTypeID == kType.kController.kBuff.kBattleDizzyBuff or 
       pController._kTypeID == kType.kController.kBuff.kBattlePoisonBuff or 
       pController._kTypeID == kType.kController.kBuff.kBattleAttriDownBuff or
       pController._kTypeID == kType.kController.kBuff.kBattleSpeedDownBuff or 
       pController._kTypeID == kType.kController.kBuff.kBattleSunderArmorBuff then
        if self._pMaster._kRoleType == kType.kRole.kPlayer then
            self._pMaster:addPassiveByTypeID(kType.kController.kPassive.kBattleDoWhenGetDebuffPassive)
        end
    end
    
    -- 刷新buff显示队列
    local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
    if pUILayer then
        if self._pMaster == self:getRolesManager()._pMainPlayerRole then
            pUILayer._pPlayerBuffIconsNode:addBuffByType(pController._kTypeID)
        end
        if self._pMaster == self:getRolesManager()._pPvpPlayerRole then
            pUILayer._pBossBuffIconsNode:addBuffByType(pController._kTypeID)
        elseif self._pMaster == self:getMonstersManager()._pBoss then
            pUILayer._pBossBuffIconsNode:addBuffByType(pController._kTypeID)
        end
    end
    table.insert(self._tControllers, pController)
    pController._pOwnerMachine = self
    pController:onEnter()
    return
end

-- 根据队列中的index从控制机中移除控制
function BattleBuffControllerMachine:removeControllerByIndex(idx)
    local pController = self._tControllers[idx]
    local type = pController._kTypeID
    pController:onExit()
    table.remove(self._tControllers, idx)
    
    -- 刷新buff显示队列
    if self._pMaster == self:getRolesManager()._pMainPlayerRole then
        if self:isBuffExist(type) == false then
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pPlayerBuffIconsNode:removeBuffByType(pController._kTypeID)
        end
    end
    if self._pMaster == self:getRolesManager()._pPvpPlayerRole then
        if self:isBuffExist(type) == false then
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pBossBuffIconsNode:removeBuffByType(pController._kTypeID)
        end
    elseif self._pMaster == self:getMonstersManager()._pBoss then
        if self:isBuffExist(type) == false then
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pBossBuffIconsNode:removeBuffByType(pController._kTypeID)
        end
    end

    return
end


-- 除了指定buff以外的剩余所有buff中，根据是否存在影响角色正常恢复到站立状态的buff而自动刷新人物状态
-- 如果存在，则自动回到站立状态
-- 如果不存在，则保留现状，不做任何状态的切换
function BattleBuffControllerMachine:refreshToStandExcept(buff)
    if self:getBattleManager()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end

    local needToStand = true 
    for k, v in pairs(self._tControllers) do
        if v ~= buff then
            if v._kTypeID == kType.kController.kBuff.kBattleColdBuff then
                if v._bIsFrozening == true then
                    needToStand = false
                    break
                end
            elseif v._kTypeID == kType.kController.kBuff.kBattleThunderBuff then
                needToStand = false
                break
            elseif v._kTypeID == kType.kController.kBuff.kBattleDizzyBuff then
                needToStand = false
                break
            end
        end
    end
    
    -- 切换角色到站立状态
    if needToStand == true then
        if self._pMaster._kRoleType == kType.kRole.kPlayer then
            if self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kDead and
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kBeaten then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
            end
        elseif self._pMaster._kRoleType == kType.kRole.kPet then
            if self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole)._pCurState._kTypeID ~= kType.kState.kBattlePetRole.kDead and
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole)._pCurState._kTypeID ~= kType.kState.kBattlePetRole.kBeaten then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kStand)
            end
        elseif self._pMaster._kRoleType == kType.kRole.kMonster then
            if self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID ~= kType.kState.kBattleMonster.kDead and
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID ~= kType.kState.kBattleMonster.kBeaten then
                self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
            end
        end
    end
    
    return
end

-- 切换角色状态到冻结状态
function BattleBuffControllerMachine:refreshToFrozen()
    if self:getBattleManager()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end

    if self._pMaster._kRoleType == kType.kRole.kPlayer then
        self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kFrozen)
    elseif self._pMaster._kRoleType == kType.kRole.kPet then
        self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kFrozen)
    elseif self._pMaster._kRoleType == kType.kRole.kMonster then
        self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kFrozen)
    end

    return
end

-- 切换角色状态到眩晕状态
function BattleBuffControllerMachine:refreshToDizzy()
    if self:getBattleManager()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end

    if self._pMaster._kRoleType == kType.kRole.kPlayer then
        self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kDizzy)
    elseif self._pMaster._kRoleType == kType.kRole.kPet then
        self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kDizzy)
    elseif self._pMaster._kRoleType == kType.kRole.kMonster then
        self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDizzy)
    end

    return
end

-- 强制设置buff的颜色
function BattleBuffControllerMachine:setColor(color)
    self._pMaster._pAni:stopActionByTag(nRoleLoseHpActAction)
    self._pMaster._pCurBuffColor = color
    self._pMaster._pAni:setColor(self._pMaster._pCurBuffColor)
    if self._pMaster._pWeaponL then
        self._pMaster._pWeaponL:setColor(self._pMaster._pCurBuffColor)
    end
    if self._pMaster._pWeaponR then
        self._pMaster._pWeaponR:setColor(self._pMaster._pCurBuffColor)
    end
    if self._pMaster._pBack then
        self._pMaster._pBack:setColor(self._pMaster._pCurBuffColor)
    end

    return
end

-- 设置除了指定buff以外的最近一次buff的颜色
function BattleBuffControllerMachine:setLastColorExcept(buff)

    -- 按照buff的ID号从大到小排序(ID越大，说明越是最近产生的buf)
    table.sort(self._tControllers,fromBigToSmallOnBuffIDs)
    
    local color = cc.c3b(255,255,255) 
    for k, v in pairs(self._tControllers) do
        if v ~= buff and v._bEnable == true then
            if v._pColor ~= nil then
                color = v._pColor
                break
            end
        end
    end
    
    self._pMaster._pCurBuffColor = color
    self._pMaster._pAni:setColor(self._pMaster._pCurBuffColor)
    if self._pMaster._pWeaponL then
        self._pMaster._pWeaponL:setColor(self._pMaster._pCurBuffColor)
    end
    if self._pMaster._pWeaponR then
        self._pMaster._pWeaponR:setColor(self._pMaster._pCurBuffColor)
    end
    if self._pMaster._pBack then
        self._pMaster._pBack:setColor(self._pMaster._pCurBuffColor)
    end
    
    -- 按照buff的ID号从小到大排序
    table.sort(self._tControllers,fromSmallToBigOnBuffIDs)
    
    return
end

-- 取消所有debuffs（包括：属性状态—灼烧   属性状态—寒冷  属性状态—雷击  晕眩  中毒  属性弱化 减速）
function BattleBuffControllerMachine:cancelAllDebuffs()
    for k, v in pairs(self._tControllers) do
        if v._bEnable == true then
            if v._kTypeID == kType.kController.kBuff.kBattleFireBuff or 
               v._kTypeID == kType.kController.kBuff.kBattleColdBuff or
               v._kTypeID == kType.kController.kBuff.kBattleThunderBuff or
               v._kTypeID == kType.kController.kBuff.kBattleDizzyBuff or
               v._kTypeID == kType.kController.kBuff.kBattlePoisonBuff or
               v._kTypeID == kType.kController.kBuff.kBattleAttriDownBuff or
               v._kTypeID == kType.kController.kBuff.kBattleSpeedDownBuff or
               v._kTypeID == kType.kController.kBuff.kBattleSunderArmorBuffthen then
                  v:cancel()
            end
            
        end
        
    end
    
    return
end

-- 取消所有buffs
function BattleBuffControllerMachine:cancelAllBuffs()
    for k, v in pairs(self._tControllers) do
        if v._bEnable == true then
            v:cancel()
        end
    end
    return
end

-- 判断是否有指定有效buff的存在
function BattleBuffControllerMachine:isBuffExist(type)
    for k, v in pairs(self._tControllers) do
        if v._bEnable == true then
            if v._kTypeID == type then
                return true
            end
        end
    end
    return false
end

-- 收集指定有效buff集合
function BattleBuffControllerMachine:collectBuffsByType(type)
    local buffs = {}
    for k, v in pairs(self._tControllers) do
        if v._bEnable == true then
            if v._kTypeID == type then
                table.insert(buffs,v)
            end
        end
    end
    return buffs
end

-- 立刻移除所有buffs
function BattleBuffControllerMachine:removeAllBuffsRightNow()
    for k, v in pairs(self._tControllers) do
        v:onExit()
    end
    self._tControllers = {}
    return
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function BattleBuffControllerMachine:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function BattleBuffControllerMachine:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function BattleBuffControllerMachine:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function BattleBuffControllerMachine:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function BattleBuffControllerMachine:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function BattleBuffControllerMachine:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function BattleBuffControllerMachine:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function BattleBuffControllerMachine:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function BattleBuffControllerMachine:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取战斗AI管理器
function BattleBuffControllerMachine:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

--------------------------------------------------------------------------------------------------------------

return BattleBuffControllerMachine
