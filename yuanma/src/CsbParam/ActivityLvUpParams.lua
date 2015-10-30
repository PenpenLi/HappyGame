--等级奖励界面界面
local ActivityLvUpParams = class("ActivityLvUpParams")

function ActivityLvUpParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ActivityLvUp.csb")
	--背景底板
    self._pOnLineBg = self._pCCS:getChildByName("OnLineBg")
    --领取按钮
    self._pOkButton = self._pOnLineBg:getChildByName("OkButton")
    -- 奖励背景1
    self._pRewardBg1 = self._pOnLineBg:getChildByName("RewardBg1")
    --奖励图标1
    self._pRewardIcon1 = self._pOnLineBg:getChildByName("RewardIcon1")
    --奖励数值1
    self._pRewardNum1 = self._pOnLineBg:getChildByName("RewardNum1")
    -- 奖励背景2
    self._pRewardBg2 = self._pOnLineBg:getChildByName("RewardBg2")
    --奖励图标2
    self._pRewardIcon2 = self._pOnLineBg:getChildByName("RewardIcon2")
    --奖励数值2
    self._pRewardNum2 = self._pOnLineBg:getChildByName("RewardNum2")
    -- 奖励背景3
    self._pRewardBg3 = self._pOnLineBg:getChildByName("RewardBg3")
    --奖励图标3
    self._pRewardIcon3 = self._pOnLineBg:getChildByName("RewardIcon3")
    --奖励数值3
    self._pRewardNum3 = self._pOnLineBg:getChildByName("RewardNum3")
    --已领取图标
    self._pYlqPic = self._pOnLineBg:getChildByName("YlqPic")
    --提示红点图标
    self._pTiShiPic = self._pOnLineBg:getChildByName("TiShiPic")
    --等级信息
    self._pLevelText = self._pOnLineBg:getChildByName("LvText1")
end

function ActivityLvUpParams:create()
    local params = ActivityLvUpParams.new()
    return params  
end

return ActivityLvUpParams
