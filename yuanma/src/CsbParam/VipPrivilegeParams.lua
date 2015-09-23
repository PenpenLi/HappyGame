--家园当前未激活的buff
local VipPriviegeParams = class("VipPrivilegeParams")

function VipPrivilegeParams:ctor()
    self._pCCS = cc.CSLoader:createNode("VipPrivilege.csb")
	--背景板
    self._pVipTips = self._pCCS:getChildByName("VipTips")
    --按钮
    self._pYes = self._pVipTips:getChildByName("Yes")	
	self._pNo = self._pVipTips:getChildByName("No")
	--文本节点
    self._pNode_9 = self._pVipTips:getChildByName("Node_9")
    --文本
    self._pText_V1_1 = self._pNode_9:getChildByName("Text_V1_1")
    self._pText_V1_2 = self._pNode_9:getChildByName("Text_V1_2")
    self._pText_V2_1 = self._pNode_9:getChildByName("Text_V2_1")
    
    
end
function VipPrivilegeParams:create()
    local params = VipPrivilegeParams.new()
    return params  
end
return VipPrivilegeParams
