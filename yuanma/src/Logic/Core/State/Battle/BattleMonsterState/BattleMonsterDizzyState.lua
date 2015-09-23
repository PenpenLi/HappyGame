--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterDizzyState.lua
-- author:    liyuhan
-- created:   2015/3/14
-- descrip:   战斗中怪物角色眩晕状态
--===================================================
local BattleMonsterDizzyState = class("BattleMonsterDizzyState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterDizzyState:ctor()
    self._strName = "BattleMonsterDizzyState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kDizzy  -- 状态类型ID
end

-- 创建函数
function BattleMonsterDizzyState:create()
    local state = BattleMonsterDizzyState.new()
    return state
end

-- 进入函数
function BattleMonsterDizzyState:onEnter(args) 
    --print(self._strName.." is onEnter!")
    
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("--STATE--MONSTER"..self:getMaster()._pRoleInfo.ID.."--:Dizzy")
        -- 复位可能存在的所有技能的动画
        for k,v in pairs(self:getMaster()._tSkills) do 
            v:stopAllActionNodes()
            v._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
        -- 刷新动作
        self:getMaster():playDizzyAction()
    end
    
    return
end

-- 退出函数
function BattleMonsterDizzyState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        -- 待完善
    end
    return
end

-- 更新逻辑
function BattleMonsterDizzyState:update(dt)    
    return
end

return BattleMonsterDizzyState
