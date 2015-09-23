--游戏的战斗界面
local VipBGParams = class("VipBGParams")

function VipBGParams:ctor()
    self._pCCS = cc.CSLoader:createNode("VipBG.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --vip进度条那个底板
    self._pVipBg = self._pBackGround:getChildByName("VipBg")
    --进度条
    self._pLoadingBar = self._pVipBg:getChildByName("LoadingBar")
    --vip等级，fnt数字，进度条提升时会变化
    self._pVipFnt = self._pVipBg:getChildByName("VipFnt")
    --返回按钮，点击返回到充值界面
    self._pBackButton = self._pVipBg:getChildByName("BackButton")
    --进度条提示数据 如5000/999
    self._pVipText01 = self._pVipBg:getChildByName("VipText01")
    --充值提示文字，还差 xxxx 即可升级
    self._pVipText02 = self._pVipBg:getChildByName("VipText02")
    --翻页容器，用来承载vip说明
    self._pPageView = self._pBackGround:getChildByName("PageView")
    --宝箱底板
    self._pChestBg = self._pBackGround:getChildByName("ChestBg")
    --宝箱按钮 点击时显示对应vip等级的奖励 读表，调用宝箱那个板子
    self._pChestButton = self._pChestBg:getChildByName("ChestButton")
    --左按钮，用来控制vip说明向左翻页
    self._pLeftButton = self._pBackGround:getChildByName("LeftButton")
    --右按钮，用来控制vip说明向右翻页
    self._pRightButton = self._pBackGround:getChildByName("RightButton")







end

function VipBGParams:create()
    local params = VipBGParams.new()
    return params  
end

return VipBGParams
