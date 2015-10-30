--游戏的战斗界面
local TitleUIParams = class("TitleUIParams")

function TitleUIParams:ctor()
    self._pCCS = cc.CSLoader:createNode("TitleUI.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --当前选中称号
    self._pTitle01 = self._pBackGround:getChildByName("Title01")
    --当前选中称号的说明01（名称解锁佩戴）
    self._pTitleTextBG01 = self._pBackGround:getChildByName("TitleTextBG01")
    --当前选中称号的说明01的文字（名称解锁佩戴）
    self._pText01 = self._pTitleTextBG01:getChildByName("Text01")
    --当前选中称号的说明02（效果）
    self._pTitleTextBG02 = self._pBackGround:getChildByName("TitleTextBG02")
    --当前选中称号的说明02的文字（效果）
    self._pText02 = self._pTitleTextBG02:getChildByName("Text02")
    --确认佩戴按钮
    self._pSureButton = self._pTitleTextBG02:getChildByName("SureButton")
    --滚动列表
    self._pScrollView = self._pBackGround:getChildByName("ScrollView")
    --一个称号图标
    self._pTitleIcon01 = self._pScrollView:getChildByName("TitleIcon01")
    --左按钮
    self._pLeftButton = self._pBackGround:getChildByName("LeftButton")
    --右按钮
    self._pRightButton = self._pBackGround:getChildByName("RightButton")
   
    



    
end

function TitleUIParams:create()
    local params = TitleUIParams.new()
    return params  
end

return TitleUIParams
