--家园当前未激活的buff
local BuyPorTParams = class("BuyPorTParams")

function BuyPorTParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BuyPorT.csb")
	--背景板
    self._pBuyP = self._pCCS:getChildByName("BuyP")
    --按钮
    self._pYes = self._pBuyP:getChildByName("Yes")	
	self._pNo = self._pBuyP:getChildByName("No")
	--文本节点
    self._pNode_1 = self._pBuyP:getChildByName("Node_1")
    --文本
    self._pText_P1_1 = self._pNode_1:getChildByName("Text_P1_1")
    self._pText_P1_2 = self._pNode_1:getChildByName("Text_P1_2")
    self._pText_P1_3 = self._pNode_1:getChildByName("Text_P1_3")
    self._pText_P2_1 = self._pNode_1:getChildByName("Text_P2_1")
    self._pText_P2_2 = self._pNode_1:getChildByName("Text_P2_2")
    self._pText_P2_3 = self._pNode_1:getChildByName("Text_P2_3")
    self._pText_P2_4 = self._pNode_1:getChildByName("Text_P2_4")
    self._pText_P2_5 = self._pNode_1:getChildByName("Text_P2_5")
    self._pText_P3_1 = self._pNode_1:getChildByName("Text_P3_1")
    self._pText_P3_2 = self._pNode_1:getChildByName("Text_P3_2")
    --文本节点
    self._pNode_2 = self._pBuyP:getChildByName("Node_2")
    --文本
    self._pText_P1_1 = self._pNode_2:getChildByName("Text_P1_1")
    self._pText_P2_1 = self._pNode_2:getChildByName("Text_P2_1")

    --文本节点
    self._pNode_3 = self._pBuyP:getChildByName("Node_3")
    --文本
    self._pText_P1_1 = self._pNode_3:getChildByName("Text_P1_1")
    self._pText_P2_1 = self._pNode_3:getChildByName("Text_P2_1")
    self._pText_P2_2 = self._pNode_3:getChildByName("Text_P2_2")
    self._pText_P2_3 = self._pNode_3:getChildByName("Text_P2_3")
    self._pText_P3_1 = self._pNode_3:getChildByName("Text_P3_1")
    self._pText_P3_2 = self._pNode_3:getChildByName("Text_P3_2")
   
    
end
function BuyPorTParams:create()
    local params = BuyPorTParams.new()
    return params  
end
return BuyPorTParams
