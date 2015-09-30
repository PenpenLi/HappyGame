--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EmailHandler.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/26
-- descrip:   邮件的handler
--===================================================
local EmailHandler = class("EmailHandler")

-- 构造函数
function EmailHandler:ctor()

    -- 获取邮件列表回复
    NetHandlersManager:registHandler(22201, self.handleEmailList22201)
    -- 获取邮件详情回复
    NetHandlersManager:registHandler(22203, self.handleEmailInfo22203)
    -- 获取邮件删除回复
    NetHandlersManager:registHandler(22205, self.handleEmailDelete22205)
    -- 获取邮件领取附件回复
    NetHandlersManager:registHandler(22207, self.handleEmailGetGoods22207)
    -- 邮件通知
    NetHandlersManager:registHandler(29513, self.handleEmailNotice29513)
    
end

-- 创建函数
function EmailHandler:create()
    local handler = EmailHandler.new()
    return handler
end

-- 获取邮件列表回复
function EmailHandler:handleEmailList22201(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        
        EmailManager:getInstance():setEmailInfos(event.mailList)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kMailList, event.mailList)
        
        -- 家园系统中
        if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
            local hasNewEmail = EmailManager:getInstance():hasNewEmail()
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer"):showNewEmail(hasNewEmail)
        end
        
    else
        local strError = "返回错误码："..msg.header.result
    end
end

-- 获取邮件详情回复
function EmailHandler:handleEmailInfo22203(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        EmailManager:getInstance():setSingleEmailInfo(event.info)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kMailInfo, event)

    else
        local strError = "返回错误码："..msg.header.result
    end
end

-- 获取邮件删除回复
function EmailHandler:handleEmailDelete22205(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kMailDeleteSuccess, event)
        
    else
        local strError = "返回错误码："..msg.header.result
    end
end

-- 获取邮件领取附件回复
function EmailHandler:handleEmailGetGoods22207(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kMailGetGoodsSuccess, event)
        
    else
        local strError = "返回错误码："..msg.header.result
    end
end

-- 邮件的通知
function EmailHandler:handleEmailNotice29513(msg)
    if msg.header.result == 0 then 
        local event = msg["body"]
        print("yuanjs:sendMail")
        EmailManager:getInstance():addEmailInfo(event.mail)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kMailNotice, event.mail)

        -- 家园系统中
        if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
            local hasNewEmail = EmailManager:getInstance():hasNewEmail()
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer"):showNewEmail(hasNewEmail)
        end

    else
        local strError = "返回错误码："..msg.header.result
    end
end

return EmailHandler