local RakingsDialogParams = class("RakingsDialogParams")
--家族排行界面
function RakingsDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RakingsDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
   --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --排行底板
    self._pRakingsBg = self._pBackGround:getChildByName("RakingsBg")
    --排行滚动框
    self._pRankingScrollView = self._pRakingsBg:getChildByName("RankingScrollView")
    --排行榜上一页按钮
    self._pPreviousButton1 = self._pRakingsBg:getChildByName("PreviousButton1")
   --排行榜下一页按钮
    self._pNextButton1 = self._pRakingsBg:getChildByName("NextButton1")
end
function RakingsDialogParams:create()
    local params = RakingsDialogParams.new()
    return params
end

return RakingsDialogParams
