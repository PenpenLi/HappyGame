--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NetReconnectLayer.lua
-- author:    liyuhang
-- created:   2015/9/21
-- descrip:   网络重连等待
--===================================================
local NetReconnectLayer = class("NetReconnectLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function NetReconnectLayer:ctor()
    self._strName = "NetReconnectLayer"         -- 层名称
    self._pBg = nil                             -- 背景
    self._pReconnectLbl = nil                   -- 文字提示
    self._pCircle = nil
    self._pCircle2 = nil
    self._pCircle3 = nil

end

-- 创建函数
function NetReconnectLayer:create()
    local layer = NetReconnectLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function NetReconnectLayer:dispose()

    self._pBg = cc.Sprite:createWithSpriteFrameName("ccsComRes/pmd.png")
    self._pBg:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/3+1)
    self._pBg:setScaleX(mmo.VisibleRect:width()/self._pBg:getContentSize().width)
    self._pBg:setScaleY(1.5)
    self:addChild(self._pBg)
    
    self._pReconnectLbl = cc.Label:createWithTTF("", strCommonFontName, 30)
    self._pReconnectLbl:setLineHeight(20)
    self._pReconnectLbl:setAdditionalKerning(-2)
    self._pReconnectLbl:setTextColor(cFontWhite)
    self._pReconnectLbl:enableOutline(cFontOutline,2)
    self._pReconnectLbl:setString("网络重连中...")
    self._pReconnectLbl:setPosition(mmo.VisibleRect:width()/2, mmo.VisibleRect:height()/3)
    self:addChild(self._pReconnectLbl)

    -- 无限旋转的菊花
    self._pCircle = cc.Sprite:createWithSpriteFrameName("com_001.png")
    self._pCircle:setScale(0.4)
    self._pCircle:setPosition(mmo.VisibleRect:width()/2+120, mmo.VisibleRect:height()/3)
    self._pCircle:stopAllActions()
    self._pCircle:setRotation(0)
    self._pCircle:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.2,35.0)))
    self:addChild(self._pCircle)

    self._pCircle2 = cc.Sprite:createWithSpriteFrameName("com_001.png")
    self._pCircle2:setPosition(mmo.VisibleRect:width()/2+120, mmo.VisibleRect:height()/3)
    self._pCircle2:stopAllActions()
    self._pCircle2:setRotation(90)
    self._pCircle2:setScale(0.6)
    self._pCircle2:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.35,-35.0)))
    self:addChild(self._pCircle2)

    self._pCircle3 = cc.Sprite:createWithSpriteFrameName("com_001.png")
    self._pCircle3:setPosition(mmo.VisibleRect:width()/2+120, mmo.VisibleRect:height()/3)
    self._pCircle3:stopAllActions()
    self._pCircle3:setRotation(180)
    self._pCircle3:setScale(0.6)
    self._pCircle3:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,-35.0)))
    self:addChild(self._pCircle3)

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
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitNetReconnectLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 退出函数
function NetReconnectLayer:onExitNetReconnectLayer()  
    self:onExitLayer()
    return   
end

return NetReconnectLayer
