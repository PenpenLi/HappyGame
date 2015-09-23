--排行榜具体排行板子
local RankingListPanelParams = class("RankingListPanelParams")

function RankingListPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RankingListPanel.csb")
    --底板
    self._pBackGround = self._pCCS:getChildByName("RankingListBg")
    --滚动框
    self._pScrollView = self._pBackGround:getChildByName("ScrollView")
 
end

function RankingListPanelParams:create()
    local params = RankingListPanelParams.new()
    return params
end

return RankingListPanelParams
