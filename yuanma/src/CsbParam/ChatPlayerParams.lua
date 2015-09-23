--游戏的战斗界面
local ChatPlayerParams = class("ChatPlayerParams")

function ChatPlayerParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ChatPlayer.csb")
	
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    
    --头像背景图
    self._pHeadIconBg = self._pBackGround:getChildByName("HeadIconBg")
    --头像本身
    self._pHeadIcon = self._pHeadIconBg:getChildByName("HeadIcon")    
    
    --玩家昵称
    self._pName = self._pBackGround:getChildByName("Name")    
    --玩家等级数字
    self._pLevel = self._pBackGround:getChildByName("Level")    
    --添加好友按钮
    self._pFriend = self._pBackGround:getChildByName("Friend")    
    --发起私聊按钮
    self._pChat = self._pBackGround:getChildByName("Chat")    
    --查看玩家按钮
    self._pCheck = self._pBackGround:getChildByName("Check")    
    --屏蔽玩家按钮
    self._pBlock = self._pBackGround:getChildByName("Block")    
  
  end

function ChatPlayerParams:create()
    local params = ChatPlayerParams.new()
    return params  
end

return ChatPlayerParams
