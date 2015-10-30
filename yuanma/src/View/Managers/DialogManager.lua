--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DialogManager.lua
-- author:    liyuhang
-- created:   2015/1/26
-- descrip:   dialog管理器
--===================================================
DialogManager = {}

local instance = nil

-- 单例
function DialogManager:getInstance()
    if not instance then
        instance = DialogManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function DialogManager:clearCache()
	self._pAppSence = nil
end

-- 设置root场景
function DialogManager:setRootSence( root )
    self._pAppSence = root
end

-- 显示alert（只有确定按钮）
function DialogManager:showAlertDialog(msg,okCallbackFunc)
    local alert = require("AlertDialog"):create(msg,okCallbackFunc)
    alert:setNoCancelBtn()
    self._pAppSence:showDialog(alert)
end

-- 显示confirm（取消和确定按钮都有）
function DialogManager:showConfirmDialog(msg, okCallbackFunc,cancelCallbackFunc)
    self._pAppSence:showDialog(require("AlertDialog"):create(msg, okCallbackFunc,cancelCallbackFunc))
end

-- 显示网络错误（取消和确定按钮都有）
function DialogManager:showNetErrorDialog(msg, okCallbackFunc,cancelCallbackFunc)
    self._pAppSence:showNetErrorDialog()
end

-- 显示Dialog（创建+显示） 根据以后的需求可能会改
function DialogManager:showDialog(pDialogName, args)
    local dialog = self._pAppSence:getDialogByName(pDialogName)
    
    if dialog ~= nil then
        dialog:updateCacheWithData(args)
        self._pAppSence:showCacheDialog(dialog)
    else
        self._pAppSence:showDialog(require(pDialogName):create(args), nil)
    end
end

-- 关闭Dialog（销毁+移除）
function DialogManager:closeDialog(pDialog)
    self._pAppSence:closeDialog(pDialog)
end

-- 关闭Dialog（销毁+移除）
function DialogManager:closeDialogByName(sDialogName)
    self._pAppSence:closeDialogByName(sDialogName)
end

-- 关闭所有Dialog（销毁+移除）
function DialogManager:closeAllDialogs()
    self._pAppSence:closeAllDialogs()
end

-- 关闭所有Dialog（销毁+移除）（不带动画）
function DialogManager:closeAllDialogsWithNoAni()
    self._pAppSence:closeAllDialogsWithNoAni()
end

-- 获得已有的Dialog
function DialogManager:getDialogByName(sDialogName)
    return self._pAppSence:getDialogByName(sDialogName)
end
