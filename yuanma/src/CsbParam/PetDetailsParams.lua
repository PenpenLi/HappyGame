--宠物详情框架
local PetDetailsParams = class("PetDetailsParams")

function PetDetailsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PetDetails.csb")
	--技能tips背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --详细按钮
    self._pXxButton = self._pBackGround:getChildByName("XxButton")
    --喂食按钮
    self._pWsButton = self._pBackGround:getChildByName("WsButton")
    --升阶按钮
    self._pSjButton = self._pBackGround:getChildByName("SjButton")
    --共鸣按钮
    self._pGmButton = self._pBackGround:getChildByName("GmButton")
    --上一页按钮
    self._pPreviousButton = self._pBackGround:getChildByName("PreviousButton")
    --下一页按钮
    self._pNextButton = self._pBackGround:getChildByName("NextButton")
    --商城按钮
    self._pShopButton = self._pBackGround:getChildByName("ShopButton")
    --右侧板子挂点
    self._pRightNode = self._pBackGround:getChildByName("RightNode")
   
end

function PetDetailsParams:create()
    local params = PetDetailsParams.new()
    return params  
end

return PetDetailsParams
