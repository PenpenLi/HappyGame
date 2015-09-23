--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DialogTriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/6
-- descrip:   对话框激活动作项
--===================================================
local DialogTriggerItem = class("DialogTriggerItem",function()
    return require("TriggerItem"):create()
end)

-- 构造函数
function DialogTriggerItem:ctor()
    self._kType = kType.kTriggerItemType.kDialog   -- 触发器动作项的类型
    self._fDialogName = ""                         -- 待触发的对话框名称
   
end

-- 创建函数
function DialogTriggerItem:create(index, dialogName)
    local item = DialogTriggerItem.new()
    item._nIndex = index
    item._fDialogName = dialogName
    return item
end

-- 作用函数
function DialogTriggerItem:work()
    if self._pOwnerTrigger._nCurStep == self._nIndex and  -- 列表中上一个动作运行结束以后才可以进入到当前动作的执行
        self:getMapManager()._pTmxMap:getActionByTag(nTriggerItemTag) == nil then 
        
        -- if DialogManager:getInstance():getDialogByName(self._fDialogName) == nil then
        if DialogManager:getInstance():getDialogByName("AlertDialog") == nil then
            -- DialogManager:getInstance():showDialogByName(self._fDialogName)
            showAlertDialog("触发对话框！！！")
            self._pOwnerTrigger._bOpened = false    -- 触发器重新复位，使下一次可以继续使用
            self._pOwnerTrigger._bWorking = false
            self:getTriggersManager():refreshDebugLayer()
        end

    end
end

return DialogTriggerItem
