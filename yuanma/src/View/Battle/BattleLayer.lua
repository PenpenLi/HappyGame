--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗层
--===================================================
local BattleLayer = class("BattleLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function BattleLayer:ctor()
    self._strName = "BattleLayer"       -- 层名称
    self._strMapName = ""               -- 当前地图名称
end

-- 创建函数
function BattleLayer:create()
    local layer = BattleLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleLayer:dispose()
    -- 错误码
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected ,handler(self, self.handleReconnected))
    -- 地图初始化
    self:getMapManager():initialize(self)  
    
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        return true
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "enter" then
            self:getBattleManager():startTime()  -- 战斗时间开启            
        elseif event == "exit" then
            self:onExitBattleLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function BattleLayer:onExitBattleLayer()
    self:onExitLayer()
        
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function BattleLayer:update(dt)
    if BattleManager:getInstance()._bIsTransforingFromEndBattle == true then
        return
    end
    --------------------------------------
    self:getMapManager():update(dt) 
    self:getRectsManager():update(dt)
    self:getTalksManager():update(dt)
    self:getSkillsManager():update(dt)
    self:getStagesManager():update(dt)
    self:getAIManager():update(dt)
    self:getTriggersManager():update(dt)
    ---------------------------------------
    self:getRolesManager():update(dt)
    self:getBattleManager():update(dt)
    self:getPetsManager():update(dt)
    self:getMonstersManager():update(dt)
    self:getEntitysManager():update(dt)
    ---------------------------------------
    self:getNoticeManager():update(dt)
    
end

-- 显示结束时的回调
function BattleLayer:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BattleLayer:doWhenCloseOver()    
end

function BattleLayer:handleReconnected(event)
    if BattleManager:getInstance()._bMidNight ~= true then
    	BattleManager:getInstance()._kBattleResult = kType.kBattleResult.kBattling
        --BattleManager:
    end
end

return BattleLayer
