--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ThugSkill8.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/21
-- descrip:   刺客技能8 【飞刀阵 】
--===================================================
local ThugSkill8 = class("ThugSkill8",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function ThugSkill8:ctor()
    self._strName = "ThugSkill8"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kThugSkill8               -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    self._bIgnoreHurtAdd = false                               -- 引用计数的标记
    self._bSkillBtnAdd = {false,false,false,false}             -- 引用计数的标记
    self._bGenAttackBtnAdd = false                             -- 引用计数的标记
    
    self._nRoleAttackActionIndex = 10                          -- 角色攻击动作index
    self._fChantDelayTime = 0.4                                -- 吟唱动作持续时间s
    
end

-- 创建函数
function ThugSkill8:create(master, skillInfo)   
    local skill = ThugSkill8.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function ThugSkill8:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitThugSkill8()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function ThugSkill8:onExitThugSkill8()    
    self:onExitSkillObj()
end

-- 循环更新
function ThugSkill8:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function ThugSkill8:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function ThugSkill8:onUse() 
    -- test
    -- cc.Director:getInstance():getScheduler():setTimeScale(0.3)
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
    end
end

function ThugSkill8:initActionsFrameEvents(index, action)
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
    if index == 3 then
        local function onFrameEvent3(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent3)
    end
end

-- 帧事件的处理
function ThugSkill8:procActionsFrameEvents()
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
    elseif self._strFrameEventName == "hurt2_4" then
        self:setCurAttackFrameEventInfo(2,4)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
        self:clearCurAttackFrameEventInfo()
    elseif self._strFrameEventName == "start3" then
    elseif self._strFrameEventName == "hurt3_1" then
        self:setCurAttackFrameEventInfo(3,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt3_2" then
        self:setCurAttackFrameEventInfo(3,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt3_3" then
        self:setCurAttackFrameEventInfo(3,3)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end3" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function ThugSkill8:onEnterIdleDo(state)
    --print("ThugSkill8:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function ThugSkill8:onExitIdleDo()
--print("ThugSkill8:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function ThugSkill8:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function ThugSkill8:onEnterChantDo(state)
    --print("ThugSkill8:onEnterChantDo()")
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
        
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)-- 切换到站立
        end
        
        self:setVisible(true)
        self:playActionByIndex(1)   -- 播放特效
        
        -- 技能施展音效
        AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
        
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)
        
        -- 摇杆禁用
        self:getMaster()._refStick:add()
        self._bStickAdd = true
        self:getMaster()._refStick._nWaitingSkillActOverToSubCount = self:getMaster()._refStick._nWaitingSkillActOverToSubCount + 1
        
        local action1Over = function()
            -- 摇杆解禁
            self:getMaster()._refStick:sub()
            self._bStickAdd = false            
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
        end
        local action1Time = self:getActionTimeByIndex(1)
        self._pChantOverActionNode:stopAllActions()
        self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(action1Time), cc.CallFunc:create(action1Over)))  -- 0.1秒动作后放出技能          
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

    -- 普通攻击按钮禁用
    self:getMaster()._refGenAttackButton:add()
    self._bGenAttackBtnAdd = true

    -- 技能按钮禁用
    for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
        self:getMaster()._tRefSkillButtons[i]:add()
        self._bSkillBtnAdd[i] = true
    end
    
end

-- 技能吟唱状态onExit时技能操作
function ThugSkill8:onExitChantDo()
--print("ThugSkill8:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function ThugSkill8:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function ThugSkill8:onEnterProcessDo(state)
    --print("ThugSkill8:onEnterProcessDo()")
    self._pCurState = state

    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill
    
    self:playActionByIndex(2)   -- 播放特效
    
    local flyOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end    
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._pSkillInfo.ExploredDuration), cc.CallFunc:create(flyOver)))
    

end

-- 技能执行状态onExit时技能操作
function ThugSkill8:onExitProcessDo()
--print("ThugSkill8:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function ThugSkill8:onUpdateProcessDo(dt)   
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight()/2)
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function ThugSkill8:onEnterReleaseDo(state)
    --print("ThugSkill8:onEnterReleaseDo()")
    self._pCurState = state
    
    self:playActionByIndex(3)   -- 播放特效
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    local showRole = function()
        self:getMaster():setVisible(true)
    end
    local action3Time = self:getActionTimeByIndex(3)
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(action3Time*2/3), cc.CallFunc:create(showRole)))
    
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight()/2)
    
end

-- 技能释放状态onExit时技能操作
function ThugSkill8:onExitReleaseDo()
    --print("ThugSkill8:onExitReleaseDo()")
    
    -- 忽略伤害引用计数-1（连应值都不会有）
    self._pMaster._pRefRoleIgnoreHurt:sub()
    self._bIgnoreHurtAdd = false

    -- 恢复普通攻击按钮禁用
    self:getMaster()._refGenAttackButton:sub()
    self._bGenAttackBtnAdd = false

    -- 恢复技能按钮禁用
    for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
        self:getMaster()._tRefSkillButtons[i]:sub()
        self._bSkillBtnAdd[i] = false
    end

end

-- 技能释放状态onUpdate时技能操作
function ThugSkill8:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function ThugSkill8:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    
    -- 检测 相关引用计数
    if self._bStickAdd == true then
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
    end
    if self._bIgnoreHurtAdd == true then
        self:getMaster()._pRefRoleIgnoreHurt:sub()
        self._bIgnoreHurtAdd = false
    end
    if self._bGenAttackBtnAdd == true then
        self:getMaster()._refGenAttackButton:sub()
        self._bGenAttackBtnAdd = false
    end
    for i=1,table.getn(self._bSkillBtnAdd) do
        if self._bSkillBtnAdd[i] == true then
            self:getMaster()._tRefSkillButtons[i]:sub()
            self._bSkillBtnAdd[i] = false
        end
    end
    
end

---------------------------------------------------------------------------------------------------------
return ThugSkill8
