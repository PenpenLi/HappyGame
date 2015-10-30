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
    self._bIsShowingDoomsday = false    -- 是否正在显示世界末日情景
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
    self:getNoticeManager():update(dt) --跑马灯监听
    self:getMapManager():update(dt) 

    if StoryGuideManager:getInstance()._bIsStory == true or (StoryGuideManager:getInstance()._bIsStory == false and StoryGuideManager:getInstance()._bActionHasStop == false) then --正在进行剧情动画。所有的战斗逻辑暂停
        return
    end

    --------------------------------------
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

    end
end

-- 刷新相机
function BattleLayer:refreshCamera() 
    self:getMapManager()._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
end

-- 显示世界末日
function BattleLayer:showDoomsday()
    -- 开始显示末日特效
    self._bIsShowingDoomsday = true
    -- 创建掉落的碎石粒子特效
    local pStone = cc.ParticleSystemQuad:create("stones.plist")
    local pStoneParent = cc.ParticleBatchNode:createWithTexture(pStone:getTexture())
    pStone:setPositionType(cc.POSITION_TYPE_GROUPED)
    pStoneParent:addChild(pStone)
    pStoneParent:setPosition(cc.p(self:getMapManager()._sMapRectPixelSize.width/2, self:getMapManager()._sMapRectPixelSize.height*1.3))
    self:getMapManager()._pTmxMap:addChild(pStoneParent,kZorder.kMax)
    self:refreshCamera()
    -- 地震
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.05,cc.p(0,-20)),cc.MoveBy:create(0.05,cc.p(0,20)))))
    -- 火海
    local pFireSea = cc.ParticleSystemQuad:create("fireSea.plist")
    local pFireSeaParent = cc.ParticleBatchNode:createWithTexture(pFireSea:getTexture())
    pFireSea:setPositionType(cc.POSITION_TYPE_GROUPED)
    pFireSeaParent:addChild(pFireSea)
    pFireSeaParent:setPosition(cc.p(self:getMapManager()._sMapRectPixelSize.width/2, self:getMapManager()._sMapRectPixelSize.height/2))
    self:getMapManager()._pTmxMap:addChild(pFireSeaParent,kZorder.kMax)
    self:refreshCamera()
    -- 爆点
    local playEffect = function()
        local pFirePost = cc.ParticleSystemQuad:create("firePost.plist")
        local pFirePostParent = cc.ParticleBatchNode:createWithTexture(pFirePost:getTexture())
        pFirePost:setPositionType(cc.POSITION_TYPE_GROUPED)
        pFirePostParent:addChild(pFirePost)
        pFirePostParent:setPosition(cc.p(getRandomNumBetween(1,self:getMapManager()._sMapRectPixelSize.width), getRandomNumBetween(1,self:getMapManager()._sMapRectPixelSize.height)))
        self:getMapManager()._pTmxMap:addChild(pFirePostParent,kZorder.kMax)
        self:refreshCamera()
    end
    for i=1, 10 do
        self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(getRandomNumBetween(50,200)/100),cc.CallFunc:create(playEffect))))
    end
end

return BattleLayer
