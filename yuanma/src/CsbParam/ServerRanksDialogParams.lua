--服务器排队面板
local ServerRanksDialogParams = class("ServerRanksDialogParams")

function ServerRanksDialogParams:ctor()
  
    self._pCCS = cc.CSLoader:createNode("ServerRanksDialog.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
	--关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
   
	--服务器名字
	self._pServerNameText = self._pBackGround:getChildByName("ServerNameText")
	--队列排名
	self._pRoleNum = self._pBackGround:getChildByName("RoleNum")
	--总排队玩家
	self._pRoleNumSum = self._pBackGround:getChildByName("RoleNumSum")
	--退出排队
    self._pOkButton = self._pBackGround:getChildByName("OkButton")
	
end

function ServerRanksDialogParams:create()
    local params = ServerRanksDialogParams.new()
    return params  
end

return ServerRanksDialogParams
