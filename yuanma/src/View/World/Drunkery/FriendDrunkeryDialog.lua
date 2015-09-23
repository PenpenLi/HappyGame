--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendDrunkeryDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/06/29
-- descrip:   好友酒馆面板
--===================================================
local FriendDrunkeryDialog = class("FriendDrunkeryDialog",function() 
	return require("Dialog"):create()
end)

-- 构造函数
function FriendDrunkeryDialog:ctor()
    self._strName = "FriendDrunkeryDialog"
	-------------- ui -------------------
	-- 返回自家
	self._pBackHomeBtn = nil 
	-- 好友列表
	self._pFriendScrollView = nil 
	-- 一键喝光
	self._pAutoDrinkBtn = nil 
	-- 饮酒次数
	self._pRemainDrinkNumText = nil 
	-- 对白底图
	self._pDialogueBg = nil 
	-- 对白01,没有卖酒的时候提示
	self._pTips1Text = nil 
	-- 对白02,正在卖酒的时候提示
	self._pTips2Text = nil 
	-- 美人大图的图标
	self._pBeautyImgView = nil 
	-- 消耗货币的图标
	self._pFinancyIcon = nil 
	-- 玩家拥有该货币的数量
	self._pFinancyNumText = nil 
	-- 正在出售酒的icon
	self._pSellGoodsIcon = nil 
	-- 增加的经验
	self._pAddExpText = nil 
	-- 增加货币图标
	self._pAddCoinIcon = nil 
	-- 增加的货币
	self._pAddCoinText = nil 
	-- 喝个痛快按钮
	self._pDrinkBtn = nil 
	-- 出售酒tip 
	self._pBeerTipImg = nil 
	-- 喝酒所消耗的货币图标
	self._pDrinkConstFinanceIcon = nil 
	-- 喝酒所消耗的数量
	self._pDrinkConstFinanceText = nil 
	---------- data --------------------------
	-- 好友的列表
	self._tFriendList = {}	
	-- 是否发生位移
	self._isTouchMoved = false
	-- 剩余喝酒次数
	self._nRemainDrinkNum = 0
	-- selected renderIdx  
	self._nSelectedFriendIdx = 0
end

-- 创建函数FriendDrunkeryDialog
function FriendDrunkeryDialog:create(args)
    local dialog = FriendDrunkeryDialog.new()
	dialog:dispose(args)
	return dialog
end

-- 处理函数
function FriendDrunkeryDialog:dispose(args)
	-- 喝个痛快网络回调 kDrinkResp
	NetRespManager:getInstance():addEventListener(kNetCmd.kDrinkResp, handler(self,self.hadleMsgDrinkResp22111))
	-- 一键喝光网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kAllDrinkResp, handler(self,self.handleMsgAllDrinkResp22113))
	-- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("DrunkeryFriend.plist")
    -- 加载美人头像 
    ResPlistManager:getInstance():addSpriteFrames("BeautyListInfo.plist")
    -- 加载美人大图
    ResPlistManager:getInstance():addSpriteFrames("beauties_bg.plist")
    ResPlistManager:getInstance():addSpriteFrames("beauties_bg1.plist")
    ResPlistManager:getInstance():addSpriteFrames("FriendOne.plist")
    -- setdata
    self._nRemainDrinkNum = args.remainDrinkNum
    self._tFriendList = self:getFriendList(args.friends)
	-- 初始化界面相关
	self:initUI()
 
	-- 初始化触摸相关
	self:initTouches()

	------------------节点事件------------------------------------
	local function onNodeEvent(event)
        if event == "exit" then
			self:onExitFriendDurnkeryDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化UI控件
function FriendDrunkeryDialog:initUI()
	
	-- 处理按钮事件
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender:getName() == "backHome" then 
				DrunkeryCGMessage:openDrunkeryDialog22100()
				self:close()
			elseif sender:getName() == "drink" then
				if self._nRemainDrinkNum <= 0 then 
					NoticeManager:getInstance():showSystemMessage("劲酒虽好不要贪杯呦。")
					return 
				end
				if self._nSelectedFriendIdx <= 0 then 
					NoticeManager:getInstance():showSystemMessage("请先选择好友")
					return 
				end
				local pSelectedFriendInfo = self._tFriendList[self._nSelectedFriendIdx]
				if pSelectedFriendInfo.wineId <= 0 then 
					NoticeManager:getInstance():showSystemMessage("您的好友没有卖酒。")
					return
				end
				if pSelectedFriendInfo.drink then 
					NoticeManager:getInstance():showSystemMessage("该酒馆您已经来过了")
					return
				end
				DrunkeryCGMessage:drinkReq22110(pSelectedFriendInfo.roleId)
			elseif sender:getName() == "autoDrink" then 
				if self._nRemainDrinkNum <= 0 then 
					NoticeManager:getInstance():showSystemMessage("劲酒虽好不要贪杯呦。")
					return 
				end
				local friendIds = self:getCanDrinkFriendList()
				if #friendIds < 1 then 
					NoticeManager:getInstance():showSystemMessage("好友都被你喝光了")
					return 
				end
				DrunkeryCGMessage:autoDrinkReq22112(friendIds)
			end	
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end

	local params = require("DrunkeryFriendParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pBackHomeBtn = params._pGoFriendButton
	self._pBackHomeBtn:setName("backHome")
	self._pBackHomeBtn:addTouchEventListener(touchEvent)
	self._pFriendScrollView = params._pScrollView
	self._pAutoDrinkBtn = params._pOneButton
	self._pAutoDrinkBtn:setName("autoDrink")
	self._pAutoDrinkBtn:addTouchEventListener(touchEvent)
	self._pRemainDrinkNumText = params._pDrinkText02
	self._pTips1Text = params._pDialogueText01
	self._pTips2Text = params._pDialogueText02
	self._pBeautyImgView = params._pBeautyIcon
	self._pAddExpText = params._pBearBuy0102
	self._pAddCoinIcon = params._pBearBuy0201
	self._pAddCoinText = params._pBearBuy0202 
	self._pSellGoodsIcon = params._pBeerIcon
	self._pDrinkBtn = params._pBeerButton
	self._pDrinkBtn:setName("drink")
	self._pDrinkBtn:addTouchEventListener(touchEvent)
	self._pBeerTipImg = params._pBeerTipImg
	self._pFinancyNumText = params._pMoneyText
	self._pDrinkConstFinanceIcon = params._pBearBuyIcon
	self._pDrinkConstFinanceText = params._pBuyNum
    self._pDialogueBg = params._pDialogueBg
	self:disposeCSB()

	-- 上下移动
	local actionMoveBy = cc.MoveBy:create(1,cc.p(0,13))
    local actionMoveToBack = actionMoveBy:reverse()
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pDialogueBg:stopAllActions()
    self._pDialogueBg:runAction(cc.RepeatForever:create(seq1))

	-- 刷新界面数据
	self:updateUI()
end

-- 刷新界面数据
function FriendDrunkeryDialog:updateUI()
	-- 喝酒次数信息
	local strDrinkInfo = self._nRemainDrinkNum.."/".. TableConstants.DrinkLimit.Value
	self._pRemainDrinkNumText:setString(strDrinkInfo)
	-- 设置好友列表
	self:setFriendScrollViewDataSource()
	self:selectedChanged(1)
	-- 设置玩家的金币数量
	self:showFinanceInfo()
end

-- 设置好友列表
function FriendDrunkeryDialog:setFriendScrollViewDataSource()
	-- touchEvent
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.moved then
	       self._isTouchMoved = true
		elseif eventType == ccui.TouchEventType.ended then
		    if self._isTouchMoved == false then
				self:selectedChanged(sender:getTag() - 10000)
			end
			-- 注意移动产生的影响
            self._isTouchMoved = false
        elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	-- 清空数据				
	self._pFriendScrollView:removeAllChildren()
	local innerWidth = self._pFriendScrollView:getContentSize().width
	local renderHeight = 160
	local innerHeight = renderHeight * #self._tFriendList
	innerHeight = math.max(self._pFriendScrollView:getContentSize().height,innerHeight)
	self._pFriendScrollView:setInnerContainerSize(cc.size(innerWidth,innerHeight))
	for friend_idx,friend_value in ipairs(self._tFriendList) do
		local friendRender = require("FriendOneParams"):create()
		-- 设置好友的头像
		friendRender._pFriendIcon:loadTexture(kRoleIcons[friend_value.roleCareer],ccui.TextureResType.plistType)
		-- 设置好友的名字
		friendRender._pFriendName:setString(friend_value.roleName)
		-- 设置正在出售的酒品
		if friend_value.wineId > 0 then
            friendRender._pFriendBuy02:setString(TableWineshop[friend_value.wineId].Name)
		else
			friendRender._pFriendBuy02:setString("无")
			friendRender._pFriendBuy02:setColor(cRed)
		end
		-- 设置好友间的亲密度
		friendRender._pHeartText:setString(friend_value.friendship)
		friendRender._pDrinkOk:setVisible(friend_value.drink)
		-- 背景图添加点击事件
		friendRender._pFriendOneBg:addTouchEventListener(touchEvent)
        friendRender._pFriendOneBg:setTouchEnabled(true)
        friendRender._pFriendOneBg:setSwallowTouches(false)
		friendRender._pFriendOneBg:setTag(10000 + friend_idx)
		-- 设置
		friendRender._pCCS:setPosition(cc.p(innerWidth/2,innerHeight - renderHeight * (friend_idx - 1) - renderHeight/2))
		self._pFriendScrollView:addChild(friendRender._pCCS)
	end
end

-- friendRender selected changed event 
function FriendDrunkeryDialog:selectedChanged(senderIdx)
	if self._nSelectedFriendIdx == senderIdx then
		return 
	end
	-- 清除上次选项的选中状态
	local renders = self._pFriendScrollView:getChildren()
	if self._nSelectedFriendIdx > 0 then
		renders[self._nSelectedFriendIdx]:getChildByName("FriendOneBg"):loadTexture("FriendOneRes/jlxt6.png",ccui.TextureResType.plistType)
	end
	self._nSelectedFriendIdx = senderIdx
    renders[self._nSelectedFriendIdx]:getChildByName("FriendOneBg"):loadTexture("FriendOneRes/tytck2.png",ccui.TextureResType.plistType)
    self:initDrunkeryInfo(self._nSelectedFriendIdx)
end

-- 刷新好友酒馆信息
function FriendDrunkeryDialog:initDrunkeryInfo(nSelectedIdx)
	-- 当前选中的好友信息
	local pSelectedFriendInfo = self._tFriendList[nSelectedIdx]
	local isOnSell = pSelectedFriendInfo.wineId > 0 
	self._pTips1Text:setVisible(isOnSell == false)
	self._pTips2Text:setVisible(isOnSell)
	if isOnSell then
		local wineInfo = TableWineshop[pSelectedFriendInfo.wineId]
		local strBeautyPic = BeautyManager:getInstance()._tBeautyModelList[wineInfo.BeautiesID].templeteInfo.BeautyImage
		self._pBeautyImgView:loadTexture(strBeautyPic..".png",ccui.TextureResType.plistType)
		self._pBeerTipImg:setVisible(true)
		local tDrinkEarnings = self:getDrinkEarnings(wineInfo,pSelectedFriendInfo.friendship)
		self._pAddExpText:setString(tDrinkEarnings.exp)
		local financeImg = FinanceManager:getInstance():getIconByFinanceType(tDrinkEarnings.finance)
		self._pAddCoinIcon:loadTexture(financeImg.filename,financeImg.textureType)
		self._pAddCoinText:setString(tDrinkEarnings.amount)
		-- 喝酒所消耗的货币数量
		self._pDrinkConstFinanceIcon:setVisible(true)
		self._pDrinkConstFinanceText:setString("喝个痛快 \n  "..wineInfo.MoneyCost)
		if wineInfo.MoneyCost >  FinanceManager:getInstance()._tCurrency[kFinance.kCoin] then 
			self._pDrinkConstFinanceText:setColor(cRed)
		end
		self._pSellGoodsIcon:loadTexture(wineInfo.WineIcon..".png",ccui.TextureResType.plistType)
	else
		-- 设置出售酒的图标
		self._pSellGoodsIcon:loadTexture("DrunkeryFriendRes/BagItem.png",ccui.TextureResType.plistType)
		self._pBeerTipImg:setVisible(false)
		self._pDrinkConstFinanceText:setString("喝个痛快")
		local strBeautyPic = self:randomBeautyPic()
		self._pBeautyImgView:loadTexture(strBeautyPic..".png",ccui.TextureResType.plistType)
		self._pDrinkConstFinanceIcon:setVisible(false)
	end
end

function FriendDrunkeryDialog:getDrinkEarnings(wineInfo,friendship)
	local baseExpValue = wineInfo.ExpFriend
	local baseFinanceInfo = wineInfo.MoneyFriend
	local drinkEarnings = {}
	local function getValue(value)
		return math.ceil(value * (1 + TableConstants.FSBonusMax.Value * friendship / (friendship + TableConstants.FSBonusReduce.Value)))		
	end
	drinkEarnings.exp = getValue(baseExpValue)
	drinkEarnings.amount = getValue(baseFinanceInfo[2])
	drinkEarnings.finance = baseFinanceInfo[1] 
    return drinkEarnings
end

function FriendDrunkeryDialog:showFinanceInfo()
	self._pFinancyNumText:setString(FinanceManager:getInstance()._tCurrency[kFinance.kCoin])
end

-- 随机获得一张美人的大图
function FriendDrunkeryDialog:randomBeautyPic()
	local beautyList = BeautyManager:getInstance()._tBeautyModelList
	local beautyNum = #beautyList
	local randomNum = getRandomNumBetween(1,beautyNum)
	return beautyList[randomNum].templeteInfo.BeautyImage
end

-- 获得好友列表并按亲密度排序
function FriendDrunkeryDialog:getFriendList(tFriendWineryUnit)
	local friendList = shallowcopy(FriendManager:getInstance()._pFriendList)
	if tFriendWineryUnit ~= nil and #tFriendWineryUnit > 0 then
    	for friend_idx,friend_value in ipairs(friendList) do
    		for unit_key,unit_value in pairs(tFriendWineryUnit) do
    			if friend_value.roleId == unit_value.friendId then
    				friend_value.wineId = unit_value.wineId
    				friend_value.drink = unit_value.drink	
    				break
    			end
    		end
    	end
	end
	table.sort(friendList,function (a,b)
		return a.friendship > b.friendship
	end)
	return friendList
end

-- 获得可喝酒的好友列表
function FriendDrunkeryDialog:getCanDrinkFriendList()
	local friendIds = {}
	for i,friendInfo in ipairs(self._tFriendList) do
		if #friendIds > self._nRemainDrinkNum then
			break
		end
		if friendInfo.drink == false and friendInfo.wineId > 0 then
			table.insert(friendIds,friendInfo.roleId)	
		end
	end
	return friendIds
end

-- 喝个痛快网络回调
function FriendDrunkeryDialog:hadleMsgDrinkResp22111(event)
	local nFiendId = event.friendId
	for friends_idx,friendInfo in ipairs(self._tFriendList) do
		if friendInfo.roleId == nFiendId then
			friendInfo.drink = true
			break
		end
	end
	-- 刷新好友列表
	self:setFriendScrollViewDataSource()
	-- 更新剩余喝酒次数
	self._nRemainDrinkNum = self._nRemainDrinkNum - 1
	local strDrinkInfo = self._nRemainDrinkNum.."/".. TableConstants.DrinkLimit.Value
	self._pRemainDrinkNumText:setString(strDrinkInfo)
	self:showFinanceInfo()
	-- 弹出获得物品的框
	self:showGetItemBox({nFiendId})
end

-- 一键喝光的网络回调 
function FriendDrunkeryDialog:handleMsgAllDrinkResp22113(event)
	self._tFriendList = self:getFriendList(event.friendList)
	-- 被喝酒的好友id 集合
	local friendIds = event.drinkIds
	for friends_idx,friendInfo in ipairs(self._tFriendList) do
		for k,v in pairs(friendIds) do
			if friendInfo.roleId == v then
				friendInfo.drink = true
			end
		end		
	end
	-- 刷新好友列表
	self:setFriendScrollViewDataSource()
	-- 更新剩余喝酒次数
	self._nRemainDrinkNum = self._nRemainDrinkNum - #friendIds
	local strDrinkInfo = self._nRemainDrinkNum.."/".. TableConstants.DrinkLimit.Value
	self._pRemainDrinkNumText:setString(strDrinkInfo)
	self:showFinanceInfo()
	-- 弹出获得物品的框
	self:showGetItemBox(friendIds)
end

-- 根据friendIds 显示获得物品的弹框
function FriendDrunkeryDialog:showGetItemBox(friendIds)
	-- 奖励物品的结构
	local rewardItems =
		{
		 finances = {},
		 exp = 0,
		}
	for idx,friendId in ipairs(friendIds) do
		-- 当前选中的好友信息
		local pSelectedFriendInfo = nil 
		for friends_idx,friendInfo in ipairs(self._tFriendList) do
			if friendInfo.roleId == friendId then 
				pSelectedFriendInfo = friendInfo
				break
			end	
		end
		local wineInfo = TableWineshop[pSelectedFriendInfo.wineId]
        local drinkEarnings = self:getDrinkEarnings(wineInfo,pSelectedFriendInfo.friendship)
		-- 获得的经验直接相加
		rewardItems.exp = drinkEarnings.exp + rewardItems.exp
		-- 获得的货币根据类型相加
		local isExist = false
		for k,v in pairs(rewardItems.finances) do
			if v.finance == drinkEarnings.finance then 
				v.amount = v.amount + drinkEarnings.amount
				isExist = true
				break
			end
		end
		-- 表示这种货币不存在
		if isExist == false then 
			local financeUnit = {finance = drinkEarnings.finance,amount = drinkEarnings.amount}
			table.insert(rewardItems.finances,financeUnit)
		end
	end
	-- 领奖弹框
	DialogManager:getInstance():showDialog("GetItemsDialog",rewardItems) 
end

-- 初始化触摸相关
function FriendDrunkeryDialog:initTouches()
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

-- 退出函数
function FriendDrunkeryDialog:onExitFriendDurnkeryDialog()
	self:onExitDialog()
	-- 释放网络监听事件
	NetRespManager:getInstance():removeEventListenersByHost(self)
	-- 释放plist 合图
	ResPlistManager:getInstance():removeSpriteFrames("DrunkeryFriend.plist")
	ResPlistManager:getInstance():removeSpriteFrames("BeautyListInfo.plist")
    ResPlistManager:getInstance():removeSpriteFrames("beauties_bg.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FriendOne.plist")
end

return FriendDrunkeryDialog