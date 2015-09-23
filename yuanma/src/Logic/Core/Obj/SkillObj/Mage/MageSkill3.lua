--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MageSkill3.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/5
-- descrip:   人鱼技能3 【道法·烈焰】
--===================================================
local MageSkill3 = class("MageSkill3",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MageSkill3:ctor()
    self._strName = "MageSkill3"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMageSkill3               -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    
    self._posTargetsPos = nil                                  -- 目标位置
    self._nRoleAttackActionIndex = 6                           -- 角色攻击动作index
    self._fChantDelayTime = 0.35                                -- 吟唱动作持续时间s

end

-- 创建函数
function MageSkill3:create(master, skillInfo)   
    local skill = MageSkill3.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MageSkill3:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMageSkill3()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function MageSkill3:onExitMageSkill3()    
    self:onExitSkillObj()
end

-- 循环更新
function MageSkill3:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MageSkill3:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function MageSkill3:onUse() 
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
function MageSkill3:initActionsFrameEvents(index, action)
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
function MageSkill3:procActionsFrameEvents()
    if self._strFrameEventName == "" then
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

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function MageSkill3:onEnterIdleDo(state)
    --print("MageSkill3:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)    

end

-- 技能待机状态onExit时技能操作
function MageSkill3:onExitIdleDo()
--print("MageSkill3:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function MageSkill3:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MageSkill3:onEnterChantDo(state)
    --print("MageSkill3:onEnterChantDo()")
    self._pCurState = state

    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill

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
function MageSkill3:onExitChantDo()
--print("MageSkill3:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function MageSkill3:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MageSkill3:onEnterProcessDo(state)
    --print("MageSkill3:onEnterProcessDo()")
    self._pCurState = state

    self:playActionByIndex(1)
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)

    -- 位置更新
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight()/2)
    -- 方向更新
    self:setRotation(270-(self:getMaster():getAngle3D())) -- 更新特效的rotation   

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
function MageSkill3:onExitProcessDo()
--print("MageSkill3:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function MageSkill3:onUpdateProcessDo(dt)

    self:setCurAttackFrameEventInfo(1,1)
    self._tCurAttackRects = {}
    table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 40, self:getPositionY() - 40, 80, 80))

    local isColliding = self:getAIManager():isRectCollidingOnEnemys(self:getMaster(), self, cc.rect(self:getPositionX() - 40, self:getPositionY() - 40, 80, 80))
    if isColliding == true then
        self:stopActionByTag(nSkillFlyActTag)  
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MageSkill3:onEnterReleaseDo(state)
    --print("MageSkill3:onEnterReleaseDo()")
    self._pCurState = state

    self:playActionByIndex(2)
    self:setRotation(0)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)

end

-- 技能释放状态onExit时技能操作
function MageSkill3:onExitReleaseDo()
    --print("MageSkill3:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function MageSkill3:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function MageSkill3:reset()
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
return MageSkill3
