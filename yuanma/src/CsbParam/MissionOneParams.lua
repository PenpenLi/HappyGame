--游戏的战斗界面
local MissionOneParams = class("MissionOneParams")

function MissionOneParams:ctor()
    self._pCCS = cc.CSLoader:createNode("MissionOne.csb")

	--背景板
    self._pOneBg = self._pCCS:getChildByName("OneBg")
	--任务icon
    self._picon = self._pOneBg:getChildByName("icon")
    --任务名称
    self._pname = self._pOneBg:getChildByName("name")
    --任务目标1
    self._ptarget1 = self._pOneBg:getChildByName("target1")
    --任务目标2
    self._ptarget2 = self._pOneBg:getChildByName("target2")
    --任务目标3
    self._ptarget3 = self._pOneBg:getChildByName("target3")
    --任务奖励
    self._paward = self._pOneBg:getChildByName("award")
    --完成进度（文字）
    self._ploadingtext = self._pOneBg:getChildByName("loadingtext")
    --完成进度进度条
    self._pLoadingBar = self._pOneBg:getChildByName("LoadingBar")
    --完成进度进度条黑框
    self._pLoadingBarBack = self._pOneBg:getChildByName("LoadingBarBack")
    --奖励icon01
    self._pawardicon01 = self._pOneBg:getChildByName("awardicon01")
    --奖励icon02
    self._pawardicon02 = self._pOneBg:getChildByName("awardicon02")
    --奖励icon03
    self._pawardicon03 = self._pOneBg:getChildByName("awardicon03")
    --奖励icon04
    self._pawardicon04 = self._pOneBg:getChildByName("awardicon04")
     --奖励icon05
    self._pawardicon05 = self._pOneBg:getChildByName("awardicon05")
    --奖励icon04
    self._pawardicon06 = self._pOneBg:getChildByName("awardicon06")
    

    --奖励1的数量
    self._pawardtext01 = self._pOneBg:getChildByName("awardtext01")
    --奖励2的数量
    self._pawardtext02 = self._pOneBg:getChildByName("awardtext02")
    --奖励3的数量
    self._pawardtext03 = self._pOneBg:getChildByName("awardtext03")
    --奖励4的数量
    self._pawardtext04 = self._pOneBg:getChildByName("awardtext04")
    --奖励5的数量
    self._pawardtext05 = self._pOneBg:getChildByName("awardtext05")
    --奖励6的数量
    self._pawardtext06 = self._pOneBg:getChildByName("awardtext06")
    --领取奖励按钮
    self._pGoButton01 = self._pOneBg:getChildByName("GoButton01")
    --前往按钮
    self._pGoButton02 = self._pOneBg:getChildByName("GoButton02")
    --完成角标
    self._pfinish = self._pOneBg:getChildByName("finish")



    
end

function MissionOneParams:create()
    local params = MissionOneParams.new()
    return params  
end

return MissionOneParams
