local ArrangeEquipPanelParams = class("ArrangeEquipPanelParams")
--装备tip界面
function ArrangeEquipPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ArrangeEquipPanel.csb")
    --tips底板
    self._pEquipTipsBg = self._pCCS:getChildByName("EquipTipsBg")
   --装备状态
   self._pEqiupStateText = self._pEquipTipsBg:getChildByName("EqiupStateText")
   --装备名称
   self._pEqiupNameText = self._pEquipTipsBg:getChildByName("EqiupNameText")
   --装备强化等级
   self._pAdvanceLvText = self._pEquipTipsBg:getChildByName("AdvanceLvText")
   --装备类型
   self._pEquipType = self._pEquipTipsBg:getChildByName("EqiupType")
   --装备等级
   self._pEquipLv = self._pEquipTipsBg:getChildByName("EquipLv")
   --装备icon
   self._pEquipIcon = self._pCCS:getChildByName("EqiupIcon")
   -- 装备图标边框
   self._pEquipIconFrame = self._pCCS:getChildByName("EqiupIconBg")
   --战斗力
   self._pEffectiveText = self._pEquipTipsBg:getChildByName("EffectiveText")
   --战斗力艺术字
   self._pEffectiveBitmapFont = self._pCCS:getChildByName("EffectiveBitmapFont")
   --装备升降图标
   self._pChangeIcon = self._pEquipTipsBg:getChildByName("ChangeIcon")
   --装备属性文字
   self._pEquipAttributeTab = self._pEquipTipsBg:getChildByName("EqiupAttributeTab")
   --装备属性值
   self._pAttributeText = self._pEquipTipsBg:getChildByName("AttributeText")
   --装备强化值
   self._pAttributeUpText = self._pEquipTipsBg:getChildByName("AttributeUpText")
   --装备附加属性滚动框
   self._pEquipInfoScrollView = self._pEquipTipsBg:getChildByName("EquipInfoScrollView")
      -- 装备附加属性背景图
   self._pTextFrameBg1 = self._pEquipInfoScrollView:getChildByName("TextFrameBg1")
   --装备附加属性文字
   self._pEquipAddAttributeTab = self._pTextFrameBg1 :getChildByName("EqiupAddAttributeTab")
   --装备附加属性值
   self._pAddAttributeText = self._pEquipInfoScrollView:getChildByName("AddAttributeText")
    -- 装备镶嵌属性背景
   self._pTextFrameBg2 = self._pEquipInfoScrollView:getChildByName("TextFrameBg2")
   --装备镶嵌属性
   self._pInlayAttributeTab = self._pTextFrameBg2:getChildByName("InlayAttributeTab")
   --装备镶嵌属性面板
    self._pInlayAttributePanel = self._pEquipInfoScrollView:getChildByName("InlayAttributePanel")
   --装备镶嵌属性没有时的提示信息
    self._pInlayAttributeNone = self._pEquipInfoScrollView:getChildByName("InlayAttributeNone")


   --出售
   self._pSaleTextNum = self._pEquipTipsBg:getChildByName("SaleValue")
   --按钮标签滚动框
   self._pButtonListView = self._pEquipTipsBg:getChildByName("ButtonListViewTab")
   --标签按钮
   self._pListButton = self._pButtonListView:getChildByName("ListButton1")
   --关闭按钮
    self._pCloseButton = self._pEquipTipsBg:getChildByName("CloseButton")
end
function ArrangeEquipPanelParams:create()
    local params = ArrangeEquipPanelParams.new()
    return params
end

return ArrangeEquipPanelParams
