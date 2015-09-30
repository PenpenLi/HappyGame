--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ActivityDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/12
-- descrip:   活动面板
--===================================================
local ActivityDialog = class("ActivityDialog",function ()
	return require("Dialog"):create()
end)

function ActivityDialog:ctor()
	self._strName = "ActivityDialog"
    self._pCCS = nil
	self._pCloseButton = nil 
	self._pBg = nil 
	-- 活动标签的容器
	self._pActivityTagListController = nil 
	self._pActivityTagScrollView = nil 
	self._pActivityTagItemRender = nil
	-- 在线礼包节点
	self._pOnlineNode = nil 
	-- 在线礼包的滚动容器
	self._pOnLineListController = nil 
	self._pOnlineScrollView = nil  
	----------------------------------
	-- 活动的标签
	self._tActivityTagList = {}
	-- 活动的节点容器
	self._tActivityNodeList = {}
end

function ActivityDialog:create()
	local dialog = ActivityDialog.new()
	dialog:dispose()
	return dialog
end

function ActivityDialog:dispose()
	-- 加载必需的资源合图
	ResPlistManager:getInstance():addSpriteFrames("ActivityDialoge.plist")
	ResPlistManager:getInstance():addSpriteFrames("ActivityOnLine.plist")
	-- 查询在线礼包的回复
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryOnlineAwardResp,handler(self,self.handleQueryOnlineAwardResp22507))  
	-- 获取在线礼包的回复
	NetRespManager:getInstance():addEventListener(kNetCmd.kGainOnlineAwardResp,handler(self,self.handleGainOnlineAwardResp22509))  
	self:initUI()

	self:initTouchEvent()

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitActivityDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	-- 默认显示在线奖励的礼包信息
	ActivityMessage:QueryOnlineAwardReq22506()
end

function ActivityDialog:initUI()
	local params = require("ActivityDialogeParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pActivityTagScrollView = params._pLeftScrollView
	self._pActivityTagItemRender = params._pActivityButton1

	local function touchEvent (sender,eventType)
		if eventType == ccui.TouchEventType.ended then
        	ActivityMessage:QueryOnlineAwardReq22506()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
	end

	self._pActivityTagItemRender:addTouchEventListener(touchEvent)
	-- 在线礼包
	self._pOnlineNode = params._pOnLineNode
	self._pOnlineScrollView = params._pOlScrollView

	self:disposeCSB()
	-- 在线奖励的节点
	--self._tActivityNodeList[kActivityType.kOnline] = self._pOnlineNode
	-- 默认显示在线时间活动
	ActivityMessage:QueryOnlineAwardReq22506()
end

function ActivityDialog:initTouchEvent()
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

function ActivityDialog:onExitActivityDialog()
	-- 释放资源合图
	ResPlistManager:getInstance():removeSpriteFrames("ActivityDialoge.plist")
	ResPlistManager:getInstance():removeSpriteFrames("ActivityOnLine.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 标签切换事件
function ActivityDialog:tagChanageEvent()

end

-- 查询在线礼包回复 
function ActivityDialog:handleQueryOnlineAwardResp22507(event)
	self:showOnlineActivity()
end

-- 查询领奖回复
function ActivityDialog:handleGainOnlineAwardResp22509(event)

end

-- 显示在线礼包
function ActivityDialog:showOnlineActivity()
	self._pOnlineNode:setVisible(true)
	self._pOnLineListController = require("ListController"):create(self,
		self._pOnlineScrollView,listLayoutType.LayoutType_vertiacl,610,140)
	self._pOnLineListController:setVertiaclDis(10)
	self._pOnLineListController:setHorizontalDis(2)
	-- 获取集合的个数
	self._pOnLineListController._pNumOfCellDelegateFunc = function ()
		return #ActivityManager:getInstance()._tOnlineGiftLocalList
	end
	self._pOnLineListController._pDataSourceDelegateFunc = function (delegate,controller,index)
		local cell = controller:dequeueReusableCell()
		if not cell then 
			cell = require("OnlineItemRender"):create()
			cell:setData(ActivityManager:getInstance()._tOnlineGiftLocalList[index])
		else
			cell:setData(ActivityManager:getInstance()._tOnlineGiftLocalList[index])
		end
		return cell
	end
	self._pOnLineListController:setDataSource(ActivityManager:getInstance()._tOnlineGiftLocalList)
end

return ActivityDialog
