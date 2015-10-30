--游戏的战斗界面
local LevelStarTipsParams = class("LevelStarTipsParams")

function LevelStarTipsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("LevelStarTips.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --充值start(工程里拼错了……别纠结)
    self._pstart = self._pBackGround:getChildByName("start")
    --进度条
    self._pLoadingBar = self._pBackGround:getChildByName("LoadingBar")
    --时间文字
    self._pText = self._pBackGround:getChildByName("Text")







end

function LevelStarTipsParams:create()
    local params = LevelStarTipsParams.new()
    return params  
end

return LevelStarTipsParams
