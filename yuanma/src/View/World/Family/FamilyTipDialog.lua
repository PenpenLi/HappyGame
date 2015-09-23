--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyTipDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/08
-- descrip:   家族tips
--===================================================

-- 家族tips  
kFamilyCallOutSrcType = {
	kUnknow = 0,	-- 未知
	KFamilyRank = 1,  -- 家族排行
	kFamilyMember = 2,  -- 家族成员
}

-- 家族处理事件
kButtons = {
 -- 查看家族信息
 familyInfo = {title = "家族信息",callback = function (familyUnit,extraParams)
        DialogManager:getInstance():showDialog("FamilyInfoDialog",{familyUnit,extraParams.isApplied}) 
  end},
 -- 申请加入
 applyJoin = {title = "申请加入",callback = function(familyUnit,extraParams) 
 	if extraParams.isApplied then
 		 NoticeManager:getInstance():showSystemMessage("您已申请过该公会请耐心等待")
         return
 	end
 	FamilyCGMessage:applyFamilyReq22308(familyUnit.familyId)
 end},
 -- 职位设置
 appointMember = {title = "职位设置",callback = function (familyMember) 
 	if familyMember.roleId == RolesManager:getInstance()._pMainRoleInfo.roleId then 
 		NoticeManager:getInstance():showSystemMessage("您不能对自己进行职位设置")
 		return
 	end
 	DialogManager:getInstance():showDialog("FamilyJobTipDialog",familyMember)
 end},
 -- 添加好友
 addFriend = {title = "添加好友",callback = function(familyMember) 
 	if familyMember.roleId == RolesManager:getInstance()._pMainRoleInfo.roleId then 
 		NoticeManager:getInstance():showSystemMessage("您不能添加自己为好友")
 		return
 	end
 	FriendCGMessage:sendMessageApplyFriend22010(familyMember.roleId)
 end},
 -- 查看玩家信息
 playerInfo = {title = "查看信息",callback = function(familyMember) 
 	FriendCGMessage:sendMessageQueryRoleInfoFriend22018(familyMember.roleId)
 end},
 -- 开除成员
 expelMember = {title = "开除成员",callback = function(familyMember) 
 	if familyMember.roleId == RolesManager:getInstance()._pMainRoleInfo.roleId  and
 		(FamilyManager:getInstance()._position == kFamilyPosition.kLeader 
 		 or FamilyManager:getInstance()._position == kFamilyPosition.kDeputyLeader) then 
 		NoticeManager:getInstance():showSystemMessage("您不能开除自己")
 		return
 	end
 	if FamilyManager:getInstance():whetherHasPermission(kFamilyChiefType.kExpelMember,familyMember.position) then 
 		showConfirmDialog("确定要开除".. familyMember.roleName .."吗？",function () FamilyCGMessage:dismissFamilyMemberReq22326(familyMember.roleId) end)		
 	end
 end},
}

local FamilyTipDialog = class("FamilyTipDialog",function() 
	return require("Dialog"):create()
end)

function FamilyTipDialog:ctor()
	self._strName = "FamilyTipDialog"
	self._pCloseButton = nil 
	self._pCCS = nil 
	self._pBg = nil 
	self._pBtnModel = nil 
	-------data-----------------
	-- 事件来源
	self._kSrcType = 0
	-- 数据
	self._pDataInfo = nil 
	-- 额外的可变参数
	self._extraParams = {}
	-- 功能集合
	self._tActions = {}
	-- 如果是家族排行
	self._tActions[kFamilyCallOutSrcType.KFamilyRank] = {kButtons.familyInfo,kButtons.applyJoin}
	-- 如果是家族成员管理
	self._tActions[kFamilyCallOutSrcType.kFamilyMember] = {
		kButtons.appointMember,
		kButtons.addFriend,
		kButtons.playerInfo,
		kButtons.expelMember,
	}
end

-- 创建函数
-- @params args = {calloutSrc,data,extraParmas}
function FamilyTipDialog:create(args)
	local dialog = FamilyTipDialog.new()
	dialog:dispose(args)
	return dialog
end

function FamilyTipDialog:dispose(args)
	-- tip 资源合图
	ResPlistManager:getInstance():addSpriteFrames("RankingsListTips.plist")

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyTipDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	-- set data 
	self._kSrcType = args[1]
	if self._kSrcType == kFamilyCallOutSrcType.KFamilyRank then 
		self._pDataInfo = args[2]
	elseif self._kSrcType == kFamilyCallOutSrcType.kFamilyMember then
		self._pDataInfo = args[2]
	end
	self._extraParams = args[3]

    -- 初始化界面
    self:initUI()

    self:registerTouchEvent()

end

function FamilyTipDialog:initUI()
	local params = require("RankingsListTipsParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pBtnModel = params._pButton_1

	self:disposeCSB()
	local tBtns = self._tActions[self._kSrcType]

	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			for k,btn in pairs(tBtns) do
				if sender:getName() == btn.title then
					btn.callback(self._pDataInfo,self._extraParams)
				end
			end
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	local btnModelRenderHeight = self._pBtnModel:getContentSize().height
	local nContentHeight = math.max(self._pBg:getContentSize().height,btnModelRenderHeight * #tBtns)
	self._pBg:setContentSize(cc.size(self._pBg:getContentSize().width,nContentHeight))
	for i,button in ipairs(tBtns) do		
		if i == 1 then 
			self._pBtnModel:setName(button.title)
			self._pBtnModel:setTitleText(button.title)
			self._pBtnModel:setPositionY(nContentHeight - btnModelRenderHeight/2)
			self._pBtnModel:addTouchEventListener(touchEvent)
		else
			local btn_clone = self._pBtnModel:clone()
			btn_clone:setPositionY(nContentHeight - (i - 0.5) * btnModelRenderHeight )
			btn_clone:setName(button.title)
			btn_clone:setTitleText(button.title)
			btn_clone:addTouchEventListener(touchEvent)
			self._pBg:addChild(btn_clone)
		end
	end

end

function FamilyTipDialog:registerTouchEvent()
	-- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
            return false
        end
        return true   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

function FamilyTipDialog:onExitFamilyTipDialog()
	self:onExitDialog()
	ResPlistManager:getInstance():removeSpriteFrames("RankingsListTips.plist")
end

return FamilyTipDialog

