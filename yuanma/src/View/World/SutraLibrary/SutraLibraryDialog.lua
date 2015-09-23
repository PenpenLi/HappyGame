--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SutraLibraryDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/09/15
-- descrip:   藏经阁
--===================================================
local SutraLibraryDialog = class("SutraLibraryDialog",function () 
	return require("Dialog"):create()
end)

function SutraLibraryDialog:ctor() 
	self._strName = "SutraLibraryDialog"
	self._pCCS = nil 
	self._pBg = nil 

	-- 经书的名字
	self._pSturaBookNameText = nil
	-- 经书的解锁等级 
	self._pUnLockLevelText = nil 
	-- 经书所需残页的集合
	self._tSturaNeedPageNodeList = {}
	-- 经书残页加成属性
	self._tSturaPagePropertyTextList = {}
	-- 经书激活附加效果
	--self._tActivatePropertyList = {}
	self._pActiveBg = nil 
	-- 经书残页的滚动容器
	self._pSturaPageScrollView = nil 
	self._pSturaPageListController = nil 
	-- 上一页
	self._pPrevPageBtn = nil 
	-- 下一页
	self._pNextPageBtn = nil 
	--------------------------------------------
	self._nCurPageIndex = 1
	-- 页数
	self._nPageNum = #SturaLibraryManager:getInstance()._tSutraBookList
	-- 是否需要显示镶嵌残页的动画
	self._bShowInsetAni = false
	-- 当前镶嵌的进度条
	self._pCurLoadingBar = nil 
	self._nNewPercent = 0
end 

-- 创建函数
function SutraLibraryDialog:create()
	local dialog = SutraLibraryDialog.new()
	dialog:dispose()
	return dialog
end

-- 处理函数
function SutraLibraryDialog:dispose()
	ResPlistManager:getInstance():addSpriteFrames("JyuuBook.plist")
	-- 藏经阁镶嵌残页的网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kSturaInsertPageResp,handler(self,self.handleMsgInsertPage22403))
	-- 断线重连的网路回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected ,handler(self, self.respNetReconnected)) 

	local function onNodeEvent(event)
		if event == "exit" then 
			self:onExitSturaLibraryDialog()
		end
	end

	self:registerScriptHandler(onNodeEvent)

	-- 触摸注册
	self:initTouches()

	self:initUI()
end

-- 初始化UI
function SutraLibraryDialog:initUI()
	-- 加载控件
	local params = require("JyuuBookParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pSturaBookNameText = params._pBookNameText
	self._pUnLockLevelText = params._pUnLockText
	self._pSturaPageScrollView = params._pPageListView
	-- 经书所需残页的节点
	self._tSturaNeedPageNodeList = 
	{
		params._pNode_1,
		params._pNode_2,
		params._pNode_3,
		params._pNode_4,
		params._pNode_5,
	}

	-- 经书残页的加成属性
	self._tSturaPagePropertyTextList = 
	{
		params._pText_4,
		params._pText_5,
		params._pText_6,
		params._pText_7,
		params._pText_8,
	}
	-- 经书全部激活加成属性的背景
	self._pActiveBg = params._pActiveBg
	-- 上一页按钮
	self._pPrevPageBtn = params._pPrevPageBtn
	self._pPrevPageBtn:addTouchEventListener(function (sender,eventType)
		if eventType == ccui.TouchEventType.ended then 
			self._nCurPageIndex = self._nCurPageIndex == 1 and self._nPageNum or self._nCurPageIndex - 1
			self:turnPage(self._nCurPageIndex)
		end
	end)
	-- 下一页按钮
	self._pNextPageBtn = params._pNextPageBtn
	self._pNextPageBtn:addTouchEventListener(function (sender,eventType)
		if eventType == ccui.TouchEventType.ended then 
			self._nCurPageIndex = self._nCurPageIndex == self._nPageNum and 1 or self._nCurPageIndex + 1
			self:turnPage(self._nCurPageIndex)
		end
	end)

	self:disposeCSB()

	-- 注入残页的事件
	local function insertPageEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if self._bShowInsetAni == true then 
				return
			end
			-- 翻页按钮不可用
			self._pPrevPageBtn:setTouchEnabled(false)
			self._pNextPageBtn:setTouchEnabled(false)
			local nPageIndex = sender:getTag() - 10000
			local pSturaBookInfo = SturaLibraryManager:getInstance()._tSutraBookList[self._nCurPageIndex]
			-- 玩家嵌入的残页数量
			local nHasPageNum = 0
		 	if pSturaBookInfo.pages ~= nil and pSturaBookInfo.pages[nPageIndex] ~= nil then 
		 		nHasPageNum = pSturaBookInfo.pages[nPageIndex]
		 	end

		 	-- 需要消耗的残页
		 	local nConstPagesNum = pSturaBookInfo.dataInfo.PageDetails[nPageIndex][2]
			
			if nHasPageNum >= nConstPagesNum then 
				NoticeManager:getInstance():showSystemMessage("已经全部嵌入成功")
				self:respNetReconnected()
				return
			end

			if SturaLibraryManager:getInstance():getSturaPageInfoById(pSturaBookInfo.dataInfo.PageDetails[nPageIndex][1]).value <= 0 then 
				NoticeManager:getInstance():showSystemMessage("所需残页数量不足")
				self:respNetReconnected()
				return 
			end

			if FinanceManager:getValueByFinanceType(kFinance.kCoin) < pSturaBookInfo.dataInfo.PageDetails[nPageIndex][3] then 
				NoticeManager:getInstance():showSystemMessage("金币数量不足")
				self:respNetReconnected()
				return 
			end

			SturaLibraryCGMessage:InsertPageReq22402(pSturaBookInfo.id,nPageIndex)
		end
	end

	-- 为残页添加自定义进度条
	for i = 1,5 do
		-- 残页进度条背景
		local pLoadingBarBg = cc.Sprite:createWithSpriteFrameName("JyuuBookRes/jsjm_005.png")
		pLoadingBarBg:setRotation(90)
		pLoadingBarBg:setPosition(cc.p(0,-60))
		self._tSturaNeedPageNodeList[i]:addChild(pLoadingBarBg)
		-- 残页进度条
		local pSprite = cc.Sprite:createWithSpriteFrameName("JyuuBookRes/jsjm_004.png")
		local pLoadingBar = cc.ProgressTimer:create(pSprite)
		pLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
		pLoadingBar:setRotation(90)
		pLoadingBar:setPosition(cc.p(0,-63))
		pLoadingBar:setMidpoint(cc.p(1,0))
		pLoadingBar:setBarChangeRate(cc.p(1, 0))
		pLoadingBar:setName("loadingBar")
		pLoadingBar:setPercentage(i * 10)
		self._tSturaNeedPageNodeList[i]:addChild(pLoadingBar)
		-- 所需残页数量标签
		local pNeedPageNumText = ccui.Text:create()
		pNeedPageNumText:setFontName(strCommonFontName)
		pNeedPageNumText:setPosition(cc.p(3.5,-80))
		pNeedPageNumText:setName("pageNumText")
		self._tSturaNeedPageNodeList[i]:addChild(pNeedPageNumText)

		-- 注入按钮添加点击响应
		local pInsertBtn = self._tSturaNeedPageNodeList[i]:getChildByName("ZRButton")
		pInsertBtn:setTag(10000 + i)
		pInsertBtn:addTouchEventListener(insertPageEvent)
	end

	self._pSturaPageListController = require("ListController"):create(self,
		self._pSturaPageScrollView,listLayoutType.LayoutType_vertiacl,102,102)
	self._pSturaPageListController:setVertiaclDis(10)
	self._pSturaPageListController:setCellAnchorPointType(1)
	self._pSturaPageListController:setHorizontalDis(-51)
	-- 获取集合的个数
	self._pSturaPageListController._pNumOfCellDelegateFunc = function ()
		return #SturaLibraryManager:getInstance()._tSutraPages
	end
	self._pSturaPageListController._pDataSourceDelegateFunc = function (delegate,controller,index)
		local cell = controller:dequeueReusableCell()
		if not cell then 
			cell = require("BagItemCell"):create()
			cell:setItemInfo(SturaLibraryManager:getInstance()._tSutraPages[index])
		else
			cell:setItemInfo(SturaLibraryManager:getInstance()._tSutraPages[index])
		end
		return cell
	end
	self._pSturaPageListController:setDataSource(SturaLibraryManager:getInstance()._tSutraPages)

	-- 检查是否有新解锁的藏经阁
	if SturaLibraryManager:getInstance():checkNewUnlockBooks() == true then 
		local nBookId = SturaLibraryManager:getInstance()._nCurUnLockBookId
		local pSturaBookInfo = SturaLibraryManager:getInstance():getLocalSturaBookInfoById(nBookId)
		-- 显示解锁的经书信息
		self._nCurPageIndex = pSturaBookInfo.index
		self:turnPage(pSturaBookInfo.index)
		self:showSturaLibraryUnlockAni()
	else
		-- 默认选中第一页
		self:turnPage(1)
	end
end


-- 翻页
function SutraLibraryDialog:turnPage(nPageIndex)
	self:showSturaBookInfo(SturaLibraryManager:getInstance()._tSutraBookList[nPageIndex])
end

-- 显示经书的信息
function SutraLibraryDialog:showSturaBookInfo(pSturaBookInfo)
	-- 经书的名字
	self._pSturaBookNameText:setString(pSturaBookInfo.dataInfo.BookName)
	self._pUnLockLevelText:setString(pSturaBookInfo.dataInfo.RequiredLevel.."级解锁")
	-- 角色的等级
	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level
	-- 经书的解锁等级
	if roleLevel < pSturaBookInfo.dataInfo.RequiredLevel then 
		self._pSturaBookNameText:setVisible(false)
		self._pUnLockLevelText:setVisible(true)
	else
		self._pSturaBookNameText:setVisible(true)
		self._pUnLockLevelText:setVisible(false)
	end
	-- 更新经书残页的信息
	for i = 1,5 do
	 	-- 残页注入程度的进度条
	 	local pLoadingBar = self._tSturaNeedPageNodeList[i]:getChildByName("loadingBar")
	 	-- 残页数值的标签
	 	local pPageNumText = self._tSturaNeedPageNodeList[i]:getChildByName("pageNumText")
	 	-- 镶嵌残页所需货币
	 	local pNeedConText = self._tSturaNeedPageNodeList[i]:getChildByName("MoneyText")
	 	-- 残页的属性
	 	local pPagePropertyText = self._tSturaPagePropertyTextList[i]
	 	---------------- data -----------------------------------------------------------
	 	-- 玩家嵌入残页的数量
	 	local nHasPageNum = 0
	 	if pSturaBookInfo.pages ~= nil and pSturaBookInfo.pages[i] ~= nil then 
	 		nHasPageNum = pSturaBookInfo.pages[i]
	 	end
	 	-- 需要消耗的残页
	 	local nConstPagesNum = pSturaBookInfo.dataInfo.PageDetails[i][2]
	 	pPageNumText:setString(nHasPageNum .."/" ..nConstPagesNum)
	 	local nPercent = math.ceil(nHasPageNum / nConstPagesNum * 100) 
	 	pLoadingBar:setPercentage(nPercent)
	 	-- 设置属性
	 	pPagePropertyText:setString(getStrAttributeRealValue(pSturaBookInfo.dataInfo.PageDetails[i][4],pSturaBookInfo.dataInfo.PageDetails[i][5] * nPercent))
	 	pNeedConText:setString(pSturaBookInfo.dataInfo.PageDetails[i][3]) 
	 	if pSturaBookInfo.dataInfo.PageDetails[i][3] > FinanceManager:getValueByFinanceType(kFinance.kCoin) then 
	 		pNeedConText:setColor(cRed)
	 	else
	 		pNeedConText:setColor(cWhite)
	 	end
	 end 
end

-- 监听镶嵌残页的网络回调
function SutraLibraryDialog:handleMsgInsertPage22403(event)
	-- 更新残页的信息
	self._pSturaPageListController:setDataSource(SturaLibraryManager:getInstance():getLocalSturaPages())
	local pSturaBookInfo = SturaLibraryManager:getInstance()._tSutraBookList[self._nCurPageIndex]
	local pageInde = event.pageIndex
	-- 玩家已经嵌入残页的数量
 	local nHasPageNum = 0
 	if pSturaBookInfo.pages ~= nil and pSturaBookInfo.pages[pageInde] ~= nil then 
 		nHasPageNum = pSturaBookInfo.pages[pageInde]
 	end
 	-- 需要消耗的残页
 	local nConstPagesNum = pSturaBookInfo.dataInfo.PageDetails[pageInde][2]
 	-- 残页数值的标签
	local pPageNumText = self._tSturaNeedPageNodeList[pageInde]:getChildByName("pageNumText")
 	pPageNumText:setString(nHasPageNum .."/" ..nConstPagesNum)

 	local nPercent = math.ceil(nHasPageNum / nConstPagesNum * 100) 
	self._tSturaPagePropertyTextList[pageInde]:setString(getStrAttributeRealValue(pSturaBookInfo.dataInfo.PageDetails[pageInde][4],pSturaBookInfo.dataInfo.PageDetails[pageInde][5] * nPercent))
	self._nNewPercent = nPercent 
	self._pCurLoadingBar = self._tSturaNeedPageNodeList[pageInde]:getChildByName("loadingBar")
	self._bShowInsetAni = true
	self._pPrevPageBtn:setTouchEnabled(true)
	self._pNextPageBtn:setTouchEnabled(true)
end

-- 监听断线重连的网路回调
function SutraLibraryDialog:respNetReconnected(event)
	self._pPrevPageBtn:setTouchEnabled(true)
	self._pNextPageBtn:setTouchEnabled(true)
end


function SutraLibraryDialog:update(dt)
	if self._bShowInsetAni == true then 
		self:playInsertPageAni(1)
	end
end

-- 进度条动画
function SutraLibraryDialog:playInsertPageAni(dt)
	if self._pCurLoadingBar:getPercentage() + dt <= self._nNewPercent then 
		self._pCurLoadingBar:setPercentage(self._pCurLoadingBar:getPercentage() + dt)
	else
		self._bShowInsetAni = false
		-- 检查是否全部激活
		if self._nNewPercent >= 100 then 
			self:checkIsSturaBookAllActivate()
		end
	end
end

-- 检查当前残页是否已经全部激活
function SutraLibraryDialog:checkIsSturaBookAllActivate()
	local pSturaBookInfo = SturaLibraryManager:getInstance()._tSutraBookList[self._nCurPageIndex]
	local bActive = true
	for i,v in ipairs(pSturaBookInfo.pages) do
		local nConstPagesNum = pSturaBookInfo.dataInfo.PageDetails[i][2]
		if v < nConstPagesNum then 
			bActive = false
		end
	end
	if bActive == true then 
		pSturaBookInfo.state = 2 -- 表示经书已经全部激活
		self:showSturaBookAllActivateAni()
		-- 检查最新解锁的经书
		if SturaLibraryManager:getInstance():checkNewUnlockBooks() == true then 
			-- 如果有新的藏经阁解锁
			local nBookId = SturaLibraryManager:getInstance()._nCurUnLockBookId
			local pSturaBookInfo = SturaLibraryManager:getInstance():getLocalSturaBookInfoById(nBookId)
			pSturaBookInfo.index = pSturaBookInfo.index
			self._nCurPageIndex = pSturaBookInfo.index
			self:turnPage(pSturaBookInfo.index)
			self:showSturaLibraryUnlockAni()
		end
	end
end

-- 藏经阁解锁特效
function SutraLibraryDialog:showSturaLibraryUnlockAni()
	print("test ......... 藏经阁解锁特效")
end

-- 经书残页全部激活的特效
function SutraLibraryDialog:showSturaBookAllActivateAni()
	print("test .... 经书全部激活")
end

-- 触摸注册
function SutraLibraryDialog:initTouches() 	
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

end

-- 退出函数
function SutraLibraryDialog:onExitSturaLibraryDialog()
	-- cleanup
	self:onExitDialog()
	ResPlistManager:getInstance():removeSpriteFrames("JyuuBook.plist")
	NetRespManager:getInstance():removeEventListenersByHost(self)
end

return SutraLibraryDialog
