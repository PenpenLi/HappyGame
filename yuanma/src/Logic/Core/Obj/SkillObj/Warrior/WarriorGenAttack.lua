--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WarriorGenAttack.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/7/2
-- descrip:   战士普通攻击（连击）
--===================================================
local WarriorGenAttack = class("WarriorGenAttack",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function WarriorGenAttack:ctor()
    self._strName = "WarriorGenAttack"                         -- 技能名称
    self._kTypeID = kType.kSkill.kID.kWarriorGenAttack         -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态    
    self._fRoleActDuration = 0                                 -- 角色攻击动作的持续时间
    self._tComboDelay = {0.05,0.1,0.1,0.1,0.31,0.90}           -- 特效出现延时
    self._tComboDistance = {100,100,0,0,150,50}                -- 特效距离人物中心的距离
    self._nComboIndex = 1                                      -- 连击index (最多6连击)
    self._fComboIndexBuff = 1                                  -- 缓存连击index
    self._fComboIntervalCounter = 0                            -- 连击间隔计数器
    
end

-- 创建函数
function WarriorGenAttack:create(master, skillInfo)
    local skill = WarriorGenAttack.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function WarriorGenAttack:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWarriorGenAttack()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function WarriorGenAttack:onExitWarriorGenAttack()    
    self:onExitSkillObj()
end

-- 循环更新
function WarriorGenAttack:update(dt)
    self:updateSkillObj(dt)
    
    if self._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
        self._fComboIntervalCounter = self._fComboIntervalCounter + dt
    end

end

-- 创建状态机
function WarriorGenAttack:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function WarriorGenAttack:onUse() 
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
function WarriorGenAttack:initActionsFrameEvents(index, action)
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
function WarriorGenAttack:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
        --print("技能特效结束！")
        self:clearCurAttackFrameEventInfo()

        if self:getMaster()._kRoleType == kType.kRole.kPlayer and self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        else
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
    elseif self._strFrameEventName == "end2" then
       -- print("技能特效结束！")
        self:clearCurAttackFrameEventInfo()           
        
        if self:getMaster()._kRoleType == kType.kRole.kPlayer and self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        else
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
    elseif self._strFrameEventName == "end3" then
       -- print("技能特效结束！")
        self:clearCurAttackFrameEventInfo()
        
        if self:getMaster()._kRoleType == kType.kRole.kPlayer and self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        else
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
    elseif self._strFrameEventName == "end4" then
        --print("技能特效结束！")
        self:clearCurAttackFrameEventInfo()
        
        if self:getMaster()._kRoleType == kType.kRole.kPlayer and self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        else
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
    elseif self._strFrameEventName == "end5" then
        --print("技能特效结束！")
        self:clearCurAttackFrameEventInfo()
        
        if self:getMaster()._kRoleType == kType.kRole.kPlayer and self:getMaster()._strCharTag == "main" then
            -- 如果当前正在长按攻击按钮，则自动关联下一击
            -- 如果当前属于自动攻击模式且摇杆非工作模式，则自动关联下一击
            local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
            if pUILayer then
                if pUILayer._bIsTouchingGenAttackButton == true or (self:getBattleManager()._bIsAutoBattle == true and pUILayer._pStick:getIsWorking() == false ) then
                    self._fComboIndexBuff = self._nComboIndex + 1
                end
            end
        else
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
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt6_2" then
        self:setCurAttackFrameEventInfo(6,2)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "hurt6_3" then
        self:setCurAttackFrameEventInfo(6,3)
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._tCurAttackRects = {}
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        table.insert(self._tCurAttackRects, cc.rect(self:getPositionX() + offsetX - 100, self:getPositionY() + offsetY - 100, 200, 200))
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end6" then
        --print("技能特效结束！")
        self:clearCurAttackFrameEventInfo()
    end

    self._strFrameEventName = ""  
end
-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function WarriorGenAttack:onEnterIdleDo(state)
    --print("WarriorGenAttack:onEnterIdleDo()")
    self._pCurState = state
    
    self:setVisible(false)
    self._nComboIndex = 1
    self._fComboIndexBuff = 1
    self._fComboIntervalCounter = 0
    
    self:setRotation(0) -- 更新特效的rotation
    
    -- 技能结束后复位，人物重新回到站立状态
    if self:getMaster():isUnusualState() == false then
        if self:getMaster()._kRoleType == kType.kRole.kPlayer then
            if self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kSkillAttack and 
               self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kAngerAttack and
               self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kRun then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
            end            
        elseif self:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
            if self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole)._pCurState._kTypeID ~= kType.kState.kBattleOtherPlayerRole.kSkillAttack and 
               self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole)._pCurState._kTypeID ~= kType.kState.kBattleOtherPlayerRole.kAngerAttack and
               self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole)._pCurState._kTypeID ~= kType.kState.kBattleOtherPlayerRole.kRun then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
            end
        elseif self:getMaster()._kRoleType == kType.kRole.kFriend then
            if self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole)._pCurState._kTypeID ~= kType.kState.kBattleFriendRole.kSkillAttack and 
               self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole)._pCurState._kTypeID ~= kType.kState.kBattleFriendRole.kRun and
               self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole)._pCurState._kTypeID ~= kType.kState.kBattleFriendRole.kSuspend and
               self._pMaster:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole)._pCurState._kTypeID ~= kType.kState.kBattleFriendRole.kDisAppear then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kStand)
            end 
        end

    end

end

-- 技能待机状态onExit时技能操作
function WarriorGenAttack:onExitIdleDo()
--print("WarriorGenAttack:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function WarriorGenAttack:onUpdateIdleDo(dt)
end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function WarriorGenAttack:onEnterChantDo(state)
    --print("WarriorGenAttack:onEnterChantDo()")
    self._pCurState = state

    self._nComboIndex = self._fComboIndexBuff
    self._fComboIntervalCounter = 0
    
    -- 播放连击时的人物动作
    self:getMaster():playAttackAction(self._nComboIndex)
    
    -- 记录人物动作时间
    self._fRoleActDuration = self:getMaster():getAttackActionTime(self._nComboIndex)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._tComboDelay[self._nComboIndex]), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

end

-- 技能吟唱状态onExit时技能操作
function WarriorGenAttack:onExitChantDo()
    --print("WarriorGenAttack:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function WarriorGenAttack:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function WarriorGenAttack:onEnterProcessDo(state)
    --print("WarriorGenAttack:onEnterProcessDo()")
    self._pCurState = state
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function WarriorGenAttack:onExitProcessDo()
    --print("WarriorGenAttack:onExitProcessDo()")
end

-- 技能执行状态onUpdate时技能操作
function WarriorGenAttack:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function WarriorGenAttack:onEnterReleaseDo(state)
    --print("WarriorGenAttack:onEnterReleaseDo()")

    self._pCurState = state
    -- 给技能指定施展时的zorder
    if self._nComboIndex == 1 or self._nComboIndex == 2 or self._nComboIndex == 5 then
        if self:getMaster()._kDirection == kDirection.kUp or
            self:getMaster()._kDirection == kDirection.kLeftUp or
            self:getMaster()._kDirection == kDirection.kRightUp then
            self._nSettledZorder = self:getMaster():getLocalZOrder() - 1
        else
            self._nSettledZorder = kZorder.kMaxSkill
        end
    else
        self._nSettledZorder = kZorder.kMaxSkill
    end

    -- 自动转向
    self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
    -- 播放技能特效
    self:playActionByIndex(self._nComboIndex)
    
    self:setVisible(true)
    
    -- 位置刷新
    if self._nComboIndex == 1 or self._nComboIndex == 2 or self._nComboIndex == 5 then
        local offsetY = self._tComboDistance[self._nComboIndex]*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._tComboDistance[self._nComboIndex]*math.cos(math.rad(self:getMaster():getAngle3D()))
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX + offsetX, posY + offsetY)
    elseif self._nComboIndex == 6 then
        local flyOutOver = function()
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
        self:setRotation(270-(self:getMaster():getAngle3D())) -- 更新特效的rotation
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)
        local offsetY = self._pSkillInfo.BulletMaxDistance*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.BulletMaxDistance*math.cos(math.rad(self:getMaster():getAngle3D()))   
        self:stopActionByTag(nSkillFlyActTag)
        local act = cc.Sequence:create(cc.EaseIn:create(cc.MoveBy:create(self._pSkillInfo.BulletMaxDistance/self._pSkillInfo.BulletSpeed, cc.p(offsetX,offsetY)),2), cc.CallFunc:create(flyOutOver))
        act:setTag(nSkillFlyActTag)
        self:runAction(act)
    else
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY)
    end
    
    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
end

-- 技能释放状态onExit时技能操作
function WarriorGenAttack:onExitReleaseDo()
    --print("WarriorGenAttack:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function WarriorGenAttack:onUpdateReleaseDo(dt)

end


---------------------------------------------------------------------------------------------------------

return WarriorGenAttack
