--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleAppearState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/7
-- descrip:   战斗中玩家角色出场状态
--===================================================
local BattlePlayerRoleAppearState = class("BattlePlayerRoleAppearState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleAppearState:ctor()
    self._strName = "BattlePlayerRoleAppearState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kAppear  -- 状态类型ID
    
end

-- 创建函数
function BattlePlayerRoleAppearState:create()
    local state = BattlePlayerRoleAppearState.new()
    return state
end

-- 进入函数
function BattlePlayerRoleAppearState:onEnter(args)
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
            if self:getMaster()._strCharTag == "pvp" then
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pBossHpNode:setVisible(true)
            end
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
        end
        local duration = self:getMaster():getAppearActionTime()
        self:getMaster()._pAppearActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(appearOver)))
    end
    
    return
end

-- 退出函数
function BattlePlayerRoleAppearState:onExit()
    --print(self._strName.." is onExit!")
    -- 终止依托节点的action
    self:getMaster()._pAppearActionNode:stopAllActions()
    
    return
end

-- 更新逻辑
function BattlePlayerRoleAppearState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattlePlayerRoleAppearState
