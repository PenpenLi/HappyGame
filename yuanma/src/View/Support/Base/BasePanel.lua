--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BasePanel.lua
-- author:    liyuhang
-- created:   2015/1/24
-- descrip:   面板基类
--===================================================
local BasePanel = class("BasePanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function BasePanel:ctor()
    self._strName = "BasePanel"        -- 对话框名称

    self._pTouchListener = nil      -- 触摸监听器

    self._pIgnoreTouchLayer = require("NoTouchLayer"):create()   -- 加载触摸屏蔽层
    self:addChild(self._pIgnoreTouchLayer,kZorder.kLayer)
end

-- 创建函数
function BasePanel:create()
    local basePanel = BasePanel.new()
    basePanel:dispose()
    return basePanel
end

-- 处理函数
function BasePanel:dispose()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function BasePanel:onExitPanel()

end

-- 循环更新
function BasePanel:update(dt)

end

function BasePanel:setTouchEnableInPanel( beTouchEnable )
    self._pIgnoreTouchLayer._pTouchListener:setEnabled(beTouchEnable)
end


return BasePanel

