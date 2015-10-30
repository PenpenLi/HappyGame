--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GameScene.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   游戏场景（唯一的场景）
--===================================================
local GameScene = class("GameScene",function()
    return cc.Scene:create()
end)

-- 构造函数
function GameScene:ctor()
    self._strName = "GameScene"                 -- 场景名称
    self._tLayers = {}                          -- 场景中层的集合
    self._tDialogs = {}                         -- 场景中对话框的集合
    self._bForceQuit = false                    -- 是否强制退出（当相同账号同时登录，或者服务器强制退出时，此项为true）
    self._nDialogsShowRef = 0
    self._nScheduleID = -1                      -- 场景主Schedule的ID
    self._pMaskBg = nil                         -- 对话框的背景蒙板（用时创建，不用时释放）
    self._pNetWaitingLayer = nil                -- 网络等待层（常驻内存中）
    self._bNetWaiting = false                   -- 标记当前是否正在等待网络响应
    self._bNetTimeoutBegin = false
    self._kCurSessionKind = kSession.kNone      -- 当前会话类型
    
    self._pDebugInfoText = nil                  -- 调试信息专用
    self._tDebugContent = {}                    -- 调试信息文本{"a","gddw",.....}
    self._nHeartBeatCount = 0                   -- 心跳计数器
    self._bSkipHeartBeat = false                -- 是否屏蔽心跳
    
    self._pNetErrorDialog = nil                 -- 网络异常面板特殊处理
    self._pNetReconnectLayer = nil
    
    self._fOtherPlayersReqCounter = 0           -- 多人数据请求时间间隔（5分钟清楚一次）
    self._nSocketReconnectNum = 0
end

-- 创建函数
function GameScene:create()
    local scene = GameScene.new()
    scene:dispose()
    return scene
end

-- 场景处理
function GameScene:dispose()
    ------------------- 初始化-------------------------
    -- 创建网络等待层
    self._pNetWaitingLayer = require("WaitingLayer"):create()
    self._pNetWaitingLayer:showWithAni()
    self:addChild(self._pNetWaitingLayer, kZorder.kWaitingLayer)
    
    self._pNetReconnectLayer = require("NetReconnectLayer"):create()
    self._pNetReconnectLayer:setVisible(false)
    self._pNetReconnectLayer._pTouchListener:setEnabled(false)
    self:addChild(self._pNetReconnectLayer, kZorder.kWaitingLayer)
    
    -- 创建网络异常面板
    self._pNetErrorDialog = require("NetErrorDialog"):create("与服务器断开连接,是否重试",
        function() socketDisconnected("disconnect") end,
        function() 
            LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER) 
            NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetReconnected, {reconnected = false})
        end) 
    self:addChild(self._pNetErrorDialog, kZorder.kMax)
    self._pNetErrorDialog:setVisible(false)
    self._pNetErrorDialog._pTouchListener:setEnabled(false)
    
    -- 调试信息专用
    if bOpenScreenLog == true then
        local ttfConfig  = {}
        ttfConfig.fontFilePath = strCommonFontName
        ttfConfig.fontSize = 20
        self._pDebugInfoText = cc.Label:create()
        self._pDebugInfoText:setDimensions(mmo.VisibleRect:width()*0.75, mmo.VisibleRect:height())
        self._pDebugInfoText:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
        self._pDebugInfoText:setTTFConfig(ttfConfig)
        self._pDebugInfoText:setTextColor(cc.c4b(0,0,0,255))
        self._pDebugInfoText:enableOutline(cFontOutline2,2)
        --self._pDebugInfoText:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self._pDebugInfoText:setString("")
        self._pDebugInfoText:setAnchorPoint(cc.p(0.0, 0.0))
        self._pDebugInfoText:setPosition(cc.p(mmo.VisibleRect:width() - mmo.VisibleRect:width()*0.75, 0))
        self:addChild(self._pDebugInfoText, kZorder.kMax)
    end
    ------------------- 循环处理 -----------------------
    local update = function(dt)
        if self._bForceQuit == false then
            self:procRequestOtherPlayers(dt)
            socketUpdate()
            self:procNetWaiting(dt)
            self:procHeartBeat(dt)
        end
        self:updateLayers(dt)
        self:updateDialogs(dt)
        cclog(mmo.DebugHelper:getDebugString())  -- c++层调试信息监控
    end
    -- 注册定时器
    self._nScheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update,0,false)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitGameScene()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function GameScene:onExitGameScene()
    print(self._strName.." onExit!")
    -- 注销定时器
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._nScheduleID)
end

-- 更新所有层
function GameScene:updateLayers(dt)
    for k,v in pairs(self._tLayers) do
        v:update(dt)
    end
end

-- 更新所有对话框
function GameScene:updateDialogs(dt)
    for k,v in pairs(self._tDialogs) do
        v:update(dt)
    end
end

-- 显示Layer（创建+显示）
function GameScene:showLayer(pLayer,nZorder)
    print(pLayer._strName.." is added success!")
    table.insert(self._tLayers,pLayer)
    pLayer:showWithAni()
    if nZorder == nil then
        self:addChild(pLayer, kZorder.kLayer)
    else
        self:addChild(pLayer, nZorder)
    end
end

-- 关闭Layer（销毁+移除）
function GameScene:closeLayer(pLayer)
    for k,var in pairs(self._tLayers) do
        if var == pLayer then
            print(var._strName.." is removed success!")
            var:closeWithAni()
            table.remove(self._tLayers,k)
            return
        end
    end
    return
end

-- 关闭Layer（销毁+移除）（不带动画）
function GameScene:closeLayerWithNoAni(pLayer)
    for k,var in pairs(self._tLayers) do
        if var == pLayer then
            print(var._strName.." is removed success!")
            var:closeWithNoAni()
            table.remove(self._tLayers,k)
            return
        end
    end
    return
end

-- 关闭Layer（销毁+移除）
function GameScene:closeLayerByName(sLayerName)
    for k,var in pairs(self._tLayers) do
        if var._strName == sLayerName then
            print(var._strName.." is removed success!")
            var:closeWithAni()
            table.remove(self._tLayers,k)
            return
        end
    end
    return
end

-- 关闭Layer（销毁+移除）（不带动画）
function GameScene:closeLayerByNameWithNoAni(sLayerName)
    for k,var in pairs(self._tLayers) do
        if var._strName == sLayerName then
            print(var._strName.." is removed success!")
            var:closeWithNoAni()
            table.remove(self._tLayers,k)
            return
        end
    end
    return
end

-- 关闭所有Layer（销毁+移除）
function GameScene:closeAllLayers()
    for k,var in pairs(self._tLayers) do
       var:closeWithAni()
    end
    self._tLayers = {}
    print("所有层移除成功！")
    return
end

function GameScene:closeAllLayersWithNoAni()
    for k,var in pairs(self._tLayers) do
        var:doWhenCloseOver()
        var:removeFromParent(true)
    end
    self._tLayers = {}

    --collectMems()
    return
end

-- 获得已有的Layer
function GameScene:getLayerByName(sLayerName)
    for k,var in pairs(self._tLayers) do
        if var._strName == sLayerName then
            return var
        end
    end
    return nil
end

function GameScene:showNetErrorDialog()
    self._pNetErrorDialog:showWithAni()
    --self:addChild(pDialog, kZorder.kSystemMessageLayer)
end

function GameScene:closeNetErrorDialog()
    if self._pNetErrorDialog ~= nil then
    	self._pNetErrorDialog:closeWithAni()
    end
end

-- 显示Dialog（创建+显示）
function GameScene:showDialog(pDialog, nZorder)
    if self._pMaskBg == nil then
        self._pMaskBg = require("MaskBgLayer"):create()
        self:showLayer(self._pMaskBg, kZorder.kMaskBgLayer)
        -- 强制设置所有角色positionZ到最小值
        RolesManager:getInstance():setForceMinPositionZ(true, -10000)
        PetsManager:getInstance():setForceMinPositionZ(true, -10000)
    else
        self._pMaskBg:setVisible(true)
        self._pMaskBg:setTouchable(true)
    end

    print(pDialog._strName.." is added success!")
    table.insert(self._tDialogs,pDialog)
    pDialog:showWithAni()
    self:popUpDialog(pDialog)
    if nZorder == nil then
        self:addChild(pDialog)
    else
        self:addChild(pDialog, nZorder)
    end
    return
end

-- 显示已经缓存的dialog
function GameScene:showCacheDialog(pDialog, nZorder)
     if self._pMaskBg == nil then
         self._pMaskBg = require("MaskBgLayer"):create()
         self:showLayer(self._pMaskBg, kZorder.kMaskBgLayer)
        -- 强制设置所有角色positionZ到最小值
        RolesManager:getInstance():setForceMinPositionZ(true, -10000)
        PetsManager:getInstance():setForceMinPositionZ(true, -10000)
    else
        self._pMaskBg:setVisible(true)
        self._pMaskBg:setTouchable(true)
    end
    self:popUpDialog(pDialog)
    pDialog:showCacheWithAni() 
    return
end

-- 显示缓存dialog 默认设置zorder 最大
function GameScene:popUpDialog(pDialog)
    for index,value in ipairs(self._tDialogs) do
        if value._strName == pDialog._strName then
            local tempDialog = value
            table.remove(self._tDialogs,index)
            table.insert(self._tDialogs,tempDialog)
        end
        if value._strName == "AlertDialog" then
            self._tDialogs[index]:setLocalZOrder(kZorder.kSystemMessageLayer)
        else
            self._tDialogs[index]:setLocalZOrder(kZorder.kDialog + index)
        end
    end 
end

function GameScene:checkMaskBg()
    local isAllClosed = true
    for i=1,table.getn(self._tDialogs) do
        local vis = self._tDialogs[i]:isVisible()
        if vis == true then
            isAllClosed = false
        end
    end

    if isAllClosed == true then
        if self._pMaskBg ~= nil then
            self._pMaskBg:setVisible(false)
            self._pMaskBg:setTouchable(false)
            -- 恢复所有角色positionZ的强制性
            RolesManager:getInstance():setForceMinPositionZ(false)
            PetsManager:getInstance():setForceMinPositionZ(false)
        end
    end
end

function GameScene:hiddenDialog(pDialog)
    pDialog:hiddenWithAni()

    self:checkMaskBg()
end

-- 关闭Dialog（销毁+移除）
function GameScene:closeDialog(pDialog)
    for k,var in pairs(self._tDialogs) do
        if var == pDialog then
            print(var._strName.." is removed success!")
            var:closeWithAni()
            table.remove(self._tDialogs,k)
        end
    end

    self:checkMaskBg()
    
    --collectMems()
    return
end

-- 关闭Dialog（销毁+移除）
function GameScene:closeDialogByName(sDialogName)
    for k,var in pairs(self._tDialogs) do
        if var._strName == sDialogName then
            print(var._strName.." is removed success!")
            var:closeWithAni()
            table.remove(self._tDialogs,k)
            self._nDialogsShowRef = self._nDialogsShowRef - 1
        end
    end

    self:checkMaskBg()
    
    --collectMems()
    return
end

-- 关闭Dialog（销毁+移除）（不带动画）
function GameScene:closeDialogByNameWithNoAni(sDialogName)
    for k,var in pairs(self._tDialogs) do
        if var._strName == sDialogName then
            print(var._strName.." is removed success!")
            var:closeWithNoAni()
            table.remove(self._tDialogs,k)
            self._nDialogsShowRef = self._nDialogsShowRef - 1
        end
    end

    local isAllClosed = true
    for i=1,table.getn(self._tDialogs) do
        local vis = self._tDialogs[i]:isVisible()
        if vis == true then
            isAllClosed = false
        end
    end

    if isAllClosed == true then
        if self._pMaskBg ~= nil then
            self._pMaskBg:setVisible(false)
            self._pMaskBg:setTouchable(false)
        end
    end

    --collectMems()
    return
end

-- 关闭所有Dialog（销毁+移除）
function GameScene:closeAllDialogs()
    local tSystemDialogs = {}
    for k,var in pairs(self._tDialogs) do
        if var._bIsSystemDialog == false then
            var:closeWithAni()
        else
            table.insert(tSystemDialogs,var)
        end
    end
    self._tDialogs = {};
    print("所有对话框移除成功！")
    self._tDialogs = tSystemDialogs

    if table.getn(self._tDialogs) == 0 then
        if self._pMaskBg ~= nil then
            self:closeLayer(self._pMaskBg)
            self._pMaskBg = nil
            -- 恢复所有角色positionZ的强制性
            RolesManager:getInstance():setForceMinPositionZ(false)
            PetsManager:getInstance():setForceMinPositionZ(false)
        end
    end
    --collectMems()
    return
end

-- 关闭所有Dialog（销毁+移除）（不带动画）
function GameScene:closeAllDialogsWithNoAni()
    local tSystemDialogs = {}
    for k,var in pairs(self._tDialogs) do
        if var._bIsSystemDialog == false then
            var:doWhenCloseOver()
            var:removeFromParent(true)
        else
            table.insert(tSystemDialogs,var)
        end
    end
    self._tDialogs = {}
    print("所有对话框移除成功！")
    self._tDialogs = tSystemDialogs
    
    if table.getn(self._tDialogs) == 0 then
        if self._pMaskBg ~= nil then
            self:closeLayer(self._pMaskBg)
            self._pMaskBg = nil
        end
    end
    --collectMems()
    return
end

-- 获得已有的Dialog
function GameScene:getDialogByName(sDialogName)
    for k,var in pairs(self._tDialogs) do
        if var._strName == sDialogName then
            return var
        end
    end
    return nil
end

-- 网络等待表现监控
function GameScene:procNetWaiting(dt)
    if self._bNetWaiting then
        if self._bNetTimeoutBegin == false then
            self._bNetTimeoutBegin = true
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(10.0),
                cc.CallFunc:create(function() 
                    --disconnect()
                    --cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = true
                    --LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER) 
                    --NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetReconnected, {reconnected = false})
                    --self._bNetWaiting = false
                end)
            ))
        end
    
        if self._pNetWaitingLayer:isVisible() == false then
            self._pNetWaitingLayer._pTouchListener:setEnabled(true)
            self._pNetWaitingLayer:setVisible(true)
            self._pNetWaitingLayer:showWithAni()
        end
    else
        if self._bNetTimeoutBegin == true then
            self._bNetTimeoutBegin = false
            self:stopAllActions()
        end
    
        if self._pNetWaitingLayer:isVisible() == true then
            self._pNetWaitingLayer._pTouchListener:setEnabled(false)
            self._pNetWaitingLayer:setVisible(false)
            self._pNetWaitingLayer:closeWithAni()
        end
    end
end

-- 网络心跳
function GameScene:procHeartBeat( dt )
    -- 如果屏蔽心跳，则直接返回（方便战斗系统开发与服务器脱离）
    if self._bSkipHeartBeat == true then
        return
    end
    self._nHeartBeatCount = self._nHeartBeatCount + 1
    if self._nHeartBeatCount == 3600 then
        self._nHeartBeatCount = 0
        HeartBeatMessage:sendMessageHeartBeat21300()
    end
end

-- 请求在线玩家数据
function GameScene:procRequestOtherPlayers(dt)
    if self._kCurSessionKind ~= kSession.kLogin and self._kCurSessionKind ~= kSession.kSelect then
        self._fOtherPlayersReqCounter = self._fOtherPlayersReqCounter + dt
        if self._fOtherPlayersReqCounter >= 60*5 then  -- 五分钟
            self._fOtherPlayersReqCounter = 0
            -- 请求在线玩家
            local args = nil
            if OptionManager:getInstance()._nPlayersRoleShowLevel == 3 then
                args = {count=TableConstants.SameScreenMin.Value}
            elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 2 then
                args = {count=TableConstants.SameScreenMid.Value}
            elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 1 then
                args = {count=TableConstants.SameScreenMax.Value}
            end
            OtherPlayersCGMessage:sendMessageOtherPlayers(args)
        end
    end
end

-- 断线重练
function GameScene:reconnectHandle(info)
    self._nSocketReconnectNum = self._nSocketReconnectNum + 1
    self._pNetReconnectLayer:setVisible(true)
    self._pNetReconnectLayer._pTouchListener:setEnabled(true)
    
    if LoginManager:getInstance()._tCurSessionId == nil then
    	disconnect()
        self._pNetReconnectLayer._pTouchListener:setEnabled(false)
        self._pNetReconnectLayer:setVisible(false)
    	return
    end
    
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function() 
            cclog("第"..self._nSocketReconnectNum.. "次重连")
            connectTo(info.ipAddr,info.port)
            if isConnect() == true then
                cclog("服务器重新连接成功！")
                if LoginManager:getInstance()._tCurSessionId ~= nil and LoginManager:getInstance()._nRoleId ~= 0 then
                    LoginCGMessage:sendMessageReconnect(LoginManager:getInstance()._nRoleId)
                elseif LoginManager:getInstance()._tCurSessionId ~= nil and LoginManager:getInstance()._nRoleId == 0 then
                    LoginCGMessage:sendMessageReconnectWithSessionId(LoginManager:getInstance()._tCurSessionId)
                end
                cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = false
                cc.Director:getInstance():getRunningScene()._bNetWaiting = false
                self._pNetReconnectLayer._pTouchListener:setEnabled(false)
                self._pNetReconnectLayer:setVisible(false)
            else
                if self._nSocketReconnectNum < 10 then
                   self:reconnectHandle(info)
                else
                    cc.Director:getInstance():getRunningScene():showNetErrorDialog()
                    cc.Director:getInstance():getRunningScene()._bNetWaiting = false
                    self._nSocketReconnectNum = 0
                    self._pNetReconnectLayer._pTouchListener:setEnabled(false)
                    self._pNetReconnectLayer:setVisible(false)
                end
            end
        end)
    ))
end

return GameScene
