--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WarriorSkill9.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/12
-- descrip:   战士技能9 【炎魔碎】
--===================================================
local WarriorSkill9 = class("WarriorSkill9",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function WarriorSkill9:ctor()
    self._strName = "WarriorSkill9"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kWarriorSkill9               -- 技能对象类型
    self._pCurState = nil                                         -- 技能当前的状态机状态

    self._bStickAdd = false                                       -- 引用计数的标记

    self._tRoleDistance = {100,250}                               -- 人物的位移
    self._tRoleDistanceDuration = {0.45,0.45}                     -- 人物的位移的时间
    self._fDistance = 100                                         -- 最后一击记录自身角色的距离
    self._nRoleAttackActionIndex = 9                              -- 角色攻击动作index
    self._fChantDelayTime = 0.5                                   -- 吟唱动作持续时间s
    self._fSecondDelayTime = 0.45                                 -- 最后一击的延时时间

end

-- 创建函数
function WarriorSkill9:create(master, skillInfo)   
    local skill = WarriorSkill9.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function WarriorSkill9:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWarriorSkill9()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function WarriorSkill9:onExitWarriorSkill9()    
    self:onExitSkillObj()
end

-- 循环更新
function WarriorSkill9:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function WarriorSkill9:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function WarriorSkill9:onUse()
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
    end
end

-- 初始化动作帧事件回调
function WarriorSkill9:initActionsFrameEvents(index, action)
    if index == 1 then
        local function onFrameEvent1(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent1)
    end

    if index == 2 then
        local function onFrameEvent2(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent2)
    end

end

-- 帧事件的处理
function WarriorSkill9:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_2" then
        self:setCurAttackFrameEventInfo(1,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        -- 发生位移
        local offsetX, offsetY = self:getAttackOffset(2)
        self:getMaster():stopActionByTag(nRoleShootAheadTag)
        local act = cc.EaseSineInOut:create(cc.MoveBy:create(self._tRoleDistanceDuration[2], cc.p(offsetX,offsetY)))
        act:setTag(nRoleShootAheadTag)
        self:getMaster():runAction(act)
    elseif self._strFrameEventName == "start2" then
    elseif self._strFrameEventName == "hurt2_1" then
        self:setCurAttackFrameEventInfo(2,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt2_2" then
        self:setCurAttackFrameEventInfo(2,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt2_3" then
        self:setCurAttackFrameEventInfo(2,3)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end


-- 发生攻击位移
-- 技能冲刺发生位移时，检测前方是否有障碍，如果有障碍，修正实际可冲刺的位移数据
function WarriorSkill9:getAttackOffset(regionIndex)
    local rect = self:getMaster():getBottomRectInMap() 
    local toX = rect.x
    local toY = rect.y
    local width = rect.width
    local height = rect.height
    local direction = self:getMaster()._kDirection
    local offset = 0
    local test = 37
    local offsetMax = self._tRoleDistance[regionIndex]

    local tmpOffsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
    local tmpOffsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))

    while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false do
        offset = offset + test
        if offset >= offsetMax then
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
    
    return offsetX, offsetY    
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function WarriorSkill9:onEnterIdleDo(state)
    --print("WarriorSkill9:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function WarriorSkill9:onExitIdleDo()
--print("WarriorSkill9:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function WarriorSkill9:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function WarriorSkill9:onEnterChantDo(state)
    --print("WarriorSkill9:onEnterChantDo()")
    self._pCurState = state

    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

    local skillActOver = function()
        -- 摇杆解禁
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)-- 切换到站立
        end
    end
    -- 摇杆禁用
    self:getMaster()._refStick:add()
    self._bStickAdd = true
    self:getMaster()._refStick._nWaitingSkillActOverToSubCount = self:getMaster()._refStick._nWaitingSkillActOverToSubCount + 1

    local duration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(skillActOver)))

end

-- 技能吟唱状态onExit时技能操作
function WarriorSkill9:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function WarriorSkill9:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function WarriorSkill9:onEnterProcessDo(state)
    --print("WarriorSkill9:onEnterProcessDo()")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function WarriorSkill9:onExitProcessDo()
--print("WarriorSkill9:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function WarriorSkill9:onUpdateProcessDo(dt)   

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function WarriorSkill9:onEnterReleaseDo(state)
    --print("WarriorSkill9:onEnterReleaseDo()")
    self._pCurState = state
    
    self._nSettledZorder = kZorder.kMaxSkill
    
    self:setPosition(cc.p(self:getMaster():getPositionX(), self:getMaster():getPositionY() + self:getMaster():getHeight()/2))

    self:playActionByIndex(1)
    
    -- 发生位移
    local offsetX, offsetY = self:getAttackOffset(1)
    self:getMaster():stopActionByTag(nRoleShootAheadTag)
    local masterAct = cc.EaseSineInOut:create(cc.MoveBy:create(self._tRoleDistanceDuration[1], cc.p(offsetX,offsetY)))
    masterAct:setTag(nRoleShootAheadTag)
    self:getMaster():runAction(masterAct)
    
    self:stopActionByTag(nSkillFlyActTag)
    local skillOffsetAct = cc.EaseSineInOut:create(cc.MoveBy:create(self._tRoleDistanceDuration[1], cc.p(offsetX,offsetY)))
    skillOffsetAct:setTag(nSkillFlyActTag)
    self:runAction(skillOffsetAct)
    
    ---第2招开始 ------------------------------------------------------------------------------
    local secondStart = function()
        -- 给技能指定施展时的zorder    
        if self:getMaster()._kDirection == kDirection.kUp or
            self:getMaster()._kDirection == kDirection.kLeftUp or
            self:getMaster()._kDirection == kDirection.kRightUp then
            self._nSettledZorder = self:getMaster():getLocalZOrder() - 1
        else
            self._nSettledZorder = kZorder.kMaxSkill
        end
        
        -- 当前转向的距离
        local offsetY = (self._fDistance)*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = (self._fDistance)*math.cos(math.rad(self:getMaster():getAngle3D()))
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX + offsetX, posY + offsetY)
        
        self:playActionByIndex(2)
        
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self:getActionTimeByIndex(1) + self._fSecondDelayTime), cc.CallFunc:create(secondStart)))  -- 0.1秒动作后放出技能  
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)

end

-- 技能释放状态onExit时技能操作
function WarriorSkill9:onExitReleaseDo()
    --print("WarriorSkill9:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function WarriorSkill9:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function WarriorSkill9:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    
    -- 检测 相关引用计数
    if self._bStickAdd == true then
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
    end
    
end

---------------------------------------------------------------------------------------------------------
return WarriorSkill9
