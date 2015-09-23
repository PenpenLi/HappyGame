--背包界面
local BagPanelParams = class("BagPanelParams")

function BagPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BagPanel.csb")
    self._pBagFramePoint = self._pCCS:getChildByName("BagFramePoint")
    --背包界面底板
    self._pBagBg = self._pBagFramePoint:getChildByName("BagBg")
    --全部标签
    self._pTabButton01 = self._pBagFramePoint:getChildByName("TabButton01")
    --装备标签
    self._pTabButton02 = self._pBagFramePoint:getChildByName("TabButton02")
    --宝石标签
    self._pTabButton03 = self._pBagFramePoint:getChildByName("TabButton03")
    --道具标签
    self._pTabButton04 = self._pBagFramePoint:getChildByName("TabButton04")
    --整理按钮
    self._pCleanUpButton = self._pBagBg:getChildByName("CleanUpButton")
    --OneKeySell按钮
    self._pOneKeySell = self._pBagBg:getChildByName("OneKeySell")
    --金币图标
    self._pMoneyIcon = self._pBagBg:getChildByName("MoneyIcon")
    --金币文本底框
    self._pMoneyBg = self._pBagBg:getChildByName("MoneyBg")
    --金币数量
    self._pMoneyNum = self._pBagBg:getChildByName("MoneyNum")
    --RMB图标
    self._pRmbIcon = self._pBagBg:getChildByName("RmbIcon")
    --RMB文本底框
    self._pMoneyBg = self._pBagBg:getChildByName("MoneyBg")
    --RMB数量
    self._pRmbNum = self._pBagBg:getChildByName("RmbNum")
    --滚动框
    self._pBagScrollView = self._pBagBg:getChildByName("BagScrollView")
    --向上箭头
end

function BagPanelParams:create()
    local params = BagPanelParams.new()
    return params
end

return BagPanelParams
