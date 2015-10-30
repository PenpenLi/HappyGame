--排行大界面界面
local RankingListDialogParams = class("RankingListDialogParams")

function RankingListDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RankingListDialog.csb")
	--背景底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --左侧底板
    self._pLeftBg = self._pBackGround:getChildByName("LeftBg")
    -- 左侧标签
    self._pLeftScrollView = self._pLeftBg:getChildByName("ScrollView_3")
    --排行按钮
    self._pRankingButton1 = self._pLeftScrollView:getChildByName("RankingButton1")
    --右侧底板
    self._pRightBg = self._pBackGround:getChildByName("RightBg")
    --右侧界面挂点
    self._pOnLineNode = self._pRightBg:getChildByName("OnLineNode")
    --排行具体内容滚动框
    self._pListScrollView = self._pOnLineNode:getChildByName("ListScrollView")

    --排行字段底板
	self._pTitleBg = self._pBackGround:getChildByName("TitleBg")
    --排行字段1
    self._pText_1 = self._pTitleBg:getChildByName("Text_1")
    --排行字段2
    self._pText_2 = self._pTitleBg:getChildByName("Text_2")
    --排行字段3
    self._pText_3 = self._pTitleBg:getChildByName("Text_3")
    --排行字段4
    self._pText_4 = self._pTitleBg:getChildByName("Text_4")
    --自己的排行榜底板
    self._pOwnTitleBg = self._pBackGround:getChildByName("OwnTitleBg")
    --我的排行
    self._pText2 = self._pOwnTitleBg:getChildByName("Text2")
    
end

function RankingListDialogParams:create()
    local params = RankingListDialogParams.new()
    return params  
end

return RankingListDialogParams
