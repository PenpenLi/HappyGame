--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyRegisterItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/10
-- descrip:   家族查找创建家族列表模板界面
--===================================================
local FamilyRegisterItemRender = class("FamilyRegisterItemRender",function() 
	return  ccui.ImageView:create()
end)

-- 构造函数
function FamilyRegisterItemRender:ctor()
	self._pBg = nil -- 背景图
	self._pRankText = nil -- 家族排名
	self._pNameText = nil -- 家族名字
	self._pLevelText = nil -- 家族等级
	self._pMemberNumText = nil -- 家族人数
	self._pLeaderNameText = nil -- 族长名字
	self._pApplicationIcon = nil  -- 家族已申请标签

	---- data
	self._nIndex = 0
	self._selectedCallback = nil 
end

-- 创建函数 
function FamilyRegisterItemRender:create()
	local imgView = FamilyRegisterItemRender.new()
	imgView:dispose()
	return imgView
end

function FamilyRegisterItemRender:dispose()
	local params = require("LoginLeftListParams"):create()
	self._pBg = params._pListBg
	self._pRankText = params._pText_1
	self._pNameText = params._pText_2
	self._pLevelText = params._pText_3
	self._pMemberNumText = params._pText_4
	self._pLeaderNameText = params._pText_6
	self._pApplicationIcon = params._pApplication

	self:addChild(params._pCCS)

	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if self._selectedCallback ~= nil then 
				self._selectedCallback(self._nIndex)
			end
		elseif eventType == ccui.TouchEventType.began then
		    AudioManager:getInstance():playEffect("ButtonClick")
		end
	end

	self._pBg:setTouchEnabled(true)
    self._pBg:addTouchEventListener(touchEvent)

	------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFamilyRegisterItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)	    
end

function FamilyRegisterItemRender:setDataSource(familyUnit,index,isApplied)
	if not familyUnit then
		self._pRankText:setString("")
		self._pNameText:setString("")
		self._pLevelText:setString("")
		self._pMemberNumText:setString("")
		self._pLeaderNameText:setString("")
	else
		self._pRankText:setString(familyUnit.rank)
		self._pNameText:setString(familyUnit.familyName)
		self._pLevelText:setString(familyUnit.level)
		self._pMemberNumText:setString(familyUnit.memCount.."/"..familyUnit.memTotal)
		self._pLeaderNameText:setString(familyUnit.leaderName)
	end
	self:setIndex(index)
	self:setApplyState(isApplied)
end

function FamilyRegisterItemRender:selectEvent(selectedIndex)
    local strImgName = self._nIndex == selectedIndex and "LoginLeftListRes/jzjm28.png" or "LoginLeftListRes/none.png"
	self._pBg:loadTexture(strImgName,ccui.TextureResType.plistType)
end

function FamilyRegisterItemRender:setIndex(index)
	if index ~= self._nIndex then 
		self._nIndex = index
	end
end

function FamilyRegisterItemRender:setCallback(callback)
	self._selectedCallback = callback
end

-- 是否已申请
function FamilyRegisterItemRender:setApplyState(isApplied)
	self._pApplicationIcon:setVisible(isApplied)
end

function FamilyRegisterItemRender:onExitFamilyRegisterItemRender()
	-- cleanup
end

return FamilyRegisterItemRender