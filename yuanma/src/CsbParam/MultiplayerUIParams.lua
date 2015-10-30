--游戏的商城界面
local MultiplayerUIParams = class("MultiplayerUIParams")

function MultiplayerUIParams:ctor()
    self._pCCS = cc.CSLoader:createNode("MultiplayerUI.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pCCS:getChildByName("CloseButton")
	--总节点
    self._pNodeAll = self._pCCS:getChildByName("NodeAll")
    --体力进度条
    self._pLoadingBar = self._pNodeAll:getChildByName("LoadingBar")
    --进度条上的字
    self._pLoadingBarText = self._pNodeAll:getChildByName("LoadingBarText")
    --增加体力按钮
    self._pBuyButton = self._pNodeAll:getChildByName("BuyButton")
    --滚动容器
    self._pScrollView = self._pNodeAll:getChildByName("ScrollView")
    --副本背景节点
    self._pCopyBG = self._pCCS:getChildByName("CopyBG")
    --副本名称
    self._pName = self._pCopyBG:getChildByName("Name")
    --进入副本按钮
    self._pSureButton = self._pCopyBG:getChildByName("SureButton")
    --今日剩余次数的次数 3/3
    self._pTimeText02 = self._pCopyBG:getChildByName("TimeText02")
    --结算节点
    self._pNodeReward = self._pCCS:getChildByName("NodeReward")
    --物品奖励滑动ScrollView
    self._pRewardScrollView = self._pNodeReward:getChildByName("RewardScrollView")
    --货币奖励节点01
    self._pNodeMoneyIcon01 = self._pNodeReward:getChildByName("NodeMoneyIcon01")
    --货币奖励节点01的icon
    self._pMoneyIcon01 = self._pNodeMoneyIcon01:getChildByName("MoneyIcon01")
    --货币奖励节点01的个数
    self._pMIconText01 = self._pMoneyIcon01:getChildByName("MIconText01")
    --货币奖励节点02
    self._pNodeMoneyIcon02 = self._pNodeReward:getChildByName("NodeMoneyIcon02")
    --货币奖励节点02的icon
    self._pMoneyIcon02 = self._pNodeMoneyIcon02:getChildByName("MoneyIcon02")
    --货币奖励节点02的个数
    self._pMIconText02 = self._pMoneyIcon02:getChildByName("MIconText02")
    --货币奖励节点03
    self._pNodeMoneyIcon03 = self._pNodeReward:getChildByName("NodeMoneyIcon03")
    --货币奖励节点03的icon
    self._pMoneyIcon03 = self._pNodeMoneyIcon03:getChildByName("MoneyIcon03")
    --货币奖励节点03的个数
    self._pMIconText03 = self._pMoneyIcon03:getChildByName("MIconText03")



    --颜色管理
    --cFontDarkRed = cc.c4b(93, 35, 35, 255)              -- 暗红色
    --控件颜色
    --button01:getTitleRenderer():setTextColor(cFontDarkRed)



    
end

function MultiplayerUIParams:create()
    local params = MultiplayerUIParams.new()
    return params  
end

return MultiplayerUIParams
