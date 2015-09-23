--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中玩家角色站立状态
--===================================================
local BattleFriendRoleStandState = class("BattleFriendRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleFriendRoleStandState:ctor()
    self._strName = "BattleFriendRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleFriendRole.kStand  -- 状态类型ID
    self._pScheduleEntry = nil                             -- 定时器
    
end

-- 创建函数
function BattleFriendRoleStandState:create()
    local state = BattleFriendRoleStandState.new()
    return state
end

-- 进入函数
function BattleFriendRoleStandState:onEnter(args)
    
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("mmo:BattleFriendRoleStandState")
        -- 刷新动作
        self:getMaster():playStandAction()
        
        -- 检测遮挡
        self:getMaster():checkCover()
        
        -- 2秒后消失掉
        local actOver = function()
            if self:getMaster() then
                self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kDisAppear)
            end
        end
        self._pScheduleEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(actOver, 1.5, false)
    end
    
    return
end

-- 退出函数
function BattleFriendRoleStandState:onExit()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduleEntry)
    return
end

-- 更新逻辑
function BattleFriendRoleStandState:update(dt)    
    return
end

return BattleFriendRoleStandState
