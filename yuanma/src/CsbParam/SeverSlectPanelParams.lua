--服务器选择界面
local SeverSlectPanelParams = class("SeverSlectPanelParams")

function SeverSlectPanelParams:ctor()
    -- 服务器弹框
    self._pCCS = cc.CSLoader:createNode("SeverSlectPanel.csb")
    self._pSeverSlectBg = self._pCCS:getChildByName("SeverSlectBg")
    --滚动框
    self._pServerScrollView =  self._pSeverSlectBg:getChildByName("ServerScrollView")
end

function SeverSlectPanelParams:create()
    local params = SeverSlectPanelParams.new()
    return params
end

return SeverSlectPanelParams

 
