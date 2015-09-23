--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ThugGenAttack.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/8
-- descrip:   刺客普通攻击（连击）
--===================================================
local ThugGenAttack = class("ThugGenAttack",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function ThugGenAttack:ctor()
    self._strName = "ThugGenAttack"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kThugGenAttack            -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态    
    self._fRoleActDuration = 0                                 -- 角色攻击动作的持续时间
    self._tComboDistance = {250,30,50,65,65,50}                -- 连击位移
    self._nComboIndex = 1                                      -- 连击index (最多6连击)
    self._fComboIndexBuff = 1                                  -- 缓存连击index
    self._fComboIntervalCounter = 0                            -- 连击间隔计数器
    
end

-- 创建函数
function ThugGenAttack:create(master, skillInfo)
    local skill = ThugGenAttack.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function ThugGenAttack:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitThugGenAttack()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function ThugGenAttack:onExitThugGenAttack()    
    self:onExitSkillObj()
end

-- 循环更新
function ThugGenAttack:update(dt)
    self:updateSkillObj(dt)
    
    if self._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
        self._fComboIntervalCounter = self._fComboIntervalCounter + dt
    end

end

-- 创建状态机
function ThugGenAttack:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function ThugGenAttack:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else
        if self._fComboIntervalCounter >= self._fRoleActDuration/2 and self._fComboIndexBuff == self._nComboIndex and 
            self._nComboIndex < 6 then
            -- 记录缓存连击
            self._fComboIndexBuff = self._nComboIndex + 1
            --print("接收连击处理！")
        end
    end
end

-- 初始化动作帧事件回调
function ThugGenAttack:initActionsFrameEvents(index, action)
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
    
    if index == 3 then
        local function onFrameEvent3(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent3)
    end
    
    if index == 4 then
        local function onFrameEvent4(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent4)
    end
    
    if index == 5 then
        local function onFrameEvent5(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent5)
    end
    
    if index == 6 then
        local function onFrameEvent6(frame)
            if nil == frame then
                return
            end
            self._strFrameEventName = frame:getEvent()
        end
        action:setFrameEventCallFunc(onFrameEvent6)
    end

end

-- 帧事件的处理
function ThugGenAttack:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
        --self:getActionManager():pauseAllRunningActions()
    elseif self._strFrameEventName == "end1" then
        self:clearCurAttackFrameEventInfo()
        if self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        elseif self:getMaster()._strCharTag == "pvp" then
            self._fComboIndexBuff = self._nComboIndex + 1                
        end
        if self._fComboIndexBuff == self._nComboIndex + 1 and self:getMaster():isUnusualState() == false then  -- 有缓存，且不为特殊状态
            -- print("开始"..self._fComboIndexBuff.."连击")
            -- 玩家角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
            self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
        else
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
    elseif self._strFrameEventName == "start2" then
    elseif self._strFrameEventName == "hurt2_1" then
        self:setCurAttackFrameEventInfo(2,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt2_2" then
        self:setCurAttackFrameEventInfo(2,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
        self:clearCurAttackFrameEventInfo()           
        if self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        elseif self:getMaster()._strCharTag == "pvp" then
            self._fComboIndexBuff = self._nComboIndex + 1                
        end
        if self._fComboIndexBuff == self._nComboIndex + 1 and self:getMaster():isUnusualState() == false then  -- 有缓存，且不为特殊状态
            -- print("开始"..self._fComboIndexBuff.."连击")
            -- 玩家角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
            self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
        else
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
    elseif self._strFrameEventName == "start3" then
    elseif self._strFrameEventName == "hurt3_1" then
        self:setCurAttackFrameEventInfo(3,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt3_2" then
        self:setCurAttackFrameEventInfo(3,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt3_3" then
        self:setCurAttackFrameEventInfo(3,3)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end3" then
        self:clearCurAttackFrameEventInfo()
        if self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        elseif self:getMaster()._strCharTag == "pvp" then
            self._fComboIndexBuff = self._nComboIndex + 1
        end
        if self._fComboIndexBuff == self._nComboIndex + 1 and self:getMaster():isUnusualState() == false then  -- 有缓存，且不为特殊状态
            -- print("开始"..self._fComboIndexBuff.."连击")
            -- 玩家角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
            self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
        else
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
    elseif self._strFrameEventName == "start4" then
    elseif self._strFrameEventName == "hurt4_1" then
        self:setCurAttackFrameEventInfo(4,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt4_2" then
        self:setCurAttackFrameEventInfo(4,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt4_3" then
        self:setCurAttackFrameEventInfo(4,3)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end4" then
        self:clearCurAttackFrameEventInfo()
        if self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        elseif self:getMaster()._strCharTag == "pvp" then
            self._fComboIndexBuff = self._nComboIndex + 1
        end
        if self._fComboIndexBuff == self._nComboIndex + 1 and self:getMaster():isUnusualState() == false then  -- 有缓存，且不为特殊状态
            -- print("开始"..self._fComboIndexBuff.."连击")
            -- 玩家角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
            self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
        else
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
    elseif self._strFrameEventName == "start5" then
    elseif self._strFrameEventName == "hurt5_1" then
        self:setCurAttackFrameEventInfo(5,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt5_2" then
        self:setCurAttackFrameEventInfo(5,2)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt5_3" then
        self:setCurAttackFrameEventInfo(5,3)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt5_4" then
        self:setCurAttackFrameEventInfo(5,4)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end5" then
        self:clearCurAttackFrameEventInfo()
        if self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        elseif self:getMaster()._strCharTag == "pvp" then
            self._fComboIndexBuff = self._nComboIndex + 1
        end
        if self._fComboIndexBuff == self._nComboIndex + 1 and self:getMaster():isUnusualState() == false then  -- 有缓存，且不为特殊状态
            -- print("开始"..self._fComboIndexBuff.."连击")
            -- 玩家角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
            self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
        else
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
    elseif self._strFrameEventName == "start6" then
    elseif self._strFrameEventName == "hurt6_1" then
        self:setCurAttackFrameEventInfo(6,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end6" then
        self:clearCurAttackFrameEventInfo()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""   
end

-- 发生攻击位移
-- 技能冲刺发生位移时，检测前方是否有障碍，如果有障碍，修正实际可冲刺的位移数据
function ThugGenAttack:AttackOffset()
    local rect = self:getMaster():getBottomRectInMap() 
    local toX = rect.x
    local toY = rect.y
    local width = rect.width
    local height = rect.height
    local direction = self:getMaster()._kDirection
    local offset = 0
    local test = 37
    
    local tmpOffsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
    local tmpOffsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))
    
    if self:getMaster()._strCharTag == "main" then
        while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false and
              self:getMonstersManager():isRectCollidingOnCurWaveMonstersBottoms(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false and 
              self:getRolesManager():isRectCollidingOnPvpPlayerBottoms(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false do
            offset = offset + test
            if offset >= self._tComboDistance[self._nComboIndex] then
                break
            end
            tmpOffsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
            tmpOffsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))
        end
    elseif self:getMaster()._strCharTag == "pvp" then
        while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false and
            self:getRolesManager():isRectCollidingOnMainPlayerBottoms(cc.rect(toX + tmpOffsetX,toY + tmpOffsetY, width, height)) == false do
            offset = offset + test
            if offset >= self._tComboDistance[self._nComboIndex] then
                break
            end
            tmpOffsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
            tmpOffsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))
        end
    end   

    if offset <= test then
        offset = test  -- 保证下面做差以后为0
    end
    offset = offset - test

    -- 发生位移
    local offsetY = offset*math.sin(math.rad(self:getMaster():getAngle3D()))
    local offsetX = offset*math.cos(math.rad(self:getMaster():getAngle3D()))
    self:getMaster():stopActionByTag(nRoleShootAheadTag)
    local act = cc.EaseSineInOut:create(cc.MoveBy:create(self._fRoleActDuration/3,cc.p(offsetX,offsetY)))
    act:setTag(nRoleShootAheadTag)
    self:getMaster():runAction(act)
    
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function ThugGenAttack:onEnterIdleDo(state)
    --print("ThugGenAttack:onEnterIdleDo()")
    self._pCurState = state
    
    self:setVisible(false)
    self._nComboIndex = 1
    self._fComboIndexBuff = 1
    self._fComboIntervalCounter = 0
    
    -- 技能结束后复位，人物重新回到站立状态
    if self:getMaster():isUnusualState() == false then
        if self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kSkillAttack and 
           self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kAngerAttack and
           self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kRun then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
        end
    end

end

-- 技能待机状态onExit时技能操作
function ThugGenAttack:onExitIdleDo()
--print("ThugGenAttack:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function ThugGenAttack:onUpdateIdleDo(dt)
end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function ThugGenAttack:onEnterChantDo(state)
    --print("ThugGenAttack:onEnterChantDo()")
    self._pCurState = state

    
    self._nComboIndex = self._fComboIndexBuff
    self._fComboIntervalCounter = 0
    
    -- 播放连击时的人物动作
    self:getMaster():playAttackAction(self._nComboIndex)
    
    -- 记录人物动作时间
    self._fRoleActDuration = self:getMaster():getAttackActionTime(self._nComboIndex)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        --print("人物吟唱结束！")
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    local delayTime = 0.1
    if self._nComboIndex == 6 then
        delayTime = 0.4
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  
          
    -- 发生位移
    local targetsInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(),self)
    if table.getn(targetInWarning) ~= 0 then
        self:AttackOffset()
    end  

end

-- 技能吟唱状态onExit时技能操作
function ThugGenAttack:onExitChantDo()
    --print("ThugGenAttack:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function ThugGenAttack:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function ThugGenAttack:onEnterProcessDo(state)
    --print("ThugGenAttack:onEnterProcessDo()")
    self._pCurState = state
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function ThugGenAttack:onExitProcessDo()
    --print("ThugGenAttack:onExitProcessDo()")
end

-- 技能执行状态onUpdate时技能操作
function ThugGenAttack:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function ThugGenAttack:onEnterReleaseDo(state)
    --print("ThugGenAttack:onEnterReleaseDo()")

    self._pCurState = state
    -- 给技能指定施展时的zorder    
    if self:getMaster()._kDirection == kDirection.kUp or
        self:getMaster()._kDirection == kDirection.kLeftUp or
        self:getMaster()._kDirection == kDirection.kRightUp then
         self._nSettledZorder = self:getMaster():getLocalZOrder() - 1
    else
         self._nSettledZorder = kZorder.kMaxSkill
    end
    
    -- 自动转向
    self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
    -- 播放技能特效
    self:playActionByIndex(self._nComboIndex)
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    self:setVisible(true)
    
end

-- 技能释放状态onExit时技能操作
function ThugGenAttack:onExitReleaseDo()
    --print("ThugGenAttack:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function ThugGenAttack:onUpdateReleaseDo(dt)
    if self._nComboIndex == 4 or self._nComboIndex == 5 then
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + 60)
    else
        local offsetY = 50*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = 50*math.cos(math.rad(self:getMaster():getAngle3D()))
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX + offsetX, posY + 30 + offsetY)
    end

end

-- 技能结束时的复位操作
function ThugGenAttack:reset()
    -- 复位给技能指定施展时的zorder
    self._nSettledZorder = nil
    self._strFrameEventName = ""

    -- 如果角色是以非正常状态结束的攻击行为，则清空所有连击数据
    if self:getMaster():isUnusualState() == true then
        self._nComboIndex = 1
        self._fComboIndexBuff = 1
        self._fComboIntervalCounter = 0
    end
end

---------------------------------------------------------------------------------------------------------

return ThugGenAttack
