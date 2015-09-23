local BeautyClubParams = class("BeautyClubParams")
--群芳阁大框架截面
function BeautyClubParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BeautyClub.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --右侧小底板
    self._pRightFrameBg = self._pBackGround:getChildByName("RightFrameBg")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --美人大图挂点
    self._pBelleBigNode = self._pRightFrameBg:getChildByName("BelleBigNode")
    --金钱底板
    self._pMoneyBg = self._pBackGround:getChildByName("MoneyBg")
    --金钱数值
    self._pMoneyNumText = self._pMoneyBg:getChildByName("MoneyNumText")
    -- 金钱图标
    self._pcurrencyicon = self._pMoneyBg:getChildByName("MoneyIcon")
    --左侧获得美人图列表滚动框
    self._pLeftScrollView = self._pBackGround:getChildByName("LeftScrollView")
    --右侧镶嵌美人图列表滚动框
    self._pRightLeftScrollView = self._pRightFrameBg:getChildByName("RightLeftScrollView") 
end
function BeautyClubParams:create()
    local params = BeautyClubParams.new()
    return params
end

return BeautyClubParams
