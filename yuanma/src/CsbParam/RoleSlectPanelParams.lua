--角色选择界面
local RoleSlectPanelParams = class("RoleSlectPanelParams")

function RoleSlectPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RoleSlectPanel.csb")

	-- 角色选择
    self._pCreatRolePoint = self._pCCS:getChildByName("CreatRolePoint")
    --选中效果框
    self._pEdging = self._pCreatRolePoint:getChildByName("Edging")
    --角色选择按钮1
    self._pCreatRoleButton001 = self._pCreatRolePoint:getChildByName("CreatRoleButton001")
    self._pCiKeButton1 = self._pCreatRolePoint:getChildByName("CiKeButton")
    self._pFaShiButton1 = self._pCreatRolePoint:getChildByName("FaShiButton")
    self._pZhanShiButton1 = self._pCreatRolePoint:getChildByName("ZhanShiButton")

    --角色信息
    self._pNameInfPoint =  self._pCCS:getChildByName("NameInfPoint")
    self._pInfBg =  self._pNameInfPoint:getChildByName("InfBg")
    self._pLvText =  self._pNameInfPoint:getChildByName("LvText")
    self._pNameText =  self._pNameInfPoint:getChildByName("NameText")
   
    --进入游戏
    self._pStartPoint =  self._pCCS:getChildByName("StartPoint")
    self._pStartGameBg = self._pStartPoint:getChildByName("StartGameBg")
    self._pStartGameButton = self._pStartPoint:getChildByName("StartGameButton")
    self._pReturnButton = self._pStartPoint:getChildByName("ReturnButton")
  
end

function RoleSlectPanelParams:create()
    local params = RoleSlectPanelParams.new()
    return params  
end

return RoleSlectPanelParams