local NotAcquiredEquipParams = class("NotAcquiredEquipParams")
--装备tip界面
function NotAcquiredEquipParams:ctor()
    self._pCCS = cc.CSLoader:createNode("NotAcquiredEquip.csb")
    

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


   --装备属性文字
   self._pEquipAttributeTab = self._pEquipTipsBg:getChildByName("EqiupAttributeTab")
   --装备属性值
   self._pAttributeText = self._pEquipTipsBg:getChildByName("AttributeText")
  
   
   --装备附加属性说明
   self._pAddAttributeText = self._pEquipTipsBg:getChildByName("AddAttributeText")
  
   --装备镶嵌属性说明
    self._pInlayAttributeText = self._pEquipTipsBg:getChildByName("InlayAttributeText")


  
   --关闭按钮
    self._pCloseButton = self._pEquipTipsBg:getChildByName("CloseButton")
end
function NotAcquiredEquipParams:create()
    local params = NotAcquiredEquipParams.new()
    return params
end

return NotAcquiredEquipParams
