--游戏的战斗界面
local ShopOneParams = class("ShopOneParams")

function ShopOneParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ShopOne.csb")

	--背景板(这个为了做选中，用butten做的)
    self._pitemCellBg = self._pCCS:getChildByName("itemCellBg")
	--核心节点
    self._pNodeBG = self._pCCS:getChildByName("NodeBG")
    --商品Icon
    self._picon01 = self._pNodeBG:getChildByName("icon01")
    --商品Icon边框
    self._picon01P = self._pNodeBG:getChildByName("icon01P")
    --商品Icon底板背景
    self._picon01BG = self._pNodeBG:getChildByName("icon01BG")
    --货币节点01
    self._pNodeMoney01 = self._pCCS:getChildByName("NodeMoney01")
    -- 打折金额的货币图标
    self._pOriginalCoinIcon = self._pNodeMoney01:getChildByName("Image_6")
    --打折金额01
    self._ptextprice01 = self._pNodeMoney01:getChildByName("textprice01")
    --货币节点02
    self._pNodeMoney02 = self._pCCS:getChildByName("NodeMoney02")
    --此商品消耗的货币的Icon
    self._pcosticon = self._pNodeMoney02:getChildByName("costicon")
    --实际金额01
    self._ptextprice02 = self._pNodeMoney02:getChildByName("textprice02")
    --货币节点03（默认隐藏）
    self._pNodeMoney03 = self._pCCS:getChildByName("NodeMoney03")
    --此商品消耗的货币的Icon（属于货币节点03）
    self._pcosticon02 = self._pNodeMoney03:getChildByName("costicon02")
    --实际金额02（属于货币节点03）
    self._ptextprice03 = self._pNodeMoney03:getChildByName("textprice03")

    --热销标签01
    self._phot01 = self._pNodeBG:getChildByName("hot01")
    --商品名称
    self._pname01 = self._pNodeBG:getChildByName("name01")
    --购买限制标题
    self._pbuytext01 = self._pNodeBG:getChildByName("buytext01")
    --购买限制次数
    self._pbuytext02 = self._pNodeBG:getChildByName("buytext02")   
    --控件颜色
    --text01:getTitleRenderer():setTextColor(cFontDarkRed)
    self._ptextprice01:setTextColor(cFontDarkRed)
    --text02:getTitleRenderer():setTextColor(cFontDarkRed)
    --text03:getTitleRenderer():setTextColor(cFontDarkRed)
    self._pbuytext01:setTextColor(cFontDarkRed)
    self._pbuytext02:setTextColor(cFontDarkRed)






    
end

function ShopOneParams:create()
    local params = ShopOneParams.new()
    return params  
end

return ShopOneParams
