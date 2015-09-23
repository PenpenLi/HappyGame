--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ElementText.lua
-- author:    taoye
-- created:   2015/6/26
-- descrip:   多元文本控件（图文混排）
--===================================================
local ElementText = class("ElementText",function()
    return ccui.RichText:create()
end)

-- 构造函数
function ElementText:ctor()
    self._strVipHead = ""               -- 字符串VIP头内容
    self._cVipColor = cGreen            -- VIP头颜色 
    self._strNameHead = ""              -- 字符串名称头内容
    self._cNameColor = cYellow          -- 名称头颜色
    self._strContent = ""               -- 字符串内容
    self._cContentColor = cWhite        -- 内容字体颜色
    self._nFontSize = 30                -- 字体大小
    self._sTotalSize = cc.size(300,30)  -- 总size
    self._tElements = {}                -- 元素对象集合

end

-- 创建函数
function ElementText:create(vip,vipColor,name,nameColor,content,contentColor,fontSize,totalSize)
    local text = ElementText.new()
    text:dispose(vip,vipColor,name,nameColor,content,contentColor,fontSize,totalSize)
    return text
end

-- 处理函数
function ElementText:dispose(vip,vipColor,name,nameColor,content,contentColor,fontSize,totalSize)    
    self:refresh(vip,vipColor,name,nameColor,content,contentColor,fontSize,totalSize)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitElementText()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function ElementText:onExitElementText()

end

-- 重新设置内容（刷新内容）
function ElementText:refresh(vip,vipColor,name,nameColor,content,contentColor,fontSize,totalSize)    
    -- 记录相关参数
    if vip then
        self._strVipHead = vip
    end
    if vipColor then
        self._cVipColor = vipColor
    end
    if name then
        self._strNameHead = name
    end
    if nameColor then
        self._cNameColor = nameColor
    end
    if content then
        self._strContent = content
    end
    if contentColor then
        self._cContentColor = contentColor
    end
    if fontSize then
        self._nFontSize = fontSize
    end
    if totalSize then
        self._sTotalSize = totalSize
    end
    
    self:ignoreContentAdaptWithSize(false)
    self:setContentSize(self._sTotalSize)
    
    -- 移除所有子元素
    for k,v in pairs(self._tElements) do 
        self:removeElement(v)
    end
    self._tElements = {}
    
    -- VIP头
    local tmpVip = ccui.RichElementText:create(1, self._cVipColor, 255, self._strVipHead, strCommonFontName, self._nFontSize)        -- 创建文本控件元素
    self:pushBackElement(tmpVip)                -- 把控件元素添加到队列中
    table.insert(self._tElements,tmpVip)        -- 记录元素
    
    -- 名称头
    local tmpName = ccui.RichElementText:create(1, self._cNameColor, 255, self._strNameHead, strCommonFontName, self._nFontSize)        -- 创建文本控件元素
    self:pushBackElement(tmpName)               -- 把控件元素添加到队列中
    table.insert(self._tElements,tmpName)       -- 记录元素   
    
    -- 开始解析text到node
    while content ~= "" and content ~= nil do
        local emoStartPos = string.find(content, "{^") -- 返回表情符号在字符串中的起始位置和终止位置
        if emoStartPos then       -- 存在表情
            local emoNumber = string.sub(content,emoStartPos+2,emoStartPos+3)
            emoNumber = tonumber(emoNumber)
            local emoEndFlag = string.sub(content,emoStartPos+4,emoStartPos+4)
            if emoNumber and emoNumber >=0 and emoNumber <= TableConstants.ExpressionNum.Value and emoEndFlag == "}" then
                local emoEndPos = emoStartPos + 5
                local tmpString = string.sub(content,1,emoStartPos-1)   -- 获取该表情符号之前的字符串内容
                local tmp = ccui.RichElementText:create(1, self._cContentColor, 255, tmpString, strCommonFontName, self._nFontSize)        -- 创建文本控件元素
                self:pushBackElement(tmp)       -- 把控件元素添加到队列中
                table.insert(self._tElements,tmp)       -- 记录元素
                local emoSignal = string.sub(content,emoStartPos, emoEndPos-1)
                local emoFileName = string.sub(emoSignal,3, -2)
                if emoFileName then
                    emoFileName = emoFileName..".png"
                    local tmp = ccui.RichElementImage:create(2, cc.c3b(255,255,255), 255, "emo/"..emoFileName)        -- 创建表情控件元素
                    self:pushBackElement(tmp)       -- 把控件元素添加到队列中
                    table.insert(self._tElements,tmp)       -- 记录元素
                end
                content = string.sub(content,emoEndPos,-1)   -- 取出当前表情之后的字符串
            else  -- 后面没有表情
                local tmp = ccui.RichElementText:create(1, self._cContentColor, 255, content, strCommonFontName, self._nFontSize)        -- 创建文本控件元素
                self:pushBackElement(tmp)       -- 把控件元素添加到队列中
                table.insert(self._tElements,tmp)       -- 记录元素
                break
            end
        else    -- 后面不再有表情了
            local tmp = ccui.RichElementText:create(1, self._cContentColor, 255, content, strCommonFontName, self._nFontSize)        -- 创建文本控件元素
            self:pushBackElement(tmp)       -- 把控件元素添加到队列中
            table.insert(self._tElements,tmp)       -- 记录元素
            break
        end
    end
    
    self:formatText()
    self:ignoreContentAdaptWithSize(false)
    self:setContentSize(cc.size(self._sTotalSize.width, self:getHeight()))
    
end

-- 获取宽度
function ElementText:getTotalWidth()
    return self:getWidth()
end

-- 获取高度
function ElementText:getHeight()
    return self:getVirtualRendererSize().height
end

return ElementText

