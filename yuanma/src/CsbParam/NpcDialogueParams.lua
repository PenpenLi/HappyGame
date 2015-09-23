--NPC对话框
local NpcDialogueParams = class("NpcDialogueParams")

function NpcDialogueParams:ctor()
    self._pCCS = cc.CSLoader:createNode("NpcDialogue.csb")
	--背景板
    self._pDialogueBg = self._pCCS:getChildByName("DialogueBg")
	--角色挂点
	self._pRoleNode = self._pDialogueBg:getChildByName("RoleNode")
	--Npc名称
	self._pNpcNameText = self._pDialogueBg:getChildByName("NpcNameText")
	--Npc对话
	self._pDialogueText = self._pDialogueBg:getChildByName("DialogueText")
	--功能按钮
	self._pFunctionButton = self._pDialogueBg:getChildByName("FunctionButton")
	
end

function NpcDialogueParams:create()
    local params = NpcDialogueParams.new()
    return params  
end

return NpcDialogueParams
