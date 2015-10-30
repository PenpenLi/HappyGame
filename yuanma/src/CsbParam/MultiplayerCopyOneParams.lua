--游戏的商城界面
local MultiplayerCopyOneParams = class("MultiplayerCopyOneParams")

function MultiplayerCopyOneParams:ctor()
    self._pCCS = cc.CSLoader:createNode("MultiplayerCopyOne.csb")

	--背景板(按钮)
    self._pCopyBG = self._pCCS:getChildByName("CopyBG")
    --副本icon
    self._pCopyIcon = self._pCopyBG:getChildByName("CopyIcon")
	--副本名称
    self._pName = self._pCopyBG:getChildByName("Name")
    



    --颜色管理
    --cFontDarkRed = cc.c4b(93, 35, 35, 255)              -- 暗红色
    --控件颜色
    --button01:getTitleRenderer():setTextColor(cFontDarkRed)



    
end

function MultiplayerCopyOneParams:create()
    local params = MultiplayerCopyOneParams.new()
    return params  
end

return MultiplayerCopyOneParams
