--游戏的战斗界面
local RmbBGParams = class("RmbBGParams")

function RmbBGParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RmbBG.csb")
	--背景板
    self._pBG = self._pCCS:getChildByName("BG")
    --充值icon
    self._picon = self._pBG:getChildByName("icon")
    --购买按钮，上面有“￥+数字”
    self._pBuyButton = self._pBG:getChildByName("BuyButton")
    --获得的游戏币数量
    self._pText = self._pBG:getChildByName("Text")








end

function RmbBGParams:create()
    local params = RmbBGParams.new()
    return params  
end

return RmbBGParams
