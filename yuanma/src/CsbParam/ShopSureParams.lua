--游戏的战斗界面
local ShopSureParams = class("ShopSureParams")

function ShopSureParams:ctor()
    self._pCCS = cc.CSLoader:createNode("ShopSure.csb")

	--背景板
    self._pShopSureBG = self._pCCS:getChildByName("ShopSureBG")
    --核心节点
    self._pNodeAll = self._pCCS:getChildByName("NodeAll")
    --商品名称（字体颜色根据品质变化）
    self._pName = self._pNodeAll:getChildByName("Name")
    --商品icon
    self._pIcon = self._pNodeAll:getChildByName("Icon")
    --商品icon边框
    self._pIconP = self._pNodeAll:getChildByName("IconP")
    --商品icon底版背景
    self._pIconBG = self._pNodeAll:getChildByName("IconBG")
    --取消按钮
    self._pNoButton = self._pNodeAll:getChildByName("NoButton")
    --确定按钮
    self._pYesButton = self._pNodeAll:getChildByName("YesButton")
    --增加数量按钮
    self._pUpButton = self._pNodeAll:getChildByName("UpButton")
    --减少数量按钮
    self._pDownButton = self._pNodeAll:getChildByName("DownButton")
    --使用货币icon（可能要隐藏）
    self._pMoneyIcon = self._pNodeAll:getChildByName("MoneyIcon")
    --购买物品数量
    self._pMoneyText01 = self._pNodeAll:getChildByName("MoneyText01")
    --花费总金额（可能要隐藏）
    self._pMoneyText02 = self._pNodeAll:getChildByName("MoneyText02")
    --总价处底框（可能要隐藏）
    self._pbg01 = self._pNodeAll:getChildByName("bg01")
    --总价 2个字（可能要隐藏）
    self._pText02 = self._pNodeAll:getChildByName("Text02")
    --购买数量 4个字（可能要变字）
    self._pText01 = self._pNodeAll:getChildByName("Text01")


    --颜色管理
    cFontDarkRed = cc.c4b(93, 35, 35, 255)              -- 暗红色
    --控件颜色
    self._pText02:setTextColor(cFontDarkRed)
    self._pText01:setTextColor(cFontDarkRed)

     

    
end

function ShopSureParams:create()
    local params = ShopSureParams.new()
    return params  
end

return ShopSureParams
