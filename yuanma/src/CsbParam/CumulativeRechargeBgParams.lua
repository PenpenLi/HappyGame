--等级奖励界面界面
local CumulativeRechargeBgParams = class("CumulativeRechargeBgParams")

function CumulativeRechargeBgParams:ctor()
    self._pCCS = cc.CSLoader:createNode("CumulativeRechargeBg.csb")
	--背景底板
    self._pRightBg= self._pCCS:getChildByName("RightBg")
    --累计充值说明底板
    self._pRechargeBg = self._pRightBg:getChildByName("RechargeBg")
    -- 说明
    self._pIntroductionText = self._pRechargeBg:getChildByName("IntroductionText")
    -- 活动时间
    self._pTimeText = self._pRechargeBg:getChildByName("TimeText")
    -- 前往充值按钮
    self._pRechargeButton = self._pRechargeBg:getChildByName("RechargeButton")
    -- 滚动条
    self._pRechargeScrollView= self._pRightBg:getChildByName("RechargeScrollView")
 
 
      
end

function CumulativeRechargeBgParams:create()
    local params = CumulativeRechargeBgParams.new()
    return params  
end

return CumulativeRechargeBgParams
