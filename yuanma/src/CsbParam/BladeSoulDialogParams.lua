--装备相关的大底板
local BladeSoulDialogParams = class("BladeSoulDialogParams")

function BladeSoulDialogParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BladeSoulDialog.csb")
    --大底板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton") 
    
    --炼化标签
    self._pTabButton1 = self._pBackGround:getChildByName("TabButton1")
    --吞噬标签
    self._pTabButton2 = self._pBackGround:getChildByName("TabButton2")
  
    
    --玩家已拥有剑魂数
    self._pBladeSoulNumber = self._pBackGround:getChildByName("BladeSoulNumber")
    --右侧半边底板
    self._pRightFrame = self._pBackGround:getChildByName("RightFrame")
    --右侧滚动框
    self._pRightScrollView = self._pRightFrame:getChildByName("RightScrollView")
    

    --炼化的总挂点
    self._pNodeQueue = self._pBackGround:getChildByName("Node_Queue")
    --第一个炼化小板子挂点
    self._pQueuePoint1 = self._pNodeQueue:getChildByName("QueuePoint1")
     --第二个炼化小板子挂点
    self._pQueuePoint2 = self._pNodeQueue:getChildByName("QueuePoint2")
     --第三个炼化小板子挂点
    self._pQueuePoint3 = self._pNodeQueue:getChildByName("QueuePoint3")
     --第四个炼化小板子挂点
    self._pQueuePoint4 = self._pNodeQueue:getChildByName("QueuePoint4") 
    --钻石底板
    self._pIconMoney = self._pNodeQueue:getChildByName("MoneyBg") 
    --当前玩家钻石总数
    self._pMoneyText = self._pIconMoney:getChildByName("MoneyText") 
    --购买剑灵丹按钮
    self._pTabButtonBuy = self._pNodeQueue:getChildByName("Button_4")
    --一键炼化按钮
    self._pOneKeyRefinery= self._pNodeQueue:getChildByName("Button_4One")
    
    --吞噬后属性的总挂点
    self._pBladeSoulEat = self._pBackGround:getChildByName("BladeSoulEat")
    --获得剑魂按钮
    self._pGetJhButton = self._pBladeSoulEat:getChildByName("GetJhButton")
    --一键吞噬按钮
    self._pOneKeySwallow = self._pBladeSoulEat:getChildByName("GetJhButtonOne")
    
    --生命值一大套   背景1
    self._pBack1 = self._pBladeSoulEat:getChildByName("Back1")
    --当前属性1的值
    self._pCurrAttr1 = self._pBack1:getChildByName("Number11")
    --当前属性1的上限值
    self._pMaxAttr1 = self._pBack1:getChildByName("Number12")
    --属性1进度条背景
    self._pLoadingBack1 = self._pBack1:getChildByName("LoadingBack1")
    --属性1进度条
    self._pLoadingBar1 = self._pLoadingBack1:getChildByName("LoadingBar1")
    --当前属性1的title
    self._pTitle1 = self._pBack1:getChildByName("Title1")


    --攻击力一大套   背景2
    self._pBack2 = self._pBladeSoulEat:getChildByName("Back2")
    --当前属性2的值
    self._pCurrAttr2 = self._pBack2:getChildByName("Number21")
    --当前属性2的上限值
    self._pMaxAttr2 = self._pBack2:getChildByName("Number22")
    --属性2进度条背景
    self._pLoadingBack2 = self._pBack2:getChildByName("LoadingBack2")
    --属性2进度条
    self._pLoadingBar2 = self._pLoadingBack2:getChildByName("LoadingBar2")
    --当前属性2的title
    self._pTitle2 = self._pBack2:getChildByName("Title2")


    --防御力一大套   背景3
    self._pBack3 = self._pBladeSoulEat:getChildByName("Back3")
    --当前属性3的值
    self._pCurrAttr3 = self._pBack3:getChildByName("Number31")
    --当前属性3的上限值
    self._pMaxAttr3 = self._pBack3:getChildByName("Number32")
    --属性3进度条背景
    self._pLoadingBack3 = self._pBack3:getChildByName("LoadingBack3")
    --属性3进度条
    self._pLoadingBar3 = self._pLoadingBack3:getChildByName("LoadingBar3")
    --当前属性3的title
    self._pTitle3 = self._pBack3:getChildByName("Title3")


    --暴击几率一大套   背景4    要填写百分比
    self._pBack4 = self._pBladeSoulEat:getChildByName("Back4")
    --当前属性4的值
    self._pCurrAttr4 = self._pBack4:getChildByName("Number41")
    --当前属性4的上限值
    self._pMaxAttr4 = self._pBack4:getChildByName("Number42")
    --属性4进度条背景
    self._pLoadingBack4 = self._pBack4:getChildByName("LoadingBack4")
    --属性4进度条
    self._pLoadingBar4 = self._pLoadingBack4:getChildByName("LoadingBar4")
    --当前属性4的title
    self._pTitle4 = self._pBack4:getChildByName("Title4")



    --暴击伤害一大套   背景5    要填写百分比
    self._pBack5 = self._pBladeSoulEat:getChildByName("Back5")
    --当前属性5的值
    self._pCurrAttr5 = self._pBack5:getChildByName("Number51")
    --当前属性5的上限值
    self._pMaxAttr5 = self._pBack5:getChildByName("Number52")
    --属性5进度条背景
    self._pLoadingBack5 = self._pBack5:getChildByName("LoadingBack5")
    --属性5进度条
    self._pLoadingBar5 = self._pLoadingBack5:getChildByName("LoadingBar5")
    --当前属性5的title
    self._pTitle5 = self._pBack5:getChildByName("Title5")



    --韧性一大套   背景6
    self._pBack6 = self._pBladeSoulEat:getChildByName("Back6")
    --当前属性6的值
    self._pCurrAttr6 = self._pBack6:getChildByName("Number61")
    --当前属性6的上限值
    self._pMaxAttr6 = self._pBack6:getChildByName("Number62")
    --属性6进度条背景
    self._pLoadingBack6 = self._pBack6:getChildByName("LoadingBack6")
    --属性6进度条
    self._pLoadingBar6 = self._pLoadingBack6:getChildByName("LoadingBar6")
    --当前属性6的title
    self._pTitle6 = self._pBack6:getChildByName("Title6")



    --抗性一大套   背景7
    self._pBack7 = self._pBladeSoulEat:getChildByName("Back7")
    --当前属性7的值
    self._pCurrAttr7 = self._pBack7:getChildByName("Number71")
    --当前属性7的上限值
    self._pMaxAttr7 = self._pBack7:getChildByName("Number72")
    --属性7进度条背景
    self._pLoadingBack7 = self._pBack7:getChildByName("LoadingBack7")
    --属性7进度条
    self._pLoadingBar7 = self._pLoadingBack7:getChildByName("LoadingBar7")
    --当前属性7的title
    self._pTitle7 = self._pBack7:getChildByName("Title7")




    
    
end

function BladeSoulDialogParams:create()
    local params = BladeSoulDialogParams.new()
    return params
end

return BladeSoulDialogParams
