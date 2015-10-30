--装备相关的大底板
local EqiupRightDialogParams = class("EqiupRightDialogParams")

function EqiupRightDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("EqiupRightDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --标题底板
    self._pFrameTitle = self._pBackGround:getChildByName("FrameTitle")
    
    --标题文字
    self._pEqiupText = self._pBackGround:getChildByName("EqiupText")
    self._pEqiupText:setTextColor(cFontFrameTitle)




    --左侧板挂点
    self._pHangingPoint = self._pBackGround:getChildByName("HangingPoint")
    --右侧小底板
    self._pEqiupRightFrame = self._pBackGround:getChildByName("EqiupRightFrame")
    --滚动框
    self._pRightScrollView = self._pEqiupRightFrame:getChildByName("RightScrollView")
   
    --分解标签
    self._pTabButton1 = self._pBackGround:getChildByName("TabButton1")
    --强化标签
    self._pTabButton2 = self._pBackGround:getChildByName("TabButton2")
    --镶嵌标签
    self._pTabButton3 = self._pBackGround:getChildByName("TabButton3")
    --合成标签
    self._pTabButton4 = self._pBackGround:getChildByName("TabButton4")
    --洗练标签
    self._pTabButton5 = self._pBackGround:getChildByName("TabButton5")
    --传承标签
    self._pTabButton6 = self._pBackGround:getChildByName("TabButton6")
    --锻造标签
    self._pTabButton7 = self._pBackGround:getChildByName("TabButton7")
    --三个标签的节点
    self._pThreePoint =  self._pBackGround:getChildByName("ThreePoint")
    --身上的
    self._pBagTabButton1 = self._pThreePoint:getChildByName("BagTabButton1")
    --背包里的
    self._pBagTabButton2 = self._pThreePoint:getChildByName("BagTabButton2")
    --宝石的
    self._pBagTabButton3 = self._pThreePoint:getChildByName("BagTabButton3")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton") 
     --金币数量底板
    self._pGoldBg = self._pBackGround:getChildByName("MoneyBg1")
    --金币数量
    self._pGoldNumber = self._pGoldBg:getChildByName("Money_Number1") 
 
    --金币数量增加按钮
    self._pGoldAdd = self._pGoldBg:getChildByName("MoneyAdd1") 
    --钻石数量底板
    self._pMoneyBg = self._pBackGround:getChildByName("MoneyBg2")
    --钻石数量
    self._pMoneyNumber = self._pMoneyBg:getChildByName("Money_Number2") 

    --钻石数量增加按钮
    self._pMoneyAdd = self._pMoneyBg:getChildByName("MoneyAdd2") 
end

function EqiupRightDialogParams:create()
    local params = EqiupRightDialogParams.new()
    return params
end

return EqiupRightDialogParams
