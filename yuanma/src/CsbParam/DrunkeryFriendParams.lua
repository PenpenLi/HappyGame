--游戏的战斗界面
local DrunkeryFriendParams = class("DrunkeryFriendParams")

function DrunkeryFriendParams:ctor()
    self._pCCS = cc.CSLoader:createNode("DrunkeryFriend.csb")

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
    --正在售卖的酒品icon
    self._pBeerIcon = self._pBuyBg:getChildByName("BeerIcon")
    --喝个痛快按钮 上面要有金币icon和金额数
    self._pBeerButton = self._pBuyBg:getChildByName("BearButton")
    
 
    --金币icon
    self._pBearBuyIcon = self._pBeerButton:getChildByName("BearBuyIcon")
    --金额数 包括购买文字
    self._pBuyNum = self._pBeerButton:getChildByName("BuyNum")





    -- 收益背景底图
    self._pBeerTipImg = self._pBuyBg:getChildByName("tips001")
    --喝酒收益0101，显示收益icon1，默认是经验
    self._pBearBuy0101 = self._pBeerTipImg:getChildByName("BearBuy0101")
    --喝酒收益0102 具体数值
    self._pBearBuy0102 = self._pBeerTipImg:getChildByName("BearBuy0102")
    --喝酒收益0201，显示收益icon2，默认是金币
    self._pBearBuy0201 = self._pBeerTipImg:getChildByName("BearBuy0201")
    --喝酒收益0202 具体数值
    self._pBearBuy0202 = self._pBeerTipImg:getChildByName("BearBuy0202")
    --好友列表底板
    self._pFriendBg = self._pBackGround:getChildByName("FriendBg")
    --滚动列表
    self._pScrollView = self._pFriendBg:getChildByName("ScrollView")
    --一键喝光按钮
    self._pOneButton = self._pFriendBg:getChildByName("OneButton")
    --饮酒次数 4个字
    self._pDrinkText01 = self._pFriendBg:getChildByName("DrinkText01")
    --饮酒次数 数值，显示是10/10
    self._pDrinkText02 = self._pFriendBg:getChildByName("DrinkText02")
    --左下货币那个node
    self._pMoneyNode = self._pBackGround:getChildByName("MoneyNode")
    --所用货币icon，默认放的是金币
    self._pMoneyIcon = self._pMoneyNode:getChildByName("MoneyIcon")
    --货币的具体数值
    self._pMoneyText = self._pMoneyNode:getChildByName("MoneyText")
    --对白底板
    self._pDialogueBg = self._pBackGround:getChildByName("DialogueBg")
    --对白01，没有卖酒的时候显示
    self._pDialogueText01 = self._pDialogueBg:getChildByName("DialogueText01")
    --对白02，卖酒的时候显示
    self._pDialogueText02 = self._pDialogueBg:getChildByName("DialogueText02")
   


end

function DrunkeryFriendParams:create()
    local params = DrunkeryFriendParams.new()
    return params  
end

return DrunkeryFriendParams
