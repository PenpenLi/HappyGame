--装备tips界面
local NumPutINDialogParams = class("NumPutINDialogParams")

function NumPutINDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("NumPutInDialog.csb") 
    --批量使用界面底板
    self._pNumBg = self._pCCS:getChildByName("NumBg")
    --减少按钮
    self._pLowButton = self._pNumBg:getChildByName("LowButton")
    --增加按钮
    self._pAddButton = self._pNumBg:getChildByName("AddButton")
    --最大按钮
    self._pMaxButton = self._pNumBg:getChildByName("MaxButton")
    --输入框底图
    self._pNumFrameBg = self._pNumBg:getChildByName("NumFrameBg")
    --输入框
    self._pNumPutInText = self._pNumBg:getChildByName("NumPutInText")
    --确定按钮
    self._pOkButton = self._pNumBg:getChildByName("OkButton")
   --关闭按钮
   self._pCloseButton = self._pNumBg:getChildByName("CloseButton")
 
end

function NumPutINDialogParams:create()
    local params = NumPutINDialogParams.new()
    return params
end

return NumPutINDialogParams
