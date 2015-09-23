--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleEntityStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗中实体状态机
--===================================================
local BattleEntityStateMachine = class("BattleEntityStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function BattleEntityStateMachine:ctor()
    self._strName = "BattleEntityStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kBattleEntity  -- 状态类机型ID
end

-- 创建函数
function BattleEntityStateMachine:create(master)
    local machine = BattleEntityStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function BattleEntityStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    -- mmo.DebugHelper:showJavaLog("mmo:BattleEntityStateMachine")
    self:setMaster(master)
    self:addState(require("BattleEntityNormalState"):create())      -- 加入正常状态到状态机
    self:addState(require("BattleEntitySkillAttackState"):create()) -- 加入正常状态到状态机
    self:addState(require("BattleEntityDestroyedState"):create())   -- 加入被摧毁状态到状态机
    self:setCurStateByTypeID(kType.kState.kBattleEntity.kNormal)    -- 设置当前状态为正常状态
    return
end

-- 退出函数
function BattleEntityStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function BattleEntityStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

return BattleEntityStateMachine
