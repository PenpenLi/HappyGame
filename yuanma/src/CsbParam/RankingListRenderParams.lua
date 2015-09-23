--排行榜具体排行板子
local RankingListRenderParams = class("RankingListRenderParams")

function RankingListRenderParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RankingListRender.csb")
    --具体信息底板
    self._pListBg = self._pCCS:getChildByName("ListBg")
    --排行
    self._pText1 = self._pCCS:getChildByName("Text_1")
    --昵称
	self._pText2 = self._pCCS:getChildByName("Text_2")
    --等级
    self._pText3 = self._pCCS:getChildByName("Text_3")
    --职业
    self._pText4 = self._pCCS:getChildByName("Text_4")
    --战斗力
    self._pText5 = self._pCCS:getChildByName("Text_5")
 
end

function RankingListRenderParams:create()
    local params = RankingListRenderParams.new()
    return params
end

return RankingListRenderParams
