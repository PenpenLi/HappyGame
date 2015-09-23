--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldEntityStateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/8
-- descrip:   世界中实体状态机
--===================================================
local WorldEntityStateMachine = class("WorldEntityStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function WorldEntityStateMachine:ctor()
    self._strName = "WorldEntityStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kWorldEntity  -- 状态类机型ID
end

-- 创建函数
function WorldEntityStateMachine:create(master)
    local machine = WorldEntityStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function WorldEntityStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    
    self:setMaster(master)
    
    self:addState(require("WorldEntityNormalState"):create())  -- 加入正常状态到状态机
    self:setCurStateByTypeID(kType.kState.kWorldEntity.kNormal)  -- 设置当前状态为正常状态
    return
end

-- 退出函数
function WorldEntityStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function WorldEntityStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

return WorldEntityStateMachine
