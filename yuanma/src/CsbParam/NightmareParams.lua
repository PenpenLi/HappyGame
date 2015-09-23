--游戏的战斗界面
local NightmareParams = class("NightmareParams")

function NightmareParams:ctor()
    self._pCCS = cc.CSLoader:createNode("NightmareUI.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮虽然用不到
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --问题背景版
    self._pQuestionBg = self._pBackGround:getChildByName("QuestionBg")
    --文字背景版
    self._pTextBg = self._pQuestionBg:getChildByName("TextBg")
    --标题
    self._pTitle = self._pTextBg:getChildByName("Title")
    --题目正文
    self._pQuestion = self._pTextBg:getChildByName("Question")
    --进度条底板
    self._pLoadingBarBack = self._pTextBg:getChildByName("LoadingBarBack")
    --进度条
    self._pLoadingBar = self._pTextBg:getChildByName("LoadingBar")
    --黑白无常位置节点01左
    self._pGhostNode01 = self._pBackGround:getChildByName("GhostNode01")
    --黑白无常位置节点02右
    self._pGhostNode02 = self._pBackGround:getChildByName("GhostNode02")
    --列表容器
    self._pListView = self._pBackGround:getChildByName("ListView")


    
end

function NightmareParams:create()
    local params = NightmareParams.new()
    return params  
end

return NightmareParams
