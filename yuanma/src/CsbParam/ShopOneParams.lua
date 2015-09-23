--游戏的战斗界面
local ShopOneParams = class("ShopOneParams")

function ShopOneParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ShopOne.csb")

	--背景板
    self._pitemCellBg = self._pCCS:getChildByName("itemCellBg")
	--核心节点
    self._pNodeBG = self._pCCS:getChildByName("NodeBG")
    --商品Icon品质框
    self._picon01P = self._pNodeBG:getChildByName("icon01P")
     --商品Icon
    self._picon01 = self._pNodeBG:getChildByName("icon01")
     -- 此商品消耗的Icon
    self._pcosticon = self._pNodeBG:getChildByName("costicon")
    --打折金额01
    self._ptextprice01 = self._pNodeBG:getChildByName("textprice01")
    --实际金额01
    self._ptextprice02 = self._pNodeBG:getChildByName("textprice02")
    --购买按钮01
    self._pbuttonbuy01 = self._pNodeBG:getChildByName("buttonbuy01")
    --热销标签背景
    self._pHotBg = self._pNodeBG:getChildByName("hotback01")
    --热销标签01
    self._phot01 = self._pNodeBG:getChildByName("hot01")
    --商品名称
    self._pname01 = self._pNodeBG:getChildByName("name01")       
    -- 消耗货币的图标
    self._pFinaceIcon = self._pNodeBG:getChildByName("costicon") 
    
end

function ShopOneParams:create()
    local params = ShopOneParams.new()
    return params  
end

return ShopOneParams
