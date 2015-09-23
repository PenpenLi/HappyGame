--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OpenItemHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/6/8
-- descrip:   打开物品的handler  
--===================================================
local OpenItemHandler = class("OpenItemHandler")

-- 构造函数
function OpenItemHandler:ctor()
    -- 打开宝箱
    NetHandlersManager:registHandler(20133, self.handleOpenBox20133)
    -- 吃丹
    NetHandlersManager:registHandler(20135, self.handleEatPills20135)
end
-- 创建函数
function OpenItemHandler:create()
    print("OpenItemHandler create")
    local handler = OpenItemHandler.new()
    return handler
end

--打开宝箱
function OpenItemHandler:handleOpenBox20133(msg)
    print("OpenItemHandler 20133")
    if msg.header.result == 0 then
        DialogManager:getInstance():showDialog("GetItemsDialog",msg.body)
        --DialogManager:getInstance():closeDialogByName("MutlipeUseItemDialog") 
        if not BagCommonManager:getInstance():getItemInfoByIndex(msg.body.argsBody.index) then --如果此物品卖完了就关闭版子
            DialogManager:getInstance():closeDialogByName("BagCallOutDialog") 
        end
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 吃丹
function OpenItemHandler:handleEatPills20135(msg)
    print("OpenItemHandler 20135")
    if msg.header.result == 0 then
        RolesManager:getInstance()._pMainRoleInfo.exp = msg["body"].exp
        RolesManager:getInstance()._pMainRoleInfo.level = msg["body"].level
        RolesManager:getInstance()._pMainRoleInfo.strength = msg["body"].strength
        
    else
        print("返回错误码："..msg.header.result)
    end
	
end


return OpenItemHandler