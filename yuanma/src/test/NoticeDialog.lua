--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NoticeDialog.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   公告对话框
--===================================================
local NoticeDialog = class("NoticeDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function NoticeDialog:ctor()
    self._strName = "NoticeDialog"        -- 层名称
    self._pCheckBox = nil
    self._pImage = nil
    self._pBMLabel = nil
    self._pLoadingBar = nil
    self._pSlider = nil
    self._pText = nil
    self._pTextField = nil
    self._pParticle = nil
    
end

-- 创建函数
function NoticeDialog:create()
    local dialog = NoticeDialog.new()
    dialog:dispose()
    return dialog
end

-- 处理函数
function NoticeDialog:dispose()

    -- 加载公司notice_dialog合图资源
    ResPlistManager:getInstance():addSpriteFrames("notice_dialog.plist")

    -- 加载dialog组件
    local params = require("NoticeDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    
    -- 初始化dialog的基础组件
    self:disposeCSB()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitNoticeDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function NoticeDialog:onExitNoticeDialog()
    self:onExitDialog()
    
    -- 释放掉login合图资源  
    ResPlistManager:getInstance():removeSpriteFrames("notice_dialog.plist")

end

-- 循环更新
function NoticeDialog:update(dt)
    return
end

-- 显示结束时的回调
function NoticeDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function NoticeDialog:doWhenCloseOver()
    return
end

return NoticeDialog
