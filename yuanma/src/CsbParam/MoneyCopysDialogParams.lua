--副本界面
local MoneyCopysDialogParams = class("MoneyCopysDialogParams")

function MoneyCopysDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("MoneyCopysDialog.csb")

	-- 底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    
    --滚动框
    self._pBgScrollView = self._pBackGround:getChildByName("BgScrollView")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    
    --体力值进度条底框
    self._pPowerBarBg = self._pBackGround:getChildByName("PowerBarBg")
    --体力值进度条
    self._pPowerBar = self._pPowerBarBg:getChildByName("PowerBar")
    --体力值按钮
    self._pBuyButton = self._pBackGround:getChildByName("BuyButton")
    --当前体力值
    self._pPowerText1 = self._pBackGround:getChildByName("PowerText1") 
    --总体力值上限
    self._pPowerText2 = self._pBackGround:getChildByName("PowerText2")

    self._pFrameTitle = self._pBackGround:getChildByName("FramTitle")
    self._pFrameTitleText = self._pFrameTitle:getChildByName("FrameTitleText")


end

function MoneyCopysDialogParams:create()
    local params = MoneyCopysDialogParams.new()
    return params  
end

return MoneyCopysDialogParams
