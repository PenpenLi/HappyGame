--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryTriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/12
-- descrip:   触发器剧情动作项
--===================================================
local StoryTriggerItem = class("StoryTriggerItem",function()
    return require("TriggerItem"):create()
end)

-- 构造函数
function StoryTriggerItem:ctor()
    self._kType = kType.kTriggerItemType.kStory   -- 触发器动作项的类型
    self._bCanUpdate = false                      -- 标记是否可以进入update
    
end

-- 创建函数
function StoryTriggerItem:create(index, talkID)
    local item = StoryTriggerItem.new()
    item._nIndex = index
    item._nTalkID = talkID
    return item
end

-- 作用函数
function StoryTriggerItem:work()
    if self._pOwnerTrigger._nCurStep == self._nIndex then
        if self:getMapManager()._pTmxMap:getActionByTag(nTriggerItemTag) == nil and self._bCanUpdate == false then
            self._bCanUpdate = true
            -- 这里添加需要激活的剧情动画
           StoryGuideManager:getInstance():createStoryGuideById(self._nTalkID)
        elseif self._bCanUpdate == true then    -- 进入每一帧update
            if StoryGuideManager:getInstance()._bIsStory == false then  --则结束当前触发器作用 
                self._bCanUpdate = false
                self._pOwnerTrigger:addCurStep()
            end
        end
        
    end
end

return StoryTriggerItem
