--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDoWhenPetDeadPassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   宠物死亡passive
--===================================================
local BattleDoWhenPetDeadPassiveController = class("BattleDoWhenPetDeadPassiveController",function(master, passiveInfo)
    return require("BattlePassiveController"):create(master, passiveInfo)
end)

-- 构造函数
function BattleDoWhenPetDeadPassiveController:ctor()
    self._strName = "BattleDoWhenPetDeadPassiveController"                      -- Passive对象名称
    self._kTypeID = kType.kController.kPassive.kBattleDoWhenPetDeadPassive      -- 控制类机型ID
    self._nBuffID = 0                                                           -- 产生的buffID
    self._pBuff = nil                                                           -- 对应的buff对象
    
end

-- 创建函数
function BattleDoWhenPetDeadPassiveController:create(master, passiveInfo)
    local controller = BattleDoWhenPetDeadPassiveController.new(master, passiveInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleDoWhenPetDeadPassiveController:dispose()
    self._nBuffID = self._pPassiveInfo.Param1
    
    return
end

-- 进入函数
function BattleDoWhenPetDeadPassiveController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:add()
    
    -- 添加相应buff
    self._pBuff = self._pMaster:addBuffByID(self._nBuffID)
    self._bEnable = false

    return
end

-- 退出函数
function BattleDoWhenPetDeadPassiveController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:sub() 
    
    return
end

-- 循环更新
function BattleDoWhenPetDeadPassiveController:update(dt)
    self:updateBattlePassive(dt)
    
end

-- 手动取消buff
function BattleDoWhenPetDeadPassiveController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
    end
end

return BattleDoWhenPetDeadPassiveController
