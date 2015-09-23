--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MageSkill4.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/11
-- descrip:   人鱼技能4 【守身冰、护身雷、焚身火 】
--===================================================
local MageSkill4 = class("MageSkill4",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MageSkill4:ctor()
    self._strName = "MageSkill4"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMageSkill4               -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    self._bIgnoreHurtAdd = false                               -- 引用计数的标记
    
    self._nRoleAttackActionIndex = 7                           -- 角色攻击动作index
    self._fChantDelayTime = 0.4                                -- 吟唱动作持续时间s

end

-- 创建函数
function MageSkill4:create(master, skillInfo)   
    local skill = MageSkill4.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MageSkill4:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMageSkill4()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function MageSkill4:onExitMageSkill4()
    self:onExitSkillObj()
end

-- 循环更新
function MageSkill4:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MageSkill4:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function MageSkill4:onUse() 
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

-- 初始化动作帧事件回调
function MageSkill4:initActionsFrameEvents(index, action)
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
function MageSkill4:procActionsFrameEvents()
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
function MageSkill4:onEnterIdleDo(state)
    --print("MageSkill4:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function MageSkill4:onExitIdleDo()
--print("MageSkill4:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function MageSkill4:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MageSkill4:onEnterChantDo(state)
    --print("MageSkill4:onEnterChantDo()")
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
function MageSkill4:onExitChantDo()
--print("MageSkill4:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function MageSkill4:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MageSkill4:onEnterProcessDo(state)
    --print("MageSkill4:onEnterProcessDo()")
    self._pCurState = state
    
    self:setVisible(true)
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight()/2)
    self:playActionByIndex(1)   -- 播放特效
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill

    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function MageSkill4:onExitProcessDo()
--print("MageSkill4:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function MageSkill4:onUpdateProcessDo(dt)   

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MageSkill4:onEnterReleaseDo(state)
    --print("MageSkill4:onEnterReleaseDo()")
    self._pCurState = state

end

-- 技能释放状态onExit时技能操作
function MageSkill4:onExitReleaseDo()
    --print("MageSkill4:onExitReleaseDo()")
    -- 忽略伤害引用计数-1（连应值都不会有）
    self._pMaster._pRefRoleIgnoreHurt:sub()
    self._bIgnoreHurtAdd = false

end

-- 技能释放状态onUpdate时技能操作
function MageSkill4:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function MageSkill4:reset()
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
    
end

---------------------------------------------------------------------------------------------------------
return MageSkill4
