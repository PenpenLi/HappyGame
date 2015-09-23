--游戏的战斗界面
local ChallengeCopysParams = class("ChallengeCopysParams")

function ChallengeCopysParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ChallengeCopys.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关卡底图
    self._pcopyBg = self._pBackGround:getChildByName("copyBg")     
    --关卡名称
    self._pcopysname = self._pBackGround:getChildByName("copysname")
    --确定按钮（进入副本）
    self._pSureButton = self._pcopyBg:getChildByName("SureButton")
    
    --下方详情底板
    self._pDownBg = self._pBackGround:getChildByName("DownBg")

    --战斗力、次数、体力挂点
    self._pTextNode1 = self._pBackGround:getChildByName("TextNode1")
    --推荐战斗力
    self._pbattlepower01 = self._pTextNode1:getChildByName("battlepower01")
    --推荐战斗力（具体）
    self._pbattlepower02 = self._pTextNode1:getChildByName("battlepower02")
    --剩余次数
    self._pcurcount01 = self._pTextNode1:getChildByName("curcount01")
    --剩余次数（具体）
    self._pcurcount02 = self._pTextNode1:getChildByName("curcount02")
    --消耗体力
    self._pusepower01 = self._pTextNode1:getChildByName("usepower01")
    --消耗体力（具体）
    self._pusepower02 = self._pTextNode1:getChildByName("usepower02")
   
    self._pReward = self._pcopyBg:getChildByName("reward")
    --关卡奖励1底板
    self._pItem1Bg = self._pcopyBg:getChildByName("Item1Bg")
    --关卡奖励物品图标1
    self._pItem1 = self._pItem1Bg:getChildByName("Item1")
    --关卡奖励2底板
    self._pItem2Bg = self._pcopyBg:getChildByName("Item2Bg")
    --关卡奖励物品图标2
    self._pItem2 = self._pItem2Bg:getChildByName("Item2")
    --关卡奖励3底板
    self._pItem3Bg = self._pcopyBg:getChildByName("Item3Bg")
    --关卡奖励物品图标3
    self._pItem3 = self._pItem3Bg:getChildByName("Item3")

    --消耗物品的挂点
    self._pTextNode2 = self._pBackGround:getChildByName("TextNode2")
	--消耗物品图标
    self._pItem = self._pTextNode2:getChildByName("Item")
	--消耗物品背景框
    self._pItemBg = self._pTextNode2:getChildByName("ItemBg")
	--消耗物品数量
	self._pCost = self._pTextNode2:getChildByName("Cost")

    --锁住的图
    self._plock = self._pCCS:getChildByName("lock")
    --需求等级（具体）
    self._plockText = self._plock:getChildByName("locktext")
    --旋转的挂载节点
    self._pNodeLock = self._pCCS:getChildByName("nodelock")
 
end

function ChallengeCopysParams:create()
    local params = ChallengeCopysParams.new()
    return params  
end

return ChallengeCopysParams
