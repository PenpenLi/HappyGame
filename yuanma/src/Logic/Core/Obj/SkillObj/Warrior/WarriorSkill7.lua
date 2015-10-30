--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WarriorSkill7.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/8
-- descrip:   战士技能7 【风暴剑】
--===================================================
local WarriorSkill7 = class("WarriorSkill7",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function WarriorSkill7:ctor()
    self._strName = "WarriorSkill7"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kWarriorSkill7               -- 技能对象类型
    self._pCurState = nil                                         -- 技能当前的状态机状态
    
    self._bStickAdd = false                                       -- 引用计数的标记
    self._bIgnoreHurtAdd = false                                  -- 引用计数的标记
    
    self._fShootActDuration = 0.25                                 -- 冲刺的持续时间
    self._nRoleAttackActionIndex = 8                              -- 角色攻击动作index
    self._fChantDelayTime = 0.5                                   -- 吟唱动作持续时间s

end

-- 创建函数
function WarriorSkill7:create(master, skillInfo)   
    local skill = WarriorSkill7.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function WarriorSkill7:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWarriorSkill7()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function WarriorSkill7:onExitWarriorSkill7()    
    self:onExitSkillObj()
end

-- 循环更新
function WarriorSkill7:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function WarriorSkill7:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function WarriorSkill7:onUse() 
    -- test
    -- cc.Director:getInstance():getScheduler():setTimeScale(0.3)
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        if self:getMaster()._kRoleType == kType.kRole.kPlayer then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)          
        elseif self:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
        end
    end
end

-- 初始化动作帧事件回调
function WarriorSkill7:initActionsFrameEvents(index, action)
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
function WarriorSkill7:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 1*offsetX/5 - 130, self:getPositionY() - 1*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 2*offsetX/5 - 130, self:getPositionY() - 2*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 3*offsetX/5 - 100, self:getPositionY() - 3*offsetY/5 - 100, 200, 200))
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_2" then
        self:setCurAttackFrameEventInfo(1,2)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 1*offsetX/5 - 130, self:getPositionY() - 1*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 2*offsetX/5 - 130, self:getPositionY() - 2*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 3*offsetX/5 - 100, self:getPositionY() - 3*offsetY/5 - 100, 200, 200))
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_3" then
        self:setCurAttackFrameEventInfo(1,3)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 1*offsetX/5 - 130, self:getPositionY() - 1*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 2*offsetX/5 - 130, self:getPositionY() - 2*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 3*offsetX/5 - 100, self:getPositionY() - 3*offsetY/5 - 100, 200, 200))
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_4" then
        self:setCurAttackFrameEventInfo(1,4)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 1*offsetX/5 - 130, self:getPositionY() - 1*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 2*offsetX/5 - 130, self:getPositionY() - 2*offsetY/5 - 130, 260, 260))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 3*offsetX/5 - 100, self:getPositionY() - 3*offsetY/5 - 100, 200, 200))
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
        self:getMaster():setVisible(true)       -- 角色现身
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            if self:getMaster()._kRoleType == kType.kRole.kPlayer then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)          
            elseif self:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
            end
        end
    end
    self._strFrameEventName = ""
end

-- 发生攻击位移
-- 技能冲刺发生位移时，检测前方是否有障碍，如果有障碍，修正实际可冲刺的位移数据
function WarriorSkill7:AttackOffset()
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
        if offset >= self._pSkillInfo.WarnRange then
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
    local act = cc.EaseSineInOut:create(cc.MoveBy:create(self._fShootActDuration,cc.p(offsetX,offsetY)))
    act:setTag(nRoleShootAheadTag)
    self:getMaster():runAction(act)
    
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function WarriorSkill7:onEnterIdleDo(state)
    --print("WarriorSkill7:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function WarriorSkill7:onExitIdleDo()
--print("WarriorSkill7:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function WarriorSkill7:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function WarriorSkill7:onEnterChantDo(state)
    --print("WarriorSkill7:onEnterChantDo()")
    self._pCurState = state
    
    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        -- 忽略伤害引用计数+1（连应值都不会有）
        self:getMaster()._pRefRoleIgnoreHurt:add()
        self._bIgnoreHurtAdd = true
        self:getMaster():setVisible(false)  -- 角色隐藏
        self:setVisible(true)
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)
        self:playActionByIndex(1)   -- 播放特效
        self:setRotation(270-(self:getMaster():getAngle3D())) -- 更新特效的rotation
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

    local skillActOver = function()
        -- 摇杆解禁
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
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
function WarriorSkill7:onExitChantDo()
--print("WarriorSkill7:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function WarriorSkill7:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function WarriorSkill7:onEnterProcessDo(state)
    --print("WarriorSkill7:onEnterProcessDo()")
    self._pCurState = state

    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)

    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function WarriorSkill7:onExitProcessDo()
--print("WarriorSkill7:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function WarriorSkill7:onUpdateProcessDo(dt)   

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function WarriorSkill7:onEnterReleaseDo(state)
    --print("WarriorSkill7:onEnterReleaseDo()")
    self._pCurState = state
    
    -- 记录所有目标的位置
    self:AttackOffset()

end

-- 技能释放状态onExit时技能操作
function WarriorSkill7:onExitReleaseDo()
    --print("WarriorSkill7:onExitReleaseDo()")
    -- 忽略伤害引用计数-1（连应值都不会有）
    self._pMaster._pRefRoleIgnoreHurt:sub()
    self._bIgnoreHurtAdd = false

end

-- 技能释放状态onUpdate时技能操作
function WarriorSkill7:onUpdateReleaseDo(dt)
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight()/2)
end

-- 技能结束时的复位操作
function WarriorSkill7:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    self:getMaster():setVisible(true)       -- 角色现身
    
    -- 检测 相关引用计数
    if self._bStickAdd == true then
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
    end
    if self._bIgnoreHurtAdd == true then
        self:getMaster()._pRefRoleIgnoreHurt:sub()
        self._bIgnoreHurtAdd = false
    end
    
end

---------------------------------------------------------------------------------------------------------
return WarriorSkill7
