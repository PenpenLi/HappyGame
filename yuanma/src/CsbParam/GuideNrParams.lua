--我要变强具体引导内容
local GuideNrParams = class("GuideNrParams")

function GuideNrParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GuideNr.csb")
	--内容挂点
    self._pNodeNr = self._pCCS:getChildByName("NodeNr")
    --图标底板
    self._pIconBg = self._pNodeNr:getChildByName("IconBg")
    --图标
    self._pIconPic = self._pNodeNr:getChildByName("IconPic")
    --功能说明文字
    self._pTextNr = self._pNodeNr:getChildByName("TextNr")
    --前往按钮
    self._pOkButton = self._pNodeNr:getChildByName("OkButton")
    
end

function GuideNrParams:create()
    local params = GuideNrParams.new()
    return params  
end

return GuideNrParams
