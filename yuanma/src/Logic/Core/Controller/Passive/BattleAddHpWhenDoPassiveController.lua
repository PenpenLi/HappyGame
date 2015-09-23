--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleAddHpWhenDoPassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   每次发生某行为时恢复血量Passive
--===================================================
local BattleAddHpWhenDoPassiveController = class("BattleAddHpWhenDoPassiveController",function(master, passiveInfo)
    return require("BattlePassiveController"):create(master, passiveInfo)
end)

-- 构造函数
function BattleAddHpWhenDoPassiveController:ctor()
    self._strName = "BattleAddHpWhenDoPassiveController"                      -- Passive对象名称
    self._kTypeID = kType.kController.kPassive.kBattleAddHpWhenDoPassive      -- 控制类机型ID
   -- self._nBuffID1 = 0                                                            -- 产生的buffID
   -- self._nBuffID2 = 0                                                            -- 产生的buffID
   -- self._pBuff1 = nil                                                            -- 对应的buff对象
   -- self._pBuff2 = nil                                                            -- 对应的buff对象
    
end

-- 创建函数
function BattleAddHpWhenDoPassiveController:create(master, passiveInfo)
    local controller = BattleAddHpWhenDoPassiveController.new(master, passiveInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleAddHpWhenDoPassiveController:dispose()

    
    return
end

-- 进入函数
function BattleAddHpWhenDoPassiveController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:add()
    
    return
end

-- 退出函数
function BattleAddHpWhenDoPassiveController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:sub() 
    
    return
end

-- 循环更新
function BattleAddHpWhenDoPassiveController:update(dt)
    self:updateBattlePassive(dt)
    
end

-- 手动取消buff
function BattleAddHpWhenDoPassiveController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
    end
end

return BattleAddHpWhenDoPassiveController
