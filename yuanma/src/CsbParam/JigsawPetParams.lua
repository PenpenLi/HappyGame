--游戏的战斗界面
local JigsawPetParams = class("JigsawPetParams")

function JigsawPetParams:ctor()
    self._pCCS = cc.CSLoader:createNode("JigsawPet.csb")
	--技能tips背景板
    self._pJigsawPetBg = self._pCCS:getChildByName("JigsawPetBg")
    --宠物icon
    self._pIcon = self._pJigsawPetBg:getChildByName("Icon")
    --宠物品质框
    self._pIconP = self._pJigsawPetBg:getChildByName("IconP")
    --进度条背景
    self._pLoadingBarBg = self._pJigsawPetBg:getChildByName("LoadingBarBg")
    --进度条
    self._pLoadingBar = self._pJigsawPetBg:getChildByName("LoadingBar")
    --进度条上的文字
    self._pLoadingBarText = self._pJigsawPetBg:getChildByName("LoadingBarText")
    --self._pLoadingBarText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --合成按钮
    self._pMergeButton = self._pJigsawPetBg:getChildByName("MergeButton")
    --self._pMergeButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --聚魂按钮
    self._pLvUpButton = self._pJigsawPetBg:getChildByName("LvUpButton")
    --self._pLvUpButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --宠物的名字
    self._pName = self._pJigsawPetBg:getChildByName("Name")
    --宠物粗略类型
    self._pPetType = self._pJigsawPetBg:getChildByName("PetType")
    --宠物当前的品质
    self._pQuality = self._pJigsawPetBg:getChildByName("Quality")
    --宠物当前的品质
    self._pLv = self._pJigsawPetBg:getChildByName("Lv02")
    
	
end

function JigsawPetParams:create()
    local params = JigsawPetParams.new()
    return params  
end

return JigsawPetParams
