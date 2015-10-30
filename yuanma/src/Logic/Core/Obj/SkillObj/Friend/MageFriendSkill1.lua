--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MageFriendSkill1.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/14
-- descrip:   好友技能1 【法师】
--===================================================
local MageFriendSkill1 = class("MageFriendSkill1",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MageFriendSkill1:ctor()
    self._strName = "MageFriendSkill1"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMageFriendSkill1               -- 技能对象类型
    self._pCurState = nil                                               -- 技能当前的状态机状态
    self._posTargetsPos = nil                                           -- 目标位置
    self._nRoleAttackActionIndex = 5                                    -- 角色攻击动作index
    self._fChantDelayTime = 0.45                                        -- 吟唱动作持续时间s

end

-- 创建函数
function MageFriendSkill1:create(master, skillInfo)   
    local skill = MageFriendSkill1.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MageFriendSkill1:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMageFriendSkill1()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function MageFriendSkill1:onExitMageFriendSkill1()    
    self:onExitSkillObj()
end

-- 循环更新
function MageFriendSkill1:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MageFriendSkill1:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function MageFriendSkill1:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function MageFriendSkill1:initActionsFrameEvents(index, action)
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
function MageFriendSkill1:procActionsFrameEvents()
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
function MageFriendSkill1:onEnterIdleDo(state)
    --print("MageFriendSkill1:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function MageFriendSkill1:onExitIdleDo()
--print("MageFriendSkill1:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function MageFriendSkill1:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MageFriendSkill1:onEnterChantDo(state)
    --print("MageFriendSkill1:onEnterChantDo()")
    self._pCurState = state
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
    
    local actOver = function()
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kStand)
    end
    local duration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(actOver)))

end

-- 技能吟唱状态onExit时技能操作
function MageFriendSkill1:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function MageFriendSkill1:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MageFriendSkill1:onEnterProcessDo(state)

    self._pCurState = state

    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill

    self:setVisible(true)

    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function MageFriendSkill1:onExitProcessDo()
--print("MageFriendSkill1:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function MageFriendSkill1:onUpdateProcessDo(dt)   

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MageFriendSkill1:onEnterReleaseDo(state)
    --print("MageFriendSkill1:onEnterReleaseDo()")
    self._pCurState = state
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
    
    -- 播放动画
    self:playActionByIndex(1)
    
    -- 搜索目标
    self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self)-- 刷新方向
    local tTargets = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self:getMaster(), self._pSkillInfo.WarnRange, nil, self._pSkillInfo.TargetGroupType)
    if table.getn(tTargets) == 0 then
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._posTargetsPos = cc.p(self:getMaster():getPositionX()+offsetX, self:getMaster():getPositionY()+offsetY)
    else
        self._posTargetsPos = cc.p(tTargets[1].enemy:getPositionX(),tTargets[1].enemy:getPositionY())
    end
    self:setPosition(cc.p(self._posTargetsPos.x, self._posTargetsPos.y))
    
    -- 播放结束后切换状态
    local skillOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)     -- 技能回到idle空闲状态
    end
    local duration = self:getActionTimeByIndex(1)
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(skillOver)))  -- 0.1秒动作后放出技能  
    

end

-- 技能释放状态onExit时技能操作
function MageFriendSkill1:onExitReleaseDo()
    --print("MageFriendSkill1:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function MageFriendSkill1:onUpdateReleaseDo(dt)

end

---------------------------------------------------------------------------------------------------------
return MageFriendSkill1
