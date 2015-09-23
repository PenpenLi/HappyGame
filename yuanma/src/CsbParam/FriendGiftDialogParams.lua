--好友赠送礼物界面
local FriendGiftDialogParams = class("FriendGiftDialogParams")

function FriendGiftDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FriendGiftDialog.csb")
	--大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --小底板
    --self._pGiftBg = self._pBackGround:getChildByName("GiftBg")
    --礼物小底板
    self._pGiftBg1 = self._pBackGround:getChildByName("GiftBg1")
    --礼物小底板
    self._pGiftBg2 = self._pBackGround:getChildByName("GiftBg2")
    --礼物小底板
    self._pGiftBg3 = self._pBackGround:getChildByName("GiftBg3")
    --礼物图标底框1
    self._pGiftIconBg1 = self._pGiftBg1:getChildByName("GiftIconBg1")
    --礼物图标1
    self._pGiftIcon1 = self._pGiftIconBg1:getChildByName("GiftIcon1")
    --礼物名称1
    self._pGiftNameText1 = self._pGiftBg1:getChildByName("GiftNameText1")
    --礼物描述1
    self._pGiftText1 = self._pGiftBg1:getChildByName("GiftText1")
    --礼物数量1
    self._pNumText1 = self._pGiftBg1:getChildByName("NumText1")
    --赠送按钮1
    self._pButton1 = self._pGiftBg1:getChildByName("Button1")
    --礼物图标底框2
    self._pGiftIconBg2 = self._pGiftBg2:getChildByName("GiftIconBg2")
    --礼物图标2
    self._pGiftIcon2 = self._pGiftIconBg2:getChildByName("GiftIcon2")
    --礼物名称2
    self._pGiftNameText2 = self._pGiftBg2:getChildByName("GiftNameText2")
    --礼物描述2
    self._pGiftText2 = self._pGiftBg2:getChildByName("GiftText2")
    --礼物数量2
    self._pNumText2 = self._pGiftBg2:getChildByName("NumText2")
    --赠送按钮2
    self._pButton2 = self._pGiftBg2:getChildByName("Button2")
    --礼物图标底框3
    self._pGiftIconBg3 = self._pGiftBg3:getChildByName("GiftIconBg3")
    --礼物图标3
    self._pGiftIcon3 = self._pGiftIconBg3:getChildByName("GiftIcon3")
    --礼物名称3
    self._pGiftNameText3 = self._pGiftBg3:getChildByName("GiftNameText3")
    --礼物描述3
    self._pGiftText3 = self._pGiftBg3:getChildByName("GiftText3")
    --礼物数量3
    self._pNumText3 = self._pGiftBg3:getChildByName("NumText3")
    --赠送按钮3
    self._pButton3 = self._pGiftBg3:getChildByName("Button3")
end

function FriendGiftDialogParams:create()
    local params = FriendGiftDialogParams.new()
    return params  
end

return FriendGiftDialogParams
