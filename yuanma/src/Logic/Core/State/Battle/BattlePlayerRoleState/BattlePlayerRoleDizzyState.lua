--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleDizzyState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/14
-- descrip:   战斗中玩家角色眩晕状态
--===================================================
local BattlePlayerRoleDizzyState = class("BattlePlayerRoleDizzyState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleDizzyState:ctor()
    self._strName = "BattlePlayerRoleDizzyState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kDizzy  -- 状态类型ID
end

-- 创建函数
function BattlePlayerRoleDizzyState:create()
    local state = BattlePlayerRoleDizzyState.new()
    return state
end

-- 进入函数
function BattlePlayerRoleDizzyState:onEnter(args)
    mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:Dizzy")
    if self:getMaster() then
        --print(self:getMaster()._strCharTag.."角色眩晕状态")
        -- 复位可能存在的所有技能的动画
        for k,v in pairs(self:getMaster()._tSkills) do 
            v:stopAllActionNodes()
            v._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
        
        -- 刷新动作
        self:getMaster():playDizzyAction()
    
        -- 摇杆禁用
        self:getMaster()._refStick:add()
        
        -- 普通攻击按钮禁用
        self:getMaster()._refGenAttackButton:add()
        
        -- 技能按钮禁用
        for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
            self:getMaster()._tRefSkillButtons[i]:add()
        end
    end
    return
end

-- 退出函数
function BattlePlayerRoleDizzyState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        -- 摇杆恢复
        self:getMaster()._refStick:sub()
        -- 普通攻击按钮恢复
        self:getMaster()._refGenAttackButton:sub()
        -- 技能按钮禁用
        for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
            self:getMaster()._tRefSkillButtons[i]:sub()
        end 
    end
    
    return
end

-- 更新逻辑
function BattlePlayerRoleDizzyState:update(dt)     
    return
end

return BattlePlayerRoleDizzyState
