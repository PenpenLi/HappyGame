--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ThugSkill3.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/13
-- descrip:   刺客技能3 【罗天坠】
--===================================================
local ThugSkill3 = class("ThugSkill3",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function ThugSkill3:ctor()
    self._strName = "ThugSkill3"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kThugSkill3               -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态
    
    self._bStickAdd = false                                    -- 引用计数的标记
    self._bIgnoreHurtAdd = false                               -- 引用计数的标记
    self._bGenAttackBtnAdd = false                             -- 引用计数的标记
    self._bSkillBtnAdd = {false,false,false,false}             -- 引用计数的标记
    
    self._tTargetsPos = {}                                     -- 技能锁定的目标的pos
    self._nCurTargetIndex = 1                                  -- 当前技能要击中的目标的index
    self._nMaxTargetsNum = 5                                   -- 可以攻击到的最大目标总数
    
    self._nRoleAttackActionIndex = 7                           -- 角色攻击动作index
    self._fChantDelayTime = 0.45                               -- 吟唱动作持续时间s
    
end

-- 创建函数
function ThugSkill3:create(master, skillInfo)   
    local skill = ThugSkill3.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function ThugSkill3:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitThugSkill3()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function ThugSkill3:onExitThugSkill3()    
    self:onExitSkillObj()
end

-- 循环更新
function ThugSkill3:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function ThugSkill3:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function ThugSkill3:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空 
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else  -- 如果当前技能正处于使用状态，则立即将角色切换回站立状态
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
    end
end

function ThugSkill3:initActionsFrameEvents(index, action)
    if index == 1 then
        local function onFrameEvent1(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent1)
    end
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
function ThugSkill3:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start2" then
    elseif self._strFrameEventName == "hurt2_1" then
        self:setCurAttackFrameEventInfo(2,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
        self:clearCurAttackFrameEventInfo()  
        if self._nCurTargetIndex >= table.getn(self._tTargetsPos) then
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
        else
            self._nCurTargetIndex = self._nCurTargetIndex + 1
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess, true)
        end
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function ThugSkill3:onEnterIdleDo(state)
    --print("ThugSkill3:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function ThugSkill3:onExitIdleDo()
--print("ThugSkill3:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function ThugSkill3:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function ThugSkill3:onEnterChantDo(state)
    --print("ThugSkill3:onEnterChantDo()")
    self._pCurState = state
       
    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)
    
    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)
    
    -- 搜索目标
    self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self)  --刷新方向
    local tTargets = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self:getMaster(), self._pSkillInfo.WarnRange, nil, self._pSkillInfo.TargetGroupType)
    
    -- 记录所有目标的位置
    if table.getn(tTargets) == 0 then
        local offsetY = 70*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = 70*math.cos(math.rad(self:getMaster():getAngle3D()))
        table.insert(self._tTargetsPos,cc.p(self:getMaster():getPositionX()+offsetX, self:getMaster():getPositionY()+offsetY)) 
    else
        for k,v in pairs(tTargets) do
            if k <= self._nMaxTargetsNum then
                table.insert(self._tTargetsPos,cc.p(v.enemy:getPositionX(),v.enemy:getPositionY()))
            else
                break
            end
        end
    end
    self._nCurTargetIndex = 1

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)
        self:getMaster():setVisible(false)
        -- 给技能指定施展时的zorder    
        self._nSettledZorder = kZorder.kMaxSkill
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY)
        self:playActionByIndex(1)
        -- 技能施展音效
        AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
        
        -- 播放第一次的攻击
        local skillAct = function()
            self:setVisible(true)
            self:getMaster():setVisible(false)
            -- 给技能指定施展时的zorder    
            self._nSettledZorder = kZorder.kMaxSkill
            local pos = self._tTargetsPos[self._nCurTargetIndex]
            self:setPosition(pos.x, pos.y)
            self:playActionByIndex(2)
            -- 技能释放音效
            AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)
        end
        self._pSkillActOverActionNode:stopAllActions()
        self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(25*cc.Director:getInstance():getAnimationInterval()+0.1), cc.CallFunc:create(skillAct)))        
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
    
    -- 摇杆禁用
    self:getMaster()._refStick:add()
    self._bStickAdd = true
    self:getMaster()._refStick._nWaitingSkillActOverToSubCount = self:getMaster()._refStick._nWaitingSkillActOverToSubCount + 1
    
    -- 普通攻击按钮禁用
    self:getMaster()._refGenAttackButton:add()
    self._bGenAttackBtnAdd = true
    
    -- 技能按钮禁用
    for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
        self:getMaster()._tRefSkillButtons[i]:add()
        self._bSkillBtnAdd[i] = true
    end
    
    -- 【开始忽略一切伤害】
    self:getMaster()._pRefRoleIgnoreHurt:add()
    self._bIgnoreHurtAdd = true
    
end

-- 技能吟唱状态onExit时技能操作
function ThugSkill3:onExitChantDo()
--print("ThugSkill3:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function ThugSkill3:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function ThugSkill3:onEnterProcessDo(state)
    --print("ThugSkill3:onEnterProcessDo()")
    self._pCurState = state
    
    self:setVisible(true)
    self:getMaster():setVisible(false)
    -- 给技能指定施展时的zorder    
    self._nSettledZorder = kZorder.kMaxSkill
    local pos = self._tTargetsPos[self._nCurTargetIndex]
    self:setPosition(pos.x, pos.y)
    self:playActionByIndex(2)
    
    -- 技能释放音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillReleaseSound)

end

-- 技能执行状态onExit时技能操作
function ThugSkill3:onExitProcessDo()
--print("ThugSkill3:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function ThugSkill3:onUpdateProcessDo(dt)
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function ThugSkill3:onEnterReleaseDo(state)
    --print("ThugSkill3:onEnterReleaseDo()")
    self._pCurState = state
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    
end

-- 技能释放状态onExit时技能操作
function ThugSkill3:onExitReleaseDo()
    --print("ThugSkill3:onExitReleaseDo()")
    
    -- 摇杆解禁
    self:getMaster()._refStick:sub()
    self._bStickAdd = false

    -- 普通攻击按钮恢复
    self:getMaster()._refGenAttackButton:sub()
    self._bGenAttackBtnAdd = false
    
    -- 技能按钮禁用
    for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
        self:getMaster()._tRefSkillButtons[i]:sub()
        self._bSkillBtnAdd[i] = false
    end
    
    -- 【恢复一切伤害】
    self:getMaster()._pRefRoleIgnoreHurt:sub()
    self._bIgnoreHurtAdd = false

end

-- 技能释放状态onUpdate时技能操作
function ThugSkill3:onUpdateReleaseDo(dt)
    
end

-- 技能结束时的复位操作
function ThugSkill3:reset()
    -- 复位给技能指定施展时的zorder
    self._tTargetsPos = {}
    self._nCurTargetIndex = 1
    self:getMaster():setVisible(true)
    -- 技能动作结束，人物即回到站立状态
    if self:getMaster():isUnusualState() == false then     -- 正常状态
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
    end
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()
    
    -- 检测 相关引用计数
    if self._bStickAdd == true then
        self:getMaster()._refStick:sub()
        self._bStickAdd = false
    end
    if self._bIgnoreHurtAdd == true then
        self:getMaster()._pRefRoleIgnoreHurt:sub()
        self._bIgnoreHurtAdd = false
    end
    if self._bGenAttackBtnAdd == true then
        self:getMaster()._refGenAttackButton:sub()
        self._bGenAttackBtnAdd = false
    end
    for i=1,table.getn(self._bSkillBtnAdd) do
        if self._bSkillBtnAdd[i] == true then
            self:getMaster()._tRefSkillButtons[i]:sub()
            self._bSkillBtnAdd[i] = false
        end
    end
    
end

---------------------------------------------------------------------------------------------------------
return ThugSkill3
