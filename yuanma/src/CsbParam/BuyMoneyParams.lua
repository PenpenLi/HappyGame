--购买铜钱界面
local BuyMoneyParams = class("BuyMoneyParams")

function BuyMoneyParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BuyMoney.csb")
	--背景板
    self._pBuyBg = self._pCCS:getChildByName("BuyBg")
    --按钮
    self._pYes = self._pBuyBg:getChildByName("Yes")	
	self._pNo = self._pBuyBg:getChildByName("No")
	self._pYes_Copy = self._pBuyBg:getChildByName("Yes_Copy")
	--文本节点
    self._pNode_1 = self._pBuyBg:getChildByName("Node_1")
    --文本
    self._pText_P2_2 = self._pNode_1:getChildByName("Text_P2_2")
    self._pText_P3_1 = self._pNode_1:getChildByName("Text_P3_1")
    self._pText_P3_2 = self._pNode_1:getChildByName("Text_P3_2")

    --文本节点
    self._pNode_2 = self._pBuyBg:getChildByName("Node_2")
    --文本
    self._pText_P4 = self._pNode_1:getChildByName("Text_P4")
    
    
end
function BuyMoneyParams:create()
    local params = BuyMoneyParams.new()
    return params  
end
return BuyMoneyParams
