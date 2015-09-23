--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyJobTipDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/20
-- descrip:   家族任职面板
--===================================================
local FamilyJobTipDialog = class("FamilyJobTipDialog",function ()
	return require("Dialog"):create()
end)

function FamilyJobTipDialog:ctor()
	self._strName = "FamilyJobTipDialog"
	-- 职位按钮(单选)	
	self._tJobCheckBtn = {}
	self._pOkBtn = nil 
	-- 按钮选中的图片
	self._pSelectedImg = nil 
	----------------------
	-- 家族成员信息
	self._pFamilyMember = nil 
	self._tMemberLimit = {}
	self._tMemberLimit[2] = TableConstants.ViceChiefLimit.Value
	self._tMemberLimit[3] = TableConstants.EldersLimit.Value	
	self._nSelectIndex = 0
end

function FamilyJobTipDialog:create(args)
	local dialog = FamilyJobTipDialog.new()
	dialog:dispose(args)
	return dialog
end

function FamilyJobTipDialog:dispose(args)
	-- 加载合图资源
	ResPlistManager:getInstance():addSpriteFrames("HomeJobDialog.plist")

	local params = require("HomeJobDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pOkBtn = params._pOkButton
	params._pButton_1:setName(kFamilyChiefType.kChief)
	params._pButton_2:setName(kFamilyChiefType.kViceCheif)
	params._pButton_3:setName(kFamilyChiefType.kElders)
	params._pButton_4:setName(kFamilyChiefType.kMember)

    self:disposeCSB()

    -- 手动添加选中状态
    self._pSelectedImg = cc.Sprite:createWithSpriteFrameName("HomeJobDialogRes/jsjm_014.png")
    self._pSelectedImg:setVisible(false)
    self._pBg:addChild(self._pSelectedImg)
	self._tJobCheckBtn = 
	{
		-- 族长
		params._pButton_1,
		-- 副族长
		params._pButton_2,	
		-- 长老
		params._pButton_3,		
		-- 成员
		params._pButton_4,
	}

	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			self._pSelectedImg:setPosition(sender:getPosition())
			local selectedIndex = 0
			for i,v in ipairs(self._tJobCheckBtn) do
				if v == sender then 
					self._nSelectIndex = i
				end
			end
			self._pSelectedImg:setVisible(true)
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end

	for i,v in ipairs(self._tJobCheckBtn) do
		v:addTouchEventListener(touchEvent)
	end

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyJobTipDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	-- setData 
	self._pFamilyMember = args
	
	self:initBtnEvent()

	self:registerTouchEvent()

	-- 默认选中对方职位
	self._pSelectedImg:setPosition(self._tJobCheckBtn[self._pFamilyMember.position] :getPosition())
	self._pSelectedImg:setVisible(true)
	self._nSelectIndex = self._pFamilyMember.position
end

function FamilyJobTipDialog:registerTouchEvent()
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

function FamilyJobTipDialog:initBtnEvent()
	local function touchEvent (sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local familyMamager = FamilyManager:getInstance()
            local strMsg = self._tJobCheckBtn[self._nSelectIndex]:getName()
            if familyMamager:whetherHasPermission(strMsg,self._pFamilyMember.position) == false then	
				return
			end
			if self._nSelectIndex <= 0 then 
				NoticeManager:getInstance():showSystemMessage("请先选个职位")
				return
			end
			if self._nSelectIndex == 2 or self._nSelectIndex == 3 then 
				local memberNum = familyMamager:getPositionNum(self._nSelectIndex)
				if memberNum >= self._tMemberLimit[self._nSelectIndex] then
					NoticeManager:getInstance():showSystemMessage("该职位已满")
					return
				end
			end
			FamilyCGMessage:familyAppointReq22324(self._pFamilyMember.roleId,self._nSelectIndex)
		elseif eventType == ccui.TouchEventType.began then
	   	    AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pOkBtn:addTouchEventListener(touchEvent)
end

function FamilyJobTipDialog:onExitFamilyJobTipDialog()
	self:onExitDialog()
	ResPlistManager:getInstance():removeSpriteFrames("HomeJobDialog.plist")
end

return FamilyJobTipDialog

