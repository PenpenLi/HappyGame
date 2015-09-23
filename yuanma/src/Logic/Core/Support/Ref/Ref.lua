--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Ref.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/17
-- descrip:   引用计数数据基类
--===================================================
local Ref = class("Ref")

-- 构造函数
function Ref:ctor()
    self._strName = "Ref"         -- 引用计数名称
    self._pMaster = nil           -- 引用计数的主人
    self._nRef = 0                -- 引用计数                      
end

-- 创建函数
function Ref:create()
    local ref = Ref.new()
    return ref
end

-- 引用计数加1
function Ref:add()
    self._nRef = self._nRef + 1
    self:doWhenIsNotZero()
    return
end

-- 引用计数-1
function Ref:sub()
    self._nRef = self._nRef - 1
    if self._nRef <= 0 then
        self._nRef = 0
        self:doWhenIsZero()
    end
    return
end

-- 为0的时候要进行的操作（需要重载）
function Ref:doWhenIsZero()
    return
end

-- 不为0的时候要进行的操作（需要重载）
function Ref:doWhenIsNotZero()
    return
end

-- 获取引用计数值
function Ref:getRefValue()
    return self._nRef
end

return Ref
