--装备分解界面
local ResolveEquipPanelParams = class("ResolveEquipPanelParams")
function ResolveEquipPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ResolveEquipPanel.csb")
    --界面底板
    self._pResolveEqiupBg = self._pCCS:getChildByName("ResolveEqiupBg")
    --放置分解装备的滚动框
    self._pResolveEquipScrollView = self._pResolveEqiupBg:getChildByName("ResolveEquipScrollView")
    --单选蓝
    self._pBlueButton = self._pResolveEqiupBg:getChildByName("BlueButton")
    --单选紫
     self._pVioletButton = self._pResolveEqiupBg:getChildByName("VioletButton")
    --单选橙
    self._pOrangeButton = self._pResolveEqiupBg:getChildByName("OrangeButton")
    --单选全部
    self._pAllButton = self._pResolveEqiupBg:getChildByName("AllButton")
    --分解按钮
    self._pResoloveButton = self._pResolveEqiupBg:getChildByName("ResoloveButton")
    --单选蓝勾
    self._pBlueSlect = self._pBlueButton:getChildByName("BlueSlect")
    --单选紫勾
     self._pVioleSlect = self._pVioletButton:getChildByName("VioleSlect")
    --单选橙勾
    self._pOrangeSlect = self._pOrangeButton:getChildByName("OrangeSlect")
    --单选全部勾
    self._pAllSlect = self._pAllButton:getChildByName("AllSlect")
    --分解按钮
    self._pResoloveButton = self._pResolveEqiupBg:getChildByName("ResoloveButton")
end
function ResolveEquipPanelParams:create()
    local params = ResolveEquipPanelParams.new()
    return params
end

return ResolveEquipPanelParams
