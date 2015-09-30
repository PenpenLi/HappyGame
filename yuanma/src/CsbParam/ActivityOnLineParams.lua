--在线奖励界面界面
local ActivityOnLineParams = class("ActivityOnLineParams")

function ActivityOnLineParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ActivityOnLine.csb")
	--背景底板
    self._pOnLineBg = self._pCCS:getChildByName("OnLineBg")
    --需要领取时间
    self._pTimeText1 = self._pOnLineBg:getChildByName("TimeText1")
    --领取时间倒计时
    self._pTimeIng = self._pOnLineBg:getChildByName("TimeIng")
    --领取按钮
    self._pOkButton = self._pOnLineBg:getChildByName("OkButton")
    --奖励图标1
    self._pRewardIcon1 = self._pOnLineBg:getChildByName("RewardIcon1")
    --奖励数值1
    self._pRewardNum1 = self._pOnLineBg:getChildByName("RewardNum1")
    --奖励图标2
    self._pRewardIcon2 = self._pOnLineBg:getChildByName("RewardIcon2")
    --奖励数值2
    self._pRewardNum2 = self._pOnLineBg:getChildByName("RewardNum2")
    --奖励图标3
    self._pRewardIcon3 = self._pOnLineBg:getChildByName("RewardIcon3")
    --奖励数值3
    self._pRewardNum3 = self._pOnLineBg:getChildByName("RewardNum3")
    --已领取图标
    self._pYlqPic = self._pOnLineBg:getChildByName("YlqPic")
    --提示红点图标
    self._pTiShiPic = self._pOnLineBg:getChildByName("TiShiPic")
end

function ActivityOnLineParams:create()
    local params = ActivityOnLineParams.new()
    return params  
end

return ActivityOnLineParams
