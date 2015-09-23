--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleSuspendState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/12
-- descrip:   战斗中好友挂起状态
--===================================================
local BattleFriendRoleSuspendState = class("BattleFriendRoleSuspendState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleFriendRoleSuspendState:ctor()
    self._strName = "BattleFriendRoleSuspendState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleFriendRole.kSuspend  -- 状态类型ID
    
end

-- 创建函数
function BattleFriendRoleSuspendState:create()
    local state = BattleFriendRoleSuspendState.new()
    return state
end

-- 进入函数
function BattleFriendRoleSuspendState:onEnter(args)
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("mmo:BattleFriendRoleSuspendState")
        self:getMaster():setVisible(false)
    end
    return
end

-- 退出函数
function BattleFriendRoleSuspendState:onExit()
    return
end

-- 更新逻辑
function BattleFriendRoleSuspendState:update(dt)
    
    return
end

return BattleFriendRoleSuspendState
