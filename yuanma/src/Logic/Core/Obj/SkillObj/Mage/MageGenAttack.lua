--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MageGenAttack.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/4
-- descrip:  人鱼普通攻击（连击）
--===================================================
local MageGenAttack = class("MageGenAttack",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MageGenAttack:ctor()
    self._strName = "MageGenAttack"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMageGenAttack            -- 技能对象类型
    self._pCurState = nil                                      -- 技能当前的状态机状态    
    self._fRoleActDuration = 0                                 -- 角色攻击动作的持续时间
    self._nComboIndex = 1                                      -- 连击index (最多4连击)
    self._fComboIndexBuff = 1                                  -- 缓存连击index
    self._fComboIntervalCounter = 0                            -- 连击间隔计数器
    self._pTargetsPos = nil                                    -- 第一击的目标位置
    self._tDelayTime = {0.1,0.1,0.1,0.1}                       -- 起手延时时间（4个值）
    
end

-- 创建函数
function MageGenAttack:create(master, skillInfo)
    local skill = MageGenAttack.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MageGenAttack:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMageGenAttack()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function MageGenAttack:onExitMageGenAttack()    
    self:onExitSkillObj()
end

-- 循环更新
function MageGenAttack:update(dt)
    self:updateSkillObj(dt)
    
    if self._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
        self._fComboIntervalCounter = self._fComboIntervalCounter + dt
    end

end

-- 创建状态机
function MageGenAttack:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function MageGenAttack:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    else
        if self._fComboIntervalCounter >= self._fRoleActDuration/2 and self._fComboIndexBuff == self._nComboIndex and 
            self._nComboIndex < 4 then
            -- 记录缓存连击
            self._fComboIndexBuff = self._nComboIndex + 1
            --print("接收连击处理！")
        end
    end
end

-- 初始化动作帧事件回调
function MageGenAttack:initActionsFrameEvents(index, action)   

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

--[[
    if index == 1 then
        local f1 = function()
            self._strFrameEventName = "hurt1_1"
        end
        local f2 = function()
            self._strFrameEventName = "end1"
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(f1)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(f2)))   
    end
    
    if index == 2 then
        local f1 = function()
            self._strFrameEventName = "hurt2_1"
        end
        local f2 = function()
            self._strFrameEventName = "hurt2_2"
        end
        local f3 = function()
            self._strFrameEventName = "hurt2_3"
        end
        local f4 = function()
            self._strFrameEventName = "end2"
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(f1)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(f2)))  
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(f3)))  
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(f4)))   
    end
    
    if index == 3 then
        local f1 = function()
            self._strFrameEventName = "hurt3_1"
        end
        local f2 = function()
            self._strFrameEventName = "hurt3_2"
        end
        local f3 = function()
            self._strFrameEventName = "end3"
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(f1)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(f2)))  
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(f3)))   
    end
    
    if index == 4 then
        local f1 = function()
            self._strFrameEventName = "hurt4_1"
        end
        local f2 = function()
            self._strFrameEventName = "hurt4_2"
        end
        local f3 = function()
            self._strFrameEventName = "hurt4_3"
        end
        local f4 = function()
            self._strFrameEventName = "end4"
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(f1)))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(f2)))  
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(f3)))  
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(f4)))   
    end
    
    ]]
    
    
end

-- 帧事件的处理
function MageGenAttack:procActionsFrameEvents()
    if self._strFrameEventName == "" then
    elseif self._strFrameEventName == "start1" then
    elseif self._strFrameEventName == "hurt1_1" then
        self:setCurAttackFrameEventInfo(1,1)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end1" then
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
            -- 角色搜索警戒范围内的目标，并根据目标的方位自动转向
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
    elseif self._strFrameEventName == "hurt2_3" then
        self:setCurAttackFrameEventInfo(2,3)
        self:getAIManager():skillCollidingOnEnemysAndHurt(self:getMaster(), self)
    elseif self._strFrameEventName == "end2" then
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
            -- 角色搜索警戒范围内的目标，并根据目标的方位自动转向
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
    elseif self._strFrameEventName == "end3" then
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
            -- 角色搜索警戒范围内的目标，并根据目标的方位自动转向
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

        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    end
    self._strFrameEventName = ""
       
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function MageGenAttack:onEnterIdleDo(state)
    --print("MageGenAttack:onEnterIdleDo()")
    self._pCurState = state
    
    -- 法师需要显示自己的武器
    if self:getMaster()._pWeaponR then
        self:getMaster()._pWeaponR:setVisible(true)
    end
    if self:getMaster()._pWeaponL then
        self:getMaster()._pWeaponL:setVisible(true)
    end
    
    self:setVisible(false)
    self._nComboIndex = 1
    self._fComboIndexBuff = 1
    self._fComboIntervalCounter = 0
    
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
function MageGenAttack:onExitIdleDo()
--print("MageGenAttack:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function MageGenAttack:onUpdateIdleDo(dt)
end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MageGenAttack:onEnterChantDo(state)
    --print("MageGenAttack:onEnterChantDo()")
    self._pCurState = state

    self._nComboIndex = self._fComboIndexBuff
    self._fComboIntervalCounter = 0
    
    -- 播放连击时的人物动作
    self:getMaster():playAttackAction(self._nComboIndex)
    
    -- 法师需要隐藏自己的武器
    if self:getMaster()._pWeaponR then
        self:getMaster()._pWeaponR:setVisible(false)
    end
    if self:getMaster()._pWeaponL then
        self:getMaster()._pWeaponL:setVisible(false)
    end
    
    -- 搜索目标
    local tTargets = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self:getMaster(), self._pSkillInfo.WarnRange, nil, self._pSkillInfo.TargetGroupType)
    -- 记录所有目标的位置
    if table.getn(tTargets) == 0 then
        local offsetY = self._pSkillInfo.WarnRange*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.WarnRange*math.cos(math.rad(self:getMaster():getAngle3D()))
        self._pTargetsPos = cc.p(self:getMaster():getPositionX()+offsetX, self:getMaster():getPositionY()+offsetY)
    else
        self._pTargetsPos = cc.p(tTargets[1].enemy:getPositionX(),tTargets[1].enemy:getPositionY())
    end
    
    -- 记录人物动作时间
    self._fRoleActDuration = self:getMaster():getAttackActionTime(self._nComboIndex)

    ---人物吟唱动作播放到一段时间时进入到process阶段------------------------------------------------------------------------------
    local chantOver = function()
        --print("人物吟唱结束！")
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    end
    self._pChantOverActionNode:stopAllActions()
    self._pChantOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(self._tDelayTime[self._nComboIndex]), cc.CallFunc:create(chantOver)))  -- 0.1秒动作后放出技能  

end

-- 技能吟唱状态onExit时技能操作
function MageGenAttack:onExitChantDo()
    --print("MageGenAttack:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function MageGenAttack:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MageGenAttack:onEnterProcessDo(state)
    --print("MageGenAttack:onEnterProcessDo()")
    self._pCurState = state
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)

end

-- 技能执行状态onExit时技能操作
function MageGenAttack:onExitProcessDo()
    --print("MageGenAttack:onExitProcessDo()")
end

-- 技能执行状态onUpdate时技能操作
function MageGenAttack:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MageGenAttack:onEnterReleaseDo(state)
    --print("MageGenAttack:onEnterReleaseDo()")

    self._pCurState = state

    self._nSettledZorder = kZorder.kMaxSkill
       
    -- 前3击要能够自动转向
    if self._nComboIndex <= 3 then
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
    end

    -- 播放技能特效
    self:playActionByIndex(self._nComboIndex)
    
    if self._nComboIndex == 1 then
        self:setPosition(self._pTargetsPos.x, self._pTargetsPos.y)
    elseif self._nComboIndex == 2 then
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)
    elseif self._nComboIndex == 3 then
        local flyOutOver = function()
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
                -- 角色搜索警戒范围内的目标，并根据目标的方位自动转向
                self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
                self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
            else
                self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
            end

        end
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)
        local offsetY = self._pSkillInfo.BulletMaxDistance*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.BulletMaxDistance*math.cos(math.rad(self:getMaster():getAngle3D()))
        self:stopActionByTag(nSkillFlyActTag)
        local act = cc.Spawn:create(cc.Sequence:create(cc.MoveBy:create(self._pSkillInfo.BulletMaxDistance/self._pSkillInfo.BulletSpeed, cc.p(offsetX,offsetY)), cc.CallFunc:create(flyOutOver)), cc.EaseSineInOut:create(cc.ScaleTo:create(0.4,1.0,1.0)) )
        act:setTag(nSkillFlyActTag)
        self:runAction(act)
    elseif self._nComboIndex == 4 then
        local offsetY = self._pSkillInfo.BulletMaxDistance*math.sin(math.rad(self:getMaster():getAngle3D()))
        local offsetX = self._pSkillInfo.BulletMaxDistance*math.cos(math.rad(self:getMaster():getAngle3D()))
        self:setPosition(self:getMaster():getPositionX()+offsetX, self:getMaster():getPositionY()+offsetY) 
    end

    -- 技能施展音效
    AudioManager:getInstance():playEffect(self._tTempleteInfo.SkillProcessSound)
    
    self:setVisible(true)
    
end

-- 技能释放状态onExit时技能操作
function MageGenAttack:onExitReleaseDo()
    --print("MageGenAttack:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function MageGenAttack:onUpdateReleaseDo(dt)
    if self._nComboIndex == 2 then
        local posX, posY = self:getMaster():getPosition()
        self:setPosition(posX, posY + self:getMaster():getHeight()/2)
    end


end

-- 技能结束时的复位操作
function MageGenAttack:reset()
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

return MageGenAttack
