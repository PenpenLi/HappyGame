--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyMemberItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/20
-- descrip:   家族成员列表
--===================================================
local FamilyMemberItemRender = class("FamilyMemberItemRender",function () 
	return ccui.ImageView:create()	
end)

function FamilyMemberItemRender:ctor()
	self._PCCS = nil 
	self._pBg = nil 
	-- 排名
	self._pRankText = nil 
	-- 角色名字
	self._pPlayerNameText = nil 
	-- 角色等级
	self._pPlayerLevelText = nil 
	-- 角色职业
	self._pPlayerCareerText = nil 
	-- 角色历史贡献度
	self._pPlayerTotalScoreText = nil 
	-- 角色周贡献度
	self._pPlayerWeekScoreText = nil 
	-- 角色的职位
	self._pPlayerPositionText = nil 
	-- 角色战斗力
	self._pPlayerFightPowerText = nil 
	-- 角色的在线状态
	self._pOnlineStatusText = nil 
	-- 每次点击背景时的位移
    self._fMoveDis = 0   
    -- 按下时的放大尺寸
	self._fBigScale = 1.04
	--------------------------------
	self._pDataInfo = nil 
	self._nIndex = 0
	self._selectCallback = nil 
	self._bSelfTextColor = cc.c3b(255,159,59)
end

function FamilyMemberItemRender:create()
	local imgView = FamilyMemberItemRender.new()
	imgView:dispose()
	return imgView
end

function FamilyMemberItemRender:dispose()
	local params = require("GlListParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pListBg
	self._pRankText = params._pText_1
	self._pPlayerNameText = params._pText_2
	self._pPlayerLevelText = params._pText_3
	self._pPlayerCareerText = params._pText_4
	self._pPlayerTotalScoreText = params._pText_5
	self._pPlayerWeekScoreText = params._pText_6
	self._pPlayerPositionText = params._pText_7
	self._pPlayerFightPowerText = params._pText_8
	self._pOnlineStatusText = params._pText_9

	self:addChild(self._pCCS)
	-- 初始化按钮的点击事件
	self:initBtnEvent()

	------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFamilyMemberItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)	
end

function FamilyMemberItemRender:initBtnEvent()
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then 
			if self._pDataInfo  and self:getScale() > 1 then 
				if self._selectedCallback ~= nil then 
					self._selectedCallback(self._nIndex)
				end
				DialogManager:getInstance():showDialog("FamilyTipDialog",{2,self._pDataInfo})
			end
			self:setScale(1)
			self._fMoveDis = 0
		elseif eventType == ccui.TouchEventType.began then
 			AudioManager:getInstance():playEffect("ButtonClick")
 			self._fMoveDis = 0
 			self:setScale(self._fBigScale)
 		elseif eventType == ccui.TouchEventType.moved then
 			self._fMoveDis = self._fMoveDis + 1
 			if self._fMoveDis >= 5 then 
 				self:setScale(1)
 			end
		end
	end
	self._pBg:setTouchEnabled(true)
	self._pBg:setSwallowTouches(false)
	self._pBg:addTouchEventListener(touchEvent)
end

function FamilyMemberItemRender:setDataSource(index,familyMemberInfo)
	if familyMemberInfo then 
		self._nIndex = index
        self._pDataInfo = familyMemberInfo
		self._pRankText:setString(index)
		self._pPlayerNameText:setString(familyMemberInfo.roleName)
		self._pPlayerLevelText:setString(familyMemberInfo.level)
		self._pPlayerCareerText:setString(kRoleCareerTitle[familyMemberInfo.roleCareer])
		self._pPlayerTotalScoreText:setString(familyMemberInfo.totalScore)
		self._pPlayerWeekScoreText:setString(familyMemberInfo.weekScore)
		self._pPlayerFightPowerText:setString(familyMemberInfo.fightingPower)
		self._pPlayerPositionText:setString(kFamilyPositionTitle[familyMemberInfo.position])
        if familyMemberInfo.offlineTime == 0 then
        	self._pOnlineStatusText:setString("在线")
            self._pOnlineStatusText:setColor(cGreen)
    	else
        	local nowTime = familyMemberInfo.offlineTime
            self._pOnlineStatusText:setString(gOneTimeToStr(nowTime) .. "前")
            self._pOnlineStatusText:setColor(cGrey)
    	end  

    	-- 如果是自己则字体颜色做区分
    	if familyMemberInfo.roleId == RolesManager:getInstance()._pMainRoleInfo.roleId then 
    		self._pRankText:setColor(self._bSelfTextColor)
    		self._pPlayerNameText:setColor(self._bSelfTextColor)
    		self._pPlayerLevelText:setColor(self._bSelfTextColor)
    		self._pPlayerCareerText:setColor(self._bSelfTextColor)
    		self._pPlayerTotalScoreText:setColor(self._bSelfTextColor)
    		self._pPlayerWeekScoreText:setColor(self._bSelfTextColor)
    		self._pPlayerFightPowerText:setColor(self._bSelfTextColor)
    		self._pPlayerPositionText:setColor(self._bSelfTextColor)
    	end 	
	end
end



function FamilyMemberItemRender:selectEvent(selectedIndex)
	local strImgName = self._nIndex == selectedIndex and "GlListRes/jzjm28.png" or "GlListRes/none.png"
	self._pBg:loadTexture(strImgName,ccui.TextureResType.plistType)
end

function FamilyMemberItemRender:setCallback(callback)
	self._selectedCallback = callback
end

function FamilyMemberItemRender:onExitFamilyMemberItemRender()
	-- cleanup
end

return FamilyMemberItemRender