--家园buff大界面
local OurHomeBuffPanelParams = class("OurHomeBuffPanelParams")

function OurHomeBuffPanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("OurHomeBuffPanel.csb")
	--背景板
    self._pBuffBg = self._pCCS:getChildByName("BuffBg")
	--当前生效滚动框
	self._pListViewNow = self._pBuffBg:getChildByName("ListViewNow")
	--已生效的数量
	self._pSxTextNum = self._pBuffBg:getChildByName("SxTextNum")
	--未生效滚动框
	self._pBuffScrollView = self._pBuffBg:getChildByName("BuffScrollView")
	--科技园介绍底板
    --self._pRightBg = self._pBuffBg:getChildByName("RightBg")
    --科技园图标底板
    --self._pBuffIconBg = self._pRightBg:getChildByName("BuffIconBg")
    --科技园图标
    self._pBuffIcon = self._pBuffBg:getChildByName("BuffIcon")
    --科技园等级
    self._pText_3 = self._pBuffBg:getChildByName("Text_3")
    --科技园升级条件
    self._pText_4 = self._pBuffBg:getChildByName("Text_4")
    --科技升级按钮
    self._pButton_3 = self._pBuffBg:getChildByName("Button_3")
    --科技园说明文字滚动框
    self._pShuoMingListView = self._pBuffBg:getChildByName("ShuoMingListView")
    --说明文字
    self._pText_6 = self._pShuoMingListView:getChildByName("Text_6")

end

function OurHomeBuffPanelParams:create()
    local params = OurHomeBuffPanelParams.new()
    return params  
end

return OurHomeBuffPanelParams
