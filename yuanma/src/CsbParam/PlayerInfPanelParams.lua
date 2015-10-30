--角色属性面板
local PlayerInfPanelParams = class("PlayerInfPanelParams")

function PlayerInfPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PlayerInfPanel.csb")

	-- 底板
    self._pInfFramePoint = self._pCCS:getChildByName("InfFramePoint")
    self._pInfBg = self._pInfFramePoint:getChildByName("InfBg")
    --属性1 生命值
    self._pBg1 = self._pInfBg:getChildByName("Bg1")
    self._pNum1 = self._pBg1:getChildByName("Num1")
    --属性2 防御力
    self._pBg2 = self._pInfBg:getChildByName("Bg2")
    self._pNum2 = self._pBg2:getChildByName("Num2")
    --属性3 韧性
    self._pBg3 = self._pInfBg:getChildByName("Bg3")
    self._pNum3 = self._pBg3:getChildByName("Num3")
    --属性4 格挡
    self._pBg4 = self._pInfBg:getChildByName("Bg4")
    self._pNum4 = self._pBg4:getChildByName("Num4")
    --属性5 闪避率 百分比
    self._pBg5 = self._pInfBg:getChildByName("Bg5")
    self._pNum5 = self._pBg5:getChildByName("Num5")
    --属性6 抗性
    self._pBg6 = self._pInfBg:getChildByName("Bg6")
    self._pNum6 = self._pBg6:getChildByName("Num6")
    --属性7 再生 百分比
    self._pBg7 = self._pInfBg:getChildByName("Bg7")
    self._pNum7 = self._pBg7:getChildByName("Num7")
    --属性8 吸血比率 百分比
    self._pBg8 = self._pInfBg:getChildByName("Bg8")
    self._pNum8 = self._pBg8:getChildByName("Num8")
    --属性9 攻击力
    self._pBg9 = self._pInfBg:getChildByName("Bg9")
    self._pNum9 = self._pBg9:getChildByName("Num9")
    --属性10 穿透
    self._pBg10 = self._pInfBg:getChildByName("Bg10")
    self._pNum10 = self._pBg10:getChildByName("Num10")
    --属性11 暴击几率 百分比
    self._pBg11 = self._pInfBg:getChildByName("Bg11")
    self._pNum11 = self._pBg11:getChildByName("Num11")
    --属性12 暴击伤害 百分比
    self._pBg12 = self._pInfBg:getChildByName("Bg12")
    self._pNum12 = self._pBg12:getChildByName("Num12")
    --属性13 属性强化
    self._pBg13 = self._pInfBg:getChildByName("Bg13")
    self._pNum13 = self._pBg13:getChildByName("Num13")
    --属性14 火属性攻击
    self._pBg14 = self._pInfBg:getChildByName("Bg14")
    self._pNum14 = self._pBg14:getChildByName("Num14")
    --属性15 冰属性攻击
    self._pBg15 = self._pInfBg:getChildByName("Bg15")
    self._pNum15 = self._pBg15:getChildByName("Num15")
    --属性16 雷属性攻击
    self._pBg16 = self._pInfBg:getChildByName("Bg16")
    self._pNum16 = self._pBg16:getChildByName("Num16")

    --详细属性板子按钮
    self._pXqButton = self._pInfFramePoint:getChildByName("XqButton")
 



end

function PlayerInfPanelParams:create()
    local params = PlayerInfPanelParams.new()
    return params  
end

return PlayerInfPanelParams