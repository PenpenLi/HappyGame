--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SpikeRockSkill.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/5
-- descrip:   地刺技能
--===================================================
local SpikeRockSkill = class("SpikeRockSkill",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function SpikeRockSkill:ctor()
    self._strName = "SpikeRockSkill"                           -- 技能名称
    self._kTypeID = kType.kSkill.kID.kSpikeRockSkill           -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
end

-- 创建函数
function SpikeRockSkill:create(master, skillInfo)   
    local skill = SpikeRockSkill.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function SpikeRockSkill:dispose()
    ------------------- 初始化 ------------------------ 
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSpikeRockSkill()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function SpikeRockSkill:onExitSpikeRockSkill()    
    self:onExitSkillObj()
end

-- 循环更新
function SpikeRockSkill:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function SpikeRockSkill:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function SpikeRockSkill:onUse(args) 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then      
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function SpikeRockSkill:initActionsFrameEvents(index, action)
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
function SpikeRockSkill:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function SpikeRockSkill:onEnterIdleDo(state)
    --print("SpikeRockSkill:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function SpikeRockSkill:onExitIdleDo()
--print("SpikeRockSkill:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function SpikeRockSkill:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function SpikeRockSkill:onEnterChantDo(state)
    --print("SpikeRockSkill:onEnterChantDo()")
    cclog("地刺开始攻击！")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)

end

-- 技能吟唱状态onExit时技能操作
function SpikeRockSkill:onExitChantDo()
--print("SpikeRockSkill:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function SpikeRockSkill:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function SpikeRockSkill:onEnterProcessDo(state)
    --print("SpikeRockSkill:onEnterProcessDo()")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    
end

-- 技能执行状态onExit时技能操作
function SpikeRockSkill:onExitProcessDo()
--print("SpikeRockSkill:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function SpikeRockSkill:onUpdateProcessDo(dt)
    --print("processing......")

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function SpikeRockSkill:onEnterReleaseDo(state)
    --print("SpikeRockSkill:onEnterReleaseDo()")
    self._pCurState = state
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY - 1)
    self:setVisible(true)
    self:playActionByIndex(1)
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    local playOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        if self:getMaster() then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleEntity):setCurStateByTypeID(kType.kState.kBattleEntity.kNormal)
        end
    end
    local duration = self:getActionTimeByIndex(1)
    self:stopActionByTag(nSkillFlyActTag)
    local act = cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(playOver))
    act:setTag(nSkillFlyActTag)
    self:runAction(act)
    
end

-- 技能释放状态onExit时技能操作
function SpikeRockSkill:onExitReleaseDo()
    --print("SpikeRockSkill:onExitReleaseDo()")
    
end

-- 技能释放状态onUpdate时技能操作
function SpikeRockSkill:onUpdateReleaseDo(dt)
    
end

---------------------------------------------------------------------------------------------------------
return SpikeRockSkill
