--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StarUINode.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/10/19
-- descrip:   战斗主UI上的评星控件Node
--===================================================
local StarUINode = class("StarUINode",function()
    return cc.Node:create()
end)

-- 构造函数
function StarUINode:ctor()
    self._strName = "StarUINode"   -- 名称
    self._pRootNode = nil                 -- 根节点
    self._nCurStarNum = 0                 -- 当前星星的个数
    self._tStarPlot = {}                  -- 星星的槽
    self._tStarGold = {}                  -- 金色星星

end

-- 创建函数
function StarUINode:create(num)
    local node = StarUINode.new()
    node:dispose(num)
    return node
end

-- 处理函数
function StarUINode:dispose(num)

    -- 跟节点
    self._pRootNode = cc.Node:create()
    self:addChild(self._pRootNode)

    for i=1,5 do
        local star = cc.Sprite:createWithSpriteFrameName("smallStars/zdjm23.png")
        star:setPositionX((i-1)*star:getContentSize().width)
        self._pRootNode:addChild(star)
        table.insert(self._tStarPlot, star)
    end

    if num == nil then
        num = 0
    end

    -- 星星个数
    self._nCurStarNum = num

    for i=1, self._nCurStarNum do 
        local star = cc.Sprite:createWithSpriteFrameName("smallStars/zdjm22.png")
        star:setPositionX((i-1)*star:getContentSize().width)
        self._pRootNode:addChild(star)
        table.insert(self._tStarGold, star)
    end

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitStarUINode()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function StarUINode:onExitStarUINode()

end

-- 遍历
function StarUINode:update(dt)

end

-- 加星
function StarUINode:addStar()
    self._nCurStarNum = self._nCurStarNum + 1
    if self._nCurStarNum > 5 then
        self._nCurStarNum = 5
        return
    end
    local star = cc.Sprite:createWithSpriteFrameName("smallStars/zdjm22.png")
    self._pRootNode:addChild(star)
    table.insert(self._tStarGold, star)

    local addOver = function()
        self._pRootNode:stopAllActions()
        self._pRootNode:setPosition(cc.p(0,0))
        self._pRootNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.05,cc.p(3,3)),cc.MoveBy:create(0.05,cc.p(-3,-3)),cc.MoveBy:create(0.05,cc.p(2,2)),cc.MoveBy:create(0.05,cc.p(-2,-2)),cc.MoveBy:create(0.05,cc.p(1,1)),cc.MoveBy:create(0.05,cc.p(-1,-1))))
    end
    local targetPos = cc.p((self._nCurStarNum-1)*star:getContentSize().width,0)
    star:setScale(2)
    star:setOpacity(0)
    star:setPosition(cc.p(-150,-150))
    star:runAction(cc.Sequence:create(cc.EaseSineInOut:create(cc.Spawn:create(cc.FadeIn:create(0.2), cc.RotateBy:create(0.2, 360))), cc.EaseIn:create(cc.Spawn:create(cc.ScaleTo:create(0.2,1.0,1.0), cc.MoveTo:create(0.2,targetPos)),6), cc.CallFunc:create(addOver)))

end

-- 减星
function StarUINode:subStar()
    local subOver = function()
        if self._nCurStarNum >= 1 then
            self._tStarGold[self._nCurStarNum]:removeFromParent(true)
            table.remove(self._tStarGold, self._nCurStarNum)
            self._nCurStarNum = self._nCurStarNum - 1
            if self._nCurStarNum <= 0 then
                self._nCurStarNum = 0
            end
        end
    end
    if self._nCurStarNum >= 1 then
        self._tStarGold[self._nCurStarNum]:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(cc.MoveBy:create(0.05,cc.p(3,3)), cc.MoveBy:create(0.05,cc.p(-3,-3))),3), cc.Spawn:create(cc.MoveBy:create(0.5,cc.p(-150,-150)), cc.RotateBy:create(0.5,360), cc.ScaleTo:create(0.5,3.0,3.0), cc.FadeOut:create(0.5)),cc.CallFunc:create(subOver)))
    end
    
end

-- 设置星星个数
function StarUINode:setStar(num)
    for k,v in pairs(self._tStarGold) do 
        v:removeFromParent(true)
    end
    self._tStarGold = {}
    if num and num >= 0 and num <= 5 then
        self._nCurStarNum = num
    end
    for i=1, self._nCurStarNum do 
        local star = cc.Sprite:createWithSpriteFrameName("smallStars/zdjm22.png")
        star:setPositionX((i-1)*star:getContentSize().width)
        self._pRootNode:addChild(star)
        table.insert(self._tStarGold, star)
    end
end

return StarUINode
