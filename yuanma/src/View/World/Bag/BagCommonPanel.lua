--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BagCommonPanel.lua
-- author:    liyuhang
-- created:   2014/12/16
-- descrip:   背包控件
--===================================================

local BagCommonPanel = class("BagCommonPanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function BagCommonPanel:ctor()
    self._strName = "BagCommonPanel"        -- 层名称
    self._pScrollItemsView = nil                  -- 滚动控件
    self._pItems = {}                    --背包集合
    self._tType = BagTabType.BagTabTypeAll

    self._pMoneyNum = nil
    self._pRmbNum = nil
    self._pOneKeySellBtn = nil          -- 一键出售白绿装备

    self._tTabBtnArray = {}
    self._pListController = nil
end

-- 创建函数
function BagCommonPanel:create()
    local layer = BagCommonPanel.new()
    layer:dispose()
    return layer
end

function BagCommonPanel:showBuyEffect()
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(0,-160)

    local _pResolveAniNode = cc.CSLoader:createNode("BuyBagEffect.csb")
    local _pResolveAniAction = cc.CSLoader:createTimeline("BuyBagEffect.csb")
    _pResolveAniNode:setScale(1.5)
    _pResolveAniNode:setPosition(pAniPostion)
    self:addChild( _pResolveAniNode)

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
            _pResolveAniNode:removeFromParent(true)
        end
    end
    _pResolveAniAction:setFrameEventCallFunc(onFrameEvent)
    _pResolveAniAction:gotoFrameAndPlay(0,_pResolveAniAction:getDuration(), false)
    _pResolveAniNode:stopAllActions()
    _pResolveAniNode:runAction(_pResolveAniAction)
end

function BagCommonPanel:updateItemArray(event)
   --购买更多
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local itemCount = TableConstants.BagExpandNumber.Value
            local itemNum = (BagCommonManager:getInstance()._nOpenCount - TableConstants.BagLimitFirst.Value) / TableConstants.BagExpandNumber.Value
            
            local buyItemCost = TableConstants.BagExpandPrice.Value + TableConstants.BagExpandPriceGrowth.Value * itemNum
        
            showConfirmDialog("确认花费".. buyItemCost .."玉璧，开启".. itemCount .."个背包格子？" , function()
                BagCommonCGMessage:sendMessageOpenPackageCell20102()
                
                
            end)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    local maxCount = BagCommonManager:getInstance()._nOpenCount
    local itemCount = BagCommonManager:getInstance():getItemCountWithBagTabType(self._tType)

    local bigCount,rowCount = 0

    if self._tType == BagTabType.BagTabTypeAll then
        bigCount = itemCount > maxCount and itemCount or maxCount
        
        self._pListController._pFootViewDelegateFunc = function (delegate,controller, index)
            --购买更多
            if self._pBuyCellBtn == nil then
                self._pBuyCellBtn = nil
                self._pBuyCellBtn = ccui.Button:create(
                    "ccsComRes/common001.png",
                    "ccsComRes/common002.png",
                    "ccsComRes/common001.png",
                    ccui.TextureResType.plistType)
                self._pBuyCellBtn:setTouchEnabled(true)
                self._pBuyCellBtn:setPosition(120,0)
                self._pBuyCellBtn:setAnchorPoint(cc.p(0, 0))
                self._pBuyCellBtn:setZoomScale(nButtonZoomScale)
                self._pBuyCellBtn:setPressedActionEnabled(true)
                --self._pScrollItemsView:addChild(self._pBuyCellBtn)
                self._pBuyCellBtn:addTouchEventListener(onTouchButton)
                self._pBuyCellBtn:setVisible(true)
                self._pBuyCellBtn:setTitleText("购买更多")
                self._pBuyCellBtn:setTitleFontSize(24)
                self._pBuyCellBtn:setTitleFontName(strCommonFontName)
                --self._pBuyCellBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
                self._pBuyCellBtn:retain()
            else

            end

            return self._pBuyCellBtn
        end

        self._pListController._pFootOfHeightDelegateFunc = function ()
            return 90
        end
        
    else
        self._pListController._pFootViewDelegateFucn = nil
        self._pListController._pFootOfHeightDelegateFunc = nil
    
        bigCount = itemCount > 24 and itemCount or 24
    end
    print("bigCount is -------------------------------------------------- " .. bigCount)
    local result1,result2 = math.modf(bigCount/4)
    if result2 > 0 then
        rowCount = result1 + 1
    else
        rowCount = result1
    end
    
   
    self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local info = nil
        -- 按照背包索引 取物品数据
        info = BagCommonManager:getInstance():getItemInfoByIndex(index,delegate._tType)

        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("BagItemCell"):create(kCalloutSrcType.kCalloutSrcBagCommon)
        end
        cell:setIndex(index)
        cell:openSelectedState()
        cell:setItemInfo(info)

        if index > maxCount then
            cell:setExceedMax()
        end

        return cell
    end

    self._pListController._pNumOfCellDelegateFunc = function ()
        return bigCount
    end

    self._pListController:setDataSource(self._tDiaryTasks)

    if event ~= nil and event.isBuy ~= nil and event.isBuy == 1 then
        self._pScrollItemsView:jumpToBottom()
        self:showBuyEffect()
    end
end

-- 处理函数
function BagCommonPanel:dispose()
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateBagItemList, handler(self, self.updateItemArray))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFisance ,handler(self, self.updateFisance))
    -- 加载资源
    ResPlistManager:getInstance():addSpriteFrames("BagPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("BuyBagEffect.plist")
    -- 加载dialog组件
    local params = require("BagPanelParams"):create()
    self._pCCS = params._pCCS
    self._pScrollItemsView = params._pBagScrollView
    self._pScrollItemsView:setInnerContainerSize(self._pScrollItemsView:getContentSize())
    self:addChild(self._pCCS)
    
    -- 初始化列表管理
    self._pListController = require("ListController"):create(self,self._pScrollItemsView,listLayoutType.LayoutType_rows,90,90)
    self._pListController:setVertiaclDis(9)
    self._pListController:setHorizontalDis(9)

    self._pMoneyNum = params._pMoneyNum
    self._pRmbNum = params._pRmbNum
    self._pMoneyNum:setString(FinanceManager:getValueByFinanceType(kFinance.kCoin))
    self._pRmbNum:setString(FinanceManager:getValueByFinanceType(kFinance.kDiamond))

    self._pScrollItemsView:setTouchEnabled(true)
    self._pScrollItemsView:setBounceEnabled(true)
    --更新格子列表
    self:updateItemArray()
    --整理按钮
    self._pTidyBtn = params._pCleanUpButton
    --self._pTidyBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pTidyBtn:setZoomScale(nButtonZoomScale)
    self._pTidyBtn:setPressedActionEnabled(true)
    self._pTidyBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            BagCommonCGMessage:sendMessageTidyPackage20104()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    local function okCallback ()
        EquipmentCGMessage:sellCheapItemByAutoReq20136()
    end
    -- 一键出售按钮
    self._pOneKeySellBtn = params._pOneKeySell
    self._pOneKeySellBtn:setZoomScale(nButtonZoomScale)
    self._pOneKeySellBtn:setPressedActionEnabled(true)
    self._pOneKeySellBtn:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            showConfirmDialog("白绿装备您可进行炼化提升自身属性，是否确定仍出售所有白绿装备?",okCallback)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    -- tab btn init
    self._tTabBtnArray[BagTabType.BagTabTypeAll] = params._pTabButton01
    self._tTabBtnArray[BagTabType.BagTabTypeEquip] = params._pTabButton02
    self._tTabBtnArray[BagTabType.BagTabTypeStone] = params._pTabButton03
    self._tTabBtnArray[BagTabType.BagTabTypeItem] = params._pTabButton04
    self:initTabArray()
    
    if BagCommonManager:getInstance():getInitDataOrNot() == false then
        BagCommonCGMessage:sendMessageGetBagList20100()
    end
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBagPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function BagCommonPanel:updateFisance()
    self._pMoneyNum:setString(FinanceManager:getValueByFinanceType(kFinance.kCoin))
    self._pRmbNum:setString(FinanceManager:getValueByFinanceType(kFinance.kDiamond))
end

function BagCommonPanel:clear()
    for i=1, table.getn(self._tTabBtnArray) do
        self._tTabBtnArray[i]:loadTextures(
            "BagPanelRes/BagTab00"..((i-1)*2+2)..".png",
            "BagPanelRes/BagTab00"..((i-1)*2+1)..".png",
            "BagPanelRes/BagTab00"..((i-1)*2+2)..".png",
            ccui.TextureResType.plistType)
    end
    
    self._tType = BagTabType.BagTabTypeAll

    self._tTabBtnArray[self._tType]:loadTextures(
        "BagPanelRes/BagTab00"..((self._tType-1)*2+1)..".png",
        "BagPanelRes/BagTab00"..((self._tType-1)*2+1)..".png",
        "BagPanelRes/BagTab00"..((self._tType-1)*2+1)..".png",
        ccui.TextureResType.plistType)

    --self:updateItemArray()
    
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kBagSelectedCell, {cell = nil}) 
    self._pTidyBtn:setVisible(true)
end

-- 退出函数
function BagCommonPanel:onExitBagPanel()
    self._pBuyCellBtn:release()
    self._pBuyCellBtn = nil
    -- release合图资源
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("BagPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BuyBagEffect.plist")
end

function BagCommonPanel:initTabArray()
    -- 标签选择按钮
    local  onTypeSelectButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print_lua_table(self._tTabBtnArray)
            
            if self._tType == sender.tag then
            	return
            end
            
            self._tTabBtnArray[self._tType]:loadTextures(
                "BagPanelRes/BagTab00"..((self._tType-1)*2+2)..".png",
                "BagPanelRes/BagTab00"..((self._tType-1)*2+1)..".png",
                "BagPanelRes/BagTab00"..((self._tType-1)*2+2)..".png",
                ccui.TextureResType.plistType)

            self._tType = sender.tag

            self._tTabBtnArray[self._tType]:loadTextures(
                "BagPanelRes/BagTab00"..((self._tType-1)*2+1)..".png",
                "BagPanelRes/BagTab00"..((self._tType-1)*2+1)..".png",
                "BagPanelRes/BagTab00"..((self._tType-1)*2+1)..".png",
                ccui.TextureResType.plistType)

            self:updateItemArray()

            if self._tType == BagTabType.BagTabTypeAll then
                self._pTidyBtn:setVisible(true)
            else
                self._pTidyBtn:setVisible(false)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._tTabBtnArray[BagTabType.BagTabTypeAll].tag = BagTabType.BagTabTypeAll
    self._tTabBtnArray[BagTabType.BagTabTypeEquip].tag = BagTabType.BagTabTypeEquip
    self._tTabBtnArray[BagTabType.BagTabTypeStone].tag = BagTabType.BagTabTypeStone
    self._tTabBtnArray[BagTabType.BagTabTypeItem].tag = BagTabType.BagTabTypeItem

    for i = 1,#self._tTabBtnArray do
        self._tTabBtnArray[i]:addTouchEventListener(onTypeSelectButton)
    end
end

function BagCommonPanel:showCache()
    self:jumpToTop()
    
    self._pListController:setDataSource(self._tDiaryTasks)
end

function BagCommonPanel:jumpToTop()
	self._pScrollItemsView:jumpToTop()
end

-- 循环更新
function BagCommonPanel:update(dt)
    return
end

return BagCommonPanel
