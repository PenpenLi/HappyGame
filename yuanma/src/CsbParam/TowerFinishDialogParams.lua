--爬塔结算界面
local TowerFinishDialogParams = class("TowerFinishDialogParams")

function TowerFinishDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("TowerFinishDialog.csb")
	-- 获得物品底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")  
    --确定按钮
     self._pOkButton = self._pBackGround:getChildByName("OkButton")
    --奖励滚动框
    self._pScrollView = self._pBackGround:getChildByName("ScrollView")
    --经验值挂点
    self._pExpNode = self._pBackGround:getChildByName("ExpNode")
    --经验值图标
    self._pExpIcon = self._pExpNode:getChildByName("ExpIcon")
    --经验值
    self._pExpTextNum = self._pExpNode:getChildByName("ExpTextNum")
    --金钱挂点
    self._pMoneyNode = self._pBackGround:getChildByName("MoneyNode")
    --金钱值
    self._pMoneyTextNum = self._pMoneyNode:getChildByName("MoneyTextNum")
    --金钱图标
    self._pMoneyIcon = self._pMoneyNode:getChildByName("MoneyIcon")
    --RMB挂点
    self._pRmbNode = self._pBackGround:getChildByName("RmbNode")
    --RMB值
    self._pRmbTextNum = self._pRmbNode:getChildByName("RmbTextNum")
    --RMB图标
    self._pRmbIcon = self._pRmbNode:getChildByName("RmbIcon")
    --斗魂挂点
    self._pToukonNode = self._pBackGround:getChildByName("ToukonNode")
    --斗魂值
    self._pToukonTextNum = self._pToukonNode:getChildByName("ToukonTextNum")
    --斗魂图标
    self._pToukonIcon = self._pToukonNode:getChildByName("ToukonIcon")
    --等级文字
    self._pLvText = self._pBackGround:getChildByName("LvText")
    --经验条底板
    self._pExpBg = self._pBackGround:getChildByName("ExpBg")
    --经验条挂点
    self._pExpBarNode = self._pBackGround:getChildByName("ExpBarNode")

end

function TowerFinishDialogParams:create()
    local params = TowerFinishDialogParams.new()
    return params  
end

return TowerFinishDialogParams
