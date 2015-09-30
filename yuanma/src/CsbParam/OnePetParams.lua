--游戏的战斗界面
local OnePetParams = class("OnePetParams")

function OnePetParams:ctor()
    self._pCCS = cc.CSLoader:createNode("OnePet.csb")
	--技能tips背景板
    self._pOnePetBg = self._pCCS:getChildByName("OnePetBg")
    --宠物icon
    self._pIcon = self._pOnePetBg:getChildByName("Icon")
    --宠物品质框
    self._pIconP = self._pOnePetBg:getChildByName("IconP")
    --self._pUpButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --宠物名称
    self._pName = self._pOnePetBg:getChildByName("Name")
    --宠物等级
    self._pLv01 = self._pOnePetBg:getChildByName("LV01")
    --宠物等级具体数字
    self._pLv02 = self._pOnePetBg:getChildByName("LV02")
    --宠物类型
    self._pType = self._pOnePetBg:getChildByName("Type")
    --宠物当前品质
    self._pQuality = self._pOnePetBg:getChildByName("Quality")
    --宠物技能（技能2个字）
    self._pSkill = self._pOnePetBg:getChildByName("Skill")
    --宠物技能（具体哪个）01
    self._pPetSkill01 = self._pOnePetBg:getChildByName("PetSkill01")
    --宠物技能（具体哪个）02
    self._pPetSkill02 = self._pOnePetBg:getChildByName("PetSkill02")
    --宠物技能（具体哪个）03
    self._pPetSkill03 = self._pOnePetBg:getChildByName("PetSkill03")
    --宠物基本属性挂点
    self._pSxNode = self._pOnePetBg:getChildByName("SxNode")
    --宠物基本属性 4个字
    self._pAttribute = self._pSxNode:getChildByName("Attribute")
    --攻击
    self._pAttack01 = self._pSxNode:getChildByName("Attack01")
    --攻击（具体数值）
    self._pAttack02 = self._pSxNode:getChildByName("Attack02")
    --防御
    self._pDefend01 = self._pSxNode:getChildByName("Defend01")
    --防御（具体数值）
    self._pDefend02 = self._pSxNode:getChildByName("Defend02")
    --生命
    self._pHp01 = self._pSxNode:getChildByName("Hp01")
    --生命（具体数值）
    self._pHp02 = self._pSxNode:getChildByName("Hp02")
    --上阵按钮
    self._pUpButton = self._pSxNode:getChildByName("UpButton")
    --已上阵图标
    self._pUpUpUp = self._pSxNode:getChildByName("UpUpUp")
    --宠物特性 2个字
    self._pRoleAttribute = self._pOnePetBg:getChildByName("RoleAttribute")
    --宠物特性01
    self._pRoleAttribute0101 = self._pOnePetBg:getChildByName("RoleAttribute0101")
    --宠物特性01具体数值
    self._pRoleAttribute0102 = self._pOnePetBg:getChildByName("RoleAttribute0102")
    --宠物特性02
    self._pRoleAttribute0201 = self._pOnePetBg:getChildByName("RoleAttribute0201")
    --宠物特性02具体数值
    self._pRoleAttribute0202 = self._pOnePetBg:getChildByName("RoleAttribute0202")
    --宠物特性03
    self._pRoleAttribute0301 = self._pOnePetBg:getChildByName("RoleAttribute0301")
    --宠物特性03具体数值
    self._pRoleAttribute0302 = self._pOnePetBg:getChildByName("RoleAttribute0302")
    --宠物特性04
    self._pRoleAttribute0401 = self._pOnePetBg:getChildByName("RoleAttribute0401")
    --宠物特性04具体数值
    self._pRoleAttribute0402 = self._pOnePetBg:getChildByName("RoleAttribute0402")  

    --合成宠物碎片挂点 
    self._pJhNode = self._pOnePetBg:getChildByName("JhNode")
    --聚魂按钮
    self._pJhButton = self._pJhNode:getChildByName("JhButton")
    --进度条底板
    self._pJhSpBarBg = self._pJhNode:getChildByName("JhSpBarBg")
    --进度条
    self._pJhBar = self._pJhNode:getChildByName("JhBar")
    --数值
    self._pJhNum = self._pJhNode:getChildByName("JhNum")
    
    
    
    
    



    
    
	
    
end

function OnePetParams:create()
    local params = OnePetParams.new()
    return params  
end

return OnePetParams
