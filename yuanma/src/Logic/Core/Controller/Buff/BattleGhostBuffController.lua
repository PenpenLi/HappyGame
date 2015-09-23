--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleGhostBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/16
-- descrip:   虚影Buff
--===================================================
local BattleGhostBuffController = class("BattleGhostBuffController",function(master, buffInfo)
    return require("BattleBuffController"):create(master, buffInfo)
end)

-- 构造函数
function BattleGhostBuffController:ctor()
    self._strName = "BattleGhostBuffController"             -- Buff对象名称
    self._strAniName = ""                                   -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kBattleGhostBuff      -- 控制类机型ID
    self._fTimeMax = 0                                      -- 持续时间
    self._fTimeCounter = 0                                  -- 时间计数器
    self._pColor = cc.c3b(150,150,150)                      -- 虚影buff的颜色
    
end

-- 创建函数
function BattleGhostBuffController:create(master, buffInfo)
    local controller = BattleGhostBuffController.new(master, buffInfo)
    controller:dispose()
    return controller
end

-- 处理函数
function BattleGhostBuffController:dispose()    
    -- 初始化buff信息
    self._fTimeMax = self._pBuffInfo.Param1
    self._fTimeCounter = 0

    return
end

-- 进入函数
function BattleGhostBuffController:onEnter()
    -- 引用计数+1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:add()
    
    -- 忽略伤害引用计数+1（连应值都不会有）
    self._pMaster._pRefRoleIgnoreHurt:add()
    
    -- 虚影半透引用计数+1
    self._pMaster._pRefGhostOpacity:add()
    
    -- 设置buff颜色
    self._pOwnerMachine:setColor(self._pColor)
    
    -- 设置半透
    self._pMaster:setOpacity()

    -- 刷新相机
    self._pMaster:refreshCamera()
    
    return
end

-- 退出函数
function BattleGhostBuffController:onExit()
    -- 引用计数-1
    self._pOwnerMachine._tBuffRefs[self._kTypeID]:sub()
    
    -- 忽略伤害引用计数-1（连应值都不会有）
    self._pMaster._pRefRoleIgnoreHurt:sub()

    -- 虚影半透引用计数-1
    self._pMaster._pRefGhostOpacity:sub()

    -- 检测层叠
    self._pMaster:checkCover()
    
    -- 设置除了指定buff以外的最近一次的颜色
    self._pOwnerMachine:setLastColorExcept(self)
    
    return
end

-- 循环更新
function BattleGhostBuffController:update(dt)
    self:updateBattleBuff(dt)
    
    -- 时间计数
    self._fTimeCounter = self._fTimeCounter + dt
    if self._fTimeCounter >= self._fTimeMax then        
        -- 结束buff
        self._bEnable = false
    end
    
end

-- 手动取消buff
function BattleGhostBuffController:cancel() 
    if self._bEnable == true then
        self._bEnable = false

    end

end

return BattleGhostBuffController
