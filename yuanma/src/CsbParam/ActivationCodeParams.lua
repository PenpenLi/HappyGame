--激活码界面
local ActivationCodeParams = class("ActivationCodeParams")

function ActivationCodeParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ActivationCode.csb")
	--背景底板
    self._pPicCodeBg = self._pCCS:getChildByName("PicCodeBg")
    --领取按钮
    self._pOkButton = self._pBackGround:getChildByName("OkButton")
    --输入框文字
    self._pCodeText = self._pBackGround:getChildByName("CodeText")
    
end

function ActivationCodeParams:create()
    local params = ActivationCodeParams.new()
    return params  
end

return ActivationCodeParams
