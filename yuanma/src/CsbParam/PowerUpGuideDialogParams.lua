--我要变强界面
local PowerUpGuideDialogParams = class("PowerUpGuideDialogParams")

function PowerUpGuideDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PowerUpGuideDialog.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --标题图片
    self._pTitleTextPic = self._pBackGround:getChildByName("TitleTextPic")
    --战斗力图片
    self._pImage_3 = self._pBackGround:getChildByName("Image_3")
    --战斗力艺术字
    self._pPowerFnt = self._pBackGround:getChildByName("PowerFnt")
    -- 进度的滚动容器
    self._pScrollView = self._pBackGround:getChildByName("ScrollView1")
end

function PowerUpGuideDialogParams:create()
    local params = PowerUpGuideDialogParams.new()
    return params  
end

return PowerUpGuideDialogParams
