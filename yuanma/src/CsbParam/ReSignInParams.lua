--在线奖励界面界面
local ReSignInParams = class("ReSignInParams")

function ReSignInParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ReSignIn.csb")
	--背景底板
    self._pReSignInBg = self._pCCS:getChildByName("ReSignInBg")
    --关闭按钮
    self._pCloseButton = self._pReSignInBg:getChildByName("CloseButton")
    --补签次数文本
    self._pReSignInText = self._pReSignInBg:getChildByName("ReSignInText")
    --补签一次按钮
    self._pOneTimeButton = self._pReSignInBg:getChildByName("OneTimeButton")
    --全部补签按钮
    self._pAllTimeButton = self._pReSignInBg:getChildByName("AllTimeButton")
    --玉璧图标
    self._pMoneyIcon1 = self._pReSignInBg:getChildByName("MoneyIcon1")
    self._pMoneyIcon2 = self._pReSignInBg:getChildByName("MoneyIcon2")
    --补签一次花费玉璧数量
    self._pOneTimeText = self._pReSignInBg:getChildByName("OneTimeText")
    --全部补签花费玉璧数量
    self._pAllTimeText = self._pReSignInBg:getChildByName("AllTimeText")


    
end

function ReSignInParams:create()
    local params = ReSignInParams.new()
    return params  
end

return ReSignInParams
