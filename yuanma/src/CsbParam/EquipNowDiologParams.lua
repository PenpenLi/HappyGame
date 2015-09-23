--删除角色提示框
local EquipNowDiologParams = class("EquipNowDiologParams")

function EquipNowDiologParams:ctor()
    self._pCCS = cc.CSLoader:createNode("EquipNowDiolog.csb")
    --框体底板
    self._pBackGround = self._pCCS:getChildByName("EquipNowBg")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --确定装配上新装备的按钮
    self._pOKButton = self._pBackGround:getChildByName("Button")
    --新装备的icon
    self._pEquipIcon = self._pBackGround:getChildByName("EqiupIcon")
    --装备品质框
    self._pEqiupIconPz = self._pBackGround:getChildByName("EqiupIconPz")
    --新装备战斗力提升标志
    self._pEquipUp = self._pBackGround:getChildByName("EquipUp")
    --新装备提升的战斗力
    self._pPwoerText = self._pBackGround:getChildByName("PwoerText")
   
end

function EquipNowDiologParams:create()
    local params = EquipNowDiologParams.new()
    return params
end

return EquipNowDiologParams
