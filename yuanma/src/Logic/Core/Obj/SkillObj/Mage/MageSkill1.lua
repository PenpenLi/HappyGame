--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MageSkill1.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/5
-- descrip:   人鱼技能1 【道法·凝冰】
--===================================================
local MageSkill1 = class("MageSkill1",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MageSkill1:ctor()
    self._strName = "MageSkill1"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMageSkill1               -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    
    self._posTargetsPos = nil                                  -- 目标位置
    self._nRoleAttackActionIndex = 6                           -- 角色攻击动作index
    self._fChantDelayTime = 0.2                                -- 吟唱动作持续时间s

end

-- 创建函数
function MageSkill1:create(master, skillInfo)   
    local skill = MageSkill1.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MageSkill1:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMageSkill1()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function MageSkill1:onExitMageSkill1()    
    self:onExitSkillObj()
end

-- 循环更新
function MageSkill1:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MageSkill1:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function MageSkill1:onUse() 
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
function MageSkill1:initActionsFrameEvents(index, action)
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
function MageSkill1:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "end1" then
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    elseif self._strFrameEventName == "start2" then
    elseif self._strFrameEventName == "end2" then
    elseif self._strFrameEventName == "start3" then
    elseif self._strFrameEventName == "hurt3_1" then
        self:setCurAttackFrameEventInfo(3,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end3" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function MageSkill1:onEnterIdleDo(state)
    --print("MageSkill1:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)    

end

-- 技能待机状态onExit时技能操作
function MageSkill1:onExitIdleDo()
--print("MageSkill1:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function MageSkill1:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MageSkill1:onEnterChantDo(state)
    --print("MageSkill1:onEnterChantDo()")
    self._pCurState = state
    
    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)
    
    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)
        self:playActionByIndex(1)
        -- 位置更新
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)
        -- 方向更新
        self:setRotation(270-(self:getMaster():getAngle3D())) -- 更新特效的rotation        
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

    local skillActOver = function()
        -- 摇杆解禁
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
        -- 技能动作结束，人物即回到站立状态
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
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
function MageSkill1:onExitChantDo()
--print("MageSkill1:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function MageSkill1:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MageSkill1:onEnterProcessDo(state)
    --print("MageSkill1:onEnterProcessDo()")
    self._pCurState = state
    
    self:playActionByIndex(2)
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    local flyOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end
    local offsetY = self._pSkillInfo.BulletMaxDistance*math.sin(math.rad(self:getMaster():getAngle3D()))
    local offsetX = self._pSkillInfo.BulletMaxDistance*math.cos(math.rad(self:getMaster():getAngle3D()))
    self:stopActionByTag(nSkillFlyActTag)  
    local action = cc.Sequence:create(cc.MoveBy:create(self._pSkillInfo.BulletMaxDistance/self._pSkillInfo.BulletSpeed, cc.p(offsetX,offsetY)), cc.CallFunc:create(flyOver))
    action:setTag(nSkillFlyActTag)
    self:runAction(action)

end

-- 技能执行状态onExit时技能操作
function MageSkill1:onExitProcessDo()
--print("MageSkill1:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function MageSkill1:onUpdateProcessDo(dt)
    local posX, posY = self:getPosition()
    local isColliding = self:getAIManager():isPointCollidingOnEnemys(self:getMaster(), self, cc.p(posX,posY))
    if isColliding == true then
        self:stopActionByTag(nSkillFlyActTag)
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MageSkill1:onEnterReleaseDo(state)
    --print("MageSkill1:onEnterReleaseDo()")
    self._pCurState = state
    
    self:playActionByIndex(3)
    self:setRotation(0)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)

end

-- 技能释放状态onExit时技能操作
function MageSkill1:onExitReleaseDo()
    --print("MageSkill1:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function MageSkill1:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function MageSkill1:reset()
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
return MageSkill1
