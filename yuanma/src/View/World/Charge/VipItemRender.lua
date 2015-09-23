--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  VipItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/07
-- descrip:   VipItemRender
--===================================================
local VipItemRender = class("VipItemRender",function () 
	return ccui.Layout:create()
end)

function VipItemRender:ctor()
	self._strName = "VipItemRender"
	self._pBg = nil 
	self._pCCS = nil 
	self._pVipLvText = nil 
	self._pVipIntroGoodText = nil 
	------------------------------
	self._pDataInfo = nil 
end

function VipItemRender:create()
	local render = VipItemRender.new()
	render:dispose()
	return render
end

function VipItemRender:dispose()
	local params = require("VipExplainParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBG
	self._pVipLvText = params._pVip
	params._pExplain:setVisible(false)
	-- 替换成goodRichText 
    local labelSize = params._pExplain:getContentSize()
    self._pVipIntroGoodText = require("GoodRichText"):create({},labelSize)
    self._pVipIntroGoodText:ignoreContentAdaptWithSize(false)
    local x,y = params._pExplain:getPosition()
    self._pVipIntroGoodText:setPosition(cc.p(x,y))
    self._pVipIntroGoodText:setAnchorPoint(0,1)
    params._pExplain:getParent():addChild(self._pVipIntroGoodText)
    local sBgSize = self._pBg:getContentSize()
    self._pCCS:setPosition(cc.p(sBgSize.width/2,sBgSize.height/2))
	self:addChild(self._pCCS)

	------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitVipItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

function VipItemRender:onExitVipItemRender()
	-- cleanup 
end

function VipItemRender:setDataSource(dataInfo)
	self._pDataInfo = dataInfo
	if dataInfo then 
		self._pVipLvText:setString(dataInfo.Ranking)
		self._pVipIntroGoodText:setString(dataInfo.Text)
	end
end

return VipItemRender
