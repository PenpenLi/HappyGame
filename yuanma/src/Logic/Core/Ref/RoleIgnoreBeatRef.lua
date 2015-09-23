--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleIgnoreBeatRef.lua
-- author:    liyuhang
-- created:   2015/3/16
-- descrip:   战斗中角色是否无视伤害的计数
--===================================================
local RoleIgnoreBeatRef = class("RoleIgnoreBeatRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function RoleIgnoreBeatRef:ctor()
    self._strName = "RoleIgnoreBeatRef"           -- 引用计数名称   
    self._bIgnoreHurt = false      
end

-- 创建函数
function RoleIgnoreBeatRef:create(master)
    local ref = RoleIgnoreBeatRef.new()
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function RoleIgnoreBeatRef:doWhenIsZero()
   -- print("保护失效！")
    self._bIgnoreHurt = false 
    return
end

-- 不为0的时候要进行的操作（需要重载）
function RoleIgnoreBeatRef:doWhenIsNotZero()
   -- print("保护生效！")
    self._bIgnoreHurt = true 
    return
end

-- get是否无视伤害
function RoleIgnoreBeatRef:getBeIgnoreHurtOrNot()
    return self._bIgnoreHurt
end

return RoleIgnoreBeatRef
