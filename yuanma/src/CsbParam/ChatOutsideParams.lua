--游戏的战斗界面
local ChatOutsideParams = class("ChatOutsideParams")

function ChatOutsideParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ChatOutside.csb")
	
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --聊天按钮
    self._pChat = self._pCCS:getChildByName("Chat")
    --新消息提示
    self._pNotice = self._pChat:getChildByName("Notice")
    --新消息提示
    self._pshenglue = self._pBackGround:getChildByName("shenglue")
 

end

function ChatOutsideParams:create()
    local params = ChatOutsideParams.new()
    return params  
end

return ChatOutsideParams
