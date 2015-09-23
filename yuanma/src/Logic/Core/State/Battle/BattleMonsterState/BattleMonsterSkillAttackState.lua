--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterSkillAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/23
-- descrip:   战斗中怪物角色技能攻击状态
--===================================================
local BattleMonsterSkillAttackState = class("BattleMonsterSkillAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterSkillAttackState:ctor()
    self._strName = "BattleMonsterSkillAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kSkillAttack  -- 状态类型ID
    
    self._pCurSkill = nil                                     -- 当前正在使用的技能对象 
    self._nCurSkillIndexInChain = 1                           -- 当前正在使用的技能在技能链中的index
    self._bToNextSkill = false                                -- 用于标记是否需要开始释放下一个技能(该标记位在野怪技能中设置)
end

-- 创建函数
function BattleMonsterSkillAttackState:create()
    local state = BattleMonsterSkillAttackState.new()
    return state
end

-- 进入函数
function BattleMonsterSkillAttackState:onEnter(args)
    -- 从确定好的技能链中第一个技能开始使用 
    self._nCurSkillIndexInChain = 1
    
    if self:getMaster() then
        -- 确定第一个要使用的技能
        self._pCurSkill = self:getMaster()._tReverseIDSkills[self:getMaster()._tCurSkillChain[self._nCurSkillIndexInChain]]
        
        -- mmo.DebugHelper:showJavaLog("--STATE--MONSTER--:SkillAttack "..self._pCurSkill._strName)
        
        -- 刷新方向（考虑野怪是否有指定转向）
        if TableTempleteMonster[self:getMaster()._pRoleInfo.TempleteID].AppointedRotation == -1 then
            self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self._pCurSkill)
        end
        
        -- 开始使用技能
        self._pCurSkill:onUse()
        
        -- 将当前技能的防御等级赋给当前的防御等级
        self:getMaster()._pCurDefLevel = self._pCurSkill._pSkillInfo.DefenseLevel
        
        -- 检测遮挡
        self:getMaster():checkCover()
    
    end

    return
end

-- 退出函数
function BattleMonsterSkillAttackState:onExit()
    if self:getMaster() then
        -- 将当前当前的防御等级为默认自身的防御等级
        self:getMaster()._pCurDefLevel = TableTempleteMonster[self:getMaster()._pRoleInfo.TempleteID].DefenseLevel
    end
    -- 复位本次攻击缓存的技能链相关信息
    self._pCurSkill = nil
    self._nCurSkillIndexInChain = 1
    self._bToNextSkill = false
    
    return
end

-- 更新逻辑
function BattleMonsterSkillAttackState:update(dt)
    if self:getMaster() then
        if self._bToNextSkill == true and self:getMaster()._nCurHp > 0 then
            -- 标记位复位
            self._bToNextSkill = false
            if self._nCurSkillIndexInChain < table.getn(self:getMaster()._tCurSkillChain) then
                -- 从确定好的技能链中确定下一个准备使用的技能的index
                self._nCurSkillIndexInChain = self._nCurSkillIndexInChain + 1
                -- 确定下一个要使用的技能对象
                self._pCurSkill = self:getMaster()._tReverseIDSkills[self:getMaster()._tCurSkillChain[self._nCurSkillIndexInChain]]
                -- mmo.DebugHelper:showJavaLog("--STATE--MONSTER--:SkillAttack "..self._pCurSkill._strName)
                self._pCurSkill:onUse()
                -- 将当前技能的防御等级赋给当前的防御等级
                if self:getMaster() then
                    self:getMaster()._pCurDefLevel = self._pCurSkill._pSkillInfo.DefenseLevel
                end
            else
                -- 当前技能链中的技能已经全部释放完，人物状态机切入待机状态
                if self:getMaster() then
                    self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
                end
            end
        end    
    end

    return
end

return BattleMonsterSkillAttackState
