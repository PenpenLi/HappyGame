--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FinanceNoticeHandler.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   金融系统数据通知的handler
--===================================================
local FinanceNoticeHandler = class("FinanceNoticeHandler")

-- 构造函数
function FinanceNoticeHandler:ctor()     
    -- 金融数据刷新返回的handler
    NetHandlersManager:registHandler(29501, self.handleFinanceNotice29501)
    -- 背包数据返回
    NetHandlersManager:registHandler(29505, self.handleItemListNotice29505)
    
end

-- 创建函数
function FinanceNoticeHandler:create()
    local handler = FinanceNoticeHandler.new()
    return handler
end

-- 网络关于金融数据的通知结果
function FinanceNoticeHandler:handleFinanceNotice29501(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        FinanceManager:getInstance():refreshDataNetBack(event.finances)

        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateFisance,{})
    else
        local strError = "返回错误码："..msg.header.result
    end
end

function FinanceNoticeHandler:handleItemListNotice29505(msg)
    if msg.header.result == 0 then 
        BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)

        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, event)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kEquipWarning, {})
    else
        local strError = "返回错误码："..msg.header.result
    end
end

return FinanceNoticeHandler