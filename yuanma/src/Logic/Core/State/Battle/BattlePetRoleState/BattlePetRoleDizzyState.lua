--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePetRoleDizzyState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   战斗中玩家宠物角色眩晕状态
--===================================================
local BattlePetRoleDizzyState = class("BattlePetRoleDizzyState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePetRoleDizzyState:ctor()
    self._strName = "BattlePetRoleDizzyState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePetRole.kDizzy  -- 状态类型ID
end

-- 创建函数
function BattlePetRoleDizzyState:create()
    local state = BattlePetRoleDizzyState.new()
    return state
end

-- 进入函数
function BattlePetRoleDizzyState:onEnter(args)
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
function BattlePetRoleDizzyState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        -- 待完善
    end
    return
end

-- 更新逻辑
function BattlePetRoleDizzyState:update(dt)     
    return
end

return BattlePetRoleDizzyState
