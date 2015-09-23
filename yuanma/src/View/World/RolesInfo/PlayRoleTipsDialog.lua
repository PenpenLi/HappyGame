--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PlayRoleTipsDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/2/12
-- descrip:   改名
--===================================================
local PlayRoleTipsDialog = class("PlayRoleTipsDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function PlayRoleTipsDialog:ctor()
    self._strName = "PlayRoleTipsDialog"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pRoleNameText = nil                   --人物的名字
	self._pCatRoleInfoBtn = nil 				--查看任务详情
	self._pAddFriendBtn = nil					--加好友btn
    self._pChangeType = nil

end

-- 创建函数
function PlayRoleTipsDialog:create(args)
    local dialog = PlayRoleTipsDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function PlayRoleTipsDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("PlayRoleTipsPanel.plist")

    local params = require("PlayRoleTipsPanelParams"):create()
    self._pCCS = params._pCCS
	self._pBg = params._pBackBg
    self._pCloseButton = params._pCloseButton
    self._pRoleNameText = params._pNameText                 --人物的名字
	self._pCatRoleInfoBtn = params._pButton_1 				--查看人物详情
	self._pAddFriendBtn = params._pButton_2					--加好友btn
    -- 初始化dialog的基础组件
    self:disposeCSB()
	--人物的详细信息
	self.pRoleInfo = args[1]
     self._pRoleNameText:setString(self.pRoleInfo.roleName)
	
	   local onTouchButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           local pTag = sender:getTag()
    	   if pTag ==  1000 then --查看人物详情
    		  FriendCGMessage:sendMessageQueryRoleInfoFriend22018(self.pRoleInfo.roleId)
    	   elseif pTag ==  2000 then 	--加好友btn
    		  FriendCGMessage:sendMessageApplyFriend22010(self.pRoleInfo.roleId)  
    	   end
		    self:close()
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick") 
        end
    end
	
	
	self._pCatRoleInfoBtn:addTouchEventListener(onTouchButton)
	self._pCatRoleInfoBtn:setZoomScale(nButtonZoomScale)
    self._pCatRoleInfoBtn:setPressedActionEnabled(true)
	self._pCatRoleInfoBtn:setTag(1000)
	self._pAddFriendBtn:addTouchEventListener(onTouchButton)
	self._pAddFriendBtn:setZoomScale(nButtonZoomScale)
    self._pAddFriendBtn:setPressedActionEnabled(true)
    self._pAddFriendBtn:setTag(2000)
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
        end
        return true   --可以向下传递事件
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
            self:onExitPlayRoleTipsDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end


-- 退出函数
function PlayRoleTipsDialog:onExitPlayRoleTipsDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("PlayRoleTipsPanel.plist")
    --NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function PlayRoleTipsDialog:update(dt)
    return
end

-- 显示结束时的回调
function PlayRoleTipsDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function PlayRoleTipsDialog:doWhenCloseOver()
    return
end

return PlayRoleTipsDialog
