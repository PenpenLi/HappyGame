--动态板子
local GuanLiPanelParams = class("GuanLiPanelParams")

function GuanLiPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GuanLiPanel.csb")
	--背景板
    self._pGlBGg = self._pCCS:getChildByName("GlBGg")
	--滚动框
	self._pGlScrollView = self._pGlBGg:getChildByName("GlScrollView")
	--在线人数值/ 家族总人数
	self._pText_11 = self._pGlBGg:getChildByName("Text_11")
	--历史贡献值
	self._pText_13 = self._pGlBGg:getChildByName("Text_13")
	--本周贡献值
	self._pText_16 = self._pGlBGg:getChildByName("Text_16")
end

function GuanLiPanelParams:create()
    local params = GuanLiPanelParams.new()
    return params  
end

return GuanLiPanelParams
