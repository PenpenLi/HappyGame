--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterSuspendState.lua
-- author:    liyuhang
-- created:   2015/1/28
-- descrip:   战斗中怪物角色挂起状态
--===================================================
local BattleMonsterSuspendState = class("BattleMonsterSuspendState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterSuspendState:ctor()
    self._strName = "BattleMonsterSuspendState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kSuspend  -- 状态类型ID
end

-- 创建函数
function BattleMonsterSuspendState:create()
    local state = BattleMonsterSuspendState.new()
    return state
end

-- 进入函数
function BattleMonsterSuspendState:onEnter(args)
    --print(self._strName.." is onEnter!")
    
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("--STATE--MONSTER"..self:getMaster()._pRoleInfo.ID.."--:Suspend")
        self:getMaster():setVisible(false)
    end
    return
end

-- 退出函数
function BattleMonsterSuspendState:onExit()
    --print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function BattleMonsterSuspendState:update(dt)
    return
end

return BattleMonsterSuspendState
