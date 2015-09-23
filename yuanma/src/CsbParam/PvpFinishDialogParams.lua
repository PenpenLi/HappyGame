--爬塔结算界面
local PvpFinishDialogParams = class("PvpFinishDialogParams")

function PvpFinishDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PvpFinishDialog.csb")
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
    self._pIcon = self._pExpNode:getChildByName("Icon")
    --经验值
    self._pTextNum = self._pExpNode:getChildByName("TextNum")
    --金钱挂点
    self._pMoneyNode = self._pBackGround:getChildByName("MoneyNode")
    --金钱值
    self._pTextNum = self._pMoneyNode:getChildByName("TextNum")
    --金钱图标
    self._pIcon = self._pMoneyNode:getChildByName("Icon")
    --RMB挂点
    self._pRmbNode = self._pBackGround:getChildByName("RmbNode")
    --RMB值
    self._pTextNum = self._pRmbNode:getChildByName("TextNum")
    --RMB图标
    self._pIcon = self._pRmbNode:getChildByName("Icon")
    --斗魂挂点
    self._pToukonNode = self._pBackGround:getChildByName("ToukonNode")
    --斗魂值
    self._pTextNum = self._pToukonNode:getChildByName("TextNum")
    --斗魂图标
    self._pIcon = self._pToukonNode:getChildByName("Icon")
    -- 排名文字 
    self._pTextRankInfo = self._pBackGround:getChildByName("Text")
    --具体排名值
    self._pText2 = self._pBackGround:getChildByName("Text2")
    -- 胜利/失败图标 
    self._pFlagImg = self._pBackGround:getChildByName("ClearanceTitele")

end

function PvpFinishDialogParams:create()
    local params = PvpFinishDialogParams.new()
    return params  
end

return PvpFinishDialogParams
