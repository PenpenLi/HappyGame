--装备锻造界面
local EquipmentFoundryPanelParams = class("EquipmentFoundryPanelParams")
function EquipmentFoundryPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("EquipmentFoundryPanel.csb")
    --界面底板
    self._pFoundryBg = self._pCCS:getChildByName("FoundryBg")
    --锻造的装备底板
    self._pImageFrameBg = self._pFoundryBg:getChildByName("ImageFrame")
    --锤子亮起特效挂点
    self._pParticleNode = self._pImageFrameBg:getChildByName("ParticleNode")
    --碎片图标
    self._pPiecesEqiupIcon = self._pFoundryBg:getChildByName("PiecesEqiupIcon")
    --碎片品质
    self._pPiecesEqiupIconQuality = self._pPiecesEqiupIcon:getChildByName("PiecesEqiupIconQuality")
    --碎片名称
    self._pPathName = self._pPiecesEqiupIcon:getChildByName("PathName")
    --碎片等级文字
    self._pPiecesLevel = self._pPiecesEqiupIcon:getChildByName("PiecesLevel")
    --拥有碎片数量文字
    self._pPiecesNum1 = self._pPiecesEqiupIcon:getChildByName("PiecesNum1")
    --需求碎片数量文字
    self._pPiecesNum2 = self._pPiecesEqiupIcon:getChildByName("PiecesNum2")
    --图谱图标
    self._pPicsIcon = self._pFoundryBg:getChildByName("PicsIcon")
    --图谱的品质
    self._pPicsIconQuality = self._pPicsIcon:getChildByName("PicsIconQuality")
    --图谱名称
    self._pPicsName = self._pPicsIcon:getChildByName("PicsName")
    --拥有图谱数量文字
    self._pPicsNum1 = self._pPicsIcon:getChildByName("PicsNum1")
    --需求图谱数量文字
    self._pPicsNum2 = self._pPicsIcon:getChildByName("PicsNum2")
    --合成装备图标
    self._pEqiupMentIcon = self._pFoundryBg:getChildByName("EqiupMentIcon")
    --合成图标的品质
    self._pEqiupMentIconQuality = self._pEqiupMentIcon:getChildByName("EqiupMentIconQuality")
    --合成的装备等级文字
    self._pEqiupMentLv = self._pEqiupMentIcon:getChildByName("EqiupMentLv")
   
    --合成的装备说明底板
    self._pDesBg = self._pFoundryBg:getChildByName("DesBg")

    --装备名称文字
    self._pEquipName = self._pDesBg:getChildByName("EquipName")
    --装备部位文字
    self._pPosName = self._pDesBg:getChildByName("PosName")
    --装备等级文字
    self._pLvName = self._pDesBg:getChildByName("LvName")
    --装备战斗力最小值
    self._pFightNum1 = self._pDesBg:getChildByName("FightNum1")
    --装备战斗力最大值
    self._pFightNum2 = self._pDesBg:getChildByName("FightNum2")
    --锻造消耗金钱值
    self._pMoneyNum = self._pFoundryBg:getChildByName("MoneyNum")
     --锻造消耗文字
    --self._pMoneyText = self._pMoneyNum:getChildByName("Text_23")
    --锻造按钮
    self._pFoundryButton = self._pFoundryBg:getChildByName("FoundryButton")
    --没有锻造装备的显示
    self._pWeiFangText = self._pFoundryBg:getChildByName("WeiFangText")
end
function EquipmentFoundryPanelParams:create()
    local params = EquipmentFoundryPanelParams.new()
    return params
end

return EquipmentFoundryPanelParams
