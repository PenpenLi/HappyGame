local RankingsListTipsParams = class("RankingsListTipsParams")
--家族排行信息tips
function RankingsListTipsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RankingsListTips.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
   --关闭按钮
    self._pCloseButton = self._pCCS:getChildByName("CloseButton")
   --家族信息
   self._pButton_1 = self._pBackGround:getChildByName("Button_1")
end
function RankingsListTipsParams:create()
    local params = RankingsListTipsParams.new()
    return params
end

return RankingsListTipsParams
