--宝石合成界面
local GemSetPanelParams = class("GemSetPanelParams")

function GemSetPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GemSetPanel.csb")

	-- 底板
    self._pGemSetGg = self._pCCS:getChildByName("GemSetBg")
    --宝石底图1-4
    self._pGem1Bg = self._pGemSetGg:getChildByName("Gem1_Bg")
    self._pGem2Bg = self._pGemSetGg:getChildByName("Gem2_Bg")
    self._pGem3Bg = self._pGemSetGg:getChildByName("Gem3_Bg")
    self._pGem4Bg = self._pGemSetGg:getChildByName("Gem4_Bg")
  
    --宝石icon1-4
    self._pGem1 = self._pGem1Bg:getChildByName("Gem1")
    self._pGem2 = self._pGem2Bg:getChildByName("Gem2")
    self._pGem3 = self._pGem3Bg:getChildByName("Gem3")
    self._pGem4 = self._pGem4Bg:getChildByName("Gem4")


    --宝石信息文字1-4
    self._pGem1Text = self._pGem1Bg:getChildByName("Gem1Text")
    self._pGem2Text = self._pGem2Bg:getChildByName("Gem2Text")
    self._pGem3Text = self._pGem3Bg:getChildByName("Gem3Text")
    self._pGem4Text = self._pGem4Bg:getChildByName("Gem4Text")
  
    --装备 底图
    self._pWeaponBg = self._pGemSetGg:getChildByName("Weapon_Bg")
    --装备 icon
    self._pWeaponIcon = self._pWeaponBg:getChildByName("Weapon") 
    --装备 名称
    self._pWeaponName = self._pWeaponBg:getChildByName("WeaponName")    
    --装备 部位
    self._pWeaponPart = self._pWeaponBg:getChildByName("WeaponType")
    

    --购买宝石按钮
    self._pButtonBuy = self._pGemSetGg:getChildByName("Button_Buy")
   
    --装备喷射粒子特效1-4
    self._pParticle01 = self._pGemSetGg:getChildByName("Particle02")
    self._pParticle02 = self._pGemSetGg:getChildByName("Particle03")
    self._pParticle03 = self._pGemSetGg:getChildByName("Particle04")
    self._pParticle04 = self._pGemSetGg:getChildByName("Particle05")
end

function GemSetPanelParams:create()
    local params = GemSetPanelParams.new()
    return params  
end

return GemSetPanelParams