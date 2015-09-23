local OurFamilyInfoPanelParams = class("OurFamilyInfoPanelParams")
--自己的家族界面
function OurFamilyInfoPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("OurFamilyInfoPanel.csb")
    --大底板
    self._pBgNode = self._pCCS:getChildByName("BgNode")
    --家族信息标题底板
    self._pTitleBg1 = self._pBgNode:getChildByName("TitleBg1")
    --家族名称输入底板
    self._pPutInTextBg1 = self._pTitleBg1:getChildByName("PutInTextBg1")
    --家族名称输入框
    self._pFamilyNameText = self._pPutInTextBg1:getChildByName("PutInTextName")
    --修改家族名称按钮
    self._pChangeNameButton = self._pPutInTextBg1:getChildByName("ChangeNameButton")
    --家族族长名称底板
    self._pPutInTextBg2 = self._pTitleBg1:getChildByName("PutInTextBg2")
    --家族名称显示框
    self._pText_6 = self._pPutInTextBg2:getChildByName("Text_6")
    --家族等级输入框底板
    self._pPutInTextBg3 = self._pTitleBg1:getChildByName("PutInTextBg3")
    --家族等级显示框
    self._pText_7 = self._pPutInTextBg3:getChildByName("Text_7")
    --成员数量显示底板
    self._pPutInTextBg4 = self._pTitleBg1:getChildByName("PutInTextBg4")
    --成员数量显示框
    self._pText_8 = self._pPutInTextBg4:getChildByName("Text_8")
    --家族宗旨标题底板
    self._pTitleBg2 = self._pBgNode:getChildByName("TitleBg2")
    --家族宗旨输入框底板
    self._pPutInTextBg5 = self._pTitleBg2:getChildByName("PutInTextBg5")
    --家族宗旨输入框
    self._pPutInTextNameNode = self._pPutInTextBg5:getChildByName("PutInTextNameNode")
    --宗旨保存修改按钮
    self._pOkButton = self._pPutInTextBg5:getChildByName("OkButton")
    --右侧大底板
    self._pBigRightBg = self._pBgNode:getChildByName("BigRightBg")
    --右侧家族财富底板
    self._pRightBg1 = self._pBigRightBg:getChildByName("RightBg1")
    --捐献次数
    self._pJxTextNum = self._pRightBg1:getChildByName("JxTextNum")
    --贡献经验条底板
    self._pGxBg = self._pRightBg1:getChildByName("GxBg")
    --贡献经验条
    self._pGxBar = self._pGxBg:getChildByName("GxBar")
    --贡献值
    self._pGXText = self._pRightBg1:getChildByName("GXText")
    --贡献捐献按钮
    self._pJxButton1 = self._pRightBg1:getChildByName("JxButton1")
    --家族资产经验条底板
    self._pZcBg = self._pRightBg1:getChildByName("ZcBg")
    --资产经验条
    self._pZcBar = self._pZcBg:getChildByName("ZcBar")
    --资产数值
    self._pZCText = self._pRightBg1:getChildByName("ZCText")
    --资产捐献按钮
    self._pJxButton2 = self._pRightBg1:getChildByName("JxButton2")
    --家族升级底板
    self._pRightBg2 = self._pBigRightBg:getChildByName("RightBg2")
    --家族人数值
    self._pPNumText = self._pRightBg2:getChildByName("PNumText")
    --家族等级值
    self._pLvNumText = self._pRightBg2:getChildByName("LvNumText")
    --家族升级按钮
    self._pLvUpButton = self._pRightBg2:getChildByName("LvUpButton")
    --退出家族
    self._pTuiChuButton = self._pBgNode:getChildByName("TuiChuButton")
    --家族排行
    self._pRakingButton = self._pBgNode:getChildByName("RakingButton")
    --家族商店
    self._pShopButton = self._pBgNode:getChildByName("ShopButton")
    --家族任务
    self._pTaskButton = self._pBgNode:getChildByName("TaskButton")
    --家族宗旨的显示txt
    self._pPutInText = self._pPutInTextBg5:getChildByName("PutInText")

end
function OurFamilyInfoPanelParams:create()
    local params = OurFamilyInfoPanelParams.new()
    return params
end

return OurFamilyInfoPanelParams
