--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldPetRoleRunState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   世界中玩家宠物角色奔跑状态
--===================================================
local WorldPetRoleRunState = class("WorldPetRoleRunState",function()
    return require("State"):create()
end)

-- 构造函数
function WorldPetRoleRunState:ctor()
    self._strName = "WorldPetRoleRunState"           -- 状态名称
    self._kTypeID = kType.kState.kWorldPetRole.kRun  -- 状态类型ID
    self._tMoveDirections = {}                       -- 指定的移动方向集合
    self._nCurStepIndexInMoveDirections = 0          -- 指定的移动方向集合中当前的步数
    self._fCurStepMoveDistanceBuf = 0                -- 当前指定移动方向集合的行进步中累计的移动间距缓存
    self._fCurAngleInMoveDirections = 0              -- 当前指定移动方向集合的行进步中的角度
    self._funcCallBackFunc = nil                     -- 指定移动方向集合结束后的回调函数
    
end

-- 创建函数
function WorldPetRoleRunState:create()
    local state = WorldPetRoleRunState.new()
    return state
end

-- 进入函数
function WorldPetRoleRunState:onEnter(args)
   -- print(self._strName.." is onEnter!")
    
    if self:getMaster() then
        -- 指定的移动方向集合
        if args ~= nil then
            if table.getn(args.moveDirections) ~= 0 then
                self._tMoveDirections = args.moveDirections
                self._nCurStepIndexInMoveDirections = 1
                self._fCurStepMoveDistanceBuf = 0
                self._fCurAngleInMoveDirections = self:getMaster():getAngle3D()
                -- 位置矫正
                self:getMaster():adjustPos()
                -- 回调函数赋值
                self._funcCallBackFunc = args.func
            elseif args.func ~= nil then -- 虽移动方向集合为0，但是回调函数不为空，则直接执行，返回即可
                args.func()
                self._pOwnerMachine:setCurStateByTypeID(kType.kState.kWorldPetRole.kStand)
                return
            end
        end
        
        -- 刷新动作
        self:getMaster():playRunAction()
    end
    
    return
end

-- 退出函数
function WorldPetRoleRunState:onExit()
    --print(self._strName.." is onExit!")
    
    self._tMoveDirections = {}
    self._nCurStepIndexInMoveDirections = 0
    self._fCurStepMoveDistanceBuf = 0
    self._fCurAngleInMoveDirections = 0
    self._funcCallBackFunc = nil
    
    return
end

-- 更新逻辑
function WorldPetRoleRunState:update(dt)
    if self:getMaster() then
        -- 奔跑逻辑
        self:procRun(dt)
        -- 检测遮挡
        self:checkCover()
    end

    return
end

-- 奔跑逻辑
function WorldPetRoleRunState:procRun(dt)    
    local direction = self:getMaster()._kDirection
    local posRole = cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY())
    local fSpeed = self:getMaster()._nCurSpeed
    local sTileSize = self:getMapManager()._sTiledPixelSize

    if table.getn(self._tMoveDirections) == 0 then  -- 没有指定的路径，则切换回站立状态
        self._pOwnerMachine:setCurStateByTypeID(kType.kState.kWorldPetRole.kStand)
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

        -- 距离全部走完还差4个格子时可以回到站立状态
        if self._nCurStepIndexInMoveDirections > table.getn(self._tMoveDirections) - 3 then
            if self._funcCallBackFunc then
                self._funcCallBackFunc()
            end
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kWorldPetRole.kStand)
        end
    end

    return
end

-- 检测遮挡
function WorldPetRoleRunState:checkCover()
    self:getMaster():checkCover()
end

-- 检测和触发器的实时碰撞
function WorldPetRoleRunState:checkCollisionOnTrigger()

end

return WorldPetRoleRunState