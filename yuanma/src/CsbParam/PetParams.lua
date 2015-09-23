--游戏的战斗界面
local PetParams = class("PetParams")

function PetParams:ctor()
    self._pCCS = cc.CSLoader:createNode("Pet.csb")
	--技能tips背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --队伍按钮（选择页签队伍）
    --self._pTeamButton = self._pBackGround:getChildByName("TeamButton")
    --self._pTeamButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --碎片按钮（选择页签碎片）
    --self._pJigsawButton = self._pBackGround:getChildByName("JigsawButton")
    --self._pJigsawButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --队伍空位背景板
    self._pTeamBg = self._pBackGround:getChildByName("TeamBg")
    --icon01
    self._pIcon01 = self._pTeamBg:getChildByName("Icon01")
    --icon01的数量
    self._picontext01 = self._pIcon01:getChildByName("icontext01")
    --self._picontext01:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    

    --宠物品质框01
    self._pIconP01 = self._pIcon01:getChildByName("IconP")

    --宠物下阵按钮01
    self._ppetbutton01 = self._pIcon01:getChildByName("petbutton01")
    --self._ppetbutton01:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --icon02
    self._pIcon02 = self._pTeamBg:getChildByName("Icon02")
    --icon02的数量
    self._picontext02 = self._pIcon02:getChildByName("icontext02")
    --self._picontext02:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
     
    --宠物品质框02
    self._pIconP02 = self._pIcon02:getChildByName("IconP")

    --宠物下阵按钮02
    self._ppetbutton02 = self._pIcon02:getChildByName("petbutton02")
    --self._ppetbutton02:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --icon03
    self._pIcon03 = self._pTeamBg:getChildByName("Icon03")
    --icon03的数量
    self._picontext03 = self._pIcon03:getChildByName("icontext03")
    --self._picontext03:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    --宠物品质框03
    self._pIconP03 = self._pIcon03:getChildByName("IconP")

    --宠物下阵按钮03
    self._ppetbutton03 = self._pIcon03:getChildByName("petbutton03")
    --self._ppetbutton03:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --所有宠物小板背景板
    self._pAllBg = self._pBackGround:getChildByName("AllBg")
    --滚动容器
    self._pScrollView = self._pAllBg:getChildByName("ScrollView")
    --商城按钮
    self._pShopButton = self._pBackGround:getChildByName("ShopButton")
    --self._pShopButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --共鸣按钮
    self._pGmButton = self._pBackGround:getChildByName("GmButton")
    --宠物详细页面挂载节点
    self._pNodeFood = self._pCCS:getChildByName("NodeFood")
    
	
    
end

function PetParams:create()
    local params = PetParams.new()
    return params  
end

return PetParams
