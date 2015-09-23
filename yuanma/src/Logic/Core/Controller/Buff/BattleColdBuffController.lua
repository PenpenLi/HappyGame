--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleColdBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/13
-- descrip:   寒冷Buff   -  属性状态
--===================================================
local BattleColdBuffController = class("BattleColdBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleColdBuffController:ctor()
    self._strName = "BattleColdBuffController"          -- Buff对象名称
    self._strAniName = ""                               -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleColdBuff   -- 控制类机型ID
    self._fSpeedDownTimeMax = 0                         -- 减速持续时间
    self._fSpeedDownRate = 0                            -- 速度下降的比率
    self._fFrozenTimeMax = 0                            -- 冰冻持续时间
    self._bIsFrozening = false                          -- 是否处于冰冻阶段
    self._pColor = cc.c3b(96,252,248)                   -- 冰冻buff的颜色
    
end

-- 创建函数
function BattleColdBuffController:create(master, buffInfo)
    local controller = BattleColdBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleColdBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "buffs/ice.png"      -- 一张图
    self._fSpeedDownTimeMax = self._pBuffInfo.Param1    
    self._fSpeedDownRate = self._pBuffInfo.Param2
    self._fFrozenTimeMax = self._pBuffInfo.Param3*(1 - self._pMaster._fDebuffTimeRate)
    
    return
end

-- 进入函数
function BattleColdBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建冰冻特效
    self._pAni = cc.Sprite:createWithSpriteFrameName(self._strAniName)
    self._pAni:setAnchorPoint(cc.p(0.5,0))
    self._pMaster:addChild(self._pAni)
    
    -- 创建粒子
    local light = cc.ParticleSystemQuad:create("ParticleIce.plist")
    local lightParent = cc.ParticleBatchNode:createWithTexture(light:getTexture())
    light:setPositionType(cc.POSITION_TYPE_GROUPED)
    lightParent:addChild(light)
    lightParent:setPosition(self._pAni:getBoundingBox().width/2, self._pAni:getBoundingBox().height/2)
    self._pAni:addChild(lightParent)
    
    -- 设置buff颜色
    self._pOwnerMachine:setColor(self._pColor)
    
    -- 动画前的参数准备
    self._pAni:setPositionY(-30)
    self._pAni:setOpacity(0)
    self._pAni:setScale(0)
    self._pAni:setRotation(0)
    
    -- 开始减速
    self._pMaster:setCurSpeedPercent(self._fSpeedDownRate)
    -- 减速结束时间到
    local speedDownTimeUp = function()
        -- 切换角色到冻结状态
        self._pOwnerMachine:refreshToFrozen()
        -- 冻结中标记
        self._bIsFrozening = true
        
    end
    --冰冻解除
    local iceFrozenTimeUp = function()
        local iceDisappearOver = function()
            self._pMaster:setCurSpeedPercent(1.0/self._fSpeedDownRate)
            self._bEnable = false
        end
        self._pAni:runAction(cc.Sequence:create(cc.EaseIn:create(cc.FadeOut:create(0.2),6),cc.Hide:create(), cc.CallFunc:create(iceDisappearOver) ))
    end
    -- 出现冰冻
    local scaleValue = ( self._pMaster:getHeight() + 50 )/self._pAni:getContentSize().height
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fSpeedDownTimeMax),cc.CallFunc:create(speedDownTimeUp),
                            cc.Spawn:create(cc.EaseIn:create(cc.FadeIn:create(0.2),6), cc.EaseIn:create(cc.ScaleTo:create(0.2,scaleValue+0.2),6)),
                            cc.Spawn:create(cc.ScaleTo:create(0.05,scaleValue-0.1),cc.RotateBy:create(0.05,5)),
                            cc.Spawn:create(cc.ScaleTo:create(0.05,scaleValue+0.1),cc.RotateBy:create(0.05,-10)),
                            cc.Spawn:create(cc.ScaleTo:create(0.03,scaleValue),cc.RotateBy:create(0.05,5)),
                            cc.MoveBy:create(0.02,cc.p(-10,0)),
                            cc.MoveBy:create(0.02,cc.p(20,0)),
                            cc.MoveBy:create(0.02,cc.p(-20,0)),
                            cc.MoveBy:create(0.02,cc.p(20,0)),
                            cc.MoveBy:create(0.02,cc.p(-20,0)),
                            cc.MoveBy:create(0.02,cc.p(20,0)),
                            cc.MoveBy:create(0.02,cc.p(-10,0)),
                            cc.DelayTime:create(self._fFrozenTimeMax),
                            cc.CallFunc:create(iceFrozenTimeUp)
                            ))
    -- 刷新相机
    self._pMaster:refreshCamera()

    return
end

-- 退出函数
function BattleColdBuffController:onExit()
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
    -- 除了指定buff以外的剩余所有buff中，根据是否存在影响角色正常恢复到站立状态的buff而自动刷新人物状态
    self._pOwnerMachine:refreshToStandExcept(self)

    return
end

-- 循环更新
function BattleColdBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleColdBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
        self._pMaster:setCurSpeedPercent(1.0/self._fSpeedDownRate)
        self._bIsFrozening = true
    end

end

return BattleColdBuffController
