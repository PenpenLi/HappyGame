--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BeautyIconItemRender.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/08/10
-- descrip:   群芳阁美人头像模板
--===================================================
local BeautyIconItemRender = class("BeautyIconItemRender",function () 
	return ccui.ImageView:create()
end)

function BeautyIconItemRender:ctor()
	self._strName = "BeautyIconItemRender"
	self._pBgImg = nil 
	self._pIconBgImg = nil 
	self._pIconImg = nil 
	self._pNameText = nil 
	self._pNumText = nil 
	self._tHeartImg = {}
	-------------------------------------
	self._index = 0
	self._pBeautyInfo = nil 
	-- 选中的回调函数
	self._selectedCallbackFunc = nil
	self._fMoveDis = 0                        -- 每次点击emailItem项时的位移
end

function BeautyIconItemRender:create(beautyInfo)
	local imageView = BeautyIconItemRender.new()
	imageView:dispose(beautyInfo)
	return imageView
end

function BeautyIconItemRender:dispose(beautyInfo)
	local params = require("BeautyListInfoParams"):create()
	self._pBgImg = params._pListBg
	self._pIconImg = params._pBelleIcon01
	self._pNameText = params._pGetNameText
	self._pNumText = params._pGetNumText
	self._tHeartImg = {
		params._pQinM01,
		params._pQinM02,
		params._pQinM03,
		params._pQinM04,
		params._pQinM05,
	}
	self._pIconBgImg = params._pBelleIcon01Bg
	self:addChild(params._pCCS)

	local function touchEvent(sender,eventType)
	 	if eventType == ccui.TouchEventType.began then
	 		AudioManager:getInstance():playEffect("ButtonClick")
            self._fMoveDis = 0
        elseif eventType == ccui.TouchEventType.moved then
            self._fMoveDis = self._fMoveDis + 1
        elseif eventType == ccui.TouchEventType.ended then
			if self._fMoveDis <= 5 then
				if self._selectedCallbackFunc then
					self._selectedCallbackFunc(self._index)
				end
				self:changeSelectEvent(true)
			end
			self._fMoveDis = 0
		end
	end

	self._pBgImg:setTouchEnabled(true)
	self._pBgImg:addTouchEventListener(touchEvent)
	self._pBgImg:setSwallowTouches(false)
	self:setDataSource(beautyInfo)

	------------节点事件-------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBeautyIconItemRender()
        end
    end
    self:registerScriptHandler(onNodeEvent)	
end

function BeautyIconItemRender:setDataSource(beautyInfo)
	if not beautyInfo then
		return
	end
	self._pBeautyInfo = beautyInfo
	-- 头像图标
	self._pIconImg:loadTexture(beautyInfo.templeteInfo.Icon..".png",ccui.TextureResType.plistType)
	-- 名字
	self._pNameText:setString(beautyInfo.templeteInfo.Name)
	-- 拥有个数
	if beautyInfo.num > 0 then 
		self._pNumText:setVisible(true)
		self._pNumText:setString("x"..beautyInfo.num)
	else
		self._pNumText:setVisible(false)
	end
	-- 亲密等级
	for i,heartImg in ipairs(self._tHeartImg) do
		heartImg:setVisible(i <= beautyInfo.level)
	end
	-- 判断是否邂逅
	if beautyInfo.haveSeen == false then 
		darkNode(self._pBgImg:getVirtualRenderer():getSprite())
		darkNode(self._pIconImg:getVirtualRenderer():getSprite())
		darkNode(self._pIconBgImg)
	else	
		unDarkNode(self._pBgImg:getVirtualRenderer():getSprite())
		unDarkNode(self._pIconImg:getVirtualRenderer():getSprite())
		unDarkNode(self._pIconBgImg)
	end

end

function BeautyIconItemRender:setIndex(index)
	self._index = index
end

function BeautyIconItemRender:setCallbackFunc(callback)
	self._selectedCallbackFunc = callback
end

-- 选中事件
function BeautyIconItemRender:changeSelectEvent(bSelected)
	local strImg = bSelected == true and "BeautyListInfoRes/jlxt6.png" or "BeautyListInfoRes/qfgjm21.png"
    self._pBgImg:loadTexture(strImg,ccui.TextureResType.plistType)
end

function BeautyIconItemRender:onExitBeautyIconItemRender()
	-- cleanup
end

return BeautyIconItemRender