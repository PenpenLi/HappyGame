--副本界面
local PvpHuashanDialogParams = class("PvpHuashanDialogParams")

function PvpHuashanDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PvpHuashanDialog.csb")

	-- 底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --帮助说明按钮
    self._pF1= self._pBackGround:getChildByName("F1") 
    --战斗按钮
    self._pFightButton= self._pBackGround:getChildByName("FightButton") 
    
    --当前玩家金币 底板
    self._pMoneyBg1 = self._pBackGround:getChildByName("MoneyBg1") 
    --当前玩家金币 Icon
    self._pMoneyIcon1 = self._pMoneyBg1 :getChildByName("MoneyIcon1") 
    --当前玩家金币数量
    self._pMoneyNum1 = self._pMoneyBg1 :getChildByName("MoneyNum1") 
    --当前玩家钻石 底板
    self._pMoneyBg2 = self._pBackGround:getChildByName("MoneyBg2") 
    --当前玩家钻石 Icon
    self._pMoneyIcon2 = self._pMoneyBg2 :getChildByName("MoneyIcon2") 
    --当前玩家钻石数量
    self._pMoneyNum2 = self._pMoneyBg2 :getChildByName("MoneyNum2") 


    --左侧选人总node
    self._pSelectNode = self._pBackGround:getChildByName("SelectNode")  

    --当前选中的人物底板
    self._pPlayer = self._pBackGround:getChildByName("Player") 
    -- 人物模型挂载的节点
    self._pvperModelNode = self._pPlayer:getChildByName("modelNode")
    --当前选中的人物昵称底板
    self._pnameback = self._pPlayer:getChildByName("name_back")
    --当前选中的人物已被战胜的标记
    self._pdefeated = self._pPlayer:getChildByName("defeated")

    --当前选中的人物昵称
    self._pname = self._pnameback:getChildByName("name")
    --当前选中的人物vip按钮
    self._pvipbutton = self._pnameback:getChildByName("vip_button") 
    --当前选中的人物VIP等级
    self._pvipnumber = self._pvipbutton:getChildByName("vip_number")
 
    --当前选中的等级文字
    self._plevel = self._pnameback:getChildByName("level")  
    --当前选中的等级数字
    self._plevelnumber = self._plevel:getChildByName("level_number") 
    
    --当前选中的人物战斗力数值
    self._pzhandoulinumber = self._pnameback:getChildByName("zhandouli_number")
    

    --当前选中人物的查看按钮
    self._pDetailsButton = self._pnameback:getChildByName("Details")   
    
    --当前选中人物的查看按钮
    self._pRewardBg = self._pPlayer:getChildByName("RewardBg")   

    --当前选中战胜奖励底板1
    self._pItem1= self._pRewardBg:getChildByName("Item1") 
    --当前选中战胜奖励Icon1
    self._pItemIcon1= self._pRewardBg:getChildByName("ItemIcon11") 
    --当前选中战胜奖励Num1
    self._pItemNum1= self._pItem1:getChildByName("ItemNum1")
    
    --当前选中战胜奖励底板2
    self._pItem2= self._pRewardBg:getChildByName("Item2") 
    --当前选中战胜奖励Icon2
    self._pItemIcon2= self._pRewardBg:getChildByName("ItemIcon22") 
    --当前选中战胜奖励Num2
    self._pItemNum2= self._pItem2:getChildByName("ItemNum2")
    
    --当前选中战胜奖励底板3
    self._pItem3= self._pRewardBg:getChildByName("Item3") 
    --当前选中战胜奖励Icon3
    self._pItemIcon3= self._pRewardBg:getChildByName("ItemIcon33") 
    --当前选中战胜奖励Num3
    self._pItemNum3= self._pItem3:getChildByName("ItemNum3")
    
   

    --当前鼓舞底板
    self._pInspireBg = self._pBackGround:getChildByName("InspireBg") 
    --当前鼓舞等级
    self._pInspireLv = self._pInspireBg:getChildByName("InspireLv")
    --当前鼓舞进度条底板
    self._pLoadingBarBg = self._pInspireBg:getChildByName("LoadingBarBg")
    --当前鼓舞进度条
    self._pLoadingBar = self._pLoadingBarBg:getChildByName("LoadingBar")
    --当前等级鼓舞加成的文字说明
    self._pInspireText = self._pInspireBg:getChildByName("InspireText")
    
    --下方鼓舞按钮的node
    self._pInspireNode = self._pInspireBg:getChildByName("InspireNode")
    --金币鼓舞按钮
    self._pInspireButton1 = self._pInspireNode:getChildByName("InspireButton1")
    --玉璧鼓舞按钮
    self._pInspireButton2 = self._pInspireNode:getChildByName("InspireButton2")
    --当前等级金币鼓舞一次的消耗
    self._pInspireMoneyNum1 = self._pInspireNode:getChildByName("MoneyNum1")
    --当前等级玉璧鼓舞一次的消耗
    self._pInspireMoneyNum2 = self._pInspireNode:getChildByName("MoneyNum2")


    --鼓舞满级提示文字
    self._pText_LvMax = self._pInspireBg:getChildByName("Text_LvMax")


  

end

function PvpHuashanDialogParams:create()
    local params = PvpHuashanDialogParams.new()
    return params  
end

return PvpHuashanDialogParams
