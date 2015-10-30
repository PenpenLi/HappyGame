--背包界面
local IconPanelParams = class("IconPanelParams")

function IconPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("IconPanel.csb")
    --底图
    self._pIconPanelBg = self._pCCS:getChildByName("IconPanelBg")
    --滚动条  水平滚动
    self._pIPScrollView = self._pIconPanelBg:getChildByName("IPScrollView")
   
    
end

function IconPanelParams:create()
    local params = IconPanelParams.new()
    return params
end

return IconPanelParams
