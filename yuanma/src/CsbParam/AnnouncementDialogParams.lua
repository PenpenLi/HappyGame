--游戏的战斗界面
local AnnouncementDialogParams = class("AnnouncementDialogParams")

function AnnouncementDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("AnnouncementDialog.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --位置节点
    self._pNode01 = self._pBackGround:getChildByName("Node01")
    --ScrollView
    self._pScrollViewDesc =  self._pNode01:getChildByName("ScrollView")
    --ListView 
    self._pScrollViewTitle = self._pBackGround:getChildByName("ScrollView")
    --button
    self._pListItemBtn = self._pBackGround:getChildByName("btnItem")   
    --notice
    self._pNotice = self._pListItemBtn:getChildByName("notice")   
	--title
    self._pTitleText = self._pBackGround:getChildByName("Text")  
    
end

function AnnouncementDialogParams:create()
    local params = AnnouncementDialogParams.new()
    return params  
end

return AnnouncementDialogParams
