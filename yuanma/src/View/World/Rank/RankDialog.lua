--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RankDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/12
-- descrip:   游戏各种排行榜面板
--===================================================
local RankDialog = class("RankDialog",function () 
	return require("Dialog"):create()
end)

function RankDialog:ctor()
	self._strName = "RankDialog"
	self._pCCS = nil 
	self._pBg = nil 
	self._pTagScrollView = nil 
	self._pTagItemRender = nil 
	self._tTitleText = {}	-- 排行内容标题
	self._pRankListController = nil 
	self._pRankScrollView = nil 
	self._pSelfRankText = nil  
	--------------------------------
	self._nCurTagIndex = 0

	self._tTitleString = 
	{
		[kRankType.kLevle] = {"排名","玩家昵称","职业","等级"},
		[kRankType.kFightPower] = {"排名","玩家昵称","职业","战力"},
		[kRankType.kFortune] = {"排名","玩家昵称","职业","玉璧"},
		[kRankType.kPet] = {"排名","玩家昵称","宠物名称","战力"},
		[kRankType.kAchievement] = {"排名","玩家昵称","职业","称号个数"},
	}
		
end

function RankDialog:create()
	local dialog = RankDialog.new()
	dialog:dispose()
	return dialog
end

function RankDialog:dispose()
	-- 加载必需的资源合图
	ResPlistManager:getInstance():addSpriteFrames("RankingListPanel.plist")
	ResPlistManager:getInstance():addSpriteFrames("ListPanel.plist")

	-- 获取排行榜的回复信息
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryRankListResp,handler(self,self.handleQueryRankListResp21321))  
	self:initUI()

	self:initTouchEvent()

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitRankDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

function RankDialog:initUI()
	local params = require("RankingListDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	-- 排行类型
	self._pTagScrollView = params._pLeftScrollView
	self._pTagItemRender = params._pRankingButton1
	self._pTagItemRender:setVisible(false)
	-- 排行内容标签
	self._pRankScrollView = params._pListScrollView
	-- 排行标签的文本
	self._tTitleText = 
	{
		params._pText_1,
		params._pText_2,
		params._pText_4,
		params._pText_3,
	}
	
	self._pSelfRankText = params._pText2

	self:disposeCSB()

	self:setTagDataSource()
end

function RankDialog:setTagDataSource()
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
            self:tagChanagerEvent(sender:getTag() - 10000)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
	end

	-- 标签的个数
	local tagNum = #TableRank
	local nInnerHeight = self._pTagScrollView:getContentSize().height
	local nInnerWidth = self._pTagScrollView:getContentSize().width
	local nRenderHeight = 90
	nInnerHeight = math.max(nInnerHeight, tagNum * nRenderHeight)		
	self._pTagScrollView:setInnerContainerSize(cc.size(nInnerWidth,nInnerHeight))
	for tag_index,tagInfo in ipairs(TableRank) do
		if tag_index == 1 then 
			self._pTagItemRender:setVisible(true)
			self._pTagItemRender:setTitleText(tagInfo.Text)
			self._pTagItemRender:setTag(10000 + tagInfo.ID)
			self._pTagItemRender:addTouchEventListener(touchEvent)
		else
			local tagRender = self._pTagItemRender:clone()
			tagRender:setTag(10000 + tagInfo.ID)
			tagRender:setTitleText(tagInfo.Text)
			tagRender:setPositionY(nInnerHeight - (tag_index - 0.5) * nRenderHeight)
			self._pTagScrollView:addChild(tagRender)
		end
	end

	-- 默认选中第一个排行榜
	self:tagChanagerEvent(1)
end

function RankDialog:tagChanagerEvent(nTagIndex)
	if self._nCurTagIndex > 0  then 
		self._pTagScrollView:getChildren()[self._nCurTagIndex]:loadTextureNormal("RankingListDialogRes/ggjm3.png",ccui.TextureResType.plistType)
	end
	self._nCurTagIndex = nTagIndex
	self._pTagScrollView:getChildren()[self._nCurTagIndex]:loadTextureNormal("RankingListDialogRes/ggjm4.png",ccui.TextureResType.plistType)	
	self:updateTitleText()
	-- 向服务器请求数据
	MessageGameInstance:QueryRankListReq21320(self._nCurTagIndex,0,50)
end

-- 更新排行榜显示内容的标题
function RankDialog:updateTitleText()
	for i,pTiteleText in ipairs(self._tTitleText) do
		pTiteleText:setString(self._tTitleString[self._nCurTagIndex][i])
	end
end

function RankDialog:updateRankInfo(tRankList)
	if self._pRankListController == nil then 
		self._pRankListController = require("ListController"):create(self,
			self._pRankScrollView,listLayoutType.LayoutType_vertiacl,610,140)
		self._pRankListController:setVertiaclDis(10)
		self._pRankListController:setHorizontalDis(2)
	end
	-- 获取集合的个数
	self._pRankListController._pNumOfCellDelegateFunc = function ()
		return #tRankList
	end
	self._pRankListController._pDataSourceDelegateFunc = function (delegate,controller,index)
		local cell = controller:dequeueReusableCell()
		if not cell then 
			cell = require("RankItemRender"):create()
			cell._nRankType = self._nCurTagIndex
			cell:setData(tRankList[index])
		else
			cell._nRankType = self._nCurTagIndex
			cell:setData(tRankList[index])
		end
		-- 设置索引
		return cell
	end

	self._pRankListController:setDataSource(tRankList)
end


-- 获取排行榜信息的网络回调
function RankDialog:handleQueryRankListResp21321(event)
	-- 更新我的排名
	local strSelfRank = event.selfRank == 0 and "未上榜" or event.selfRank
	self._pSelfRankText:setString(strSelfRank)
	self:updateRankInfo(event.list)
end

function RankDialog:initTouchEvent()
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
end

function RankDialog:onExitRankDialog()
	self:onExitDialog()
	-- 释放资源合图
	ResPlistManager:getInstance():removeSpriteFrames("RankingListPanel.plist")
	ResPlistManager:getInstance():removeSpriteFrames("ListPanel.plist")
	
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return RankDialog