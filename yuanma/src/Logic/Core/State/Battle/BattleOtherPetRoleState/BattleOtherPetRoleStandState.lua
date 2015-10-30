--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPetRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/10
-- descrip:   战斗中其他玩家宠物角色站立状态
--===================================================
local BattleOtherPetRoleStandState = class("BattleOtherPetRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPetRoleStandState:ctor()
    self._strName = "BattleOtherPetRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPetRole.kStand  -- 状态类型ID
    self._fTimeCounter = 0                              -- 时间累加
    self._fWaitCounter = 0                              -- 站立后的延时计数
    
end

-- 创建函数
function BattleOtherPetRoleStandState:create()
    local state = BattleOtherPetRoleStandState.new()
    return state
end

-- 进入函数
function BattleOtherPetRoleStandState:onEnter(args)
    --cclog("宠物站立")
    --print(self:getMaster()._strCharTag.."宠物角色站立状态")
    -- mmo.DebugHelper:showJavaLog("--STATE--PET--:Stand")
    if self:getMaster() then
        self._fTimeCounter = 0
        self._fWaitCounter = 0
        -- 刷新动作
        self:getMaster():playStandAction()
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

-- 退出函数
function BattleOtherPetRoleStandState:onExit()
    --print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function BattleOtherPetRoleStandState:update(dt)
    if self:getMaster() then
        -- 如果正在显示对话或地图正在移动，则直接返回
        if self:getTalksManager():isShowingTalks() == true or self:getMapManager():isCameraMoving() == true then
            return
        end
	    
        self._fWaitCounter = self._fWaitCounter + dt
        if self._fWaitCounter < fRoleStandWaitDelay then
            return
        end
        -- 自动战斗相关逻辑
        self:procAutoBattle(dt)
        
        -- 检查位置（必要时寻路）
        self:procCheckPos(dt)
    end
    
    return
end

-- 检查位置相关逻辑
function BattleOtherPetRoleStandState:procCheckPos(dt)
    -- 时间计数
    self._fTimeCounter = self._fTimeCounter + dt
    if self._fTimeCounter >= 0.5 then   -- 每隔0.5s检测一次
        local target = self:getMaster()._pMaster  -- 宠物的主人
        ---------------------------------------------- 开始寻路 ----------------------------------------------------------
        local posIndex = self:getMaster():getPositionIndex()
        local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
        if math.abs(posIndex.x - targetPosIndex.x) > 4 or math.abs(posIndex.y - targetPosIndex.y) > 4 then      -- 横竖超过4个格子时需要寻路跟随
            self._fTimeCounter = 0
            local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kRun, false, {moveDirections = path, bExictlyToTarget = false})  -- 不用精确走到目标位置（用于跟随主人）
        end
        
    end

end

-- 自动战斗相关逻辑
function BattleOtherPetRoleStandState:procAutoBattle(dt)
    -- 先检测是否需要进行自动攻击  (先判定是否所有技能目前都处于idle状态才可以进行)
    for k,v in pairs(self:getMaster()._tSkills) do
        if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
            return  -- 存在正在使用的技能，直接返回，不可以攻击，也不可以寻路
        end
    end

    local damageSkillCDOverNum = 0      -- 攻击型技能CD结束的个数
    
    if self:getMaster()._pMaster and self:getMaster()._pMaster._nCurHp > 0 then
        if self:getMaster()._pMaster._nCurHp / self:getMaster()._pMaster._nHpMax < TableConstants.PetSupportCondition.Value then -- 可以给主角加血
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
               if vSkill._pSkillInfo.PetSkillType == 4 then -- 回复性技能类型
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该回复技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, false)
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kSkillAttack, false, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
               end
            end
        end
    end

    -- 玩家宠物角色判定当前是否可以进入战斗模式
    local canEnterBattle = self:getAIManager():isPetCanEnterBattleModeForDamage(self:getMaster())
    if canEnterBattle == true then  -- 可以进入战斗模式
        for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
            if vSkill._pSkillInfo.PetSkillType == 3 then -- buff型技能
                if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                    local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, false)
                    if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kSkillAttack, false, {["skillIndex"] = kSkill})
                        return 
                    end
                end
            end
        end
        for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
            if vSkill._pSkillInfo.PetSkillType == 2 then -- 普通型技能
                if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                    damageSkillCDOverNum = damageSkillCDOverNum + 1
                    local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, true)     -- 找离宠物主人最近的，同时在宠物的警戒范围内
                    if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kSkillAttack, false, {["skillIndex"] = kSkill})
                        return 
                    end
                end
            end
        end
        for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
            if vSkill._pSkillInfo.PetSkillType == 1 then -- 普通型攻击
                if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                    damageSkillCDOverNum = damageSkillCDOverNum + 1
                    local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, true)    -- 找离宠物主人最近的，同时在宠物的警戒范围内
                    if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kSkillAttack, false, {["skillIndex"] = kSkill})
                        return 
                    end
                end
            end
        end
        
    end
    
    -- 伤害型的技能已经CD结束，只是目标当前没有在警戒范围内，这时可以奔向目标
    if damageSkillCDOverNum ~= 0 then
        local targetInView = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self:getMaster(), self:getMaster()._pRoleInfo.ViewRange, true)    -- 在宠物的视野范围内查找离主人最近的目标
        if #targetInView ~= 0 then  -- 视野范围内有目标，则开始寻路
            local target = targetInView[1].enemy
            local posIndex = self:getMaster():getPositionIndex()
            local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
            if posIndex.x ~= targetPosIndex.x or posIndex.y ~= targetPosIndex.y then
                local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kRun, false, {moveDirections = path, bExictlyToTarget = true})  -- 追怪
            end
            return 
        end
    else  -- 伤害型的技能都没有CD结束，则等待跟随玩家
        return
    end
    return
    
end

return BattleOtherPetRoleStandState
