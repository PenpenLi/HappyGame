--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleGenAttackState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/15
-- descrip:   战斗中好友角色普通攻击状态
--===================================================
local BattleFriendRoleGenAttackState = class("BattleFriendRoleGenAttackState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleFriendRoleGenAttackState:ctor()
    self._strName = "BattleFriendRoleGenAttackState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleFriendRole.kGenAttack  -- 状态类型ID
    
end

-- 创建函数
function BattleFriendRoleGenAttackState:create()
    local state = BattleFriendRoleGenAttackState.new()
    return state
end

-- 进入函数
function BattleFriendRoleGenAttackState:onEnter(args)
    if self:getMaster() then
        --print(self:getMaster()._strCharTag.."角色普通攻击状态")

        -- 角色搜索警戒范围内的野怪目标，并根据目标的方位自动转向
        self:getAIManager():roleRefreshDirectionWhenAttackEnemys(self:getMaster(), self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack])
        
        -- 开始使用技能
        self:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack]:onUse()
        
        -- 检测遮挡
        self:getMaster():checkCover()
        
    end
    return
end

-- 退出函数
function BattleFriendRoleGenAttackState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then

    end
    return
end

-- 更新逻辑
function BattleFriendRoleGenAttackState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattleFriendRoleGenAttackState
