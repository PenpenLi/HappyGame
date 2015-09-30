--宠物进阶界面界面
local AdvancedPetPanelParams = class("AdvancedPetPanelParams")

function AdvancedPetPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("AdvancedPetPanel.csb")
	--进阶背景底板
    self._pAdvancedPetBg = self._pCCS:getChildByName("AdvancedPetBg")
    --宠物名字
    self._pNameText = self._pAdvancedPetBg:getChildByName("NameText")
    --宠物类型
    self._pPetTypeText = self._pAdvancedPetBg:getChildByName("PetTypeText")
    --宠物品阶
    self._pPzText1 = self._pAdvancedPetBg:getChildByName("PzText1")
    --升阶后品阶
    self._pPzText2 = self._pAdvancedPetBg:getChildByName("PzText2")
    --宠物等级
    self._pLvText = self._pRightBg:getChildByName("LvText")
    --战斗力艺术字数值
    self._pPowerFnts = self._pAdvancedPetBg:getChildByName("PowerFnts")
    --升阶后战斗力
    self._pPowerFnts1 = self._pAdvancedPetBg:getChildByName("PowerFnts1")
    --宠物生命值
    self._pshxtextNum = self._pAdvancedPetBg:getChildByName("shxtextNum")
    --升阶后生命值
    self._pshxtextNum_1 = self._pAdvancedPetBg:getChildByName("shxtextNum_1")
    --宠物防御力值
    self._pfangyutextNum = self._pAdvancedPetBg:getChildByName("fangyutextNum")
    --升阶后防御力
    self._pfangyutextNum1 = self._pAdvancedPetBg:getChildByName("fangyutextNum1")
    --宠物攻击力值
    self._pGjltextNum = self._pAdvancedPetBg:getChildByName("GjltextNum")
    --升阶后攻击力
     self._pGjltextNum_1 = self._pAdvancedPetBg:getChildByName("GjltextNum_1")
    --宠物升阶材料1底板
    self._pJjieBg = self._pRightBg:getChildByName("JjieBg")
    --宠物升阶材料1底板 
    self._pIconBg1 = self._pAdvancedPetBg:getChildByName("IconBg1")
    --升阶材料1数量
    self._pIcon1Num = self._pAdvancedPetBg:getChildByName("Icon1Num")
    --宠物升阶材料1图标
    self._pIcon1 = self._pJjieBg:getChildByName("Icon1")
    --宠物升阶材料2底板 
    self._pIconBg2 = self._pJjieBg:getChildByName("IconBg2")
    --宠物升阶材料2图标
    self._pIcon2 = self._pJjieBg:getChildByName("Icon2")
    --升阶材料2数量
    self._pIcon2Num = self._pAdvancedPetBg:getChildByName("Icon2Num")
    --宠物升阶材料3底板 
    self._pIconBg3 = self._pJjieBg:getChildByName("IconBg3")
    --宠物升阶材料3图标
    self._pIcon3 = self._pJjieBg:getChildByName("Icon3")
    --升阶材料3数量
    self._pIcon3Num = self._pAdvancedPetBg:getChildByName("Icon3Num")
    --宠物升阶材料4底板 
    self._pIconBg4 = self._pJjieBg:getChildByName("IconBg4")
    --宠物升阶材料4图标
    self._pIcon4 = self._pJjieBg:getChildByName("Icon4")
    --升阶材料4数量
    self._pIcon4Num = self._pAdvancedPetBg:getChildByName("Icon4Num")
    --升阶按钮
    self._pJjieButton = self._pAdvancedPetBg:getChildByName("JjieButton")
    

    
end

function AdvancedPetPanelParams:create()
    local params = AdvancedPetPanelParams.new()
    return params  
end

return AdvancedPetPanelParams
