--家园当前未激活的buff
local BuffweiParams = class("BuffweiParams")

function BuffweiParams:ctor()
    self._pCCS = cc.CSLoader:createNode("Buffwei.csb")
	--背景板
    self._pBuffBg = self._pCCS:getChildByName("BuffBg")
	--图标底板
	self._pIconBg = self._pBuffBg:getChildByName("IconBg")
	--图标
    self._pIcon = self._pBuffBg:getChildByName("Icon")
    --技能名称
    self._pNameText = self._pBuffBg:getChildByName("NameText")
    --技能等级
    self._pLvText = self._pBuffBg:getChildByName("LvText")
    --技能说明
    self._pSmText = self._pBuffBg:getChildByName("SmText")
    --技能条件
    self._pTjText = self._pBuffBg:getChildByName("TjText")
    --按钮挂点
    self._pButtonNode = self._pBuffBg:getChildByName("ButtonNode")
    --激活按钮
    self._pButton_1 = self._pButtonNode:getChildByName("Button_1")
    --升级按钮
    self._pButton_2 = self._pButtonNode:getChildByName("Button_2")
end

function BuffweiParams:create()
    local params = BuffweiParams.new()
    return params  
end

return BuffweiParams
