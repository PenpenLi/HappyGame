--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SlideDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/12
-- descrip:   活动幻灯片
--===================================================
local SlideDialog = class("SlideDialog",function ()
	return require("Dialog"):create()
end)

function SlideDialog:ctor()
	self._strName = "SlideDialog"
	self._pCloseButton = nil 
	self._pCCS = nil 
	self._pBg = nil
	self._pGoBtn = nil
	self._pImgPageView = nil 
	self._pPageIndexImg = nil 
	-----------------------------
	-- 当前选中的活动类型
	self._nCurActivityType = 0
	-- 代表页数的小点
	self._tPageIndexImgs = {}
	-- 自动翻页的定时器
	self._pSchedulerEntry = nil 
	-- 当前页数
	self._curPageIndex = 1
	-- 每一页的宽度
	self._nRenderWidth = 500
	-- 点击之后延时
	self._nDelaySec = 0
    -- 是否正在滑动中
    self._bMoving = false
    -- 允许滑动的像素
    self._nMoveDis = 0
    -- 滚动容器所在矩形
    self._recBg = cc.rect(0,0,0,0)
end

function SlideDialog:create()
	local dialog = SlideDialog.new()
	dialog:dispose()
	return dialog
end

function SlideDialog:dispose()
	-- add plist 
	ResPlistManager:getInstance():addSpriteFrames("AdvertiseMent.plist")
	ResPlistManager:getInstance():addSpriteFrames("AdvertiseMentPic.plist")

	local function onNodeEvent(event)
		if event == "cleanup" then 
			self:onExitSlideDialog()
		end
	end
    self:registerScriptHandler(onNodeEvent)

    self:initUI()
    self:changePageIndex(1)
end

function SlideDialog:initUI()
	local params = require("AdvertiseMentParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pImgPageView = params._pPictureQ	
    self._pImgPageView:setTouchEnabled(false)
	self._pGoBtn = params._pOkButton
	self._pPageIndexImg = params._pNowButton
	self._tPageIndexImgs[1] = self._pPageIndexImg
	self:disposeCSB()

    local x,y = self._pImgPageView:getPosition()
    local size = self._pImgPageView:getContentSize()
    local anchor = self._pImgPageView:getAnchorPoint()
    local posView = self._pBg:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posView.x,posView.y,size.width,size.height)

	-- 加载广告图片
	self._pageNum =  #TableAdvertiseMent
	local s = self._pImgPageView:getInnerContainerSize()
	local contentWidth = 0
	for i,advertiseInfo in ipairs(TableAdvertiseMent) do
		local adImg = cc.Sprite:createWithSpriteFrameName("AdvertiseMentPic/"..advertiseInfo.ResourcesName..".png")	
		contentWidth = contentWidth + self._nRenderWidth 
		adImg:setAnchorPoint(cc.p(1, 0.5))
		adImg:setPosition(cc.p(contentWidth,s.height/2))
		self._pImgPageView:addChild(adImg)
	end
	if contentWidth > s.width then
        self._pImgPageView:setInnerContainerSize(cc.size(contentWidth,s.height))
	end
	s = self._pImgPageView:getInnerContainerSize()

    local gapX = self._pPageIndexImg:getContentSize().width
    -- 加载对应按钮
    for i = 1, #TableAdvertiseMent do
    	if i == 1 then 
    		self._tPageIndexImgs[1]:setVisible(true)
        else
            self._tPageIndexImgs[i] = self._pPageIndexImg:clone()
            self._pBg:addChild(self._tPageIndexImgs[i])    
    	end
    	self._tPageIndexImgs[i]:setPositionX(self._tPageIndexImgs[i]:getPositionX() + gapX *( i - 1))
    end

    -- 幻灯片特效
    local function slideAni ()
        if self._bMoving == true then 
            return
        end

    	if self._nDelaySec > 0 then 
    		self._nDelaySec = self._nDelaySec - 1
    		return
    	end

    	self:changePageIndex(self._curPageIndex + 1)
    end
    self._pSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(slideAni,3.0,false)
   
    self:initTouchEvent()
end

function SlideDialog:changePageIndex(index)
	    if index == self._pageNum + 1 then 
    		self._pImgPageView:jumpToLeft()
    		self._tPageIndexImgs[1]:loadTexture("AdvertiseMentRes/ggjm6.png",ccui.TextureResType.plistType)
    		self._tPageIndexImgs[self._pageNum]:loadTexture("AdvertiseMentRes/ggjm7.png",ccui.TextureResType.plistType)
    		self._curPageIndex = 1
    		return
    	else
    		local percent = (index - 1) / (self._pageNum - 1)
    		self._pImgPageView:scrollToPercentHorizontal(math.floor(percent * 100),0.5,false)
            self._curPageIndex = index
    	end

	for i,v in ipairs(self._tPageIndexImgs) do
		local imgName = "AdvertiseMentRes/ggjm7.png"
		if i == index then 
			imgName = "AdvertiseMentRes/ggjm6.png"
		end
		v:loadTexture(imgName,ccui.TextureResType.plistType)
	end
end

function SlideDialog:initTouchEvent()
	-- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        if cc.rectContainsPoint(self._recBg,location) == true then
       	    self._nDelaySec = 3
        end

        return true
    end

    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        if cc.rectContainsPoint(self._recBg,location) == true then
            self._nMoveDis = self._nMoveDis + 1 
    	    if self._nMoveDis > 5 then 
                self._bMoving = true
            end
        end
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        if cc.rectContainsPoint(self._recBg,location) == true then
            self._nDelaySec = 3
            local startLocationX = touch:getStartLocation().x
            local locationX = touch:getLocation().x
            if math.abs(locationX - startLocationX) >= 100 and self._bMoving == true then 
                if locationX - startLocationX < 0 then  --表示向左滑动
                    if self._curPageIndex ~= self._pageNum then
                        self._curPageIndex = self._curPageIndex + 1
                    else
                        self._curPageIndex = 1
                    end
            	else 
                    if self._curPageIndex == 1 then 
                        self._curPageIndex = self._pageNum
                    else
                        self._curPageIndex = self._curPageIndex - 1
                    end
                end
                self:changePageIndex(self._curPageIndex)
            end
        end
        self._bMoving = false
    end

    local function onTouchCancelled(touch,event)
        self._bMoving = false
    	self._nDelaySec = 3
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self._pTouchListener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

function SlideDialog:onExitSlideDialog()
	self:onExitDialog()
	if self._pSchedulerEntry ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pSchedulerEntry )
        self._pSchedulerEntry = nil
    end  
	ResPlistManager:getInstance():removeSpriteFrames("AdvertiseMent.plist")
    ResPlistManager:getInstance():removeSpriteFrames("AdvertiseMentPic.plist") 
end

return SlideDialog