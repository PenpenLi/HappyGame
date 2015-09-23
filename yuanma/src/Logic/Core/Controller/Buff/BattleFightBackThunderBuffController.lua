--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFightBackThunderBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/17
-- descrip:   反击-雷buff
--===================================================
local BattleFightBackThunderBuffController = class("BattleFightBackFireBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleFightBackThunderBuffController:ctor()
    self._strName = "BattleFightBackThunderBuffController"          -- Buff对象名称
    self._strAniName = ""                                           -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleFightBackThunderBuff   -- 控制类机型ID
    self._fTimeMax = 0                                              -- 持续时间
    self._fThunderSavingValue = 0                                   -- 雷属性积蓄值

end

-- 创建函数
function BattleFightBackThunderBuffController:create(master, buffInfo)
    local controller = BattleFightBackThunderBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleFightBackThunderBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "FightBackThunderBuff.csb"     --  序列帧
    self._fTimeMax = self._pBuffInfo.Param1
    self._fThunderSavingValue = self._pBuffInfo.Param2
    
    return
end

-- 进入函数
function BattleFightBackThunderBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 创建特效对象
    self._pAni = cc.CSLoader:createNode(self._strAniName)
    self._pAniPos = function() return cc.p(0,self._pMaster:getHeight()/2) end
    self._pAni:setPosition(self._pAniPos())
    self._pMaster:addChild(self._pAni)

    -- 创建特效动画
    local act = cc.CSLoader:createTimeline(self._strAniName)
    act:gotoFrameAndPlay(0, act:getDuration(), true)
    act:clearFrameEventCallFunc()
    self._pAni:stopAllActions()
    self._pAni:runAction(act)

    -- 时间到    
    local timeUp = function()
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fTimeMax), cc.CallFunc:create(timeUp)))

    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleFightBackThunderBuffController:onExit()
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
function BattleFightBackThunderBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleFightBackThunderBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattleFightBackThunderBuffController
