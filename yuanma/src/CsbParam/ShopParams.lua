--游戏的战斗界面
local ShopParams = class("ShopParams")

function ShopParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ShopUI.csb")

	--背景板
    self._pbackground = self._pCCS:getChildByName("background")
	--顶排按钮那个节点
    self._pNodebutton = self._pCCS:getChildByName("Nodebutton")
    --热销按钮
    self._pbutton01 = self._pNodebutton:getChildByName("button01")    
    --关闭按钮
    self._pbuttonclose = self._pNodebutton:getChildByName("buttonclose")
    --横向滚动框
    self._pscrollview01 = self._pCCS:getChildByName("scrollview01")
    
    --底边那个节点
    self._pNodebuy = self._pCCS:getChildByName("Nodebuy")
    --货币显示框
    self._pcurrencybackground = self._pNodebuy:getChildByName("currencybackground")
    --货币icon
    self._pcurrencyicon = self._pNodebuy:getChildByName("currencyicon")
    --货币金额
    self._pmoney = self._pNodebuy:getChildByName("money")
	--充值按钮
    self._pbuttonrecharge = self._pNodebuy:getChildByName("buttonrecharge")
    
end

function ShopParams:create()
    local params = ShopParams.new()
    return params  
end

return ShopParams
