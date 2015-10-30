--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  QueueUpDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/8/10
-- descrip:   排队等候界面
--===================================================
local QueueUpDialog = class("QueueUpDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function QueueUpDialog:ctor()
    self._strName = "QueueUpDialog"        -- 层名称
    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pServerNameText = nil            -- 服务器名字
    self._pCurrRank = nil                  -- 当前排名
    self._pTotalCount = nil                -- 总排名
    self._bHasExitRank = false             -- 是否退出排队
end

-- 创建函数
function QueueUpDialog:create(args)
    local dialog = QueueUpDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function QueueUpDialog:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryRankResp, handler(self, self.queryRank))
    NetRespManager:getInstance():addEventListener(kNetCmd.kCancelRankResp, handler(self, self.CancelRankResp))
    
    
    ResPlistManager:getInstance():addSpriteFrames("ServerRanksDialog.plist")
    local params = require("ServerRanksDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pServerNameText = params._pServerNameText     --服务器名字
    self._pCurrRank = params._pRoleNum                  -- 当前排名
    self._pTotalCount = params._pRoleNumSum             -- 总排名
    self._pOkButton =  params._pOkButton                -- 退出排队
    
    -- 服务器名字
    self._pServerNameText:setString(args[1])
    self:refreshUi(args[2],args[3])
    -- 初始化dialog的基础组件
    self:disposeCSB()
    local pTallTime = 3600000
    local pZoneId = args[4]
    
    local timeCallBack = function(time,id)
        if (pTallTime - time)%10 == 0 then --10秒发一次请求
            if not self._bHasExitRank then
               LoginCGMessage:sendMessageQueryRank(pZoneId)
            end
    	end	
    end
    CDManager:getInstance():insertCD({cdType.kServerRank,pTallTime,timeCallBack})
    
    
    local exitRankDialog = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           self._bHasExitRank = true
           LoginCGMessage:sendMessageCancelRank()
        end
    end
    self._pOkButton:addTouchEventListener(exitRankDialog)
   
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
            return true
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
            self:onExitQueueUpDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function QueueUpDialog:queryRank(event)
    local pCurRank = event.currRank         --当前排名
    local pTotalCount = event.totalCount    --总排名
    self:refreshUi(pCurRank,pTotalCount)
end

function QueueUpDialog:CancelRankResp(event)
  self:close()
end

--刷新界面
function QueueUpDialog:refreshUi(currRank,totalCount)
    self._pCurrRank:setString(currRank)                  -- 当前排名
    self._pTotalCount:setString(totalCount)              -- 总排名	
end

-- 退出函数
function QueueUpDialog:onExitQueueUpDialog()
    self:onExitDialog()
    CDManager:getInstance():deleteOneCdByKey(cdType.kServerRank)
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("ServerRanksDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function QueueUpDialog:update(dt)
    return
end

-- 显示结束时的回调
function QueueUpDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function QueueUpDialog:doWhenCloseOver()
    return
end

return QueueUpDialog
