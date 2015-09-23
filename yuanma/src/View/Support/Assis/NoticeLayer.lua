--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NoticeLayer.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/21
-- descrip:   文字层
--===================================================
local NoticeLayer = class("NoticeLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function NoticeLayer:ctor()
    self._strName = "NoticeLayer"         -- 层名称
end

-- 创建函数
function NoticeLayer:create()
    local layer = NoticeLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function NoticeLayer:dispose()
    NoticeManager:getInstance():setNoticeLayer(self)
end


return NoticeLayer
