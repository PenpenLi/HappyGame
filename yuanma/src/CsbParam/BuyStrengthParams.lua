
local BuyStrengthParams = class("BuyStrengthParams")

function BuyStrengthParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BuyPorT.csb")
	--背景板
    self._pBuyP = self._pCCS:getChildByName("BuyP")
    -- 确定按钮
    self._pYes = self._pBuyP:getChildByName("Yes")	
	-- 取消按钮
    self._pNo = self._pBuyP:getChildByName("No")
	-- 购买体力的节点
    self._pNode_1 = self._pBuyP:getChildByName("Node_1")
    -- 体力恢复的时间间隔
    self._pAutoAddStrengthText = self._pNode_1:getChildByName("Text_P1_2")
    -- 购买一次体力消耗的玉璧数量
    self._pBuyStrengthInfoText = self._pNode_1:getChildByName("Text_P2_2")
    -- 今日体力购买的数量
    self._pBuyStrengthNumText = self._pNode_1:getChildByName("Text_P3_2")
    -- 玉璧不足的节点
    self._pNode_2 = self._pBuyP:getChildByName("Node_2")
    -- 购买战斗次数的节点
    self._pNode_3 = self._pBuyP:getChildByName("Node_3")
    -- 购买战斗次数消耗的玉璧数量
    self._pBuyBattleConstDiamondText = self._pNode_3:getChildByName("Text_P2_2")
    -- 今日购买战斗次数
    self._pBuyBattleNumText = self._pNode_3:getChildByName("Text_P3_2") 
    -- 购买次数不足的节点
    self._pLackBuyNumNode = self._pBuyP:getChildByName("Node_4")
    -- 今日购买次数的文本
    self._pCurBuyNumText = self._pLackBuyNumNode:getChildByName("Text_V1_2")  
end

function BuyStrengthParams:create()
    local params = BuyStrengthParams.new()
    return params  
end
return BuyStrengthParams
