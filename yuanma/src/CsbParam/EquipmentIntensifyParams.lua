--装备强化界面
local EquipmentIntensifyParams = class("EquipmentIntensifyParams")

function EquipmentIntensifyParams:ctor()
    self._pCCS = cc.CSLoader:createNode("EquipmentIntensifyPanel.csb")
    --底板
    self._pStrengthenEquipBg = self._pCCS:getChildByName("StrengthenEquipBg")
    --要强化装备的星光底板
    self._pEqiupFrame01 = self._pStrengthenEquipBg:getChildByName("EqiupFrame01")
    --要强化装备的箭头底板
    self._pEqiupFrame02 = self._pStrengthenEquipBg:getChildByName("EqiupFrame02")
    --放入要强化的装备的栏位
    self._pStrengthenEqiup = self._pEqiupFrame01:getChildByName("StrengthenEqiup")
    --挂载的node
    self._pMountNode = self._pStrengthenEquipBg:getChildByName("MountNode")
    --强化材料栏位1
    self._pStrengMateria1 = self._pMountNode:getChildByName("StrengMateria1")
    --强化材料栏位2
    self._pStrengMateria2 = self._pMountNode:getChildByName("StrengMateria2")
    --强化材料栏位3
    self._pStrengMateria3 = self._pMountNode:getChildByName("StrengMateria3")
    --强化装备当前等级
    self._pStrengthenLvText1 = self._pStrengthenEquipBg:getChildByName("StrengthenLvText1")
    --强化后变化等级
    self._pStrengthenLvText2 = self._pStrengthenEquipBg:getChildByName("StrengthenLvText2")
    --强化装备当前属性
    self._pAttributeText1 = self._pStrengthenEquipBg:getChildByName("AttributeText1")
    --强化后属性变化值
    self._pAttributeText2 = self._pStrengthenEquipBg:getChildByName("AttributeText2")
    --一键强化按钮
    self._pStrengthenButton2 = self._pMountNode:getChildByName("StrengthenButton2")
    --强化按钮
    self._pStrengthenButton1 = self._pMountNode:getChildByName("StrengthenButton1")
    --强化消耗金钱值
    self._pMoneyNumText = self._pMountNode:getChildByName("MoneyNumText")
    --满级的显示图片
    self._pEquMaxIcon =  self._pStrengthenEquipBg:getChildByName("PictureText")
end

function EquipmentIntensifyParams:create()
    local params = EquipmentIntensifyParams.new()
    return params
end

return EquipmentIntensifyParams
