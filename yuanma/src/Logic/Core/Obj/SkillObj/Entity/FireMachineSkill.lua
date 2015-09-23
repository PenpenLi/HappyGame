--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FireMachineSkill.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/5
-- descrip:   喷火机关技能
--===================================================
local FireMachineSkill = class("FireMachineSkill",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function FireMachineSkill:ctor()
    self._strName = "FireMachineSkill"                           -- 技能名称
    self._kTypeID = kType.kSkill.kID.kFireMachineSkill           -- 技能对象类型
    self._pCurState = nil                                        -- 技能当前的状态机状态
    self._pTarget = nil                                          -- 标准的目标对象
    
end

-- 创建函数
function FireMachineSkill:create(master, skillInfo)   
    local skill = FireMachineSkill.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function FireMachineSkill:dispose()
    ------------------- 初始化 ------------------------ 
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFireMachineSkill()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function FireMachineSkill:onExitFireMachineSkill()    
    self:onExitSkillObj()
end

-- 循环更新
function FireMachineSkill:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function FireMachineSkill:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function FireMachineSkill:onUse(args) 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._pTarget = args.target
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function FireMachineSkill:initActionsFrameEvents(index, action)
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
function FireMachineSkill:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start2" then
    elseif self._strFrameEventName == "hurt2_1" then
        self:setCurAttackFrameEventInfo(2,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function FireMachineSkill:onEnterIdleDo(state)
    --print("FireMachineSkill:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)
    self._pTarget = nil

end

-- 技能待机状态onExit时技能操作
function FireMachineSkill:onExitIdleDo()
--print("FireMachineSkill:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function FireMachineSkill:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function FireMachineSkill:onEnterChantDo(state)
    --print("FireMachineSkill:onEnterChantDo()")
    --cclog("喷火机开炮！")
    
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)

end

-- 技能吟唱状态onExit时技能操作
function FireMachineSkill:onExitChantDo()
--print("FireMachineSkill:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function FireMachineSkill:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function FireMachineSkill:onEnterProcessDo(state)
    --print("FireMachineSkill:onEnterProcessDo()")
    self._pCurState = state
    
    self:setVisible(true)
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY + self:getMaster():getHeight()/3)
    self:playActionByIndex(1)
    
    -- 先确定角度
    local fAttackAngle = mmo.HelpFunc:gAngleAnalyseForRotation(self._pTarget:getPositionX(), self._pTarget:getPositionY() + self._pTarget:getHeight()/2, self:getPositionX(), self:getPositionY())
    self:setRotation(90-fAttackAngle)
    -- 飞行结束的回调
    local flyOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end
    -- 在确定位移
    local offsetY = self._pSkillInfo.BulletMaxDistance*math.sin(math.rad(( (180 + math.abs(math.modf(self:getRotation()-90)) )%360) )) 
    local offsetX = self._pSkillInfo.BulletMaxDistance*math.cos(math.rad(( (180 + math.abs(math.modf(self:getRotation()-90)) )%360) ))    
    self:stopActionByTag(nSkillFlyActTag)
    local act = cc.Sequence:create(cc.MoveBy:create(self._pSkillInfo.BulletMaxDistance/self._pSkillInfo.BulletSpeed, cc.p(offsetX,offsetY)), cc.CallFunc:create(flyOver))
    act:setTag(nSkillFlyActTag)
    self:runAction(act)
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
end

-- 技能执行状态onExit时技能操作
function FireMachineSkill:onExitProcessDo()
--print("FireMachineSkill:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function FireMachineSkill:onUpdateProcessDo(dt)
    --print("processing......")

    local posX, posY = self:getPosition()
    if cc.rectContainsPoint(self._pTarget:getBodyRectInMap(),cc.p(posX, posY)) then
        self:stopActionByTag(nSkillFlyActTag)
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function FireMachineSkill:onEnterReleaseDo(state)
    --print("FireMachineSkill:onEnterReleaseDo()")
    self._pCurState = state

    self:playActionByIndex(2)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
    
    self._nSettledZorder = kZorder.kMaxSkill
    
end

-- 技能释放状态onExit时技能操作
function FireMachineSkill:onExitReleaseDo()
--print("FireMachineSkill:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function FireMachineSkill:onUpdateReleaseDo(dt)
    
end

---------------------------------------------------------------------------------------------------------
return FireMachineSkill
