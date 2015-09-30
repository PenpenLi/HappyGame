--宠物共鸣左侧板子
local PetGmingParams = class("PetGmingParams")

function PetGmingParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PetGming.csb")
	--进阶背景底板
    self._pGmingBg = self._pCCS:getChildByName("GmingBg")
    --共鸣列表滚动框
    self._pScrollView_1 = self._pGmingBg:getChildByName("ScrollView_1")
    
    
end

function PetGmingParams:create()
    local params = PetGmingParams.new()
    return params  
end

return PetGmingParams
