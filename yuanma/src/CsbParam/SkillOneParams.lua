--游戏的战斗界面
local SkillOneParams = class("SkillOneParams")

function SkillOneParams:ctor()
    self._pCCS = cc.CSLoader:createNode("SkillOne.csb")

	--背景板,同时也是表示技能类型的色块版
    self._pBG = self._pCCS:getChildByName("BG")
    --技能icon
    self._pSkillIcon = self._pBG:getChildByName("SkillIcon")
    --技能表框按钮
    self._pSkillEdgeButton = self._pBG:getChildByName("SkillEdgeButton")
    --锁定图标
    self._pLock = self._pBG:getChildByName("Lock")
    --可升级图标
    self._pUpIcon = self._pBG:getChildByName("UpIcon")
    --当前技能等级
    self._pLv = self._pBG:getChildByName("Lv")

    
end

function SkillOneParams:create()
    local params = SkillOneParams.new()
    return params  
end

return SkillOneParams
