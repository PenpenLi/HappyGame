--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TalksTriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/6
-- descrip:   触发器剧情对话动作项
--===================================================
local TalksTriggerItem = class("TalksTriggerItem",function()
    return require("TriggerItem"):create()
end)

-- 构造函数
function TalksTriggerItem:ctor()
    self._kType = kType.kTriggerItemType.kTalks   -- 触发器动作项的类型
    self._nTalkID = 0                             -- 对话表中的ID号
    self._bCanUpdate = false                      -- 标记是否可以进入update
    
end

-- 创建函数
function TalksTriggerItem:create(index, talkID)
    local item = TalksTriggerItem.new()
    item._nIndex = index
    item._nTalkID = talkID
    return item
end

-- 作用函数
function TalksTriggerItem:work()
    if self._pOwnerTrigger._nCurStep == self._nIndex then
        if self:getMapManager()._pTmxMap:getActionByTag(nTriggerItemTag) == nil and self._bCanUpdate == false then
            self._bCanUpdate = true
            self:getTalksManager():setCurTalks(self._nTalkID)
        elseif self._bCanUpdate == true then    -- 进入每一帧update
            if self:getTalksManager():isCurTalksFinished() == true then     -- 如果当前对话已经结束，则结束当前触发器作用
                self._bCanUpdate = false
                self._pOwnerTrigger:addCurStep()
            end
        end
        
    end
end

return TalksTriggerItem
