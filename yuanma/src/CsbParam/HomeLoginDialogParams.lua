local HomeLoginDialogParams = class("HomeLoginDialogParams")
--创建家族界面
function HomeLoginDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("HomeLoginDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
   --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
   --上一页按钮
    self._pPreviousButton = self._pBackGround:getChildByName("PreviousButton")
   --下一页按钮
    self._pNextButton = self._pBackGround:getChildByName("NextButton")
   --页数显示
   self._pPageText = self._pBackGround:getChildByName("PageText")

   --左侧家族底板
   self._pRightBg = self._pBackGround:getChildByName("RightBg")
   --家族列表滚动框
   self._pLeftScrollView = self._pRightBg:getChildByName("LeftListScrollView")
   
   --查找家族输入框底板
   self._pPutInBg = self._pBackGround:getChildByName("PutInBg")
   --查找家族输入框
   self._pPutInText = self._pPutInBg:getChildByName("PutInText")
   --查找家族按钮
   self._pLookUpButton = self._pPutInBg:getChildByName("LookUpButton")
   
   --右侧底板
   self._pLeftBg = self._pBackGround:getChildByName("LeftBg")
   --右侧宗旨底板
   self._pRightBg1 = self._pLeftBg:getChildByName("RightBg1")
   --家族宗旨文字
   self._pText_7 = self._pRightBg1:getChildByName("Text_7")
   --申请加入
   self._pButton2 = self._pRightBg1:getChildByName("Button2")
   --创建家族
   self._pButton3 = self._pRightBg1:getChildByName("Button3")
   --家族排行
   self._pButton4= self._pRightBg1:getChildByName("Button4")
   --家族排行挂点
   self._pHomeRakingsNode = self._pBackGround:getChildByName("HomeRakingsNode")
end
function HomeLoginDialogParams:create()
    local params = HomeLoginDialogParams.new()
    return params
end

return HomeLoginDialogParams
