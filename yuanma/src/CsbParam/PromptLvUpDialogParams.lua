--家族升级提示板子
local PromptLvUpDialogParams = class("PromptLvUpDialogParams")

function PromptLvUpDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PromptLvUpDialog.csb")

	-- 大背景板子
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    -- 关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --确定按钮
    self._pOkButton = self._pBackGround:getChildByName("OkButton")
    --取消按钮
    self._pCancelButton = self._pBackGround:getChildByName("CancelButton")
    --家族升级提示文字挂点
    self._pTextNode = self._pBackGround:getChildByName("TextNode")
    --需消耗的家族贡献
    self._pText_6_1 = self._pBackGround:getChildByName("Text_6_1")
    --需消耗的家族资金
    self._pText_7_1 = self._pBackGround:getChildByName("Text_7_1")
   --家族升级的title
    self._pTitleImage =  self._pBackGround:getChildByName("Text_1")
    
end

function PromptLvUpDialogParams:create()
    local params = PromptLvUpDialogParams.new()
    return params  
end

return PromptLvUpDialogParams
