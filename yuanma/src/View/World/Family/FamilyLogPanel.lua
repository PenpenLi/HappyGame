--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyLogPanel.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/13
-- descrip:   家族动态界面
--===================================================

local FamilyLogPanel = class("FamilyLogPanel",function() 
	return require("BasePanel"):create()
end)

function FamilyLogPanel:ctor()
	self._strName = "FamilyLogPanel"
	------------------------------
	-- 家族动态集合
	self._tFamilyNews = {}
	
end

function FamilyLogPanel:create(args)
    local dialog = FamilyLogPanel.new()
	dialog:dispose(args)
	return dialog
end

function FamilyLogPanel:dispose(args)       
	ResPlistManager:getInstance():addSpriteFrames("DongTaiPanel.plist")
	ResPlistManager:getInstance():addSpriteFrames("Trends.plist")
	-- 查找家族日志的网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFamilyNewsResp, handler(self,self.handleMsgQueryFamilyNews22331))

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyLogPanel()
		end
	end
	self:registerScriptHandler(onNodeEvent)
    
    -- 初始化界面
    self:initUI()
end
function FamilyLogPanel:initUI()	
	local params = require("DongTaiPanelParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pDongTaiBg
    self._pScrollView = params._pDtScrollView
	self:addChild(self._pCCS)

end

function FamilyLogPanel:updateUI()
	local nRenderHeight = 154
	self._pScrollView:removeAllChildren(true)
	local nContentWidth = self._pScrollView:getContentSize().width
	local nContentHeight = self._pScrollView:getContentSize().height
   	nContentHeight = math.max(nContentHeight,#self._tFamilyNews * nRenderHeight)
	self._pScrollView:setInnerContainerSize(cc.size(nContentWidth,nContentHeight))
	-- 家族动态最新的在上面
	local newsCount = #self._tFamilyNews
	local familyNews = nil 
	for i = newsCount,1, -1 do
		familyNews = self._tFamilyNews[i]
		local render = require("TrendsParams"):create()
        render._pCCS:setPosition(cc.p(nContentWidth/2,nContentHeight - (newsCount - i + 0.5) * nRenderHeight))
		render._pHeadIcon:loadTexture(kRoleIcons[familyNews.roleCareer],ccui.TextureResType.plistType)
		render._pLvText:setString("Lv "..familyNews.level)
		render._pNameText:setString(familyNews.roleName)
		render._pDongTaiText:setString(familyNews.content)
		render._pTimeText:setString(timeStampConvertToString(familyNews.newsTime))
		self._pScrollView:addChild(render._pCCS)
	end
end

function FamilyLogPanel:handleMsgQueryFamilyNews22331(event)
	self._tFamilyNews = event.newsList
	self:updateUI()
end

function FamilyLogPanel:onExitFamilyLogPanel()
    ResPlistManager:getInstance():removeSpriteFrames("DongTaiPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("Trends.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FamilyLogPanel