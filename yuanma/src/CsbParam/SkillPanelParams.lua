--游戏的战斗界面
local SkillPanelParams = class("SkillPanelParams")

function SkillPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("skillpanel.csb")
	--背景板
    self._pbackground = self._pCCS:getChildByName("background")
	--顶排技能按钮那个节点
    self._pnodeskillgenre = self._pCCS:getChildByName("nodeskillgenre")
    --关闭按钮
    self._pclosebutton = self._pnodeskillgenre:getChildByName("closebutton")
    --主动技能按钮
    self._pskillgenre01 = self._pnodeskillgenre:getChildByName("skillgenre01")
    --被动技能按钮
    self._pskillgenre02 = self._pnodeskillgenre:getChildByName("skillgenre02")
    --天赋技能按钮
    self._pskillgenre03 = self._pnodeskillgenre:getChildByName("skillgenre03")

    --技能系列1按钮
    self._pSkillButton01 = self._pnodeskillgenre:getChildByName("SkillButton01")
    --技能系列2按钮
    self._pSkillButton02 = self._pnodeskillgenre:getChildByName("SkillButton02")
    --技能系列3按钮
    self._pSkillButton03 = self._pnodeskillgenre:getChildByName("SkillButton03")

    --技能小板那个节点
    self._pnodeskillbackground = self._pCCS:getChildByName("nodeskillbackground")


    --货币节点
    self._pnodecurrency = self._pCCS:getChildByName("nodecurrency")
    --货币背景板
    self._pcurrencybackground = self._pnodecurrency:getChildByName("currencybackground")
    --金币icon
    self._pcurrencyicon = self._pnodecurrency:getChildByName("currencyicon")
    --金币数量
    self._pnumber = self._pnodecurrency:getChildByName("number")
    --斗魂数量
    self._pnumberFight = self._pnodecurrency:getChildByName("numberFight")

    --已上阵技能那个节点
    self._pNodeSkillUp = self._pCCS:getChildByName("NodeSkillUp")
    --已上阵技能，位置1，底板
    self._pSkill1 = self._pNodeSkillUp:getChildByName("Skill1")
    --已上阵技能，位置1，当前技能等级
    self._pTextLv01 = self._pSkill1:getChildByName("TextLv01")
    --已上阵技能，位置1，当前技能图标定位节点
    self._pNodeSkill01 = self._pSkill1:getChildByName("NodeSkill01")
    --已上阵技能，位置1，当前技能图标定位节点，上的图标
    self._pSkillIcon01 = self._pNodeSkill01:getChildByName("SkillIcon01")
    --已上阵技能，位置2，底板
    self._pSkill2 = self._pNodeSkillUp:getChildByName("Skill2")
    --已上阵技能，位置2，当前技能等级
    self._pTextLv02 = self._pSkill2:getChildByName("TextLv02")
    --已上阵技能，位置2，当前技能图标定位节点
    self._pNodeSkill02 = self._pSkill2:getChildByName("NodeSkill02")
    --已上阵技能，位置2，当前技能图标定位节点，上的图标
    self._pSkillIcon02 = self._pNodeSkill02:getChildByName("SkillIcon02")
    --已上阵技能，位置3，底板
    self._pSkill3 = self._pNodeSkillUp:getChildByName("Skill3")
    --已上阵技能，位置3，当前技能等级
    self._pTextLv03 = self._pSkill3:getChildByName("TextLv03")
    --已上阵技能，位置3，当前技能图标定位节点
    self._pNodeSkill03 = self._pSkill3:getChildByName("NodeSkill03")
    --已上阵技能，位置3，当前技能图标定位节点，上的图标
    self._pSkillIcon03 = self._pNodeSkill03:getChildByName("SkillIcon03")
    --已上阵技能，位置4，底板
    self._pSkill4 = self._pNodeSkillUp:getChildByName("Skill4")
    --已上阵技能，位置4，当前技能等级
    self._pTextLv04 = self._pSkill4:getChildByName("TextLv04")
    --已上阵技能，位置4，当前技能图标定位节点
    self._pNodeSkill04 = self._pSkill4:getChildByName("NodeSkill04")
    --已上阵技能，位置4，当前技能图标定位节点，上的图标
    self._pSkillIcon04 = self._pNodeSkill04:getChildByName("SkillIcon04")
    --已上阵技能，位置5，底板
    self._pSkill5 = self._pNodeSkillUp:getChildByName("Skill5")
    --已上阵技能，位置5，当前技能等级
    self._pTextLv05 = self._pSkill5:getChildByName("TextLv05")
    --已上阵技能，位置5，当前技能图标定位节点
    self._pNodeSkill05 = self._pSkill5:getChildByName("NodeSkill05")
    --已上阵技能，位置5，当前技能图标定位节点，上的图标
    self._pSkillIcon05 = self._pNodeSkill05:getChildByName("SkillIcon05")



















end

function SkillPanelParams:create()
    local params = SkillPanelParams.new()
    return params  
end

return SkillPanelParams
