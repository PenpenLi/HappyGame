--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NoPetCell.lua
-- author:    liyuhang
-- created:   2015/7/23
-- descrip:   未获得宠物
--===================================================
local NoPetCell = class("NoPetCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function NoPetCell:ctor()
    -- 层名称
    self._strName = "NoPetCell"        

    -- 地图背景
    self._pParams = nil
    self._pBg = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形
end

-- 创建函数
function NoPetCell:create()
    local dialog = NoPetCell.new()
    dialog:dispose()
    return dialog
end

-- 处理函数
function NoPetCell:dispose()
    self:initUI()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,pLocal) == false then

        end

        return false
    end
    local function onTouchMoved(touch,event)
        local location = self._pBg:convertTouchToNodeSpace(touch)

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)

    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitNoPetCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function NoPetCell:initUI()
    -- 加载csb 组件
    local params = require("NoPetParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackBg

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)

end

--退出函数
function NoPetCell:onExitNoPetCell()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return NoPetCell
