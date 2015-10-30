--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MaskBgLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   场景的mask背景层（主要用于对话框的衬底蒙版）
--===================================================
local MaskBgLayer = class("MaskBgLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function MaskBgLayer:ctor()
    self._strName = "MaskBgLayer"         -- 层名称
    self._pColorLayer = nil
    --是否屏蔽触摸事件
    self._bTouchable = true 
end

-- 创建函数
function MaskBgLayer:create()
    local layer = MaskBgLayer.new()
    layer:dispose()
    return layer
end

-- 创建函数
function MaskBgLayer:dispose()
    self._pColorLayer =  cc.LayerColor:create(cc.c4b(0,0,0,255))
    self:addChild( self._pColorLayer)
    -- 触摸注册
    local function onTouchBegin(touch,event)
        return self._bTouchable
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

-- 显示（带动画）
function MaskBgLayer:showWithAni()
    self._pColorLayer:setVisible(true)
    self._pColorLayer:setOpacity(0.0)
    self._pColorLayer:stopAllActions()
    local action = cc.EaseInOut:create(cc.FadeTo:create(1.0, 230), 5.0)
    self._pColorLayer:runAction(action)
    return
end

-- 关闭（带动画）
function MaskBgLayer:closeWithAni()
    self._pColorLayer:stopAllActions()
    local closeOver = function()
        self:removeFromParent(true)
    end
    local action = cc.Sequence:create(
        cc.EaseIn:create(cc.FadeTo:create(0.4, 0), 5.0),
        cc.CallFunc:create(closeOver))
    self._pColorLayer:runAction(action)
    return
end

-- 设置是否触摸屏蔽
function MaskBgLayer:setTouchable(args)
    self._bTouchable = args 
end

return MaskBgLayer
