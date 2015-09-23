--游戏的战斗界面
local SearchPlayerParams = class("SearchPlayerParams")

function SearchPlayerParams:ctor()
    self._pCCS = cc.CSLoader:createNode("SearchPlayer.csb")
	
	--背景板
    self._pSearchPlayerBg = self._pCCS:getChildByName("SearchPlayerBg")
    --搜索按钮
    self._pSearch = self._pCCS:getChildByName("Search")
    --输入查找玩家的昵称的挂载点
    self._pTextFieldNode = self._pCCS:getChildByName("TextFiledNode")
  

end

function SearchPlayerParams:create()
    local params = SearchPlayerParams.new()
    return params  
end

return SearchPlayerParams
