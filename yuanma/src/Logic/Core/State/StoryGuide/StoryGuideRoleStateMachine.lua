--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryGuideRoleStateMachine.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   剧情引导玩家角色状态机
--===================================================
local StoryGuideRoleStateMachine = class("StoryGuideRoleStateMachine",function()
    return require("StateMachine"):create()
end)

-- 构造函数
function StoryGuideRoleStateMachine:ctor()
    self._strName = "StoryGuideRoleStateMachine"         -- 状态机名称
    self._kTypeID = kType.kStateMachine.kStoryGuideRole  -- 状态类机型ID
    self._bHasOpenTalk = false                            -- 是否有对话
    self._pLashNpcId = nil
end

-- 创建函数
function StoryGuideRoleStateMachine:create(master)
    local machine = StoryGuideRoleStateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function StoryGuideRoleStateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    
    self:setMaster(master)
    
    self:addState(require("StoryGuideRoleStandState"):create())  -- 加入站立状态到状态机
    self:addState(require("StoryGuideRoleRunState"):create())    -- 加入奔跑状态到状态机
    self:addState(require("StoryGuideRoleSkillAtack"):create())    -- 加入释放技能状态到状态机
    self:addState(require("StoryGuideRoleDeadState"):create())    -- 加入释放技能状态到状态机
    
    self:setCurStateByTypeID(kType.kState.kStoryGuideRole.kStand)  -- 设置当前状态为站立状态
    
    return
end

-- 退出函数
function StoryGuideRoleStateMachine:onExit()
    --print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
        self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function StoryGuideRoleStateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    
    return
end

return StoryGuideRoleStateMachine
