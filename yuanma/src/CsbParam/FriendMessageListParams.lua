--好友申请列表信息
local FriendMessageListParams = class("FriendMessageListParams")

function FriendMessageListParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FriendMessageList.csb")
	--大底板
    self._pMessageBg = self._pCCS:getChildByName("MessageBg")
    --头像底板
    self._pHeadIconBg = self._pMessageBg:getChildByName("HeadIconBg")
    --头像图标
    self._pHeadIcon = self._pMessageBg:getChildByName("HeadIcon")
    --昵称
    self._pPNameText = self._pMessageBg:getChildByName("NameText")
    --拒绝按钮
    self._pIgnoreButton = self._pMessageBg:getChildByName("IgnoreButton")
    --同意按钮
    self._pOkButton = self._pMessageBg:getChildByName("OkButton")
end

function FriendMessageListParams:create()
    local params = FriendMessageListParams.new()
    return params  
end

return FriendMessageListParams
