--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleSkillAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/12
-- descrip:   战斗中好友角色技能攻击状态
--===================================================
local BattleFriendRoleSkillAttackState = class("BattleFriendRoleSkillAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleFriendRoleSkillAttackState:ctor()
    self._strName = "BattleFriendRoleSkillAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleFriendRole.kSkillAttack  -- 状态类型ID

end

-- 创建函数
function BattleFriendRoleSkillAttackState:create()
    local state = BattleFriendRoleSkillAttackState.new()
    return state
end

-- 进入函数
function BattleFriendRoleSkillAttackState:onEnter(args)
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("mmo:BattleFriendRoleSkillAttackState")
        -- 自动刷新方向
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._pSkill)
        -- 使用技能 
        self:getMaster()._pSkill:onUse()       
    end
    return
end

-- 退出函数
function BattleFriendRoleSkillAttackState:onExit()
    return
end

-- 更新逻辑
function BattleFriendRoleSkillAttackState:update(dt)
    return
end

return BattleFriendRoleSkillAttackState
