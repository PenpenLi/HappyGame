--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyRankItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/07/10
-- descrip:   家族查找创建家族列表模板界面
--===================================================
local FamilyRankItemRender = class("FamilyRankItemRender",function() 
	return  ccui.ImageView:create()
end)

-- 构造函数
function FamilyRankItemRender:ctor()
	self._pBg = nil -- 背景图
	self._pRankText = nil -- 家族排名
	self._pNameText = nil -- 家族名字
	self._pLevelText = nil -- 家族等级
	self._pMemberNumText = nil -- 家族人数
	self._pLeaderNameText = nil -- 族长名字
	self._pApplicationIcon = nil  -- 家族已申请标签
	self._pCreateTimeText = nil -- 家族的创建时间
	------- data ------------------
	self._nIndex = 0
	self._selectedCallback = nil 
	self._pFamilyUnit = nil 
	self._isApplied = false
end

-- 创建函数 
function FamilyRankItemRender:create()
    local imgView = FamilyRankItemRender.new()
	imgView:dispose()
	return imgView
end

function FamilyRankItemRender:dispose()
	local params = require("HomeRankingsListParams"):create()
	self._pBg = params._pListBg
	self._pRankText = params._pText_1
	self._pNameText = params._pText_2
	self._pLevelText = params._pText_4
	self._pMemberNumText = params._pText_6
	self._pLeaderNameText = params._pText_3
	--self._pApplicationIcon = params._pApplication
	self._pCreateTimeText = params._pText_8
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
            self:onExitFamilyRankItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)	

end

function FamilyRankItemRender:setDataSource(familyUnit,index,isApplied)
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
		self._pCreateTimeText:setString(timeStampConvertToString(familyUnit.createTime))
		self._pFamilyUnit = familyUnit
	end
	self:setIndex(index)
	self:setApplyState(isApplied)
end

function FamilyRankItemRender:selectEvent(selectedIndex)
	local strImgName = self._nIndex == selectedIndex and "HomeRankingsListRes/jzjm28.png" or "HomeRankingsListRes/none.png"
	self._pBg:loadTexture(strImgName,ccui.TextureResType.plistType)
	-- 弹tips
	DialogManager:getInstance():showDialog("FamilyTipDialog",{1,self._pFamilyUnit,{isApplied = self._isApplied}})
end

function FamilyRankItemRender:setIndex(index)
	if index ~= self._nIndex then 
		self._nIndex = index
	end
end

function FamilyRankItemRender:setCallback(callback)
	self._selectedCallback = callback
end

-- 是否已申请
function FamilyRankItemRender:setApplyState(isApplied)
	self._isApplied = isApplied
	--self._pApplicationIcon:setVisible(isApplied)
end

function FamilyRankItemRender:onExitFamilyRankItemRender()
	-- clean up 
end

return FamilyRankItemRender