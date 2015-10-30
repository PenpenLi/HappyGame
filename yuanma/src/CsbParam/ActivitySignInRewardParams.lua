--在线奖励界面界面
local ActivitySignInRewardParams = class("ActivitySignInRewardParams")

function ActivitySignInRewardParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ActivitySignInReward.csb")
	--背景底板
    self._pRewardBg = self._pCCS:getChildByName("RewardBg")
    --奖励图标
    self._pRewardIcon = self._pRewardBg:getChildByName("RewardIcon")
    --签到图标
    self._pSignIn = self._pRewardBg:getChildByName("SignIn")
    --签到完成后对勾图标
    self._pGou = self._pRewardBg:getChildByName("Gou")
    --VIPXX双倍文字底板
    self._pVipDouble = self._pRewardBg:getChildByName("VipDouble")
    --VIPXX双倍文字
    self._pVipDoubleText = self._pVipDouble:getChildByName("VipDoubleText")
    
end

function ActivitySignInRewardParams:create()
    local params = ActivitySignInRewardParams.new()
    return params  
end

return ActivitySignInRewardParams
