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
    self._pReconnectLbl = nil
end

-- 创建函数
function NetReconnectLayer:create()
    local layer = NetReconnectLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function NetReconnectLayer:dispose()
    local sScreen = mmo.VisibleRect:getVisibleSize()
    
    self._pColorLayer =  cc.LayerColor:create(cc.c4b(0,0,0,255))
    self._pColorLayer:setOpacity(90.0)
    self:addChild( self._pColorLayer)
    
    self._pReconnectLbl = cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pReconnectLbl:setLineHeight(20)
    self._pReconnectLbl:setAdditionalKerning(-2)
    self._pReconnectLbl:setTextColor(cc.c4b(255, 255, 255, 255))
    self._pReconnectLbl:setPosition(sScreen.width/2-40, sScreen.height/2-20)
    self._pReconnectLbl:setWidth(145)
    self._pReconnectLbl:setString("重连中..")
    self._pReconnectLbl:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._pReconnectLbl:setAnchorPoint(0,0)
    self:addChild(self._pReconnectLbl)
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
