--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ShopDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/01/23
-- descrip:   商城层
--===================================================
local ShopDialog = class("ShopDialog",function()
	return require("Dialog"):create()
end)

-- 构造函数
function ShopDialog:ctor()
	-- 层名字
	self._strName = "ShopDialog" 
	-- 商城的类型（改变货币的消耗类型）
	self._kShopType = 0   
	--  标签的数据
	self._tTagDataSource = {} 
	-- 商品的列表   
	self._tDataSource = {}
	-- 当前选中标签的tag
	self._nSelecteTag = 0
	-- 触摸监听器
	self._pTouchListener = nil 
	--  商城相关的PCCS
	self._pCCS = nil  
	-- 商城背景
	self._pBg = nil
	-- 关闭按钮
	self._pCloseButton = nil           
	-- 标签的集合
	self._tTags = {}
	-- 标签的模板
	self._pTagBtn = nil 
	-- 物品的滚动列表 
	self._pGoodsScrollView = nil 
	-- 物品的模板
	self._pGoodsItemCell = nil 
	-- 货币的图标
	self._pCoinIcon = nil 
	-- 货币的数量
	self._pCoinNumText = nil 
	-- 充值按钮
	self._pChargeBtn = nil 
	--  标签节点
	self._pTagNode = nil

	-- 标签的纹理集合
    self._tTagTextures = {
    	{normal = "ShopUIRes/scjm10.png",pressed = "ShopUIRes/scjm11.png"},
    	{normal = "ShopUIRes/scjm12.png",pressed = "ShopUIRes/scjm13.png"},
    	{normal = "ShopUIRes/scjm14.png",pressed = "ShopUIRes/scjm15.png"},
    	{normal = "ShopUIRes/scjm16.png",pressed = "ShopUIRes/scjm17.png"},
    	{normal = "ShopUIRes/scjm18.png",pressed = "ShopUIRes/scjm19.png"},
    	{normal = "ShopUIRes/scjm20.png",pressed = "ShopUIRes/scjm21.png"},
    }		

    kQualityFontColor4b = {
		cc.c4b(255,255,255,255),
		cc.c4b(59,255,59,255),
		cc.c4b(48,159,253,255),
		cc.c4b(144,66,251,255),
		cc.c4b(255,198,0,255),
	}
    -- 消耗货币的类型
    self._kFinaneType = 0
end

-- 创建函数
function ShopDialog:create(args)
	local layer = ShopDialog.new()
	layer:dispose(args)
	return layer
end

-- 处理函数
function ShopDialog:dispose(args)
    -- 商店类型
    self._kShopType = args[1]
    if args[2] then 
    	self._nSelecteTag = args[2]
    end
	-- 注册打开商城的网络事件kQueryShopInfo
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryShopInfo, handler(self,self.handleMsgQueryShopInfo20501))
   	-- 注册切换商城标签网络事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryShopInfoByTag, handler(self,self.handleMsgQueryShopInfoByTag20503))
    -- 注册购买商品的回调函数kBuyGoods
	NetRespManager:getInstance():addEventListener(kNetCmd.kBuyGoods, handler(self,self.handleMsgBuyGoods20505))
	-- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("ShopUI.plist")
    ResPlistManager:getInstance():addSpriteFrames("ShopOne.plist")
	-- 初始化界面相关
	self:initUI()
    
	-- 初始化触摸相关
	self:initTouches()

	------------------节点事件------------------------------------
	local function onNodeEvent(event)
        if event == "exit" then
			self:onExitShopDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function ShopDialog:initUI()
	-- 加载组件
	local params = require("ShopParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pbackground
	self._pCloseButton = params._pbuttonclose
	self._pTagNode = params._pNodebutton
	self._pTagBtn = params._pbutton01
	self._pTagBtn:setVisible(false)
    self._pGoodsScrollView = params._pscrollview01
	self._pCoinIcon = params._pcurrencyicon
	self._pCoinNumText = params._pmoney
	self._pChargeBtn = params._pbuttonrecharge
	self._pChargeBtn:setZoomScale(nButtonZoomScale)
	self._pChargeBtn:setPressedActionEnabled(true)

	local function touchEvent(sender,eventType) 
		if eventType == ccui.TouchEventType.ended then 
			ShopSystemCGMessage:queryChargeListReq20506()
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pChargeBtn:setVisible(false)
	self._pChargeBtn:addTouchEventListener(touchEvent)
	
	self:disposeCSB()
end

-- 更新界面 
function ShopDialog:updateUI()
	--  显示玩家的图标信息
	self:showCoinsInfo()
	-- 初始化商店的标签
	-- 第一个标签的坐标
	local tagX,tagY = self._pTagBtn:getPosition()
	-- 第一个标签宽度（向左偏移3个像素）
	local tagWidth = self._pTagBtn:getContentSize().width - 3
	if type(self._tTags) == "table" then
		-- 标签的点击事件
		local function tagClickEvent(sender,eventType)
			if eventType == ccui.TouchEventType.ended then
				if self._nSelecteTag == sender:getTag() then 
					return
				end
				self._nSelecteTag = sender:getTag()
				--  更新标签显示 
				self:tagSelecteChanged(sender:getTag())
				-- 向服务器发送切换商品标签的消息
				ShopSystemCGMessage:QueryShopInfoByTagReq20502(self._kShopType,self._nSelecteTag - 10000)
			elseif eventType == ccui.TouchEventType.began then
 				AudioManager:getInstance():playEffect("ButtonClick")
			end
		end
		for k,shopTag in pairs(self._tTagDataSource) do 
			if k == 1 then 
			  self._pTagBtn:setVisible(true)
			  -- 设置标签显示的文字
			  --self._pTagBtn:setTitleText(shopTag.tagName)
			  local pTagTextures = self._tTagTextures[shopTag.tagType + 1]
              self._pTagBtn:loadTextures(pTagTextures.normal,pTagTextures.pressed,pTagTextures.pressed,ccui.TextureResType.plistType)
			  -- 设置标签的tag (shopTag.tagType + 10000)
			  self._pTagBtn:setTag(shopTag.tagType + 10000)
			  self._pTagBtn:addTouchEventListener(tagClickEvent)
			  table.insert(self._tTags,self._pTagBtn)
		    else
		    	local tag = self._pTagBtn:clone()
		    	--tag:setTitleText(shopTag.tagName)
		    	local pTagTextures = self._tTagTextures[shopTag.tagType + 1]
                tag:loadTextures(pTagTextures.normal,pTagTextures.pressed,pTagTextures.pressed,ccui.TextureResType.plistType)
		    	tag:setTag(shopTag.tagType + 10000)
		    	local x = tagX + tagWidth * (k-1)		    	
		    	tag:setPosition(x,tagY)
		    	tag:addTouchEventListener(tagClickEvent)
		    	self._pTagNode:addChild(tag)
		    	table.insert(self._tTags,tag)
			end
		end
	end
	-- 设置数据
	self:setDataSource(self._tDataSource)
	-- 设置第一个标签为默认选中状态
	self:tagSelecteChanged(self._tTags[1]:getTag())
    -- 设置充值按钮是否可见
	self:setChargeBtnVisibleByShopType()
end

-- 设置玩家的金币信息
function ShopDialog:showCoinsInfo()

	local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(self._kFinaneType)
	self._pCoinIcon:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
	-- 设置金币
	self._pCoinNumText:setString(FinanceManager:getInstance()._tCurrency[self._kFinaneType])
end

-- 更新tag选中状态
function ShopDialog:tagSelecteChanged(nTag)
	if nTag <= 0  or #self._tTags < 1 then
		return
	end
	-- 改变按钮显示的样式
	for index,tagBtn in pairs(self._tTags) do
		if nTag == tagBtn:getTag() then
			tagBtn:loadTextureNormal(self._tTagTextures[tagBtn:getTag() - 10000 + 1].pressed,ccui.TextureResType.plistType)
		else
			tagBtn:loadTextureNormal(self._tTagTextures[tagBtn:getTag() - 10000 + 1].normal,ccui.TextureResType.plistType)
		end
	end
end

-- 更新物品的数据信息
function ShopDialog:updateGoodsList(goodsInfoArry)
	if type(goodsInfoArry) ~= "table" then
		return 
	end
	-- 初始化魔板列表
	self._pGoodsScrollView:setVisible(true)
	self._pGoodsScrollView:removeAllChildren(true)
	local scrollViewSize = self._pGoodsScrollView:getContentSize()
	local scrollViewInnerSize = self._pGoodsScrollView:getInnerContainerSize()
	local nRenderWidth = 235
	local nRenderHeight = 525
	local itemNum = #goodsInfoArry
	self._pGoodsScrollView:setInnerContainerSize(cc.size(nRenderWidth * itemNum,scrollViewInnerSize.height))
	for index,goodsDataInfo in pairs(goodsInfoArry) do
		local itemCell = require("ShopItemRender"):create(self._kFinaneType,self._kShopType)
		itemCell:setDataSource(goodsDataInfo)
		itemCell:setPositionX(nRenderWidth * (index - 1) + nRenderWidth / 2)
		itemCell:setPositionY(nRenderHeight/2)
		itemCell:setTouchEnabled(true)
		itemCell:setSwallowTouches(false)
        self._pGoodsScrollView:addChild(itemCell)
	end	
end

-- 初始化触摸相关
function ShopDialog:initTouches()
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
function ShopDialog:onExitShopDialog()
    self:onExitDialog()
	-- 释放网络监听事件
	NetRespManager:getInstance():removeEventListenersByHost(self)
	-- 释放掉shop合图资源
    ResPlistManager:getInstance():removeSpriteFrames("ShopUI.plist")
end

-- 处理查询商城的网络回调
function ShopDialog:handleMsgQueryShopInfo20501(args)
	 -- 商店类型
    self._kShopType = args.shopType
    -- 设置消耗货币类型
    self:setFinaneType()
	-- 商店的标签
	self._tTagDataSource = args.tags
	-- 默认显示首个标签的商品数据
	self._tDataSource = args.goodsInfo
	self:updateUI()
	if self._nSelecteTag > 0 then 
		ShopSystemCGMessage:QueryShopInfoByTagReq20502(self._kShopType,self._nSelecteTag)
	end 
end

-- 处理切换标签的网络回调
function ShopDialog:handleMsgQueryShopInfoByTag20503(event)
	-- 获得当前选中的标签类型 
	local tagType = event.tagId
	-- 获得当前标签下的商品列表 
	local goodsArry = event.goodsArry
	self:setDataSource(goodsArry)
    self:tagSelecteChanged(tagType + 10000)
end

-- 处理购买商品的网络回调
function ShopDialog:handleMsgBuyGoods20505(event)
	-- 当前购买物品的信息
	local goodsInfo = event.goodsInfo
    -- 显示当前玩家货币信息
    self:showCoinsInfo()
end 

-- 设置商品列表的数据源
function ShopDialog:setDataSource(tGoodsArry)
	if type(tGoodsArry) == "table" then 
		self._tDataSource = tGoodsArry
		-- 更新商品列表
		self:updateGoodsList(tGoodsArry)
        -- 切换标签时
        self._pGoodsScrollView:jumpToLeft()
	end
end

-- 根据商城类型设置消耗的货币类型
function ShopDialog:setFinaneType()
	if self._kShopType == kShopType.kDiamondShop then
		self._kFinaneType = kFinance.kDiamond -- 消耗钻石
	elseif self._kShopType == kShopType.kHonorShop then
		self._kFinaneType = kFinance.kHR -- 消耗货币为荣誉
	elseif self._kShopType == kShopType.kFamilyShop then 
        self._kFinaneType = kFinance.kFC -- 消耗的货币类型为家族贡献度
        
	end
end

-- 根据商城类型设置充值按钮是否可见
function ShopDialog:setChargeBtnVisibleByShopType()
	-- body
	-- if self._kShopType == kShopType.kDiamondShop then
	-- 	self._pChargeBtn:setVisible(true)
	-- else
	-- 	self._pChargeBtn:setVisible(false)
	-- end		
end

-- 显示完成
function ShopDialog:doWhenShowOver()
	ShopSystemCGMessage:QueryShopInfoReq20500(self._kShopType)
end


return ShopDialog