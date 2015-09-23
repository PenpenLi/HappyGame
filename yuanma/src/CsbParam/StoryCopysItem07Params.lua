--游戏的第一章节界面
local StoryCopysItem07Params = class("StoryCopysItem07Params")

function StoryCopysItem07Params:ctor()
    self._pCCS = cc.CSLoader:createNode("StoryCopysItem07.csb")
	--大背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    --self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
	--选中边框节点
    self._pNodeClick = self._pBackGround:getChildByName("NodeClick")
    --副本节点01                                                              
    self._pnodecopy01 = self._pBackGround:getChildByName("nodecopys01")
    --副本节点02
    self._pnodecopy02 = self._pBackGround:getChildByName("nodecopys02")
    --副本节点03
    self._pnodecopy03 = self._pBackGround:getChildByName("nodecopys03")
    --副本节点04
    self._pnodecopy04 = self._pBackGround:getChildByName("nodecopys04")
    --副本节点05
    self._pnodecopy05 = self._pBackGround:getChildByName("nodecopys05")
    --副本节点06
    self._pnodecopy06 = self._pBackGround:getChildByName("nodecopys06")
    --副本节点07
    self._pnodecopy07 = self._pBackGround:getChildByName("nodecopys07")
    --副本节点08
    self._pnodecopy08 = self._pBackGround:getChildByName("nodecopys08")
    --副本节点09
    self._pnodecopy09 = self._pBackGround:getChildByName("nodecopys09")
    --副本节点10
    self._pnodecopy10 = self._pBackGround:getChildByName("nodecopys10")
    --副本节点11
    self._pnodecopy11 = self._pBackGround:getChildByName("nodecopys11")
    --副本节点12
    self._pnodecopy12 = self._pBackGround:getChildByName("nodecopys12")
    --副本节点13
    self._pnodecopy13 = self._pBackGround:getChildByName("nodecopys13")


    --副本节点集合
    self._tNodeCopy ={self._pnodecopy01,self._pnodecopy02,self._pnodecopy03,self._pnodecopy04,self._pnodecopy05,self._pnodecopy06,self._pnodecopy07,self._pnodecopy08,self._pnodecopy09,self._pnodecopy10,self._pnodecopy11,self._pnodecopy12,self._pnodecopy13}
    --下一章按钮
    --self._pNextButton = self._pBackGround:getChildByName("NextButton")
    --星级评价进度条节点（位置）
    self._pNodelevelstar = self._pBackGround:getChildByName("Nodelevelstar")
    --星级评价进度条底板
    self._pLSback = self._pNodelevelstar:getChildByName("LSback")
    --星级评价-进度条-
    self._pLSloadingbar = self._pNodelevelstar:getChildByName("LSloadingbar")
    --星级评价第1星
    self._pLS01 = self._pNodelevelstar:getChildByName("LS01")
    --星级评价第1星下面的数字
    self._pLStext01 = self._pLS01:getChildByName("LStext01")
    --星级评价第2星
    self._pLS02 = self._pNodelevelstar:getChildByName("LS02")
    --星级评价第2星下面的数字
    self._pLStext02 = self._pLS02:getChildByName("LStext02")
    --星级评价第3星
    self._pLS03 = self._pNodelevelstar:getChildByName("LS03")
    --星级评价第3星下面的数字
    self._pLStext03 = self._pLS03:getChildByName("LStext03")
    --宝箱按钮01
    self._pLSbutton01 = self._pNodelevelstar:getChildByName("LSbutton01")
    --宝箱按钮02
    self._pLSbutton02 = self._pNodelevelstar:getChildByName("LSbutton02")
    --宝箱按钮03
    self._pLSbutton03 = self._pNodelevelstar:getChildByName("LSbutton03")


    --宝箱的按钮集合
    self._tBoxButton = {self._pLSbutton01,self._pLSbutton02,self._pLSbutton03}
    --文字的按钮集合
    self._tLsText = {self._pLStext01,self._pLStext02,self._pLStext03}

    
end

function StoryCopysItem07Params:create()
    local params = StoryCopysItem07Params.new()
    return params  
end

return StoryCopysItem07Params
