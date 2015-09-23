--游戏的战斗界面
local SkillTipsParams = class("SkillTipsParams")

function SkillTipsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("skilltips.csb")
	--技能tips背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
	--顶排节点
    self._pnodeup = self._pCCS:getChildByName("nodeup")
    --技能icon
    self._pskillicon = self._pnodeup:getChildByName("skillicon")
    --技能名称
    self._pskillname = self._pnodeup:getChildByName("skillname")
    --技能等级
    self._pskilllv = self._pnodeup:getChildByName("skilllv")
    --技能we位置
    self._pskillPos = self._pnodeup:getChildByName("skilllv2")
    --下排节点
    self._pnodedown = self._pCCS:getChildByName("nodedown")

    --滚筒容器01
    self._pscrollview01 = self._pnodedown:getChildByName("scrollview01")
    --技能效果具体文字01
    self._pskilldepict01 = self._pscrollview01:getChildByName("skilldepict01")
    --滚筒容器02
    self._pscrollview02 = self._pnodedown:getChildByName("scrollview02")
    --技能效果具体文字02
    self._pskilldepict02 = self._pscrollview02:getChildByName("skilldepict02")
    --滚筒容器03
    self._pscrollview03 = self._pnodedown:getChildByName("scrollview03")
    --技能需求具体文字
    self._pskilldepict03 = self._pscrollview03:getChildByName("skilldepict03")

    --技能效果
    self._pskillattribute = self._pnodedown:getChildByName("skillattribute")
    --升级价格底板
    self._plvuppriceBg = self._pCCS:getChildByName("SkillTitleBg03")
    --升级价格
    self._plvupprice = self._plvuppriceBg:getChildByName("lvupprice")
    --升级价格具体金币数值
    self._plvupprice02 = self._pnodedown:getChildByName("lvupprice02")
    --升级价格具体斗魂数值
    self._plvupprice03 = self._pnodedown:getChildByName("lvupprice03")
    --货币icon
    self._pcurrencyicon = self._pnodedown:getChildByName("currencyicon")
    --升级按钮
    self._plvupbutton = self._pnodedown:getChildByName("lvupbutton")
    --出战按钮
    self._pskillchoicebutton = self._pnodedown:getChildByName("skillchoicebutton")

    --技能效果底板（当前技能等级）
    self._pSkillTitleBg01 = self._pCCS:getChildByName("SkillTitleBg01")
    --技能效果，当前技能等级，具体等级数字
    self._pSkillDiscEffectLv01 = self._pSkillTitleBg01:getChildByName("SkillDiscEffectLv01")
    --技能效果底板（下一级技能等级）
    self._pSkillTitleBg02 = self._pCCS:getChildByName("SkillTitleBg02")
    --技能效果，当前技能等级，具体等级数字
    self._pSkillDiscEffectLv02 = self._pSkillTitleBg02:getChildByName("SkillDiscEffectLv02")
    --技能效果底板（下一级技能等级）
    self._pSkillTitleBg03 = self._pCCS:getChildByName("SkillTitleBg03")

    
end

function SkillTipsParams:create()
    local params = SkillTipsParams.new()
    return params  
end

return SkillTipsParams
