--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中玩家角色站立状态
--===================================================
local BattlePlayerRoleStandState = class("BattlePlayerRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleStandState:ctor()
    self._strName = "BattlePlayerRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kStand  -- 状态类型ID
    self._fWaitCounter = 0                                 -- 站立后的延时计数
    
end

-- 创建函数
function BattlePlayerRoleStandState:create()
    local state = BattlePlayerRoleStandState.new()
    return state
end

-- 进入函数
function BattlePlayerRoleStandState:onEnter(args)
    if self:getMaster() then
        mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:Stand")
        self._fWaitCounter = 0    
        -- 刷新动作
        self:getMaster():playStandAction()
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 检测和触发器的停留碰撞
        if self:getMaster()._strCharTag == "main" then
            self:getMaster():checkCollisionOnTriggerWithRuntime(false)
        end
    end
    
    return
end

-- 退出函数
function BattlePlayerRoleStandState:onExit()
    --print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function BattlePlayerRoleStandState:update(dt)
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
    end
    return
end

-- 自动战斗相关逻辑
function BattlePlayerRoleStandState:procAutoBattle(dt)
    -- 自动战斗情况下，搜索最近目标后，自动切换到跑步状态
    if self:getMaster()._strCharTag == "main" then
        if self:getBattleManager()._bIsAutoBattle == true and cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getIsWorking() == false and
           self:getRolesManager()._pMainPlayerRole._refStick:getRefValue() == 0 then

            -- 先检测是否需要进行自动攻击  (先判定是否所有技能目前都处于idle状态才可以进行)
            for k,v in pairs(self:getMaster()._tSkills) do
                if k ~= kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack then
                    if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                        return  -- 存在正在使用的技能，直接返回，不可以攻击，也不可以寻路
                    end
                end
            end
            -- 再判定是否怒气技能目前正在释放，如果不为idle，则立即返回
            if self:getMaster()._pRoleInfo.roleCareer ~= kCareer.kThug then  -- 不为刺客
               if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] then
                    if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack]:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                        return
                    end
                end
            end
            
            -- 玩家角色搜索视野范围（无限大）内的最近目标集合（用于自动战斗寻路锁定目标位置）与普通攻击的警戒范围内的目标集合
            local targetsInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
            if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                --------------------------------------------------- 自动攻击 ------------------------------------------------------------------
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kGenAttack)
                return
            else
                ---------------------------------------------- 无法进行攻击时，开始寻路 ----------------------------------------------------------
                -- 玩家角色自动搜索视野范围内的最近目标
                if #targetsInView ~= 0 then  -- 视野范围内有目标，则寻路后开始切入跑步状态
                    local posIndex = self:getMaster():getPositionIndex()
                    local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(targetsInView[1].enemy:getPositionX(), targetsInView[1].enemy:getPositionY()))
                    local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, false, {moveDirections = path})
                    return
                end

                -- 当前区域的路障还没有消失，则不可以进行到下一个野怪区域中心位置和结束传送门位置的寻路
                local roadBlocks = self:getEntitysManager()._tRoadBlockEntitys[self:getMonstersManager()._nCurMonsterAreaIndex]
                if roadBlocks ~= nil and table.getn(roadBlocks) ~= 0 then
                    return
                end

                -- 玩家角色自动搜索下一个野怪区域中心位置，寻路后开始切入跑步状态
                if MapManager:getInstance()._nNextMonsterAreaCenterPos.x ~= 0 and self:getMapManager()._nNextMonsterAreaCenterPos.y ~= 0 then
                    local posIndex = self:getMaster():getPositionIndex()
                    local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(self:getMapManager()._nNextMonsterAreaCenterPos.x, self:getMapManager()._nNextMonsterAreaCenterPos.y))
                    local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, false, {moveDirections = path})
                    return
                end
                -- 玩家角色自动搜索结束传送门位置，寻路后开始切入跑步状态
                if table.getn(self:getEntitysManager()._tDoors[2]) ~= 0 then
                    local doorIndex = getRandomNumBetween(1,table.getn(self:getEntitysManager()._tDoors[2]))
                    local target = self:getEntitysManager()._tDoors[2][doorIndex]
                    if target:isVisible() == true and target._pAni:getOpacity() == 255 then
                        local posIndex = self:getMaster():getPositionIndex()
                        for k,v in pairs(self:getEntitysManager()._tDoors[2]) do
                            local doorPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(v:getPositionX(), v:getPositionY()))
                            if posIndex.x == doorPosIndex.x and posIndex.y == doorPosIndex.y - 2 then
                                return  -- 已经站在门的位置上了，则直接返回，不做寻路
                            end
                        end
                        local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
                        targetPosIndex.y = targetPosIndex.y - 2
                        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, false, {moveDirections = path})
                        return
                    end
                end
            end

        end
    elseif self:getMaster()._strCharTag == "pvp" then
        
        -- 测试使用
        --self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kGenAttack, true)

        if self:getRolesManager()._pPvpPlayerRole._refStick:getRefValue() == 0 then
            -- 先检测是否需要进行自动攻击  (先判定是否所有技能目前都处于idle状态才可以进行)
            for k,v in pairs(self:getMaster()._tSkills) do
                if k ~= kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack then
                    if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                        return  -- 存在正在使用的技能，直接返回，不可以攻击，也不可以寻路
                    end
                end
            end
            -- 再判定是否怒气技能目前正在释放，如果不为idle，则立即返回
            if self:getMaster()._pRoleInfo.roleCareer ~= kCareer.kThug then  -- 不为刺客
                if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] then
                    if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack]:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                        return
                    end
                end
            end
            -- PVP对手搜索视野范围（无限大）内的最近目标集合与已经冷却结束的警戒范围内的目标集合
            local skillWayIdex = self:getAIManager():playerRoleDecideSkill(self:getMaster())
            local targetsInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tSkills[skillWayIdex])
            if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                --------------------------------------------------- 自动攻击 ------------------------------------------------------------------
                if skillWayIdex == kType.kSkill.kWayIndex.kPlayerRole.kGenAttack then  -- 需要发起普通攻击
                    if self:getMaster()._refGenAttackButton:getRefValue() == 0 then
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kGenAttack)
                    end
                elseif skillWayIdex == kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack then  -- 需要发起怒气攻击
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kAngerAttack)
                else    -- 需要发起技能攻击
                    if self:getMaster()._tRefSkillButtons[skillWayIdex-1]:getRefValue() == 0 then
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kSkillAttack, false, skillWayIdex)
                    end
                end
                return
            else
                ---------------------------------------------- 无法进行攻击时，开始寻路 ----------------------------------------------------------
                if self:getMaster()._refStick:getRefValue() == 0 then
                    -- PVP对手自动搜索视野范围内的最近目标
                    local target = self:getRolesManager()._pMainPlayerRole
                    local posIndex = self:getMaster():getPositionIndex()
                    local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
                    local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, false, {moveDirections = path})
                end
                return
                
            end
            
        end
        
    end
    
end

return BattlePlayerRoleStandState
