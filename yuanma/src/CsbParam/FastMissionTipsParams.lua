--游戏的战斗界面
local FastMissionTipsParams = class("FastMissionTipsParams")

function FastMissionTipsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("FastMissionTips.csb")

	--前往、领取按钮
    self._pButton = self._pCCS:getChildByName("Button")
	--负责板子隐藏的node
    self._pNodeAll = self._pButton:getChildByName("NodeAll")
    --板子本身
    self._pBg = self._pNodeAll:getChildByName("Bg")
    --奖励物品1
    self._picon01 = self._pNodeAll:getChildByName("icon01")
    --奖励物品1的数量
    self._picontext01 = self._picon01:getChildByName("icontext01")
    --奖励物品2
    self._picon02 = self._pNodeAll:getChildByName("icon02")
    --奖励物品2的数量
    self._picontext02 = self._picon02:getChildByName("icontext02")
    --奖励物品3
    self._picon03 = self._pNodeAll:getChildByName("icon03")
    --奖励物品3的数量
    self._picontext03 = self._picon03:getChildByName("icontext03")
    --奖励物品4
    self._picon04 = self._pNodeAll:getChildByName("icon04")
    --奖励物品4的数量
    self._picontext04 = self._picon04:getChildByName("icontext04")
    --任务名称 四个字
    self._pname01 = self._pNodeAll:getChildByName("name01")
    --任务名称 内容
    self._pname02 = self._pNodeAll:getChildByName("name02")
    --任务目标 四个字
    self._ptext01 = self._pNodeAll:getChildByName("text01")
    --任务目标 内容
    self._ptext02 = self._pNodeAll:getChildByName("text02")
    --任务奖励 四个字
    self._ptext03 = self._pNodeAll:getChildByName("text03")
    



    
end

function FastMissionTipsParams:create()
    local params = FastMissionTipsParams.new()
    return params  
end

return FastMissionTipsParams
