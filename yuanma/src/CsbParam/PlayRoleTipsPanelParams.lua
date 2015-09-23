--主城玩家互动板子
local PlayRoleTipsPanelParams = class("PlayRoleTipsPanelParams")

function PlayRoleTipsPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PlayRoleTipsPanel.csb")
    --底板
    self._pBackBg = self._pCCS:getChildByName("BackBg")
    --按钮1
    self._pButton_1 = self._pBackBg:getChildByName("Button_1")
    --按钮2
    self._pButton_2 = self._pBackBg:getChildByName("Button_2")
    --按钮2
    self._pCloseButton = self._pBackBg:getChildByName("Button_4")
    --角色名称
    self._pNameText = self._pBackBg:getChildByName("NameText")
end

function PlayRoleTipsPanelParams:create()
    local params = PlayRoleTipsPanelParams.new()
    return params
end

return PlayRoleTipsPanelParams
