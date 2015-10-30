--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPlayerRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/8
-- descrip:   战斗中其他玩家角色站立状态
--===================================================
local BattleOtherPlayerRoleStandState = class("BattleOtherPlayerRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPlayerRoleStandState:ctor()
    self._strName = "BattleOtherPlayerRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPlayerRole.kStand  -- 状态类型ID
    self._fWaitCounter = 0                                      -- 站立后的延时计数
    self._fStandWaitDelay = fRoleStandWaitDelay                 -- 站立等待的时间
    
end

-- 创建函数
function BattleOtherPlayerRoleStandState:create()
    local state = BattleOtherPlayerRoleStandState.new()
    return state
end

-- 进入函数
function BattleOtherPlayerRoleStandState:onEnter(args)
    if self:getMaster() then
        --mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:Stand")
        self._fWaitCounter = 0
        -- 刷新动作
        self:getMaster():playStandAction()
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 站立等待的时间
        self._fStandWaitDelay = fRoleStandWaitDelay + getRandomNumBetween(1,10)/10

    end
    
    return
end

-- 退出函数
function BattleOtherPlayerRoleStandState:onExit()
    --print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function BattleOtherPlayerRoleStandState:update(dt)
    if self:getMaster() then
        -- 如果正在显示对话或地图正在移动，则直接返回
        if self:getTalksManager():isShowingTalks() == true or self:getMapManager():isCameraMoving() == true then
            return
        end
        -- 待机等待计数器
        self._fWaitCounter = self._fWaitCounter + dt
        if self._fWaitCounter < self._fStandWaitDelay then
            return
        end
        -- 自动战斗相关逻辑
        self:procAutoBattle(dt)
    end
    return
end

-- 自动战斗相关逻辑
function BattleOtherPlayerRoleStandState:procAutoBattle(dt)
    if self:getMaster()._refStick:getRefValue() == 0 then
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
            self._pOwnerMachine:usePetCooperateSkill()  -- 发现目标时，考虑自动释放宠物共鸣技能
            --------------------------------------------------- 自动攻击 ------------------------------------------------------------------
            if skillWayIdex == kType.kSkill.kWayIndex.kPlayerRole.kGenAttack then  -- 需要发起普通攻击
                if self:getMaster()._refGenAttackButton:getRefValue() == 0 then
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kGenAttack)
                end
            elseif skillWayIdex == kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack then  -- 需要发起怒气攻击
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kAngerAttack)
            else    -- 需要发起技能攻击
                if self:getMaster()._tRefSkillButtons[skillWayIdex-1]:getRefValue() == 0 then
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kSkillAttack, false, skillWayIdex)
                end
            end
            return
        elseif #targetsInView ~= 0 then   -- 视野范围内有目标，则开始寻路
            ---------------------------------------------- 无法进行攻击时，开始寻路 ----------------------------------------------------------
            if self:getMaster()._refStick:getRefValue() == 0 then
                local target = targetsInView[1].enemy
                local posIndex = self:getMaster():getPositionIndex()
                local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
                local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kRun, false, {moveDirections = path})
            end
            return
        end
        
    end
    
end

return BattleOtherPlayerRoleStandState
