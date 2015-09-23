--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BombSkill.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/4
-- descrip:   炸弹技能
--===================================================
local BombSkill = class("BombSkill",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function BombSkill:ctor()
    self._strName = "BombSkill"                           -- 技能名称
    self._kTypeID = kType.kSkill.kID.kBombSkill           -- 技能对象类型
    self._pCurState = nil                                 -- 技能当前的状态机状态
    
end

-- 创建函数
function BombSkill:create(master, skillInfo)   
    local skill = BombSkill.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function BombSkill:dispose()
    ------------------- 初始化 ------------------------ 
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBombSkill()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function BombSkill:onExitBombSkill()    
    self:onExitSkillObj()
end

-- 循环更新
function BombSkill:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function BombSkill:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function BombSkill:onUse(args) 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then      
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function BombSkill:initActionsFrameEvents(index, action)
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
function BombSkill:procActionsFrameEvents()
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
function BombSkill:onEnterIdleDo(state)
    --print("BombSkill:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function BombSkill:onExitIdleDo()
--print("BombSkill:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function BombSkill:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function BombSkill:onEnterChantDo(state)
    --print("BombSkill:onEnterChantDo()")
    cclog("炸弹开始引燃爆炸！")
    
    self._pCurState = state
    
    self:getMaster():playOnFireAction()
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    local onFireOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(onFireOver)))

end

-- 技能吟唱状态onExit时技能操作
function BombSkill:onExitChantDo()
--print("BombSkill:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function BombSkill:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function BombSkill:onEnterProcessDo(state)
    --print("BombSkill:onEnterProcessDo()")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    
end

-- 技能执行状态onExit时技能操作
function BombSkill:onExitProcessDo()
--print("BombSkill:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function BombSkill:onUpdateProcessDo(dt)
    --print("processing......")

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function BombSkill:onEnterReleaseDo(state)
    --print("BombSkill:onEnterReleaseDo()")
    self._pCurState = state
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight()/2)
    self:setVisible(true)
    self:playActionByIndex(1)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
    
    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleEntity):setCurStateByTypeID(kType.kState.kBattleEntity.kDestroy)
    
    self._nSettledZorder = kZorder.kMaxSkill
    
end

-- 技能释放状态onExit时技能操作
function BombSkill:onExitReleaseDo()
    --print("BombSkill:onExitReleaseDo()")
    
end

-- 技能释放状态onUpdate时技能操作
function BombSkill:onUpdateReleaseDo(dt)
    
end

---------------------------------------------------------------------------------------------------------
return BombSkill
