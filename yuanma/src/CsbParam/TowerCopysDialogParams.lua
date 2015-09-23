--爬塔副本界面
local TowerCopysDialogParams = class("TowerCopysDialogParams")

function TowerCopysDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("TowerCopysDialog.csb")
	--底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --上一页按钮
    self._pCPreviousButton = self._pBackGround:getChildByName("PreviousButton")
    --下一页按钮
    self._pNextButton = self._pBackGround:getChildByName("NextButton")
    --滚动框
    self._pTowerPageView = self._pBackGround:getChildByName("TowerPageView")
    --说明板子
    self._pIllustrateBg = self._pBackGround:getChildByName("IllustrateBg")
    --说明当前所在层数数值
    self._pSmText2Num= self._pIllustrateBg:getChildByName("SmText2Num")
    --通关奖滚动框
    self._pScrollView= self._pIllustrateBg:getChildByName("ScrollView")
    --挑战按钮
    self._pBattleButton= self._pIllustrateBg:getChildByName("BattleButton")
    --塔名称图片
    self._pTowerName = self._pBackGround:getChildByName("TowerName")
    --挑战剩余次数
    self._pChallengeNum1= self._pIllustrateBg:getChildByName("ChallengeNum1")
    --挑战总次数
    self._pChallengeNum2= self._pIllustrateBg:getChildByName("ChallengeNum2")
end

function TowerCopysDialogParams:create()
    local params = TowerCopysDialogParams.new()
    return params  
end

return TowerCopysDialogParams
