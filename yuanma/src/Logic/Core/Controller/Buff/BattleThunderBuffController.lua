--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleThunderBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/13
-- descrip:   雷击Buff   -  属性状态
--===================================================
local BattleThunderBuffController = class("BattleThunderBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleThunderBuffController:ctor()
    self._strName = "BattleThunderBuffController"           -- Buff对象名称
    self._strAniName = ""                                   -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleThunderBuff    -- 控制类机型ID
    self._fThunderTimeMax = 0                               -- 麻痹持续时间
    self._fHurtedUpRate = 0                                 -- 伤害增加的比率
    self._pColor = cc.c3b(5,23,135)                         -- 雷击buff的颜色
    
end

-- 创建函数
function BattleThunderBuffController:create(master, buffInfo)
    local controller = BattleThunderBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleThunderBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "ThunderBuff.csb"        -- 序列帧
    self._fThunderTimeMax = self._pBuffInfo.Param1*(1 - self._pMaster._fDebuffTimeRate)
    self._fHurtedUpRate = self._pBuffInfo.Param2
    
    return
end

-- 进入函数
function BattleThunderBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建麻痹特效对象
    self._pAni = cc.CSLoader:createNode(self._strAniName)
    
    self._pAniPos = function() return cc.p(0,self._pMaster:getHeight()/2) end
    self._pAni:setPosition(self._pAniPos())
    self._pMaster:addChild(self._pAni)
    
    -- 创建麻痹特效动画
    local act = cc.CSLoader:createTimeline(self._strAniName)
    act:gotoFrameAndPlay(0, act:getDuration(), true)
    act:clearFrameEventCallFunc()
    self._pAni:stopAllActions()
    self._pAni:runAction(act)
    
    -- 设置buff颜色
    self._pOwnerMachine:setColor(self._pColor)
    
    -- 设置master受到的伤害比例
    self._pMaster:setCurHurtedPercent(self._fHurtedUpRate)

    -- 切换角色到冻结状态
    self._pOwnerMachine:refreshToFrozen()

    -- 时间到    
    local thunderTimeUp = function()
        -- 恢复master受到的伤害比例
        self._pMaster:setCurHurtedPercent(1.0/self._fHurtedUpRate)
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fThunderTimeMax), cc.CallFunc:create(thunderTimeUp)))

    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleThunderBuffController:onExit()
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
function BattleThunderBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleThunderBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
        self._pMaster:setCurHurtedPercent(1.0/self._fHurtedUpRate)
    end

end

return BattleThunderBuffController
