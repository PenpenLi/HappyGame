--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPetRoleAppearState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/10
-- descrip:   战斗中其他玩家宠物角色出场状态
--===================================================
local BattleOtherPetRoleAppearState = class("BattleOtherPetRoleAppearState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPetRoleAppearState:ctor()
    self._strName = "BattleOtherPetRoleAppearState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPetRole.kAppear  -- 状态类型ID
    
end

-- 创建函数
function BattleOtherPetRoleAppearState:create()
    local state = BattleOtherPetRoleAppearState.new()
    return state
end

-- 进入函数
function BattleOtherPetRoleAppearState:onEnter(args)
    --print(self:getMaster()._strCharTag.."宠物出现状态")
    -- mmo.DebugHelper:showJavaLog("--STATE--PET--:Appear")
    if self:getMaster() then
        -- 终止依托节点的action
        self:getMaster()._pAppearActionNode:stopAllActions()
        -- 出场特效
        self:getMaster():playAppearEffect()
        local appear = function()
            -- 刷新动作
            self:getMaster():playAppearAction()
            -- 检测遮挡
            self:getMaster():checkCover()
        end
        -- 添加动作回调
        local appearOver = function()
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kStand)
        end
        local duration = self:getMaster():getAppearActionTime()
        self:getMaster()._pAppearActionNode:runAction(cc.Sequence:create(cc.Hide:create(),cc.DelayTime:create(0.1), cc.Show:create(), cc.CallFunc:create(appear),cc.DelayTime:create(duration), cc.CallFunc:create(appearOver)))
    end
    return
end

-- 退出函数
function BattleOtherPetRoleAppearState:onExit()
    --print(self._strName.." is onExit!")
    -- 终止依托节点的action
    self:getMaster()._pAppearActionNode:stopAllActions()
    return
end

-- 更新逻辑
function BattleOtherPetRoleAppearState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattleOtherPetRoleAppearState
