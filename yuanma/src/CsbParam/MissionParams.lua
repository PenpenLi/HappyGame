--游戏的战斗界面
local MissionParams = class("MissionParams")

function MissionParams:ctor()
    self._pCCS = cc.CSLoader:createNode("MissionBg.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
	--关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --任务总底板
    self._pmissionBg = self._pBackGround:getChildByName("missionBg")
    --流程任务按钮
    self._pMissionButton1 = self._pmissionBg:getChildByName("MissionButton1")
    --日常任务按钮
    self._pMissionButton2 = self._pmissionBg:getChildByName("MissionButton2")
    --滚动容器
    self._pScrollView = self._pmissionBg:getChildByName("ScrollView")
    --每日活跃奖励总底板
    self._pAwardBg = self._pBackGround:getChildByName("AwardBg")
    --每日活跃进度条
    self._pLoadingBar = self._pAwardBg:getChildByName("LoadingBar")
    --每日活跃进度条黑框
    self._pLoadingBarBack = self._pAwardBg:getChildByName("LoadingBarBack")
    --每日活跃宝箱1
    self._pAwardButton1 = self._pAwardBg:getChildByName("AwardButton1")
    --每日活跃宝箱2
    self._pAwardButton2 = self._pAwardBg:getChildByName("AwardButton2")
    --每日活跃宝箱3
    self._pAwardButton3 = self._pAwardBg:getChildByName("AwardButton3")
    --每日活跃宝箱4
    self._pAwardButton4 = self._pAwardBg:getChildByName("AwardButton4")


    
end

function MissionParams:create()
    local params = MissionParams.new()
    return params  
end

return MissionParams
