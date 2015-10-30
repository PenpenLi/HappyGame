--游戏的战斗界面
local PrivateChatParams = class("PrivateChatParams")

function PrivateChatParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PrivateChat.csb")
	
	--背景板
    self._pBackGround = self._pCCS:getChildByName("PrivateChat")
    --头像背景图
    self._pHeadIconBg = self._pBackGround:getChildByName("HeadIconBg")
    --头像本身
    self._pHeadIcon = self._pHeadIconBg :getChildByName("HeadIcon")
    --玩家昵称
    self._pName = self._pBackGround:getChildByName("Name")    
    self._pName:setTextColor(cFontDarkRed)

    --私聊最后发言时间
    self._pLastTime = self._pBackGround:getChildByName("LastTime") 
    self._pLastTime:setTextColor(cFontRed)

    --删除与之历史记录
    self._pDeleteHistory = self._pBackGround:getChildByName("DeleteHistory")    
    
    --未读条目数字
    self._pUnreadNum = self._pBackGround:getChildByName("UnreadNum")  
    self._pUnreadNum:setTextColor(cFontRed)
  

    --未读条目文字说明
    self._pUnread = self._pBackGround:getChildByName("Unread")   
    self._pUnread:setTextColor(cFontRed)


end

function PrivateChatParams:create()
    local params = PrivateChatParams.new()
    return params  
end

return PrivateChatParams
