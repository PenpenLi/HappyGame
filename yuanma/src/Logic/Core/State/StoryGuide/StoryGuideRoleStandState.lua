--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryGuideRoleStandState.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   剧情引导玩家角色站立状态
--===================================================
local StoryGuideRoleStandState = class("StoryGuideRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function StoryGuideRoleStandState:ctor()
    self._strName = "StoryGuideRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kStoryGuideRole.kStand  -- 状态类型ID
    ------------ 时间计数 ---------------------------------------------
    self._fStandTime = 0
    self._fCasualTime = 0

end

-- 创建函数
function StoryGuideRoleStandState:create()
    local state = StoryGuideRoleStandState.new()
    return state
end

-- 进入函数
function StoryGuideRoleStandState:onEnter(args)
    print(self:getMaster()._pInstenceId.."角色站立")    
    if self:getMaster() then
        self._fStandTime = 0
        self._fCasualTime = 0
        self._fStandTime = self:getMaster()._tTempleteInfo.CasualActInterval
        self:getMaster():playStandAction()
    end
    return
end

-- 退出函数
function StoryGuideRoleStandState:onExit()
   -- print(self._strName.." is onExit!")
    self._fStandTime = 0
    self._fCasualTime = 0
    return
end

-- 更新逻辑
function StoryGuideRoleStandState:update(dt)

   --只有角色跟npc才有休闲动作
  if self:getMaster()._kStoryRoleType == kType.kRole.kPlayer or self:getMaster()._kStoryRoleType == kType.kRole.kNpc then
    -- 时间计数
    if self._fCasualTime == 0 then
        self._fStandTime = self._fStandTime - dt
        if self._fStandTime <= 0 then
            self._fStandTime = 0
            print("播放休闲动作")
            self._fCasualTime = self:getMaster():getCasualActionTime()
            self:getMaster():playCasualAction()
        end
    else
        self._fCasualTime = self._fCasualTime - dt
        if self._fCasualTime <= 0 then
            self._fCasualTime = 0
            self._fStandTime = self:getMaster()._tTempleteInfo.CasualActInterval
            self:getMaster():playStandAction()
        end
    end
  end
  
    return
end

return StoryGuideRoleStandState
