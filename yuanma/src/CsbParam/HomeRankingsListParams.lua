local HomeRankingsListParams = class("HomeRankingsListParams")
--创建排行列表信息
function HomeRankingsListParams:ctor()
    self._pCCS = cc.CSLoader:createNode("HomeRankingsList.csb")
    --大底板
    self._pListBg = self._pCCS:getChildByName("ListBg")
    --排行
    self._pText_1 = self._pListBg:getChildByName("Text_1")
    --家族名称
    self._pText_2 = self._pListBg:getChildByName("Text_2")
    --族长
    self._pText_3 = self._pListBg:getChildByName("Text_3")
    --家族等级
    self._pText_4 = self._pListBg:getChildByName("Text_4")
    --家族人数
    self._pText_6 = self._pListBg:getChildByName("Text_6")
    --家族成立时间
    self._pText_8 = self._pListBg:getChildByName("Text_8")
end
function HomeRankingsListParams:create()
    local params = HomeRankingsListParams.new()
    return params
end

return HomeRankingsListParams
