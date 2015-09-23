--境界界面
local FairyLandDialogParams = class("FairyLandDialogParams")

function FairyLandDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FairyLandDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --右侧小底板
    self._pDanRightFrame = self._pBackGround:getChildByName("DanRightFrame")
    --右侧滚动框
    self._pDanRightScrollView = self._pDanRightFrame:getChildByName("DanRightScrollView")
    --左侧小底板
    self._pInlayDanLeftFrame = self._pBackGround:getChildByName("InlayDanLeftFrame")
    --境界点数值底板
    self._pFairyLandDanNumBg = self._pBackGround:getChildByName("FairyLandDanNumBg")
    --境界点数值
    self._pFairyLandDanNumText1 = self._pFairyLandDanNumBg:getChildByName("FairyLandDanNumText1")
    self._pFairyLandDanNumText2 = self._pFairyLandDanNumBg:getChildByName("FairyLandDanNumText2")
    --刷新按钮
    self._pRefreshButton = self._pBackGround:getChildByName("RefreshButton")
    --效果按钮
    self._pResultbutton = self._pBackGround:getChildByName("Resultbutton")
    --镶嵌的境界丹图标
    self._p1Icon = self._pBackGround:getChildByName("1Icon")
    self._p2Icon = self._pBackGround:getChildByName("2Icon")
    self._p3Icon = self._pBackGround:getChildByName("3Icon")
    self._p4Icon = self._pBackGround:getChildByName("4Icon")
    self._p5Icon = self._pBackGround:getChildByName("5Icon")
    self._p6Icon = self._pBackGround:getChildByName("6Icon")
    self._p7Icon = self._pBackGround:getChildByName("7Icon")
    self._p8Icon = self._pBackGround:getChildByName("8Icon")
    self._p9Icon = self._pBackGround:getChildByName("9Icon")
    self._p10Icon = self._pBackGround:getChildByName("10Icon")
    self._p11Icon = self._pBackGround:getChildByName("11Icon")
    self._p12Icon = self._pBackGround:getChildByName("12Icon")
   
   
    self._pFairyLandDanLvText = self._pBackGround:getChildByName("FairyLandDanLvText")
    --境界盘经验条
    self._pFairyLandDanLvBg = self._pBackGround:getChildByName("FairyLandDanLvBg")
    self._pFairyLandDanLvBar = self._pFairyLandDanLvBg:getChildByName("FairyLandDanLvBar")
    --境界盘经验值数字
    self._pPanExpText = self._pBackGround:getChildByName("PanExpText")
    --一键吞噬
    self._pDevourButton = self._pBackGround:getChildByName("DevourButton")
    --境界升阶丹数值底板
    self._pDanNumBg = self._pBackGround:getChildByName("DanNumBg")
    --境界升阶丹数值
    self._pDanNumText1 = self._pDanNumBg:getChildByName("DanNumText1")
    self._pDanNumText2 = self._pDanNumBg:getChildByName("DanNumText2")
    
    --境界升阶丹Icon
    self._pDanIcon= self._pDanNumBg:getChildByName("DanIcon")
    --境界升阶丹 名称
    self._pDanName = self._pDanNumBg:getChildByName("DanName")
    --升阶按钮
    self._pUpButton = self._pBackGround:getChildByName("UpButton")

    --转圈底板
   self._pTips = self._pBackGround:getChildByName("Tips")
    
    --当前境界丹tips总node
    self._pTipsNode = self._pBackGround:getChildByName("TipsNode")
   
    --当前境界丹名称
    self._pFdanName = self._pTipsNode:getChildByName("Text_22")
    --属性名称
   self._pAtrrType = self._pTipsNode:getChildByName("Text_23")
    --属性数值
   self._pAtrrNum = self._pTipsNode:getChildByName("Text_24")
    --提升按钮
   self._pAttribute = self._pTipsNode:getChildByName("Button_18")
   --卸下按钮
   self._pUnsnatch = self._pTipsNode:getChildByName("Button_19")
   --境界丹没有的时候提示
   self._pRemindText = self._pBackGround:getChildByName("Text_25")


end

function FairyLandDialogParams:create()
    local params = FairyLandDialogParams.new()
    return params
end

return FairyLandDialogParams
