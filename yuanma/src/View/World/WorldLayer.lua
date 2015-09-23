--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   世界层
--===================================================
local WorldLayer = class("WorldLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function WorldLayer:ctor()
    self._strName = "WorldLayer"        -- 层名称
    self._strMapName = ""               -- 当前地图名称
end

-- 创建函数
function WorldLayer:create()
    local layer = WorldLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function WorldLayer:dispose()
    -- 注册事件监听
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryTasksResp, handler(self,self.handleMsgQueryTasksResp))

    -- 开始心跳
    cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = false
    
    -- 地图初始化
    self:getMapManager():initialize(self)
    
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local index = self:getMapManager():convertPiexlToIndex(location)
        
        return true
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWorldLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function WorldLayer:onExitWorldLayer()
    self:onExitLayer()
    
end

-- 循环更新
function WorldLayer:update(dt)    
    self:getMapManager():update(dt)
    self:getRectsManager():update(dt)
    self:getTriggersManager():update(dt)
    self:getRolesManager():update(dt)
    self:getPetsManager():update(dt)
    self:getEntitysManager():update(dt)
    self:getTalksManager():update(dt)
    self:getTasksManager():update(dt)
    self:getPurposeManager():update(dt)
    self:getNoticeManager():update(dt)
    -- 记录主角玩家的角色    
    self:getRolesManager()._posMainRoleLastPosIndexOnWorldMap = self:getRolesManager()._pMainPlayerRole:getPositionIndex()
    
end

-- 显示结束时的回调
function WorldLayer:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function WorldLayer:doWhenCloseOver()
end

function WorldLayer:handleMsgQueryTasksResp(event)
	
end

return WorldLayer
