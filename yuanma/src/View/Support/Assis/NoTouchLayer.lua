--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NoTouchLayer.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/21
-- descrip:   屏蔽触摸层
--===================================================
local NoTouchLayer = class("NoTouchLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function NoTouchLayer:ctor()
    self._strName = "NoTouchLayer"         -- 层名称
end

-- 创建函数
function NoTouchLayer:create()
    local layer = NoTouchLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function NoTouchLayer:dispose()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        return true
    end
    local function onTouchMoved(touch,event)
    end
    local function onTouchEnded(touch,event)
    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:setEnabled(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

end

-- 退出函数
function NoTouchLayer:onExitNoTouchLayer()  
    self:onExitLayer()
    return   
end

return NoTouchLayer
