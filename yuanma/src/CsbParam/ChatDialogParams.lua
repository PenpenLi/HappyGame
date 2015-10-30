--游戏的聊天界面
local ChatDialogParams = class("ChatDialogParams")

function ChatDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ChatDialog.csb")
	
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --世界频道按钮
    self._pButton1 = self._pBackGround:getChildByName("Button1")
    --家族频道按钮
    self._pButton2 = self._pBackGround:getChildByName("Button2")    
    --私聊频道按钮
    self._pButton3 = self._pBackGround:getChildByName("Button3")    
    --队伍频道按钮
    self._pButton4 = self._pBackGround:getChildByName("Button4")    
    --组队频道按钮
    self._pButton5 = self._pBackGround:getChildByName("Button5")    
    --系统频道按钮
    self._pButton6 = self._pBackGround:getChildByName("Button6")    
    
    --世界频道按钮提示
    self._pNotice1 = self._pButton1:getChildByName("Notice")
    --家族频道按钮提示
    self._pNotice2 = self._pButton2:getChildByName("Notice")    
    --私聊频道按钮提示
    self._pNotice3 = self._pButton3:getChildByName("Notice")    
    --队伍频道按钮提示
    self._pNotice4 = self._pButton4:getChildByName("Notice")    
    --组队频道按钮提示
    self._pNotice5 = self._pButton5:getChildByName("Notice")    
    --系统频道按钮提示
    self._pNotice6 = self._pButton6:getChildByName("Notice")   



  


    --设置按钮
    self._pOption = self._pBackGround:getChildByName("Option")    
    --聊天内容主显示列表
    self._pListView = self._pBackGround:getChildByName("ListView")    
  


    --输入框背景图
    self._pTextBg = self._pBackGround:getChildByName("TextBg")
    --输入框
    self._pTextFieldNode = self._pTextBg:getChildByName("TextFieldNode")
    --输入框新图
    self._pTextImage = self._pTextBg:getChildByName("TextImage")
    --输入框显示新node
    self._pTextNode = self._pTextBg:getChildByName("TextNode")





    --发送按钮
    self._pSend = self._pTextBg:getChildByName("Send")
    --组队界面下方文字提示
    self._pTeamNotice = self._pBackGround:getChildByName("TeamNotice")
    self._pTeamNotice:setTextColor(cFontDarkRed)


    --表情按钮
    self._pExpression = self._pTextBg:getChildByName("Expression")
    --语音按钮
    self._pVoice = self._pTextBg:getChildByName("Voice")
    


    --小喇叭按钮
    self._pBroadcast = self._pBackGround:getChildByName("Broadcast")
    --小喇叭使用状态
    self._pState = self._pBroadcast:getChildByName("State")
    --小喇叭数据
    self._pBroadcastNum = self._pBroadcast:getChildByName("BroadcastNum")


    --私聊标题背景
    self._pPrivateBg = self._pBackGround:getChildByName("PrivateBg")
    --私聊内层昵称 ：当前正在和玩家 “xxxxx” 聊天。
    self._pPrivateName = self._pPrivateBg:getChildByName("PrivateName")
    --私聊内层返回按钮
    self._pPrivateBack = self._pPrivateBg:getChildByName("Back")


    --表情底板
    self._pExpressionBg = self._pCCS:getChildByName("ExpressionBg")
    --表情底板
    self._pExpressionList = self._pExpressionBg:getChildByName("ExpressionList")
    --表情底板
    self._pExpressionClose = self._pExpressionBg:getChildByName("ExpressionClose")

    --私聊搜索节点
    self._pSearchNode = self._pBackGround:getChildByName("Search")
   

    --其他频道的文本框Node
    self._pListViewNode = self._pBackGround:getChildByName("TextNode") 
    --聊天历史记录底板
    self._pChatTextBG = self._pBackGround:getChildByName("ChatTextBG") 


end

function ChatDialogParams:create()
    local params = ChatDialogParams.new()
    return params  
end

return ChatDialogParams
