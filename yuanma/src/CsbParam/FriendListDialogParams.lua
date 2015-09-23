--好友列表界面
local FriendListDialogParams = class("FriendListDialogParams")

function FriendListDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FriendListDialog.csb")
	--大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --我的好友按钮
    self._pMyFriendButton = self._pBackGround:getChildByName("MyFriendButton")
    --好友申请按钮
    self._pFriendMessageButton = self._pBackGround:getChildByName("FriendMessageButton")
    --礼物详情按钮
    self._pGiftsInfoButton = self._pBackGround:getChildByName("GiftsInfoButton")
    --数量显示
    self._pListNum = self._pBackGround:getChildByName("ListNum")
    --好友列表挂点
    self._pFriendListNode= self._pBackGround:getChildByName("FriendListNode")
    --好友申请挂点
    self._pFriendMessageNode = self._pBackGround:getChildByName("FriendMessageNode")
    --礼物详情挂点
    self._pGiftsInfoNode = self._pBackGround:getChildByName("GiftsInfoNode")
    --好友列表小底板
    --self._pFriendsListBg= self._pFriendListNode:getChildByName("FriendsListBg")
    --好友申请小底板
    --self._pFriendsMessageBg= self._pFriendMessageNode:getChildByName("FriendsMessageBg")
    --礼物详情列表
    self._pGiftsInfoBg= self._pGiftsInfoNode:getChildByName("GiftsInfoBg")
    --好友列表滚动框
    self._pFriendListScrollView = self._pFriendListNode:getChildByName("FriendListScrollView")
    --好友申请滚动框
    self._pFriendMessageScrollView = self._pFriendMessageNode:getChildByName("FriendMessageScrollView")
    --礼物详情滚动框
    self._pGiftsInfoScrollView = self._pGiftsInfoBg:getChildByName("GiftsInfoScrollView")
    --添加按钮
    self._pAddFriendButton= self._pFriendListNode:getChildByName("AddFriendButton")
end

function FriendListDialogParams:create()
    local params = FriendListDialogParams.new()
    return params  
end

return FriendListDialogParams
