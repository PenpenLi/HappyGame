local HelpTextParams = class("HelpTextParams")
--物品tip界面排版
function HelpTextParams:ctor()
    self._pCCS = cc.CSLoader:createNode("HelpText.csb")
    --底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --标题
    self._pTitle = self._pBackGround:getChildByName("Title")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    -- ListView
    self._pListView = self._pBackGround:getChildByName("ListView")
    -- 文本框
    self._pText = self._pListView:getChildByName("Text")



    
end
function HelpTextParams:create()
    local params = HelpTextParams.new()
    return params
end

return HelpTextParams
