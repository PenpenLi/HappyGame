--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleDisAppearState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/12
-- descrip:   战斗中好友角色退场状态
--===================================================
local BattleFriendRoleDisAppearState = class("BattleFriendRoleDisAppearState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleFriendRoleDisAppearState:ctor()
    self._strName = "BattleFriendRoleDisAppearState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleFriendRole.kDisAppear  -- 状态类型ID

end

-- 创建函数
function BattleFriendRoleDisAppearState:create()
    local state = BattleFriendRoleDisAppearState.new()
    return state
end

-- 进入函数
function BattleFriendRoleDisAppearState:onEnter(args)
    -------------------------- 退场特效 -------------------------------------------------------------
    if self:getMaster() then
        -- 终止依托节点的action
        self:getMaster()._pAppearActionNode:stopAllActions()
        -- mmo.DebugHelper:showJavaLog("mmo:BattleFriendRoleDisAppearState")
        local time = self:getMaster():showDisAppearEffect()
        local showOver = function()
            -- 复位技能状态
            if self:getMaster()._pSkill then
	    	    self:getMaster()._pSkill:stopAllActionNodes()
                self:getMaster()._pSkill:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill):setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
            end
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kSuspend)
        end
        self:getMaster()._pAppearActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(showOver)))
    end
    return
end

-- 退出函数
function BattleFriendRoleDisAppearState:onExit()
    -- 终止依托节点的action
    self:getMaster()._pAppearActionNode:stopAllActions()
    return
end

-- 更新逻辑
function BattleFriendRoleDisAppearState:update(dt)
    return
end

return BattleFriendRoleDisAppearState
