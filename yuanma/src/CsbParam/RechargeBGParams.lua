--游戏的战斗界面
local RechargeBGParams = class("RechargeBGParams")

function RechargeBGParams:ctor()
    self._pCCS = cc.CSLoader:createNode("RechargeBG.csb")
	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --vip进度条那个底板
    self._pVipBg = self._pBackGround:getChildByName("VipBg")
    --进度条
    self._pLoadingBar = self._pVipBg:getChildByName("LoadingBar")
    --vip图标按钮，点击跳转到vip特权界面
    self._pVipButton = self._pVipBg:getChildByName("VipButton")
    --vip等级，fnt数字，进度条提升时会变化
    self._pVipFnt = self._pVipBg:getChildByName("VipFnt")
    --vip特权按钮，点击跳转到vip特权界面（同vip图标按钮）
    self._pPrivilegeButton = self._pVipBg:getChildByName("PrivilegeButton")
    --进度条提示数据 如5000/999
    self._pVipText01 = self._pVipBg:getChildByName("VipText01")
    --充值提示文字，还差 xxxx 即可升级
    self._pVipText02 = self._pVipBg:getChildByName("VipText02")
    --滚动容器，用来承载充值具体项
    self._pScrollView = self._pBackGround:getChildByName("ScrollView")







end

function RechargeBGParams:create()
    local params = RechargeBGParams.new()
    return params  
end

return RechargeBGParams
