--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleRigidBodyBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/17
-- descrip:   钢体Buff
--===================================================
local BattleRigidBodyBuffController = class("BattleRigidBodyBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleRigidBodyBuffController:ctor()
    self._strName = "BattleRigidBodyBuffController"         -- Buff对象名称
    self._strAniName = ""                                   -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleRigidBodyBuff  -- 控制类机型ID
    self._fTimeMax = 0                                      -- 持续时间
    self._fAddDefenseValue = 0                              -- 提升的防御等级的点数
    
end

-- 创建函数
function BattleRigidBodyBuffController:create(master, buffInfo)
    local controller = BattleRigidBodyBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleRigidBodyBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "ParticleRigidBody.plist"  -- 粒子
    self._fTimeMax = self._pBuffInfo.Param1
    self._fAddDefenseValue = self._pBuffInfo.Param2

    return
end

-- 进入函数
function BattleRigidBodyBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建粒子特效
    self._pAni = cc.ParticleSystemQuad:create(self._strAniName)
    self._pAniParent = cc.ParticleBatchNode:createWithTexture(self._pAni:getTexture())
    self._pAni:setPositionType(cc.POSITION_TYPE_GROUPED)
    self._pAniParent:addChild(self._pAni)
    self._pMaster:addChild(self._pAniParent)
    
    -- 添加防御等级提升值
    self._pMaster:addDefenseLevelOffset(self._fAddDefenseValue)
    
    -- 添加动作
    local timeUp = function()
        self._pAni:stopSystem()
    end
    local disappearOver = function()
        -- 恢复防御等级
        self._pMaster:addDefenseLevelOffset(-self._fAddDefenseValue)
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fTimeMax+0.1),cc.CallFunc:create(timeUp),cc.DelayTime:create(1.0), cc.CallFunc:create(disappearOver)))

    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleRigidBodyBuffController:onExit()
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
function BattleRigidBodyBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleRigidBodyBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattleRigidBodyBuffController
