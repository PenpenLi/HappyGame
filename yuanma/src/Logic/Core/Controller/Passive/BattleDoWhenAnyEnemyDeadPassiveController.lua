--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDoWhenAnyEnemyDeadPassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   每杀死一个敌方单位passive
--===================================================
local BattleDoWhenAnyEnemyDeadPassiveController = class("BattleDoWhenAnyEnemyDeadPassiveController",function(master, passiveInfo)
    return require("BattlePassiveController"):create(master, passiveInfo)
end)

-- 构造函数
function BattleDoWhenAnyEnemyDeadPassiveController:ctor()
    self._strName = "BattleDoWhenAnyEnemyDeadPassiveController"                      -- Passive对象名称
    self._kTypeID = kType.kController.kPassive.kBattleDoWhenAnyEnemyDeadPassive      -- 控制类机型ID
    self._nBuffID = 0                                                                -- 产生的buffID
    self._pBuff = nil                                                                -- 对应的buff对象
    
end

-- 创建函数
function BattleDoWhenAnyEnemyDeadPassiveController:create(master, passiveInfo)
    local controller = BattleDoWhenAnyEnemyDeadPassiveController.new(master, passiveInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleDoWhenAnyEnemyDeadPassiveController:dispose()
    self._nBuffID = self._pPassiveInfo.Param1
    
    return
end

-- 进入函数
function BattleDoWhenAnyEnemyDeadPassiveController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:add()
    
    -- 添加相应buff
    self._pBuff = self._pMaster:addBuffByID(self._nBuffID)
    self._bEnable = false

    return
end

-- 退出函数
function BattleDoWhenAnyEnemyDeadPassiveController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:sub() 
    
    return
end

-- 循环更新
function BattleDoWhenAnyEnemyDeadPassiveController:update(dt)
    self:updateBattlePassive(dt)
    
end

-- 手动取消buff
function BattleDoWhenAnyEnemyDeadPassiveController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
    end
end

return BattleDoWhenAnyEnemyDeadPassiveController
