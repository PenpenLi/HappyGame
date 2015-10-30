--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPlayerRoleAppearState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/8
-- descrip:   战斗中其他玩家角色出场状态
--===================================================
local BattleOtherPlayerRoleAppearState = class("BattleOtherPlayerRoleAppearState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPlayerRoleAppearState:ctor()
    self._strName = "BattleOtherPlayerRoleAppearState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPlayerRole.kAppear  -- 状态类型ID
    
end

-- 创建函数
function BattleOtherPlayerRoleAppearState:create()
    local state = BattleOtherPlayerRoleAppearState.new()
    return state
end

-- 进入函数
function BattleOtherPlayerRoleAppearState:onEnter(args)
    mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:Appear")
    --print(self:getMaster()._strCharTag.."角色出现状态")
    if self:getMaster() then
        -- 终止依托节点的action
        self:getMaster()._pAppearActionNode:stopAllActions()
        -- 刷新动作
        self:getMaster():playAppearAction()
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 添加动作回调
        local appearOver = function()
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kStand)
        end
        local duration = self:getMaster():getAppearActionTime()
        self:getMaster()._pAppearActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(appearOver)))
    end
    
    return
end

-- 退出函数
function BattleOtherPlayerRoleAppearState:onExit()
    --print(self._strName.." is onExit!")
    -- 终止依托节点的action
    self:getMaster()._pAppearActionNode:stopAllActions()
    
    return
end

-- 更新逻辑
function BattleOtherPlayerRoleAppearState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattleOtherPlayerRoleAppearState
