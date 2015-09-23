--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleHpLimitUpBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/17
-- descrip:   增加血量上限Buff
--===================================================
local BattleHpLimitUpBuffController = class("BattleHpLimitUpBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleHpLimitUpBuffController:ctor()
    self._strName = "BattleHpLimitUpBuffController"         -- Buff对象名称
    self._strAniName = ""                                   -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleHpLimitUpBuff  -- 控制类机型ID
    self._fTimeMax = 0                                      -- 持续时间
    self._fHpLimitUpValue = 0                               -- 提升血量上限的值
    self._fScale = 1.2
    
end

-- 创建函数
function BattleHpLimitUpBuffController:create(master, buffInfo)
    local controller = BattleHpLimitUpBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleHpLimitUpBuffController:dispose()    
    -- 初始化buff信息
    self._fTimeMax = self._pBuffInfo.Param1    
    self._fHpLimitUpValue = self._pBuffInfo.Param2
    
    return
end

-- 进入函数
function BattleHpLimitUpBuffController:onEnter()
        
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 如果已经有了一个这个buff，则直接返回，不会发生叠加
    if self._pOwnerMachine._tBuffRefs[self._kTypeID]:getRefValue() >= 2 then
        self._bEnable = false
        return
    end
    
    -- Hp上限数据提升
    local maxValue = self._pMaster._nHpMax + self._fHpLimitUpValue
    local curValue = self._pMaster._nCurHp + self._fHpLimitUpValue
    self._pMaster:setHp(curValue, maxValue)
    self._pMaster:showNum("+", self._fHpLimitUpValue)
    
    -- bottom和body矩形放大
    self._pMaster._recBottomOnObj.width = self._pMaster._recBottomOnObj.width*self._fScale
    self._pMaster._recBottomOnObj.height = self._pMaster._recBottomOnObj.height*self._fScale
    self._pMaster._recBottomOnObj.x = self._pMaster._recBottomOnObj.x - self._pMaster._recBottomOnObj.width/2
    self._pMaster._recBodyOnObj.width = self._pMaster._recBodyOnObj.width*self._fScale
    self._pMaster._recBodyOnObj.height = self._pMaster._recBodyOnObj.height*self._fScale
    self._pMaster._recBodyOnObj.x = self._pMaster._recBodyOnObj.x - self._pMaster._recBodyOnObj.width/2
    
    -- 放大模型 
    local timeUp = function()       -- 时间到，Hp上限数据恢复
        local maxValue = self._pMaster._nHpMax - self._fHpLimitUpValue
        local curValue = self._pMaster._nCurHp
        if curValue > maxValue then
            curValue = maxValue
        end
        self._pMaster:setHp(curValue, maxValue)
        
        -- bottom和body矩形复原
        self._pMaster._recBottomOnObj.x = self._pMaster._recBottomOnObj.x + (self._pMaster._recBottomOnObj.width/2 - self._pMaster._recBottomOnObj.width/self._fScale/2)  
        self._pMaster._recBottomOnObj.width = self._pMaster._recBottomOnObj.width/self._fScale
        self._pMaster._recBottomOnObj.height = self._pMaster._recBottomOnObj.height/self._fScale
        self._pMaster._recBodyOnObj.x = self._pMaster._recBodyOnObj.x + (self._pMaster._recBodyOnObj.width/2 - self._pMaster._recBodyOnObj.width/self._fScale/2)  
        self._pMaster._recBodyOnObj.width = self._pMaster._recBodyOnObj.width/self._fScale
        self._pMaster._recBodyOnObj.height = self._pMaster._recBodyOnObj.height/self._fScale
        
    end
    local over = function()
        self._bEnable = false
    end
    
    local scaleTo1 = cc.EaseElasticInOut:create(cc.ScaleBy:create(2.0, self._fScale))  -- 放大
    local scaleTo2 = cc.EaseElasticInOut:create(cc.ScaleBy:create(2.0, 1/self._fScale))  -- 缩小
    local act = cc.Sequence:create(scaleTo1, cc.DelayTime:create(self._fTimeMax), cc.CallFunc:create(timeUp), scaleTo2, cc.CallFunc:create(over))
    self._pMaster._pAni:runAction(act)
    
    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleHpLimitUpBuffController:onExit()

    -- 引用计数-1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:sub()  

    return
end

-- 循环更新
function BattleHpLimitUpBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleHpLimitUpBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattleHpLimitUpBuffController
