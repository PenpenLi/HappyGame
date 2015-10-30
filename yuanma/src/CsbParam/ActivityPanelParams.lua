--家园当前未激活的buff
local ActivityPanelParams = class("ActivityPanelParams")

function ActivityPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ActivityPanel.csb")
	--背景板(可点击)
    self._pBg = self._pCCS:getChildByName("Bg")
    --分界线
    self._pZbfj18A= self._pBg:getChildByName("Zbfj18A")	
    --分界线
    self._pZbfj18B= self._pBg:getChildByName("Zbfj18B")	
    --分界线
    self._pZbfj19A= self._pBg:getChildByName("Zbfj19A")	
    --关闭按钮
	self._pCloseButton = self._pBg:getChildByName("CloseButton")
	--滚动条
    self._pScrollView_1 = self._pBg:getChildByName("ScrollView_1")
    --左侧页签（未按下时，字体为咖啡色，按下时，字体为白色）
    self._pLeftButton = self._pBg:getChildByName("LeftButton")
    --界面花纹图片
    self._pHuawen1 = self._pBg:getChildByName("Huawen1")
    --图标底板
    self._pTitleBase = self._pCCS:getChildByName("TitleBase")
    --系统名称
    self._pText_1 = self._pCCS:getChildByName("Text_1")
    --系统图标
    self._pXiuxingIcon = self._pCCS:getChildByName("XiuxingIcon")

    --左侧页签字体颜色
    cDeepGrey = cc.c3b(96,56,17)
    self._pLeftButton:getTitleRenderer():setTextColor(cDeepGrey)

 
end
function ActivityPanelParams:create()
    local params = ActivityPanelParams.new()
    return params  
end
return ActivityPanelParams
