local HomeInfoDialogParams = class("HomeInfoDialogParams")
--信息界面底板
function HomeInfoDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("HomeInfoDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
   --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
   --家族名称
   self._pText1_1 = self._pBackGround:getChildByName("Text1_1")
   --家族等级
   self._pText2_1 = self._pBackGround:getChildByName("Text2_1")
   --家族人数
   self._pText3_1 = self._pBackGround:getChildByName("Text3_1")
   --族长名称
   self._pText4_1 = self._pBackGround:getChildByName("Text4_1")
   --家族宗旨文字
   self._pText6 = self._pBackGround:getChildByName("Text6")
   -- 申请加入按钮
   self._pApplyBtn = self._pBackGround:getChildByName("Button1")
end
function HomeInfoDialogParams:create()
    local params = HomeInfoDialogParams.new()
    return params
end

return HomeInfoDialogParams
