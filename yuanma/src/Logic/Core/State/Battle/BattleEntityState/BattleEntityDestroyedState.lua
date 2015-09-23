--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleEntityDestroyedState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/27
-- descrip:   战斗中实体被摧毁状态
--===================================================
local BattleEntityDestroyedState = class("BattleEntityDestroyedState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleEntityDestroyedState:ctor()
    self._strName = "BattleEntityDestroyedState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleEntity.kDestroy    -- 状态类型ID
end

-- 创建函数
function BattleEntityDestroyedState:create()
    local state = BattleEntityDestroyedState.new()
    return state
end

-- 进入函数
function BattleEntityDestroyedState:onEnter(args)
    --print(self._strName.." is onEnter!")        
    
    -- 刷新动作
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("mmo:BattleEntityDestroyedState")
        self:getMaster():playDestroyedAction()
        
        self:getMaster()._pAni:runAction(cc.TintTo:create(0.2, 255, 255, 255)) 

        local function destroyedOver()
            self:getMaster():removeAllEffects()-- 移除所有特效            
            self:getMaster()._bActive = false  -- 实体等待管理器删除回收
            self:getMaster()._pAni = nil
            self._pOwnerMachine._pMaster = nil
        end
        local duration = 0.0
        if self:getMaster()._kEntityType == kType.kEntity.kBomb then
            duration = 0.4
        else
            duration = 1.5
        end
        self:getMaster()._pAni:runAction(cc.Sequence:create(cc.FadeOut:create(duration),cc.CallFunc:create(destroyedOver)))        
        
        -- 复位技能状态
        if self:getMaster()._pSkill then
           self:getMaster()._pSkill:stopAllActionNodes()
           self:getMaster()._pSkill:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill):setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
           self:getMaster()._pSkill._pMaster = nil
           self:getMaster()._pSkill._pAni = nil
           self:getMaster()._pSkill._bActive = false  -- 技能等待管理器删除回收
        end
        self:getMaster()._pSkill = nil
        
        -- 摧毁的声音
        AudioManager:getInstance():playEffect(self:getMaster()._tTempleteInfo.DestroyedSound)
    end
    return
end

-- 退出函数
function BattleEntityDestroyedState:onExit()
    --print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function BattleEntityDestroyedState:update(dt)
    return
end

return BattleEntityDestroyedState
