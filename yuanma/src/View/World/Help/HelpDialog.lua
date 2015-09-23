--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ArenaDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/05/21
-- descrip:   帮助界面
--===================================================

local HelpDialog = class("HelpDialog",function() 
	return require("Dialog"):create()
end)

function HelpDialog:ctor()
	self._strName = "HelpDialog"
	self._pCloseButton = nil 
	self._pCCS = NIL 
	self._pBg = nil 

	self._pTitleImg = nil 
	self._pContainerList = nil 
	self._pText = nil 
	-- 小标题字体颜色
	self._subTitleColor = cOrange
end

function HelpDialog:create(helpSysType)
	local dialog = HelpDialog.new()
	dialog:dispose(helpSysType)
	return dialog
end

function HelpDialog:dispose(helpSysType)   
    ResPlistManager:getInstance():addSpriteFrames("HelpText.plist")
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitHelpDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	 -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
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
    self:initUI()
    self:setDataSource (helpSysType)
end

function HelpDialog:initUI()
	local params = require("HelpTextParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton

	self._pContainerList = params._pListView
	self._pText = params._pText
	self._pContainerList:setItemModel(self._pText)	
	self._pTitleImg = params._pTitle
    
    self:disposeCSB()
end

function HelpDialog:setDataSource (helpSysType)
	
	local helpInfo = TableHelpText[helpSysType]

	if not helpInfo then
		return
	end

	self._pTitleImg:loadTexture(helpInfo.Headline..".png",ccui.TextureResType.plistType)

	self._pContainerList:removeAllChildren()
	for i = 1,helpInfo.ParagraphNum * 2 do
		if helpInfo["Subtitle"..i] ~= nil then 
            local pLabel = cc.Label:createWithTTF(helpInfo["Subtitle"..i],strCommonFontName,30)
			pLabel:setColor(self._subTitleColor)
           
            local custom_item = ccui.Layout:create()
        	custom_item:setContentSize(pLabel:getContentSize())
        	pLabel:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
        	custom_item:addChild(pLabel)
        
        	self._pContainerList:pushBackCustomItem(custom_item) 
		end
		if helpInfo["Text"..i] ~= nil then 
            local pLabel = cc.Label:createWithTTF(helpInfo["Text"..i],strCommonFontName,25)
            pLabel:setWidth(self._pContainerList:getContentSize().width)
        	pLabel:setLineBreakWithoutSpace(true)
   
        	local custom_item = ccui.Layout:create()
        	custom_item:setContentSize(pLabel:getContentSize())
        	pLabel:setPosition(cc.p(custom_item:getContentSize().width / 2.0, custom_item:getContentSize().height / 2.0))
        	custom_item:addChild(pLabel)
        
        	self._pContainerList:pushBackCustomItem(custom_item) 
            
		end
	end
end

function HelpDialog:onExitHelpDialog()
    ResPlistManager:getInstance():removeSpriteFrames("HelpText.plist")
end

return HelpDialog