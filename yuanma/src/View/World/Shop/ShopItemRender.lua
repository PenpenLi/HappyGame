--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ShopItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/18
-- descrip:   商城商品模板
--===================================================
local ShopItemRender = class("ShopItemRender",function () 
	return ccui.ImageView:create()
end)

function ShopItemRender:ctor()
	self._strName = "ShopItemRender"
	self._pCCS = nil
	self._pGoodsIconImgView = nil 
	self._pGoodsIconBgImgView = nil 
	self._pGoodsNameText = nil 
	self._pHotImgView = nil 
	self._pHotBgImgView = nil
	-- 商品的原价
	self._pOriginalPriceNode = nil 
	self._pOriginalCoinIcon = nil 
	self._pOriginalPriceText = nil 
	-- 商品的现价
	self._pCurrentPriceNode = nil 
	self._pCurrentCoinIcon = nil 
	self._pCurrentPriceText = nil 
	-- 商品的出售价格
	self._pSellPriceNode = nil 
	self._pSellCoinIcon = nil 
	self._pSellPriceText = nil 

	self._nFinaceIconImgView = nil 
	self._pBuyButton = nil 
	self._pBg = nil
	------------------------------
	self._pGoodsDataInfo = nil 
	self._pItemInfo = nil 
	self._kFinaneType = 0
	self._kShopType = 0
end

function ShopItemRender:create(financeType,shopType)
	local imageView = ShopItemRender.new()
	imageView:dispose(financeType,shopType)
	return imageView
end

function ShopItemRender:dispose(financeType,shopType)
	self._kFinaneType = financeType
	self._kShopType = shopType
	local params = require("ShopOneParams"):create()
	self._pCCS = params._pCCS
	-- 此处是个button
	self._pBg = params._pitemCellBg
	self._pGoodsIconImgView = params._picon01
	self._pGoodsIconBgImgView = params._picon01P
	self._pGoodsNameText = params._pname01
	self._pHotImgView = params._phot01
	--self._pHotBgImgView = params._pHotBg
	self._pOriginalPriceNode = params._pNodeMoney01
	self._pOriginalPriceText = params._ptextprice01
	self._pOriginalCoinIcon = params._pOriginalCoinIcon
	self._pCurrentPriceNode = params._pNodeMoney02
	self._pCurrentCoinIcon = params._pcosticon
	self._pCurrentPriceText = params._ptextprice02
	self._pSellPriceNode = params._pNodeMoney03
	self._pSellCoinIcon = params._pcosticon02
	self._pSellPriceText = params._ptextprice03

	--self._nFinaceIconImgView = params._pFinaceIcon
	self._pBuyButton = params._pitemCellBg
	--self._pBg:setTouchEnabled(true)
	self._pBg:setSwallowTouches(false)
	self:addChild(self._pCCS)
	
	self:initTouches()

	------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitShopItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)	 	
end

function ShopItemRender:initTouches()
	-- 商品图标点击事件
	local function onTouchGoodsIcon(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pTipDialog = nil
            if self._pGoodsDataInfo.itemInfo.baseType ~= kItemType.kEquip then            
                DialogManager:getInstance():showDialog("BagCallOutDialog",{self._pItemInfo,nil,nil,false,false})
			else
                DialogManager:getInstance():showDialog("NeverGetEquipCallOutDialog",{self._pItemInfo})
			end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pGoodsIconImgView:setTouchEnabled(true)
	self._pGoodsIconImgView:addTouchEventListener(onTouchGoodsIcon)

	-- 点击购买按钮函数
	local function onBuyGoodsBtnClick (sender,eventType)
		if eventType == ccui.TouchEventType.began then 
			AudioManager:getInstance():playEffect("ButtonClick")
			self._fMoveDis = 0
		elseif eventType == ccui.TouchEventType.moved then
            self._fMoveDis = self._fMoveDis + 1    
      	elseif eventType == ccui.TouchEventType.ended then
      		if self._fMoveDis >= 4 then
      			self._fMoveDis = 0 
      			return
      		end
			-- 判断是否可以复数购买
			if self._pGoodsDataInfo.plural then 
				-- 此处弹出复选框
				DialogManager:getInstance():showDialog("MutlipeUseItemDialog",{self._pGoodsDataInfo,2,self._pGoodsDataInfo.financeType,self._kShopType})
			else
				-- 商品的剩余购买次数（-1：没有次数限制）
				if self._pGoodsDataInfo.remainBuy == 0 then
					local strMsg = "购买次数为0"
					showSystemMessage(msg)
				else
					local tMsg = {
					              {type = 2,title = "确定花费"},
                                  {type = 2,title = self._pGoodsDataInfo.currentPrice,
                                    fontColor = self._pGoodsDataInfo.currentPrice > FinanceManager:getInstance()._tCurrency[self._kFinaneType] 
                                    and cRed or cWhite},
                                  {type = 2,title = "个"..FinanceManager:getFinanceTitleByType(self._kFinaneType).."购买"..self._pItemInfo.templeteInfo.Name.."?"}
						}
                    showConfirmDialog(tMsg,function () 
						if FinanceManager:getInstance()._tCurrency[self._kFinaneType] >= self._pGoodsDataInfo.currentPrice then
							ShopSystemCGMessage:buyGoodsReq20504(self._kShopType,self._pGoodsDataInfo.goodsId,1)
						else
							local strMsg = string.format("%s不足",FinanceManager:getInstance():getFinanceTitleByType(self._kFinaneType))
							showSystemMessage(strMsg)
						end
					end)
				end
			end
		end
	end
	self._pBuyButton:addTouchEventListener(onBuyGoodsBtnClick)
end

function ShopItemRender:updateUI()
	
    -- 商品的名称
    self._pGoodsNameText:setString(self._pItemInfo.templeteInfo.Name)
    -- 热销标签的图标
    if self._pGoodsDataInfo.flag ~= kGoodsFlag.kNote then
        self._pHotImgView:loadTexture(self._pGoodsDataInfo.saleIcon..".png",ccui.TextureResType.plistType)
    else
    	self._pHotImgView:setVisible(false)
    	--self._pHotBgImgView:setVisible(false)
    end
    -- 商品的品质边框
    if self._pItemInfo.dataInfo.Quality ~= nil and self._pItemInfo.dataInfo.Quality ~= 0 then 
    	local quality = self._pItemInfo.dataInfo.Quality
    	self._pGoodsIconBgImgView:loadTexture("ccsComRes/qual_" ..quality.."_normal.png",ccui.TextureResType.plistType)
    	self._pGoodsNameText:setTextColor(kQualityFontColor4b[quality]) 
	else
        self._pGoodsIconBgImgView:setVisible(false)
	end
    self._pGoodsIconImgView:loadTexture(self._pItemInfo.templeteInfo.Icon..".png",ccui.TextureResType.plistType)
	
	local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(self._kFinaneType)

    -- 商品按原价出售时原价不显示
    if self._pGoodsDataInfo.currentPrice == self._pGoodsDataInfo.originalPrice then 
    	--self._pOriginalPriceText:setVisible(false)
    	self._pOriginalPriceNode:setVisible(false)
    	self._pCurrentPriceNode:setVisible(false)
    	self._pSellPriceNode:setVisible(true)
    	self._pSellCoinIcon:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)	
	else
		self._pOriginalPriceNode:setVisible(true)
    	self._pCurrentPriceNode:setVisible(true)
    	self._pSellPriceNode:setVisible(false)
    	-- 商品的打折金额
    	self._pOriginalPriceText:setString(self._pGoodsDataInfo.originalPrice)
    	self._pOriginalCoinIcon:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
		-- 商品的原价
    	self._pCurrentPriceText:setString(self._pGoodsDataInfo.currentPrice)
    	self._pCurrentCoinIcon:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
    end
end

function ShopItemRender:setDataSource(pGoodsInfo)
	if pGoodsInfo then 
		self._pGoodsDataInfo = pGoodsInfo
		-- 商品包含的物品信息
        self._pItemInfo = GetCompleteItemInfo(pGoodsInfo.itemInfo)

    	self:updateUI()
	end
end

function ShopItemRender:onExitShopItemRender()
	-- cleanup 

end

return ShopItemRender