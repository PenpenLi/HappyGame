--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中玩家角色站立状态
--===================================================
local BattleFriendRoleStandState = class("BattleFriendRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleFriendRoleStandState:ctor()
    self._strName = "BattleFriendRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleFriendRole.kStand  -- 状态类型ID
    self._fWaitCounter = 0                                 -- 站立后的延时计数
    
end

-- 创建函数
function BattleFriendRoleStandState:create()
    local state = BattleFriendRoleStandState.new()
    return state
end

-- 进入函数
function BattleFriendRoleStandState:onEnter(args)
    
    if self:getMaster() then

        self._fWaitCounter = 0

        -- 刷新动作
        self:getMaster():playStandAction()
        
        -- 检测遮挡
        self:getMaster():checkCover()
        
    end
    
    return
end

-- 退出函数
function BattleFriendRoleStandState:onExit()
    return
end

-- 更新逻辑
function BattleFriendRoleStandState:update(dt)    
    if self:getMaster() then
        -- 如果正在显示对话或地图正在移动，则直接返回
        if self:getTalksManager():isShowingTalks() == true or self:getMapManager():isCameraMoving() == true then
            return
        end
        -- 待机等待计数器
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
function BattleFriendRoleStandState:procAutoBattle(dt)
    -- 搜索视野范围（无限大）内的最近目标集合与已经冷却结束的警戒范围内的目标集合
    local targetsInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
    if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
        --------------------------------------------------- 自动攻击 ------------------------------------------------------------------
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kGenAttack)
    elseif #targetsInView ~= 0 then   -- 视野范围内有目标，则开始寻路
        ---------------------------------------------- 无法进行攻击时，开始寻路 ----------------------------------------------------------
        -- 自动搜索视野范围内的最近目标
        local target = targetsInView[1].enemy
        local posIndex = self:getMaster():getPositionIndex()
        local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kRun, false, {moveDirections = path})
    end
        
end

return BattleFriendRoleStandState
