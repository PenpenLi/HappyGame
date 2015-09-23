--游戏的战斗界面
local BearOneParams = class("BearOneParams")

function BearOneParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BearOne.csb")

	--背景板
    self._pBearOneBg = self._pCCS:getChildByName("BearOneBg")
    --美人icon
    self._pBeautyIcon = self._pBearOneBg:getChildByName("BeautyIcon")
    --酒类icon
    self._pBearIcon = self._pBearOneBg:getChildByName("BearIcon")
    --酒类名字
    self._pBearName = self._pBearOneBg:getChildByName("BearName")
    --奖励货币icon01，默认是经验
    self._pMoneyIcon01 = self._pBearOneBg:getChildByName("MoneyIcon01")
    --奖励货币01，具体数值
    self._pMoney0101 = self._pBearOneBg:getChildByName("Money0101")
    --奖励货币01，附加值的具体数值，这后面固定要有“*顾客”字样
    self._pMoney0102 = self._pBearOneBg:getChildByName("Money0102")
    --奖励货币icon02，默认是金币
    self._pMoneyIcon02 = self._pBearOneBg:getChildByName("MoneyIcon02")
    --奖励货币02，具体数值
    self._pMoney0201 = self._pBearOneBg:getChildByName("Money0201")
    --奖励货币02，附加值的具体数值，这后面固定要有“*顾客”字样
    self._pMoney0202 = self._pBearOneBg:getChildByName("Money0202")
    --用时 2个字
    self._pTime0101 = self._pBearOneBg:getChildByName("Time0101")
    --用时具体时间
    self._pTime0102 = self._pBearOneBg:getChildByName("Time0102")
    --必要等级，“LV：”字样之后是具体值
    self._pLv = self._pBearOneBg:getChildByName("Lv")



    
end

function BearOneParams:create()
    local params = BearOneParams.new()
    return params  
end

return BearOneParams
