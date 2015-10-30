--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleOtherPlayerRoleFrozenState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/8
-- descrip:   战斗中其他玩家角色冻结状态
--===================================================
local BattleOtherPlayerRoleFrozenState = class("BattleOtherPlayerRoleFrozenState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleOtherPlayerRoleFrozenState:ctor()
    self._strName = "BattleOtherPlayerRoleFrozenState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleOtherPlayerRole.kFrozen  -- 状态类型ID
end

-- 创建函数
function BattleOtherPlayerRoleFrozenState:create()
    local state = BattleOtherPlayerRoleFrozenState.new()
    return state
end

-- 进入函数
function BattleOtherPlayerRoleFrozenState:onEnter(args)
    mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:Frozen")
    if self:getMaster() then
        --print(self:getMaster()._strCharTag.."角色冻结状态")
        -- 复位可能存在的所有技能的动画
        for k,v in pairs(self:getMaster()._tSkills) do 
            v:stopAllActionNodes()
            v._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
        
        -- 刷新动作
        self:getMaster()._pAni:stopActionByTag(nRoleActAction)
        if self:getMaster()._pBack then
            self:getMaster()._pBack:stopAllActions()
        end
    
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
function BattleOtherPlayerRoleFrozenState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then 
        -- 时装背播放动画
        if self:getMaster()._pBack then
            local animation = cc.Animation3D:create(self:getMaster()._strBackTexturePvrName..".c3b")
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self:getMaster()._pBack:runAction(act)
        end
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
function BattleOtherPlayerRoleFrozenState:update(dt)     
    return
end

return BattleOtherPlayerRoleFrozenState
