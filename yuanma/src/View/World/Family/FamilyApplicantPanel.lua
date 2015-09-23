--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyApplicatPanel.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/13
-- descrip:   家族申请管理界面
--===================================================

local FamilyApplicatPanel = class("FamilyApplicatPanel",function() 
	return require("BasePanel"):create()
end)

function FamilyApplicatPanel:ctor()
	self._strName = "FamilyApplicatPanel"
	-- 申请者滚动框
	self._pScrollView = nil 
	-- 一键同意
	self._pAutoAgreeBtn = nil 
	-- 一键拒绝
	self._pAutoDenyBtn = nil 
	------------------------------
	-- 申请者集合
	self._tApplyFriendInfo = {}
	-- 当前申请者的信息
	self._nSelectedIndex = 0
end

function FamilyApplicatPanel:create(args)
    local dialog = FamilyApplicatPanel.new()
	dialog:dispose(args)
	return dialog
end

function FamilyApplicatPanel:dispose(args)
	-- 家族申请者管理          
	ResPlistManager:getInstance():addSpriteFrames("CyPanel.plist")
	ResPlistManager:getInstance():addSpriteFrames("CyList.plist")
	-- 注册查询家族排行网络回调
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFamilyApplysResp, handler(self,self.handleMsgQueryFamilyApplys22319))
	-- 批复申请回复
    NetRespManager:getInstance():addEventListener(kNetCmd.kReplyFamilyApplyResp, handler(self,self.handleMsgReplyFamilyApply22321))
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyApplicatPanel()
		end
	end
	self:registerScriptHandler(onNodeEvent)
    
    -- 初始化界面
    self:initUI()
end
function FamilyApplicatPanel:initUI()	
	local params = require("CyPanelParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pCyBg
	self._pScrollView = params._pCyScrollView
	self._pAutoAgreeBtn = params._pTgButton
	self._pAutoDenyBtn = params._pJjButton
   
	self:addChild(self._pCCS)

	self:initBtnEvent()
end

function FamilyApplicatPanel:initBtnEvent()
    local pFamilyManager = FamilyManager:getInstance()
	local function touchEvent(sender,eventType)
        if pFamilyManager:whetherHasPermission(kFamilyChiefType.kJoinFamily) == false then
            NoticeManager:getInstance():showSystemMessage("对不起您没有权限")       
            return 
        end
		if eventType == ccui.TouchEventType.ended then
            if sender:getName() == "agree" then 
                FamilyCGMessage:resplyFamilyApplyReq22320(0,true,true)
			elseif sender:getName() == "deny" then 
                FamilyCGMessage:resplyFamilyApplyReq22320(0,false,true)
			end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pAutoAgreeBtn:setName("agree")
	self._pAutoAgreeBtn:addTouchEventListener(touchEvent)
	self._pAutoDenyBtn:setName("deny")
	self._pAutoDenyBtn:addTouchEventListener(touchEvent)
end

function FamilyApplicatPanel:updateUI()
	local nRenderHeight = 50
	local nContentWidth = self._pScrollView:getInnerContainerSize().width
	local nContentHeight = self._pScrollView:getInnerContainerSize().height
    self._pScrollView:removeAllChildren(true)

	for i,friendInfo in ipairs(self._tApplyFriendInfo) do
		local render = require("FamilyApplicantItemRender"):create()
		render:setPosition(cc.p(nContentWidth/2,nContentHeight - (i - 0.5) * nRenderHeight))
		render:setDataSource(i,friendInfo)
		self._pScrollView:addChild(render)
	end
end

-- 获取家族申请者网络回调
function FamilyApplicatPanel:handleMsgQueryFamilyApplys22319(event)
	self._tApplyFriendInfo = event.applyList
	self:updateUI()
end

-- 批复回复
function FamilyApplicatPanel:handleMsgReplyFamilyApply22321(event)
	if event.isAuto then
		self._tApplyFriendInfo = {}
	else
		for k,v in pairs(self._tApplyFriendInfo ) do
			if v.roleId == event.roleId then 
				table.remove(self._tApplyFriendInfo,k)
			end
		end
	end
	self:updateUI()
end

function FamilyApplicatPanel:onExitFamilyApplicatPanel()
    ResPlistManager:getInstance():removeSpriteFrames("RakingsDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("HomeRankingsList.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FamilyApplicatPanel