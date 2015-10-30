--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryGuideRoleSkillAtack.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   剧情引导中玩家角色站立状态
--===================================================
local StoryGuideRoleSkillAtack = class("StoryGuideRoleSkillAtack",function()
    return require("State"):create()
end)

-- 构造函数
function StoryGuideRoleSkillAtack:ctor()
    self._strName = "StoryGuideRoleSkillAtack"           -- 状态名称
    self._kTypeID = kType.kState.kStoryGuideRole.kSkillAttack  -- 状态类型ID

end

-- 创建函数
function StoryGuideRoleSkillAtack:create()
    local state = StoryGuideRoleSkillAtack.new()
    return state
end

-- 进入函数
function StoryGuideRoleSkillAtack:onEnter(args)

    if self:getMaster() then
        local funcCallBack = function()
          self._pOwnerMachine:setCurStateByTypeID(kType.kState.kStoryGuideRole.kStand)
          args.func()
        end
       self:getMaster():playAttackAction(args.tkillInfo.PlayActionNum)
       self:getMaster():playSkill(args.tkillInfo)
       local pTime = self:getMaster():getAttackActionTime(args.tkillInfo.PlayActionNum)
       self:getMaster()._pSkillActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(pTime),cc.CallFunc:create(funcCallBack)))
       -- 技能
        self._nRunSoundID = AudioManager:getInstance():playEffect(args.tkillInfo.SkillVoice,nil,true)
    end
    return
end

-- 退出函数
function StoryGuideRoleSkillAtack:onExit()
   -- print(self._strName.." is onExit!")

    return
end

-- 更新逻辑
function StoryGuideRoleSkillAtack:update(dt)
    return
end

return StoryGuideRoleSkillAtack
