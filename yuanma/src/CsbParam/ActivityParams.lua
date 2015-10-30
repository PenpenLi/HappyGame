--家园当前未激活的buff
local ActivityParams = class("ActivityParams")

function ActivityParams:ctor()
    self._pCCS = cc.CSLoader:createNode("Activity.csb")
	--背景板(可点击)
    self._pActivityBgButton = self._pCCS:getChildByName("ActivityBgButton")
    --图标底板
    self._pIconbase= self._pActivityBgButton:getChildByName("Iconbase")	
    --活动图标
	self._pActivityIcon = self._pActivityBgButton:getChildByName("ActivityIcon")
	--活动时间
    self._pActivityTime = self._pActivityBgButton:getChildByName("ActivityTime")
    --今日次数
    self._pTimes = self._pActivityBgButton:getChildByName("Times")
    --活动说明
    self._pInstructionText = self._pActivityBgButton:getChildByName("InstructionText")
    --奖励图标槽
    self._pRewardIconBg = self._pActivityBgButton:getChildByName("RewardIconBg")
    --品质框
    self._pPinZhi = self._pRewardIconBg:getChildByName("PinZhi")
    --奖励图标
    self._pRewardIcon = self._pRewardIconBg:getChildByName("RewardIcon")
    --前往按钮
    self._pGoButton = self._pActivityBgButton:getChildByName("GoButton")
    
end
function ActivityParams:create()
    local params = ActivityParams.new()
    return params  
end
return ActivityParams
