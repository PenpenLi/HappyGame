--动态板子
local DongTaiPanelParams = class("DongTaiPanelParams")

function DongTaiPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("DongTaiPanel.csb")
	--背景板
    self._pDongTaiBg = self._pCCS:getChildByName("DongTaiBg")
	--滚动框
	self._pDtScrollView = self._pDongTaiBg:getChildByName("DtScrollView")
end

function DongTaiPanelParams:create()
    local params = DongTaiPanelParams.new()
    return params  
end

return DongTaiPanelParams
