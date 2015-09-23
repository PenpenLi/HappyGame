--家园当前激活的buff
local BuffNowParams = class("BuffNowParams")

function BuffNowParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BuffNow.csb")
	--背景板
    self._pBackBg = self._pCCS:getChildByName("BackBg")
	--图标底板
	self._pBuffIconBg = self._pBackBg:getChildByName("BuffIconBg")
	--图标
	self._pBuffIcon = self._pBackBg:getChildByName("BuffIcon")
    --技能名称
    self._pBuffName = self._pBackBg:getChildByName("BuffName")
    --技能等级
    self._pBuffLv = self._pBackBg:getChildByName("BuffLv")
    --技能说明
    self._pBuffSM = self._pBackBg:getChildByName("BuffSM")
    --经验条底板
    self._pExpBg = self._pBackBg:getChildByName("ExpBg")
    --经验条
    self._pExpBar = self._pExpBg:getChildByName("ExpBar")
    --剩余时间文字
    self._pTimeTextNum = self._pBackBg:getChildByName("TimeTextNum")
end

function BuffNowParams:create()
    local params = BuffNowParams.new()
    return params  
end

return BuffNowParams
