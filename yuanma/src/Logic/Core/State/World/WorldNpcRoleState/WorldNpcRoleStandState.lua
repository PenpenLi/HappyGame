--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldNpcRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   世界中NPC角色站立状态
--===================================================
local WorldNpcRoleStandState = class("WorldNpcRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function WorldNpcRoleStandState:ctor()
    self._strName = "WorldNpcRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kWorldNpcRole.kStand  -- 状态类型ID
    ------------ 时间计数 ---------------------------------------------
    self._fStandTime = 0
    self._fCasualTime = 0

end

-- 创建函数
function WorldNpcRoleStandState:create()
    local state = WorldNpcRoleStandState.new()
    return state
end

-- 进入函数
function WorldNpcRoleStandState:onEnter(args)
   -- print(self._strName.." is onEnter!")    
    if self:getMaster() then
        self._fStandTime = 0
        self._fCasualTime = 0
        self._fStandTime = self:getMaster()._tTempleteInfo.CasualActInterval
        self:getMaster():playStandAction()
    end
    return
end

-- 退出函数
function WorldNpcRoleStandState:onExit()
  --  print(self._strName.." is onExit!")
    self._fStandTime = 0
    self._fCasualTime = 0
    return
end

-- 更新逻辑
function WorldNpcRoleStandState:update(dt)
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
            self._fStandTime = self:getMaster()._tTempleteInfo.CasualActInterval
            self:getMaster():playStandAction()
        end
    end

    return
end

return WorldNpcRoleStandState
