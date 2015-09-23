--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyInfoDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/13
-- descrip:   家族创建界面
--===================================================

local FamilyInfoDialog = class("FamilyInfoDialog",function() 
	return require("Dialog"):create()
end)

function FamilyInfoDialog:ctor()
	self._strName = "FamilyInfoDialog"
	self._pCloseButton = nil 
	self._pCCS = nil
	self._pBg = nil 
	-- 家族名字
	self._pFamilyNameText = nil 
	-- 家族等级
	self._pFamilyLevelText = nil 
	-- 家族人数
	self._pFamilyMemText = nil 
	-- 族长名字
	self._pLeaderNameText = nil 
	-- 家族宗旨
	self._pFamilyPurposeText = nil 
	-- 申请按钮
	self._pApplyBtn = nil 
	------------------------------
	-- 当前家族的信息
	self._pFamilyUnit = nil 
	-- 当前家族的申请状态
	self._isApply = false

end

function FamilyInfoDialog:create(args)
	local dialog = FamilyInfoDialog.new()
	dialog:dispose(args)
	return dialog
end

function FamilyInfoDialog:dispose(args)
	-- 家族创建查找纹理           
	ResPlistManager:getInstance():addSpriteFrames("HomeInfoDialog.plist")
	-- 注册家族申请成功网络回调
	-- NetRespManager:getInstance():addEventListener(kNetCmd.kCreateFamilyResp,handler(self,self.handleMsgCreateFamily22307))
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitFamilyInfoDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	 -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    
    self._pFamilyUnit = args[1]
    self._isApply = args[2]
    -- 初始化界面
    self:initUI()
end
function FamilyInfoDialog:initUI()
	-- 申请家族按钮
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if FamilyManager:getInstance()._pFamilyInfo ~= nil then 
				NoticeManager:getInstance():showSystemMessage("您已经加入家族")
				return
			end
			if self._isApply == true then 
				NoticeManager:getInstance():showSystemMessage("您已申请该家族，请耐心等候。")
				return
			end
			if self._pFamilyUnit.memCount > self._pFamilyUnit.memTotal then 
				NoticeManager:getInstance():showSystemMessage("家族人数已满")
				return
			end 
			FamilyCGMessage:applyFamilyReq22308(self._pFamilyUnit.familyId)
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
		end 
	end
	local params = require("HomeInfoDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pFamilyNameText = params._pText1_1
	self._pFamilyLevelText = params._pText2_1
	self._pFamilyMemText = params._pText3_1
    self._pLeaderNameText = params._pText4_1
	self._pFamilyPurposeText = params._pText6
	self._pApplyBtn = params._pApplyBtn
	self._pApplyBtn:addTouchEventListener(touchEvent)
   
	self:disposeCSB()

	self:updateUI()
end

function FamilyInfoDialog:updateUI()
	if self._pFamilyUnit then 
		self._pFamilyNameText:setString(self._pFamilyUnit.familyName)
		self._pFamilyLevelText:setString(self._pFamilyUnit.level)
		self._pFamilyMemText:setString(self._pFamilyUnit.memCount.."/"..self._pFamilyUnit.memTotal)
		self._pFamilyPurposeText:setString(self._pFamilyUnit.purpose)
		self._pLeaderNameText:setString(self._pFamilyUnit.leaderName)
	end
end

function FamilyInfoDialog:onExitFamilyInfoDialog()
	self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("HomeInfoDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FamilyInfoDialog