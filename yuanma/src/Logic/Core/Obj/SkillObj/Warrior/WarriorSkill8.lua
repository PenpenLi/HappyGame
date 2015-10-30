--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WarriorSkill8.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/10
-- descrip:   战士技能8 【炎螺旋】
--===================================================
local WarriorSkill8 = class("WarriorSkill8",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function WarriorSkill8:ctor()
    self._strName = "WarriorSkill8"                               -- 技能名称
    self._kTypeID = kType.kSkill.kID.kWarriorSkill8               -- 技能对象类型
    self._pCurState = nil                                         -- 技能当前的状态机状态
    self._kDirectionBak = nil                                     -- 技能释放前的方向
    self._kAngle3DBak = nil                                       -- 技能释放前的角度        
    
    self._bSkillBtnAdd = {false,false,false,false}                -- 引用计数的标记
    self._bGenAttackBtnAdd = false                                -- 引用计数的标记

    self._nRoleAttackActionIndex = 10                             -- 角色攻击动作index
    self._fChantDelayTime = 0.1                                   -- 吟唱动作持续时间s

end

-- 创建函数
function WarriorSkill8:create(master, skillInfo)   
    local skill = WarriorSkill8.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function WarriorSkill8:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWarriorSkill8()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function WarriorSkill8:onExitWarriorSkill8()    
    self:onExitSkillObj()
end

-- 循环更新
function WarriorSkill8:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function WarriorSkill8:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function WarriorSkill8:onUse() 
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
function WarriorSkill8:initActionsFrameEvents(index, action)
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
function WarriorSkill8:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt1_2" then
        self:setCurAttackFrameEventInfo(1,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
    end
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function WarriorSkill8:onEnterIdleDo(state)
    --print("WarriorSkill8:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)
    self:setScaleY(0.7)

end

-- 技能待机状态onExit时技能操作
function WarriorSkill8:onExitIdleDo()
--print("WarriorSkill8:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function WarriorSkill8:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function WarriorSkill8:onEnterChantDo(state)
    --print("WarriorSkill8:onEnterChantDo()")
    self._pCurState = state

    -- 播放人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    -- 技能吼叫音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillRoarVoice)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self:setVisible(true)
        self:playActionByIndex(1)   -- 播放特效

        -- 技能施展音效
        AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
        
        -- 特效位置
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY)
        
        -- 备份技能释放前的方向和角度
        self._kDirectionBak = self:getMaster()._kDirection
        self._kAngle3DBak = self:getMaster():getAngle3D()
        
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)

    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._fChantDelayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
    
    -- 普通攻击按钮禁用
    self:getMaster()._refGenAttackButton:add()
    self._bGenAttackBtnAdd = true

    -- 技能按钮禁用
    for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
        self:getMaster()._tRefSkillButtons[i]:add()
        self._bSkillBtnAdd[i] = true
    end

end

-- 技能吟唱状态onExit时技能操作
function WarriorSkill8:onExitChantDo()
--print("WarriorSkill8:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function WarriorSkill8:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function WarriorSkill8:onEnterProcessDo(state)
    --print("WarriorSkill8:onEnterProcessDo()")
    self._pCurState = state

    -- 给技能指定施展时的zorder
    self._nSettledZorder = kZorder.kMaxSkill
    
    ---process结束------------------------------------------------------------------------------
    local processOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._pSkillInfo.ExploredDuration), cc.CallFunc:create(processOver)))

end

-- 技能执行状态onExit时技能操作
function WarriorSkill8:onExitProcessDo()
--print("WarriorSkill8:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function WarriorSkill8:onUpdateProcessDo(dt)
    if self:getMaster()._kRoleType == kType.kRole.kPlayer and self:getMaster()._strCharTag == "main" then
        local bIsStickWorking = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getIsWorking()
        if bIsStickWorking == true then -- 摇杆中ing
            self:getMaster()._kDirection = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getDirection()
            self:getMaster():setAngle3D(cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getAngle())
            local direction = self:getMaster()._kDirection
            local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
            local fSpeed = self:getMaster()._nCurSpeed
            local sTileSize = self:getMapManager()._sTiledPixelSize
            if direction == kDirection.kUp then
                posRole.y = posRole.y + fSpeed*dt/1.414
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kUp) == kDirection.kUp then
                    return
                end
            elseif direction == kDirection.kDown then
                posRole.y = posRole.y - fSpeed*dt/1.414
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kDown) == kDirection.kDown then
                    return
                end
            elseif direction == kDirection.kLeft then
                posRole.x = posRole.x - fSpeed*dt
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kLeft) == kDirection.kLeft then
                    return
                end
            elseif direction == kDirection.kRight then
                posRole.x = posRole.x + fSpeed*dt
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kRight) == kDirection.kRight then
                    return
                end
            elseif direction == kDirection.kLeftUp then
                posRole.x = posRole.x - fSpeed*dt/1.414
                posRole.y = posRole.y + fSpeed*dt/2
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kLeftUp) == kDirection.kLeftUp then
                    return
                end
            elseif direction == kDirection.kLeftDown then
                posRole.x = posRole.x - fSpeed*dt/1.414
                posRole.y = posRole.y - fSpeed*dt/2
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kLeftDown) == kDirection.kLeftDown then
                    return
                end
            elseif direction == kDirection.kRightUp then
                posRole.x = posRole.x + fSpeed*dt/1.414
                posRole.y = posRole.y + fSpeed*dt/2
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kRightUp) == kDirection.kRightUp then
                    return
                end
            elseif direction == kDirection.kRightDown then
                posRole.x = posRole.x + fSpeed*dt/1.414
                posRole.y = posRole.y - fSpeed*dt/2
                local directions = self:getMaster():detecCollisionBottomOnBottomsByDetecPos(posRole, true)
                if mmo.HelpFunc:bitAnd(directions,kDirection.kRightDown) == kDirection.kRightDown then
                    return
                end
            end

            if posRole.x >= self:getMapManager()._sMapRectPixelSize.width - sTileSize.width/2 then
                posRole.x = self:getMapManager()._sMapRectPixelSize.width - sTileSize.width/2
            elseif posRole.x <= sTileSize.width/2 then
                posRole.x = sTileSize.width/2
            end

            if posRole.y >= self:getMapManager()._sMapRectPixelSize.height - sTileSize.height/2 then
                posRole.y = self:getMapManager()._sMapRectPixelSize.height - sTileSize.height/2
            elseif posRole.y <= sTileSize.height/2 then
                posRole.y = sTileSize.height/2
            end
            self:getMaster():setPosition(posRole)        
        end
    end

    -- 特效位置
    local posX, posY = self:getMaster():getPosition()
    self:setPosition(posX, posY)
    
end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function WarriorSkill8:onEnterReleaseDo(state)
    --print("WarriorSkill8:onEnterReleaseDo()")
    self._pCurState = state
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)

    if self:getMaster():isUnusualState() == false then     -- 正常状态
        if self:getMaster()._kRoleType == kType.kRole.kPlayer then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)          
        elseif self:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
        end
    end
    
end

-- 技能释放状态onExit时技能操作
function WarriorSkill8:onExitReleaseDo()
    --print("WarriorSkill8:onExitReleaseDo()")

    -- 恢复普通攻击按钮禁用
    self:getMaster()._refGenAttackButton:sub()
    self._bGenAttackBtnAdd = false

    -- 恢复技能按钮禁用
    for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
        self:getMaster()._tRefSkillButtons[i]:sub()
        self._bSkillBtnAdd[i] = false
    end

    self:getMaster()._kDirection = self._kDirectionBak
    self:getMaster():setAngle3D(self._kAngle3DBak)

    self._kDirectionBak = nil
    self._kAngle3DBak = nil  

end

-- 技能释放状态onUpdate时技能操作
function WarriorSkill8:onUpdateReleaseDo(dt)

end

-- 技能结束时的复位操作
function WarriorSkill8:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self:clearCurAttackFrameEventInfo()   

    -- 检测 相关引用计数
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
return WarriorSkill8
