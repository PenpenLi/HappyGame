--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BuffRef.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/13
-- descrip:   战斗中Buff的引用计数
--===================================================
local BuffRef = class("BuffRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function BuffRef:ctor()
    self._strName = "BuffRef"     -- 引用计数名称       
end

-- 创建函数
function BuffRef:create(master)
    local ref = BuffRef.new()
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function BuffRef:doWhenIsZero()
    return
end

-- 不为0的时候要进行的操作（需要重载）
function BuffRef:doWhenIsNotZero()
    return
end

return BuffRef
