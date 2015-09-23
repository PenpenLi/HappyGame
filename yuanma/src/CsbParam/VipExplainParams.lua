--游戏的战斗界面
local VipExplainParams = class("VipExplainParams")

function VipExplainParams:ctor()
    self._pCCS = cc.CSLoader:createNode("VipExplain.csb")
	--背景板
    self._pBG = self._pCCS:getChildByName("BG")
    --标题：vip等级
    self._pVip = self._pBG:getChildByName("Vip")
    --说明内容，对应vip等级显示
    self._pExplain = self._pBG:getChildByName("Explain")








end

function VipExplainParams:create()
    local params = VipExplainParams.new()
    return params  
end

return VipExplainParams
