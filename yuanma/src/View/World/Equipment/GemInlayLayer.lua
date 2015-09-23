--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GemInlayLayer.lua
-- author:    wuquandong
-- created:   2015/01/13
-- descrip:   宝石镶嵌系统 
--===================================================
local GemInlayLayer = class("GemInlayLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function GemInlayLayer:ctor()
	self._strName = "GemInlayLayer"
	self._fCallback = nil -- 宝石列表的回调函数
	self._tGemSlotIconArry = {} -- 装备宝石槽图标
	self._tGemSlotFrameArry = {} -- 装备宝石的边框
	self._tGemSlotInfoArry = {} -- 装备宝石槽宝石信息
	self._pEquipIcon = nil -- 装备图标
	self._pEquipSlotIcon = nil -- 装备槽图标
	self._pEquipNameLbl = nil -- 装备的名称
	self._pEquipPartLbl = nil -- 装备位的名字
	self._pBuyGemBtn = nil -- 宝石的购买按钮
	self._pEquipItemInfo = nil  -- 当前选中装备的信息
	self._kEquipSrcType = nil -- 装备存放的位置（背包/装备位） 
	self._pEquipItemCell = nil -- 装备的itemCell 
	self._tGemItemCellArry = {} -- 宝石信息itemCell集合
	self._tInlayGemInfoArry = {} -- 该装备已镶嵌宝石的集合
	self._pGemInlaySucceedNode = nil  -- 宝石镶嵌成功特效
	self._pGemInlaySucceedAni = nil 
	self._nStoneId = 0  -- 最新镶嵌成功的宝石ID
	self._strTempGemInfo = "" -- 最新宝石信息的临时变量
	 --装备喷射粒子特效1-4
    self._pParticle01 = nil
    self._pParticle02 = nil
    self._pParticle03 = nil
    self._pParticle04 = nil
    self._showGemTabFunc = nil 
end

-- 创建函数 
function GemInlayLayer:create(callbackFunc,showGemTabFunc)
	local layer = GemInlayLayer.new()
	layer:dispose(callbackFunc,showGemTabFunc)
	return layer
end

-- 处理函数
function GemInlayLayer:dispose(callbackFunc,showGemTabFunc)
	self._fCallback = callbackFunc
	self._showGemTabFunc = showGemTabFunc
	-- 加载宝石镶嵌的图片资源
    ResPlistManager:getInstance():addSpriteFrames("GemSetPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("EquippingEffect.plist")
	-- 加载ui组件
	local params = require("GemSetPanelParams"):create()
	self._pCCS = params._pCCS
	self._pEquipNameLbl = params._pWeaponName
	self._pEquipIcon = params._pWeaponIcon
	-- 装备图标不可显示
	self._pEquipIcon:setVisible(false)
	-- 装备图标的粒子效果
	self._pParticle01 = params._pParticle01
	self._pParticle01:setVisible(false)
	self._pParticle02 = params._pParticle02
	self._pParticle02:setVisible(false)
	self._pParticle03 = params._pParticle03
	self._pParticle03:setVisible(false)
	self._pParticle04 = params._pParticle04
	self._pParticle04:setVisible(false)
	-- 装备槽图标
	self._pEquipSlotIcon = params._pWeaponBg
	self._pEquipItemCell = require("BagItemCell"):create()
    self._pEquipItemCell:setPosition(self._pEquipIcon:getPosition())
	self._pEquipSlotIcon:addChild(self._pEquipItemCell)
	self._pEquipItemCell:setTouchEnabled(false)
	-- 装备位
	self._pEquipPartLbl = params._pWeaponPart
	-- 装备镶嵌宝石的边框
	table.insert(self._tGemSlotFrameArry,params._pGem1Bg)
	table.insert(self._tGemSlotFrameArry,params._pGem2Bg)
	table.insert(self._tGemSlotFrameArry,params._pGem3Bg)
	table.insert(self._tGemSlotFrameArry,params._pGem4Bg)
    -- 装备镶嵌宝石的图标
	table.insert(self._tGemSlotIconArry,params._pGem1)
	table.insert(self._tGemSlotIconArry,params._pGem2)
	table.insert(self._tGemSlotIconArry,params._pGem3)
	table.insert(self._tGemSlotIconArry,params._pGem4)
    -- 装备镶嵌宝石的宝石信息
	table.insert(self._tGemSlotInfoArry,params._pGem1Text)
	table.insert(self._tGemSlotInfoArry,params._pGem2Text)
	table.insert(self._tGemSlotInfoArry,params._pGem3Text)
	table.insert(self._tGemSlotInfoArry,params._pGem4Text)
	for k,v in pairs(self._tGemSlotIconArry) do
		local pGemItemCell = require("BagItemCell"):create()
		pGemItemCell:setNameLabelVisible(false)
		-- 背景不显示
		--pGemItemCell._pBg:setVisible(false)
		pGemItemCell:setVisible(false)
        local itemSize = pGemItemCell._pBg:getContentSize()
		pGemItemCell:setPosition(v:getPositionX() - itemSize.width/2,v:getPositionY() - itemSize.height/2)
		self._tGemSlotFrameArry[k]:addChild(pGemItemCell)
		table.insert(self._tGemItemCellArry,pGemItemCell)
	end
	self._pBuyGemBtn = params._pButtonBuy

	self:addChild(self._pCCS)

	-- 宝石的购买按钮事件
	local function onBuyGemBtnCallback(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop,kTagType.kJewel})
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pBuyGemBtn:addTouchEventListener(onBuyGemBtnCallback)
	self._pBuyGemBtn:setZoomScale(nButtonZoomScale)  
    self._pBuyGemBtn:setPressedActionEnabled(true)
    --self._pBuyGemBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pBuyGemBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
	  ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitGemInlayLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function GemInlayLayer:onExitGemInlayLayer()
	-- 释放宝石镶嵌的图片资源
    ResPlistManager:getInstance():removeSpriteFrames("EquippingEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("GemSetPanel.plist")
end
	
-- 初始化宝石镶嵌UI
function GemInlayLayer:initUI()

	-- 设置装备位的图标
	self._pEquipItemCell:setItemInfo(self._pEquipItemInfo)
	-- 显示粒子效果
	self._pParticle01:setVisible(true)
	self._pParticle02:setVisible(true)
	self._pParticle03:setVisible(true)
	self._pParticle04:setVisible(true)
	-- 设置装备的名字
	self._pEquipNameLbl:setString(self._pEquipItemInfo.templeteInfo.Name)
	-- 设置装备的装备位
	self._pEquipPartLbl:setString(kEquipPositionTypeTitle[self._pEquipItemInfo.dataInfo.Part])
	-- 设置当前镶嵌宝石的信息
	local inlaidHoleNum = self._pEquipItemInfo.dataInfo.InlaidHole 
	for i = 1,inlaidHoleNum do
		-- 边框添加点击事件
		local function touchEvent(sender,eventType)
			if eventType == ccui.TouchEventType.ended then 
				 print("显示宝石标签")
				 -- 默认显示身上的标签(数据默认为第一个装备)
           	     --self:updateGemMountingButtonArrayTexture(3)
	             if self._showGemTabFunc  then 
	             	self._showGemTabFunc()
	             end
             elseif eventType == ccui.TouchEventType.began then
 			 	 AudioManager:getInstance():playEffect("ButtonClick")
			end
		end
        self._tGemSlotIconArry[i]:addTouchEventListener(touchEvent)
        self._tGemSlotIconArry[i]:setTouchEnabled(true)
        self._tGemSlotIconArry[i]:setSwallowTouches(false)
        self._tGemSlotIconArry[i]:setVisible(true)
        self._tGemSlotIconArry[i]:setTouchEnabled(true)
		self._tGemSlotFrameArry[i]:setVisible(true)
		self._tGemSlotInfoArry[i]:setVisible(true)
	end
	-- 获得当前装备已镶嵌宝石的id集合
    local tGemInfoArry = self._pEquipItemInfo.equipment[1].stones
	local pGemItemInfo = nil 
	if tGemInfoArry then
    	for index,gemId in pairs(tGemInfoArry) do
    		--根据宝石Id 获得宝石的详细信息
    		pGemItemInfo = BagCommonManager:getInstance():getItemRealInfo(gemId,kItemType.kStone)
    		table.insert(self._tInlayGemInfoArry,pGemItemInfo)
    		-- 设置宝石的图标
    		if self._tGemItemCellArry[index] ~= nil then
                self._tGemItemCellArry[index]:setItemInfo(pGemItemInfo)
                self._tGemItemCellArry[index]:setVisible(true)
    		end
    		--  设置装备上宝石的是背包还是身上的
    		local gemCellSrcType = self._kEquipSrcType == kCalloutSrcType.kCalloutSrcEquip and kCalloutSrcType.kCalloutSrcRoleEquipGem or kCalloutSrcType.kCalloutSrcBagEquipGem
    		if self._tGemItemCellArry[index] ~= nil then
                self._tGemItemCellArry[index]:setCalloutSrcType(gemCellSrcType)
            end
    		-- 设置弹出层需要的可选参数
    		local args = {} 
    		-- 如果当前是背包装备上的宝石
    		if gemCellSrcType == kCalloutSrcType.kCalloutSrcBagEquipGem then
    			-- 装备在背包中的位置
    			args.index = self._pEquipItemInfo.position 
    		else
    		-- 如果当前是身上的装备
    		    args.part = self._pEquipItemInfo.dataInfo.Part  	
    		end
    		if self._tGemItemCellArry[index] ~= nil then 
    			self._tGemItemCellArry[index]:setCalloutArgs(args)
			end 
    		-- 设置宝石的属性信息 
    		local msg = "" 
    		for k,property in pairs(pGemItemInfo.dataInfo.Property) do
    			-- 属性的名称
    			msg = msg..getStrAttributeRealValue(property[1],property[2]).."\n"
    		end
    		if self._tGemSlotInfoArry[index] ~= nil then
    			self._tGemSlotInfoArry[index]:setString(msg)
    			self._tGemSlotInfoArry[index]:setTextColor(cc.c4b(35, 235, 14, 255))
			end
    		-- 如果当前为最新镶嵌成功的宝石那么等特效播放成功才可显示宝石信息
    		if pGemItemInfo.dataInfo.ID == self._nStoneId then
    			if self._tGemSlotInfoArry[index] ~= nil then
    				self._tGemItemCellArry[index]:setVisible(false)
    				self._strTempGemInfo = self._tGemSlotInfoArry[index]:getString()
    				self._tGemSlotInfoArry[index]:setString("点击镶嵌宝石")
				end
			end
    	end
	end
end

-- 清空UI的显示信息
function GemInlayLayer:clearUI()
	-- 清空已镶嵌宝石的信息
	self._tInlayGemInfoArry = {}
	-- 初始化装备信息
	self._pEquipItemCell:setItemInfo(nil)
	self._pParticle01:setVisible(false)
	self._pParticle02:setVisible(false)
	self._pParticle03:setVisible(false)
	self._pParticle04:setVisible(false)
	-- 设置装备的名字
	self._pEquipNameLbl:setString("")
	-- 设置装备的装备位
	self._pEquipPartLbl:setString("")
	-- 初始化宝石图标并隐藏显示
	for k,gemSlotIcon in pairs(self._tGemSlotIconArry) do
		gemSlotIcon:setVisible(false)
		self._tGemSlotFrameArry[k]:setVisible(false)
		self._tGemItemCellArry[k]:setItemInfo(nil)
		self._tGemItemCellArry[k]:setVisible(false)
	end
	-- 初始化宝石属性信息并且隐藏显示
    for k,gemSlotInfo in pairs(self._tGemSlotInfoArry) do
		gemSlotInfo:setString("点击镶嵌宝石")
		gemSlotInfo:setTextColor(cc.c4b(255, 255, 255, 255))
		gemSlotInfo:setVisible(false)
	end
	-- 初始化装备来源
	self._kEquipSrcType = nil
	-- 初始化最新镶嵌成功的宝石
	self._nStoneId = 0
	self._pEquipItemInfo = nil
end

-- 物品列表选项改变的时候
function GemInlayLayer:SetRightScrollViewClickByIndex(pItemInfo,kItemSrcType)
	-- 如果选中的物品为宝石
	if kItemSrcType == kCalloutSrcType.kCalloutSrcGem then
	    DialogManager:getInstance():showDialog("BagCallOutDialog",{pItemInfo,kCalloutSrcType.kCalloutSrcGemSysMosaic,nil,true})
	else --  如果选中的物品为装备
		self:setDataSource(pItemInfo,kItemSrcType)
	end
end

-- 宝石tips 回调
function GemInlayLayer:gemTipsCallback(pItemInfo)
    if not self._pEquipItemInfo then 
        NoticeManager:getInstance():showSystemMessage("请先选择装备")
        return 
    end
    if pItemInfo.dataInfo.RequiredLevel > RolesManager:getInstance()._pMainRoleInfo.level then
            local msg = string.format("镶嵌此%s宝石需要达到%d级",pItemInfo.templeteInfo.Name,pItemInfo.dataInfo.RequiredLevel)
            NoticeManager:getInstance():showSystemMessage(msg)
        return
    end
	if self:isInlayedSameGem(pItemInfo.dataInfo.Type) == true then
        NoticeManager:getInstance():showSystemMessage("已镶嵌相同类型的宝石")
	else
		-- 如果当前装备为背包中
		if self._kEquipSrcType == kCalloutSrcType.kCalloutSrcBagCommon then
			GemSystemCGMessage:sendMessageInlayBagEquipReq20120(false,self._pEquipItemInfo.position,pItemInfo.dataInfo.ID,pItemInfo.position)	
		else
		-- 如果当前装备位身上的 
			GemSystemCGMessage:sendMessageInlayRoleEquipReq20122(false,self._pEquipItemInfo.dataInfo.Part,pItemInfo.dataInfo.ID,pItemInfo.position)
		end
	end
end

-- 判断此装备是否已镶嵌同类型的宝石
function GemInlayLayer:isInlayedSameGem(nGemType)
	for k,v in pairs(self._tInlayGemInfoArry) do
		if v.dataInfo.Type == nGemType then
			return true
		end
	end
	return false
end

-- 播放镶嵌成功特效
function GemInlayLayer:playGemInlaySucceedAni(nStoneId)
	for k,v in pairs(self._tInlayGemInfoArry) do
		if v.dataInfo.ID == nStoneId then 
			local itemCell = nil 
			-- 宝石镶嵌帧事件回调函数	
			local function onFrameEvent(frame)	     
				if nil == frame then 
					return
				end
				local str = frame:getEvent()
				if str == "playOver" then
					for k1,v in pairs(self._tGemItemCellArry) do
	                	if k1 == table.getn(self._tInlayGemInfoArry) then
	                		self._tGemItemCellArry[k1]:setVisible(true)
		                	self._tGemSlotInfoArry[k1]:setString(self._strTempGemInfo)
		                	itemCell:setVisible(false)
	                	end
					end
				end
			end
			
			self._pGemInlaySucceedNode = cc.CSLoader:createNode("EquippingEffect.csb")
			local pGemInlaySucceedAni = cc.CSLoader:createTimeline("EquippingEffect.csb")
			local x,y = self._tGemSlotIconArry[k]:getPosition()
			self._pGemInlaySucceedNode:setPosition(cc.p(x,y + 30))
			self._tGemSlotFrameArry[k]:addChild(self._pGemInlaySucceedNode)			
            pGemInlaySucceedAni:setFrameEventCallFunc(onFrameEvent)
            itemCell = self._tGemItemCellArry[k]:clone()
            local itemSize = self._tGemItemCellArry[k]._pBg:getContentSize()
            itemCell:setPosition(cc.p(itemSize.width + 10,itemSize.height - 20))
            itemCell:setScale(1.2)
            itemCell:setVisible(true)
            self._pGemInlaySucceedNode:getChildByName("Default"):addChild(itemCell)
            pGemInlaySucceedAni:gotoFrameAndPlay(0,pGemInlaySucceedAni:getDuration(), false)
            self._pGemInlaySucceedNode:runAction(pGemInlaySucceedAni)			
		end
	end
end

-- 获得当前镶嵌的装备
function GemInlayLayer:getItemInfo()
	local tEquip = {}
	tEquip[1] = self._pEquipItemInfo
	return tEquip
end

--  清理界面缓存
function GemInlayLayer:clearResolveUiDateInfo()
	self:clearUI()
end

-- 更新界面的数据源
function GemInlayLayer:setDataSource(pEquipItemInfo,kItemSrcType,nStoneId)
	self:clearUI()
	if not pEquipItemInfo or pEquipItemInfo.dataInfo.ID <= 0 then
		return
	end
	self._kEquipSrcType = kItemSrcType
	self._pEquipItemInfo = pEquipItemInfo
	self._nStoneId = nStoneId --  
	self:initUI()
	self:playGemInlaySucceedAni(nStoneId)
end

return GemInlayLayer