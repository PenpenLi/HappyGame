--装备分解界面
local ResolveEquipPanelParams = class("ResolveEquipPanelParams")
function ResolveEquipPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ResolveEquipPanel.csb")
    --界面底板
    self._pResolveEqiupBg = self._pCCS:getChildByName("ResolveEqiupBg")
    --分解按钮
    self._pResoloveButton = self._pResolveEqiupBg:getChildByName("ResoloveButton")
    --一键翻入按钮
    self._pResoloveButton_Copy = self._pResolveEqiupBg:getChildByName("ResoloveButton_Copy")
    --可以分解的装备
    self._pEqu1 = self._pResolveEqiupBg:getChildByName("FenJie1")
    self._pEqu2 = self._pResolveEqiupBg:getChildByName("FenJie2")
    self._pEqu3 = self._pResolveEqiupBg:getChildByName("FenJie3")
    self._pEqu4 = self._pResolveEqiupBg:getChildByName("FenJie4")
    self._pEqu5 = self._pResolveEqiupBg:getChildByName("FenJie5")
    self._pEqu6 = self._pResolveEqiupBg:getChildByName("FenJie6")
    self._pEqu7 = self._pResolveEqiupBg:getChildByName("FenJie7")
    self._pEqu8 = self._pResolveEqiupBg:getChildByName("FenJie8")
    self._tCanResolveEqu = { self._pEqu1, self._pEqu2, self._pEqu3, self._pEqu4, self._pEqu5, self._pEqu6, self._pEqu7, self._pEqu8}

    --全部按钮
    self._pAllButton = self._pResolveEqiupBg:getChildByName("AllButton")
     --蓝装按钮
    self._pBlueButton = self._pResolveEqiupBg:getChildByName("BlueButton")
     --紫装按钮
    self._pVioletButton = self._pResolveEqiupBg:getChildByName("VioletButton")
     --橙装按钮
    self._pOrangeButton = self._pResolveEqiupBg:getChildByName("OrangeButton")
    self._tColorCanResEquBtn = { self._pAllButton, self._pBlueButton, self._pVioletButton, self._pOrangeButton }
end
function ResolveEquipPanelParams:create()
    local params = ResolveEquipPanelParams.new()
    return params
end

return ResolveEquipPanelParams
