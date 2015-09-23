--通用提示框界面
local ChangeNameDialogParams = class("ChangeNameDialogParams")

function ChangeNameDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ChangeNameDialog.csb")
    --通用提示框底板
    self._pBackGround = self._pCCS:getChildByName("PromptFrame")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --确定按钮
    self._pOkButton = self._pBackGround:getChildByName("OkButton")
    --取消按钮
    self._pCancelButton = self._pBackGround:getChildByName("CancelButton")
    --输入的挂节点
    self._pEditBoxNode = self._pBackGround:getChildByName("editBoxNode")
    --所需钻石数目数字
    self._pPrice = self._pBackGround:getChildByName("Price")
end

function ChangeNameDialogParams:create()
    local params = ChangeNameDialogParams.new()
    return params
end

return ChangeNameDialogParams
