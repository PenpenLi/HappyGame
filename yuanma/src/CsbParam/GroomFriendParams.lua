--推荐好友列表信息
local GroomFriendParams = class("GroomFriendParams")

function GroomFriendParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GroomFriend.csb")
	--大底板
    self._pGroomInfoBg = self._pCCS:getChildByName("GroomInfoBg")
    --头像底板
    self._pHeadIconBg = self._pGroomInfoBg:getChildByName("HeadIconBg")
    --头像图标
    self._pHeadIcon = self._pHeadIconBg:getChildByName("HeadIcon")
    --昵称
    self._pPlayerName = self._pGroomInfoBg:getChildByName("PlayerName")
    --添加按钮
    self._pAddButton = self._pGroomInfoBg:getChildByName("AddButton")
    --已添加图标
    self._pSendImage = self._pGroomInfoBg:getChildByName("SendImage")
    --等级文字
    self._pLvText = self._pGroomInfoBg:getChildByName("LvText")
end

function GroomFriendParams:create()
    local params = GroomFriendParams.new()
    return params  
end

return GroomFriendParams
