--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterFrozenState.lua
-- author:    liyuhan
-- created:   2015/1/17
-- descrip:   战斗中怪物角色冻结状态
--===================================================
local BattleMonsterFrozenState = class("BattleMonsterFrozenState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterFrozenState:ctor()
    self._strName = "BattleMonsterFrozenState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kFrozen  -- 状态类型ID
end

-- 创建函数
function BattleMonsterFrozenState:create()
    local state = BattleMonsterFrozenState.new()
    return state
end

-- 进入函数
function BattleMonsterFrozenState:onEnter(args) 
    --print(self._strName.." is onEnter!")
    
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("--STATE--MONSTER"..self:getMaster()._pRoleInfo.ID.."--:Frozen")
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
function BattleMonsterFrozenState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        -- 待完善
    end
    return
end

-- 更新逻辑
function BattleMonsterFrozenState:update(dt)    
    return
end

return BattleMonsterFrozenState
