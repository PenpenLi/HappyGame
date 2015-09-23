local LinkToObtainParams = class("LinkToObtainParams")
--物品tip界面排版
function LinkToObtainParams:ctor()
    self._pCCS = cc.CSLoader:createNode("LinkToObtain.csb")
    --链接底板
    self._pLinkBg = self._pCCS:getChildByName("LinkBg")
    --副本类型名称
    self._pText1 = self._pLinkBg:getChildByName("Text1")
    --前往按钮
    self._pButton = self._pLinkBg:getChildByName("Button")
    -- 具体关卡名称
    self._pText2 = self._pLinkBg:getChildByName("Text2")
  

end
function LinkToObtainParams:create()
    local params = LinkToObtainParams.new()
    return params
end

return LinkToObtainParams
