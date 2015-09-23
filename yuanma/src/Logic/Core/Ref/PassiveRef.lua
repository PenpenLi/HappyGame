--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PassiveRef.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/27
-- descrip:   战斗中Passive的引用计数
--===================================================
local PassiveRef = class("PassiveRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function PassiveRef:ctor()
    self._strName = "PassiveRef"     -- 引用计数名称       
end

-- 创建函数
function PassiveRef:create(master)
    local ref = PassiveRef.new()
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function PassiveRef:doWhenIsZero()
    return
end

-- 不为0的时候要进行的操作（需要重载）
function PassiveRef:doWhenIsNotZero()
    return
end

return PassiveRef
