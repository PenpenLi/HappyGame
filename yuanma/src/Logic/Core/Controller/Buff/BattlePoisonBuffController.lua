--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePoisonBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/16
-- descrip:   中毒Buff
--===================================================
local BattlePoisonBuffController = class("BattlePoisonBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattlePoisonBuffController:ctor()
    self._strName = "BattlePoisonBuffController"        -- Buff对象名称
    self._strAniName = ""                               -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattlePoisonBuff -- 控制类机型ID
    self._fTimeMax = 0                                  -- 持续时间
    self._fHurtValue = 0                                -- 每秒减少生命值
    
end

-- 创建函数
function BattlePoisonBuffController:create(master, buffInfo)
    local controller = BattlePoisonBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattlePoisonBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "ParticlePoison.plist"  -- 粒子
    self._fTimeMax = self._pBuffInfo.Param1*(1 - self._pMaster._fDebuffTimeRate)
    self._fHurtValue = self._pBuffInfo.Param2
    
    return
end

-- 进入函数
function BattlePoisonBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建粒子特效
    self._pAni = cc.ParticleSystemQuad:create(self._strAniName)
    self._pAniParent = cc.ParticleBatchNode:createWithTexture(self._pAni:getTexture())
    self._pAni:setPositionType(cc.POSITION_TYPE_GROUPED)
    self._pAniParent:addChild(self._pAni)
    self._pMaster:addChild(self._pAniParent)
    
    -- 添加动作
    local timeUp = function()
        self._pAni:stopSystem()
    end
    local disappearOver = function()
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fTimeMax+0.1),cc.CallFunc:create(timeUp),cc.DelayTime:create(1.0), cc.CallFunc:create(disappearOver)))
    
    local hurt = function()
    	if self._pAni:isActive() == true then
    	   self._pMaster:beHurtedByBuff(self)
           --print("buff伤害"..self._nID.."  最大时间"..self._fTimeMax)
    	end
    end
    -- 每隔1s掉血一次
    local times = math.modf(self._fTimeMax)
    self._pAni:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(hurt)),times))   
    
    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattlePoisonBuffController:onExit()
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
function BattlePoisonBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattlePoisonBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattlePoisonBuffController
