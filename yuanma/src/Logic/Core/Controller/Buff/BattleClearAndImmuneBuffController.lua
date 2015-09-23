--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleClearAndImmuneBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/17
-- descrip:   异常抵抗 Buff(免疫异常)
--===================================================
local BattleClearAndImmuneBuffController = class("BattleClearAndImmuneBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleClearAndImmuneBuffController:ctor()
    self._strName = "BattleClearAndImmuneBuffController"        -- Buff对象名称
    self._strAniName = ""                                       -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleClearAndImmuneBuff -- 控制类机型ID
    self._fTimeMax = 0                                          -- 持续时间
    
end

-- 创建函数
function BattleClearAndImmuneBuffController:create(master, buffInfo)
    local controller = BattleClearAndImmuneBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleClearAndImmuneBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "ParticleImmune.plist"  -- 粒子
    self._fTimeMax = self._pBuffInfo.Param1
    
    return
end

-- 进入函数
function BattleClearAndImmuneBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建粒子特效
    self._pAni = cc.ParticleSystemQuad:create(self._strAniName)
    self._pAniParent = cc.ParticleBatchNode:createWithTexture(self._pAni:getTexture())
    self._pAni:setPositionType(cc.POSITION_TYPE_GROUPED)
    self._pAniParent:addChild(self._pAni)
    self._pAniPos = function() return cc.p(0,self._pMaster:getHeight()/2) end
    self._pAniParent:setPosition(self._pAniPos())
    self._pMaster:addChild(self._pAniParent)
    
    -- 取消所有debuff（debuff包括：属性状态—灼烧   属性状态—寒冷  属性状态—雷击  晕眩  中毒  属性弱化 减速）
    self._pOwnerMachine:cancelAllDebuffs()
    
    -- 添加动作
    local timeUp = function()
        self._pAni:stopSystem()
    end
    local disappearOver = function()
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fTimeMax+0.1),cc.CallFunc:create(timeUp),cc.DelayTime:create(1.0), cc.CallFunc:create(disappearOver)))
    
    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleClearAndImmuneBuffController:onExit()
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
function BattleClearAndImmuneBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleClearAndImmuneBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattleClearAndImmuneBuffController
