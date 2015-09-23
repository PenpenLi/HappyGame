--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetSkill25.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/7/27
-- descrip:   宠物技能攻击25  白骨精
--===================================================
local PetSkill25 = class("PetSkill25",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function PetSkill25:ctor()
    self._strName = "PetSkill25"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kPetSkill25            -- 技能对象类型
    self._pCurState = nil                                       -- 技能当前的状态机状态
    self._nRoleAttackActionIndex = 1                            -- 角色攻击动作index
    self._fChantDelayTime = 0.75                                -- 吟唱动作持续时间s
    
end

-- 创建函数
function PetSkill25:create(master,skillInfo)
    local skill = PetSkill25.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function PetSkill25:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetSkill25()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function PetSkill25:onExitPetSkill25()    
    self:onExitSkillObj()
end

-- 循环更新
function PetSkill25:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function PetSkill25:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end


-- 技能使用接口
function PetSkill25:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空     
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function PetSkill25:initActionsFrameEvents(index, action)

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

--[[
    if index == 2 then
        local f1 = function()
            self._strFrameEventName = "hurt2_1"
        end
        local f2 = function()
            self._strFrameEventName = "end2"
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(f1)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(f2)))
    end
    ]]
    
end

-- 帧事件的处理
function PetSkill25:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "end1" then
    elseif self._strFrameEventName == "start2" then
    elseif self._strFrameEventName == "hurt2_1" then
        self:setCurAttackFrameEventInfo(2,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function PetSkill25:onEnterIdleDo(state)
    self._pCurState = state
    self._pAni:setOpacity(255)
    self._pAni:setScale(1.0)
    self:setVisible(false)
    
end

-- 技能待机状态onExit时技能操作
function PetSkill25:onExitIdleDo()

end

-- 技能待机状态onUpdate时技能操作
function PetSkill25:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function PetSkill25:onEnterChantDo(state)
    self._pCurState = state

    -- 播放攻击时的人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    local skillActOver = function()
        -- 技能动作结束，人物不为特殊状态时即回到站立状态
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kStand)
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
function PetSkill25:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function PetSkill25:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function PetSkill25:onEnterProcessDo(state)
    self._pCurState = state

    self:setVisible(true)
    
    self._nSettledZorder = kZorder.kMaxSkill
    
    -- 方向更新
    self:setRotation(270-(self:getMaster():getAngle3D())) -- 更新特效的rotation
    
    -- 位置更新
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY+self:getMaster():getHeight()/2)

    local flyOutOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end
    local offsetY = self._pSkillInfo.BulletMaxDistance*math.sin(math.rad(self:getMaster():getAngle3D()))
    local offsetX = self._pSkillInfo.BulletMaxDistance*math.cos(math.rad(self:getMaster():getAngle3D()))   
    self:playActionByIndex(1)
    self:stopActionByTag(nSkillFlyActTag) 
    local action = cc.Sequence:create(cc.MoveBy:create(self._pSkillInfo.BulletMaxDistance/self._pSkillInfo.BulletSpeed, cc.p(offsetX,offsetY)), cc.DelayTime:create(0.1), cc.CallFunc:create(flyOutOver))
    action:setTag(nSkillFlyActTag)
    self:runAction(action)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)

end

-- 技能执行状态onExit时技能操作
function PetSkill25:onExitProcessDo()

end

-- 技能执行状态onUpdate时技能操作
function PetSkill25:onUpdateProcessDo(dt)

    self:setCurAttackFrameEventInfo(1,1)
    self._tCurAttackRects = {}
    table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 50, self:getPositionY() - 50, 100, 100))

    local isColliding = self:getAIManager():isRectCollidingOnEnemys(self:getMaster(), self, cc.rect(self:getPositionX() - 50, self:getPositionY() - 50, 100, 100))
    if isColliding == true then
        self:stopActionByTag(nSkillFlyActTag)
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function PetSkill25:onEnterReleaseDo(state)
    self._pCurState = state

    self:setRotation(0)
    self:playActionByIndex(2)

    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
    
end

-- 技能释放状态onExit时技能操作
function PetSkill25:onExitReleaseDo()

end

-- 技能释放状态onUpdate时技能操作
function PetSkill25:onUpdateReleaseDo(dt)

end

---------------------------------------------------------------------------------------------------------
return PetSkill25
