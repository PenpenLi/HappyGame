--宠物喂食界面界面
local FoodPanelParams = class("FoodPanelParams")

function FoodPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FoodPanel.csb")
	--喂食背景底板
    self._pRightBg = self._pCCS:getChildByName("RightBg")
    --宠物名字
    self._pNameText = self._pRightBg:getChildByName("NameText")
    --宠物类型
    self._pPetTypeText = self._pRightBg:getChildByName("PetTypeText")
    --宠物品阶
    self._pPzText = self._pRightBg:getChildByName("PzText")
    --宠物等级
    self._pLvText = self._pRightBg:getChildByName("LvText")
    --战斗力艺术字数值
    self._pPowerFnts = self._pRightBg:getChildByName("PowerFnts")
    --宠物生命值
    self._pshxtextNum = self._pRightBg:getChildByName("shxtextNum")
    --宠物防御力值
    self._pfangyutextNum = self._pRightBg:getChildByName("fangyutextNum")
    --宠物攻击力值
    self._pGjltextNum = self._pRightBg:getChildByName("GjltextNum")
    --当前经验进度条
    self._pExpBar = self._pRightBg:getChildByName("ExpBar")
    --当前经验值
    self._pExpTextNum = self._pRightBg:getChildByName("ExpTextNum")
    --宠物喂食材料底板
    self._pWeiSBg = self._pRightBg:getChildByName("WeiSBg")
    --宠物食材1底板 
    self._pIconBg1 = self._pWeiSBg:getChildByName("IconBg1")
    --宠物食材1图标
    self._pIcon1 = self._pWeiSBg:getChildByName("Icon1")
    --宠物食材1数量
    self._pWeiNum1 = self._pWeiSBg:getChildByName("WeiNum1")
    --喂食按钮1
    self._pWsButton1 = self._pWeiSBg:getChildByName("WsButton1")
    --宠物食材2底板 
    self._pIconBg2 = self._pWeiSBg:getChildByName("IconBg2")
    --宠物食材2图标
    self._pIcon2 = self._pWeiSBg:getChildByName("Icon2")
    --宠物食材2数量
    self._pWeiNum2 = self._pWeiSBg:getChildByName("WeiNum2")
    --喂食按钮2
    self._pWsButton2 = self._pWeiSBg:getChildByName("WsButton2")
    --宠物食材3底板 
    self._pIconBg3 = self._pWeiSBg:getChildByName("IconBg3")
    --宠物食材3数量
    self._pWeiNum3 = self._pWeiSBg:getChildByName("WeiNum3")
    --宠物食材1图标
    self._pIcon3 = self._pWeiSBg:getChildByName("Icon3")
    --喂食按钮1
    self._pWsButton3 = self._pWeiSBg:getChildByName("WsButton3")

    
end

function FoodPanelParams:create()
    local params = FoodPanelParams.new()
    return params  
end

return FoodPanelParams
