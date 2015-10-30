--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSkillReleaseState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/9
-- descrip:   战斗中技能释放状态
--===================================================
local BattleSkillReleaseState = class("BattleSkillReleaseState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleSkillReleaseState:ctor()
    self._strName = "BattleSkillReleaseState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleSkill.kRelease  -- 状态类型ID
end

-- 创建函数
function BattleSkillReleaseState:create()
    local state = BattleSkillReleaseState.new()
    return state
end

-- 进入函数
function BattleSkillReleaseState:onEnter(args)
    --print(self._strName.." is onEnter!")
    if self:getMaster() then
        self:getMaster():onEnterReleaseDo(self)
    end
    return
end

-- 退出函数
function BattleSkillReleaseState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        self:getMaster():onExitReleaseDo(self)
    end
    return
end

-- 更新逻辑
function BattleSkillReleaseState:update(dt)
    if self:getMaster() then
        self:getMaster():onUpdateReleaseDo(dt,self)
    end
    return
end

return BattleSkillReleaseState
