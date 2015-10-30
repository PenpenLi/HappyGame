--游戏的战斗界面
local ChatOptionParams = class("ChatOptionParams")

function ChatOptionParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ChatOption.csb")
	
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --世界频道是否自动播放语音按钮
    self._pCheckBox1 = self._pBackGround:getChildByName("CheckBox1")
    --世界频道是否自动播放语音按钮上面的对勾
    self._pPick1 = self._pCheckBox1:getChildByName("Pick1")


    --家族频道是否自动播放语音按钮
    self._pCheckBox2 = self._pBackGround:getChildByName("CheckBox2")    
    --家族频道是否自动播放语音按钮上面的对勾
    self._pPick2 = self._pCheckBox2:getChildByName("Pick2")


    -- 队伍频道是否自动播放语音按钮
    self._pCheckBox3 = self._pBackGround:getChildByName("CheckBox3")    
    --队伍频道是否自动播放语音按钮上面的对勾
    self._pPick3 = self._pCheckBox3:getChildByName("Pick3")


    --屏蔽人数显示 （x/50)
    self._pBlockNum = self._pBackGround:getChildByName("BlockNum")    
    self._pBlockNum:setTextColor(cFontDarkRed)

    --下方列表
    self._pListView = self._pBackGround:getChildByName("ListView")    
    
    --屏蔽玩家的背景
    self._pBlockBg = self._pListView:getChildByName("BlockBg")    
    --头像背景
    self._pHeadIconBg = self._pBlockBg:getChildByName("HeadIconBg")
    --头像本身
    self._pHeadIcon = self._pHeadIconBg:getChildByName("HeadIcon")    
     --玩家昵称
    self._pBlockName = self._pBlockBg:getChildByName("BlockName")    
    self._pBlockName:setTextColor(cFontDarkRed)
    --删除按钮
    self._pDelButton = self._pBlockBg:getChildByName("DelButton")    
    
    
     --标题
    self._pTitle = self._pBackGround:getChildByName("Title")
    self._pTitle:enableShadow(cFontShadow)

    --选项标题1
    self._pText1 = self._pBackGround:getChildByName("Text1")
    self._pText1:setTextColor(cFontDarkRed)

    --选项标题2
    self._pText2 = self._pBackGround:getChildByName("Text2")
    self._pText2:setTextColor(cFontDarkRed)

    --选项标题3
    self._pText3 = self._pBackGround:getChildByName("Text3")
    self._pText3:setTextColor(cFontDarkRed)
    
    --屏蔽标题
    self._pBlockTitle = self._pBackGround:getChildByName("BlockTitle")
    self._pBlockTitle:setTextColor(cFontDarkRed)

    

end

function ChatOptionParams:create()
    local params = ChatOptionParams.new()
    return params  
end

return ChatOptionParams
