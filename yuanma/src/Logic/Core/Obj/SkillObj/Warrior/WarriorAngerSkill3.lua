--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WarriorAngerSkill3.lua
-- author:    taoye
-- e-mail:    870428198@qq.com
-- created:   2015/6/24
-- descrip:   刺客怒气技能3  绝剑·黑白
--===================================================
local WarriorAngerSkill3 = class("WarriorAngerSkill3",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function WarriorAngerSkill3:ctor()
    self._strName = "WarriorAngerSkill3"                          -- 技能名称
    self._kTypeID = kType.kSkill.kID.kWarriorAngerSkill3          -- 技能对象类型
    self._pCurState = nil                                         -- 技能当前的状态机状态
    
    self._bStickAdd = false                                       -- 引用计数的标记
    self._bIgnoreHurtAdd = false                                  -- 引用计数的标记
    
    self._nRoleAttackActionIndex = 6                              -- 角色攻击动作index
    self._fChantDelayTime = 0.90                                  -- 吟唱动作持续时间s
    
end

-- 创建函数
function WarriorAngerSkill3:create(master, skillInfo)   
    local skill = WarriorAngerSkill3.new(master, skillInfo)
    skill:dispose()
    
    return skill
end

-- 处理函数
function WarriorAngerSkill3:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWarriorAngerSkill3()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function WarriorAngerSkill3:onExitWarriorAngerSkill3()    
    self:onExitSkillObj()
end

-- 循环更新
function WarriorAngerSkill3:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function WarriorAngerSkill3:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function WarriorAngerSkill3:onUse() 
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
function WarriorAngerSkill3:initActionsFrameEvents(index, action)
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
function WarriorAngerSkill3:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_2" then
        self:setCurAttackFrameEventInfo(1,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_3" then
        self:setCurAttackFrameEventInfo(1,3)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_4" then
        self:setCurAttackFrameEventInfo(1,4)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_5" then
        self:setCurAttackFrameEventInfo(1,5)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function WarriorAngerSkill3:onEnterIdleDo(state)
    --print("WarriorAngerSkill3:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function WarriorAngerSkill3:onExitIdleDo()
--print("WarriorAngerSkill3:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function WarriorAngerSkill3:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function WarriorAngerSkill3:onEnterChantDo(state)
    --print("WarriorAngerSkill3:onEnterChantDo()")
    self._pCurState = state
    local info = self._pSkillInfo
    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        --self:setScale(0.1)
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
    
    local skillActOver = function()
        -- 摇杆解禁
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            if self:getMaster()._kRoleType == kType.kRole.kPlayer then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)          
            elseif self:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
            end
        end
    end
    -- 摇杆禁用
    self:getMaster()._refStick:add()
    self._bStickAdd = true
    self:getMaster()._refStick._nWaitingSkillActOverToSubCount = self:getMaster()._refStick._nWaitingSkillActOverToSubCount + 1
    
    -- 【开始忽略一切伤害】
    self:getMaster()._pRefRoleIgnoreHurt:add()
    self._bIgnoreHurtAdd = true
    
    local duration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(skillActOver)))
    
end

-- 技能吟唱状态onExit时技能操作
function WarriorAngerSkill3:onExitChantDo()
--print("WarriorAngerSkill3:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function WarriorAngerSkill3:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function WarriorAngerSkill3:onEnterProcessDo(state)
    --print("WarriorAngerSkill3:onEnterProcessDo()")
    self._pCurState = state 
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
end

-- 技能执行状态onExit时技能操作
function WarriorAngerSkill3:onExitProcessDo()
    --print("WarriorAngerSkill3:onExitProcessDo()")   
end

-- 技能执行状态onUpdate时技能操作
function WarriorAngerSkill3:onUpdateProcessDo(dt)
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function WarriorAngerSkill3:onEnterReleaseDo(state)
    --print("WarriorAngerSkill3:onEnterReleaseDo()")
    self._pCurState = state
 
    self:setVisible(true)        
    self:playActionByIndex(1)
    
    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill
    
    -- 屏幕正中央的位置
    self:setPosition(cc.p(self:getMapManager()._pMapCamera:getPositionX(), self:getMapManager()._pMapCamera:getPositionY()))
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)

end

-- 技能释放状态onExit时技能操作
function WarriorAngerSkill3:onExitReleaseDo()
    --print("WarriorAngerSkill3:onExitReleaseDo()")
    -- 【恢复忽略一切伤害】
    self:getMaster()._pRefRoleIgnoreHurt:sub()
    self._bIgnoreHurtAdd = false
    
end

-- 技能释放状态onUpdate时技能操作
function WarriorAngerSkill3:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function WarriorAngerSkill3:reset()
    -- 恢复技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    self:stopActionByIndex(1)
    
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
return WarriorAngerSkill3
