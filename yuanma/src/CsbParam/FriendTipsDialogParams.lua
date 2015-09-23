--好友功能菜单
local FriendTipsDialogParams = class("FriendTipsDialogParams")

function FriendTipsDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FriendTipsDialog.csb")
	--大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --功能按钮1
    self._pButton1 = self._pBackGround:getChildByName("Button1")
    --功能按钮2
    self._pButton2 = self._pBackGround:getChildByName("Button2")
    --功能按钮3
    self._pButton3 = self._pBackGround:getChildByName("Button3")
    --功能按钮4
    self._pButton4 = self._pBackGround:getChildByName("Button4")
    --功能按钮5
    self._pButton5 = self._pBackGround:getChildByName("Button5")
    --功能按钮6
    self._pButton6 = self._pBackGround:getChildByName("Button6")
end

function FriendTipsDialogParams:create()
    local params = FriendTipsDialogParams.new()
    return params  
end

return FriendTipsDialogParams
