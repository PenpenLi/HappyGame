--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyApplicantItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/16
-- descrip:   家族申请者列表
--===================================================
local FamilyApplicantItemRender = class("FamilyApplicantItemRender",function() 
	return ccui.ImageView:create()	
end)

function FamilyApplicantItemRender:ctor()
	self._pCCS = nil
	self._pBg = nil -- 背景图
	self._pRankText = nil -- 排名
	self._pNameText = nil -- 名称
	self._pLevelText = nil -- 等级
	self._pCareerText = nil -- 职业
	self._pFightPowerText = nil -- 战斗力
	self._pOnlineText = nil -- 在线状态
	self._pAgreeBtn = nil -- 通过按钮
	self._pDenyBtn = nil -- 拒绝按钮
	-------------------------------
	self._nIndex = 0
	self._selectCallback = nil 
	self._pApplyFriendInfo = nil 
end

function FamilyApplicantItemRender:create()
	local panel = FamilyApplicantItemRender.new()
	panel:dispose()
	return panel
end

function FamilyApplicantItemRender:dispose()
	local params = require("CyListParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pListBg
	self._pRankText = params._pText_1
	self._pNameText = params._pText_2
	self._pLevelText = params._pText_3
	self._pCareerText = params._pText_4
	self._pFightPowerText = params._pText_5
	self._pOnlineText = params._pText_6
	self._pAgreeBtn = params._pButton_1
	self._pDenyBtn = params._pButton_2
	
	self:addChild(self._pCCS)
	-- 初始化按钮点击事件 	
	self:initBtnEvent()
	------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFamilyApplicantItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)	
end

function FamilyApplicantItemRender:initBtnEvent()
	local pFamilyManager = FamilyManager:getInstance()
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if pFamilyManager:whetherHasPermission(kFamilyChiefType.kJoinFamily) == false then
				NoticeManager:getInstance():showSystemMessage("对不起您没有权限")		
				return 
			end
			if pFamilyManager._pFamilyInfo.memCount >= pFamilyManager._pFamilyInfo.memTotal then 
				NoticeManager:getInstance():showSystemMessage("家族成员已满")		
				return
			end
			local isAgree = sender:getName() == "agree" 
			FamilyCGMessage:resplyFamilyApplyReq22320(self._pApplyFriendInfo.roleId,isAgree,false)
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pAgreeBtn:setName("agree")
	self._pAgreeBtn:addTouchEventListener(touchEvent)
	self._pDenyBtn:setName("deny")
	self._pDenyBtn:addTouchEventListener(touchEvent)
end

function FamilyApplicantItemRender:setDataSource(index,applyFriendInfo)
	if applyFriendInfo then 
		self._nIndex = index
		self._pApplyFriendInfo = applyFriendInfo
		self._pRankText:setString(index)
		self._pNameText:setString(applyFriendInfo.roleName)
		self._pLevelText:setString(applyFriendInfo.level)
		self._pCareerText:setString(kRoleCareerTitle[applyFriendInfo.roleCareer])
        self._pCareerText:setColor(kRoleCareerFontColor[applyFriendInfo.roleCareer])
		self._pFightPowerText:setString(applyFriendInfo.fightingPower)
		self._pOnlineText:setString(gOneTimeToStr(os.time() - applyFriendInfo.applyTime).."前")
	end
end

function FamilyApplicantItemRender:onExitFamilyApplicantItemRender()
	-- cleanup 
end

return FamilyApplicantItemRender

