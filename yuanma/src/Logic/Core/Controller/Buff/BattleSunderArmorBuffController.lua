--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSunderArmorBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/9/17
-- descrip:   破甲Buff
--===================================================
local BattleSunderArmorBuffController = class("BattleSunderArmorBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleSunderArmorBuffController:ctor()
    self._strName = "BattleSunderArmorBuffController"                -- Buff对象名称
    self._strAniName = ""                                            -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleSunderArmorBuff   -- 控制类机型ID
    self._fTime = 0                                                  -- 持续时间
    self._fSubDefenseValue = 0                                       -- 防御等级下降数值
    self._fSunderRate = 0                                            -- 破甲掉血时的HP百分比数
end

-- 创建函数
function BattleSunderArmorBuffController:create(master, buffInfo)
    local controller = BattleSunderArmorBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleSunderArmorBuffController:dispose()    
    -- 初始化buff信息
    self._strAniName = "PenetrateBuff.csb"
    self._fTime = self._pBuffInfo.Param1*(1 - self._pMaster._fDebuffTimeRate)
    self._fSubDefenseValue = self._pBuffInfo.Param2
    self._fSunderRate = self._pBuffInfo.Param3
    
    return
end

-- 进入函数
function BattleSunderArmorBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 如果已经有了一个这个buff，则直接返回，不会发生叠加
    if self._pOwnerMachine._tBuffRefs[self._kTypeID]:getRefValue() >= 2 then
        self._bEnable = false
        return
    end
    
    -- 创建特效对象
    self._pAni = cc.CSLoader:createNode(self._strAniName)
    self._pAniPos = function() return cc.p(0,self._pMaster:getHeight()/2) end
    self._pMaster:addChild(self._pAni)

    -- 创建特效动画
    local act = cc.CSLoader:createTimeline(self._strAniName)
    act:gotoFrameAndPlay(0, 30, false)
    act:clearFrameEventCallFunc()
    self._pAni:setPosition(self._pAniPos())
    self._pAni:setLocalZOrder(1)
    self._pAni:stopAllActions()
    self._pAni:runAction(act)
    local changeToLoopAni = function()
        local act = cc.CSLoader:createTimeline(self._strAniName)
        act:gotoFrameAndPlay(100, 160, true)
        act:clearFrameEventCallFunc()
        self._pAni:stopAllActions()
        self._pAni:runAction(act)
        self._pAni:setPosition(cc.p(0,0))
        self._pAni:setLocalZOrder(-1)
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(30*cc.Director:getInstance():getAnimationInterval()),cc.CallFunc:create(changeToLoopAni)))
    
    -- 开始破甲
    self._pMaster._fSunderArmorLoseHpRate = self._fSunderRate
    
    -- 减少防御等级
    self._pMaster:addDefenseLevelOffset(-self._fSubDefenseValue)

    -- 添加动作
    local timeUp = function()
        -- 破甲失效
        self._pMaster._fSunderArmorLoseHpRate = 0
        -- 恢复防御等级
        self._pMaster:addDefenseLevelOffset(self._fSubDefenseValue)
    end
    local disappearOver = function()
        self._bEnable = false
    end
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(self._fTime+0.1),cc.CallFunc:create(timeUp),cc.CallFunc:create(disappearOver)))

    -- 刷新相机
    self._pMaster:refreshCamera()

    return
end

-- 退出函数
function BattleSunderArmorBuffController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:sub()  

    if self._pAni then
        self._pMaster:removeChild(self._pAni,true)
    end

    return
end

-- 循环更新
function BattleSunderArmorBuffController:update(dt)
    self:updateBattleBuff(dt)
    
end

-- 手动取消buff
function BattleSunderArmorBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
        -- 破甲失效
        self._pMaster._bSunderArmoring = false        
        -- 破甲失效
        if self._pMaster._fSunderArmorLoseHpRate ~= 0 then
            self._pMaster._fSunderArmorLoseHpRate = 0
            self._pMaster:addDefenseLevelOffset(self._fSubDefenseValue)  -- 恢复防御等级
        end
    end

end

return BattleSunderArmorBuffController
