--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldFuncListMenu.lua
-- author:    liyuhang
-- created:   2015/10/19
-- descrip:   主UI 右下角主功能二级菜单
--===================================================
local WorldFuncListMenu = class("WorldFuncListMenu",function()
	return cc.Layer:create()
end)

-- 构造函数
function WorldFuncListMenu:ctor()
	self._strName = "WorldFuncListMenu" 
    self._pTouchListener = nil
	self._pParams = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

    self._tFuncBtns = {}
end

-- 创建函数
function WorldFuncListMenu:create()
	local menu = WorldFuncListMenu.new()
    menu:dispose()
	return menu
end

function WorldFuncListMenu:dispose()

    ResPlistManager:getInstance():addSpriteFrames("IconPanel.plist")

    local params = require("IconPanelParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pIconPanelBg
    self._pScrollView = params._pIPScrollView
    self:addChild(self._pCCS)

    local sNode = self._pCCS:getContentSize()
    local sScreen = mmo.VisibleRect:getVisibleSize()
    self._pCCS:setPosition(sScreen.width/2, sScreen.height/2)

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)
    
    self:initTouches()

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWorldFuncListMenu()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

function WorldFuncListMenu:setListMenuState(args)
    -- body
    if args == true then
        if self._pTouchListener then
            self._pTouchListener:setSwallowTouches(true)
            self._pTouchListener:setEnabled(true)
        end
        self:setVisible(true)
    else
        if self._pTouchListener then
            self._pTouchListener:setSwallowTouches(false)
            self._pTouchListener:setEnabled(false)
        end
        self:setVisible(false)
    end
end

-- 触摸注册
function WorldFuncListMenu:initTouches()   
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --return true
            self:setListMenuState(false)
        end
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

function WorldFuncListMenu:setDataInfo(info)
    self._pScrollView:removeAllChildren()
    self._tFuncBtns = {}

    for i=1,table.getn(info) do
        if TableMainUIFunc[info[i]].OpenConditions <= RolesManager:getInstance()._pMainRoleInfo.level then
            local funcBtn = require("WorldFuncBtn"):create( TableMainUIFunc[info[i]] )
            self._pScrollView:addChild(funcBtn,0)
            funcBtn:setStateAble()
            funcBtn:setPoints(
                cc.p(i*(104),60),
                cc.p(i*(104),60)
            )
            funcBtn:setCallback(mainActionFunc[TableMainUIFunc[info[i]].FuncId])
            table.insert(self._tFuncBtns , funcBtn)
        end
    end
end

-- 退出函数
function WorldFuncListMenu:onExitWorldFuncListMenu()
    ResPlistManager:getInstance():removeSpriteFrames("IconPanel.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return WorldFuncListMenu
