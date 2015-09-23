--游戏的战斗界面
local FightRevivedParams = class("FightRevivedParams")

function FightRevivedParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FightRevived.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --取消按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --立即复活按钮
    self._pSureButton = self._pBackGround:getChildByName("SureButton")
    --标题文字
    self._pText00 = self._pBackGround:getChildByName("Text00")
    --倒计时进度条
    self._pLoadingBar = self._pBackGround:getChildByName("LoadingBar")
    --倒计时进度条黑底
    self._pLoadingBarBack = self._pBackGround:getChildByName("LoadingBarBack")
    --节点01，用于显示有“免费复活次数”时的全部文字内容
    self._pNode01 = self._pBackGround:getChildByName("Node01")
    --文字0101 今日免费复活次数
    self._pText0101 = self._pNode01:getChildByName("Text0101")
    --文字0102 免费复活次数（具体次数）
    self._pText0102 = self._pNode01:getChildByName("Text0102")
    --节点02，用于显示无“免费复活次数”时的全部文字内容
    self._pNode02 = self._pBackGround:getChildByName("Node02")
    --文字0201 今日免费复活次数已用完
    self._pText0201 = self._pNode02:getChildByName("Text0201")
    --文字0202 复活花费
    self._pText0202 = self._pNode02:getChildByName("Text0202")
    --文字0203 复活花费（具体货币数值）
    self._pText0203 = self._pNode02:getChildByName("Text0203")
    --货币icon
    self._picon = self._pText0203:getChildByName("icon")

    
end

function FightRevivedParams:create()
    local params = FightRevivedParams.new()
    return params  
end

return FightRevivedParams
