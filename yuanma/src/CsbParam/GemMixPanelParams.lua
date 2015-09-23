--宝石合成界面
local GemMixPanelParams = class("GemMixPanelParams")

function GemMixPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GemMixPanel.csb")

	-- 底板
    self._pGemMixGg = self._pCCS:getChildByName("GemMixBg")
    --素材宝石底图1-5
    self._pBagItem1Bg = self._pGemMixGg:getChildByName("BagItem1_Bg")
    self._pBagItem2Bg = self._pGemMixGg:getChildByName("BagItem2_Bg")
    self._pBagItem3Bg = self._pGemMixGg:getChildByName("BagItem3_Bg")
    self._pBagItem4Bg = self._pGemMixGg:getChildByName("BagItem4_Bg")
    self._pBagItem5Bg = self._pGemMixGg:getChildByName("BagItem5_Bg") 
    --素材宝石icon1-5
    self._pBagItem1 = self._pBagItem1Bg:getChildByName("BagItem1")
    self._pBagItem2 = self._pBagItem2Bg:getChildByName("BagItem2")
    self._pBagItem3 = self._pBagItem3Bg:getChildByName("BagItem3")
    self._pBagItem4 = self._pBagItem4Bg:getChildByName("BagItem4")
    self._pBagItem5 = self._pBagItem5Bg:getChildByName("BagItem5")
    --宝石结果 底图
    self._pBagItemBg = self._pGemMixGg:getChildByName("BagItem_Bg")
    --宝石结果 icon
    self._pBagItem = self._pBagItemBg:getChildByName("BagItem")
    --购买按钮
    self._pButtonBuy = self._pGemMixGg:getChildByName("Button_Buy")
    --合成按钮
    self._pButtonMix = self._pGemMixGg:getChildByName("button_Mix")
    
end

function GemMixPanelParams:create()
    local params = GemMixPanelParams.new()
    return params  
end

return GemMixPanelParams