--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  AngerSkillUINode.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/19
-- descrip:   战斗主UI上的怒气技能控件Node
--===================================================
local AngerSkillUINode = class("AngerSkillUINode",function()
    return cc.Node:create()
end)

-- 构造函数
function AngerSkillUINode:ctor()
    self._strName = "AngerSkillUINode"    -- 名称
    self._pRootNode = nil                 -- 根节点
    self._pAngerBg = nil                  -- 怒气背景
    self._pAngerBar1 = nil                -- 怒气技能条1  占总值的70%
    self._pAngerBar2 = nil                -- 怒气技能条2  占总值的30%
    self._pAngerMaxValue = 0              -- 怒气最大值
    self._pAngerCurValue = 0              -- 怒气当前值
    self._nAngerBar1MaxValue = 0          -- 怒气条1分摊怒气值上限  占总值的70%
    self._nAngerBar2MaxValue = 0          -- 怒气条2分摊怒气值上限  占总值的30%
    self._pAngerButton = nil              -- 怒气技能按钮 

end

-- 创建函数
function AngerSkillUINode:create()
    local node = AngerSkillUINode.new()
    node:dispose()
    return node
end

-- 处理函数
function AngerSkillUINode:dispose()
    -- 跟节点
    self._pRootNode = cc.Node:create()
    self:addChild(self._pRootNode)

    -- 怒气背景
    self._pAngerBg = cc.Sprite:createWithSpriteFrameName("SkillUIRes/zdjm33.png")
    self._pRootNode:addChild(self._pAngerBg)

    -- 怒气技能进度条
    self._pAngerBar1 = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("SkillUIRes/zdjm34_1.png"))
    self._pAngerBar1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pAngerBar1:setMidpoint(cc.p(0,0))
    self._pAngerBar1:setBarChangeRate(cc.p(1,0))
    self._pAngerBar1:setPercentage(0)
    self._pAngerBar1:setPosition(cc.p(-32,-47))
    self._pRootNode:addChild(self._pAngerBar1)

    self._pAngerBar2 = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("SkillUIRes/zdjm34_2.png"))
    self._pAngerBar2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pAngerBar2:setMidpoint(cc.p(0,0))
    self._pAngerBar2:setBarChangeRate(cc.p(0,1))
    self._pAngerBar2:setPercentage(0)
    self._pAngerBar2:setPosition(cc.p(108,8))
    self._pRootNode:addChild(self._pAngerBar2)

    self._pTitle = ccui.Text:create()
    self._pTitle:setFontName(strCommonFontName)
    self._pTitle:setFontSize(20)
    self._pTitle:setTextColor(cFontWhite)
    self._pTitle:enableOutline(cFontOutline,2)
    self._pTitle:setString("怒气")
    self._pTitle:setPosition(cc.p(108, 12))
    self._pRootNode:addChild(self._pTitle)

    -- 怒气技能按钮
    self._pAngerButton = ccui.Button:create("SkillUIRes/zdjm32none.png","SkillUIRes/zdjm32none.png","SkillUIRes/zdjm32none.png",ccui.TextureResType.plistType)
    self._pAngerButton:setPosition(cc.p(108,12))
    self._pRootNode:addChild(self._pAngerButton)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitAngerSkillUINode()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function AngerSkillUINode:onExitAngerSkillUINode()

end

-- 遍历
function AngerSkillUINode:update(dt)

end

-- 设置怒气值最大值
function AngerSkillUINode:setAngerMax(value)
    self._pAngerMaxValue = value
    self._nAngerBar1MaxValue = self._pAngerMaxValue*0.7
    self._nAngerBar2MaxValue = self._pAngerMaxValue - self._nAngerBar1MaxValue
end

-- 设置怒气值
function AngerSkillUINode:setAngerCur(value)
    if self._pAngerMaxValue ~= 0 then
        self._pAngerCurValue = value
        if self._pAngerCurValue >= self._pAngerMaxValue then
            self._pAngerCurValue = self._pAngerMaxValue
        end
        local percent = self._pAngerCurValue/self._pAngerMaxValue*100
        if percent <= 70 then
            self._pAngerBar1:setPercentage(percent/70*100)
            self._pAngerBar2:setPercentage(0)
        else
            self._pAngerBar1:setPercentage(100)
            self._pAngerBar2:setPercentage((percent-70)/30*100)
        end
    else
        self._pAngerBar1:setPercentage(0)
        self._pAngerBar2:setPercentage(0)
    end
end

-- 清空怒气值
function AngerSkillUINode:clearAnger()
    self._pAngerCurValue = 0
    self._pAngerBar1:setPercentage(0)
    self._pAngerBar2:setPercentage(0)
end

return AngerSkillUINode
