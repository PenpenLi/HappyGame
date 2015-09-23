--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePassiveControllerMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/25
-- descrip:   战斗被动技能控制机
--===================================================
local BattlePassiveControllerMachine = class("BattlePassiveControllerMachine",function()
    return require("ControllerMachine"):create()
end)

-- 构造函数
function BattlePassiveControllerMachine:ctor()
    self._strName = "BattlePassiveControllerMachine"           -- 控制机名称
    self._kTypeID = kType.kControllerMachine.kBattlePassive    -- 控制类机型ID
    self._tPassiveRefs = {}                                    -- 所有passive的引用计数
    self._fCurSafeTimeCount = 0                                -- 持续安全时间（未被打持续时间）
    
end

-- 创建函数
function BattlePassiveControllerMachine:create(master)
    local machine = BattlePassiveControllerMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattlePassiveControllerMachine:onEnter(master)
    print(self._strName.." is onEnter!")
    self:setMaster(master)

    for k=1, kType.kController.kPassive.kBattlePassiveTotalNum do
        table.insert(self._tPassiveRefs, require("PassiveRef"):create(master))
    end
    
    return
end

-- 退出函数
function BattlePassiveControllerMachine:onExit()
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
function BattlePassiveControllerMachine:update(dt)
    for k,v in pairs(self._tControllers) do
        if v._bEnable == true then
            v:update(dt)
        else
            self:removeControllerByIndex(k)
            break
        end
    end 
    
    -- 实时监控，当前角色血量已经低于限定血量，则需要触发【血量低于多少时passive】（对应引用计数为0）
    if self._pMaster._tPassiveSkillInfos[kType.kController.kPassive.kBattleDoWhenHpBelowPassive] then
        if self._tPassiveRefs[kType.kController.kPassive.kBattleDoWhenHpBelowPassive]:getRefValue() == 0 then
            if self._pMaster._nCurHp / self._pMaster._nHpMax <= self._pMaster._tPassiveSkillInfos[kType.kController.kPassive.kBattleDoWhenHpBelowPassive].Param1 then
                self._pMaster:addPassiveByTypeID(kType.kController.kPassive.kBattleDoWhenHpBelowPassive)
            end
        end
    end
    
    -- 实时监控，当前角色怒气满时，则需要触发【怒气技能准备就绪时passive】（对应引用计数为0）
    if self._pMaster._tPassiveSkillInfos[kType.kController.kPassive.kBattleDoWhenAngerIsReadyPassive] then
        if self._tPassiveRefs[kType.kController.kPassive.kBattleDoWhenAngerIsReadyPassive]:getRefValue() == 0 then
            if self._pMaster._nCurAnger >= self._pMaster._nAngerMax then
                self._pMaster:addPassiveByTypeID(kType.kController.kPassive.kBattleDoWhenAngerIsReadyPassive)
            end
        end
    end

    
    -- 实时监控，当前角色未被打持续一定时间后要触发【未被攻击x秒钟时passive】（对应引用计数为0）
    if self._pMaster._tPassiveSkillInfos[kType.kController.kPassive.kBattleDoWhenBeSafePassive] then
        self._fCurSafeTimeCount = self._fCurSafeTimeCount + dt
        if self._tPassiveRefs[kType.kController.kPassive.kBattleDoWhenBeSafePassive]:getRefValue() == 0 then
            if self._fCurSafeTimeCount >= self._pMaster._tPassiveSkillInfos[kType.kController.kPassive.kBattleDoWhenBeSafePassive].Param1 then
                self._pMaster:addPassiveByTypeID(kType.kController.kPassive.kBattleDoWhenBeSafePassive)
                self._fCurSafeTimeCount = 0 -- 计时器清零
            end
        end
    end
    
    return
end

-- 添加控制到控制机
function BattlePassiveControllerMachine:addController(pController)
    table.insert(self._tControllers, pController)
    pController._pOwnerMachine = self
    pController:onEnter()
    return
end

-- 根据队列中的index从控制机中移除控制
function BattlePassiveControllerMachine:removeControllerByIndex(idx)
    local pController = self._tControllers[idx]
    local type = pController._kTypeID
    pController:onExit()
    table.remove(self._tControllers, idx)
    
    return
end

-- 取消所有buffs
function BattlePassiveControllerMachine:cancelAllPassives()
    for k, v in pairs(self._tControllers) do
        if v._bEnable == true then
            v:cancel()
        end
    end
    return
end

-- 判断是否有指定有效Passive的存在
function BattlePassiveControllerMachine:isPassiveExist(type)
    for k, v in pairs(self._tControllers) do
        if v._bEnable == true then
            if v._kTypeID == type then
                return true
            end
        end
    end
    return false
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function BattlePassiveControllerMachine:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function BattlePassiveControllerMachine:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function BattlePassiveControllerMachine:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function BattlePassiveControllerMachine:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function BattlePassiveControllerMachine:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function BattlePassiveControllerMachine:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function BattlePassiveControllerMachine:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function BattlePassiveControllerMachine:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function BattlePassiveControllerMachine:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取战斗AI管理器
function BattlePassiveControllerMachine:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

--------------------------------------------------------------------------------------------------------------

return BattlePassiveControllerMachine
