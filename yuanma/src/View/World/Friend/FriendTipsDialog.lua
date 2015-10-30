--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendTipsDialog.lua
-- author:    liyuhang
-- created:   2015/5/18
-- descrip:   好友功能列表面板
--===================================================
local FriendTipsDialog = class("FriendTipsDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FriendTipsDialog:ctor()
    -- 层名字
    self._strName = "FriendTipsDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self.params = nil

    self._pData = nil
end

-- 创建函数
function FriendTipsDialog:create(args)
    local layer = FriendTipsDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function FriendTipsDialog:dispose(args)
    -- 注册网络回调事件
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetGetPets, handler(self,self.handleMsgGetPets))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFieldPet, handler(self,self.handleMsgFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetUnFieldPet, handler(self,self.handleMsgUnFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("FriendTipsDialog.plist")

    self._pData = args[1]

    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFriendTipsDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function FriendTipsDialog:initUI()
    -- 加载组件
    local params = require("FriendTipsDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
      
    self.params._pButton2:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            showConfirmDialog("是否删除好友" ..self._pData.roleName .."?",function()
               FriendCGMessage:sendMessageRemoveFriend(self._pData.roleId)
               self:close()
            end) 
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self.params._pButton3:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then

            ChatManager:getInstance():setDesInfoByRoleInfo(self._pData)
            DialogManager:showDialog("ChatDialog",{kChatType.kPrivate,self._pData.roleId})
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    
    self.params._pButton4:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            DialogManager:showDialog("FriendGiftDialog",{self._pData})
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self.params._pButton5:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            FriendCGMessage:sendMessageQueryRoleInfoFriend22018(self._pData.roleId)
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    self.params._pButton6:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
--            if RolesManager:getInstance()._pMainRoleInfo.level < TableNewFunction[18].Level then --等级不足
--                NoticeManager:getInstance():showSystemMessage("酒坊系统"..TableNewFunction[11].Level.."级开放")
--                return 
--            end
            DrunkeryCGMessage:getFriendWineryReq22108()
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    self:disposeCSB()
end

-- 初始化触摸相关
function FriendTipsDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

-- 退出函数
function FriendTipsDialog:onExitFriendTipsDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FriendTipsDialog.plist")
end

return FriendTipsDialog