--活动框架界面
local ActivityDialogeParams = class("ActivityDialogeParams")

function ActivityDialogeParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ActivityDialoge.csb")
	--背景底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --左侧底板
    self._pLeftBg = self._pBackGround:getChildByName("LeftBg")
    -- 左侧标签
    self._pLeftScrollView = self._pLeftBg:getChildByName("ScrollView_3")
    --活动按钮
    self._pActivityButton1 = self._pLeftScrollView:getChildByName("ActivityButton1")
    --右侧底板
    self._pRightBg = self._pBackGround:getChildByName("RightBg")
    --右侧界面挂点
    self._pOnLineNode = self._pRightBg:getChildByName("OnLineNode")
    --在线礼包滚动框
    self._pOlScrollView = self._pOnLineNode:getChildByName("OlScrollView")


    

    --激活码挂点
   self._pCodeNode = self._pRightBg:getChildByName("CodeNode")
   --领取按钮
    self._pOkButton = self._pCodeNode:getChildByName("OkButton")
    --输入框文字
    self._pCodeText = self._pCodeNode:getChildByName("CodeText")
    --等级礼包挂点
    self._pLvUpNode = self._pRightBg:getChildByName("LvUpNode")
    --等级礼包右侧滚动框
    self._pLvUpView = self._pLvUpNode:getChildByName("LvUpView")

    --右侧界面月签到节点
    self._pSignInNode = self._pRightBg:getChildByName("SignInNode")

    --右侧体力赠送节点
    self._pPowerNode = self._pRightBg:getChildByName("PowerNode")
     --右侧累计充值节点
    self._pRechargeNode = self._pRightBg:getChildByName("RechargeNode")
    
    
end

function ActivityDialogeParams:create()
    local params = ActivityDialogeParams.new()
    return params  
end

return ActivityDialogeParams
