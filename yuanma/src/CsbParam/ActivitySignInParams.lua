--在线奖励界面界面
local ActivitySignInParams = class("ActivitySignInParams")

function ActivitySignInParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ActivitySignIn.csb")


    --背景底板
    self._pRightBg = self._pCCS:getChildByName("RightBg")
	--说明底板背景
    self._pSingInBg = self._pRightBg:getChildByName("SingInBg")
    --滚动框
    self._pSiScrollView = self._pCCS:getChildByName("SiScrollView")

    --签到月份
    self._pMoonText = self._pSingInBg:getChildByName("MoonText")
    --累计签到天数
    self._pLeijiText = self._pSingInBg:getChildByName("LeijiText")
    --补签按钮
    self._pButton_5 = self._pSingInBg:getChildByName("Button_5")
    
end

function ActivitySignInParams:create()
    local params = ActivitySignInParams.new()
    return params  
end

return ActivitySignInParams
