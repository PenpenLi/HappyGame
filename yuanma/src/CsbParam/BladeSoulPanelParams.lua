local BladeSoulPanelParams = class("BladeSoulPanelParams")
--物品tip界面排版
function BladeSoulPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BladeSoulPanel.csb")
    --物品说明底板
    self._pItemFrame = self._pCCS:getChildByName("ItemFrame")
    --物品名称
    self._pItemName = self._pItemFrame:getChildByName("ItemName")
    --物品说明滚动框
    self._pTextListView = self._pItemFrame:getChildByName("TextListView")
    --物品说明
    self._pTextIntroText = self._pTextListView:getChildByName("IllustrationText")
    --属性title
    self._pTextIntroText2 = self._pItemFrame:getChildByName("IllustrationText2") 
    --属性条目
    self._pTextIntroText3 = self._pItemFrame:getChildByName("IllustrationText3") 
    --所需人物等级
    self._pTextIntroTextLevel = self._pTextListView:getChildByName("IllustrationTextLevel")
    --按钮滚动框
    self._pButtonListView = self._pItemFrame:getChildByName("ButtonListView")
    --标签按钮
    self._pListButtonTab = self._pButtonListView:getChildByName("ListButtonTab")
    --关闭按钮
    self._pCloseButton = self._pItemFrame:getChildByName("CloseButton")
    --物品的出售价格
    self._pSaleNumText = self._pItemFrame:getChildByName("SaleTextNum")
end
function BladeSoulPanelParams:create()
    local params = BladeSoulPanelParams.new()
    return params
end

return BladeSoulPanelParams
