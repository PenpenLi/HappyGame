--游戏的战斗结算界面
local FightEndParams = class("FightEndParams")

function FightEndParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FightEndUI.csb")

	--背景板
    self._pBg = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBg:getChildByName("CloseButton")
    --星级评价节点(5个星星底座就不写了，这个节点用于和星级评价动画对位置)
    self._pNodelevelstar = self._pCCS:getChildByName("Nodelevelstar")
    --角色icon经验那个节点
    self._pNodeiconandexp = self._pCCS:getChildByName("Nodeiconandexp")
    --经验槽位置节点
    self._pnodeexp = self._pNodeiconandexp:getChildByName("nodeexp")
    --角色等级
    self._prolelevel = self._pNodeiconandexp:getChildByName("rolelevel")
    --结算奖励节点01
    self._pnodegold01 = self._pNodeiconandexp:getChildByName("nodegold01")
    --结算奖励icon01
    self._picon01 = self._pnodegold01:getChildByName("icon01")
    --结算奖励数量01
    self._ptext01 = self._pnodegold01:getChildByName("text01")
    --结算奖励节点02
    self._pnodegold02 = self._pNodeiconandexp:getChildByName("nodegold02")
    --结算奖励icon02
    self._picon02 = self._pnodegold02:getChildByName("icon02")
    --结算奖励数量02
    self._ptext02 = self._pnodegold02:getChildByName("text02")
    --结算奖励节点03
    self._pnodegold03 = self._pNodeiconandexp:getChildByName("nodegold03")
    --结算奖励icon03
    self._picon03 = self._pnodegold03:getChildByName("icon03")
    --结算奖励数量03
    self._ptext03 = self._pnodegold03:getChildByName("text03")
    --结算奖励物品and道具那个节点
    self._pNodeitem = self._pCCS:getChildByName("Nodeitem")
    --滚动容器
    self._pscrollview = self._pNodeitem:getChildByName("scrollview")
    --背景人物对位节点01（战士）
    self._pNoderole01 = self._pCCS:getChildByName("Noderole01")
    --背景人物对位节点02（法师）
    self._pNoderole02 = self._pCCS:getChildByName("Noderole02")
    --背景人物对位节点03（刺客）
    self._pNoderole03 = self._pCCS:getChildByName("Noderole03")
    --确定按钮对位节点
    self._pNodesure = self._pCCS:getChildByName("Nodesure")
    --重来一次按钮对位节点
    self._pNodeagain = self._pCCS:getChildByName("Nodeagain")
    --刺客的那只手（配合结算背景人物使用，已经取消可见性）
    self._prole03arm = self._pCCS:getChildByName("role03arm")



end

function FightEndParams:create()
    local params = FightEndParams.new()
    return params  
end

return FightEndParams
