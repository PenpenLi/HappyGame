local ArrageItemPanelParams = class("ArrageItemPanelParams")
--物品tip界面排版
function ArrageItemPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ArrangeItemPanel.csb")
    --物品说明底板
    self._pItemFrame = self._pCCS:getChildByName("ItemFrame")
    --物品名称
    self._pItemName = self._pItemFrame:getChildByName("ItemName")
    --物品说明滚动框
    self._pTextListView = self._pItemFrame:getChildByName("ScrollView_1")
    -- 物品说明标签
    self._pTextIntroText = self._pTextListView:getChildByName("Text_info")
    -- 宝石属性的值的底板
    self._pNeedLevelTitle = self._pItemFrame:getChildByName("Image_10")
    -- 需求等级的标题
    self._pNeedLevelTitleText = self._pNeedLevelTitle:getChildByName("LevelTitle")
    -- 需求等级的值
    self._pNeedLevelValue = self._pItemFrame:getChildByName("Text_Level")
    -- 宝石属性的标题底板
    self._pGemAttrTitle = self._pItemFrame:getChildByName("Image_10_Copy")
    -- 宝石属性的标题
    self._pGemAttrTitleText = self._pGemAttrTitle:getChildByName("Text_GemAttr")
    
    -- 宝石属性的值
    self._pGemAttrValue = self._pItemFrame:getChildByName("Text_GemAttr")
    --按钮滚动框
    self._pButtonListView = self._pItemFrame:getChildByName("ButtonListView")
    --标签按钮
    self._pListButtonTab = self._pButtonListView:getChildByName("ListButtonTab")
    --关闭按钮
    self._pCloseButton = self._pItemFrame:getChildByName("CloseButton")
    --物品的出售价格标题
    self._pSaleNumText = self._pItemFrame:getChildByName("SaleTitle")
    -- 物品的出售价格值
    self._pSaleNumValue = self._pItemFrame:getChildByName("SaleValue")
    -- 说明底板
    self._pInfBg = self._pItemFrame:getChildByName("Image_10_Copy_Copy")
    -- 获取途径底板
    self._pLinkBg = self._pItemFrame:getChildByName("LinkBg")
    -- 获取途径列表
    self._pLinkScrollView = self._pItemFrame:getChildByName("LinkScrollView")
    -- 获取途径文字
    self._pLinkText = self._pItemFrame:getChildByName("LinkText")


end
function ArrageItemPanelParams:create()
    local params = ArrageItemPanelParams.new()
    return params
end

return ArrageItemPanelParams
