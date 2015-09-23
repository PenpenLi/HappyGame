--爬塔副本战斗中界面
local TowerBattlePanelParams = class("TowerBattlePanelParams")

function TowerBattlePanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("TowerBattlePanel.csb")
	--底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --当前所在关卡数艺术字
    self._pChapterFnt = self._pBackGround:getChildByName("ChapterFnt")
    --当前关卡数小字
    self._pText_3 = self._pBackGround:getChildByName("Text_3")
    --总关卡数
    self._pText_4 = self._pBackGround:getChildByName("Text_4")
    --获得的物品ScrollView
    self._pGetItemsScrollView = self._pBackGround:getChildByName("ItemScrollView")
end

function TowerBattlePanelParams:create()
    local params = TowerBattlePanelParams.new()
    return params  
end

return TowerBattlePanelParams
