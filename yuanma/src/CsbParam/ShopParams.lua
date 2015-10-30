--游戏的商城界面
local ShopParams = class("ShopParams")

function ShopParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ShopUI.csb")

	--背景板
    self._pbackground = self._pCCS:getChildByName("background")
	--顶排按钮那个节点
    self._pNodebutton = self._pCCS:getChildByName("Nodebutton")
    --热销按钮(共6个，按下时变为白色)
    self._pbutton01 = self._pNodebutton:getChildByName("button01")
    --关闭按钮
    self._pbuttonclose = self._pNodebutton:getChildByName("buttonclose")
    --滚动容器
    self._pscrollview01 = self._pCCS:getChildByName("scrollview01")
    
    --玉璧那个节点
    self._pNodebuy = self._pCCS:getChildByName("Nodebuy")
  
    --货币显示框02
    self._pcurrencybackground02 = self._pNodebuy:getChildByName("currencybackground02")
    --货币icon02
    self._pcurrencyicon02 = self._pNodebuy:getChildByName("currencyicon02")
    --货币金额02
    self._pmoney02 = self._pNodebuy:getChildByName("money02")
    --充值按钮 加玉璧
    self._pbuttonrecharge02 = self._pNodebuy:getChildByName("buttonrecharge02")

    --控件颜色
    self._pbutton01:getTitleRenderer():setTextColor(cFontDarkRed)



    
end

function ShopParams:create()
    local params = ShopParams.new()
    return params  
end

return ShopParams
