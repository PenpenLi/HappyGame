--通用提示框界面
local PromptDialogParams = class("PromptDialogParams")

function PromptDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PromptDialog.csb")
    --通用提示框底板
    self._pPromptDialog = self._pCCS:getChildByName("PromptFrame")
    --关闭按钮
    self._pCloseButton = self._pPromptDialog:getChildByName("CloseButton")
    --确定按钮
    self._pOkButton = self._pPromptDialog:getChildByName("OkButton")
    --取消按钮
    self._pCancelButton = self._pPromptDialog:getChildByName("CancelButton")
    --提示文字
    self._pPromptText = self._pPromptDialog:getChildByName("PromptText")
end

function PromptDialogParams:create()
    local params = PromptDialogParams.new()
    return params
end

return PromptDialogParams
