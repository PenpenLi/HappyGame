--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RollHammerSkill.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/5
-- descrip:   旋转锤技能
--===================================================
local RollHammerSkill = class("RollHammerSkill",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function RollHammerSkill:ctor()
    self._strName = "RollHammerSkill"                           -- 技能名称
    self._kTypeID = kType.kSkill.kID.kRollHammerSkill           -- 技能对象类型
    self._pCurState = nil                                       -- 技能当前的状态机状态           
    
end

-- 创建函数
function RollHammerSkill:create(master, skillInfo)   
    local skill = RollHammerSkill.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function RollHammerSkill:dispose()
    ------------------- 初始化 ------------------------ 
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRollHammerSkill()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function RollHammerSkill:onExitRollHammerSkill()    
    self:onExitSkillObj()
end

-- 循环更新
function RollHammerSkill:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function RollHammerSkill:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function RollHammerSkill:onUse(args) 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then      
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function RollHammerSkill:initActionsFrameEvents(index, action)
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
function RollHammerSkill:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start2" then
    elseif self._strFrameEventName == "hurt2_1" then
        self:setCurAttackFrameEventInfo(2,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
        self:clearCurAttackFrameEventInfo()
    end
    self._strFrameEventName = ""
end


-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function RollHammerSkill:onEnterIdleDo(state)
    --print("RollHammerSkill:onEnterIdleDo()")
    self._pCurState = state
    
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight())
    self:playActionByIndex(1)
    
end

-- 技能待机状态onExit时技能操作
function RollHammerSkill:onExitIdleDo()
--print("RollHammerSkill:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function RollHammerSkill:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function RollHammerSkill:onEnterChantDo(state)
    --print("RollHammerSkill:onEnterChantDo()")
    cclog("旋转锤开始旋转！")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)

end

-- 技能吟唱状态onExit时技能操作
function RollHammerSkill:onExitChantDo()
--print("RollHammerSkill:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function RollHammerSkill:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function RollHammerSkill:onEnterProcessDo(state)
    --print("RollHammerSkill:onEnterProcessDo()")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    
end

-- 技能执行状态onExit时技能操作
function RollHammerSkill:onExitProcessDo()
--print("RollHammerSkill:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function RollHammerSkill:onUpdateProcessDo(dt)
    --print("processing......")

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function RollHammerSkill:onEnterReleaseDo(state)
    --print("RollHammerSkill:onEnterReleaseDo()")
    self._pCurState = state
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight())
    self:playActionByIndex(2)
    
    self._nSettledZorder = kZorder.kMaxSkill
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    local IntervalOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        if self:getMaster() then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleEntity):setCurStateByTypeID(kType.kState.kBattleEntity.kNormal)
        end
    end
    self:stopActionByTag(nSkillFlyActTag)
    local act = cc.Sequence:create(cc.DelayTime:create(3.0), cc.CallFunc:create(IntervalOver))
    act:setTag(nSkillFlyActTag)
    self:runAction(act)
    
end

-- 技能释放状态onExit时技能操作
function RollHammerSkill:onExitReleaseDo()
    --print("RollHammerSkill:onExitReleaseDo()")
    
end

-- 技能释放状态onUpdate时技能操作
function RollHammerSkill:onUpdateReleaseDo(dt)
    
end

---------------------------------------------------------------------------------------------------------
return RollHammerSkill
