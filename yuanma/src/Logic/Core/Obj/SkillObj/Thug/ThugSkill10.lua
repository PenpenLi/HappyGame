--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ThugSkill10.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/16
-- descrip:   刺客技能10 【八方刃】
--===================================================
local ThugSkill10 = class("ThugSkill10",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function ThugSkill10:ctor()
    self._strName = "ThugSkill10"                              -- 技能名称
    self._kTypeID = kType.kSkill.kID.kThugSkill10              -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    
    self._posTargetsPos = nil                                  -- 目标位置
    self._nRoleAttackActionIndex = 9                           -- 角色攻击动作index
    self._fChantDelayTime = 0.2                               -- 吟唱动作持续时间s

end

-- 创建函数
function ThugSkill10:create(master, skillInfo)   
    local skill = ThugSkill10.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function ThugSkill10:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitThugSkill10()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function ThugSkill10:onExitThugSkill10()    
    self:onExitSkillObj()
end

-- 循环更新
function ThugSkill10:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function ThugSkill10:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function ThugSkill10:onUse() 
    -- test
    -- cc.Director:getInstance():getScheduler():setTimeScale(0.3)
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        if self:getMaster()._kRoleType == kType.kRole.kPlayer then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)          
        elseif self:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
        end
    end
end

-- 初始化动作帧事件回调
function ThugSkill10:initActionsFrameEvents(index, action)
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
function ThugSkill10:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        local rectNum = 10
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 1*offsetX/5 - 40, self:getPositionY() - 1*offsetY/5 - 40, 80, 80))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 0*offsetX/5 - 80, self:getPositionY() - 0*offsetY/5 - 80, 160, 160))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + 1*offsetX/5 - 100, self:getPositionY() + 1*offsetY/5 - 100, 200, 200))
        for i=1,rectNum do
            local rectTmp = cc.rect(self:getPositionX() + offsetX*i/(rectNum) - 40*i/2, self:getPositionY() + offsetY*i/(rectNum) - 40*i/2, 40*i, 40*i)
            table.insert(self._tCurAttackRects,rectTmp)
        end
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_2" then
        self:setCurAttackFrameEventInfo(1,2)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        local rectNum = 10
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 1*offsetX/5 - 40, self:getPositionY() - 1*offsetY/5 - 40, 80, 80))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 0*offsetX/5 - 80, self:getPositionY() - 0*offsetY/5 - 80, 160, 160))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + 1*offsetX/5 - 100, self:getPositionY() + 1*offsetY/5 - 100, 200, 200))
        for i=1,rectNum do
            local rectTmp = cc.rect(self:getPositionX() + offsetX*i/(rectNum) - 40*i/2, self:getPositionY() + offsetY*i/(rectNum) - 40*i/2, 40*i, 40*i)
            table.insert(self._tCurAttackRects,rectTmp)
        end
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_3" then
        self:setCurAttackFrameEventInfo(1,3)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        local rectNum = 10
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 1*offsetX/5 - 40, self:getPositionY() - 1*offsetY/5 - 40, 80, 80))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() - 0*offsetX/5 - 80, self:getPositionY() - 0*offsetY/5 - 80, 160, 160))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + 1*offsetX/5 - 100, self:getPositionY() + 1*offsetY/5 - 100, 200, 200))
        for i=1,rectNum do
            local rectTmp = cc.rect(self:getPositionX() + offsetX*i/(rectNum) - 40*i/2, self:getPositionY() + offsetY*i/(rectNum) - 40*i/2, 40*i, 40*i)
            table.insert(self._tCurAttackRects,rectTmp)
        end
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function ThugSkill10:onEnterIdleDo(state)
    --print("ThugSkill10:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function ThugSkill10:onExitIdleDo()
--print("ThugSkill10:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function ThugSkill10:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function ThugSkill10:onEnterChantDo(state)
    --print("ThugSkill10:onEnterChantDo()")
    self._pCurState = state

    local info = self._pSkillInfo

    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)
        local posX, posY = self:getMaster():getPosition()
        local offsetY = 80*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = 130*math.cos(math.rad(self:getMaster():getAngle3D()))
        self:setPosition(posX + offsetX, posY + offsetY + self:getMaster():getHeight()/2)        
        self:playActionByIndex(1)   -- 播放特效
        self:setRotation(270-(self:getMaster():getAngle3D())) -- 更新特效的rotation

        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

    local skillActOver = function()
        -- 摇杆解禁
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
        if self:getMaster():isUnusualState() == false then     -- 正常状态
            if self:getMaster()._kRoleType == kType.kRole.kPlayer then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)          
            elseif self:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
            end
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
function ThugSkill10:onExitChantDo()
--print("ThugSkill10:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function ThugSkill10:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function ThugSkill10:onEnterProcessDo(state)
    --print("ThugSkill10:onEnterProcessDo()")
    self._pCurState = state

    -- 给技能指定施展时的zorder    
    if self:getMaster()._kDirection == kDirection.kUp or
        self:getMaster()._kDirection == kDirection.kLeftUp or
        self:getMaster()._kDirection == kDirection.kRightUp then
        self._nSettledZorder = self:getMaster():getLocalZOrder() - 1
    else
        self._nSettledZorder = kZorder.kMaxSkill
    end
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)

    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function ThugSkill10:onExitProcessDo()
--print("ThugSkill10:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function ThugSkill10:onUpdateProcessDo(dt)   

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function ThugSkill10:onEnterReleaseDo(state)
    --print("ThugSkill10:onEnterReleaseDo()")
    self._pCurState = state

end

-- 技能释放状态onExit时技能操作
function ThugSkill10:onExitReleaseDo()
    --print("ThugSkill10:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function ThugSkill10:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function ThugSkill10:reset()
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
return ThugSkill10
