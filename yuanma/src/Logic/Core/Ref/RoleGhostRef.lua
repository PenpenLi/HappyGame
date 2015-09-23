--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleGhostRef.lua
-- author:    taoye
-- created:   2015/3/16
-- descrip:   战斗中角色虚影半透的引用计数
--===================================================
local RoleGhostRef = class("RoleGhostRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function RoleGhostRef:ctor()
    self._strName = "RoleGhostRef"           -- 引用计数名称   
    self._bNeedOpacity = false     
end

-- 创建函数
function RoleGhostRef:create(master)
    local ref = RoleGhostRef.new()
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function RoleGhostRef:doWhenIsZero()
    self._bNeedOpacity = false
    return
end

-- 不为0的时候要进行的操作（需要重载）
function RoleGhostRef:doWhenIsNotZero()
    self._bNeedOpacity = true 
    return
end

-- get是否需要半透
function RoleGhostRef:needOpacity()
    return self._bNeedOpacity
end

return RoleGhostRef
