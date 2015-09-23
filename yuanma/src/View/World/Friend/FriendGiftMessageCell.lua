--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendGiftMessageCell.lua
-- author:    liyuhang
-- created:   2015/5/26
-- descrip:   礼物信息cell
--===================================================
local FriendGiftMessageCell = class("FriendGiftMessageCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function FriendGiftMessageCell:ctor()
    -- 层名称
    self._strName = "FriendGiftMessageCell"        

    -- 控件
    self._pMessageText = nil
    self._pTimeText = nil

    self._pDataInfo = nil
end

-- 创建函数
function FriendGiftMessageCell:create(dataInfo)
    local dialog = FriendGiftMessageCell.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function FriendGiftMessageCell:dispose(dataInfo)
    
    self._pDataInfo = dataInfo

    self:initUI()

    -- 触摸注册
    local function onTouchBegin(touch,event)
       

        return false
    end
    local function onTouchMoved(touch,event)
        
    end
    local function onTouchEnded(touch,event)
        

    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFriendGiftMessageCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function FriendGiftMessageCell:initUI()
    
    self:updateData()
end

function FriendGiftMessageCell:updateData()
    if self._pDataInfo == nil then
        return
    end
    
    local tMsg = nil
    local info = nil
    if self._pDataInfo.isSend == true then
        info = GetCompleteItemInfo(self._pDataInfo.giftItem)
        tMsg = {
            {type = 2,title = "您送了",fontColor = cRed},
            {type = 2,title = self._pDataInfo.roleName .. " ",fontColor = cWhite},  
            {type = 2,title = self._pDataInfo.giftItem.value,fontColor = cWhite},
            {type = 2,title = "个"..info.templeteInfo.Name,fontColor = cRed},
        }
    else
        info = GetCompleteItemInfo(self._pDataInfo.giftItem)
        tMsg = {
            {type = 2,title = self._pDataInfo.roleName,fontColor = cWhite},           
            {type = 2,title = "送您了",fontColor = cRed},
            {type = 2,title = self._pDataInfo.giftItem.value,fontColor = cWhite},
            {type = 2,title = "个"..info.templeteInfo.Name,fontColor = cRed},
        }
    end
     
    self._pMessageText = require("GoodRichText"):create(tMsg,{x=0,y=0,width=400,height=40})
    self:addChild(self._pMessageText)
    
    self._pTimeText= cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pTimeText:setLineHeight(20)
    self._pTimeText:setAdditionalKerning(-2)
    self._pTimeText:setTextColor(cc.c4b(255, 255, 255, 255))
    self._pTimeText:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self._pTimeText:setPositionX(270)
    self._pTimeText:setPositionY(15)
    self._pTimeText:setWidth(285)
    --self._pTimeText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._pTimeText:setAnchorPoint(0,0)
    self:addChild(self._pTimeText)
    
    self._pTimeText:setString(gOneTimeToStr(os.time() - self._pDataInfo.timestamp))
end

function FriendGiftMessageCell:timeToStrMinute(fTime)
    local strDes = ""
    local nNewTime = fTime + 0.99
    local nNum = fTime%3600

    strDes = strDes..mmo.HelpFunc:gNumToStr(fTime/3600/24).."天 "  -- 天
    strDes = strDes..mmo.HelpFunc:gNumToStr(fTime/3600%24).."时 "             -- 小时
    strDes = strDes.. mmo.HelpFunc:gNumToStr(nNum/60).."分"          -- 分钟
    strDes = strDes.."前"           --秒
    
    return strDes
end

-- 退出函数
function FriendGiftMessageCell:onExitFriendGiftMessageCell()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return FriendGiftMessageCell
