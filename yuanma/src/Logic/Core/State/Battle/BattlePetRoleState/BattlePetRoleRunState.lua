--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePetRoleRunState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   战斗中玩家宠物角色奔跑状态
--===================================================
local BattlePetRoleRunState = class("BattlePetRoleRunState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePetRoleRunState:ctor()
    self._strName = "BattlePetRoleRunState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePetRole.kRun  -- 状态类型ID
    self._tMoveDirections = {}                        -- 指定的移动方向集合
    self._nCurStepIndexInMoveDirections = 0           -- 指定的移动方向集合中当前的步数
    self._fCurStepMoveDistanceBuf = 0                 -- 当前指定移动方向集合的行进步中累计的移动间距缓存
    self._fCurAngleInMoveDirections = 0               -- 当前指定移动方向集合的行进步中的角度
    self._bExictlyToTarget = false                    -- 是否精确走到目标位置（false时：用于跟随主人，true时：用于追怪）
    self._fIgnoreHurtTimeCount = -1                   -- 避免此时切换应值等其他3D动作时导致安卓的闪退，做一个缓冲

end

-- 创建函数
function BattlePetRoleRunState:create()
    local state = BattlePetRoleRunState.new()
    return state
end

-- 进入函数
function BattlePetRoleRunState:onEnter(args)
    --cclog("宠物奔跑")
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
            self._bExictlyToTarget = args.bExictlyToTarget
        end
    end
    -- 忽略伤害引用计数+1（连应值都不会有）（避免此时切换应值等其他3D动作时导致安卓的闪退，做一个缓冲）
    self:getMaster()._pRefRoleIgnoreHurt:add()
    self._fIgnoreHurtTimeCount = 0
        
    return
end

-- 退出函数
function BattlePetRoleRunState:onExit()
    --print(self._strName.." is onExit!")
    self._tMoveDirections = {}
    self._nCurStepIndexInMoveDirections = 0
    self._fCurStepMoveDistanceBuf = 0
    self._fCurAngleInMoveDirections = 0
    self._bExictlyToTarget = false
    if self._fIgnoreHurtTimeCount ~= -1 then
        self:getMaster()._pRefRoleIgnoreHurt:sub()
    end
    self._fIgnoreHurtTimeCount = -1
    
    return
end

-- 更新逻辑
function BattlePetRoleRunState:update(dt)

    if self._fIgnoreHurtTimeCount ~= - 1 then
        self._fIgnoreHurtTimeCount = self._fIgnoreHurtTimeCount + dt
        if self._fIgnoreHurtTimeCount >= 0.2 then
            self:getMaster()._pRefRoleIgnoreHurt:sub()
            self._fIgnoreHurtTimeCount = -1
        end
    end

    if self:getMaster() then
        -- 奔跑逻辑    
        self:procRun(dt)
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 自动战斗相关逻辑
        self:procAutoBattle(dt)  
    end
    return
end

-- 自动战斗相关逻辑
function BattlePetRoleRunState:procAutoBattle(dt)
    -- 自动战斗情况下，搜索最近目标后，自动切换到跑步状态
    if self:getMaster()._strCharTag == "main" then
        -- 先检测是否需要进行自动攻击  (先判定是否所有技能目前都处于idle状态才可以进行)
        for k,v in pairs(self:getMaster()._tSkills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                return  -- 存在正在使用的技能，直接返回，不可以攻击，也不可以寻路
            end
        end

        if self:getRolesManager()._pMainPlayerRole._nCurHp / self:getRolesManager()._pMainPlayerRole._nHpMax < TableConstants.PetSupportCondition.Value then -- 可以给主角加血
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 4 then -- 回复性技能类型
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该回复技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, false)
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end
        end

        -- 玩家宠物角色判定当前是否可以进入战斗模式
        local canEnterBattle = self:getAIManager():isPetCanEnterBattleModeForDamage(self:getMaster())
        if canEnterBattle == true then  -- 可以进入战斗模式
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 3 then -- buff型技能
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, false)
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 2 then -- 普通型技能
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, true)  -- 找离宠物主人最近的，同时在宠物的警戒范围内 
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 1 then -- 普通型攻击
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, true)  -- 找离宠物主人最近的，同时在宠物的警戒范围内
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end

        else    -- 不可进入战斗模式，等待继续跟随玩家
            return
        end

    elseif self:getMaster()._strCharTag == "pvp" then
        -- 先检测是否需要进行自动攻击  (先判定是否所有技能目前都处于idle状态才可以进行)
        for k,v in pairs(self:getMaster()._tSkills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                return  -- 存在正在使用的技能，直接返回，不可以攻击，也不可以寻路
            end
        end

        if self:getRolesManager()._pPvpPlayerRole._nCurHp / self:getRolesManager()._pPvpPlayerRole._nHpMax < TableConstants.PetSupportCondition.Value then -- 可以给pvp主角加血
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 4 then -- 回复性技能类型
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该回复技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, false)
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end
        end

        -- 玩家宠物角色判定当前是否可以进入战斗模式
        local canEnterBattle = self:getAIManager():isPetCanEnterBattleModeForDamage(self:getMaster())
        if canEnterBattle == true then  -- 可以进入战斗模式
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 3 then -- buff型技能
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, false)
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 2 then -- 普通型技能
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, true)
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end
            for kSkill,vSkill in pairs(self:getMaster()._tSkills) do 
                if vSkill._pSkillInfo.PetSkillType == 1 then -- 普通型攻击
                    if vSkill:isCDOver() == true then   -- 且已经CD结束，则使用该技能
                        local targetInView, targetInWarning = self:getAIManager():objSearchNearestEnemysInViewAndSkillWarningRange(self:getMaster(), vSkill, false, true)
                        if #targetInWarning ~= 0 then  -- 警戒范围内有目标，则直接开始战斗
                            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kSkillAttack, true, {["skillIndex"] = kSkill})
                            return 
                        end
                    end
                end
            end
            
        else    -- 不可进入战斗模式，等待继续跟随玩家
            return
        end

    end

end

-- 奔跑逻辑
function BattlePetRoleRunState:procRun(dt)      
    local direction = self:getMaster()._kDirection
    local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
    local fSpeed = self:getMaster()._nCurSpeed
    local sTileSize = self:getMapManager()._sTiledPixelSize

    if table.getn(self._tMoveDirections) == 0 then  -- 没有指定的路径，则切换回站立状态
        self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePetRole.kStand)
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
        

        if self._bExictlyToTarget == false then  -- 跟随主人时，距离全部走完还差3个格子时可以回到站立状态
            if self._nCurStepIndexInMoveDirections > table.getn(self._tMoveDirections) - 3 then
                local target = self:getMaster()._pMaster  -- 宠物的主人
                local posIndex = self:getMaster():getPositionIndex()
                local targetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(target:getPositionX(), target:getPositionY()))
                local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
                if table.getn(path) - 3 > 0 then       -- 继续寻路
                    self._tMoveDirections = path
                    self._nCurStepIndexInMoveDirections = 1
                    self._fCurStepMoveDistanceBuf = 0
                    self._fCurAngleInMoveDirections = self:getMaster():getAngle3D()
                    -- 位置矫正
                    self:getMaster():adjustPos()
                else  -- 在制定距离内，恢复到站立即可
                    self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePetRole.kStand)
                end
            end
        elseif self._bExictlyToTarget == true then  -- 追怪时，距离全部走完还差1个格子时可以回到站立状态
            if self._nCurStepIndexInMoveDirections > table.getn(self._tMoveDirections) - 1 then
                self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePetRole.kStand)
            end
        end
    end
    
end 
            
return BattlePetRoleRunState
