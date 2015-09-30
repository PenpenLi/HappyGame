--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleDizzyBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/14
-- descrip:   眩晕buff
--===================================================
local BattleDizzyBuffController = class("BattleDizzyBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleDizzyBuffController:ctor()
    self._strName = "BattleDizzyBuffController"         -- Buff对象名称
    self._strAniName = ""                               -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleDizzyBuff  -- 控制类机型ID
    self._fDizzyTimeMax = 0                             -- 眩晕持续时间

end

-- 创建函数
function BattleDizzyBuffController:create(master, buffInfo)
    local controller = BattleDizzyBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleDizzyBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "StunBuff.csb"          --  序列帧
    self._fDizzyTimeMax = self._pBuffInfo.Param1*(1 - self._pMaster._fDebuffTimeRate)
    
    return
end

-- 进入函数
function BattleDizzyBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 如果有当前有debuff，则退出
    if self._pMaster:isUnusualState() == true then
        self._bEnable = false
        return
    end

    -- 创建特效对象
    self._pAni = cc.CSLoader:createNode(self._strAniName)
    self._pAniPos = function() return cc.p(0,self._pMaster:getHeight()) end
    self._pAni:setPosition(self._pAniPos())
    self._pMaster:addChild(self._pAni)

    -- 创建特效动画
    local act = cc.CSLoader:createTimeline(self._strAniName)
    act:gotoFrameAndPlay(0, act:getDuration(), true)
    act:clearFrameEventCallFunc()
    self._pAni:stopAllActions()
    self._pAni:runAction(act)
    
    -- 切换角色到眩晕状态
    self._pOwnerMachine:refreshToDizzy()

    -- 时间到    
    local dizzyTimeUp = function()
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fDizzyTimeMax), cc.CallFunc:create(dizzyTimeUp)))

    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleDizzyBuffController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:sub()

    if self._pAni then
        self._pAni:stopAllActions()
    end

    if self._pAniParent then
        self._pMaster:removeChild(self._pAniParent,true)
    else
        if self._pAni then
            self._pMaster:removeChild(self._pAni,true)
        end
    end

    -- 除了指定buff以外的剩余所有buff中，根据是否存在影响角色正常恢复到站立状态的buff而自动刷新人物状态
    self._pOwnerMachine:refreshToStandExcept(self)

    return
end

-- 循环更新
function BattleDizzyBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleDizzyBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattleDizzyBuffController
