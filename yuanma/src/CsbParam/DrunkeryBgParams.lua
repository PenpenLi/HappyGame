--游戏的战斗界面
local DrunkeryBgParams = class("DrunkeryBgParams")

function DrunkeryBgParams:ctor()
    self._pCCS = cc.CSLoader:createNode("DrunkeryBg.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")   
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --光顾好友酒坊按钮
    self._pGoFriendButton = self._pBackGround:getChildByName("GoFriendButton")
    --美人图底板01
    self._pBeautyBg01 = self._pBackGround:getChildByName("BeautyBg01")
    --美人图底板02
    self._pBeautyBg02 = self._pBeautyBg01:getChildByName("BeautyBg02")
    -- 美人的风景图
    self._pBeautyBackdropImg = self._pBeautyBg02:getChildByName("qfgjm17")
    -- 美人的图片
    self._pBeautyIcon = self._pBeautyBackdropImg:getChildByName("qfgjm18")
    --售卖酒类底板
    self._pBuyBg = self._pBeautyBg02:getChildByName("BuyBg")
    --正在售卖 4个字
    self._pBuyText = self._pBuyBg:getChildByName("BuyText")
    --正在售卖的酒品icon
    self._pBeerIcon = self._pBuyBg:getChildByName("BeerIcon")
    --开始售卖按钮，这个按钮上需要有倒计时
    self._pBeerButton = self._pBuyBg:getChildByName("BeerButton")
    --来访好友底板
    self._pClientBg = self._pBackGround:getChildByName("ClientBg")
    --来访顾客 4个字
    self._pSaleText = self._pClientBg:getChildByName("SaleText")
    --滚动列表
    self._pScrollView = self._pClientBg:getChildByName("ScrollView")
    --好友名称
    self._pFriendName = self._pScrollView:getChildByName("FriendName")
    --营业额底板
    self._pSaleBg = self._pBackGround:getChildByName("SaleBg")
    --营业额 3个字
    self._pSaleName01 = self._pSaleBg:getChildByName("SaleName01")
    --控制应收和道具显示/消失的那个node
    self._pNode000 = self._pSaleBg:getChildByName("Node000")
    --经验icon
    self._pExp = self._pNode000:getChildByName("Exp")
    --经验具体数值
    self._pExpText = self._pNode000:getChildByName("ExpText")
    --金币icon01
    self._pMoney01 = self._pNode000:getChildByName("Money01")
    --金币具体数值01
    self._pMoneyText01 = self._pNode000:getChildByName("MoneyText01")
    --金币icon02
    self._pMoney02 = self._pNode000:getChildByName("Money02")
    --金币具体数值02
    self._pMoneyText02 = self._pNode000:getChildByName("MoneyText02")
    --额外奖励 4个字
    self._pSaleName02 = self._pSaleBg:getChildByName("SaleName02")
    --全部领取按钮
    self._pOkButton01 = self._pSaleBg:getChildByName("OkButton01")
    --全部领取按钮文字，上面有倒计时
    self._pOkButtonText01 = self._pOkButton01:getChildByName("Text")
    --立刻完成按钮
    self._pOkButton02 = self._pSaleBg:getChildByName("OkButton02")
     --立刻完成按钮文字，上面要有玉璧icon
    self._pOkButtonText02 = self._pOkButton02:getChildByName("Text")
    --立刻完成按钮文字，上面要有玉璧icon
    self._pOKIcon = self._pOkButton02:getChildByName("OKIcon")


    --奖励物品icon01
    self._pItemIcon01 = self._pNode000:getChildByName("ItemIcon01")
    --奖励物品01的具体数量
    self._pItemText = self._pItemIcon01:getChildByName("ItemText")
    --奖励物品icon02
    self._pItemIcon02 = self._pNode000:getChildByName("ItemIcon02")
    --奖励物品02的具体数量
    self._pItemText = self._pItemIcon02:getChildByName("ItemText")
    --奖励物品icon03
    self._pItemIcon03 = self._pNode000:getChildByName("ItemIcon03")
    --奖励物品03的具体数量
    self._pItemText = self._pItemIcon03:getChildByName("ItemText")
    --左下货币那个node
    self._pFinancyNode = self._pBackGround:getChildByName("MoneyNode")
    --所用货币icon，默认放的是玉璧
    self._pFinancyIcon = self._pFinancyNode:getChildByName("financyIcon")
    --货币的具体数值
    self._pFinancyText = self._pFinancyNode:getChildByName("financyText")
    --对白底板
    self._pDialogueBg = self._pBackGround:getChildByName("DialogueBg")
    --对白01，没有卖酒的时候显示
    self._pDialogueText01 = self._pDialogueBg:getChildByName("DialogueText01")
    --对白02，卖酒的时候显示
    self._pDialogueText02 = self._pDialogueBg:getChildByName("DialogueText02")



    
end

function DrunkeryBgParams:create()
    local params = DrunkeryBgParams.new()
    return params  
end

return DrunkeryBgParams
