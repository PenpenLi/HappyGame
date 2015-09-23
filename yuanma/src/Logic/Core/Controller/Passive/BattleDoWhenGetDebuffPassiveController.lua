--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDoWhenGetDebuffPassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   受到异常buff的passive
--===================================================
local BattleDoWhenGetDebuffPassiveController = class("BattleDoWhenGetDebuffPassiveController",function(master, passiveInfo)
    return require("BattlePassiveController"):create(master, passiveInfo)
end)

-- 构造函数
function BattleDoWhenGetDebuffPassiveController:ctor()
    self._strName = "BattleDoWhenGetDebuffPassiveController"                      -- Passive对象名称
    self._kTypeID = kType.kController.kPassive.kBattleDoWhenGetDebuffPassive      -- 控制类机型ID
    self._nBuffID = 0                                                             -- 产生的buffID
    self._pBuff = nil                                                             -- 对应的buff对象
    
end

-- 创建函数
function BattleDoWhenGetDebuffPassiveController:create(master, passiveInfo)
    local controller = BattleDoWhenGetDebuffPassiveController.new(master, passiveInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleDoWhenGetDebuffPassiveController:dispose()
    self._nBuffID = self._pPassiveInfo.Param1
    
    return
end

-- 进入函数
function BattleDoWhenGetDebuffPassiveController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:add()
    
    -- 添加相应buff
    self._pBuff = self._pMaster:addBuffByID(self._nBuffID)
    self._bEnable = false

    return
end

-- 退出函数
function BattleDoWhenGetDebuffPassiveController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:sub() 
    
    return
end

-- 循环更新
function BattleDoWhenGetDebuffPassiveController:update(dt)
    self:updateBattlePassive(dt)
    
end

-- 手动取消buff
function BattleDoWhenGetDebuffPassiveController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
    end
end

return BattleDoWhenGetDebuffPassiveController
