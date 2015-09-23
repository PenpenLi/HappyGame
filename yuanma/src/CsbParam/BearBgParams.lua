--游戏的战斗界面
local BearBgParams = class("BearBgParams")

function BearBgParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BearBg.csb")

	--背景板
    self._pBackGround = self._pCCS:getChildByName("BackGround")
    --滚动列表
    self._pScrollView = self._pBackGround:getChildByName("ScrollView")
    --开始售卖按钮
    self._pButton_1 = self._pBackGround:getChildByName("Button_1")    
    



    
end

function BearBgParams:create()
    local params = BearBgParams.new()
    return params  
end

return BearBgParams
