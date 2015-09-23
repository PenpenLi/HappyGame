--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendGiftDialog.lua
-- author:    liyuhang
-- created:   2015/5/18
-- descrip:   好有礼物系统面板
--===================================================
local FriendGiftDialog = class("FriendGiftDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FriendGiftDialog:ctor()
    -- 层名字
    self._strName = "FriendGiftDialog" 
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
function FriendGiftDialog:create(args)
    local layer = FriendGiftDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function FriendGiftDialog:dispose(args)
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateBagItemList, handler(self,self.handleMsgUpdate))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFieldPet, handler(self,self.handleMsgFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetUnFieldPet, handler(self,self.handleMsgUnFieldPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("FriendGiftDialog.plist")

    self._pData = args[1]

    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFriendGiftDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function FriendGiftDialog:initUI()
    -- 加载组件
    local params = require("FriendGiftDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    self:disposeCSB()
    
    self:updateData()
end

function FriendGiftDialog:updateData()
    local function btnClick(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            
            local info = BagCommonManager:getInstance():getItemRealInfo(tag,kItemType.kFeed)
            if info.value <= 0 then
            	NoticeManager:getInstance():showSystemMessage("礼物不足")
            	return
            end

            FriendCGMessage:sendMessageGiftFriend(self._pData.roleId,tag)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    for i=1,3 do
        local info = BagCommonManager:getInstance():getItemRealInfo(200081-1+i,kItemType.kFeed)
        self.params["_pGiftIcon"..i]:loadTexture(
            info.templeteInfo.Icon..".png",
            ccui.TextureResType.plistType)

        -- 赠送礼品弹tips
        local function touchEvent(sender,eventType)
            if eventType == ccui.TouchEventType.ended then 
                DialogManager:getInstance():showDialog("BagCallOutDialog",{info,nil,nil,false})
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end
        self.params["_pGiftIcon"..i]:setTouchEnabled(true)
        self.params["_pGiftIcon"..i]:addTouchEventListener(touchEvent)

        self.params["_pGiftNameText"..i]:setString(info.templeteInfo.Name)
        self.params["_pGiftText"..i]:setString("亲密度+"..info.dataInfo.Property[1])
        self.params["_pNumText"..i]:setString(info.value)

        self.params["_pButton"..i]:setTag(200081-1+i)
        self.params["_pButton"..i]:addTouchEventListener(btnClick)
    end
end

-- 初始化触摸相关
function FriendGiftDialog:initTouches()
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
function FriendGiftDialog:onExitFriendGiftDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FriendGiftDialog.plist")
end

function FriendGiftDialog:handleMsgUpdate(event)
	self:updateData()
end

return FriendGiftDialog