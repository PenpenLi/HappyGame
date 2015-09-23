
local PlayerRolesDialogParams = class("PlayerRolesDialogParams")

function PlayerRolesDialogParams:ctor()
  
 --角色界面（含背包界面）
 	self._pCCS = cc.CSLoader:createNode("PlayerRolesDialog.csb")
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    self._pPlayer = self._pBackGround:getChildByName("Player")
 --右侧节点
    self._pNodeRight = self._pBackGround:getChildByName("node_right")
 --昵称底板、昵称 
    self._pName_back = self._pBackGround:getChildByName("name_back")
    self._pName = self._pName_back:getChildByName("name")
 --玩家等级前缀:Lv
 --self._pLevel = self._pName_back:getChildByName("level")
 --玩家等级数字   
    self._pLevel_number = self._pName_back:getChildByName("level_number")
 --更改昵称按钮
    self._pChange_name = self._pName_back:getChildByName("change_name")
 --VIP按钮，点击弹出VIP详情   
    self._pVip_button = self._pName_back:getChildByName("vip_button")
 --当前玩家VIP等级数字   
    self._pVip_number = self._pVip_button:getChildByName("vip_number")
 --经验进度条底板   
    self._pExp_bar = self._pName_back:getChildByName("exp_bar")
 --经验进度条   
    self._pExp_bar2 = self._pExp_bar:getChildByName("exp_bar2")
 --当前等级经验数值，xxx/xxxx  
    self._pExp_number = self._pName_back:getChildByName("exp_number")
 --战斗力艺术字  
    self._pZhandouli = self._pName_back:getChildByName("zhandouli")
 --战斗力数值   
    self._pZhandouli_number = self._pZhandouli:getChildByName("zhandouli_number")
 --切换至背包界面按钮   
    self._pExchange = self._pName_back:getChildByName("exchange")
 --切换至背包界面按钮文字：切至背包   
    self._pExchange_text = self._pExchange:getChildByName("exchange_text")
 --角色点击层  
    self._pRolesClickPanel = self._pPlayer:getChildByName("RolesClickPanel") 

 --右侧属性普通容器   
    self._pShuxing = self._pBackGround:getChildByName("shuxing")
 --右侧背包列表容器   
    self._pBox = self._pBackGround:getChildByName("box")
    
end

function PlayerRolesDialogParams:create()
    local params = PlayerRolesDialogParams.new()
    return params
end

return PlayerRolesDialogParams


