local GmDialogParams = class("GmDialogParams")

--宠物共鸣界面板子
function GmDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GmDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    
end

function GmDialogParams:create()
    local params = GmDialogParams.new()
    return params
end

return GmDialogParams
