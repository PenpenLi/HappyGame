--查找到的好友界面
local FindFriendsDialogParams = class("FindFriendsDialogParams")

function FindFriendsDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FindFriendsDialog.csb")
	--大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --查找好友标签
    self._pFindButton = self._pBackGround:getChildByName("FindButton")
    --推荐好友标签
    self._pGroomButton = self._pBackGround:getChildByName("GroomButton")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --查找底板的挂点
    self._pFindNode = self._pBackGround:getChildByName("FindNode")
    --查找小底板
    --self._pFindFriendBg = self._pFindNode:getChildByName("FindFriendBg")
    --输入框底板
    self._pFindNameBg = self._pFindNode:getChildByName("FindNameBg")
    --输入文字
    self._pFindName = self._pFindNameBg:getChildByName("FindName")
    --查找按钮
    self._pFindFriendButton = self._pFindNode:getChildByName("FindFriendButton")
    --推荐好友板子挂点
    self._pGroomNode = self._pBackGround:getChildByName("GroomNode")
    --推荐好友小底板
    --self._pGroomFriendBg = self._pGroomNode:getChildByName("GroomFriendBg")
    --刷新按钮
    self._pRefurbishButton = self._pGroomNode:getChildByName("RefurbishButton")
end

function FindFriendsDialogParams:create()
    local params = FindFriendsDialogParams.new()
    return params  
end

return FindFriendsDialogParams
