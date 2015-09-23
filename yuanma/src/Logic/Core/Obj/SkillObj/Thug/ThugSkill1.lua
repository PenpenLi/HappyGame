--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ThugSkill1.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/24
-- descrip:   刺客技能1 【回旋镖】
--===================================================
local ThugSkill1 = class("ThugSkill1",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function ThugSkill1:ctor()
    self._strName = "ThugSkill1"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kThugSkill1               -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    self._bFlayOutOver = false                                 -- 当前子物体是否已经飞出完毕
    
    self._bStickAdd = false                                    -- 引用计数的标记
    
    self._nRoleAttackActionIndex = 8                           -- 角色攻击动作index
    self._fChantDelayTime = 0.45                               -- 吟唱动作持续时间s
    
end

-- 创建函数
function ThugSkill1:create(master, skillInfo)   
    local skill = ThugSkill1.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function ThugSkill1:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitThugSkill1()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function ThugSkill1:onExitThugSkill1()    
    self:onExitSkillObj()
end

-- 循环更新
function ThugSkill1:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function ThugSkill1:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function ThugSkill1:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
    end
end

-- 初始化动作帧事件回调
function ThugSkill1:initActionsFrameEvents(index, action)
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
function ThugSkill1:procActionsFrameEvents()
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
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function ThugSkill1:onEnterIdleDo(state)
    --print("ThugSkill1:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function ThugSkill1:onExitIdleDo()
--print("ThugSkill1:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function ThugSkill1:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function ThugSkill1:onEnterChantDo(state)
    --print("ThugSkill1:onEnterChantDo()")
    self._pCurState = state
    
    local info = self._pSkillInfo
    
    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)
        -- 给技能指定施展时的zorder    
        if self:getMaster()._kDirection == kDirection.kUp or
            self:getMaster()._kDirection == kDirection.kLeftUp or
            self:getMaster()._kDirection == kDirection.kRightUp then
            self._nSettledZorder = self:getMaster():getLocalZOrder() - 1
        else
            self._nSettledZorder = kZorder.kMaxSkill
        end
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY+40)
        self:playActionByIndex(1)
        self:setScale(0.1)
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
function ThugSkill1:onExitChantDo()
--print("ThugSkill1:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function ThugSkill1:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function ThugSkill1:onEnterProcessDo(state)
    --print("ThugSkill1:onEnterProcessDo()")
    self._pCurState = state
    
    --- 子物体飞回自身位置结束 ------------------------------------------------------------------------------
    local flyOutOver = function()
        self._bFlayOutOver = true
    end
    local offsetY = self._pSkillInfo.BulletMaxDistance*math.sin(math.rad(self:getMaster():getAngle3D()))
    local offsetX = self._pSkillInfo.BulletMaxDistance*math.cos(math.rad(self:getMaster():getAngle3D()))
    self:stopActionByTag(nSkillFlyActTag)
    local action = cc.Spawn:create(cc.Sequence:create(cc.EaseSineOut:create(cc.MoveBy:create(self._pSkillInfo.BulletMaxDistance/self._pSkillInfo.BulletSpeed, cc.p(offsetX,offsetY))), cc.CallFunc:create(flyOutOver)), cc.ScaleTo:create(self._pSkillInfo.BulletMaxDistance/self._pSkillInfo.BulletSpeed/3,1.0,1.0))
    action:setTag(nSkillFlyActTag)
    self:runAction(action)
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
end

-- 技能执行状态onExit时技能操作
function ThugSkill1:onExitProcessDo()
--print("ThugSkill1:onExitProcessDo()")
    self._bFlayOutOver = false
end

-- 技能执行状态onUpdate时技能操作
function ThugSkill1:onUpdateProcessDo(dt)
    if self._bFlayOutOver == true then  -- 回旋镖开始回收   
        -- 每一帧都要刷新主人的位置和自己当前的位置
        local posMasterX, posMasterY = self:getMaster():getPosition()
        local posX, posY = self:getPosition()
        posMasterY = posMasterY + 40

        local intervalX = (posMasterX - posX) / 5
        local intervalY = (posMasterY - posY) / 5
        local intervalScale = (0.1-1.0)/5

        self:setPosition(posX + intervalX, posY + intervalY)
        if self:getScale() + intervalScale < 0.1 then
            self:setScale(0.1)
        else
            self:setScale(self:getScale() + intervalScale)
        end
        
        -- 已经回到主人位置
        if math.abs(intervalX) <= 5 and math.abs(intervalY) <= 5 then
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
        end
        
    end    
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function ThugSkill1:onEnterReleaseDo(state)
    --print("ThugSkill1:onEnterReleaseDo()")
    self._pCurState = state
   
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
end

-- 技能释放状态onExit时技能操作
function ThugSkill1:onExitReleaseDo()
    --print("ThugSkill1:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function ThugSkill1:onUpdateReleaseDo(dt)
    
end

-- 技能结束时的复位操作
function ThugSkill1:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    self:stopActionByIndex(1)
    
    -- 检测 相关引用计数
    if self._bStickAdd == true then
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
    end
    
end

---------------------------------------------------------------------------------------------------------
return ThugSkill1
