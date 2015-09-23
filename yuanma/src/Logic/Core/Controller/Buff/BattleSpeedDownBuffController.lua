--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSpeedDownBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/16
-- descrip:   减速Buff
--===================================================
local BattleSpeedDownBuffController = class("BattleSpeedDownBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleSpeedDownBuffController:ctor()
    self._strName = "BattleSpeedDownBuffController"         -- Buff对象名称
    self._strAniName = ""                                   -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleSpeedDownBuff  -- 控制类机型ID
    self._fSpeedDownTimeMax = 0                             -- 减速持续时间
    self._fSpeedDownRate = 0                                -- 速度下降的比率
    
end

-- 创建函数
function BattleSpeedDownBuffController:create(master, buffInfo)
    local controller = BattleSpeedDownBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleSpeedDownBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "buffs/speedDown.png"      -- 一张图
    self._fSpeedDownTimeMax = self._pBuffInfo.Param1*(1 - self._pMaster._fDebuffTimeRate)
    self._fSpeedDownRate = self._pBuffInfo.Param2
    
    return
end

-- 进入函数
function BattleSpeedDownBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建特效
    self._pAni = cc.Sprite:createWithSpriteFrameName(self._strAniName)
    self._pMaster:addChild(self._pAni)
    
    -- 动画前的参数准备
    self._pAni:setPositionY(self._pAni:getContentSize().height/2)
    self._pAni:setOpacity(0)
    self._pAni:setScale(0)
    
    -- 开始减速
    self._pMaster:setCurSpeedPercent(self._fSpeedDownRate)

    -- 添加动作
    local timeUp = function()
        -- 速度恢复
        self._pMaster:setCurSpeedPercent(1.0/self._fSpeedDownRate)
    end
    local disappearOver = function()
        self._bEnable = false
    end
    local appearAct = cc.Sequence:create(cc.Spawn:create(cc.EaseIn:create(cc.FadeIn:create(0.5),3),cc.EaseIn:create(cc.ScaleTo:create(0.5,1.2,1.2),3)), cc.EaseOut:create(cc.ScaleTo:create(0.1,1,1),3) )
    self._pAni:runAction(cc.Sequence:create(appearAct, cc.DelayTime:create(self._fSpeedDownTimeMax+0.1),cc.CallFunc:create(timeUp),cc.Spawn:create(cc.EaseIn:create(cc.ScaleTo:create(0.3,2.0,2.0),3), cc.EaseIn:create(cc.FadeOut:create(0.3),3)), cc.CallFunc:create(disappearOver)))

    -- 刷新相机
    self._pMaster:refreshCamera()

    return
end

-- 退出函数
function BattleSpeedDownBuffController:onExit()
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
function BattleSpeedDownBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleSpeedDownBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
        --self._pMaster:setCurSpeedPercent(1.0/self._fSpeedDownRate)
        self._pMaster:resetSpeed()
    end

end

return BattleSpeedDownBuffController
