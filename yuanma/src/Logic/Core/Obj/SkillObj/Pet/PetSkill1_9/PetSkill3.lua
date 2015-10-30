--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetSkill3.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/7/24
-- descrip:   宠物技能攻击3   红孩儿
--===================================================
local PetSkill3 = class("PetSkill3",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function PetSkill3:ctor()
    self._strName = "PetSkill3"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kPetSkill3            -- 技能对象类型
    self._pCurState = nil                                  -- 技能当前的状态机状态
    self._posTargetsPos = nil                              -- 目标位置
    self._nRoleAttackActionIndex = 3                       -- 角色攻击动作index
    self._fChantDelayTime = 1.0                            -- 吟唱动作持续时间s
    
end

-- 创建函数
function PetSkill3:create(master,skillInfo)
    local skill = PetSkill3.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function PetSkill3:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetSkill3()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function PetSkill3:onExitPetSkill3()    
    self:onExitSkillObj()
end

-- 循环更新
function PetSkill3:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function PetSkill3:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end


-- 技能使用接口
function PetSkill3:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function PetSkill3:initActionsFrameEvents(index, action)
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
function PetSkill3:procActionsFrameEvents()
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
    elseif self._strFrameEventName == "hurt1_6" then
        self:setCurAttackFrameEventInfo(1,6)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_7" then
        self:setCurAttackFrameEventInfo(1,7)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function PetSkill3:onEnterIdleDo(state)
    --print("PetSkill3:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)
    
end

-- 技能待机状态onExit时技能操作
function PetSkill3:onExitIdleDo()
--print("PetSkill3:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function PetSkill3:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function PetSkill3:onEnterChantDo(state)
    self._pCurState = state

    -- 播放攻击时的人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    -- 人物动作结束
    local roleActOver = function()        
        -- 技能动作结束，人物不为特殊状态时即回到站立状态
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            if self:getMaster()._kRoleType == kType.kRole.kPet then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kStand)               
            elseif self:getMaster()._kRoleType == kType.kRole.kOtherPet then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kStand)
            end
        end
    end
    local duration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(roleActOver)))

    ---人物吟唱动作播放到一段时间时进入到process阶段---------------------------------------------------------------------------
    local chantOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
    
end

-- 技能吟唱状态onExit时技能操作
function PetSkill3:onExitChantDo()
--print("PetSkill3:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function PetSkill3:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function PetSkill3:onEnterProcessDo(state)
    --print("PetSkill3:onEnterProcessDo()")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function PetSkill3:onExitProcessDo()
--print("PetSkill3:onExitProcessDo()")
end

-- 技能执行状态onUpdate时技能操作
function PetSkill3:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function PetSkill3:onEnterReleaseDo(state)
    --print("PetSkill3:onEnterReleaseDo()")
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

    -- 搜索目标
    local tTargets = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self:getMaster(), self._pSkillInfo.WarnRange, nil, self._pSkillInfo.TargetGroupType)
    -- 记录所有目标的位置
    if table.getn(tTargets) == 0 then
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._posTargetsPos = cc.p(self:getMaster():getPositionX()+offsetX, self:getMaster():getPositionY()+offsetY)
    else
        self._posTargetsPos = cc.p(tTargets[1].enemy:getPositionX(),tTargets[1].enemy:getPositionY())
    end
    self:setPosition(cc.p(self._posTargetsPos.x, self._posTargetsPos.y))
    self:playActionByIndex(1)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
    
end

-- 技能释放状态onExit时技能操作
function PetSkill3:onExitReleaseDo()
--print("PetSkill3:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function PetSkill3:onUpdateReleaseDo(dt)

end

---------------------------------------------------------------------------------------------------------
return PetSkill3
