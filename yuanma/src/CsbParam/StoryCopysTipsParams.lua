--游戏的战斗界面
local StoryCopysTipsParams = class("StoryCopysTipsParams")

function StoryCopysTipsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("StoryCopysTips.csb")
	--技能tips背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --关闭按钮
    self._pCloseButton = self._pBackGround:getChildByName("CloseButton")
    --确定按钮（进入副本）
    self._pSureButton = self._pBackGround:getChildByName("SureButton")
    --关卡名称
    --self._pstorycopysname01 = self._pBackGround:getChildByName("storycopysname01")
    --关卡名称（具体）
    self._pstorycopysname02 = self._pBackGround:getChildByName("storycopysname02")
    --副本难度
    self._pstorycopysdifficulty01 = self._pBackGround:getChildByName("storycopysdifficulty01")
    --副本难度（具体）
    self._pstorycopysdifficulty02 = self._pBackGround:getChildByName("storycopysdifficulty02")
    --需求等级
    self._pneedlevel01 = self._pBackGround:getChildByName("needlevel01")
    --需求等级（具体）
    self._pneedlevel02 = self._pBackGround:getChildByName("needlevel02")
    --推荐战斗力
    self._pbattlepower01 = self._pBackGround:getChildByName("battlepower01")
    --推荐战斗力（具体）
    self._pbattlepower02 = self._pBackGround:getChildByName("battlepower02")
    --当前体力
    self._ppower = self._pBackGround:getChildByName("power")
    --当前体力进度条那个底板
    self._pPloadingbarback = self._pBackGround:getChildByName("Ploadingbarback")
    --当前体力进度条
    self._pPloadingbar = self._pBackGround:getChildByName("Ploadingbar")
    --当前体力上面的数字
    self._ppowertext = self._pBackGround:getChildByName("powertext")
    --剩余次数
    self._pcurcount01 = self._pBackGround:getChildByName("curcount01")
    --剩余次数（具体）
    self._pcurcount02 = self._pBackGround:getChildByName("curcount02")
    --消耗体力
    self._pusepower01 = self._pBackGround:getChildByName("usepower01")
    --消耗体力（具体）
    self._pusepower02 = self._pBackGround:getChildByName("usepower02")
    --关卡奖励
    self._preward = self._pBackGround:getChildByName("reward")
    --关卡奖励（具体哪些滚动区域）
    self._pscrollview = self._pBackGround:getChildByName("scrollview")
    --星级评价图片
    self._plevelstar = self._pBackGround:getChildByName("levelstar")
	--助战好友头像底板
	self._pIconBg = self._pBackGround:getChildByName("IconBg")
	--助战好友头像
	self._pIconPic = self._pBackGround:getChildByName("IconPic")
	--玄奘助战好友按钮
	self._pChooseButton = self._pBackGround:getChildByName("ChooseButton")
    
end

function StoryCopysTipsParams:create()
    local params = StoryCopysTipsParams.new()
    return params  
end

return StoryCopysTipsParams
