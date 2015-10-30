--首冲翻倍界面
local FirstChargeParams = class("FirstChargeParams")

function FirstChargeParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FirstCharge.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
	--关闭按钮
	self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
	--充值领取按钮
	self._pOkButton = self._pBackGround:getChildByName("OkButton")
    --物品滚动框
    self._pCzScrollView = self._pBackGround:getChildByName("CzScrollView")
    --提示红点
    self._pTsPic = self._pBackGround:getChildByName("TsPic")
	
end

function FirstChargeParams:create()
    local params = FirstChargeParams.new()
    return params  
end

return FirstChargeParams
