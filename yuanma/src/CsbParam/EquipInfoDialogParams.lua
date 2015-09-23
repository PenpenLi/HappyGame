--装备tips界面
local EquipInfoDialogParams = class("EquipInfoDialogParams")

function EquipInfoDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("EquipInfoDialog.csb")
    --tips底板
    self._pBackGround = self._pCCS:getChildByName("EquipTipsBg")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --滚动框
    self._pEquipInfoScrollView = self._pBackGround:getChildByName("EquipInfoScrollView")
    --标签按钮列表框
    self._pButtonListView = self._pBackGround:getChildByName("ButtonListView")
    --标签按钮
    self._pTabButton = self._pButtonListView:getChildByName("TabButton") 
 
end

function EquipInfoDialogParams:create()
    local params = EquipInfoDialogParams.new()
    return params
end

return EquipInfoDialogParams
