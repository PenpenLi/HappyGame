--游戏的战斗界面
local SkillSet01Params = class("SkillSet01Params")

function SkillSet01Params:ctor()
    self._pCCS = cc.CSLoader:createNode("SkillSet01.csb")
	--技能系列01背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --技能系列01技能节点01
    self._pNode01 = self._pCCS:getChildByName("Node01")
    --技能系列01技能节点02
    self._pNode02 = self._pCCS:getChildByName("Node02")
    --技能系列01技能节点03
    self._pNode03 = self._pCCS:getChildByName("Node03")
    --技能系列01技能节点04
    self._pNode04 = self._pCCS:getChildByName("Node04")
    --技能系列01技能节点05
    self._pNode05 = self._pCCS:getChildByName("Node05")
    --技能系列01技能节点06
    self._pNode06 = self._pCCS:getChildByName("Node06")
    --技能系列01技能节点07
    self._pNode07 = self._pCCS:getChildByName("Node07")


    self._pNodes = {self._pNode01,self._pNode02,self._pNode03,self._pNode04,self._pNode05,self._pNode06,self._pNode07}
    
end

function SkillSet01Params:create()
    local params = SkillSet01Params.new()
    return params  
end

return SkillSet01Params
