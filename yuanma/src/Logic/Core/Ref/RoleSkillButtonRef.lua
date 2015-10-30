--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleSkillButtonRef.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/17
-- descrip:   战斗中玩家技能按钮的是否可用的引用计数
--===================================================
local RoleSkillButtonRef = class("RoleSkillButtonRef",function()
    return require("Ref"):create()
end)

-- 构造函数
function RoleSkillButtonRef:ctor()
    self._strName = "RoleSkillButtonRef"     -- 引用计数名称
    self._nSkillIndex = 0                        -- 技能按钮的index        
end

-- 创建函数
function RoleSkillButtonRef:create(index,master)
    local ref = RoleSkillButtonRef.new()
    ref._nSkillIndex = index
    ref._pMaster = master
    return ref
end

-- 为0的时候要进行的操作（需要重载）
function RoleSkillButtonRef:doWhenIsZero()
    if self._pMaster._kRoleType == kType.kRole.kPlayer and self._pMaster._strCharTag == "main" then
        -- print("技能按钮"..self._nSkillIndex.."恢复使用！")
        local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        if pUILayer then
            pUILayer._tSkillAttackButtons[self._nSkillIndex]:setTouchEnabled(true)
            pUILayer._tSkillAttackButtons[self._nSkillIndex]:setBright(true)
        end
    end
    return
end

-- 不为0的时候要进行的操作（需要重载）
function RoleSkillButtonRef:doWhenIsNotZero()
    if self._pMaster._kRoleType == kType.kRole.kPlayer and self._pMaster._strCharTag == "main" then
        --  print("技能按钮"..self._nSkillIndex.."禁用！")
        local pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        if pUILayer then
            pUILayer._tSkillAttackButtons[self._nSkillIndex]:setTouchEnabled(false)
            pUILayer._tSkillAttackButtons[self._nSkillIndex]:setBright(false)
        end
    end
    return
end

return RoleSkillButtonRef
