--家族动态信息
local TrendsParams = class("TrendsParams")

function TrendsParams:ctor()
    self._pCCS = cc.CSLoader:createNode("Trends.csb")
	--技能tips背景板
    self._pDongTaiBg = self._pCCS:getChildByName("DongTaiBg")
    --头像底板
    self._pHeadIconBg = self._pDongTaiBg:getChildByName("HeadIconBg")
    --头像
    self._pHeadIcon = self._pHeadIconBg:getChildByName("HeadIcon")
    --等级
    self._pLvText = self._pDongTaiBg:getChildByName("LvText")
    --名称
    self._pNameText = self._pDongTaiBg:getChildByName("NameText")
    --信息内容
    self._pDongTaiText = self._pDongTaiBg:getChildByName("DongTaiText")  
    -- 新闻创建的时间
    self._pTimeText = self._pDongTaiBg:getChildByName("Time")  
end

function TrendsParams:create()
    local params = TrendsParams.new()
    return params  
end

return TrendsParams
