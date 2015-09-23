--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleNotLoseHpRef.lua
-- author:    taoye
-- created:   2015/3/16
-- descrip:   战斗中角色是否不掉血的引用计数，其他正常（可以应值等等）的计数
--===================================================
local RoleNotLoseHpRef = class("RoleNotLoseHpRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function RoleNotLoseHpRef:ctor()
    self._strName = "RoleNotLoseHpRef"           -- 引用计数名称   
    self._bNotLoseHp = false      
end

-- 创建函数
function RoleNotLoseHpRef:create(master)
    local ref = RoleNotLoseHpRef.new()
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function RoleNotLoseHpRef:doWhenIsZero()
   -- print("保护失效！")
    self._bNotLoseHp = false 
    return
end

-- 不为0的时候要进行的操作（需要重载）
function RoleNotLoseHpRef:doWhenIsNotZero()
   -- print("保护生效！")
    self._bNotLoseHp = true 
    return
end

-- get是否无视伤害
function RoleNotLoseHpRef:getBeNotLoseHpOrNot()
    return self._bNotLoseHp
end

return RoleNotLoseHpRef
