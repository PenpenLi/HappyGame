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
    
end

function ActivityDialogeParams:create()
    local params = ActivityDialogeParams.new()
    return params  
end

return ActivityDialogeParams
