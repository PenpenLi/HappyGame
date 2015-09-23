--升级，战斗力变化提示
local PowerUpParams = class("PowerUpParams")

function PowerUpParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PowerUp.csb")
	--背景板
    self._pTiShiBg = self._pCCS:getChildByName("TiShiBg")
	--提升图标
	self._pUpBz = self._pTiShiBg:getChildByName("UpBz")
	--当前战斗力艺术字
	--self._pPowerFnts = self._pTiShiBg:getChildByName("PowerFnts")
	--战斗力提升百分比艺术字
	self._pPowerUpFnts = self._pTiShiBg:getChildByName("PowerUpFnts")
	
end

function PowerUpParams:create()
    local params = PowerUpParams.new()
    return params  
end

return PowerUpParams
