--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleGenAttackButtonRef.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/17
-- descrip:   战斗中玩家普通攻击按钮是否可用的引用计数
--===================================================
local RoleGenAttackButtonRef = class("RoleGenAttackButtonRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function RoleGenAttackButtonRef:ctor()
    self._strName = "RoleGenAttackButtonRef"     -- 引用计数名称     
end

-- 创建函数
function RoleGenAttackButtonRef:create(master)
    local ref = RoleGenAttackButtonRef.new()
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function RoleGenAttackButtonRef:doWhenIsZero()
   if self._pMaster._strCharTag == "main" then
        -- print("普通攻击按钮恢复使用！")
        local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        if pUILayer then
            --unDarkNode(pUILayer._pGenAttackButton:getVirtualRenderer():getSprite())
            pUILayer._pGenAttackButton:setColor(cWhite)
        end
   end
   return
end

-- 不为0的时候要进行的操作（需要重载）
function RoleGenAttackButtonRef:doWhenIsNotZero()
    if self._pMaster._strCharTag == "main" then
        --  print("普通攻击按钮禁用！")
        local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        if pUILayer then
            --darkNode(pUILayer._pGenAttackButton:getVirtualRenderer():getSprite())
            pUILayer._pGenAttackButton:setColor(cDeepGrey)
        end
    end
    return
end

return RoleGenAttackButtonRef
