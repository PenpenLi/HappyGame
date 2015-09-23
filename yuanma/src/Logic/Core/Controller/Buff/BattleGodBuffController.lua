--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleGodBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/16
-- descrip:   无敌Buff
--===================================================
local BattleGodBuffController = class("BattleGodBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleGodBuffController:ctor()
    self._strName = "BattleGodBuffController"               -- Buff对象名称
    self._strAniName = ""                                   -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleGodBuff        -- 控制类机型ID
    self._fTimeMax = 0                                      -- 持续时间
    self._pColor = cc.c3b(255,255,0)                        -- 无敌buff的颜色
    
end

-- 创建函数
function BattleGodBuffController:create(master, buffInfo)
    local controller = BattleGodBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleGodBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "ParticleGod.plist"      -- 粒子
    self._fTimeMax = self._pBuffInfo.Param1

    return
end

-- 进入函数
function BattleGodBuffController:onEnter()
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
    
    -- 设置buff颜色
    self._pOwnerMachine:setColor(self._pColor)
    
    -- 无视伤害引用计数+1
    self._pMaster._pRefNotLoseHp:add()

    -- 添加动作
    local timeUp = function()
        -- 无视伤害引用计数-1
        self._pMaster._pRefNotLoseHp:sub()
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
function BattleGodBuffController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:sub()

    self._pAni:stopAllActions()
    if self._pAniParent then
        self._pMaster:removeChild(self._pAniParent,true)
    else
        self._pMaster:removeChild(self._pAni,true)
    end
    
    -- 设置除了指定buff以外的最近一次的颜色
    self._pOwnerMachine:setLastColorExcept(self)
    
    return
end

-- 循环更新
function BattleGodBuffController:update(dt)
    self:updateBattleBuff(dt)
    
    --print("主角位置: X = "..self._pMaster:getPositionX().." Y = "..self._pMaster:getPositionY())
    --print("粒子位置: X = "..self._pAniParent:getPositionX().." Y = "..self._pAniParent:getPositionY())
    
end

-- 手动取消buff
function BattleGodBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattleGodBuffController
