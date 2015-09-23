--游戏的战斗界面
local FightEndCardParams = class("FightEndCardParams")

function FightEndCardParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FightEndCard.csb")

	--卡牌背面01
    self._pcardA01 = self._pCCS:getChildByName("cardA01")
    --卡牌背面02
    self._pcardA02 = self._pCCS:getChildByName("cardA02")
    --卡牌背面03
    self._pcardA03 = self._pCCS:getChildByName("cardA03")
    --卡牌背面04
    self._pcardA04 = self._pCCS:getChildByName("cardA04")
    --卡牌正面01
    self._pcardB01 = self._pCCS:getChildByName("cardB01")
    --物品icon显示节点01
    self._pNodeitem01 = self._pcardB01:getChildByName("Nodeitem01")
    --卡牌正面02
    self._pcardB02 = self._pCCS:getChildByName("cardB02")
    --物品icon显示节点02
    self._pNodeitem02 = self._pcardB02:getChildByName("Nodeitem02")
    --卡牌正面03
    self._pcardB03 = self._pCCS:getChildByName("cardB03")
    --物品icon显示节点03
    self._pNodeitem03 = self._pcardB03:getChildByName("Nodeitem03")
    --卡牌正面04
    self._pcardB04 = self._pCCS:getChildByName("cardB04")
    --物品icon显示节点04
    self._pNodeitem04 = self._pcardB04:getChildByName("Nodeitem04")
        

end

function FightEndCardParams:create()
    local params = FightEndCardParams.new()
    return params  
end

return FightEndCardParams
