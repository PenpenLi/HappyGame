--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldEntityNormalState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/8
-- descrip:   世界中实体正常状态
--===================================================
local WorldEntityNormalState = class("WorldEntityNormalState",function()
    return require("State"):create()
end)

-- 构造函数
function WorldEntityNormalState:ctor()
    self._strName = "WorldEntityNormalState"           -- 状态名称
    self._kTypeID = kType.kState.kWorldEntity.kNormal  -- 状态类型ID
end

-- 创建函数
function WorldEntityNormalState:create()
    local state = WorldEntityNormalState.new()
    return state
end

-- 进入函数
function WorldEntityNormalState:onEnter(args)
    --print(self._strName.." is onEnter!")    
    
    -- 刷新动作
    if self:getMaster() then
        self:getMaster():playNormalAction()
    end
    return
end

-- 退出函数
function WorldEntityNormalState:onExit()
    --print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function WorldEntityNormalState:update(dt)
    return
end

return WorldEntityNormalState
