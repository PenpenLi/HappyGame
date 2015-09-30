--共鸣组合
local GmlistParams = class("GmlistParams")

function GmlistParams:ctor()
    self._pCCS = cc.CSLoader:createNode("Gmlist.csb")
	--共鸣底板
    self._pGmListBg = self._pCCS:getChildByName("GmListBg")
    --共鸣1图标
    self._pIcon1 = self._pGmListBg:getChildByName("Icon1")
    --共鸣1图标品质
    self._pIconPz1 = self._pGmListBg:getChildByName("IconPz1")
    --共鸣2图标
    self._pIcon2 = self._pGmListBg:getChildByName("Icon2")
    --共鸣2图标品质
    self._pIconPz2 = self._pGmListBg:getChildByName("IconPz2")
    --共鸣3图标
    self._pIcon3 = self._pGmListBg:getChildByName("Icon3")
    --共鸣3图标品质
    self._pIconPz3 = self._pGmListBg:getChildByName("IconPz3")
    --激活属性文字
    self._pGmText = self._pGmListBg:getChildByName("GmText")
    --已激活文字
    self._pJiHuoText1 = self._pGmListBg:getChildByName("JiHuoText1")
    --未激活文字
    self._pJiHuoText2 = self._pGmListBg:getChildByName("JiHuoText2")
end

function GmlistParams:create()
    local params = GmlistParams.new()
    return params  
end

return GmlistParams
