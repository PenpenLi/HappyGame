local BelleBigPictureParams = class("BelleBigPictureParams")
--美人大图
function BelleBigPictureParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BelleBigPicture.csb")
    --大底板
    self._pBelleBg = self._pCCS:getChildByName("BelleBg")
    --风景图
    self._pBelleImage = self._pBelleBg:getChildByName("BelleImage")
    --美人大图
    self._pBellePicture01 = self._pBelleBg:getChildByName("BellePicture01")
    --美人名称
    self._pBelleName01 = self._pBelleBg:getChildByName("BelleName01")
    --关闭按钮
    self._pCloseButton = self._pBelleBg:getChildByName("CloseButton")
    --亲密按钮
    self._pQinButton = self._pBelleBg:getChildByName("QinButton")
    --亲密进度条底板
    self._pQinMinBarBg = self._pBelleBg:getChildByName("QinMinBarBg")
    --进度条
    self._pQinMiBar = self._pQinMinBarBg:getChildByName("QinMiBar")
    --进度文字
    self._pQinMinNumText = self._pQinMinBarBg:getChildByName("QinMinNumText")
    --亲密等级
    self._pQmLvText = self._pBelleBg:getChildByName("QmLvText")
    -- 互动剩余次数 
    self._pRemainNumText = self._pBelleBg:getChildByName("remainNumText")
 
end
function BelleBigPictureParams:create()
    local params = BelleBigPictureParams.new()
    return params
end

return BelleBigPictureParams
