--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonsterSkill37.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/7/22
-- descrip:   怪物技能攻击37 判官
--===================================================
local MonsterSkill37 = class("MonsterSkill37",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MonsterSkill37:ctor()
    self._strName = "MonsterSkill37"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMonsterSkill37            -- 技能对象类型
    self._pCurState = nil                                       -- 技能当前的状态机状态
    self._fRoleActDuration = nil                                -- 攻击动作完成的时间
    self._nRoleAttackActionIndex = 1                            -- 角色攻击动作index
    self._fChantDelayTime = 1.15                                -- 吟唱动作持续时间s
    self._fAttackOffset = 200                                   -- 向前冲刺的距离
    self._fDistance = 140                                        -- 技能特效距离人物自身的距离
    
end

-- 创建函数
function MonsterSkill37:create(master,skillInfo)
    local skill = MonsterSkill37.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MonsterSkill37:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMonsterSkill37()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function MonsterSkill37:onExitMonsterSkill37()    
    self:onExitSkillObj()
end

-- 循环更新
function MonsterSkill37:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MonsterSkill37:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end


-- 技能使用接口
function MonsterSkill37:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空     
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function MonsterSkill37:initActionsFrameEvents(index, action)
    if index == 1 then
        local function onFrameEvent1(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent1)
    end

end

-- 帧事件的处理
function MonsterSkill37:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function MonsterSkill37:onEnterIdleDo(state)
    self._pCurState = state
    self:setVisible(false)
    
end

-- 技能待机状态onExit时技能操作
function MonsterSkill37:onExitIdleDo()

end

-- 技能待机状态onUpdate时技能操作
function MonsterSkill37:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MonsterSkill37:onEnterChantDo(state)
    self._pCurState = state
    
    -- 刷新方向（考虑野怪是否有指定转向）
    --[[
    if TableTempleteMonster[self:getMaster()._pRoleInfo.TempleteID].AppointedRotation == -1 then
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self)
    end
    ]]
    
    -- 播放攻击时的人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    -- 人物动作结束
    local roleActOver = function()
        -- 人物动作结束后，可以开始释放下一个技能
        if self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID == kType.kState.kBattleMonster.kSkillAttack then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._bToNextSkill = true
        end
    end
    self._fRoleActDuration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fRoleActDuration), cc.CallFunc:create(roleActOver)))

    ---人物吟唱动作播放到一段时间时进入到process阶段---------------------------------------------------------------------------
    local chantOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
    
    -- 发生位移
    local targetsInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(),self)
    if table.getn(targetInWarning) ~= 0 then
        self:AttackOffset()
    end  
    
end

-- 技能吟唱状态onExit时技能操作
function MonsterSkill37:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function MonsterSkill37:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MonsterSkill37:onEnterProcessDo(state)
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function MonsterSkill37:onExitProcessDo()

end

-- 技能执行状态onUpdate时技能操作
function MonsterSkill37:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MonsterSkill37:onEnterReleaseDo(state)
    self._pCurState = state
    
    self:setVisible(true)
    
    -- 给技能指定施展时的zorder    
    if self:getMaster()._kDirection == kDirection.kUp or
        self:getMaster()._kDirection == kDirection.kLeftUp or
        self:getMaster()._kDirection == kDirection.kRightUp then
        self._nSettledZorder = self:getMaster():getLocalZOrder() - 1
    else
        self._nSettledZorder = kZorder.kMaxSkill
    end
    
    local offsetY = self._fDistance*math.sin(math.rad(self:getMaster():getAngle3D()))
    local offsetX = self._fDistance*math.cos(math.rad(self:getMaster():getAngle3D()))
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX + offsetX, posY + offsetY)

    self:playActionByIndex(1)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
    
end

-- 技能释放状态onExit时技能操作
function MonsterSkill37:onExitReleaseDo()

end

-- 技能释放状态onUpdate时技能操作
function MonsterSkill37:onUpdateReleaseDo(dt)

end

-- 发生攻击位移
-- 技能冲刺发生位移时，检测前方是否有障碍，如果有障碍，修正实际可冲刺的位移数据
function MonsterSkill37:AttackOffset()
    local rect = self:getMaster():getBottomRectInMap() 
    local toX = rect.x
    local toY = rect.y
    local width = rect.width
    local height = rect.height
    local direction = self:getMaster()._kDirection
    local offset = 0
    local test = 37

    local tmpOffsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
    local tmpOffsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))

    while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false and
        self:getRolesManager():isRectCollidingOnMainPlayerBottoms(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false do
        offset = offset + test
        if offset >= self._fAttackOffset then
            break
        end
        tmpOffsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
        tmpOffsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))
    end

    if offset <= test then
        offset = test  -- 保证下面做差以后为0
    end
    offset = offset - test

    -- 发生位移
    local offsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))
    local offsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
    self:getMaster():stopActionByTag(nRoleShootAheadTag)
    local act = cc.EaseSineInOut:create(cc.MoveBy:create(self._fRoleActDuration,cc.p(offsetX,offsetY)))
    act:setTag(nRoleShootAheadTag)
    self:getMaster():runAction(act)
    
end

---------------------------------------------------------------------------------------------------------
return MonsterSkill37
