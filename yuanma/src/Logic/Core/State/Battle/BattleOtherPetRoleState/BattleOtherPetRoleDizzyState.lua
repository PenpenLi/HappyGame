--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPetRoleDizzyState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/10
-- descrip:   战斗中其他玩家宠物角色眩晕状态
--===================================================
local BattleOtherPetRoleDizzyState = class("BattleOtherPetRoleDizzyState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPetRoleDizzyState:ctor()
    self._strName = "BattleOtherPetRoleDizzyState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPetRole.kDizzy  -- 状态类型ID
end

-- 创建函数
function BattleOtherPetRoleDizzyState:create()
    local state = BattleOtherPetRoleDizzyState.new()
    return state
end

-- 进入函数
function BattleOtherPetRoleDizzyState:onEnter(args)
    --print(self:getMaster()._strCharTag.."宠物角色眩晕状态")
    -- mmo.DebugHelper:showJavaLog("--STATE--PET--:Dizzy")
    if self:getMaster() then
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
function BattleOtherPetRoleDizzyState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        -- 待完善
    end
    return
end

-- 更新逻辑
function BattleOtherPetRoleDizzyState:update(dt)     
    return
end

return BattleOtherPetRoleDizzyState
