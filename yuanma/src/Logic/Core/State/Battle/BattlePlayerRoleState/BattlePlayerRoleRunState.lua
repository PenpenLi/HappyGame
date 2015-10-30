--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleRunState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中玩家角色奔跑状态
--===================================================
local BattlePlayerRoleRunState = class("BattlePlayerRoleRunState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleRunState:ctor()
    self._strName = "BattlePlayerRoleRunState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kRun  -- 状态类型ID

    self._tMoveDirections = {}                           -- 指定的移动方向集合
    self._nCurStepIndexInMoveDirections = 0              -- 指定的移动方向集合中当前的步数
    self._fCurStepMoveDistanceBuf = 0                    -- 当前指定移动方向集合的行进步中累计的移动间距缓存
    self._fCurAngleInMoveDirections = 0                  -- 当前指定移动方向集合的行进步中的角度
    self._fRunTimeCount = 0                              -- 奔跑的持续时间
    self._nRunSoundID = -1                               -- 跑步的声音ID

    self._fIgnoreHurtTimeCount = -1                      -- 避免此时切换应值等其他3D动作时导致安卓的闪退，做一个缓冲
    
end

-- 创建函数
function BattlePlayerRoleRunState:create()
    local state = BattlePlayerRoleRunState.new()
    return state
end

-- 进入函数
function BattlePlayerRoleRunState:onEnter(args)
    if self:getMaster() then
        mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:Run")
        -- 刷新动作
        self:getMaster():playRunAction()

        -- 自动战斗情况下，并且摇杆没有工作时
        if self:getMaster()._strCharTag == "main" then
            if self:getBattleManager()._bIsAutoBattle == true and cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getIsWorking() == false then
                -- 指定的移动方向集合
                if args ~= nil then
                    if table.getn(args.moveDirections) ~= 0 then
                        self._tMoveDirections = args.moveDirections
                        self._nCurStepIndexInMoveDirections = 1
                        self._fCurStepMoveDistanceBuf = 0
                        self._fCurAngleInMoveDirections = self:getMaster():getAngle3D()
                        -- 位置矫正
                        self:getMaster():adjustPos()
                    end
                end
            end
        elseif self:getMaster()._strCharTag == "pvp" then
            -- 指定的移动方向集合
            if args ~= nil then
                if table.getn(args.moveDirections) ~= 0 then
                    self._tMoveDirections = args.moveDirections
                    self._nCurStepIndexInMoveDirections = 1
                    self._fCurStepMoveDistanceBuf = 0
                    self._fCurAngleInMoveDirections = self:getMaster():getAngle3D()
                    -- 位置矫正
                    self:getMaster():adjustPos()
                end
            end
        end
        
        -- 脚步声
        self._nRunSoundID = AudioManager:getInstance():playEffect(self:getMaster()._pTempleteInfo.RunSound,true)
    end

    -- 忽略伤害引用计数+1（连应值都不会有）（避免此时切换应值等其他3D动作时导致安卓的闪退，做一个缓冲）
    self:getMaster()._pRefRoleIgnoreHurt:add()
    self._fIgnoreHurtTimeCount = 0

    return
end

-- 退出函数
function BattlePlayerRoleRunState:onExit()
    --print(self._strName.." is onExit!")
    self._tMoveDirections = {}
    self._nCurStepIndexInMoveDirections = 0
    self._fCurStepMoveDistanceBuf = 0
    self._fCurAngleInMoveDirections = 0
    self._fRunTimeCount = 0
    
    AudioManager:getInstance():stopEffect(self._nRunSoundID)
    self._nRunSoundID = -1

    if self._fIgnoreHurtTimeCount ~= -1 then
        self:getMaster()._pRefRoleIgnoreHurt:sub()
    end
    self._fIgnoreHurtTimeCount = -1
    
    return
end

-- 更新逻辑
function BattlePlayerRoleRunState:update(dt)

    if self._fIgnoreHurtTimeCount ~= - 1 then
        self._fIgnoreHurtTimeCount = self._fIgnoreHurtTimeCount + dt
        if self._fIgnoreHurtTimeCount >= 0.2 then
            self:getMaster()._pRefRoleIgnoreHurt:sub()
            self._fIgnoreHurtTimeCount = -1
        end
    end

    -- 如果正在显示对话或地图正在移动，则直接返回    
    if self:getTalksManager():isShowingTalks() == true or self:getMapManager():isCameraMoving() == true then
        self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
        return
    end
    
    if self:getMaster() then
        -- 奔跑逻辑    
        self:procRun(dt)
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 检测和触发器的实时碰撞
        if self:getMaster()._strCharTag == "main" then
            self:getMaster():checkCollisionOnTriggerWithRuntime(true)
        end
        -- 检测玩家是否已经离开了入场传送门
        self:getMaster():checkLeavingFromEnterDoor()
        -- 自动战斗相关逻辑
        self:procAutoBattle(dt)
    end

    return
end

-- 自动战斗相关逻辑
function BattlePlayerRoleRunState:procAutoBattle(dt)
    
    -- 奔跑的持续时间
    self._fRunTimeCount = self._fRunTimeCount + dt
    
    -- 自动战斗情况下，搜索最近目标后，自动切换到跑步状态
    if self:getMaster()._strCharTag == "main" then
        if cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getIsWorking() == false then
            if self:getBattleManager()._bIsAutoBattle == true then

                -- 先检测是否需要进行自动攻击  (先判定是否所有技能目前都处于idle状态才可以进行)
                for k,v in pairs(self:getMaster()._tSkills) do
                    if k ~= kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack then
                        if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                            return  -- 存在正在使用的技能，直接返回，不可以攻击，也不可以寻路
                        end
                    end
                end
                -- 再判定是否怒气技能目前正在释放，如果不为idle，则立即返回
                if self:getMaster()._pRoleInfo.roleCareer ~= kCareer.kThug then  -- 不为刺客
                    if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] then
                        if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack]:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                            return
                        end
                    end
                end

                -- 玩家角色搜索视野范围（无限大）内的最近目标集合（用于自动战斗寻路锁定目标位置）与普通攻击的警戒范围内的目标集合
                local targetsInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
                if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                    --------------------------------------------------- 自动攻击 ------------------------------------------------------------------
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kGenAttack)
                    return
                elseif #targetsInView ~= 0 then  -- 警戒范围内没有目标，视野范围内有目标
                    if self._fRunTimeCount >= 3.0 then  -- 超过3秒，重新寻路
                        local posIndex = self:getMaster():getPositionIndex()
                        local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(targetsInView[1].enemy:getPositionX(), targetsInView[1].enemy:getPositionY()))
                        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, true, {moveDirections = path})
                        return
                    end
                end
            else
                if table.getn(self._tMoveDirections) ~= 0 then
                    self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
                end
            end

        end
    elseif self:getMaster()._strCharTag == "pvp" then
        -- 先检测是否需要进行自动攻击  (先判定是否所有技能目前都处于idle状态才可以进行)
        for k,v in pairs(self:getMaster()._tSkills) do
            if k ~= kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack then
                if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                    return  -- 存在正在使用的技能，直接返回，不可以攻击，也不可以寻路
                end
            end
        end
        -- 再判定是否怒气技能目前正在释放，如果不为idle，则立即返回
        if self:getMaster()._pRoleInfo.roleCareer ~= kCareer.kThug then  -- 不为刺客
            if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] then
                if self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack]:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                    return
                end
            end
        end
        -- PVP对手搜索视野范围（无限大）内的最近目标集合与已经冷却结束的警戒范围内的目标集合
        local skillWayIdex = self:getAIManager():playerRoleDecideSkill(self:getMaster())
        local targetsInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tSkills[skillWayIdex])
        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
            self._pOwnerMachine:usePetCooperateSkill()  -- 发现目标时，考虑自动释放宠物共鸣技能
            --------------------------------------------------- 自动攻击 ------------------------------------------------------------------
            if skillWayIdex == kType.kSkill.kWayIndex.kPlayerRole.kGenAttack then  -- 需要发起普通攻击
                if self:getMaster()._refGenAttackButton:getRefValue() == 0 then
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kGenAttack)
                end
            elseif skillWayIdex == kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack then  -- 需要发起怒气攻击
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kAngerAttack)
            else    -- 需要发起技能攻击
                if self:getMaster()._tRefSkillButtons[skillWayIdex-1]:getRefValue() == 0 then
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kSkillAttack, false, skillWayIdex)
                end
            end
            return
         elseif #targetsInView ~= 0 then  -- 警戒范围内没有目标，视野范围内有目标，则开始寻路
            if self._fRunTimeCount >= 2.0 then  -- 超过3秒，重新寻路
                local posIndex = self:getMaster():getPositionIndex()
                local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(targetsInView[1].enemy:getPositionX(), targetsInView[1].enemy:getPositionY()))
                local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, true, {moveDirections = path})
                return
            end
         end
        
    end
    
end

-- 奔跑逻辑
function BattlePlayerRoleRunState:procRun(dt)      
    if self:getMaster()._strCharTag == "main" then
        self:procRunWithMainRoleStickWorking(dt)
        self:procRunWithMainRoleNoStickWorkingOrPvpRoleAutoRunning(dt)
    elseif self:getMaster()._strCharTag == "pvp" then
        self:procRunWithMainRoleNoStickWorkingOrPvpRoleAutoRunning(dt)
    end
    return
end

-- 主角玩家摇杆跑步逻辑
function BattlePlayerRoleRunState:procRunWithMainRoleStickWorking(dt)
    local bIsStickWorking = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getIsWorking()
    local direction = self:getMaster()._kDirection
    local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
    local fSpeed = self:getMaster()._nCurSpeed
    local sTileSize = self:getMapManager()._sTiledPixelSize
    
    if bIsStickWorking == true then -- 主角摇杆中ing
        -- 一旦发生摇杆动作，则之前的寻路信息即被中断清空 
        if table.getn(self._tMoveDirections) ~= 0 then
            self._tMoveDirections = {}
            self._nCurStepIndexInMoveDirections = 0
            self._fCurStepMoveDistanceBuf = 0
            self._fCurAngleInMoveDirections = 0    
            self._funcCallBackFunc = nil
        end  
        
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


-- 主角玩家非摇杆跑步逻辑 || pvp自动跑步逻辑
function BattlePlayerRoleRunState:procRunWithMainRoleNoStickWorkingOrPvpRoleAutoRunning(dt)
    local bIsStickWorking = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:getIsWorking()
    local direction = self:getMaster()._kDirection
    local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
    local fSpeed = self:getMaster()._nCurSpeed
    local sTileSize = self:getMapManager()._sTiledPixelSize
    
    if (bIsStickWorking == false and self:getMaster()._strCharTag == "main") or self:getMaster()._strCharTag == "pvp" then
        if table.getn(self._tMoveDirections) == 0 then  -- 没有指定的路径，则切换回站立状态
            if self:getMaster()._strCharTag == "pvp" then
                ---------------------------------------------- 开始寻路 ----------------------------------------------------------
                local target = self:getRolesManager()._pMainPlayerRole
                local posIndex = self:getMaster():getPositionIndex()
                local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
                local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, true, {moveDirections = path})
            else
                self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
            end
        else -- 有指定的路径，则自动行走开始
            -- 当前方向
            local curDirection = self._tMoveDirections[self._nCurStepIndexInMoveDirections]
            if curDirection == kDirection.kUp then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kLeftUp or 
                    lastDirection == kDirection.kLeft or 
                    lastDirection == kDirection.kLeftDown or 
                    lastDirection == kDirection.kDown then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 90 then
                        self._fCurAngleInMoveDirections = 90
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 90 then
                        self._fCurAngleInMoveDirections = 90
                    end
                end

                -- 刷新位置
                posRole.y = posRole.y + fSpeed*dt
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt
                if self._fCurStepMoveDistanceBuf >= sTileSize.height then
                    posRole.y = posRole.y - (self._fCurStepMoveDistanceBuf - sTileSize.height)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
                end
            elseif curDirection == kDirection.kDown then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kUp or 
                    lastDirection == kDirection.kLeftUp or 
                    lastDirection == kDirection.kLeft or 
                    lastDirection == kDirection.kLeftDown then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 270 then
                        self._fCurAngleInMoveDirections = 270
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 270 then
                        self._fCurAngleInMoveDirections = 270
                    end
                end

                -- 刷新位置
                posRole.y = posRole.y - fSpeed*dt
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt
                if self._fCurStepMoveDistanceBuf >= sTileSize.height then
                    posRole.y = posRole.y + (self._fCurStepMoveDistanceBuf - sTileSize.height)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
                end
            elseif curDirection == kDirection.kLeft then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kLeftUp or 
                    lastDirection == kDirection.kUp or 
                    lastDirection == kDirection.kRightUp or 
                    lastDirection == kDirection.kRight then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 180 then
                        self._fCurAngleInMoveDirections = 180
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 180 then
                        self._fCurAngleInMoveDirections = 180
                    end
                end

                -- 刷新位置
                posRole.x = posRole.x - fSpeed*dt
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt
                if self._fCurStepMoveDistanceBuf >= sTileSize.width then
                    posRole.x = posRole.x + (self._fCurStepMoveDistanceBuf - sTileSize.width)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
                end
            elseif curDirection == kDirection.kRight then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kRightUp or 
                    lastDirection == kDirection.kUp or 
                    lastDirection == kDirection.kLeftUp or 
                    lastDirection == kDirection.kLeft then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 0 then
                        self._fCurAngleInMoveDirections = 0
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 0 then
                        self._fCurAngleInMoveDirections = 0
                    end
                end

                -- 刷新位置
                posRole.x = posRole.x + fSpeed*dt
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt
                if self._fCurStepMoveDistanceBuf >= sTileSize.width then
                    posRole.x = posRole.x - (self._fCurStepMoveDistanceBuf - sTileSize.width)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
                end
            elseif curDirection == kDirection.kLeftUp then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kUp or 
                    lastDirection == kDirection.kRightUp or 
                    lastDirection == kDirection.kRight or 
                    lastDirection == kDirection.kRightDown then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 135 then
                        self._fCurAngleInMoveDirections = 135
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 135 then
                        self._fCurAngleInMoveDirections = 135
                    end
                end

                -- 刷新位置
                posRole.x = posRole.x - fSpeed*dt/2
                posRole.y = posRole.y + fSpeed*dt/2
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt/2
                if self._fCurStepMoveDistanceBuf >= sTileSize.width then
                    posRole.x = posRole.x + (self._fCurStepMoveDistanceBuf - sTileSize.width)
                    posRole.y = posRole.y - (self._fCurStepMoveDistanceBuf - sTileSize.height)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
                end       
            elseif curDirection == kDirection.kLeftDown then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kLeft or 
                    lastDirection == kDirection.kLeftUp or 
                    lastDirection == kDirection.kUp or 
                    lastDirection == kDirection.kRightUp then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 225 then
                        self._fCurAngleInMoveDirections = 225
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 225 then
                        self._fCurAngleInMoveDirections = 225
                    end
                end

                -- 刷新位置
                posRole.x = posRole.x - fSpeed*dt/2
                posRole.y = posRole.y - fSpeed*dt/2
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt/2
                if self._fCurStepMoveDistanceBuf >= sTileSize.width then
                    posRole.x = posRole.x + (self._fCurStepMoveDistanceBuf - sTileSize.width)
                    posRole.y = posRole.y + (self._fCurStepMoveDistanceBuf - sTileSize.height)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
                end
            elseif curDirection == kDirection.kRightUp then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kUp or 
                    lastDirection == kDirection.kLeftUp or 
                    lastDirection == kDirection.kLeft or 
                    lastDirection == kDirection.kLeftDown then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 45 then
                        self._fCurAngleInMoveDirections = 45
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 45 then
                        self._fCurAngleInMoveDirections = 45
                    end
                end

                -- 刷新位置
                posRole.x = posRole.x + fSpeed*dt/2
                posRole.y = posRole.y + fSpeed*dt/2
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt/2
                if self._fCurStepMoveDistanceBuf >= sTileSize.width then
                    posRole.x = posRole.x - (self._fCurStepMoveDistanceBuf - sTileSize.width)
                    posRole.y = posRole.y - (self._fCurStepMoveDistanceBuf - sTileSize.height)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
                end       
            elseif curDirection == kDirection.kRightDown then
                -- 先刷新角度
                local lastDirection = self:getMaster()._kDirection
                if lastDirection == kDirection.kLeftUp or 
                    lastDirection == kDirection.kUp or 
                    lastDirection == kDirection.kRightUp or 
                    lastDirection == kDirection.kRight then
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections - 10)%360)
                    if self._fCurAngleInMoveDirections <= 315 then
                        self._fCurAngleInMoveDirections = 315
                    end
                else
                    self._fCurAngleInMoveDirections = math.abs((self._fCurAngleInMoveDirections + 10)%360)
                    if self._fCurAngleInMoveDirections >= 315 then
                        self._fCurAngleInMoveDirections = 315
                    end
                end

                -- 刷新位置
                posRole.x = posRole.x + fSpeed*dt/2
                posRole.y = posRole.y - fSpeed*dt/2
                self._fCurStepMoveDistanceBuf = self._fCurStepMoveDistanceBuf + fSpeed*dt/2
                if self._fCurStepMoveDistanceBuf >= sTileSize.width then
                    posRole.x = posRole.x - (self._fCurStepMoveDistanceBuf - sTileSize.width)
                    posRole.y = posRole.y + (self._fCurStepMoveDistanceBuf - sTileSize.height)
                    self._fCurStepMoveDistanceBuf = 0
                    self._nCurStepIndexInMoveDirections = self._nCurStepIndexInMoveDirections + 1
                    self:getMaster()._kDirection = curDirection
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

            self:getMaster():setAngle3D(self._fCurAngleInMoveDirections)


            self:getMaster():setPosition(posRole)

            -- 全部走完，则回到站立状态
            if self._nCurStepIndexInMoveDirections > table.getn(self._tMoveDirections) then
                if self:getMaster()._strCharTag == "pvp" then
                    ---------------------------------------------- 开始寻路 ----------------------------------------------------------
                    local target = self:getRolesManager()._pMainPlayerRole
                    local posIndex = self:getMaster():getPositionIndex()
                    local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
                    local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun, true, {moveDirections = path})
                else
                    self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
                end
                
            end
        end
    end
    
end
            
            
return BattlePlayerRoleRunState
