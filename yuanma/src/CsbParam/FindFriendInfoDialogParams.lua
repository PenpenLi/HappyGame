--查找到的好友信息界面
local FindFriendInfoDialogParams = class("FindFriendInfoDialogParams")

function FindFriendInfoDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FindFriendInfoDialog.csb")
	--大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --小底板
    --self._pInfoBg = self._pBackGround:getChildByName("InfoBg")
    --添加好友按钮
    self._pAddButton = self._pBackGround:getChildByName("AddButton")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --头像底框
    self._pHeadIconBg = self._pBackGround:getChildByName("HeadIconBg") 
    --头像图标
    self._pHeadIcon = self._pHeadIconBg:getChildByName("HeadIcon") 
    --角色等级
    self._pText1_1 = self._pBackGround:getChildByName("Text1_1")
    --角色昵称
    self._pText2_2 = self._pBackGround:getChildByName("Text2_2")
    --角色职业
    self._pText3_3 = self._pBackGround:getChildByName("Text3_3")
    --战斗力
    self._pText4_4 = self._pBackGround:getChildByName("Text4_4")

end

function FindFriendInfoDialogParams:create()
    local params = FindFriendInfoDialogParams.new()
    return params  
end

return FindFriendInfoDialogParams
