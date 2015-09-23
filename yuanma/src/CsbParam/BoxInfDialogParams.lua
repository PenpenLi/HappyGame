--获得物品界面
local BoxInfDialogParams = class("BoxInfDialogParams")

function BoxInfDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BoxInfDialog.csb")
	-- 获得物品底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --底板上面的装饰图标底板
    self._pItemIconBg = self._pBackGround:getChildByName("ItemIconBg")
    --底板上面的装饰图标
    --self._pItemIcon = self._pItemIconBg:getChildByName("ItemIcon")
    --获得的物品显示滚动框
    self._pGetItemScrollView = self._pBackGround:getChildByName("GetItemScrollView")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")   
    --领取按钮
    self._pButton = self._pBackGround:getChildByName("Button")   



end

function BoxInfDialogParams:create()
    local params = BoxInfDialogParams.new()
    return params  
end

return BoxInfDialogParams
