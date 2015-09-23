--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyMemberPanel.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/13
-- descrip:   家族成员管理界面
--===================================================

local FamilyMemberPanel = class("FamilyMemberPanel",function() 
	return require("BasePanel"):create()
end)

function FamilyMemberPanel:ctor()
	self._strName = "FamilyMemberPanel"
	-- 家族成员
	self._pScrollView = nil 
	-- 在线人数
	self._pOnlineMemberText = nil 
	-- 历史贡献
	self._pTotalScoreText = nil 
	-- 周贡献
	self._pWeekScoreText = nil 
	------------------------------
	-- 家族成员集合
	self._tFamilyMember = {}
	-- 当前选中家族索引
	self._nSelectedIndex = 0
end

function FamilyMemberPanel:create(args)
    local dialog = FamilyMemberPanel.new()
	dialog:dispose(args)
	return dialog
end

function FamilyMemberPanel:dispose(args)       
	ResPlistManager:getInstance():addSpriteFrames("GuanLiPanel.plist")
	ResPlistManager:getInstance():addSpriteFrames("GlList.plist")
	-- 查询家族成员网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFamilyMemberResp, handler(self,self.handleMsgQueryFamilyMembers22323))
	-- 任命成员的网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kFamilyAppointResp, handler(self,self.handleMsgFamilyAppoint22325))
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyMemberPanel()
		end
	end
	self:registerScriptHandler(onNodeEvent)
    
    -- 初始化界面
    self:initUI()
end
function FamilyMemberPanel:initUI()	
	local params = require("GuanLiPanelParams"):create()
	self._pCCS = params._pCCS
    self._pBg = params._pGlBGg
    self._pScrollView = params._pGlScrollView
	self._pOnlineMemberText = params._pText_11
	self._pTotalScoreText = params._pText_13
	self._pWeekScoreText = params._pText_16
	self:addChild(self._pCCS)

end

function FamilyMemberPanel:updateUI()
	local nRenderHeight = 50
    self._pScrollView:removeAllChildren(true)
    local nContentWidth = self._pScrollView:getContentSize().width
	local nContentHeight = self._pScrollView:getContentSize().height
	nContentHeight = math.max(nContentHeight,#self._tFamilyMember * nRenderHeight)
	self._pScrollView:setInnerContainerSize(cc.size(nContentWidth,nContentHeight))
	local function callback(index)
		for i,v in ipairs(self._pScrollView:getChildren()) do
			v:selectEvent(index)
		end
	end
	for i,familyMember in ipairs(self._tFamilyMember) do
		local render = require("FamilyMemberItemRender"):create()
		render:setPosition(cc.p(nContentWidth/2,nContentHeight - (i - 0.5) * nRenderHeight))
		render:setDataSource(i,familyMember)
		render:setCallback(callback)
		self._pScrollView:addChild(render)
	end
	-- 更新自己在家族中的信息 
	local pFamilyManager = FamilyManager:getInstance()
	local familyMember = pFamilyManager:getSelfFamilyMemberInfo()
	self._pTotalScoreText:setString(familyMember.totalScore)
	self._pWeekScoreText:setString(familyMember.weekScore)
	self._pOnlineMemberText:setString(pFamilyManager:getOnlineMemberNum().."/".. pFamilyManager._pFamilyInfo.memTotal)
end

-- 查询家族成员网络回调
function FamilyMemberPanel:handleMsgQueryFamilyMembers22323(event)
	self._tFamilyMember = event.members
	self:updateUI()
end

-- 任命家族成员的网络回调
function FamilyMemberPanel:handleMsgFamilyAppoint22325(event)
	local roleId = event.argsBody.roleId
	local position = event.argsBody.position
	
	for i, familyMember in ipairs(self._tFamilyMember) do
	   if familyMember.roleId == roleId then
		  familyMember.position = position
		  self._pScrollView:getChildren()[i]:setDataSource(i,familyMember)
          break
	   end
	end
	DialogManager:getInstance():closeDialogByName("FamilyTipDialog")	
	DialogManager:getInstance():closeDialogByName("FamilyJobTipDialog")
	
    FamilyCGMessage:queryFamilyMemberReq22322()
end

function FamilyMemberPanel:onExitFamilyMemberPanel()
    ResPlistManager:getInstance():removeSpriteFrames("GuanLiPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("GlList.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FamilyMemberPanel