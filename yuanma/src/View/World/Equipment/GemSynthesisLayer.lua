--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GemSynthesisLayer.lua
-- author:    wuquandong
-- created:   2015/01/06
-- descrip:   宝石合成系统 
--===================================================
local GemSynthesisLayer = class("GemSynthesisLayer",function()
    return cc.Layer:create()
end)

--构造函数
function GemSynthesisLayer:ctor()
	self._strName = "GemSynthesisLayer"
	self._pIconItem1 = nil -- 宝石材料1图标
	self._pIconItem2 = nil -- 宝石材料2图标
	self._pIconItem3 = nil -- 宝石材料3图标
	self._pIconItem4 = nil -- 宝石材料4图标
	self._pIconItem5 = nil -- 宝石材料5图标 
	self._pIconResult = nil -- 合成后宝石图标
	self._pBuyGemBtn = nil -- 购买宝石按钮
	self._pGemSynthesisBtn = nil -- 宝石合成按钮
    self._tGemIconArry = {} -- 宝石图标的集合
    self._pSelectedGemInfo = nil -- 当前选中宝石的信息
    self._pNextLevelGemInfo = nil -- 下级宝石的信息
    self._fCallback = nil -- 宝石列表的回调函数
    self._tGemItemCellArry = {} -- 宝石信息的ItemCell 集合
end

--创建函数
function GemSynthesisLayer:create(callbackFunc)
	local layer = GemSynthesisLayer.new()
    layer:dispose(callbackFunc)
	return layer
end

-- 处理函数
function GemSynthesisLayer:dispose(callbackFunc)
    -- 右侧列表的回调函数
    self._fCallback = callbackFunc
	-- 加载宝石合成图片资源
    ResPlistManager:getInstance():addSpriteFrames("GemMixPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("StoneMixEffect.plist")
	-- 加载UI组件
	local params = require("GemMixPanelParams"):create()
	self._pCCS = params._pCCS
	self._pIconItem1 = params._pBagItem1
	self._pIconItem2 = params._pBagItem2
	self._pIconItem3 = params._pBagItem3
	self._pIconItem4 = params._pBagItem4
	self._pIconItem5 = params._pBagItem5
	self._pIconResult = params._pBagItem
    self._tGemIconArry = {self._pIconItem1,
                         self._pIconItem2,
                         self._pIconItem3,
                         self._pIconItem4,
                         self._pIconItem5,
                         self._pIconResult,
                     }
    for k,v in pairs(self._tGemIconArry) do
        local pGemItemCell = require("BagItemCell"):create()
        v:setVisible(false)
        pGemItemCell:setNameLabelVisible(false)
        local itemSize = pGemItemCell._pBg:getContentSize()
        pGemItemCell:setPosition(v:getPositionX() - itemSize.width/2,v:getPositionY() - itemSize.height/2)
        v:getParent():addChild(pGemItemCell)
        pGemItemCell:setTouchEnabled(true)
        pGemItemCell:setCalloutSrcType(kCalloutSrcType.KCalloutSrcTypeUnKnow)
        --pGemItemCell:setButtonListVisible(false)
        pGemItemCell:getVirtualRenderer():setScale(v:getVirtualRenderer():getScale())
        table.insert(self._tGemItemCellArry,pGemItemCell)
    end
	self._pBuyGemBtn = params._pButtonBuy
    self._pGemSynthesisBtn = params._pButtonMix
    self._pBg = params._pGemMixGg
	self:addChild(self._pCCS)
    -- 添加购买按钮事件
    local function onBuyGemBtnCallback(sendr,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("跳转到商店界面")
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
    -- 添加合成按钮事件
    local function onGemSynthesisClickCallback (sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            print ("合成宝石")
            if not self._pSelectedGemInfo then 
                NoticeManager:getInstance():showSystemMessage("请先选择可合成宝石")
                return 
            end
            
            if BagCommonManager:getInstance():isBagItemsEnough() then
                NoticeManager:getInstance():showSystemMessage("背包已满")
                return 
            end
            
            local function okCallback ()
                -- 向服务器发送宝石合成的协议
                print("向服务器发送宝石合成的协议")
                GemSystemCGMessage:sendMessageGemSynthesis20114(self._pSelectedGemInfo.dataInfo.ID)
            end
            -- 获得背包中该物品的真实数量
            self._pSelectedGemInfo.value = BagCommonManager:getInstance():getItemRealInfo(self._pSelectedGemInfo.dataInfo.ID,self._pSelectedGemInfo.baseType).value
           -- 判断背包中材料是否齐全         
           if TableConstants.GemMixRequire.Value > self._pSelectedGemInfo.value then
              --  缺少宝石的数量
              local lackGemNum =  TableConstants.GemMixRequire.Value - self._pSelectedGemInfo.value
               -- 需要花费的钻石数量
              local needPrice =  self._pSelectedGemInfo.dataInfo.ShopPrice * lackGemNum
              local msg = string.format("确定需要花费%d玉璧购买%d个%s合成一个%s?",needPrice,
                    lackGemNum,self._pSelectedGemInfo.templeteInfo.Name,self._pNextLevelGemInfo.templeteInfo.Name)
              
              showConfirmDialog(msg,okCallback)
            else
                local msg = string.format("确定消耗%d个%s合成一个%s?",TableConstants.GemMixRequire.Value,
                        self._pSelectedGemInfo.templeteInfo.Name,self._pNextLevelGemInfo.templeteInfo.Name)
                 showConfirmDialog(msg,okCallback)
           end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    -- 合成按钮
    self._pGemSynthesisBtn:addTouchEventListener(onGemSynthesisClickCallback)
    self._pGemSynthesisBtn:setZoomScale(nButtonZoomScale)
    self._pGemSynthesisBtn:setPressedActionEnabled(true)

    --self._pGemSynthesisBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pGemSynthesisBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitGemSynthesisLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)

     -- 宝石合成动画
    self._pPanIntoEffect = cc.CSLoader:createNode("StoneMixEffect.csb")
    self._pPanIntoEffect:setPosition(cc.p(self._pIconResult:getContentSize().width/2,self._pIconResult:getContentSize().height/2))
    self._tGemItemCellArry[6]:addChild(self._pPanIntoEffect)
    self._pPanIntoEffect:setVisible(false)
end

function GemSynthesisLayer:playeSuccessAni(callbackFunc)
     local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
            if callbackFunc then 
                self._pPanIntoEffect:setVisible(false)
                callbackFunc()
            end
        end
    end
    self._pPanIntoEffect:setVisible(true)
    local PanIntoAniAction = cc.CSLoader:createTimeline("StoneMixEffect.csb")
    PanIntoAniAction:setFrameEventCallFunc(onFrameEvent)
    PanIntoAniAction:gotoFrameAndPlay(0,PanIntoAniAction:getDuration(), false)
    self._pPanIntoEffect:stopAllActions()
    self._pPanIntoEffect:runAction(PanIntoAniAction)
end

function GemSynthesisLayer:onExitGemSynthesisLayer()
    -- 释放宝石合成资源
    ResPlistManager:getInstance():removeSpriteFrames("GemMixPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("StoneMixEffect.plist")
end

-- 显示（带动画）
function GemSynthesisLayer:showWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:setVisible(true)
    self:stopAllActions()

    local pPreposMask = cc.LayerColor:create(cc.c4b(0,0,0,255))
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)

    local showOver = function()
        self:doWhenShowOver()
        if self._pTouchListener ~= nil then
            self._pTouchListener:setEnabled(true)
        end
        pPreposMask:removeFromParent(true)
    end
    pPreposMask:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(showOver)))
    return
end

-- 右侧宝石列表的点击回调事件
function GemSynthesisLayer:SetRightScrollViewClickByIndex(pItemInfo)
    self:updateUI(pItemInfo)
    -- 更新宝石列表的选中状态
    local tempTable = {self._pSelectedGemInfo}
    self._fCallback(tempTable)
    
end

-- 更新宝石的信息 
function GemSynthesisLayer:updateUI(pGemInfo)
    if not pGemInfo then 
       return
    end
    if pGemInfo == "update" then
        pGemInfo = self._pSelectedGemInfo
    end
    -- 获得下级宝石的信息
    local nextLevelGemInfo = GemManager:getInstance():getGemDataInfoByGemId(pGemInfo.dataInfo.MixResult)
    -- 判断是否达到最大级
    if not nextLevelGemInfo then 
        NoticeManager:getInstance():showSystemMessage("此宝石已达到最高等级")
        return
    end

    -- 判断是否达到合成需要的角色等级
    if nextLevelGemInfo.dataInfo.RequiredLevel > RolesManager:getInstance()._pMainRoleInfo.level then
        local msg = string.format("合成更高一级的%s宝石需要达到%d级",nextLevelGemInfo.templeteInfo.Name,nextLevelGemInfo.dataInfo.RequiredLevel)
        NoticeManager:getInstance():showSystemMessage(msg)
        return
    end
    -- 设置当前选中宝石的信息
    self._pSelectedGemInfo = pGemInfo
    self._pNextLevelGemInfo = nextLevelGemInfo
    
    -- 根据背包里宝石的个数设置宝石槽里面的图片 
    local pBagItemInfo = BagCommonManager:getInstance():getItemRealInfo(pGemInfo.dataInfo.ID,pGemInfo.baseType)
    -- 当前拥有宝石的数量
    local hasItemNum = 0
    if pBagItemInfo ~= nil then 
        hasItemNum = pBagItemInfo.value
    end
    -- 获取在背包中真实个数
    self._pSelectedGemInfo.value = hasItemNum 
    
    local expendGemNum = pGemInfo.value >= TableConstants.GemMixRequire.Value and TableConstants.GemMixRequire.Value or self._pSelectedGemInfo.value
    for i = 1, TableConstants.GemMixRequire.Value do
        if i <= expendGemNum then
            --self._tGemIconArry[i]:loadTexture(pGemInfo.templeteInfo.Icon ..".png", ccui.TextureResType.plistType)
            self._tGemItemCellArry[i]:setItemInfo(pGemInfo)
        else
            --self._tGemIconArry[i]:loadTexture("ccsComRes/BagItem.png", ccui.TextureResType.plistType)
            self._tGemItemCellArry[i]:setItemInfo(nil)
        end
    end
    -- 加载要合成的宝石图片
    --self._pIconResult:loadTexture(nextLevelGemInfo.templeteInfo.Icon ..".png", ccui.TextureResType.plistType)
    self._tGemItemCellArry[6]:setItemInfo(nextLevelGemInfo)

end 

function GemSynthesisLayer:getItemInfo()
    if self._pSelectedGemInfo ~= nil and self._pSelectedGemInfo.value > 0 then 
        return {self._pSelectedGemInfo}
    else
        return {}
    end
end

-- 设置界面的数据信息
function GemSynthesisLayer:setDataSource(pGemInfo)
    self:updateUI(pGemInfo)
end

--  清理界面缓存
function GemSynthesisLayer:clearResolveUiDateInfo()
    self:clearUI()
end

-- 清空界面信息
function GemSynthesisLayer:clearUI()
    for k,v in pairs(self._tGemItemCellArry) do
        v:setItemInfo(pGemInfo)
    end
    self._pSelectedGemInfo = nil -- 当前选中宝石的信息
    self._pNextLevelGemInfo = nil -- 下级宝石的信息
end

return GemSynthesisLayer