--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDoWhenHpBelowPassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   血量低于多少时passive
--===================================================
local BattleDoWhenHpBelowPassiveController = class("BattleDoWhenHpBelowPassiveController",function(master, passiveInfo)
    return require("BattlePassiveController"):create(master, passiveInfo)
end)

-- 构造函数
function BattleDoWhenHpBelowPassiveController:ctor()
    self._strName = "BattleDoWhenHpBelowPassiveController"                      -- Passive对象名称
    self._kTypeID = kType.kController.kPassive.kBattleDoWhenHpBelowPassive      -- 控制类机型ID
    self._fHpBelowPercent = 0                                                   -- 低于血量的百分比
    self._nBuffID = 0                                                           -- 产生的buffID
    self._pBuff = nil                                                           -- 对应的buff对象
    
end

-- 创建函数
function BattleDoWhenHpBelowPassiveController:create(master, passiveInfo)
    local controller = BattleDoWhenHpBelowPassiveController.new(master, passiveInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleDoWhenHpBelowPassiveController:dispose()
    self._fHpBelowPercent = self._pPassiveInfo.Param1
    self._nBuffID = self._pPassiveInfo.Param2
    
    return
end

-- 进入函数
function BattleDoWhenHpBelowPassiveController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:add()
    
    -- 添加相应buff（该buff会长期有效）
    self._pBuff = self._pMaster:addBuffByID(self._nBuffID)
    
    return
end

-- 退出函数
function BattleDoWhenHpBelowPassiveController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:sub()  
    
    return
end

-- 循环更新
function BattleDoWhenHpBelowPassiveController:update(dt)
    self:updateBattlePassive(dt)
    
    -- 实时监控，如果当前角色血量已经高于限定血量，则立即取消相应buff，否则，buff一直存在
    if self._pMaster._nCurHp / self._pMaster._nHpMax > self._fHpBelowPercent then
        self:cancel()   -- 取消buff
    end
    
end

-- 手动取消buff
function BattleDoWhenHpBelowPassiveController:cancel() 
    if self._bEnable == true then
        self._pBuff:cancel()
        self._bEnable = false
    end

end

return BattleDoWhenHpBelowPassiveController
