--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleAttriDownBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/16
-- descrip:   属性弱化Buff
--===================================================
local BattleAttriDownBuffController = class("BattleAttriDownBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleAttriDownBuffController:ctor()
    self._strName = "BattleAttriDownBuffController"           -- Buff对象名称
    self._strAniName = ""                                     -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleAttriDownBuff    -- 控制类机型ID
    self._fTimeMax = 0                                        -- 持续时间
    self._fSubAttriValue = 0                                  -- 属性的点数
    self._kAttriType = kAttribute.kNone                       -- 属性的类型
    
end

-- 创建函数
function BattleAttriDownBuffController:create(master, buffInfo)
    local controller = BattleAttriDownBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleAttriDownBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "ParticleAttriDown.plist"  -- 粒子
    self._fTimeMax = self._pBuffInfo.Param1*(1 - self._pMaster._fDebuffTimeRate)
    self._fSubAttriValue = self._pBuffInfo.Param2
    self._kAttriType = self._pBuffInfo.Param3

    return
end

-- 进入函数
function BattleAttriDownBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建粒子特效
    self._pAni = cc.ParticleSystemQuad:create(self._strAniName)
    self._pAniParent = cc.ParticleBatchNode:createWithTexture(self._pAni:getTexture())
    self._pAni:setPositionType(cc.POSITION_TYPE_GROUPED)
    self._pAniParent:addChild(self._pAni)
    self._pAniPos = function() return cc.p(0,60) end
    self._pAniParent:setPosition(self._pAniPos())
    self._pMaster:addChild(self._pAniParent)
    
    -- 添加属性变化偏移量
    self._pMaster:addAttriValueOffset(self._kAttriType, -self._fSubAttriValue)
    
    -- 添加动作
    local timeUp = function()
        -- 恢复属性变化偏移量
        self._pMaster:addAttriValueOffset(self._kAttriType, self._fSubAttriValue)
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fTimeMax+0.1),cc.CallFunc:create(timeUp)))

    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleAttriDownBuffController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:sub()
    
    self._pAni:stopAllActions()
    if self._pAniParent then
        self._pMaster:removeChild(self._pAniParent,true)
    else
        self._pMaster:removeChild(self._pAni,true)
    end
    
    return
end

-- 循环更新
function BattleAttriDownBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleAttriDownBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
        self._pMaster:addAttriValueOffset(self._kAttriType, self._fSubAttriValue)
    end

end

return BattleAttriDownBuffController
