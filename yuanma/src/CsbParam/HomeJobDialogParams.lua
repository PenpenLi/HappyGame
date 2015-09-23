local HomeJobDialogParams = class("HomeJobDialogParams")
--家族职位界面
function HomeJobDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("HomeJobDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --确定按钮
    self._pOkButton = self._pBackGround:getChildByName("OkButton")
    --族长按钮
    self._pButton_1 = self._pBackGround:getChildByName("Button_1")
    --副族长按钮
    self._pButton_2 = self._pBackGround:getChildByName("Button_2")
    --长老按钮
    self._pButton_3 = self._pBackGround:getChildByName("Button_3")
    --成员按钮
    self._pButton_4 = self._pBackGround:getChildByName("Button_4")
end
function HomeJobDialogParams:create()
    local params = HomeJobDialogParams.new()
    return params
end

return HomeJobDialogParams
