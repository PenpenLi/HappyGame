--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDoWhenBeSafePassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   未被攻击x秒钟时passive
--===================================================
local BattleDoWhenBeSafePassiveController = class("BattleDoWhenBeSafePassiveController",function(master, passiveInfo)
    return require("BattlePassiveController"):create(master, passiveInfo)
end)

-- 构造函数
function BattleDoWhenBeSafePassiveController:ctor()
    self._strName = "BattleDoWhenBeSafePassiveController"                      -- Passive对象名称
    self._kTypeID = kType.kController.kPassive.kBattleDoWhenBeSafePassive      -- 控制类机型ID
    self._fTimeMax = 0                                                         -- 等待时间间隔
    self._nBuffID = 0                                                          -- 产生的buffID
    self._pBuff = nil                                                          -- 对应的buff对象

end

-- 创建函数
function BattleDoWhenBeSafePassiveController:create(master, passiveInfo)
    local controller = BattleDoWhenBeSafePassiveController.new(master, passiveInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleDoWhenBeSafePassiveController:dispose()
    self._fTimeMax = self._pPassiveInfo.Param1
    self._nBuffID = self._pPassiveInfo.Param2

    return
end

-- 进入函数
function BattleDoWhenBeSafePassiveController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:add()

    -- 添加相应buff
    self._pBuff = self._pMaster:addBuffByID(self._nBuffID)
    self._bEnable = false

    return
end

-- 退出函数
function BattleDoWhenBeSafePassiveController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:sub() 

    return
end

-- 循环更新
function BattleDoWhenBeSafePassiveController:update(dt)
    self:updateBattlePassive(dt)

end

-- 手动取消buff
function BattleDoWhenBeSafePassiveController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
    end
end

return BattleDoWhenBeSafePassiveController
