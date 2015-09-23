--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleEntityNormalState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中实体正常状态
--===================================================
local BattleEntityNormalState = class("BattleEntityNormalState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleEntityNormalState:ctor()
    self._strName = "BattleEntityNormalState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleEntity.kNormal  -- 状态类型ID
    self._fIntervalCounter = 0                          -- 待机状态下进入攻击状态的间隔计数器
end

-- 创建函数
function BattleEntityNormalState:create()
    local state = BattleEntityNormalState.new()
    return state
end

-- 进入函数
function BattleEntityNormalState:onEnter(args)
    --print(self._strName.." is onEnter!")    
    -- mmo.DebugHelper:showJavaLog("mmo:BattleEntityNormalState")
    -- 待机状态下进入攻击状态的间隔计数器清0
    self._fIntervalCounter = 0
    
    if self:getMaster() then
        -- 刷新动作
        self:getMaster():playNormalAction()
    end
    
    return
end

-- 退出函数
function BattleEntityNormalState:onExit()
    --print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function BattleEntityNormalState:update(dt)
    -- 如果正在显示对话或地图正在移动，则直接返回
    if self:getTalksManager():isShowingTalks() == true or self:getMapManager():isCameraMoving() == true then
        return
    end
    
    if self:getMaster() then
        if self:getMaster()._pSkill then
            self._fIntervalCounter = self._fIntervalCounter + dt
            if self._fIntervalCounter < self:getMaster()._fNormalInterval then  -- 如果没有等到当前实体normal状态下的间隔周期，则立即返回，不会进入到攻击状态
                return
            end        
            
            -- 野怪搜索视野范围内的最近目标和当前技能链中第一个技能的警戒范围内的最近目标
            local targetsInView, targetsInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._pSkill)
            if #targetsInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                -- entity发起进攻            
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleEntity):setCurStateByTypeID(kType.kState.kBattleEntity.kSkillAttack, false, {target = targetsInWarning[1]["enemy"]})
            end
        end
    end
    
    return
end

return BattleEntityNormalState
