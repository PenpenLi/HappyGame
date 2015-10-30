--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonsterSkill62.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/20
-- descrip:   怪物技能攻击62  妲己
--===================================================
local MonsterSkill62 = class("MonsterSkill62",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MonsterSkill62:ctor()
    self._strName = "MonsterSkill62"                              -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMonsterSkill62              -- 技能对象类型
    self._pCurState = nil                                         -- 技能当前的状态机状态
    
    self._posTargetsPos = nil                                     -- 目标位置
    self._nRoleAttackActionIndex = 1                              -- 角色攻击动作index
    self._fChantDelayTime = 0.5                                   -- 吟唱动作持续时间s

end

-- 创建函数
function MonsterSkill62:create(master, skillInfo)   
    local skill = MonsterSkill62.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MonsterSkill62:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMonsterSkill62()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function MonsterSkill62:onExitMonsterSkill62()    
    self:onExitSkillObj()
end

-- 循环更新
function MonsterSkill62:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MonsterSkill62:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function MonsterSkill62:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空     
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end

end

-- 初始化动作帧事件回调
function MonsterSkill62:initActionsFrameEvents(index, action)
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
function MonsterSkill62:procActionsFrameEvents()
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
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
    
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function MonsterSkill62:onEnterIdleDo(state)
    --print("MonsterSkill62:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function MonsterSkill62:onExitIdleDo()
--print("MonsterSkill62:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function MonsterSkill62:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MonsterSkill62:onEnterChantDo(state)
    --print("MonsterSkill62:onEnterChantDo()")
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
function MonsterSkill62:onExitChantDo()
--print("MonsterSkill62:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function MonsterSkill62:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MonsterSkill62:onEnterProcessDo(state)
    --print("MonsterSkill62:onEnterProcessDo()")
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
function MonsterSkill62:onExitProcessDo()
--print("MonsterSkill62:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function MonsterSkill62:onUpdateProcessDo(dt)   

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MonsterSkill62:onEnterReleaseDo(state)
    --print("MonsterSkill62:onEnterReleaseDo()")
    self._pCurState = state

    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)

end

-- 技能释放状态onExit时技能操作
function MonsterSkill62:onExitReleaseDo()
    --print("MonsterSkill62:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function MonsterSkill62:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function MonsterSkill62:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    
end

---------------------------------------------------------------------------------------------------------
return MonsterSkill62
