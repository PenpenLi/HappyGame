--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonsterSkill63.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/20
-- descrip:   怪物技能攻击63  妲己
--===================================================
local MonsterSkill63 = class("MonsterSkill63",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MonsterSkill63:ctor()
    self._strName = "MonsterSkill63"                              -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMonsterSkill63              -- 技能对象类型
    self._pCurState = nil                                         -- 技能当前的状态机状态
    
    self._posTargetsPos = nil                                     -- 目标位置
    self._nRoleAttackActionIndex = 2                              -- 角色攻击动作index
    self._fChantDelayTime = 0.5                                   -- 吟唱动作持续时间s

end

-- 创建函数
function MonsterSkill63:create(master, skillInfo)   
    local skill = MonsterSkill63.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MonsterSkill63:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMonsterSkill63()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function MonsterSkill63:onExitMonsterSkill63()    
    self:onExitSkillObj()
end

-- 循环更新
function MonsterSkill63:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MonsterSkill63:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function MonsterSkill63:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空     
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end

end

-- 初始化动作帧事件回调
function MonsterSkill63:initActionsFrameEvents(index, action)
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
function MonsterSkill63:procActionsFrameEvents()
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
    elseif self._strFrameEventName == "hurt1_4" then
        self:setCurAttackFrameEventInfo(1,4)
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
function MonsterSkill63:onEnterIdleDo(state)
    --print("MonsterSkill63:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function MonsterSkill63:onExitIdleDo()
--print("MonsterSkill63:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function MonsterSkill63:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MonsterSkill63:onEnterChantDo(state)
    --print("MonsterSkill63:onEnterChantDo()")
    self._pCurState = state

    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    local skillActOver = function()
        -- 人物动作结束后，可以开始释放下一个技能
        if self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID == kType.kState.kBattleMonster.kSkillAttack then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._bToNextSkill = true
        end
    end
    local duration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(skillActOver)))
    
    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)        
        self:playActionByIndex(1)   -- 播放特效
        self:setRotation(270-(self:getMaster():getAngle3D())) -- 更新特效的rotation
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

end

-- 技能吟唱状态onExit时技能操作
function MonsterSkill63:onExitChantDo()
--print("MonsterSkill63:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function MonsterSkill63:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MonsterSkill63:onEnterProcessDo(state)
    --print("MonsterSkill63:onEnterProcessDo()")
    self._pCurState = state

    -- 给技能指定施展时的zorder    
    if self:getMaster()._kDirection == kDirection.kUp or
        self:getMaster()._kDirection == kDirection.kLeftUp or
        self:getMaster()._kDirection == kDirection.kRightUp then
        self._nSettledZorder = self:getMaster():getLocalZOrder() - 1
    else
        self._nSettledZorder = kZorder.kMaxSkill
    end

    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function MonsterSkill63:onExitProcessDo()
--print("MonsterSkill63:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function MonsterSkill63:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MonsterSkill63:onEnterReleaseDo(state)
    --print("MonsterSkill63:onEnterReleaseDo()")
    self._pCurState = state

    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)

end

-- 技能释放状态onExit时技能操作
function MonsterSkill63:onExitReleaseDo()
    --print("MonsterSkill63:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function MonsterSkill63:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function MonsterSkill63:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    
end

---------------------------------------------------------------------------------------------------------
return MonsterSkill63
