--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WaitingLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   等待层（用于网络延时等待）
--===================================================
local WaitingLayer = class("WaitingLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function WaitingLayer:ctor()
    self._strName = "WaitingLayer"         -- 层名称
    self._pCircle = nil                    -- 等待菊花
    self._pCircle2 = nil                   -- 等待菊花2 
    self._pCircle3 = nil                   -- 等待菊花3 
end

-- 创建函数
function WaitingLayer:create()
    local layer = WaitingLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function WaitingLayer:dispose()
    ------------------- 初始化 --------------------------
    -- 无限旋转的菊花
    self._pCircle = cc.Sprite:createWithSpriteFrameName("com_001.png")
    self._pCircle:setPosition(mmo.VisibleRect:center())
    self._pCircle:stopAllActions()
    self._pCircle:setRotation(0)
    self._pCircle:setScale(0.8)
    self._pCircle:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.2,35.0)))
    self:addChild(self._pCircle)
    
    self._pCircle2 = cc.Sprite:createWithSpriteFrameName("com_001.png")
    self._pCircle2:setPosition(mmo.VisibleRect:center())
    self._pCircle2:stopAllActions()
    self._pCircle2:setRotation(90)
    self._pCircle2:setScale(1.8)
    self._pCircle2:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.35,-35.0)))
    self:addChild(self._pCircle2)
    
    self._pCircle3 = cc.Sprite:createWithSpriteFrameName("com_001.png")
    self._pCircle3:setPosition(mmo.VisibleRect:center())
    self._pCircle3:stopAllActions()
    self._pCircle3:setRotation(180)
    self._pCircle3:setScale(1.8)
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
            self:onExitWaitingLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 退出函数
function WaitingLayer:onExitWaitingLayer()  
    self:onExitLayer()
    return   
end

-- 显示（带动画）
function WaitingLayer:showWithAni()
    self:setVisible(true)
    self._pCircle:setRotation(0)
    self._pCircle:stopAllActions()
    self._pCircle:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.2,35.0)))
    self._pCircle2:setRotation(90)
    self._pCircle2:stopAllActions()
    self._pCircle2:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.35,-35.0)))
    self._pCircle3:setRotation(180)
    self._pCircle3:stopAllActions()
    self._pCircle3:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,-35.0)))
    return
end

-- 关闭（带动画）
function WaitingLayer:closeWithAni()
    self:setVisible(false)
    self._pCircle:stopAllActions()
    self._pCircle2:stopAllActions()
    self._pCircle3:stopAllActions()
    return
end

return WaitingLayer
