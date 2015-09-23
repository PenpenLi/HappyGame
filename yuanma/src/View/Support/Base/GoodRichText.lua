--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GoodRichText.lua
-- author:    wuquandong 
-- e-mail:    365667276@qq.com
-- created:   2015/1/27
-- descrip:   自定义的富文本
--===================================================
local kRichElementType = {
	-- 新的一行
	kRichItemNewLine = 1,
	-- 文本
	kRichItemText = 2,
	-- 图片
	kRichItemImage = 3,
	-- 
	kRichItemCustom = 4,
}

local GoodRichText = class("GoodRichText",function()
	return ccui.ScrollView:create()
end)


-- 构造函数
function GoodRichText:ctor()
	-- 当前显示的标签
	self._nShowTag = 0
	-- 最大显示的行数
	self._nMaxLine = 200
	-- 行间距
	self._nLineSpace = 5
	-- 当前行排版余的宽度
	self._nLeftSpaceWidth = 0
	-- 是否重新排版
	self._isFormatTextDirty = true
	-- 文本内容
	self._context = ""
	-- 文本标签的集合
	self._tRichElements = {}
	self._customSize = nil
	-- 
	self._tElementRenders = {}
	-- 根据不同的标签类型执行不同的处理方法
	self._tHandleActions = {
		[kRichElementType.kRichItemNewLine] = function () self:changeLine() end,
		[kRichElementType.kRichItemText] = function (element) self:handleTextRenderer(element) end,
		[kRichElementType.kRichItemImage] = function (element) self:handleImageRenderer(element) end,  
		[kRichElementType.kRichItemCustom] = function (element) self:handleCustomRenderer(element) end,
	}
end

-- 创建函数 
function GoodRichText:create(tTitle,sContentSize)
	local goodRichText = GoodRichText.new()
    goodRichText:dispose(tTitle,sContentSize)
	return goodRichText
end

-- 处理函数
function GoodRichText:dispose(tTitle,sContentSize)
	self:setInertiaScrollEnabled(true)
	self:setContentSize(sContentSize)
	self._customSize = self:getContentSize()
	for k,v in pairs(tTitle) do
		-- {type = 1,title = "这是一个测试内容",fontColor = cc.c3b(255, 255, 255)}
		if not v.fontName then
            v.fontName = strCommonFontName
		end
		if not v.fontSize then
			v.fontSize = 20
		end
		if not v.fontColor then
			v.fontColor = cc.c3b(255,255,255)
		end
		if not v.opacity then
			v.opacity = 255
		end
		self:insertElement(v)
	end
    self:formatText()
end

-- 设置内容
function GoodRichText:setString(tTitle) 
	for k,v in pairs(tTitle) do
		-- {type = 1,title = "这是一个测试内容",fontColor = cc.c3b(255, 255, 255)}
		if not v.fontName then
            v.fontName = strCommonFontName
		end
		if not v.fontSize then
			v.fontSize = 20
		end
		if not v.fontColor then
			v.fontColor = cc.c3b(255,255,255)
		end
		if not v.opacity then
			v.opacity = 255
		end
		self:insertElement(v)
	end
    self:formatText()
end

-- clearAll
function GoodRichText:clearAll()
	self._tRichElements = {}
	self._isFormatTextDirty = true
end 

-- insertNewLine 
function GoodRichText:insertNewLine()
	local pItem = require(""):create()
	self:insertElement(pItem)
end

-- 插入元素
function GoodRichText:insertElement(element)
	table.insert(self._tRichElements,element)
	self._isFormatTextDirty = true
end

-- formatText()
function GoodRichText:formatText()
	if (self._isFormatTextDirty) then
		self:removeAllChildren()
		self._tElementRenders = {}
		self:changeLine()
		for k,pRichElement in pairs(self._tRichElements) do
			if self._nShowTag == 0 or pRichElement.tag == 0 or pRichElement.tag == self._nShowTag then
				self._tHandleActions[pRichElement.type](pRichElement)
			end
		end
		self:formartRenders()
		self._isFormatTextDirty = false
		self:jumpToBottom()
	end
end

--showItemByTag
function GoodRichText:showItemByTag(tag)
	if self._nShowTag ~= tag then
		self._nShowTag = tag
		self._isFormatTextDirty = true
	end
end

-- setMaxLine()
function GoodRichText:setMaxLine(nLineCount)
	self._nMaxLine = nLineCount
end

-- setLineSpace
function GoodRichText:setLineSpace(nLineSpace)
	self._nLineSpace = nLineSpace
end

function GoodRichText:changeLine()
	-- _customSize is portected 
	self._nLeftSpaceWidth = self._customSize.width
	table.insert(self._tElementRenders,cc.Node:create())
end

-- 处理文本标签（以后扩展超链接）
function GoodRichText:handleTextRenderer(element)
	local pLabel = nil
	local isFileExist = cc.FileUtils:getInstance():isFileExist(element.fontName)
	pLabel = cc.Label:createWithTTF(element.title,element.fontName,element.fontSize)

    self._nLeftSpaceWidth = self._nLeftSpaceWidth - pLabel:getContentSize().width
    if self._nLeftSpaceWidth < 0.0 then
        pLabel:setWidth(self._customSize.width)
        pLabel:setLineBreakWithoutSpace(true)
    end
	pLabel:setColor(element.fontColor)
	pLabel:setOpacity(element.opacity)
	self:pushToContainer(pLabel)

end

-- 处理图片
function GoodRichText:handleImageRenderer(element)
	local pImageRender = cc.Sprite:createWithSpriteFrameName(element.title)
	self:handleCustomRenderer(pImageRender)
end

-- 自定义
function GoodRichText:handleCustomRenderer(element)
	local imgSize = element:getContentSize()
	self._nLeftSpaceWidth = self._nLeftSpaceWidth - imgSize.width
	if self._nLeftSpaceWidth < 0.0 then 
		--self:addNewLine()
		self:changeLine()
		self:pushToContainer(element)
		self._nLeftSpaceWidth = self._nLeftSpaceWidth - imgSize.width
	else
		self:pushToContainer(element)
	end
end

-- formartRenders
function GoodRichText:formartRenders()
	while #self._tElementRenders > self._nMaxLine do
		table.remove(self._tElementRender,1)
	end
	local newContentSizeHeight = 0.0 
	local tMaxHeights = {}
	for k,render in pairs(self._tElementRenders) do
		local maxHeight = 0.0
		if type(render) == "table" then 
    		for k2,v in pairs(render) do
    			maxHeight = math.max(v:getContentSize().height,maxHeight)
    		end
		else
		  render:setContentSize(cc.size(self._customSize.width,self._nLineSpace))
		end
		tMaxHeights[k] = maxHeight + self._nLineSpace
		newContentSizeHeight = newContentSizeHeight + tMaxHeights[k]
	end
    if newContentSizeHeight < self._customSize.height then
        newContentSizeHeight = self._customSize.height
    end
	local nexPosY = newContentSizeHeight
	for k1,v in pairs(self._tElementRenders) do
		local nextPosX = 0.0
		nexPosY = nexPosY - tMaxHeights[k1]
		if type(v) == "table" then
    		for k3,element in pairs(v) do
    			element:setAnchorPoint(cc.p(0,0))
                element:setPosition(cc.p(nextPosX,nexPosY))
                self:addChild(element,1,k1 * 10 + k3)
                nextPosX = nextPosX + element:getContentSize().width
    		end
		else
            v:setAnchorPoint(cc.p(0,0))
            v:setPosition(cc.p(nextPosX,nexPosY))
            self:addChild(v,1,k1 * 10 )
		end
	end
	tMaxHeights = {}
	self._tElementRenders = {}
	self:setInnerContainerSize(cc.size(self._customSize.width,newContentSizeHeight))
end

-- pushToContainer()
function GoodRichText:pushToContainer(render)
	if #self._tElementRenders <= 0 then
		return 
	end
	--table.insert(self._tElementRenders,render)
	if type(self._tElementRenders[#self._tElementRenders]) ~= "table" then
	   self._tElementRenders[#self._tElementRenders] = {}
	end
	table.insert(self._tElementRenders[#self._tElementRenders],render)
end

-- visit ()
function GoodRichText:visit(render,parentTransform,parentTransformUpdated)
	if self._enabled then
		self:formatText()
		self:visit(render,parentTransform,parentTransformUpdated)
	end
end

return GoodRichText