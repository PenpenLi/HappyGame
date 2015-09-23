--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ChatPlayerDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/6/29
-- descrip:   
--===================================================
local ChatPlayerDialog = class("ChatPlayerDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function ChatPlayerDialog:ctor()
    self._strName = "ChatPlayerDialog"        -- 层名称

    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pHeadIcon = nil --人物头像
    self._pName = nil     --玩家昵称
    self._pLevel = nil    --玩家等级数字
    self._pFriend = nil   --添加好友按钮
    self._pChat = nil     --发起私聊按钮
    self._pCheck = nil    --查看玩家按钮
    self._pBlock = nil    --屏蔽玩家按钮
    self._pTempInfo = nil

end

-- 创建函数
function ChatPlayerDialog:create(args)
    local dialog = ChatPlayerDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function ChatPlayerDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("ChatPlayerParams.plist")
    self._pTempInfo = args[1]
    
    local params = require("ChatPlayerParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pHeadIcon = params._pHeadIcon --人物头像
    self._pName =  params._pName --玩家昵称
    self._pLevel =  params._pLevel --玩家等级数字
    self._pFriend =  params._pFriend --添加好友按钮
    self._pChat =  params._pChat --发起私聊按钮
    self._pCheck =  params._pCheck --查看玩家按钮
    self._pBlock =  params._pBlock --屏蔽玩家按钮

    -- 初始化dialog的基础组件
    self:disposeCSB()
    
    --初始化UI
    self:initUi()
 
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return false   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end ".."x="..location.x.."  y="..location.y)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitChatPlayerDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end


--初始化UI
function ChatPlayerDialog:initUi()
    self._pHeadIcon:loadTexture( self._pTempInfo.roleIcon,ccui.TextureResType.plistType)
    self._pName:setString(self._pTempInfo.name)--玩家昵称
    self._pLevel:setString(self._pTempInfo.level)--玩家昵称
    
    --设置按钮点击
    local onTouchButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            if nTag == 1000 then     --添加好友
                FriendCGMessage:sendMessageApplyFriend22010(self._pTempInfo.desRoleId)  
            elseif nTag == 2000 then --发起私聊按钮
             --发送聊天
              local dialog =  DialogManager:getInstance():getDialogByName("ChatDialog")
                if dialog then --超链接到私聊界面
                    dialog:JumpPrivateDesRole(self._pTempInfo.desRoleId)
                else
                   DialogManager:getInstance():showDialog("ChatDialog",{kChatType.kPrivate,self._pTempInfo.desRoleId})
               end
               
            elseif nTag == 3000 then --查看玩家按钮
                FriendCGMessage:sendMessageQueryRoleInfoFriend22018(self._pTempInfo.desRoleId)
            else --屏蔽玩家按钮
                ChatCGMessage:sendMessageSetBlackList21306(self._pTempInfo.desRoleId)
            end
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    --添加好友
    self._pFriend:setTag(1000)
    self._pFriend:addTouchEventListener(onTouchButton)
    --发起私聊按钮
    self._pChat:setTag(2000)
    self._pChat:addTouchEventListener(onTouchButton)
    --查看玩家按钮
    self._pCheck:setTag(3000)
    self._pCheck:addTouchEventListener(onTouchButton)
    --屏蔽玩家按钮
    self._pBlock:setTag(4000)
    self._pBlock:addTouchEventListener(onTouchButton)
    
    
    --设置黑名单按钮的状态
    local pList = ChatManager:getInstance()._tBlacklist
    --设置黑名单的状态
    for k,v in pairs(pList) do
       if v.roleId == self._pTempInfo.desRoleId then --如果发现自己的黑名单列表里面有这个人
          self._pBlock:setTitleText("解除屏蔽")
       end
    
    end
    
end

-- 退出函数
function ChatPlayerDialog:onExitChatPlayerDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("ChatPlayerParams.plist")
end

-- 循环更新
function ChatPlayerDialog:update(dt)
    return
end

-- 显示结束时的回调
function ChatPlayerDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function ChatPlayerDialog:doWhenCloseOver()
    return
end

return ChatPlayerDialog
