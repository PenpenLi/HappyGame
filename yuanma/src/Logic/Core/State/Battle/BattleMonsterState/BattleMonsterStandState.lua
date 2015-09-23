--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中怪物角色站立状态
--===================================================
local BattleMonsterStandState = class("BattleMonsterStandState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterStandState:ctor()
    self._strName = "BattleMonsterStandState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kStand  -- 状态类型ID
    self._fSearchInterval = 0                           -- 搜索目标反应时间
    self._fIntervalCounter = 0                          -- 搜索目标反应时间的计数器
    self._bThiefReadyToAttack = false

end

-- 创建函数
function BattleMonsterStandState:create()
    local state = BattleMonsterStandState.new()
    return state
end

-- 进入函数
function BattleMonsterStandState:onEnter(args)
    --print(self._strName.." is onEnter!")   
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("--STATE--MONSTER"..self:getMaster()._pRoleInfo.ID.."--:Stand")
        if fRoleStandWaitDelay > self:getMaster()._pRoleInfo.StandSearchInterval then
            self._fSearchInterval = fRoleStandWaitDelay
        else
            self._fSearchInterval = self:getMaster()._pRoleInfo.StandSearchInterval
        end 
        
        self._fIntervalCounter = 0
        
        -- 刷新新的技能链以备战斗使用
        self:getMaster():initRandomSkillChain()
        
        -- print("刷新新的技能链！！！！！")
        
        -- 刷新动作
        self:getMaster():playStandAction()
        
        -- 检测遮挡
        self:getMaster():checkCover()

        if self:getMaster()._nMonsterType == kType.kMonster.kThiefBOSS then
            if args and args.bThiefReadyToAttack then
                self._bThiefReadyToAttack = args.bThiefReadyToAttack
            end
        end
    end
    
    return
end

-- 退出函数
function BattleMonsterStandState:onExit()
    --print(self._strName.." is onExit!")
    self._fSearchInterval = 0
    self._fIntervalCounter = 0
    self._bThiefReadyToAttack = false

    return
end

-- 更新逻辑
function BattleMonsterStandState:update(dt)
    
    -- 如果正在显示对话或地图正在移动，则直接返回
    if self:getTalksManager():isShowingTalks() == true or self:getMapManager():isCameraMoving() == true then
        return
    end
    
    -- 搜索反应时间计数器
    self._fIntervalCounter = self._fIntervalCounter + dt
    if self._fIntervalCounter <= self._fSearchInterval then
        return
    end
    
    if self:getMaster() then
        -- 先判定是否所有技能目前都处于idle状态
        local bSkillsAllIdles = true
        for k,v in pairs(self:getMaster()._tSkills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                bSkillsAllIdles = false
                break
            end
        end
        if bSkillsAllIdles == true then
            if self:getMaster()._nMonsterType == kType.kMonster.kThiefBOSS then  -- 盗宝贼BOSS
                if self._bThiefReadyToAttack == false then  -- 没准备好攻击，则只可能逃跑或者待机
                    local posIndex = self:getMaster():getPositionIndex()
                    local thiefNextPlotIndex = self:getAIManager():thiefBossGetThiefNextPlotIndex(self:getMaster())
                    if thiefNextPlotIndex then  -- 如果为非空，则可以寻路，否则原地待机
                        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, thiefNextPlotIndex)
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kRun, false, {moveDirections = path})
                    end
                elseif self._bThiefReadyToAttack == true then  -- 说明逃跑刚刚结束，可以准备回击  
                    -- 野怪搜索视野范围内的最近目标和当前技能链中第一个技能的警戒范围内的最近目标
                    local targetsInView, targetsInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tReverseIDSkills[self:getMaster()._tCurSkillChain[1]])
                    if #targetsInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                        -- monster发起进攻
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kSkillAttack)
                    else  -- 逃跑结束后，警戒范围内没有发现目标，则丧失每次攻击机会
                        self._bThiefReadyToAttack = false
                    end
                end

            else -- 普通野怪的正常逻辑
                -- 野怪搜索视野范围内的最近目标和当前技能链中第一个技能的警戒范围内的最近目标
                local targetsInView, targetsInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tReverseIDSkills[self:getMaster()._tCurSkillChain[1]])
                if #targetsInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                    -- monster发起进攻
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kSkillAttack)
                elseif #targetsInView ~= 0 then  -- 警戒范围内没有目标，视野范围内却有目标，则开始朝着目标前进
                    if TableTempleteMonster[self:getMaster()._pRoleInfo.TempleteID].CanMove == 1 then
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kRun)
                    end
                end
            end
            
        end
    end
    
    return
end

return BattleMonsterStandState
