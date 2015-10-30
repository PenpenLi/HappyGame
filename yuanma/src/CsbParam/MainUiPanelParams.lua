--主界面
local MainUiPanelParams = class("MainUiPanelParams")
function MainUiPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("MainUiPanel.csb")
    --头像节点
    self._pHeadPoint = self._pCCS:getChildByName("HeadPoint")
    --头像底框
    self._pHeadIconFrame = self._pHeadPoint:getChildByName("HeadIconFrame")
    --角色头像按钮
    self._pJsButton = self._pHeadIconFrame:getChildByName("JsButton")
    --vip图标
    self._pVipImage = self._pHeadPoint:getChildByName("VipImage")
    -- vip 等级文字
    self._pBitmapFontLabel_2 = self._pVipImage:getChildByName("BitmapFontLabel_2")
    --等级文字
    self._pLvText = self._pHeadPoint:getChildByName("LvText")
    --昵称文字
    self._pNameText = self._pHeadPoint:getChildByName("NameText")
    --战斗力艺术字
    self._pEffectiveImage = self._pHeadPoint:getChildByName("EffectiveImage")
    --战斗力数值
    self._pEffectiveText = self._pHeadPoint:getChildByName("EffectiveText")
    --体力值
    self._pBarBg = self._pHeadPoint:getChildByName("BarBg")
    --体力值文字
    self._pPowerText = self._pHeadPoint:getChildByName("PowerText")
    --购买体力值按钮
    self._pBuyButton1 = self._pHeadPoint:getChildByName("BuyButton1")
    --体力底板
    self._pBarBg = self._pHeadPoint:getChildByName("BarBg")
    --体力进度条
    self._pBar = self._pBarBg:getChildByName("Bar")
    --金币底板
    self._pMoneyBg1 = self._pHeadPoint:getChildByName("MoneyBg1")
    --购买金币按钮
    self._pBuyButton2 = self._pHeadPoint:getChildByName("BuyButton2")
    --金币数值
    self._pMoneyText = self._pHeadPoint:getChildByName("MoneyText")
    --rmb底板
    self._pMoneyBg2 = self._pHeadPoint:getChildByName("MoneyBg2")
    --rmb购买按钮
    self._pBuyButton3 = self._pHeadPoint:getChildByName("BuyButton3")
    --rmb数值
    self._pRmbText = self._pHeadPoint:getChildByName("RmbText")
    --活动按钮节点
    self._pActivityPoint = self._pCCS:getChildByName("ActivityPoint")
    --活动收缩展开按钮
    self._pActivityButton = self._pActivityPoint:getChildByName("ActivityButton")
    --活动按钮滚动框
    self._pActivityScrollView = self._pActivityPoint:getChildByName("ActivityScrollView")
    --功能按钮节点
    self._pFunctionPoint = self._pCCS:getChildByName("FunctionPoint")
    --功能收缩展开按钮
    self._pFunctionButton = self._pFunctionPoint:getChildByName("FunctionButton")
    --功能水平滚动框
    self._pFunctionScrollView1 = self._pFunctionPoint:getChildByName("FunctionScrollView1")
    --功能垂直滚动框
    self._pFunctionScrollView2 = self._pFunctionPoint:getChildByName("FunctionScrollView2")
    --经验条节点
    self._pExpPoint = self._pCCS:getChildByName("ExpPoint")
    --经验条底板
    self._pExpBarBg = self._pExpPoint:getChildByName("ExpBarBg")
    --经验条
    self._pExpBar = self._pExpBarBg:getChildByName("ExpBar")
    --经验条分割线
    self._pExpOver = self._pExpBarBg:getChildByName("ExpOver")
    --经验条文字
    self._pExpText = self._pExpPoint:getChildByName("ExpText")
end

function MainUiPanelParams:create()
    local params = MainUiPanelParams.new()
    return params
end

return MainUiPanelParams
