--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonsterSkill61.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/9/25
-- descrip:   怪物技能攻击61   牛魔王  冲撞  
--===================================================
local MonsterSkill61 = class("MonsterSkill61",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MonsterSkill61:ctor()
    self._strName = "MonsterSkill61"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMonsterSkill61            -- 技能对象类型
    self._pCurState = nil                                       -- 技能当前的状态机状态
    self._fRoleActDuration = nil                                -- 攻击动作的时间
    self._bHit = false                                          -- 是否已经击中
    self._nRoleAttackActionIndex = 4                            -- 角色攻击动作index
    self._fAttackOffset = 1500                                   -- 向前冲撞的距离
    
end

-- 创建函数
function MonsterSkill61:create(master,skillInfo)
    local skill = MonsterSkill61.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MonsterSkill61:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMonsterSkill61()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function MonsterSkill61:onExitMonsterSkill61()    
    self:onExitSkillObj()
end

-- 循环更新
function MonsterSkill61:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MonsterSkill61:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end


-- 技能使用接口
function MonsterSkill61:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空     
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function MonsterSkill61:initActionsFrameEvents(index, action)
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
function MonsterSkill61:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        local hit = self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
        if hit == true then  -- 击中
            self._bHit = true
        end
    elseif self._strFrameEventName == "hurt1_2" then
        self:setCurAttackFrameEventInfo(1,2)
        local hit = self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
        if hit == true then  -- 击中
            self._bHit = true
        end
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function MonsterSkill61:onEnterIdleDo(state)
    self._pCurState = state
    self:setVisible(false)
    self._bHit = false
    
end

-- 技能待机状态onExit时技能操作
function MonsterSkill61:onExitIdleDo()

end

-- 技能待机状态onUpdate时技能操作
function MonsterSkill61:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MonsterSkill61:onEnterChantDo(state)
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
        if self._bHit == false then  -- 没有击中时，要求强制倒地
            if self:getMaster():isUnusualState() == false then  -- 非异常状态时，可以切入应值(强制原地倒地)
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kBeaten, false, {nil, -1})
                return  -- 强制返回
            end
        end
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        -- 没有切换到应值倒地状态的情况下，接下来的逻辑一切正常，准备切换到下一个技能即可
        if self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID == kType.kState.kBattleMonster.kSkillAttack then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._bToNextSkill = true
        end
    end
    self._fRoleActDuration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fRoleActDuration), cc.CallFunc:create(roleActOver)))

    ---人物吟唱动作播放到一段时间时进入到process阶段---------------------------------------------------------------------------
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)

end

-- 技能吟唱状态onExit时技能操作
function MonsterSkill61:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function MonsterSkill61:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MonsterSkill61:onEnterProcessDo(state)
    self._pCurState = state
    self:setVisible(true)
    self:playActionByIndex(1)
    self:AttackOffset()  -- 开始冲撞

end

-- 技能执行状态onExit时技能操作
function MonsterSkill61:onExitProcessDo()

end

-- 技能执行状态onUpdate时技能操作
function MonsterSkill61:onUpdateProcessDo(dt)
    -- 给技能指定施展时的zorder    
    self._nSettledZorder = self:getMaster():getLocalZOrder() + 1  
    -- 位置刷新
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY)
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MonsterSkill61:onEnterReleaseDo(state)
    self._pCurState = state

end

-- 技能释放状态onExit时技能操作
function MonsterSkill61:onExitReleaseDo()

end

-- 技能释放状态onUpdate时技能操作
function MonsterSkill61:onUpdateReleaseDo(dt)

end

-- 向前冲的位移
-- 技能冲刺发生位移时，检测前方是否有障碍，如果有障碍，修正实际可冲刺的位移数据
function MonsterSkill61:AttackOffset()
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

    while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false do
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
    local act = cc.EaseSineIn:create(cc.MoveBy:create(self._fRoleActDuration,cc.p(offsetX,offsetY)))
    act:setTag(nRoleShootAheadTag)
    self:getMaster():runAction(act)
    
end

---------------------------------------------------------------------------------------------------------
return MonsterSkill61
