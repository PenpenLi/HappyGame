local BladeSoulQueuePanelParams = class("BladeSoulQueuePanelParams")
--炼化剑灵小板子
function BladeSoulQueuePanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BladeSoulQueuePanel.csb")
    --背景板子
    self._pBack = self._pCCS:getChildByName("back")
    --大图标
    self._pIcon = self._pBack:getChildByName("Icon")
    
    --加速按钮
    self._pSpeedButton = self._pBack:getChildByName("SpeedButton")
    --收取按钮
    self._pCollectButton = self._pBack:getChildByName("CollectButton")
    --取消按钮
    self._pCancelButtom = self._pBack:getChildByName("CancelButtom")
    
    --当前状态说明   已完成   排队中  进行中
    self._pState = self._pBack:getChildByName("State")
    --进度条背景
    self._pLoadingBack = self._pBack:getChildByName("LoadingBack")
    --进度条
    self._pLoadingBar = self._pLoadingBack:getChildByName("LoadingBar")
    --剩余时间显示
    self._pRemainingTime = self._pBack:getChildByName("RemainingTime")
   
end
function BladeSoulQueuePanelParams:create()
    local params = BladeSoulQueuePanelParams.new()
    return params
end

return BladeSoulQueuePanelParams
