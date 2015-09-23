--成员申请板子
local CyPanelParams = class("CyPanelParams")

function CyPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("CyPanel.csb")
	--背景板
    self._pCyBg = self._pCCS:getChildByName("CyBg")
	--滚动框
	self._pCyScrollView = self._pCyBg:getChildByName("CyScrollView")
	--一键通过按钮
	self._pTgButton = self._pCyBg:getChildByName("TgButton")
	--一键拒绝按钮
    self._pJjButton = self._pCyBg:getChildByName("JjButton")
end

function CyPanelParams:create()
    local params = CyPanelParams.new()
    return params  
end

return CyPanelParams
