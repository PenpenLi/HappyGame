local BelleTipsParams = class("BelleTipsParams")

--右侧美人图镶嵌信息
function BelleTipsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BelleTips.csb")
    --大底板
    self._pTipsBg = self._pCCS:getChildByName("TipsBg")
    --关闭按钮
    self._pCloseButton = self._pTipsBg:getChildByName("CloseButton")
    --标题名称
    self._pName = self._pTipsBg:getChildByName("BeautyNameText")
    -- 属性1节点
    self._pPropNode1 = self._pTipsBg:getChildByName("propNode1")
    -- 属性2节点
    self._pPropNode2 = self._pTipsBg:getChildByName("propNode2")
    -- 属性3节点
    self._pPropNode3 = self._pTipsBg:getChildByName("propNode3")
    -- 美人1加成比
    self._pAddPercentNode1 = self._pTipsBg:getChildByName("addPercentNode1")
    -- 美人2加成比
    self._pAddPercentNode2 = self._pTipsBg:getChildByName("addPercentNode2")
    -- 美人3加成比
    self._pAddPercentNode3 = self._pTipsBg:getChildByName("addPercentNode3")
    -- 美人4加成比
    self._pAddPercentNode4 = self._pTipsBg:getChildByName("addPercentNode4")
    -- 美人5加成比
    self._pAddPercentNode5 = self._pTipsBg:getChildByName("addPercentNode5")
    -- 总加成比
    self._pAddPercentNode6 = self._pTipsBg:getChildByName("addPercentNode6")
   
end

function BelleTipsParams:create()
    local params = BelleTipsParams.new()
    return params
end

return BelleTipsParams
