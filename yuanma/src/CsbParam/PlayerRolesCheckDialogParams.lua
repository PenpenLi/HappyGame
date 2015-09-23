
local PlayerRolesCheckDialogParams = class("PlayerRolesCheckDialogParams")

function PlayerRolesCheckDialogParams:ctor()
  
    --角色界面（含背包界面）
 	self._pCCS = cc.CSLoader:createNode("PlayerRolesCheckDialog.csb")
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    self._pPlayer = self._pBackGround:getChildByName("Player")

    --昵称底板、昵称 
    self._pName_back = self._pBackGround:getChildByName("name_back")
    self._pName = self._pName_back:getChildByName("name")
    --更改昵称按钮
    self._pAddFriends = self._pName_back:getChildByName("AddFriends")
    --VIP按钮，点击弹出VIP详情   
    self._pVip_button = self._pName_back:getChildByName("vip_button")
    --当前玩家VIP等级数字   
    self._pVip_number = self._pVip_button:getChildByName("vip_number")
    --玩家等级后缀：级
    --self._pLevel = self._pName_back:getChildByName("level")
    --玩家等级数字   
    self._pLevel_number = self._pName_back:getChildByName("level_number")
    -- 战斗力底板
    self._pZhandouliBg = self._pBackGround:getChildByName("jsjm01")
    --战斗力艺术字  
    self._pZhandouli = self._pZhandouliBg:getChildByName("zhandouli")
    --战斗力数值   
    self._pZhandouli_number = self._pZhandouliBg:getChildByName("zhandouli_number")
    --切换至属性详情界面按钮   
    self._pExchange = self._pName_back:getChildByName("exchange")
    --切换至属性详情界面按钮文字
    self._pExchange_text = self._pExchange:getChildByName("exchange_text")
 
    --右侧节点
    self._pNodeRight = self._pBackGround:getChildByName("node_right")
    --战斗配置底板
    self._pEqiupRight = self._pNodeRight:getChildByName("EqiupRight")
    
    --技能配置底板
    self._pSkillBg = self._pEqiupRight:getChildByName("SkillBg")
    
    
    --宠物1底板
    self._pPetBg1 = self._pEqiupRight:getChildByName("PetBg1")
    --宠物1图标底板
    self._pIconBg1 = self._pPetBg1:getChildByName("IconBg")
    --宠物1没有的文字
    self._pNoPet1 = self._pPetBg1:getChildByName("TextNoPet")
    --宠物1图标
    self._pIcon1 = self._pIconBg1:getChildByName("Icon")
    --宠物1攻击力数值
    self._pAttack1 = self._pIconBg1:getChildByName("Attack")
    --宠物1生命值数值
    self._pHp1 = self._pIconBg1:getChildByName("Hp")
    --宠物1防御力数值
    self._pDefend1 = self._pIconBg1:getChildByName("Defend")
    --宠物1宠物类型
    self._pType1 = self._pIconBg1:getChildByName("Type")
    --宠物1品质级别
    self._pQuality1 = self._pIconBg1:getChildByName("Quality")
    --宠物1名称
    self._pName1 = self._pIconBg1:getChildByName("Name")
    --宠物1等级数值
    self._pLv1 = self._pIconBg1:getChildByName("Lv")
 
     --宠物2底板
    self._pPetBg2 = self._pEqiupRight:getChildByName("PetBg2")
    --宠物2图标底板
    self._pIconBg2 = self._pPetBg2:getChildByName("IconBg")
    --宠物2没有的文字
    self._pNoPet2 = self._pPetBg2:getChildByName("TextNoPet")
    --宠物2图标
    self._pIcon2 = self._pIconBg2:getChildByName("Icon")
    --宠物2攻击力数值
    self._pAttack2 = self._pIconBg2:getChildByName("Attack")
    --宠物2生命值数值
    self._pHp2 = self._pIconBg2:getChildByName("Hp")
    --宠物2防御力数值
    self._pDefend2 = self._pIconBg2:getChildByName("Defend")
    --宠物2宠物类型
    self._pType2 = self._pIconBg2:getChildByName("Type")
    --宠物2品质级别
    self._pQuality2 = self._pIconBg2:getChildByName("Quality")
    --宠物2名称
    self._pName2 = self._pIconBg2:getChildByName("Name")
    --宠物2等级数值
    self._pLv2 = self._pIconBg2:getChildByName("Lv")

    --宠物3底板
    self._pPetBg3 = self._pEqiupRight:getChildByName("PetBg3")
    --宠物3图标底板
    self._pIconBg3 = self._pPetBg3:getChildByName("IconBg")
    --宠物3没有的文字
    self._pNoPet3 = self._pPetBg3:getChildByName("TextNoPet")
    --宠物3图标
    self._pIcon3 = self._pIconBg3:getChildByName("Icon")
    --宠物3攻击力数值
    self._pAttack3 = self._pIconBg3:getChildByName("Attack")
    --宠物3生命值数值
    self._pHp3 = self._pIconBg3:getChildByName("Hp")
    --宠物3防御力数值
    self._pDefend3 = self._pIconBg3:getChildByName("Defend")
    --宠物3宠物类型
    self._pType3 = self._pIconBg3:getChildByName("Type")
    --宠物3品质级别
    self._pQuality3 = self._pIconBg3:getChildByName("Quality")
    --宠物3名称
    self._pName3 = self._pIconBg3:getChildByName("Name")
    --宠物3等级数值
    self._pLv3 = self._pIconBg3:getChildByName("Lv")

end

function PlayerRolesCheckDialogParams:create()
    local params = PlayerRolesCheckDialogParams.new()
    return params
end

return PlayerRolesCheckDialogParams


