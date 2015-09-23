--家族信息主界面
local FamilyDialogParams = class("FamilyDialogParams")

function FamilyDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FamilyDialog.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --信息按钮
    self._pButton_1 = self._pBackGround:getChildByName("Button_1")
    --管理按钮
    self._pButton_2 = self._pBackGround:getChildByName("Button_2")
    --科技按钮
    self._pButton_3 = self._pBackGround:getChildByName("Button_3")
    --申请按钮
    self._pButton_4 = self._pBackGround:getChildByName("Button_4")
    --动态按钮
    self._pButton_5 = self._pBackGround:getChildByName("Button_5")
    --挂点
    self._pNode = self._pBackGround:getChildByName("Node")
end

function FamilyDialogParams:create()
    local params = FamilyDialogParams.new()
    return params  
end

return FamilyDialogParams
