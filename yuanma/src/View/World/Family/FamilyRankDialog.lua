--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyInfoDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/13
-- descrip:   家族创建界面
--===================================================

local FamilyRankDialog = class("FamilyRankDialog",function() 
	return require("Dialog"):create()
end)

function FamilyRankDialog:ctor()
	self._strName = "FamilyRankDialog"
	self._pCloseButton = nil 
	self._pCCS = nil
	self._pBg = nil 
	-- 家族排行滚动框
	self._pScrollView = nil 
	-- 前一页
	self._pPrevPageBtn = nil 
	-- 后一页
	self._pNextPageBtn = nil 
	------------------------------
	-- 家族列表
	self._tFamilyUnitArry = {}
	-- 当前选中的家族信息
	self._pCurFamilyUnit = nil 
	-- 当前页
	self._nPageIndex = 1
	-- 家族的数量
	self._nFamilyCount = 0
	-- 家族列表的申请状况
	self._tFamilyListApplyStatus = {}

end

function FamilyRankDialog:create(args)
	local dialog = FamilyRankDialog.new()
	dialog:dispose(args)
	return dialog
end

function FamilyRankDialog:dispose(args)
	-- 家族创建查找纹理           
	ResPlistManager:getInstance():addSpriteFrames("RakingsDialog.plist")
	ResPlistManager:getInstance():addSpriteFrames("HomeRankingsList.plist")
	-- 注册查询家族排行网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFamilyListResp, handler(self,self.handleMsgQueryFamilyList22301))
	
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyRankDialog()
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
    
    -- 初始化界面
    self:initUI()
end
function FamilyRankDialog:initUI()	
	local params = require("RakingsDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pScrollView = params._pRankingScrollView
	self._pPrevPageBtn = params._pPreviousButton1
	self._pNextPageBtn = params._pNextButton1
   
	self:disposeCSB()

	self:initBtnEvent()
end

function FamilyRankDialog:initBtnEvent()
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
            if sender:getName() == "prevPage" then 
				self:pageChangeEvent(self._nPageIndex - 1)
			elseif sender:getName() == "nextPage" then 
				self:pageChangeEvent(self._nPageIndex + 1)
			end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pPrevPageBtn:setName("prevPage")
	self._pPrevPageBtn:addTouchEventListener(touchEvent)
	self._pNextPageBtn:setName("nextPage")
	self._pNextPageBtn:addTouchEventListener(touchEvent)
end

function FamilyRankDialog:updateUI()
	local nRenderHeight = 70
	local nContentWidth = self._pScrollView:getInnerContainerSize().width
	local nContentHeight = self._pScrollView:getInnerContainerSize().height
    self._pScrollView:removeAllChildren(true)
	-- 家族选中回调
	local function selectedCallback(index)
		self._pCurFamilyUnit = self._tFamilyUnitArry[index]
		for i,render in ipairs(self._pScrollView:getChildren()) do
			render:selectEvent(index)
		end	
	end
	for i,familyUnit in ipairs(self._tFamilyUnitArry) do
		local render = require("FamilyRankItemRender"):create()
		render:setDataSource(familyUnit,i,self._tFamilyListApplyStatus[i])
		render:setPosition(cc.p(nContentWidth/2,nContentHeight - (i - 0.5) * nRenderHeight))
		render:setCallback(selectedCallback)
		self._pScrollView:addChild(render)
	end
	local pageNum = math.ceil(self._nFamilyCount / 8)
	self._pPrevPageBtn:setVisible(self._nPageIndex > 1)
	self._pNextPageBtn:setVisible(self._nPageIndex ~= pageNum)
end

-- 响应查找家族排行的回复
function FamilyRankDialog:handleMsgQueryFamilyList22301(event)
	self._tFamilyUnitArry = event.familyList
	self._nFamilyCount = event.familyCount
	self._tFamilyListApplyStatus = event.applyInfo

	self:updateUI()
end

-- 翻页事件
function FamilyRankDialog:pageChangeEvent(pageIndex)
	local pageNum = math.ceil(self._nFamilyCount / 8)
	if pageIndex < 1 or pageIndex > pageNum then
		print("请求页数越界")
		return
	end
	self._nPageIndex = pageIndex
	local starIndex = (pageIndex - 1) * 8
	FamilyCGMessage:queryFamilyListReq22300(starIndex,8)
end

function FamilyRankDialog:onExitFamilyRankDialog()
	self:onExitDialog()
	local familyRegisterDialog = DialogManager:getInstance():getDialogByName("FamilyRegisterDialog")
    if familyRegisterDialog then 
    	-- 家族查找创建界面恢复相应查找家族排行的功能
    	familyRegisterDialog._isRespEffective = true
    end
    ResPlistManager:getInstance():removeSpriteFrames("RakingsDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("HomeRankingsList.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FamilyRankDialog