--没有宠物时候的小板
local NoPetParams = class("NoPetParams")

function NoPetParams:ctor()
    self._pCCS = cc.CSLoader:createNode("NoPet.csb")
	--技能tips背景板
    self._pBackBg = self._pCCS:getChildByName("BackBg")
    --背景板上面的图片
   self._pPicture = self._pBackBg:getChildByName("Picture")
    
	
end

function NoPetParams:create()
    local params = NoPetParams.new()
    return params  
end

return NoPetParams
