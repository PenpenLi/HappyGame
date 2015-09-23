--创建角色面板
local CreatRolePanelParams = class("CreatRolePanelParams")

function CreatRolePanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("CreatRolePanel.csb")

	-- 职业选择
    self._pJobSlect = self._pCCS:getChildByName("JobSlect")
    --选中效果框
    self._pEdging = self._pJobSlect:getChildByName("Edging")
    --战士
    self._pWarriorButton = self._pJobSlect:getChildByName("WarriorButton")
    --法师
    self._pMasterButton = self._pJobSlect:getChildByName("MasterButton")
    --刺客
    self._pThugButton = self._pJobSlect:getChildByName("ThugButton")
    --职业图标
    self._pCiKe3 =  self._pThugButton:getChildByName("CiKe3")
    self._pZhanShi1 =  self._pWarriorButton:getChildByName("ZhanShi1")
    self._pFaShi2 =  self._pMasterButton:getChildByName("FaShi2")
    --随机昵称
 	self._pRandomNamePoint =  self._pCCS:getChildByName("RandomNamePoint")
    self._pStartGameBg = self._pRandomNamePoint:getChildByName("StartGameBg")
 	
    --随机昵称底板
    self._pNameFrame = self._pRandomNamePoint:getChildByName("NameFrame")
    --随机昵称
    self._pNameNode = self._pNameFrame:getChildByName("NameNode")
    --确定按钮
    self._pOKFrame = self._pRandomNamePoint:getChildByName("OkButton")
    --随机按钮
    self._pNameFrame = self._pRandomNamePoint:getChildByName("RandomButton")
    --返回按钮
    self._pBackButton = self._pRandomNamePoint:getChildByName("ReturnButton")
   
   --职业说明
    self._pInfPoint =  self._pCCS:getChildByName("InfPoint")
    --职业说明底板
    self._pImage_3 =  self._pInfPoint:getChildByName("Image_3")
	--刺客职业图标
	self._pCiKeIcon3 =  self._pImage_3:getChildByName("CiKeIcon3")
	self._pZhanShiIcon1 =  self._pImage_3:getChildByName("ZhanShiIcon1")
	self._pFaShiIcon2 =  self._pImage_3:getChildByName("FaShiIcon2")
  	--成长图
  	self._pCiKeCz3 =  self._pImage_3:getChildByName("CiKeCz3")
  	self._pZhanShiCz1 =  self._pImage_3:getChildByName("ZhanShiCz1")
  	self._pFaShiCz2 =  self._pImage_3:getChildByName("FaShiCz2")
  	--操作难易程度
  	self._pStartImage001 =  self._pImage_3:getChildByName("StartImage001")
    self._pStartImage002 =  self._pImage_3:getChildByName("StartImage002")
    self._pStartImage003 =  self._pImage_3:getChildByName("StartImage003")
    self._pStartImage004 =  self._pImage_3:getChildByName("StartImage004")
    self._pStartImage005 =  self._pImage_3:getChildByName("StartImage005")
    self._pStartImage006 =  self._pImage_3:getChildByName("StartImage006")
    self._pStartImage007 =  self._pImage_3:getChildByName("StartImage007")
    self._pStartImage008 =  self._pImage_3:getChildByName("StartImage008")
    self._pStartImage009 =  self._pImage_3:getChildByName("StartImage009")
    self._pStartImage010 =  self._pImage_3:getChildByName("StartImage010")
end

function CreatRolePanelParams:create()
    local params = CreatRolePanelParams.new()
    return params  
end

return CreatRolePanelParams
 
