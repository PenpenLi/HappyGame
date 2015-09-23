--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ClipNodeLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/2
-- descrip:   指定了有效触摸区域的层（未指定触摸区域的部分均被遮罩，且无视触摸事件）
--===================================================
local ClipNodeLayer = class("ClipNodeLayer",function()
    return cc.LayerColor:create(cc.c4b(0,0,0,0))
end)

-- 构造函数
function ClipNodeLayer:ctor()
    self._strName = "ClipNodeLayer"         -- 层名称
    self._tRects = {}                       -- 响应触摸的有效矩形集合
end

-- 创建函数
function ClipNodeLayer:create(rects)
    local layer = ClipNodeLayer.new()
    layer:dispose(rects)
    return layer
end

-- 创建函数
function ClipNodeLayer:dispose(rects)
    self._tRects = rects
    
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        for kRect,vRect in pairs(self._tRects) do 
            if cc.rectContainsPoint(vRect, location) == true then
                return false
            end
        end
        return true
    end
    local function onTouchMoved(touch,event)
    end
    local function onTouchEnded(touch,event)
    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

return ClipNodeLayer
