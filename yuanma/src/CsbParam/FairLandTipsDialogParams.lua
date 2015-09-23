--境界盘中显示提升效果的版子
local FairLandTipsDialogParams = class("FairLandTipsDialogParams")

function FairLandTipsDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FairLandTipsDialog.csb")
    --底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --标题文字
    self._pTitleText = self._pBackGround:getChildByName("TitleText")
    --提升属性类型
    self._pAttributeText = self._pBackGround:getChildByName("AttributeText")
    --提升属性数值
    self._pAttributeNum = self._pBackGround:getChildByName("AttributeNum")
end

function FairLandTipsDialogParams:create()
    local params = FairLandTipsDialogParams.new()
    return params
end

return FairLandTipsDialogParams
