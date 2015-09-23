--游戏的战斗界面
local FightEndFailureParams = class("FightEndFailureParams")

function FightEndFailureParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FightEndFailure.csb")

	--战斗失败背景
    self._pBackGorund = self._pCCS:getChildByName("BackGorund")
    --战斗失败图片01
    self._pfailure01 = self._pBackGorund:getChildByName("failure01")
    --战斗失败图片02
    self._pfailure02 = self._pBackGorund:getChildByName("failure02")
    --战斗失败图片03
    self._pfailure03 = self._pBackGorund:getChildByName("failure03")
    --战斗失败光效01
    self._pline01 = self._pBackGorund:getChildByName("line01")
    --战斗失败光效02
    self._pline02 = self._pBackGorund:getChildByName("line02")
    --关闭按钮
    self._pCloseButton = self._pBackGorund:getChildByName("CloseButton")
    --确定按钮位置节点
    self._pNodesure = self._pCCS:getChildByName("Nodesure")
    --重来一次按钮位置节点
    self._pNodeagain = self._pCCS:getChildByName("Nodeagain")
    --我要变强系列的那个节点
    self._pNodeStrengthen = self._pCCS:getChildByName("NodeStrengthen")

end

function FightEndFailureParams:create()
    local params = FightEndFailureParams.new()
    return params  
end

return FightEndFailureParams
