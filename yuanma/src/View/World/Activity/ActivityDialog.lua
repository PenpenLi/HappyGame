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
	-----------【在线礼包】---------------
	-- 在线礼包节点
	self._pOnlineNode = nil 
	-- 在线礼包的滚动容器
	self._pOnLineListController = nil 
	self._pOnlineScrollView = nil  
	-----------【兑换码】-----------------
	-- 兑换码节点
	self._pExchangeCodeNode = nil 
	-- 兑换码的输入框
	self._pExchangeCodeText = nil 
	-- 领取兑换码
	self._pExchangeCodeBtn = nil 
	-----------【等级礼包】---------------
	self._pLevelGiftNode = nil 
	self._pLevelGiftListController = nil 
	self._pLevelGiftScrollView = nil 
	-----------【体力赠送】---------------
	self._pPhysicalGiftNode = nil 
	self._pPhysicalGiftPanel = nil 
	----------------------------------
    -------------【月签到】---------------
    self._pSignPanel = nil
    self._pSignInNode = nil
    ------------------------------------

    -------------【累计消费 lzx】---------------
    self._pCumulativeRechargePanel = nil
    ------------------------------------

	-- 活动的标签
	self._tActivityTagRenderList = {}
	-- 活动的节点容器
	self._tActivityNodeList = {}
	-- 当前显示的活动类型
	self._curKActType = 0
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
	ResPlistManager:getInstance():addSpriteFrames("ActivityLvUp.plist")
	ResPlistManager:getInstance():addSpriteFrames("CumulativeRechargeBg.plist")
	
	-- 体力赠送纹理
	ResPlistManager:getInstance():addSpriteFrames("PowerGift.plist")
	
	-- 获取在线礼包的回复
	NetRespManager:getInstance():addEventListener(kNetCmd.kGainOnlineAwardResp,handler(self,self.handleGainOnlineAwardResp22509))  
	-- 领取等级礼包的回复
	NetRespManager:getInstance():addEventListener(kNetCmd.kGainLevelGiftResp,handler(self,self.handlekGainLevelGiftResp22513)) 

	NetRespManager:getInstance():addEventListener(kNetCmd.kGainPowerResp,handler(self,self.handleMsgGainPowerResp22513))

	self:initUI()

	self:initTouchEvent()

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitActivityDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	
end

function ActivityDialog:initUI()
	local params = require("ActivityDialogeParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pActivityTagScrollView = params._pLeftScrollView
	self._pActivityTagItemRender = params._pActivityButton1
	self._pActivityTagItemRender:setVisible(false)
	-- 标签红点提示图标默认隐藏
	self._pActivityTagItemRender:getChildByName("TiShiPic"):setVisible(false)
	
	-- 在线礼包
	self._pOnlineNode = params._pOnLineNode
	self._pOnlineScrollView = params._pOlScrollView
	-- 兑换码
	self._pExchangeCodeNode = params._pCodeNode
	self._pExchangeCodeText = params._pCodeText
	self._pExchangeCodeBtn = params._pOkButton
	self._pExchangeCodeBtn:addTouchEventListener(function (sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			-- 领取兑换码请求
			if self._pExchangeCodeText:getString() == "" then 
				NoticeManager:getInstance():showSystemMessage("请先输入激活码！")
				return
			end
			local strExCode = self._pExchangeCodeText:getString()
			ActivityMessage:ExchangeCodeReq21318(strExCode)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
	end)
	-- 等级礼包
	self._pLevelGiftNode = params._pLvUpNode
	self._pLevelGiftScrollView = params._pLvUpView
	-- 体力赠送
	self._pPhysicalGiftNode = params._pPowerNode

	self:disposeCSB()
	-- 在线奖励的节点
	self._tActivityNodeList[kActivityType.kOnline] = self._pOnlineNode
	-- 兑换码节点
	self._tActivityNodeList[kActivityType.kGiftCodeCash] = self._pExchangeCodeNode
	-- 等级礼包节点
	self._tActivityNodeList[kActivityType.kLevelGift] = self._pLevelGiftNode
	-- 体力赠送的节点
	self._tActivityNodeList[kActivityType.kStrengthGive] = self._pPhysicalGiftNode
    -- 月签到
    self._pSignInNode = params._pSignInNode
    self._pSignPanel = require("SignInPanel"):create()
    self._pSignInNode:addChild(self._pSignPanel)
    self._pSignInNode:setVisible(false)
    self._tActivityNodeList[kActivityType.kMonthSign] = self._pSignInNode

    -- 累计充值显示节点
    self._pRechargeNode = params._pRechargeNode

    -- 初始化标签选项
    self:initTags()
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
	self:onExitDialog()
	-- 释放资源合图
	ResPlistManager:getInstance():removeSpriteFrames("ActivityDialoge.plist")
	ResPlistManager:getInstance():removeSpriteFrames("ActivityOnLine.plist")
	ResPlistManager:getInstance():removeSpriteFrames("ActivityLvUp.plist")
	ResPlistManager:getInstance():removeSpriteFrames("PowerGift.plist")	
	ResPlistManager:getInstance():removeSpriteFrames("CumulativeRechargeBg.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 初始化标签
function ActivityDialog:initTags()
	
	local function touchEvent (sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			self:tagChanageEvent(sender:getTag() - 10000)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
	end

	ActivityManager:getInstance():getTagListByPageIndex(1)
	local tTags = ActivityManager:getInstance()._tActivityTagList

	local nInnerHeight = self._pActivityTagScrollView:getContentSize().height
	local nInnerWidth = self._pActivityTagScrollView:getContentSize().width
	local nRenderHeight = 90
	nInnerHeight = math.max(nInnerHeight, #tTags * nRenderHeight)		
	self._pActivityTagScrollView:setInnerContainerSize(cc.size(nInnerWidth,nInnerHeight))
	
	for i,v in ipairs(tTags) do
		if i == 1 then 
			self._pActivityTagItemRender:setVisible(true)
			self._pActivityTagItemRender:setTitleText(v.Text)
			self._pActivityTagItemRender:setTag(10000 + v.ID)
			self._pActivityTagItemRender:addTouchEventListener(touchEvent)
			self._tActivityTagRenderList[v.ID] = self._pActivityTagItemRender
		else
			local pTagRender = self._pActivityTagItemRender:clone()
			pTagRender:setTag(10000 + v.ID)	
			pTagRender:setTitleText(v.Text)
			pTagRender:setPositionY(nInnerHeight - (i - 0.5) * nRenderHeight)
			self._pActivityTagScrollView:addChild(pTagRender)
			self._tActivityTagRenderList[v.ID] = pTagRender
		end		
	end	

	-- 默认选中第一个标签
	if tTags[1] ~= nil then 
		self:tagChanageEvent(tTags[1].ID)
	end

	-- 判断是否有在线礼包标签
	self:bShowOnlineTagWarn()
	-- 判断是否有等级礼包标签警告
	self:bShowLevelGiftTagWarn()
	-- 判断是否有体力礼包
	self:bShowPhysicGiftTagWarn()
end

-- 标签切换事件
function ActivityDialog:tagChanageEvent(kActType)
	if self._tActivityTagRenderList[self._curKActType] ~= nil then
	   self._tActivityTagRenderList[self._curKActType]:loadTextureNormal("ActivityDialogeRes/ggjm3.png",ccui.TextureResType.plistType)
	end
	if self._curKActType > 0 and self._tActivityNodeList[self._curKActType] ~= nil then 
		self._tActivityNodeList[self._curKActType]:setVisible(false)
	end
	self._curKActType = kActType
	if self._tActivityNodeList[self._curKActType] ~= nil then 		
		self._tActivityNodeList[self._curKActType]:setVisible(true)
	end
	if self._tActivityTagRenderList[self._curKActType] ~= nil then
	   self._tActivityTagRenderList[self._curKActType]:loadTextureNormal("ActivityDialogeRes/ggjm4.png",ccui.TextureResType.plistType)
	end
	
	if kActType == kActivityType.kOnline then 
        self:showOnlineActivity()
    elseif kActType == kActivityType.kLevelGift then 
    	self:showLevelGiftActivity()
	elseif kActType == kActivityType.kStrengthGive then 
		self:showPhysicalGiftActivity()
	elseif kActType == kActivityType.kAmassPay then 
		self:showCumulativeRechargePanel()
    end

end

function ActivityDialog:update(dt)
	-- 更新在线礼包
	self:updateOnlineGift(dt)

end

-- 更新在线礼包
function ActivityDialog:updateOnlineGift(dt)
	local nCurIndex = ActivityManager:getInstance()._nCurOnlineGiftIndex
	local nRoleOnlineTime = ActivityManager:getInstance()._nRoleOnlineTime
	local pOnlineGiftInfo = ActivityManager:getInstance()._tOnlineGiftLocalList[nCurIndex]
	if pOnlineGiftInfo == nil or not self._pOnLineListController then 
		-- 没有在线奖励
		return
	end
	local nRemainTime = pOnlineGiftInfo.totalTime - nRoleOnlineTime 
	if nRemainTime <= 0 then 
		-- 同步索引
		ActivityManager:getInstance():getCurOnlineGiftIndex()
		-- 重刷数据
		self._pOnLineListController:setDataSource(ActivityManager:getInstance()._tOnlineGiftLocalList)
		self:bShowOnlineTagWarn()
	else
		local cell = self._pOnLineListController:cellWithIndex(nCurIndex)
		cell:timeDown(nRemainTime)
	end 
end

-- 领取在线礼包回复
function ActivityDialog:handleGainOnlineAwardResp22509(event)
	local cell = self._pOnLineListController:cellWithIndex(event.index)
	cell:setOnlineGiftState()
	-- 判断是否有在线礼包标签
	self:bShowOnlineTagWarn()
end

-- 领取等级礼包的回复
function ActivityDialog:handlekGainLevelGiftResp22513(event)
	local cell = self._pLevelGiftListController:cellWithIndex(event.index)
	cell:setGiftState()
	self:bShowLevelGiftTagWarn()
end

-- 显示在线礼包
function ActivityDialog:showOnlineActivity()
	if self._pOnLineListController == nil then 
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
				cell._nIndex = index
				cell:setData(ActivityManager:getInstance()._tOnlineGiftLocalList[index])
			else
				cell._nIndex = index
				cell:setData(ActivityManager:getInstance()._tOnlineGiftLocalList[index])
			end
			-- 设置索引
			return cell
		end
	end
	self._pOnLineListController:setDataSource(ActivityManager:getInstance()._tOnlineGiftLocalList)
end

-- 显示等级礼包
function ActivityDialog:showLevelGiftActivity()
	if self._pLevelGiftListController == nil then 
		self._pLevelGiftListController = require("ListController"):create(self,
			self._pLevelGiftScrollView,listLayoutType.LayoutType_vertiacl,610,160)
		self._pLevelGiftListController:setVertiaclDis(10)
		self._pLevelGiftListController:setHorizontalDis(2)
		self._pLevelGiftListController._pNumOfCellDelegateFunc = function ()
			return #TableLevelGift
		end
		self._pLevelGiftListController._pDataSourceDelegateFunc = function (delegate,controller,index)
			local cell = controller:dequeueReusableCell()
			if not cell then 
				cell = require("LevelGiftItemRender"):create()
				cell._nIndex = index
				cell:setData(TableLevelGift[index])
			else
				cell._nIndex = index
				cell:setData(TableLevelGift[index])
			end
			return cell
		end
	end
	self._pLevelGiftListController:setDataSource(TableLevelGift)
end

-- 显示累计奖励 lzx
function ActivityDialog:showCumulativeRechargePanel()
	if self._pCumulativeRechargePanel == nil then
		local panel = require("CumulativeRechargePanel"):create()
		self._pRechargeNode:addChild(panel)
		self._tActivityNodeList[kActivityType.kAmassPay] = panel
		self._pCumulativeRechargePanel = panel
		panel.father = self
	end
	self._pCumulativeRechargePanel:setVisible(true)
end

-- 显示体力赠送
function ActivityDialog:showPhysicalGiftActivity()
	if not self._pPhysicalGiftPanel then 
		self._pPhysicalGiftPanel = require("PhysicalGiftPanel"):create()
		self._tActivityNodeList[self._curKActType]:addChild(self._pPhysicalGiftPanel)
	end
	self._pPhysicalGiftPanel:setData(ActivityManager:getInstance()._tPhysicalGiftState)
end

-- 判断是否有在线礼包标签警告
function ActivityDialog:bShowOnlineTagWarn()
	if self._tActivityTagRenderList[kActivityType.kOnline] ~= nil then 
		local bShow = ActivityManager:getInstance():isShowOnlineWarn()
		self._tActivityTagRenderList[kActivityType.kOnline]:getChildByName("TiShiPic"):setVisible(bShow)
	end
end

-- 判断是否有等级礼包标签警告
function ActivityDialog:bShowLevelGiftTagWarn()
	if self._tActivityTagRenderList[kActivityType.kLevelGift] ~= nil then 
		local bShow = ActivityManager:getInstance():isShowLevelGiftWarn()
		self._tActivityTagRenderList[kActivityType.kLevelGift]:getChildByName("TiShiPic"):setVisible(bShow)
	end
end

-- 判断是否显示体力礼包
function ActivityDialog:bShowPhysicGiftTagWarn()
	if self._tActivityTagRenderList[kActivityType.kStrengthGive] ~= nil then 
		local bShow = ActivityManager:getInstance():isShowPhysicalGiftWarn()
		self._tActivityTagRenderList[kActivityType.kStrengthGive]:getChildByName("TiShiPic"):setVisible(bShow)
	end
end

function ActivityDialog:handleMsgGainPowerResp22513(event)
	-- 更新体力礼包的领取状态
	self:bShowPhysicGiftTagWarn()
end

return ActivityDialog
