--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyRegisterDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/08
-- descrip:   家族查找创建界面
--===================================================

local FamilyRegisterDialog = class("FamilyRegisterDialog",function()
	return require("Dialog"):create()
end)

function FamilyRegisterDialog:ctor()
	self._strName = "FamilyRegisterDialog"
	self._pCloseButton = nil 
	self._pCCS = nil
	self._pBg = nil 
	-- 家族滚动容器
	self._pFamilyScrollView = nil 
	-- 家族宗旨
	self._pFamilyPurposeText = nil 
	-- 查找家族的名字
	self._pQueryFamilyNameText = nil 
	-- 查找家族的按钮
	self._pQueryFamilyBtn = nil 
	-- 申请加入
	self._pApplyFamilyBtn = nil 
	-- 创建家族
	self._pCreateFamilyBtn = nil 
	-- 家族排行
	self._pFamilyRankBtn = nil 
	-- 上一页按钮
	self._pPrevPageBtn = nil 
	-- 下一页按钮
	self._pNextPageBtn = nil 
	-- 当前页数信息
	self._pPageText = nil 
	--------data-----------------------
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
	-- 是否响应查询家族排行的相应
	self._isRespEffective = true
end

function FamilyRegisterDialog:create(args)
	local dialog = FamilyRegisterDialog.new()
	dialog:dispose()
	return dialog
end

function FamilyRegisterDialog:dispose()
	-- 家族创建查找纹理           
	ResPlistManager:getInstance():addSpriteFrames("HomeLoginDialog.plist")
	-- 家族列表
	ResPlistManager:getInstance():addSpriteFrames("LoginLeftList.plist")
	-- 查询家族排行的网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFamilyListResp, handler(self,self.handleMsgQueryFamilyList22301))
	-- 查找家族网络回调 
	NetRespManager:getInstance():addEventListener(kNetCmd.kFindFamilyResp, handler(self,self.handleMsgQueryFamily22305))
	-- 申请家族的网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kApplyFamilyResp, handler(self,self.handleMsgApplyFamily22309))
    --服务器主动推的家族变化信息
    NetRespManager:getInstance():addEventListener(kNetCmd.kEnteryFamilyResp ,handler(self, self.enteryFamilyResp))
    -- 断线重连的网路回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected ,handler(self, self.respNetReconnected)) 

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyRegisterDialog()
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
    
    self:initBtnEvent()
end

function FamilyRegisterDialog:initUI()
	local params = require("HomeLoginDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
    self._pFamilyScrollView = params._pLeftScrollView
	self._pQueryFamilyBtn = params._pLookUpButton
	self._pFamilyPurposeText = params._pText_7
	self._pPutInTextNode = params._pPutInTextNode
	self._pFamilyPurposeText:setString("")
	self._pApplyFamilyBtn = params._pButton2
	self._pCreateFamilyBtn = params._pButton3
	self._pFamilyRankBtn = params._pButton4
	self._pPrevPageBtn = params._pPreviousButton
	self._pNextPageBtn = params._pNextButton
	self._pPageText = params._pPageText
	self:disposeCSB()
	self._pQueryFamilyNameText = createEditBoxBySize(cc.size(300,50),TableConstants.NameMaxLenWord.Value)
	params._pPutInTextNode:addChild(self._pQueryFamilyNameText)
end

--注册界面按钮的点击事件
function FamilyRegisterDialog:initBtnEvent()
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender:getName() == "create" then 
				DialogManager:getInstance():showDialog("FamilyCreateDialog")	
			elseif sender:getName() == "query" then 
				if self._pQueryFamilyNameText:getText() == "" then 
					NoticeManager:getInstance():showSystemMessage("请输入要查找的家族名称")
					return
				end
				FamilyCGMessage:findFamilyReq22304(self._pQueryFamilyNameText:getText())
				sender:setTouchEnabled(false)
			elseif sender:getName() == "apply" then 
				if not self._pCurFamilyUnit then 
					NoticeManager:getInstance():showSystemMessage("先选择家族")
					return 
				end
				if self._pCurFamilyUnit.memCount >= self._pCurFamilyUnit.memTotal then 
					NoticeManager:getInstance():showSystemMessage("家族人数已满")
					return 
				end
				FamilyCGMessage:applyFamilyReq22308(self._pCurFamilyUnit.familyId)
			elseif sender:getName() == "rank" then
				-- 测试 
				DialogManager:getInstance():showDialog("FamilyRankDialog")
				FamilyCGMessage:queryFamilyListReq22300(0,8)
				self._isRespEffective = false
			elseif sender:getName() == "prevPage" then 
				self:pageChangeEvent(self._nPageIndex - 1)
			elseif sender:getName() == "nextPage" then 
				self:pageChangeEvent(self._nPageIndex + 1)
			end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end

	self._pCreateFamilyBtn:setName("create")
	self._pCreateFamilyBtn:addTouchEventListener(touchEvent)
	self._pQueryFamilyBtn:setName("query")
	self._pQueryFamilyBtn:addTouchEventListener(touchEvent)
	self._pApplyFamilyBtn:setName("apply")
	self._pApplyFamilyBtn:addTouchEventListener(touchEvent)
	self._pPrevPageBtn:setName("prevPage")
	self._pPrevPageBtn:addTouchEventListener(touchEvent)
	self._pNextPageBtn:setName("nextPage")
	self._pNextPageBtn:addTouchEventListener(touchEvent)
	self._pFamilyRankBtn:setName("rank")
	self._pFamilyRankBtn:addTouchEventListener(touchEvent)
end

function FamilyRegisterDialog:updateUI()
	local nRenderHeight = 60
	local nContentWidth = self._pFamilyScrollView:getInnerContainerSize().width
    local nContentHeight = self._pFamilyScrollView:getInnerContainerSize().height
    self._pFamilyScrollView:removeAllChildren(true)
	-- 家族选中回调
	local function selectedCallback(index)
		self._pCurFamilyUnit = self._tFamilyUnitArry[index]
		self._pFamilyPurposeText:setString(self._pCurFamilyUnit.purpose)
		for i,render in ipairs(self._pFamilyScrollView:getChildren()) do
			render:selectEvent(index)
		end	
	end
	for i,familyUnit in ipairs(self._tFamilyUnitArry) do
		local render = require("FamilyRegisterItemRender"):create()
		render:setDataSource(familyUnit,i,self._tFamilyListApplyStatus[i])
		render:setPosition(cc.p(nContentWidth/2,nContentHeight - (i - 0.5) * nRenderHeight))
		render:setCallback(selectedCallback)
		self._pFamilyScrollView:addChild(render)
	end
	local pageNum = math.ceil(self._nFamilyCount / 8) 
    pageNum = pageNum == 0 and 1 or pageNum
	self._pPageText:setString(self._nPageIndex.. "/"..pageNum)
	self._pPrevPageBtn:setVisible(self._nPageIndex > 1)
	self._pNextPageBtn:setVisible(self._nPageIndex ~= pageNum)
end

-- 查询家族排行的网络回调
function FamilyRegisterDialog:handleMsgQueryFamilyList22301(event)
	if self._isRespEffective == true then
		self._tFamilyUnitArry = event.familyList
		self._nFamilyCount = event.familyCount
		self._tFamilyListApplyStatus = event.applyInfo

		self:updateUI()
	end
end

-- 查找家族网络回调
function FamilyRegisterDialog:handleMsgQueryFamily22305(event)
	self._pQueryFamilyBtn:setTouchEnabled(true)
	if FamilyManager:getInstance()._position > 0 then 
		return
	end
	if event == "failed" then 
		return 
	end
	local familyUnit = event.familyInfo[1]
	local isApply = event.isApply
    if familyUnit then 
		DialogManager:getInstance():showDialog("FamilyInfoDialog",{familyUnit,isApply}) 
	end
end

-- 断线重连的网络回调
function FamilyRegisterDialog:respNetReconnected(event)
	-- 查询家族的按钮恢复点击
	self._pQueryFamilyBtn:setTouchEnabled(true)
end

-- 申请家族网络回调
function FamilyRegisterDialog:handleMsgApplyFamily22309(event)
	local familyId = event.familyId
	local idx,familyUnit = self:getFamilyInfoById(familyId)
	-- 同步数据
	if idx then 
		self._tFamilyListApplyStatus[idx] = true
		self._pFamilyScrollView:getChildren()[idx]:setApplyState(true)
	end
end

function FamilyRegisterDialog:enteryFamilyResp(event)
    if FamilyManager:getInstance()._bOwnFamily == true then --如果当前突然被加入家族
        DialogManager:getInstance():closeAllDialogs()
        NoticeManager:getInstance():showSystemMessage("您已经加入了家族")
        DialogManager:getInstance():showDialog("FamilyDialog")
    end
	
end

-- 根据家族Id 查找当前页家族的信息
function FamilyRegisterDialog:getFamilyInfoById(familyId)
	for i,familyUnit in ipairs(self._tFamilyUnitArry) do
		if familyUnit.familyId == familyId then
			return i,familyUnit
		end
	end
	return nil 
end

-- 翻页事件
function FamilyRegisterDialog:pageChangeEvent(pageIndex)
	local pageNum = math.ceil(self._nFamilyCount / 8)
	if pageIndex < 1 or pageIndex > pageNum then
		print("请求页数越界")
		return
	end
	self._nPageIndex = pageIndex
	local starIndex = (pageIndex - 1) * 8
	FamilyCGMessage:queryFamilyListReq22300(starIndex,8)
end

function FamilyRegisterDialog:onExitFamilyRegisterDialog()
	self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("HomeLoginDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("LoginLeftList.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FamilyRegisterDialog