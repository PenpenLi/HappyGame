--宠物详情小板子
local PetDetailedParams = class("PetDetailedParams")

function PetDetailedParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PetDetailed.csb")
	--详情底板
    self._pDetailedBg = self._pCCS:getChildByName("DetailedBg")
    --头像icon
    self._pIcon = self._pDetailedBg:getChildByName("Icon")
    --宠物名字
    self._pPetNameText = self._pDetailedBg:getChildByName("PetNameText")
    --宠物等级
    self._pPetLvText = self._pDetailedBg:getChildByName("PetLvText")
    --宠物类型
    self._pPetTypeText = self._pDetailedBg:getChildByName("PetTypeText")
    --宠物品质
    self._pPetPzText = self._pDetailedBg:getChildByName("PetPzText")
    --详情滚动框
    self._pDetailedScrollView = self._pDetailedBg:getChildByName("DetailedScrollView")
    --攻击值
    self._pText2_1 = self._pDetailedScrollView:getChildByName("Text2_1")
    --生命值
    self._pText4_1 = self._pDetailedScrollView:getChildByName("Text4_1")
    --防御值
    self._pText3_1 = self._pDetailedScrollView:getChildByName("Text3_1")
    --暴击值
    self._pText5_1 = self._pDetailedScrollView:getChildByName("Text5_1")
    --暴伤值
    self._pText6_1 = self._pDetailedScrollView:getChildByName("Text6_1")
    --抗性值
    self._pText8_1 = self._pDetailedScrollView:getChildByName("Text8_1")
    --韧性值
    self._pText7_1 = self._pDetailedScrollView:getChildByName("Text7_1")
    --格挡值
    self._pText9_1 = self._pDetailedScrollView:getChildByName("Text9_1")
    --穿透值
    self._pText10_1 = self._pDetailedScrollView:getChildByName("Text10_1")
    --闪避值
    self._pText11_1 = self._pDetailedScrollView:getChildByName("Text11_1")
    --再生值
    self._pText16_1 = self._pDetailedScrollView:getChildByName("Text16_1")
    --吸血值
    self._pText17_1 = self._pDetailedScrollView:getChildByName("Text17_1")
    --属性强化值
    self._pText12_1 = self._pDetailedScrollView:getChildByName("Text12_1")
    --火属性
    self._pText13_1 = self._pDetailedScrollView:getChildByName("Text13_1")
    --冰属性
 	 self._pText14_1 = self._pDetailedScrollView:getChildByName("Text14_1")
    --雷属性
    self._pText15_1 = self._pDetailedScrollView:getChildByName("Text15_1")
    --特性值1
    self._pText19 = self._pDetailedScrollView:getChildByName("Text19")
    --特性值2
    self._pText20 = self._pDetailedScrollView:getChildByName("Text20")
    --特性值3
    self._pText21 = self._pDetailedScrollView:getChildByName("Text21")
    --特性值4
    self._pText22 = self._pDetailedScrollView:getChildByName("Text22")
    --技能1
    self._pText23 = self._pDetailedScrollView:getChildByName("Text23")
    --技能2
    self._pText24 = self._pDetailedScrollView:getChildByName("Text24")
    --技能3
    self._pText25 = self._pDetailedScrollView:getChildByName("Text25")
    --技能4
    self._pText26 = self._pDetailedScrollView:getChildByName("Text26")

end

function PetDetailedParams:create()
    local params = PetDetailedParams.new()
    return params  
end

return PetDetailedParams
