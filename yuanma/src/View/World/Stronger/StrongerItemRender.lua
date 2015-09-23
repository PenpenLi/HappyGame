--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StrongerItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/09/22
-- descrip:   我要变强模板
--===================================================
local StrongerItemRender = class("StrongerItemRender",function ()
	-- body
	return ccui.ImageView:create()
end)

function StrongerItemRender:ctor()
	self._strName = "StrongerItemRender"
	self._pCCS = nil 
	self._pFuncIcon = nil 
	self._pFuncNameText = nil
	self._pGoBtn = nil
	--------------------------------
	self._pNewFunctionInfo = nil
end

function StrongerItemRender:create()
	local imageView = StrongerItemRender.new()
	imageView:dispose()
	return imageView
end

function StrongerItemRender:dispose()
	local params = require("GuideNrParams"):create()
	self._pCCS = params._pCCS
	self._pFuncIcon = params._pIconPic
	self._pFuncNameText = params._pTextNr
	self._pGoBtn = params._pOkButton
	self:addChild(self._pCCS)

	------------- 节点事件-------------------------
	local function onNodeEvent(event)
		if event == "exit" then 
			self:onExitStrongerItemRender()
		end
	end

	self:registerScriptHandler(onNodeEvent)

	-- 跳转到具体功能的
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then 
			if not self._pNewFunctionInfo then 
				return
			end
			
            PurposeManager:getInstance():createPurpose( self._pNewFunctionInfo.GuideID1)
			PurposeManager:getInstance():startOperateByTaskId( self._pNewFunctionInfo.GuideID1)
		elseif eventType == ccui.TouchEventType.began then 
			AudioManager:getInstance():playEffect("ButtonClick")
		end
	end

	self._pGoBtn:addTouchEventListener(touchEvent)
end

function StrongerItemRender:updateUI()
	-- 设置功能的图标
	self._pFuncIcon:loadTexture("GuideNrRes/" ..self._pNewFunctionInfo.GuideIcon..".png",ccui.TextureResType.plistType)
	-- 设置功能的名字
	self._pFuncNameText:setString(self._pNewFunctionInfo.FunctionName)
	-- 设置前往按钮的tag 值	
end

function StrongerItemRender:setData(pDataInfo)
	if not pDataInfo then 
		print("StrongerItemRender 数据不能为空")
		return 
	end
	self._pNewFunctionInfo = pDataInfo
	self:updateUI()
end

function StrongerItemRender:onExitStrongerItemRender()
	-- cleanup

end

return StrongerItemRender