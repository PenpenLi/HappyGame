--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Controller.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   控制基类
--===================================================
local Controller = class("Controller")

-- 构造函数
function Controller:ctor()
    self._strName = "Controller"                        -- 控制名称
    self._nID = 0                                       -- ID
    self._kTypeID = kType.kController.kNone             -- 控制类型ID
    self._bEnable = true                                -- 是否可用（默认不可用）
    self._pOwnerMachine = nil                           -- 所归属的控制机
    
end

-- 创建函数
function Controller:create()
    local controller = Controller.new()
    controller._nID = nBattleBuffID
    nBattleBuffID = nBattleBuffID + 1
    return controller
end

-- 进入函数
function Controller:onEnter()
    print(self._strName.." is onEnter!")
    return
end

-- 退出函数
function Controller:onExit()
    print(self._strName.." is onExit!")
    return
end

-- 更新逻辑
function Controller:update(dt)
    if self._bEnable == false then return end

    return
end

-- 获取当前控制的持有者（主人）
function Controller:getMaster()
    return self._pOwnerMachine:getMaster()
end

-- 设置是否可用
function Controller:setEnable(enable)
    if self._bEnable == enable then return end

    if enable == true then
        if self._pOwnerMachine._bEnable == true then
            self._bEnable = enable
            print(self._strName.." is Enabled!")
            self:onEnter()
        else
            print(self._strName.." can't Enabled because "..self._pOwnerMachine._strName.." is UnEnabled!")
        end
    else
        if self._pOwnerMachine._bEnable == true then
            self._bEnable = enable
            print(self._strName.." is UnEnabled!")
            self:onExit()
        else
            print(self._strName.." can't UnEnabled because "..self._pOwnerMachine._strName.." is UnEnabled!")
        end
    end
end

return Controller
