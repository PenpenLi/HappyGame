--开屏广告
local AdvertiseMentParams = class("AdvertiseMentParams")

function AdvertiseMentParams:ctor()
    self._pCCS = cc.CSLoader:createNode("AdvertiseMent.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
	--关闭按钮
	self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
	--关联入口按钮
	self._pOkButton = self._pBackGround:getChildByName("OkButton")
	--广告图切换框
	self._pPictureQ = self._pBackGround:getChildByName("PictureQh")
	--切换表示按钮
	self._pNowButton = self._pBackGround:getChildByName("NowButton")
	
end

function AdvertiseMentParams:create()
    local params = AdvertiseMentParams.new()
    return params  
end

return AdvertiseMentParams
