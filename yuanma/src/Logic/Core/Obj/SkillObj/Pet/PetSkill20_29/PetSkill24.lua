--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetSkill24.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/7/27
-- descrip:   宠物技能攻击24   玉兔
--===================================================
local PetSkill24 = class("PetSkill24",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function PetSkill24:ctor()
    self._strName = "PetSkill24"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kPetSkill24            -- 技能对象类型
    self._pCurState = nil                                  -- 技能当前的状态机状态
    self._nRoleAttackActionIndex = 3                       -- 角色攻击动作index
    self._fChantDelayTime = 0.42                           -- 吟唱动作持续时间s
    self._fDistance = 100                                  -- 技能距离人物的距离
    
end

-- 创建函数
function PetSkill24:create(master,skillInfo)
    local skill = PetSkill24.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function PetSkill24:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetSkill24()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function PetSkill24:onExitPetSkill24()    
    self:onExitSkillObj()
end

-- 循环更新
function PetSkill24:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function PetSkill24:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end


-- 技能使用接口
function PetSkill24:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空     
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function PetSkill24:initActionsFrameEvents(index, action)
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
function PetSkill24:procActionsFrameEvents()
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
function PetSkill24:onEnterIdleDo(state)
    self._pCurState = state
    self:setVisible(false)
    
end

-- 技能待机状态onExit时技能操作
function PetSkill24:onExitIdleDo()

end

-- 技能待机状态onUpdate时技能操作
function PetSkill24:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function PetSkill24:onEnterChantDo(state)
    self._pCurState = state
    
    -- 播放攻击时的人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    local skillActOver = function()
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
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(skillActOver)))
    

    ---人物吟唱动作播放到一段时间时进入到process阶段---------------------------------------------------------------------------
    local chantOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
    
end

-- 技能吟唱状态onExit时技能操作
function PetSkill24:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function PetSkill24:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function PetSkill24:onEnterProcessDo(state)
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function PetSkill24:onExitProcessDo()

end

-- 技能执行状态onUpdate时技能操作
function PetSkill24:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function PetSkill24:onEnterReleaseDo(state)
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
function PetSkill24:onExitReleaseDo()

end

-- 技能释放状态onUpdate时技能操作
function PetSkill24:onUpdateReleaseDo(dt)

end

---------------------------------------------------------------------------------------------------------
return PetSkill24
