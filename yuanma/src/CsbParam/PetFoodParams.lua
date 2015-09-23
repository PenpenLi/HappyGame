--游戏的战斗界面
local PetFoodParams = class("PetFoodParams")

function PetFoodParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PetFood.csb")
	--技能tips背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
     --宠物食材背景板
    self._pFoodBg = self._pBackGround:getChildByName("FoodBg")
    --喂食按钮01
    self._pFoodButton01 = self._pFoodBg:getChildByName("FoodButton01")
    --self._pFoodButton01:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --喂食按钮02
    self._pFoodButton02 = self._pFoodBg:getChildByName("FoodButton02")
    --self._pFoodButton02:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --喂食按钮03
    self._pFoodButton03 = self._pFoodBg:getChildByName("FoodButton03")
    --self._pFoodButton03:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
   
    --icon01
    self._pIcon01 = self._pFoodBg:getChildByName("Icon01")
    --icon01的数量
    self._picontext01 = self._pIcon01:getChildByName("icontext01")
    --self._picontext01:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._picontext01:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --icon02
    self._pIcon02 = self._pFoodBg:getChildByName("Icon02")
    --icon02的数量
    self._picontext02 = self._pIcon02:getChildByName("icontext02")
    --self._picontext02:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._picontext02:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --icon03
    self._pIcon03 = self._pFoodBg:getChildByName("Icon03")
    --icon03的数量
    self._picontext03 = self._pIcon03:getChildByName("icontext03")
    --self._picontext03:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._picontext03:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --3D模型的背景板
    self._p3DBg = self._pBackGround:getChildByName("3DBg")
    --经验进度条背景
    self._pLoadingBarBg = self._p3DBg:getChildByName("LoadingBarBg")
    --经验进度条
    self._pLoadingBar = self._p3DBg:getChildByName("LoadingBar")
    
    --经验数值显示
    self._pExpText = self._p3DBg:getChildByName("ExpText")
    --self._pExpText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._pExpText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
  


    --宠物详细属性的背景板
    self._pAttributeBg = self._pBackGround:getChildByName("AttributeBg")
    --宠物icon
    self._pIcon = self._pAttributeBg:getChildByName("Icon")
    --宠物品质框
    self._pIconP = self._pAttributeBg:getChildByName("IconP")

    --宠物名称
    self._pName = self._pAttributeBg:getChildByName("Name")
    --宠物等级
    self._pLv01 = self._pAttributeBg:getChildByName("Lv01")
    --宠物等级具体数字
    self._pLv02 = self._pAttributeBg:getChildByName("LV02")
    --宠物类型
    self._pType = self._pAttributeBg:getChildByName("Type")
    --宠物当前品质
    self._pQuality = self._pAttributeBg:getChildByName("Quality")
    --宠物详细属性的滚动容器
    self._pScrollView = self._pAttributeBg:getChildByName("ScrollView")
    --宠物基本属性 4个字
    self._pAttribute = self._pScrollView:getChildByName("Attribute")
    --攻击
    self._pAttack01 = self._pScrollView:getChildByName("Attack01")
    --攻击（具体数值）
    self._pAttack02 = self._pScrollView:getChildByName("Attack02")
    --穿透
    self._pPenetration01 = self._pScrollView:getChildByName("Penetration01")
    --穿透（具体数值）
    self._pPenetration02 = self._pScrollView:getChildByName("Penetration02")
    --暴击率
    self._pCriticalChance01 = self._pScrollView:getChildByName("CriticalChance01")
    --暴击率（具体数值）
    self._pCriticalChance02 = self._pScrollView:getChildByName("CriticalChance02")
    --暴击伤害
    self._pCriticalDmage01 = self._pScrollView:getChildByName("CriticalDmage01")
    --暴击伤害（具体数值）
    self._pCriticalDmage02 = self._pScrollView:getChildByName("CriticalDmage02")
    --属性强化
    self._pAbilityPower01 = self._pScrollView:getChildByName("AbilityPower01")
    --属性强化（具体数值）
    self._pAbilityPower02 = self._pScrollView:getChildByName("AbilityPower02")
    --火属性
    self._pFire01 = self._pScrollView:getChildByName("Fire01")
    --火属性（具体数值）
    self._pFire02 = self._pScrollView:getChildByName("Fire02")
    --冰属性
    self._pCold01 = self._pScrollView:getChildByName("Cold01")
    --冰属性（具体数值）
    self._pCold02 = self._pScrollView:getChildByName("Cold02")
    --雷属性
    self._pLightning01 = self._pScrollView:getChildByName("Lightning01")
    --雷属性（具体数值）
    self._pLightning02 = self._pScrollView:getChildByName("Lightning02")
    --生命
    self._pHp01 = self._pScrollView:getChildByName("Hp01")
    --生命（具体数值）
    self._pHp02 = self._pScrollView:getChildByName("Hp02")
    --防御
    self._pDefend01 = self._pScrollView:getChildByName("Defend01")
    --防御（具体数值）
    self._pDefend02 = self._pScrollView:getChildByName("Defend02")
    --韧性
    self._pResilience01 = self._pScrollView:getChildByName("Resilience01")
    --韧性（具体数值）
    self._pResilience02 = self._pScrollView:getChildByName("Resilience02")
    --格挡
    self._pBlock01 = self._pScrollView:getChildByName("Block01")
    --格挡（具体数值）
    self._pBlock02 = self._pScrollView:getChildByName("Block02")
    --闪避
    self._pDodgeChance01 = self._pScrollView:getChildByName("DodgeChance01")
    --闪避（具体数值）
    self._pDodgeChance02 = self._pScrollView:getChildByName("DodgeChance02")
    --抗性
    self._pResistance01 = self._pScrollView:getChildByName("Resistance01")
    --抗性（具体数值）
    self._pResistance02 = self._pScrollView:getChildByName("Resistance02")
    --再生
    self._pLifeperSecond01 = self._pScrollView:getChildByName("LifeperSecond01")
    --再生（具体数值）
    self._pLifeperSecond02 = self._pScrollView:getChildByName("LifeperSecond02")
    --吸血
    self._pLifeSteal01 = self._pScrollView:getChildByName("LifeSteal01")
    --吸血（具体数值）
    self._pLifeSteal02 = self._pScrollView:getChildByName("LifeSteal02")
    --宠物特性 2个字
    self._pRoleAttribute = self._pScrollView:getChildByName("RoleAttribute")
    --宠物特性01
    self._pRoleAttribute0101 = self._pScrollView:getChildByName("RoleAttribute0101")
    --宠物特性01具体数值
    self._pRoleAttribute0102 = self._pScrollView:getChildByName("RoleAttribute0102")
    --宠物特性02
    self._pRoleAttribute0201 = self._pScrollView:getChildByName("RoleAttribute0201")
    --宠物特性02具体数值
    self._pRoleAttribute0202 = self._pScrollView:getChildByName("RoleAttribute0202")
    --宠物特性03
    self._pRoleAttribute0301 = self._pScrollView:getChildByName("RoleAttribute0301")
    --宠物特性03具体数值
    self._pRoleAttribute0302 = self._pScrollView:getChildByName("RoleAttribute0302")
    --宠物特性04
    self._pRoleAttribute0401 = self._pScrollView:getChildByName("RoleAttribute0401")
    --宠物特性03具体数值
    self._pRoleAttribute0402 = self._pScrollView:getChildByName("RoleAttribute0402")
    --宠物技能（技能2个字）
    self._pSkill = self._pScrollView:getChildByName("Skill")
    --宠物技能（具体哪个）01
    self._pPetSkill01 = self._pScrollView:getChildByName("PetSkill01")
    --宠物技能（具体哪个）02
    self._pPetSkill02 = self._pScrollView:getChildByName("PetSkill02")
    --宠物技能（具体哪个）03
    self._pPetSkill03 = self._pScrollView:getChildByName("PetSkill03")
    --宠物技能（具体哪个）04
    self._pPetSkill04 = self._pScrollView:getChildByName("PetSkill04")
    
	
    
end

function PetFoodParams:create()
    local params = PetFoodParams.new()
    return params  
end

return PetFoodParams
