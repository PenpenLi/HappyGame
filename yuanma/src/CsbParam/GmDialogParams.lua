local GmDialogParams = class("GmDialogParams")

--宠物共鸣界面板子
function GmDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GmDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    -- 滚动容器
    self._pScrollView = self._pCCS:getChildByName("ScrollView_2")
end

function GmDialogParams:create()
    local params = GmDialogParams.new()
    return params
end

return GmDialogParams
