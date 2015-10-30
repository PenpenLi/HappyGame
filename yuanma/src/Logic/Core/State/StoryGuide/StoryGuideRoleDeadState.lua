--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryGuideRoleDeadState.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   剧情引导玩家角色死亡状态
--===================================================
local StoryGuideRoleDeadState = class("StoryGuideRoleDeadState",function()
    return require("State"):create()
end)

-- 构造函数
function StoryGuideRoleDeadState:ctor()
    self._strName = "StoryGuideRoleDeadState"           -- 状态名称
    self._kTypeID = kType.kState.kStoryGuideRole.kDead  -- 状态类型ID
end

-- 创建函数
function StoryGuideRoleDeadState:create()
    local state = StoryGuideRoleDeadState.new()
    return state
end

-- 进入函数
function StoryGuideRoleDeadState:onEnter(args)
     self._funcCallBackFunc = args.func
        -- 刷新动作
        self:getMaster():playDeadAction()
        -- 死亡动画
        self:getMaster():playDeadEffect()
        -- 添加动作回调
        local deadOver = function()
              self._funcCallBackFunc()
        end
        -- 设置透明度和positionZ层级  
        self:getMaster()._pAni:runAction(cc.Sequence:create(cc.FadeOut:create(1.5), cc.CallFunc:create(deadOver)))
         -- 死亡声音，只有怪物跟人有
         if self:getMaster()._kStoryRoleType == kType.kRole.kPlayer or self:getMaster()._kStoryRoleType == kType.kRole.kMonster then
            AudioManager:getInstance():playEffect(self:getMaster()._tTempleteInfo.DeadVoice,nil,true)
         end
      
    return
end

-- 退出函数
function StoryGuideRoleDeadState:onExit()
    --print(self._strName.." is onExit!")
    
    return
end

-- 更新逻辑
function StoryGuideRoleDeadState:update(dt)     
    return
end

return StoryGuideRoleDeadState
