--游戏的战斗界面
local GoldDropNodeParams = class("GoldDropNodeParams")

function GoldDropNodeParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GoldDropNode.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --金币icon
    self._pgold = self._pBackGround:getChildByName("gold")
    --数字
    self._pText = self._pBackGround:getChildByName("Text")




    
end

function GoldDropNodeParams:create()
    local params = GoldDropNodeParams.new()
    return params  
end

return GoldDropNodeParams
