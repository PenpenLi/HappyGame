--游戏的战斗界面
local FightParams = class("FightParams")

function FightParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FightUI.csb")

	--角色hp槽怒气槽一块那个节点
    self._pNodePCHPrage = self._pCCS:getChildByName("NodePCHPrage")
    --角色icon按钮
    self._piconandskill5 = self._pNodePCHPrage:getChildByName("iconandskill5")
    --测试按钮
    self._pTestButton = self._pNodePCHPrage:getChildByName("TestButton")
    --NodeFunc功能按钮节点
    self._pNodeFunc = self._pCCS:getChildByName("NodeFunc")
    --自动战斗按钮
    self._pautomaticfight = self._pNodeFunc:getChildByName("automaticfight")
    --自动战斗另一态
    self._pautomaticfight2 = self._pNodeFunc:getChildByName("automaticfight2")
    --退出按钮
    self._pout = self._pNodeFunc:getChildByName("out")
    --攻击按钮和技能那堆那个节点
    self._pNodeAttack = self._pCCS:getChildByName("NodeAttack")
    --普通攻击按钮
    self._pnormalattack = self._pNodeAttack:getChildByName("normalattack")
    --时间
    self._ptime = self._pCCS:getChildByName("time")
end

function FightParams:create()
    local params = FightParams.new()
    return params  
end

return FightParams
