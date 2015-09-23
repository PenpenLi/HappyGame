--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterRunState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中怪物角色奔跑状态
--===================================================
local BattleMonsterRunState = class("BattleMonsterRunState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterRunState:ctor()
    self._strName = "BattlePlayerRoleRunState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kRun     -- 状态类型ID
    self._tMoveDirections = {}                           -- 指定的移动方向集合
    self._nCurStepIndexInMoveDirections = 0              -- 指定的移动方向集合中当前的步数
    self._fCurStepMoveDistanceBuf = 0                    -- 当前指定移动方向集合的行进步中累计的移动间距缓存
    self._fCurAngleInMoveDirections = 0                  -- 当前指定移动方向集合的行进步中的角度

end

-- 创建函数
function BattleMonsterRunState:create()
    local state = BattleMonsterRunState.new()
    return state
end

-- 进入函数
function BattleMonsterRunState:onEnter(args)
    if self:getMaster() then
        -- 刷新动作
        self:getMaster():playRunAction()
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
    return
end

-- 退出函数
function BattleMonsterRunState:onExit()
    --print(self._strName.." is onExit!")
    self._tMoveDirections = {}
    self._nCurStepIndexInMoveDirections = 0
    self._fCurStepMoveDistanceBuf = 0
    self._fCurAngleInMoveDirections = 0

    return
end

-- 更新逻辑
function BattleMonsterRunState:update(dt)

    -- 如果正在显示对话或地图正在移动，则直接返回
    if self:getTalksManager():isShowingTalks() == true or self:getMapManager():isCameraMoving() == true then
        self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
        return
    end
    
    if self:getMaster() then
        -- 先判定是否所有技能目前都处于idle状态
        local bSkillsAllIdles = true
        for k,v in pairs(self:getMaster()._tSkills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                bSkillsAllIdles = false
                break
            end
        end
        if bSkillsAllIdles == true then
            -- 野怪搜索视野范围内的最近目标和当前技能链中第一个技能的警戒范围内的最近目标
            if self:getMaster() then
                if self:getMaster()._nMonsterType == kType.kMonster.kThiefBOSS then  -- 盗宝贼BOSS
                    --（盗宝贼在逃跑过程中不具备作战能力）
                    -- 奔跑逻辑
                    self:procRunForThief(dt)
                    -- 检测遮挡
                    self:getMaster():checkCover()
                else  -- 普通野怪逻辑
                    local targetsInView, targetsInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), self:getMaster()._tReverseIDSkills[self:getMaster()._tCurSkillChain[1]])
                    if #targetsInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                        -- monster发起进攻
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kSkillAttack)
                        return
                    end
                    if #targetsInView ~= 0 then  -- 视野范围内有目标，则开始奔跑
                        -- 奔跑逻辑
                        self:procRun(dt, targetsInView)
                        -- 检测遮挡
                        self:getMaster():checkCover()
                    else    -- 视野内也没有目标，则切回站立状态
                        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
                    end  
                end
       
            end
    
        end
    end
    
    return
end

-- 奔跑逻辑
function BattleMonsterRunState:procRun(dt, targetsInView)    
    -- 刷新方向
    local fAttackAngle = mmo.HelpFunc:gAngleAnalyseForRotation(self:getMaster():getPositionX(), self:getMaster():getPositionY(), targetsInView[1].enemy:getPositionX(), targetsInView[1].enemy:getPositionY())
    self:getMaster():setAngle3D(fAttackAngle)
    self:getMaster()._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(fAttackAngle)
    
    -- 刷新位置
    local direction = self:getMaster()._kDirection
    local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
    local fSpeed = self:getMaster()._nCurSpeed

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

    if posRole.x >= self:getMapManager()._sMapRectPixelSize.width then
        posRole.x = self:getMapManager()._sMapRectPixelSize.width
    elseif posRole.x <= 0 then
        posRole.x = 0
    end

    if posRole.y >= self:getMapManager()._sMapRectPixelSize.height then
        posRole.y = self:getMapManager()._sMapRectPixelSize.height
    elseif posRole.y <= 0 then
        posRole.y = 0
    end

    self:getMaster():setPosition(posRole)

end

function BattleMonsterRunState:procRunForThief(dt)
    local direction = self:getMaster()._kDirection
    local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
    local fSpeed = self:getMaster()._nCurSpeed
    local sTileSize = self:getMapManager()._sTiledPixelSize

    if table.getn(self._tMoveDirections) == 0 then  -- 没有指定的路径，则切换回站立状态
        self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
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
        
        if self._nCurStepIndexInMoveDirections >= table.getn(self._tMoveDirections) then
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleMonster.kStand, false, {bThiefReadyToAttack = true})  -- 切换到站立状态，到达目的地后，准备攻击
        end

    end
end


return BattleMonsterRunState
