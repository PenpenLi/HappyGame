--游戏剧情界面框架
local StoryCopysDialogParams = class("StoryCopysDialogParams")

function StoryCopysDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("StoryCopysDialog.csb")
	--大背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
	--上一页按钮
    self._pPreviousButton = self._pBackGround:getChildByName("PreviousButton")
    --下一页按钮
    self._pNextButton = self._pBackGround:getChildByName("NextButton")
    --翻页容器
    self._pStoryCopysPageView = self._pBackGround:getChildByName("StoryCopysPageView")
   
 end

function StoryCopysDialogParams:create()
    local params = StoryCopysDialogParams.new()
    return params  
end

return StoryCopysDialogParams
