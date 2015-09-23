--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ThugSkill2.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/10
-- descrip:   刺客技能2 【连影杀】
--===================================================
local ThugSkill2 = class("ThugSkill2",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function ThugSkill2:ctor()
    self._strName = "ThugSkill2"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kThugSkill2               -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    
    self._nCurTimes = 0                                        -- 一共放三次
    self._nDisInterval = 60                                    -- 特效每次出现时在WarnRange的正负_nDisInterval像素内的位置上
    self._nStartRotation3D = 0                                 -- 起始时的master角度
    
    self._nRoleAttackActionIndex = 7                           -- 角色攻击动作index
    self._fChantDelayTime = 0.45                               -- 吟唱动作持续时间s

end

-- 创建函数
function ThugSkill2:create(master, skillInfo)   
    local skill = ThugSkill2.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function ThugSkill2:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitThugSkill2()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function ThugSkill2:onExitThugSkill2()    
    self:onExitSkillObj()
end

-- 循环更新
function ThugSkill2:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function ThugSkill2:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function ThugSkill2:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
    end
end

function ThugSkill2:initActionsFrameEvents(index, action)
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
function ThugSkill2:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._nCurTimes = self._nCurTimes + 1
        if self._nCurTimes >= 3 then -- 达到3次，立即回到idle状态
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        else -- 未达到3次，继续播放
            self:playActionByIndex(1)
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
        end
    end
    self._strFrameEventName = ""
end


-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function ThugSkill2:onEnterIdleDo(state)
    --print("ThugSkill2:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function ThugSkill2:onExitIdleDo()
--print("ThugSkill2:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function ThugSkill2:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function ThugSkill2:onEnterChantDo(state)
    --print("ThugSkill2:onEnterChantDo()")
    self._pCurState = state
    
    -- 获得master的初始角度
    self._nStartRotation3D = self:getMaster():getAngle3D()
    
    local info = self._pSkillInfo
    
    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)        
        self:playActionByIndex(1)
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
function ThugSkill2:onExitChantDo()
--print("ThugSkill2:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function ThugSkill2:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function ThugSkill2:onEnterProcessDo(state)
    --print("ThugSkill2:onEnterProcessDo()")
    self._pCurState = state
    
    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill
    
    local offsetY = ( self._pSkillInfo.WarnRange + getRandomNumBetween(1,self._nDisInterval) )*math.sin(math.rad(self._nStartRotation3D))
    local offsetX = ( self._pSkillInfo.WarnRange + getRandomNumBetween(1,self._nDisInterval) )*math.cos(math.rad(self._nStartRotation3D))
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX + offsetX, posY + 30 + offsetY)
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    
end

-- 技能执行状态onExit时技能操作
function ThugSkill2:onExitProcessDo()
--print("ThugSkill2:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function ThugSkill2:onUpdateProcessDo(dt)   
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function ThugSkill2:onEnterReleaseDo(state)
    --print("ThugSkill2:onEnterReleaseDo()")
    self._pCurState = state
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
    
end

-- 技能释放状态onExit时技能操作
function ThugSkill2:onExitReleaseDo()
    --print("ThugSkill2:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function ThugSkill2:onUpdateReleaseDo(dt)
    
end

-- 技能结束时的复位操作
function ThugSkill2:reset()
    -- 复位给技能指定施展时的zorder
    if self._nCurTimes >= 3 then -- 达到3次，清空为0
        self._nCurTimes = 0
    end
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    
    -- 检测 相关引用计数
    if self._bStickAdd == true then
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
    end
    
end

---------------------------------------------------------------------------------------------------------
return ThugSkill2
