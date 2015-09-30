--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleAddHpBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/16
-- descrip:   持续加血Buff
--===================================================
local BattleAddHpBuffController = class("BattleAddHpBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleAddHpBuffController:ctor()
    self._strName = "BattleAddHpBuffController"                 -- Buff对象名称
    self._strAniName = ""                                       -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleAddHpBuff    -- 控制类机型ID
    self._fTimeMax = 0                                          -- 持续时间
    self._fAddHpValue = 0                                       -- 每秒回生命值
    self._fAddHpOnLostHpRate = 0                                -- 每秒恢复目标已损失生命值的比率

end

-- 创建函数
function BattleAddHpBuffController:create(master, buffInfo)
    local controller = BattleAddHpBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleAddHpBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "ParticleHeal.plist"  -- 粒子
    self._fTimeMax = self._pBuffInfo.Param1    
    self._fAddHpValue = self._pBuffInfo.Param2
    self._fAddHpOnLostHpRate = self._pBuffInfo.Param3
    
    return
end

-- 进入函数
function BattleAddHpBuffController:onEnter()
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
    
    -- 添加动作
    local timeUp = function()
        self._pAni:stopSystem()
    end
    local disappearOver = function()
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fTimeMax+0.1),cc.CallFunc:create(timeUp),cc.DelayTime:create(1.0), cc.CallFunc:create(disappearOver)))
    
    local addHp = function()
    	if self._pAni:isActive() == true then
    	   self._pMaster:beHurtedByBuff(self)
           --print("buff回血"..self._nID.."  最大时间"..self._fTimeMax)
    	end
    end
    -- 每隔1s回血一次
    local times = math.modf(self._fTimeMax)
    self._pAni:runAction(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(addHp)),times))   
    
    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleAddHpBuffController:onExit()
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
function BattleAddHpBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleAddHpBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
        
    end

end


return BattleAddHpBuffController
