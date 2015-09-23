--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDoWhenAngerIsReadyPassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   怒气技能CD准备就绪时passive
--===================================================
local BattleDoWhenAngerIsReadyPassiveController = class("BattleDoWhenAngerIsReadyPassiveController",function(master, passiveInfo)
    return require("BattlePassiveController"):create(master, passiveInfo)
end)

-- 构造函数
function BattleDoWhenAngerIsReadyPassiveController:ctor()
    self._strName = "BattleDoWhenAngerIsReadyPassiveController"                      -- Passive对象名称
    self._kTypeID = kType.kController.kPassive.kBattleDoWhenAngerIsReadyPassive      -- 控制类机型ID
    self._nBuffID = 0                                                           -- 产生的buffID
    self._pBuff = nil                                                           -- 对应的buff对象
    
end

-- 创建函数
function BattleDoWhenAngerIsReadyPassiveController:create(master, passiveInfo)
    local controller = BattleDoWhenAngerIsReadyPassiveController.new(master, passiveInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleDoWhenAngerIsReadyPassiveController:dispose()
    self._nBuffID = self._pPassiveInfo.Param1

    return
end

-- 进入函数
function BattleDoWhenAngerIsReadyPassiveController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:add()
    
    -- 添加相应buff
    self._pBuff = self._pMaster:addBuffByID(self._nBuffID)
    
    return
end

-- 退出函数
function BattleDoWhenAngerIsReadyPassiveController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tPassiveRefs[self._kTypeID]:sub() 
    
    return
end

-- 循环更新
function BattleDoWhenAngerIsReadyPassiveController:update(dt)
    self:updateBattlePassive(dt)
    
    -- 实时监控，如果当前角色怒气不为满，则立即取消相应buff，否则，buff一直存在
    if self._pMaster._nCurAnger < self._pMaster._nAngerMax then
        self:cancel()
    end
    
end

-- 手动取消buff
function BattleDoWhenAngerIsReadyPassiveController:cancel() 
    if self._bEnable == true then
        self._pBuff:cancel()
        self._bEnable = false
    end
end

return BattleDoWhenAngerIsReadyPassiveController
