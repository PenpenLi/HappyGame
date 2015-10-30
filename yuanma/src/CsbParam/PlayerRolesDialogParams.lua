
local PlayerRolesDialogParams = class("PlayerRolesDialogParams")

function PlayerRolesDialogParams:ctor()
  
    --角色界面（含背包界面）
 	self._pCCS = cc.CSLoader:createNode("PlayerRolesDialog.csb")
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")

    --角色的挂在node
    self._pRoleInfoNode = self._pBackGround:getChildByName("RoleInfoNode")
      --属性按钮  
    self._pExchange = self._pBackGround:getChildByName("exchange")
    --包裹按钮
    self._pBaoGuo = self._pBackGround:getChildByName("BaoGuo")
    --3d模型挂在层
    self._pPlayer = self._pRoleInfoNode:getChildByName("Player")
    --右侧节点
    self._pNodeRight = self._pBackGround:getChildByName("node_right")

    --昵称底板、昵称 
    self._pName_back = self._pRoleInfoNode:getChildByName("name_back")
    self._pName = self._pName_back:getChildByName("name")
    --玩家等级数字   
    self._pLevel_number = self._pName_back:getChildByName("level_number")
    --战斗力艺术字  
    self._pZhandouli = self._pName_back:getChildByName("zhandouli")
    --战斗力数值   
    self._pZhandouli_number = self._pZhandouli:getChildByName("zhandouli_number")

    --装备槽1
    self._pEqu1 = self._pRoleInfoNode:getChildByName("Sprite_1")
     --装备槽2
    self._pEqu2 = self._pRoleInfoNode:getChildByName("Sprite_2")
     --装备槽3
    self._pEqu3 = self._pRoleInfoNode:getChildByName("Sprite_3")
     --装备槽4
    self._pEqu4 = self._pRoleInfoNode:getChildByName("Sprite_4")
     --装备槽5
    self._pEqu5 = self._pRoleInfoNode:getChildByName("Sprite_5")
     --装备槽6
    self._pEqu6 = self._pRoleInfoNode:getChildByName("Sprite_6")
     --装备槽7
    self._pEqu7 = self._pRoleInfoNode:getChildByName("Sprite_7")
     --装备槽8
    self._pEqu8 = self._pRoleInfoNode:getChildByName("Sprite_8")
     --装备槽1
    self._pEqu9 = self._pRoleInfoNode:getChildByName("Sprite_9")
     --装备槽1
    self._pEqu10 = self._pRoleInfoNode:getChildByName("Sprite_10")

    self._tEquALlNode = {self._pEqu1, self._pEqu2, self._pEqu3, self._pEqu4, self._pEqu5, self._pEqu6, self._pEqu7, self._pEqu8, self._pEqu9, self._pEqu10}
    

--粗略三属性  
    self._pAttack_back = self._pPlayer:getChildByName("attack_back")
    self._pAttack_number = self._pAttack_back:getChildByName("attack_number")
    self._pHp_back = self._pPlayer:getChildByName("hp_back")
    self._pHp_number = self._pHp_back:getChildByName("hp_number")
    self._pDefend_back = self._pPlayer:getChildByName("defend_back")
    self._pDefend_number = self._pDefend_back:getChildByName("defend_number")

    
end

function PlayerRolesDialogParams:create()
    local params = PlayerRolesDialogParams.new()
    return params
end

return PlayerRolesDialogParams


