--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DrunkeryDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/06/24
-- descrip:   酒馆面板
--===================================================
local DrunkeryDialog = class("DrunkeryDialog",function()
	return require("Dialog"):create()
end)

-- 构造函数
function DrunkeryDialog:ctor()
	-- 名字
	self._strName = "DrunkeryDialog"
	-- ui --
	-- 来访好友列表滚动容器
	self._pVisitedFriendScrollView = nil 
	-- 来访好友名字
	self._pFriendNameText = nil 
	-- 营业额节点
	self._pTurnoverNode = nil  
	-- 增加经验
	self._pTurnoverExpText = nil
	-- 增加货币的集合
	self._tTurnoverCoin = {}
	-- 额外奖励的物品
	self._tExtraRewardItem = {}
	-- 全部领奖按钮
	self._pGetAllRewardBtn = nil 
	-- 立刻完成按钮
	self._pSpeedUpBtn = nil 
	-- 没有卖酒时显示的tips
	self._pTips1Text = nil
	-- 正在卖酒时显示的tips
	self._pTips2Text = nil 
	-- 正在出售酒的icon 
	self._pSellGoodsIcon = nil 
	-- 开始出售按钮
	self._pSellBtn = nil  
	-- 玩家钻石数量
	self._pDiamondText = nil 
	-- 光顾好友按钮
	self._pVisiteFriendBtn = nil
	-- 美人大图的图标
	self._pBeautyImgView = nil
	-- 消耗货币的图标
	self._pFinancyIcon = nil 
	-- 玩家拥有该货币的数量
	self._pFinancyNumText = nil 
	-- 酒品列表的选择界面
	self._pWineListLayer = nil 
	-- 对白底图
	self._pDialogueBg = nil 
	-- data -- 
	-- 来访好友列表
	self._tVistedFriend = {}
	-- 营业额信息
	self._tTurnoverInfo = {}
	-- 来访者数量
	self._nVistedNum = 0
	-- 正在出售的酒品ID
	self._nCurSellWineId = 0
	-- 酿酒的剩余时间
	self._nRemainSecond = 0
	-- 剩余喝酒的次数
	self._nRemainDrinkNum = 0
end

-- 创建函数
function DrunkeryDialog:create(args)
	local dialog = DrunkeryDialog.new()
	dialog:dispose(args)
	return dialog
end

-- 处理函数 
function DrunkeryDialog:dispose(args)
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "酒坊按钮" , value = false})

	-- 领取奖励的网络回调 
	NetRespManager:getInstance():addEventListener(kNetCmd.kGetWineryRewardResp,handler(self,self.handleMsgGetRewardResp22103))
	-- 立即完成的网络回调 kWineryOnceCompleteResp
	NetRespManager:getInstance():addEventListener(kNetCmd.kWineryOnceCompleteResp,handler(self,self.handleMsgOnceCompleteResp22105))
	-- 卖酒成功网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kSellWineResp,handler(self,self.handleMsgSellWineResp22107))
	-- 请求好友酒坊网络回调 
	NetRespManager:getInstance():addEventListener(kNetCmd.kGetFriendWineryInfoResp,handler(self,self.handleMsgGetFriendWineryResp22109))

	-- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("DrunkeryBg.plist")
    -- 加载美人头像 
    ResPlistManager:getInstance():addSpriteFrames("BeautyListInfo.plist")
    -- 加载美人大图
    ResPlistManager:getInstance():addSpriteFrames("beauties_bg.plist")
    ResPlistManager:getInstance():addSpriteFrames("beauties_bg1.plist")
	-------  set data
	self._tVistedFriend = args.visitors
	self._nVistedNum = args.visitorCount
	self._nRemainDrinkNum = args.remainDrinkNum
	self._nRemainSecond = args.remainSec
	self._nCurSellWineId = args.wineId
	-- 初始化界面相关
	self:initUI()
 
	-- 初始化触摸相关
	self:initTouches()

	------------------节点事件------------------------------------
	local function onNodeEvent(event)
        if event == "exit" then
			self:onExitDrunkeryDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化UI 控件
function DrunkeryDialog:initUI()
	-- 加载组件
	local params = require("DrunkeryBgParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pVisiteFriendBtn = params._pGoFriendButton
	self._pBeautyImgView = params._pBeautyIcon
	self._pSellGoodsIcon = params._pBeerIcon
	self._pSellBtn = params._pBeerButton
	self._pVisitedFriendScrollView = params._pScrollView
	self._pFriendNameText = params._pFriendName
    self._pTurnoverNode = params._pNode000
	self._pTurnoverExpText = params._pExpText
	-- 营业产生的货币收入
	self._tTurnoverCoin[1] = {icon = params._pMoney01, pText = params._pMoneyText01}
	self._tTurnoverCoin[2] = {icon = params._pMoney02, pText = params._pMoneyText02}
	self._pGetAllRewardBtn = params._pOkButton01
	self._pSpeedUpBtn = params._pOkButton02
	self._tExtraRewardItem = 
	{
		params._pItemIcon01,
		params._pItemIcon02,
		params._pItemIcon03,
	}

	self._pFinancyIcon = params._pFinancyIcon
	self._pFinancyNumText = params._pFinancyText
	self._pDialogueBg = params._pDialogueBg
	self._pTips1Text = params._pDialogueText01
	-- 默认不显示
	self._pTips2Text = params._pDialogueText02
	self._pTips2Text:setVisible(false)

	self:disposeCSB()

	-- 上下移动
	local actionMoveBy = cc.MoveBy:create(1,cc.p(0,13))
    local actionMoveToBack = actionMoveBy:reverse()
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pDialogueBg:stopAllActions()
    self._pDialogueBg:runAction(cc.RepeatForever:create(seq1))

	-- 按钮注册点击事件
	self:initBtnEvent()
	self:updateUI()
end

-- 刷新界面数据
function DrunkeryDialog:updateUI()
	-- 显示玩家的钻石信息
	self:showDiamondInfo()
	-- 设置来访者列表
	self:setVisitedFriendDataSource()
	local isOnSell = self._nCurSellWineId > 0
	self._pTips1Text:setVisible(isOnSell == false)
	self._pTips2Text:setVisible(isOnSell) 
	local wineInfo = TableWineshop[self._nCurSellWineId]	
	if isOnSell then 
		self._pVisitedFriendScrollView:setVisible(true)
		self._pTurnoverNode:setVisible(true)
		-- 设置出售酒的图标
		self._pSellGoodsIcon:loadTexture(wineInfo.WineIcon..".png",ccui.TextureResType.plistType)
		-- 当前营业额的信息
		self:getTurnoverInfo(self._nCurSellWineId)
		-- 设置奖励物品
		self._tTurnoverInfo.items = {}
		-- 设置美人大图
		local strBeautyPic = BeautyManager:getInstance()._tBeautyModelList[wineInfo.BeautiesID].templeteInfo.BeautyImage
		self._pBeautyImgView:loadTexture(strBeautyPic..".png",ccui.TextureResType.plistType)
		-- 设置额外奖励物品
		for i,v in ipairs(wineInfo.ItemReward) do
			-- 表示奖励的是物品
			local pItemInfo = {id = v[1],value = v[2],baseType = v[3]}
			self._tTurnoverInfo.items[i] = pItemInfo
			pItemInfo = GetCompleteItemInfo(pItemInfo)
			self._tExtraRewardItem[i]:getChildByName("ItemIcon"):loadTexture(pItemInfo.templeteInfo.Icon..".png",ccui.TextureResType.plistType)
			self._tExtraRewardItem[i]:getChildByName("ItemText"):setString(pItemInfo.value)
			-- 奖励物品的品质框
			if pItemInfo.dataInfo.Quality ~= nil and pItemInfo.dataInfo.Quality ~= 0 then 
				local quality = pItemInfo.dataInfo.Quality
				self._tExtraRewardItem[i]:loadTexture("ccsComRes/qual_" ..quality.."_normal.png",ccui.TextureResType.plistType)
			end
		end
		for i,v in ipairs(self._tExtraRewardItem) do
			v:setVisible(i <= #wineInfo.ItemReward)
		end
	else 
		-- 设置出售酒的图标
		self._pSellGoodsIcon:loadTexture("DrunkeryBgRes/BagItem.png",ccui.TextureResType.plistType)
		-- 访问列表不显示
		self._pVisitedFriendScrollView:setVisible(false)
		-- 营业额信息不显示
		self._pTurnoverNode:setVisible(false)
		local strBeautyPic = self:randomBeautyPic()
		self._pBeautyImgView:loadTexture(strBeautyPic..".png",ccui.TextureResType.plistType)
	end
end

-- 设置当前的营业额信息
function DrunkeryDialog:setTurnoverInfo()
	-- 设置奖励经验
	self._pTurnoverExpText:setString(self._tTurnoverInfo.exp)
	-- 设置奖励货币
	for finances_idx,financeUnit in ipairs(self._tTurnoverInfo.finances) do
		local financeImg = FinanceManager:getInstance():getIconByFinanceType(financeUnit.finance)
        self._tTurnoverCoin[finances_idx].icon:loadTexture(financeImg.filename,financeImg.textureType)
        self._tTurnoverCoin[finances_idx].pText:setString(financeUnit.amount)
	end
	-- 奖励货币的数量
	local nRewardCoinNum = #self._tTurnoverInfo.finances
	for i = nRewardCoinNum + 1,2 do
		self._tTurnoverCoin[i].icon:setVisible(false)
		self._tTurnoverCoin[i].pText:setVisible(false)
	end
end

-- 获得营业额的属性值
function DrunkeryDialog:getTurnoverInfo(wineId)
	local wineInfo = TableWineshop[wineId]	
    local customerNum = self._nVistedNum > wineInfo.CustomerLimi and wineInfo.CustomerLimi or self._nVistedNum
	-- 经验为固定值+固定值*访客人数，
	self._tTurnoverInfo.exp = wineInfo.ExpReward[1] + wineInfo.ExpReward[2] * customerNum 
	-- 重置奖励的货币
	self._tTurnoverInfo.finances = {}
	-- 货币为固定值*访客人数。
	for MoneyReward_idx,moneyReward in ipairs(wineInfo.MoneyReward) do
		local financeUnit = {}
		financeUnit.finance = moneyReward[1]  
		financeUnit.amount = moneyReward[2] + moneyReward[3] * customerNum
		self._tTurnoverInfo.finances[MoneyReward_idx] = financeUnit
	end
	self:setTurnoverInfo()
end

-- 注册各个按钮的点击事件
function DrunkeryDialog:initBtnEvent()
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender:getName() == "sellNow" then
				if self._nCurSellWineId > 0 then 
					local strMsg = self._nRemainSecond > 0 and "正在卖酒。" or "请先领取奖品。"
					NoticeManager:getInstance():showSystemMessage(strMsg)
					return
				end	
				self:showWineListLayer()
			elseif sender:getName() == "visitFriend" then
				if #FriendManager:getInstance()._pFriendList < 1 then 
					local tMsg = "您现在没有任何好友，现在要去添加好友吗？"
	                showConfirmDialog(tMsg,function () 
						DialogManager:showDialog("FriendsDialog",{})
						self:close()
					end)
				else
					-- 请求好友的酒坊信息
					DrunkeryCGMessage:getFriendWineryReq22108()	
				end
			elseif sender:getName() == "speedUp" then
				if self._nRemainSecond < 0 or self._nCurSellWineId <= 0 then 
					return
				end
				local constNum = self:getConstDiamondByTime(self._nRemainSecond)
				local tMsg = {
					              {type = 2,title = "确定花费"},
                                  {type = 2,title = constNum,
                                    fontColor = constNum > FinanceManager:getInstance()._tCurrency[kFinance.kDiamond] 
                                    and cRed or cWhite},
                                  {type = 2,title = "个"..FinanceManager:getFinanceTitleByType(kFinance.kDiamond).. "立即完成?"}
						}
                showConfirmDialog(tMsg,function () 
					if FinanceManager:getInstance()._tCurrency[kFinance.kDiamond] >= constNum then
						 DrunkeryCGMessage:OnceCompleteReq22104()
					else
						local strMsg = string.format("%s不足",FinanceManager:getInstance():getFinanceTitleByType(kFinance.kDiamond))
						showSystemMessage(strMsg)
					end
				end)
			elseif sender:getName() == "getAll" then 
				if self._nCurSellWineId > 0 then 
					if self._nRemainSecond > 0 then
						NoticeManager:getInstance():showSystemMessage("酒正在出售中，请稍后。")
						return
					else
						DrunkeryCGMessage:getRewardReq22102()
					end
				else
					NoticeManager:getInstance():showSystemMessage("请先卖酒")
					return
				end		

				
				
			end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pGetAllRewardBtn:setName("getAll")
	self._pSpeedUpBtn:setName("speedUp")
	self._pSellBtn:setName("sellNow")
	self._pVisiteFriendBtn:setName("visitFriend")
	self._pGetAllRewardBtn:addTouchEventListener(touchEvent)
	self._pSpeedUpBtn:addTouchEventListener(touchEvent)
	self._pSellBtn:addTouchEventListener(touchEvent)
	self._pVisiteFriendBtn:addTouchEventListener(touchEvent)
end

-- 显示酒品列表的面板
function DrunkeryDialog:showWineListLayer()
	if not self._pWineListLayer then 
		self._pWineListLayer = require("WineListLayer"):create()
		self:addChild(self._pWineListLayer)
	else
		self._pWineListLayer:setVisible(true)
	end
end

-- 初始化触摸相关
function DrunkeryDialog:initTouches()
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

-- 随机获得一张美人的大图
function DrunkeryDialog:randomBeautyPic()
	local beautyList = BeautyManager:getInstance()._tBeautyModelList
	local beautyNum = #beautyList
	local randomNum = getRandomNumBetween(1,beautyNum)
	return beautyList[randomNum].templeteInfo.BeautyImage
end

-- 设置来访顾客的列表
function DrunkeryDialog:setVisitedFriendDataSource()
	local innerWidth = self._pVisitedFriendScrollView:getContentSize().width
	local innerHeight = self._pVisitedFriendScrollView:getContentSize().height
	local strNames = "" 
	for i,v in ipairs(self._tVistedFriend) do
		strNames = strNames .. v .."\n"
	end
	self._pFriendNameText:setString(strNames)
	if innerHeight >= self._pFriendNameText:getContentSize().height then
		self._pVisitedFriendScrollView:setTouchEnabled(false)
		self._pVisitedFriendScrollView:setBounceEnabled(false)
	else
		innerHeight = self._pFriendNameText:getContentSize().height
		self._pVisitedFriendScrollView:setInnerContainerSize(cc.size(innerWidth,innerHeight))
		self._pVisitedFriendScrollView:setTouchEnabled(true)
		self._pVisitedFriendScrollView:setBounceEnabled(true)
	end
	self._pFriendNameText:setPosition(cc.p(0,innerHeight - 10))
end

-- 显示玩家的钻石信息
function DrunkeryDialog:showDiamondInfo()
	self._pFinancyNumText:setString(FinanceManager:getInstance()._tCurrency[kFinance.kDiamond])
end

--通过时间来获取加速需要的钻石数
function DrunkeryDialog:getConstDiamondByTime(nSecond)
    if nSecond == 0 then
		return 0
	end
    return math.ceil(TableConstants.WineshopFast1.Value * nSecond ^ TableConstants.WineshopFast2.Value)
end

-- 领取奖励的网络回调
function DrunkeryDialog:handleMsgGetRewardResp22103(event)
	self._nVistedNum = event.visitorCount
	self:getTurnoverInfo(self._nCurSellWineId)
	-- 领奖弹框
	DialogManager:getInstance():showDialog("GetItemsDialog",self._tTurnoverInfo)  
	-- 重置正在出售酒的id
	self._nCurSellWineId = 0
	self._nRemainSecond = 0
	self:updateUI()
end

-- 立即完成的网络回调
function DrunkeryDialog:handleMsgOnceCompleteResp22105(event)
	
	self:getTurnoverInfo(self._nCurSellWineId)
	-- 领奖弹框
	DialogManager:getInstance():showDialog("GetItemsDialog",self._tTurnoverInfo)  
	-- 重置正在出售酒的id
	self._nCurSellWineId = 0
	self._nRemainSecond = 0
    self._nVistedNum = event.visitorCount
	self:updateUI()
end

-- 卖酒成功的网络回调
function DrunkeryDialog:handleMsgSellWineResp22107(event)
	-- 正在出售的酒
	self._nCurSellWineId = event.wineId
	self._nRemainSecond = TableWineshop[self._nCurSellWineId].ConsumeTime
	-- 更新界面数据
	self:updateUI()
end

-- 请求好友酒坊信息网络回调
function DrunkeryDialog:handleMsgGetFriendWineryResp22109(event)                           
	self:close()
end

-- 定时器（循环更新）
function DrunkeryDialog:update(dt)
	self:updateSellWineTime(dt)
end

-- 更新售酒的倒计时
function DrunkeryDialog:updateSellWineTime(dt)
	if self._nRemainSecond < -1 then 
		return 
	end
	if self._nRemainSecond > 0 then 
		local format = gTimeToStr(self._nRemainSecond)
		-- 控件显示时间
        self._pGetAllRewardBtn:getChildByName("Text"):setString("全部领取\n"..format)
        self._pSellBtn:setTitleText(format)
        local nNeedDiamondNum = self:getConstDiamondByTime(self._nRemainSecond)
        self._pSpeedUpBtn:getChildByName("Text"):setString("立刻完成\n      "..nNeedDiamondNum)
        if nNeedDiamondNum > FinanceManager:getInstance()._tCurrency[kFinance.kDiamond] then 
        	self._pSpeedUpBtn:getChildByName("Text"):setColor(cRed)
        end
        self._pSpeedUpBtn:getChildByName("OKIcon"):setVisible(true)
		self._nRemainSecond = self._nRemainSecond - dt
	else
		self._pSpeedUpBtn:getChildByName("Text"):setString("立刻完成")
		self._pSpeedUpBtn:getChildByName("OKIcon"):setVisible(false)
		self._pGetAllRewardBtn:getChildByName("Text"):setString("全部领取")
        self._pSellBtn:setTitleText("售卖酒品")
	end
end

-- 退出函数
function DrunkeryDialog:onExitDrunkeryDialog()
	self:onExitDialog()
	-- 释放网络监听事件
	NetRespManager:getInstance():removeEventListenersByHost(self)
	-- 释放plist 合图
	ResPlistManager:getInstance():removeSpriteFrames("DrunkeryBg.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BeautyListInfo.plist")
    ResPlistManager:getInstance():removeSpriteFrames("beauties_bg.plist")
end

return DrunkeryDialog