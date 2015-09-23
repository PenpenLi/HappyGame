--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendFindInfoDialog.lua
-- author:    liyuhang
-- created:   2015/5/18
-- descrip:   好有查找结果系统面板
--===================================================
local FriendFindInfoDialog = class("FriendFindInfoDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FriendFindInfoDialog:ctor()
    -- 层名字
    self._strName = "FriendFindInfoDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self.params = nil

    self._pItems = {}
    
    self._pData = nil
end

-- 创建函数
function FriendFindInfoDialog:create(args)
    local layer = FriendFindInfoDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function FriendFindInfoDialog:dispose(args)
    -- 注册网络回调事件
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetGetPets, handler(self,self.handleMsgGetPets))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFieldPet, handler(self,self.handleMsgFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetUnFieldPet, handler(self,self.handleMsgUnFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("FindFriendInfoDialog.plist")

    self._pData = args[1]
    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFriendFindInfoDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function FriendFindInfoDialog:initUI()
    -- 加载组件
    local params = require("FindFriendInfoDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    
    local friendResult = FriendManager:checkIsFriendWithRoleId(self._pData.roleId)
    
    if friendResult ~= -1 or self._pData.roleId == RolesManager:getInstance()._pMainPlayerRole._pRoleInfo.roleId then
        self.params._pAddButton:setVisible(false)
    end
    
    self.params._pAddButton:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            FriendCGMessage:sendMessageApplyFriend22010(self._pData.roleId)
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    self:disposeCSB()
    
    self.params._pText1_1:setString(self._pData.level)
    self.params._pText2_2:setString(self._pData.roleName)
    self.params._pText3_3:setString(kRoleCareerTitle[self._pData.roleCareer])
    self.params._pText4_4:setString(self._pData.fightingPower)
    
    self.params._pHeadIcon:loadTexture(
        kRoleIcons[self._pData.roleCareer],
        ccui.TextureResType.plistType)
end

-- 初始化触摸相关
function FriendFindInfoDialog:initTouches()
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
function FriendFindInfoDialog:onExitFriendFindInfoDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FindFriendInfoDialog.plist")
end

return FriendFindInfoDialog