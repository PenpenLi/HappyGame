--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldPlayerRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   世界中玩家角色站立状态
--===================================================
local WorldPlayerRoleStandState = class("WorldPlayerRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function WorldPlayerRoleStandState:ctor()
    self._strName = "WorldPlayerRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kWorldPlayerRole.kStand  -- 状态类型ID
    ------------ 时间计数 ---------------------------------------------
    self._fStandTime = 0
    self._fCasualTime = 0

end

-- 创建函数
function WorldPlayerRoleStandState:create()
    local state = WorldPlayerRoleStandState.new()
    return state
end

-- 进入函数
function WorldPlayerRoleStandState:onEnter(args)
    --print(self._strName.."角色站立")    
    
    if self:getMaster() then
        self._fStandTime = 0
        self._fCasualTime = 0
        self._fStandTime = self:getMaster()._pTempleteInfo.CasualActInterval
        self:getMaster():playStandAction()
        -- 刷新一下层级关系
        if self:getMaster()._kRoleType == kType.kRole.kPlayer then
            -- 检测遮挡
            self:getMaster():checkCover()
            -- 检测和触发器的停留碰撞
            if self:getMaster()._strCharTag == "main" then
                self:getMaster():checkCollisionOnTriggerWithRuntime(false)
            end
        end
    end
    return
end

-- 退出函数
function WorldPlayerRoleStandState:onExit()
   -- print(self._strName.." is onExit!")
    self._fStandTime = 0
    self._fCasualTime = 0
    return
end

-- 更新逻辑
function WorldPlayerRoleStandState:update(dt)
    -- 时间计数
    if self._fCasualTime == 0 then
        self._fStandTime = self._fStandTime - dt
        if self._fStandTime <= 0 then
            self._fStandTime = 0
            self._fCasualTime = self:getMaster():getCasualActionTime()
            self:getMaster():playCasualAction()
        end
    else
        self._fCasualTime = self._fCasualTime - dt
        if self._fCasualTime <= 0 then
            self._fCasualTime = 0
            self._fStandTime = self:getMaster()._pTempleteInfo.CasualActInterval
            self:getMaster():playStandAction()
        end
    end

    return
end

return WorldPlayerRoleStandState
