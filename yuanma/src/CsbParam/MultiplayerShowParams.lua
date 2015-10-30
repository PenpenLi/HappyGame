--游戏的商城界面
local MultiplayerShowParams = class("MultiplayerShowParams")

function MultiplayerShowParams:ctor()
    self._pCCS = cc.CSLoader:createNode("MultiplayerShow.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
	--node1
    self._pNode1 = self._pBackGround:getChildByName("Node_1")
    --node2
    self._pNode2 = self._pBackGround:getChildByName("Node_2")
    --node3
    self._pNode3 = self._pBackGround:getChildByName("Node_3")
    self._tNodeMount = {self._pNode1, self._pNode2, self._pNode3}
    --总时间
    self._pTotalTime = self._pBackGround:getChildByName("Text_3")
    --剩余时间
    self._pRemainTime = self._pBackGround:getChildByName("Text_4")

    --颜色管理
    --cFontDarkRed = cc.c4b(93, 35, 35, 255)              -- 暗红色
    --控件颜色
    --button01:getTitleRenderer():setTextColor(cFontDarkRed)



    
end

function MultiplayerShowParams:create()
    local params = MultiplayerShowParams.new()
    return params  
end

return MultiplayerShowParams
