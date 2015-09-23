local DonateDialogParams = class("DonateDialogParams")
--捐献界面
function DonateDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("DonateDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
   --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
   --普通捐献
    self._pButton_1 = self._pBackGround:getChildByName("Button_1")
   --普通捐献数值
   self._pText_1_1 = self._pBackGround:getChildByName("Text_1_1")
   --普通捐献获得贡献度
   self._pText_2_1 = self._pBackGround:getChildByName("Text_2_1")
   --普通捐献获得的家族贡献/家族资金
   self._pText_7_1 = self._pBackGround:getChildByName("Text_7_1")
   --家族贡献或者家族资金文字
   self._pText_7 = self._pBackGround:getChildByName("Text_7")
   --家族资金或贡献图标
   self._pJzGxIcon = self._pBackGround:getChildByName("JzGxIcon")
   --豪华捐献
   self._pButton_2 = self._pBackGround:getChildByName("Button_2")
   --豪华捐献数值
   self._pText_3_1 = self._pBackGround:getChildByName("Text_3_1")
   --豪华捐献获得贡献度
   self._pText_4_1 = self._pBackGround:getChildByName("Text_4_1")
   --豪华捐献获得的家族贡献/家族资金
   self._pText_8_1 = self._pBackGround:getChildByName("Text_8_1")
   --家族贡献或者家族资金文字
   self._pText_8 = self._pBackGround:getChildByName("Text_8")
   --家族资金或贡献图标
   self._pJzGxIcon_1 = self._pBackGround:getChildByName("JzGxIcon_1")
   --至尊捐献
   self._pButton_3 = self._pBackGround:getChildByName("Button_3")
   --至尊捐献数值
   self._pText_5_1 = self._pBackGround:getChildByName("Text_5_1")
   --至尊捐献获得贡献度
   self._pText_6_1 = self._pBackGround:getChildByName("Text_6_1")
   --至尊捐献获得的家族贡献/家族资金
   self._pText_9_1 = self._pBackGround:getChildByName("Text_9_1")
   --家族贡献或者家族资金文字
   self._pText_9 = self._pBackGround:getChildByName("Text_9")
   --家族资金或贡献图标
   self._pJzGxIcon_2 = self._pBackGround:getChildByName("JzGxIcon_2")
end
function DonateDialogParams:create()
    local params = DonateDialogParams.new()
    return params
end

return DonateDialogParams
