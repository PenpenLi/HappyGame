--游戏的战斗界面
local PetEvolutionParams = class("PetEvolutionParams")

function PetEvolutionParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PetEvolution.csb")
	--技能tips背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --取消按钮
    self._pBackButton = self._pBackGround:getChildByName("BackButton")
    --确定按钮
    self._pSureButton = self._pBackGround:getChildByName("SureButton")
    --self._pSureButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --进阶材料背景板
    self._pItemBg = self._pBackGround:getChildByName("ItemBg")
    --icon01
    self._pIcon01 = self._pItemBg:getChildByName("Icon01")
    --icon01的数量
    self._picontext01 = self._pIcon01:getChildByName("icontext01")
    --self._picontext01:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._picontext01:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --icon02
    self._pIcon02 = self._pItemBg:getChildByName("Icon02")
    --icon02的数量
    self._picontext02 = self._pIcon02:getChildByName("icontext02")
    --self._picontext02:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._picontext02:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --icon03
    self._pIcon03 = self._pItemBg:getChildByName("Icon03")
    --icon03的数量
    self._picontext03 = self._pIcon03:getChildByName("icontext03")
    --self._picontext03:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._picontext03:enableOutline(cc.c4b(0, 0, 0, 255), 2)

    --宠物碎片进度条
    self._pLoadingBar = self._pItemBg:getChildByName("LoadingBar")
    --碎片进度条上的数字“10/10”
    self._pTextLoad = self._pItemBg:getChildByName("TextLoad")

    --3D模型的背景板
    self._p3DBg = self._pBackGround:getChildByName("3DBg")
    --模型1到模型的箭头
    self._pArrow = self._p3DBg:getChildByName("Arrow")
    --升阶之前的品质
    self._plevelBefore = self._p3DBg:getChildByName("levelBefore")
    --升阶之后的品质
    self._plevelAfter = self._p3DBg:getChildByName("levelAfter")




    --宠物详细属性的背景板
    self._pAttributeBg = self._pBackGround:getChildByName("AttributeBg")
    --宠物icon
    self._pIcon = self._pAttributeBg:getChildByName("Icon")
    --宠物名称
    self._pName = self._pAttributeBg:getChildByName("name")
    --宠物等级
    self._pLv01 = self._pAttributeBg:getChildByName("Lv01")
    --宠物等级具体数字
    self._pLv02 = self._pAttributeBg:getChildByName("Lv02")
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
    --攻击（具体数值）增加值
    self._pAttack03 = self._pScrollView:getChildByName("Attack03")
    --穿透
    self._pPenetration01 = self._pScrollView:getChildByName("Penetration01")
    --穿透（具体数值）
    self._pPenetration02 = self._pScrollView:getChildByName("Penetration02")
    --穿透（具体数值）增加值
    self._pPenetration03 = self._pScrollView:getChildByName("Penetration03")
    --暴击率
    self._pCriticalChance01 = self._pScrollView:getChildByName("CriticalChance01")
    --暴击率（具体数值）
    self._pCriticalChance02 = self._pScrollView:getChildByName("CriticalChance02")
    --暴击率（具体数值）增加值
    self._pCriticalChance03 = self._pScrollView:getChildByName("CriticalChance03")
    --暴击伤害
    self._pCriticalDmage01 = self._pScrollView:getChildByName("CriticalDmage01")
    --暴击伤害（具体数值）
    self._pCriticalDmage02 = self._pScrollView:getChildByName("CriticalDmage02")
    --暴击伤害（具体数值）增加值
    self._pCriticalDmage03 = self._pScrollView:getChildByName("CriticalDmage03")
    --属性强化
    self._pAbilityPower01 = self._pScrollView:getChildByName("AbilityPower01")
    --属性强化（具体数值）
    self._pAbilityPower02 = self._pScrollView:getChildByName("AbilityPower02")
    --属性强化（具体数值）增加值
    self._pAbilityPower03 = self._pScrollView:getChildByName("AbilityPower03")
    --火属性
    self._pFire01 = self._pScrollView:getChildByName("Fire01")
    --火属性（具体数值）
    self._pFire02 = self._pScrollView:getChildByName("Fire02")
    --火属性（具体数值）增加值
    self._pFire03 = self._pScrollView:getChildByName("Fire03")
    --冰属性
    self._pCold01 = self._pScrollView:getChildByName("Cold01")
    --冰属性（具体数值）
    self._pCold02 = self._pScrollView:getChildByName("Cold02")
    --冰属性（具体数值）增加值
    self._pCold03 = self._pScrollView:getChildByName("Cold03")
    --雷属性
    self._pLightning01 = self._pScrollView:getChildByName("Lightning01")
    --雷属性（具体数值）
    self._pLightning02 = self._pScrollView:getChildByName("Lightning02")
    --雷属性（具体数值）增加值
    self._pLightning03 = self._pScrollView:getChildByName("Lightning03")
    --生命
    self._pHp01 = self._pScrollView:getChildByName("Hp01")
    --生命（具体数值）
    self._pHp02 = self._pScrollView:getChildByName("Hp02")
    --生命（具体数值）增加值
    self._pHp03 = self._pScrollView:getChildByName("Hp03")
    --防御
    self._pDefend01 = self._pScrollView:getChildByName("Defend01")
    --防御（具体数值）
    self._pDefend02 = self._pScrollView:getChildByName("Defend02")
    --防御（具体数值）增加值
    self._pDefend03 = self._pScrollView:getChildByName("Defend03")
    --韧性
    self._pResilience01 = self._pScrollView:getChildByName("Resilience01")
    --韧性（具体数值）
    self._pResilience02 = self._pScrollView:getChildByName("Resilience02")
    --韧性（具体数值）增加值
    self._pResilience03 = self._pScrollView:getChildByName("Resilience03")
    --格挡
    self._pBlock01 = self._pScrollView:getChildByName("Block01")
    --格挡（具体数值）
    self._pBlock02 = self._pScrollView:getChildByName("Block02")
    --格挡（具体数值）增加值
    self._pBlock03 = self._pScrollView:getChildByName("Block03")
    --闪避
    self._pDodgeChance01 = self._pScrollView:getChildByName("DodgeChance01")
    --闪避（具体数值）
    self._pDodgeChance02 = self._pScrollView:getChildByName("DodgeChance02")
    --闪避（具体数值）增加值
    self._pDodgeChance03 = self._pScrollView:getChildByName("DodgeChance03")
    --抗性
    self._pResistance01 = self._pScrollView:getChildByName("Resistance01")
    --抗性（具体数值）
    self._pResistance02 = self._pScrollView:getChildByName("Resistance02")
    --抗性（具体数值）增加值
    self._pResistance03 = self._pScrollView:getChildByName("Resistance03")
    --再生
    self._pLifeperSecond01 = self._pScrollView:getChildByName("LifeperSecond01")
    --再生（具体数值）
    self._pLifeperSecond02 = self._pScrollView:getChildByName("LifeperSecond02")
    --再生（具体数值）增加值
    self._pLifeperSecond03 = self._pScrollView:getChildByName("LifeperSecond03")
    --吸血
    self._pLifeSteal01 = self._pScrollView:getChildByName("LifeSteal01")
    --吸血（具体数值）
    self._pLifeSteal02 = self._pScrollView:getChildByName("LifeSteal02")
    --吸血（具体数值）增加值
    self._pLifeSteal03 = self._pScrollView:getChildByName("LifeSteal03")
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

function PetEvolutionParams:create()
    local params = PetEvolutionParams.new()
    return params  
end

return PetEvolutionParams
