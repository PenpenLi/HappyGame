--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePetRoleFrozenState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   战斗中玩家宠物角色冻结状态
--===================================================
local BattlePetRoleFrozenState = class("BattlePetRoleFrozenState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePetRoleFrozenState:ctor()
    self._strName = "BattlePetRoleFrozenState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePetRole.kFrozen  -- 状态类型ID
end

-- 创建函数
function BattlePetRoleFrozenState:create()
    local state = BattlePetRoleFrozenState.new()
    return state
end

-- 进入函数
function BattlePetRoleFrozenState:onEnter(args)
    --print(self:getMaster()._strCharTag.."宠物角色冻结状态")
    -- mmo.DebugHelper:showJavaLog("--STATE--PET--:Frozen")
    if self:getMaster() then
        -- 复位可能存在的所有技能的动画
        for k,v in pairs(self:getMaster()._tSkills) do 
            v:stopAllActionNodes()
            v._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
        -- 刷新动作（定身）
        self:getMaster()._pAni:stopActionByTag(nRoleActAction)
    end
    return
end

-- 退出函数
function BattlePetRoleFrozenState:onExit()
    --print(self._strName.." is onExit!")
    
    if self:getMaster() then
        -- 待完善
    end
    
    return
end

-- 更新逻辑
function BattlePetRoleFrozenState:update(dt)     
    return
end

return BattlePetRoleFrozenState
