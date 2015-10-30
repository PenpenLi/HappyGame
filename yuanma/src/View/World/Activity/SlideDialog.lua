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
    self._pImgPageViewInner = nil
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
    --table表中的页数
    self._tablePageNum = 0
    --scroll列表中的页数
    self._scrollPageNum = 0
    self._everyTurnMove = -500
    self._everyTurnTime = 0.5
	-- 每一页的宽度
	self._nRenderWidth = 0
    self._nInnerWidth = 0
    -- 滚动容器所在矩形
    self._recBg = cc.rect(0,0,0,0)
    self._touchInAd = false
    self._nDir = 0 -- -1 为向左边滑动，1为向右滑动
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
        elseif event == "enter" then
            self:enter()
		end
	end
    self:registerScriptHandler(onNodeEvent)

    self:initUI()
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
    self._pImgPageViewInner = self._pImgPageView:getInnerContainer()
    self._nRenderWidth = size.width
    self._recBg = cc.rect(posView.x,posView.y,size.width,size.height)

	-- 加载广告图片
	self._tablePageNum =  #TableAdvertiseMent

    local EndInfo = TableAdvertiseMent[self._tablePageNum]
    self:initAdImg(EndInfo)

	for i,advertiseInfo in ipairs(TableAdvertiseMent) do
        self:initAdImg(advertiseInfo)
	end

    local firstInfo = TableAdvertiseMent[1]
    self:initAdImg(firstInfo)

    local s = self._pImgPageView:getInnerContainerSize()
    if self._nInnerWidth > s.width then
        self._pImgPageView:setInnerContainerSize(cc.size(self._nInnerWidth,s.height))
    end

end

function SlideDialog:initAdImg(AdvertiseMentInfo)
    local s = self._pImgPageView:getInnerContainerSize()
    local adImg = cc.Sprite:createWithSpriteFrameName("AdvertiseMentPic/"..AdvertiseMentInfo.ResourcesName..".png") 
    self._nInnerWidth = self._nInnerWidth + self._nRenderWidth 
    adImg:setAnchorPoint(cc.p(1, 0.5))
    adImg:setPosition(cc.p(self._nInnerWidth,s.height/2))
    self._pImgPageView:addChild(adImg)
    self._scrollPageNum = self._scrollPageNum + 1
end

--为了初始设置滚动列表位置
function SlideDialog:enter(  )
    local innerY = self._pImgPageViewInner:getPositionY()
    self._pImgPageViewInner:setPosition(cc.p(-self._nRenderWidth,innerY))
    self._curPageIndex = 2

    local pageNum = #TableAdvertiseMent
    local scaleX = self._pPageIndexImg:getScaleX()
    local gapX = self._pPageIndexImg:getContentSize().width*scaleX
    local invX = 10
    local startX = (self._nRenderWidth - pageNum*(gapX+invX) + invX)/2 + self._pImgPageView:getPositionX()+gapX/2
    -- 加载对应按钮
    for i = 1, pageNum do
        if i == 1 then 
            self._tPageIndexImgs[1]:setVisible(true)
        else
            self._tPageIndexImgs[i] = self._pPageIndexImg:clone()
            self._pBg:addChild(self._tPageIndexImgs[i])    
        end
        self._tPageIndexImgs[i]:setPositionX(startX + (i-1)*(gapX+invX))
    end
    self:changeCurIndexImgs()

    self:scrollAutoActionAni()
    self:initTouchEvent()
end

function SlideDialog:changeCurIndexImgs(  )
    local innerX = math.abs(self._pImgPageViewInner:getPositionX())
    self._curPageIndex = math.ceil(innerX/self._nRenderWidth) 
    if innerX % self._nRenderWidth == 0 then
        self._curPageIndex = self._curPageIndex + 1
    end

    local index = self._curPageIndex
    if index == 1 then
        index = self._tablePageNum 
    elseif index == self._scrollPageNum then
        index = 1
    else
        index = index -1
    end

    for i,v in ipairs(self._tPageIndexImgs) do
        local imgName = "AdvertiseMentRes/ggjm7.png"
        if i == index then 
            imgName = "AdvertiseMentRes/ggjm6.png"
        end
        v:loadTexture(imgName,ccui.TextureResType.plistType)
    end
end

--自动朝左侧移动
function SlideDialog:scrollAutoActionAni(  )
    self._everyTurnMove = -self._nRenderWidth
    self._everyTurnTime = 0.5
    local SequenceAction = cc.Sequence:create(
        cc.DelayTime:create(2.5),
        cc.MoveBy:create(self._everyTurnTime, cc.p(self._everyTurnMove, 0)),
        cc.CallFunc:create(function (  )
            local innerX = self._pImgPageViewInner:getPositionX() - 5
            if innerX <= -self._nInnerWidth+self._nRenderWidth then
                self._pImgPageViewInner:setPositionX(-self._nRenderWidth)
            end
            self:changeCurIndexImgs()
        end)
    )

    self._pImgPageViewInner:stopAllActions()
    self._pImgPageViewInner:runAction(cc.RepeatForever:create(SequenceAction))
end
--触摸屏幕时停止滚动
function SlideDialog:stopActionAni(  )
    self._pImgPageViewInner:stopAllActions()
end

function SlideDialog:initTouchEvent()
	 -- 触摸注册
    local function onTouchBegin(touch,event)
        self._touchInAd = false
        self._nDir = 0
        local location = touch:getLocation()
        local previouslocation = touch:getPreviousLocation()
        if cc.rectContainsPoint(self._recBg,location) == true then
            self._touchInAd = true
            self:stopActionAni()
        end

        return true
    end

    local function onTouchMoved(touch,event)
        if not self._touchInAd then
            return
        end
        local location = touch:getLocation()
        local previouslocation = touch:getPreviousLocation()
        if cc.rectContainsPoint(self._recBg,location) == true then
            local moveDisX = location.x - previouslocation.x
            if math.floor(math.abs(moveDisX)) < 1 then
                return
            end
            if moveDisX > 0 then
                self._nDir = 1
            else
                self._nDir = -1
            end

            local innerX = self._pImgPageViewInner:getPositionX()
            innerX = innerX + moveDisX

            --判断是否需要重新定位
            if innerX > -self._nRenderWidth then  --向右边拖动时
                local inv = innerX + self._nRenderWidth
                innerX = -self._nInnerWidth + self._nRenderWidth + inv
            elseif innerX <= -(self._nInnerWidth - self._nRenderWidth) then
                local inv = -self._nInnerWidth + self._nRenderWidth - innerX
                innerX = -self._nRenderWidth - inv
            end
            self._pImgPageViewInner:setPositionX(innerX)

            self:changeCurIndexImgs()

        end
    end
    local function onTouchEnded(touch,event)
        if not self._touchInAd then
            return
        end
        self._touchInAd = false
        --需要自动回弹
        local innerX = self._pImgPageViewInner:getPositionX()
        local inv = math.abs(innerX)%self._nRenderWidth 
        if self._nDir == 1 then
            self._everyTurnMove = inv
        else
            self._everyTurnMove = -(self._nRenderWidth-inv)
        end            
        self._everyTurnTime = 0.5*math.abs(self._everyTurnMove)/self._nRenderWidth
        local SequenceAction = cc.Sequence:create(
            cc.MoveBy:create(self._everyTurnTime, cc.p(self._everyTurnMove, 0)),
            cc.CallFunc:create(function (  )
                --2为调试像素
                local innerX = self._pImgPageViewInner:getPositionX()
                if innerX - 2 <= -(self._nInnerWidth - self._nRenderWidth) then
                    innerX = -self._nRenderWidth
                end
                self._pImgPageViewInner:setPositionX(innerX)

                self:changeCurIndexImgs()
                self:scrollAutoActionAni()
            end))

            self._pImgPageViewInner:stopAllActions()
            self._pImgPageViewInner:runAction(SequenceAction)

        local location = touch:getLocation()
        if cc.rectContainsPoint(self._recBg,location) == true then
        end
    end

    local function onTouchCancelled(touch,event)
        self._touchInAd = false
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
	ResPlistManager:getInstance():removeSpriteFrames("AdvertiseMent.plist")
    ResPlistManager:getInstance():removeSpriteFrames("AdvertiseMentPic.plist") 
end

--原来的滚动定时器
--[[function SlideDialog:startSlideAni(fDelayTime)
    if nil ~= self._pSchedulerEntry then
        return
    end

    -- 幻灯片特效
    local function slideAni ()

        if self._curPageIndex == self._scrollPageNum - 1 then 
            local innerY = self._pImgPageViewInner:getPositionY()
            self._pImgPageViewInner:setPosition(cc.p(0,innerY))
            self._curPageIndex = 1
        end

        self:changePageIndex(self._curPageIndex + 1)
    end
    self._pSchedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(slideAni,fDelayTime,false)
end

function SlideDialog:stopSlideAni(  )
    if self._pSchedulerEntry ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pSchedulerEntry)
        self._pSchedulerEntry = nil
    end  
end

function SlideDialog:changePageIndex(index)
    local percent = (index - 1) / (self._scrollPageNum - 1)
    self._pImgPageView:scrollToPercentHorizontal(math.floor(percent * 100),0.5,false)
    self._curPageIndex = index

    self:changeCurIndexImgs()
end]]


return SlideDialog