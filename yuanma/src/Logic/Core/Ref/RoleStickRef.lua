--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleStickRef.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/17
-- descrip:   战斗中玩家摇杆是否可用的引用计数
--===================================================
local RoleStickRef = class("RoleStickRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function RoleStickRef:ctor()
    self._strName = "RoleStickRef"           -- 引用计数名称         
    self._nWaitingSkillActOverToSubCount = 0     -- 等待人物技能动作结束时的引用计数自减操作的次数，用于避免人物在强制受到应值状态时因为强制stopAllActions或人物吟唱时间早于人物动作时间而导致引用计数自检操作没有被执行而无法操作摇杆的问题
end

-- 创建函数
function RoleStickRef:create(master)
    local ref = RoleStickRef.new()
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function RoleStickRef:doWhenIsZero()
    if self._pMaster._strCharTag == "main" then
        -- print("摇杆恢复使用！")
        local layer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        if layer then
            layer._bStickDisabled = false
        end
    end
    return
end

-- 不为0的时候要进行的操作（需要重载）
function RoleStickRef:doWhenIsNotZero()
    if self._pMaster._strCharTag == "main" then
        --  print("摇杆禁用！")
        local layer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        if layer then
            layer._bStickDisabled = true
        end
    end
    return
end

return RoleStickRef
