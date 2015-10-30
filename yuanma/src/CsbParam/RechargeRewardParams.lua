--等级奖励界面界面
local RechargeRewardParams = class("RechargeRewardParams")

function RechargeRewardParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RechargeReward.csb")
	--背景底板
    self._pRechargerRewardBg= self._pCCS:getChildByName("RechargerRewardBg")
    --充值数额说明
    self._pMoneyText = self._pRechargerRewardBg:getChildByName("MoneyText")
    -- 奖励图标1
    self._pReward1 = self._pRechargerRewardBg:getChildByName("Reward1")
    -- 奖励1数额
    self._pRewardNum1 = self._pRechargerRewardBg:getChildByName("RewardNum1")
    -- 奖励图标2
    self._pReward2 = self._pRechargerRewardBg:getChildByName("Reward2")
    -- 奖励2数额
    self._pRewardNum2= self._pRechargerRewardBg:getChildByName("RewardNum2")
    -- 奖励图标3
    self._pReward3 = self._pRechargerRewardBg:getChildByName("Reward3")
    -- 奖励3数额
    self._pRewardNum3 = self._pRechargerRewardBg:getChildByName("RewardNum3")
    -- 进度条底板
    self._pMoneyLoadingBg = self._pRechargerRewardBg:getChildByName("MoneyLoadingBg") 
    -- 进度条
    self._pMoneyLoadingBar = self._pMoneyLoadingBg:getChildByName("MoneyLoadingBar")
    -- 进度数值：当前值/上限
    self._pMoneyNow = self._pRechargerRewardBg:getChildByName("MoneyNow") 
    -- 领取按钮
    self._pYesButton = self._pRechargerRewardBg:getChildByName("YesButton")
    -- 已领取美术字
    self._pReceived = self._pRechargerRewardBg:getChildByName("Received")
    

      
end

function RechargeRewardParams:create()
    local params = RechargeRewardParams.new()
    return params  
end

return RechargeRewardParams
