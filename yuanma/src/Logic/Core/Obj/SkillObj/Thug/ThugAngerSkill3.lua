--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ThugAngerSkill3.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/30
-- descrip:   刺客怒气技能3  幻影阵
--===================================================
local ThugAngerSkill3 = class("ThugAngerSkill3",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function ThugAngerSkill3:ctor()
    self._strName = "ThugAngerSkill3"                          -- 技能名称
    self._kTypeID = kType.kSkill.kID.kThugAngerSkill3           -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    self._bIgnoreHurtAdd = false                               -- 引用计数的标记
    
    self._nRoleAttackActionIndex = 10                          -- 角色攻击动作index
    self._fChantDelayTime = 0.45                               -- 吟唱动作持续时间s
    self._nTimes = 0                                           -- 播放的次数
    
end

-- 创建函数
function ThugAngerSkill3:create(master, skillInfo)   
    local skill = ThugAngerSkill3.new(master, skillInfo)
    skill:dispose()
    
    return skill
end

-- 处理函数
function ThugAngerSkill3:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitThugAngerSkill3()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function ThugAngerSkill3:onExitThugAngerSkill3()    
    self:onExitSkillObj()
end

-- 循环更新
function ThugAngerSkill3:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function ThugAngerSkill3:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function ThugAngerSkill3:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
    end
end

-- 初始化动作帧事件回调
function ThugAngerSkill3:initActionsFrameEvents(index, action)
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
function ThugAngerSkill3:procActionsFrameEvents()
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
        self._nTimes = self._nTimes - 1
        if self._nTimes <= 0 then       -- 所有次数用完时，回到待机
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        else
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
        end
    end
    self._strFrameEventName = ""
end


-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function ThugAngerSkill3:onEnterIdleDo(state)
    --print("ThugAngerSkill3:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function ThugAngerSkill3:onExitIdleDo()
--print("ThugAngerSkill3:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function ThugAngerSkill3:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function ThugAngerSkill3:onEnterChantDo(state)
    --print("ThugAngerSkill3:onEnterChantDo()")
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
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
        end
        -- 【恢复忽略一切伤害】
        self:getMaster()._pRefRoleIgnoreHurt:sub()
        self._bIgnoreHurtAdd = false
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
    
    self._nTimes = math.modf(self._pSkillInfo.ExploredDuration) -- 计算特效播放的次数
    
end

-- 技能吟唱状态onExit时技能操作
function ThugAngerSkill3:onExitChantDo()
--print("ThugAngerSkill3:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function ThugAngerSkill3:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function ThugAngerSkill3:onEnterProcessDo(state)
    --print("ThugAngerSkill3:onEnterProcessDo()")
    self._pCurState = state 
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
end

-- 技能执行状态onExit时技能操作
function ThugAngerSkill3:onExitProcessDo()
    --print("ThugAngerSkill3:onExitProcessDo()")   
end

-- 技能执行状态onUpdate时技能操作
function ThugAngerSkill3:onUpdateProcessDo(dt)
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function ThugAngerSkill3:onEnterReleaseDo(state)
    --print("ThugAngerSkill3:onEnterReleaseDo()")
    self._pCurState = state
 
    self:setVisible(true)
    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill

    -- 搜索目标
    self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self)  --刷新方向
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
function ThugAngerSkill3:onExitReleaseDo()
    --print("ThugAngerSkill3:onExitReleaseDo()")
    
end

-- 技能释放状态onUpdate时技能操作
function ThugAngerSkill3:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function ThugAngerSkill3:reset()
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
return ThugAngerSkill3
