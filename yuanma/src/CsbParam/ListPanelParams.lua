--排行内容界面
local ListPanelParams = class("ListPanelParams")

function ListPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ListPanel.csb")
	--背景底板
    self._pListBg = self._pCCS:getChildByName("ListBg")
    --排行字段1
    self._pText_1 = self._pListBg:getChildByName("Text_1")
    --排行字段2
    self._pText_2 = self._pListBg:getChildByName("Text_2")
    --排行字段3
    self._pText_3 = self._pListBg:getChildByName("Text_3")
    --排行字段4
    self._pText_4 = self._pListBg:getChildByName("Text_4")
    
end

function ListPanelParams:create()
    local params = ListPanelParams.new()
    return params  
end

return ListPanelParams
