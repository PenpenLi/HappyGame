local CreatHomeDialogParams = class("CreatHomeDialogParams")
--创建家族界面
function CreatHomeDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("CreatHomeDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
   --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
   --输入家族名称底板
   self._pPutInTextBg = self._pCCS:getChildByName("PutInTextBg")
   --输入家族名称输入框挂在
   self._pHomeNameTextNode = self._pPutInTextBg:getChildByName("HomeNameTextNode")
   --家族宗旨输入框底板
   self._pPutInTextBg1= self._pCCS:getChildByName("PutInTextBg1")
   --家族宗旨输入框
   self._pHomeNameZZTextNode= self._pPutInTextBg1:getChildByName("HomeNameZZTextNode")
   -- 创建家族所需货币的图标
   self._pMoneyIcon = self._pBackGround:getChildByName("MoneyIcon")
   --创建家族所需货币数量
   self._pMoneyNumText= self._pBackGround:getChildByName("MoneyNumText")
   --创建家族按钮
   self._pCreatButton= self._pBackGround:getChildByName("CreatButton")
   --家族宗旨显示text
   self._pHomeZZTextShow = self._pPutInTextBg1:getChildByName("homeZZTextShow")
end
function CreatHomeDialogParams:create()
    local params = CreatHomeDialogParams.new()
    return params
end

return CreatHomeDialogParams
