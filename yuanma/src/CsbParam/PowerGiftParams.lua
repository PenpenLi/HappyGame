--体力赠送界面
local PowerGiftParams = class("PowerGiftParams")

function PowerGiftParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PowerGift.csb")
	--背景底板
    self._pPowerGiftBg = self._pCCS:getChildByName("PowerGiftBg")
    -- 礼品1的图标
    self._pGift1Icon = self._pPowerGiftBg:getChildByName("FoodPics1")
    -- 礼品2的图标
    self._pGift2Icon = self._pPowerGiftBg:getChildByName("FoodPics2")
    --领取时间段1
    self._pPowerTextTime1 = self._pPowerGiftBg:getChildByName("PowerTextTime1")
    --时间段1体力值
    self._pPowerTextNum1 = self._pPowerGiftBg:getChildByName("PowerTextNum1")
    --时间段1领取按钮
    self._pLQButton1 = self._pPowerGiftBg:getChildByName("LQButton1")
    --时间段1红点
    self._pRedPics1 = self._pPowerGiftBg:getChildByName("RedPics1")
    --领取时间段2
    self._pPowerTextTime1_Copy = self._pPowerGiftBg:getChildByName("PowerTextTime1_Copy")
    --时间段2体力值
    self._pPowerTextNum2 = self._pPowerGiftBg:getChildByName("PowerTextNum2")
    --时间段2领取按钮
    self._pLQButton1_Copy = self._pPowerGiftBg:getChildByName("LQButton1_Copy")
    --时间段2红点
    self._pRedPics2 = self._pPowerGiftBg:getChildByName("RedPics2")
    --不同时间段显示文字
    self._ptishiText1 = self._pPowerGiftBg:getChildByName("tishiText1")
    
    
end

function PowerGiftParams:create()
    local params = PowerGiftParams.new()
    return params  
end

return PowerGiftParams
