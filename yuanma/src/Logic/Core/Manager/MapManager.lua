--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MapManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   世界地图管理器
--===================================================
MapManager = {}

local instance = nil

-- 单例
function MapManager:getInstance()
    if not instance then
        instance = MapManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function MapManager:clearCache()
    self._pTmxMap = nil                                         -- 地图对象
    self._pSplashSky = nil                                      -- 地图的闪屏
    self._pGoDirectionAni = nil                                 -- 人物行走箭头提示标（仅适用于战斗系统，用来提示野怪区域的中心点）
    self._nNextMonsterAreaCenterPos = cc.p(0,0)                 -- 当前关卡下一个Monster区域的中心点坐标,用于人物行走箭头提示标的指定
    self._pDebugLayer = nil                                     -- 调试层对象
    self._sMapIndexSize = nil                                   -- 地图索引尺寸（n*n）(cc.size)
    self._sMapRectPixelSize = nil                               -- 地图像素尺寸(cc.size)
    self._sTiledPixelSize = nil                                 -- tiled单位尺寸(cc.size)
    self._ttTiledAttris = {}                                    -- 地图属性集合（二维数组）
    self._tMapArea = {}                                         -- 地图分块矩形区域(cc.rect)
    self._pMapCamera = nil                                      -- tmx地图相机（跟随地图移动，用于避免3D半透后无法遮挡的引擎bug）
    self._strNextMapName = ""                                   -- 传送到的下一地图的文件名称
    self._strNextMapPvrName = ""                                -- 传送到的下一地图的pvr名称
    self._nNextMapDoorIDofEntity = 0                            -- 传送到的下一地图的传送门ID（在Entitys中的ID）
    self._f3DZ = 0                                              -- 用于3D模型的positionZ，区别3D的遮挡关系
    self._bShake = false                                        -- 是否发生震屏
    self._posShakeCameraOnScreen = cc.p(0,0)                    -- 当前时刻屏幕上的相机位置（配合震屏等镜头拉近拉远效果）
    self._bIsCameraMoving = false                               -- 相机是否正在移动（非跟随性的移动，即镜头的移动缩放等等）
    self._bBossDeadFilming = false                              -- 是否正处于boss死亡的特写中
    self._kCurSkyType = kType.kSky.kDaySunShine                 -- 天气类型
    self._tOthersPlots = {}                                     -- 其他角色寻路点集合
    if self._nRainUpdateID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._nRainUpdateID)
    end
    self._tThiefPlots = {}                                      -- 盗宝贼角色寻路点集合
    self._nRainUpdateID = nil                                   -- 雨天更新回调id

    self._pKartunActionNode = nil                               -- 【动作依托的节点】卡顿的动作节点
    
end

-- 循环处理
function MapManager:update(dt)
    
    -- 相机跟随
    self:refreshCameraPosition()
    
    -- 人物行进提示跟随与角度计算
    self:procGoDirectionAni()
    
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

-- 初始化相机
function MapManager:initMapCameraData(pos) 
    -- 初始化地图相机
    if self._pMapCamera == nil then
        self._pMapCamera = cc.Camera:create()
        self._pMapCamera:setContentSize(cc.size(mmo.VisibleRect:width(), mmo.VisibleRect:height()))
        self._pMapCamera:setCameraFlag(cc.CameraFlag.USER1)
        --self._pMapCamera:setScale(1.5)
        self._pTmxMap:addChild(self._pMapCamera)
        self._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
               
    end
end

-- 初始化相机scale
function MapManager:initMapCameraWithScale()
    -- 初始化地图相机
    if self._pMapCamera then
        -- 相机由进拉远，给主角场景一个缓冲
        local cameraOver = function()
            -- 相机复原，回到正常比例
            self:moveMapCameraByPos(4, 0, cc.p(-1,-1), 1.5, 1.0, cc.p(-1,-1), true)
            -- 恢复设置所有角色positionZ到最小值
            MonstersManager:getInstance():setForceMinPositionZ(false)
            RolesManager:getInstance():setForceMinPositionZ(false)
            PetsManager:getInstance():setForceMinPositionZ(false)
            SkillsManager:getInstance():setForceMinPositionZ(false) 
            
        end
        self:moveMapCameraByPos(4, 0, cc.p(-1,-1), 0, 0.5, cc.p(-1,-1), true, cameraOver)
        -- 强制设置所有角色positionZ到最小值
        MonstersManager:getInstance():setForceMinPositionZ(true, -10000)
        RolesManager:getInstance():setForceMinPositionZ(true, -10000)
        PetsManager:getInstance():setForceMinPositionZ(true,-10000)
        SkillsManager:getInstance():setForceMinPositionZ(true, -10000)
        
    end
    
end

-- 退场相机scale
function MapManager:endMapCameraWithScale()
    -- 初始化地图相机
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld or 
        cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        if self._pMapCamera then
            -- 相机由远拉近，给主角场景一个缓冲
            self:moveMapCameraByPos(4, 0, cc.p(-1,-1), 2.0, 0.5, cc.p(-1,-1), true)
            -- 禁用摇杆
            if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
                cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._bStickDisabled = true
            elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._bStickDisabled = true
            end

            -- 强制设置所有角色positionZ到最小值
            MonstersManager:getInstance():setForceMinPositionZ(false)
            RolesManager:getInstance():setForceMinPositionZ(false)
            PetsManager:getInstance():setForceMinPositionZ(false)
            SkillsManager:getInstance():setForceMinPositionZ(false)

        end
    end
end

-- 相机跟随
function MapManager:refreshCameraPosition()
    if self._pMapCamera ~= nil then
        if self._bShake == false then       -- 非震屏时要实时刷新相机位置
            local pos = self:convertScreenPosToMapPos(mmo.VisibleRect:center())
            self._pMapCamera:setAnchorPoint(cc.p(0.5,0.5))
            self._pMapCamera:setPosition(cc.p(pos.x, pos.y))
        else    -- 正在震屏
            local pos = self:convertScreenPosToMapPos(self._posShakeCameraOnScreen)
            self._pMapCamera:setAnchorPoint(cc.p(self._posShakeCameraOnScreen.x/mmo.VisibleRect:width(), self._posShakeCameraOnScreen.y/mmo.VisibleRect:height()))
            self._pMapCamera:setPosition(cc.p(pos.x, pos.y))
        end

    end
    
end


-- 初始化
function MapManager:initialize(parent)
    
    -- 添加到父节点
    parent:addChild(self._pTmxMap)

    -- 动作依托的节点
    self._pKartunActionNode = cc.Node:create()
    self._pTmxMap:addChild(self._pKartunActionNode)
    
    -- 保留tmx地图对象
    self._pTmxMap:release()
    
    -- 清楚上一次传送触发器的信息
    self:clearNextMapInfo()

    -- 初始化地图相机
    self:initMapCameraData()

end

-- 创建地图(返回：tmx地图层、对象层)
function MapManager:createMap(bDebug, bDebugBlockLayerInfo)
    if self._pTmxMap == nil then
        if self._strNextMapName ~= "" then  -- 说明是传送过来的地图
            self:createMapWithTMX(self._strNextMapName, bDebug, bDebugBlockLayerInfo)
        else  -- 说明是第一次进入家园
            self:createMapWithTMX(tDefaultMapNames, bDebug, bDebugBlockLayerInfo)
        end
        -- 创建地图特效
        self:createMapEffect()
        -- 人物行走箭头提示标（用来提示野怪区域的中心点）
        self:createGoDirectionAni()   
        -- 创建场景云 
        self:createSky()
    end
    -- 创建闪屏
    self._pSplashSky = cc.LayerColor:create(cc.c4b(255,255,255,128))
    self._pSplashSky:setContentSize(self._pTmxMap:getContentSize())
    self._pSplashSky:setOpacity(0)
    self._pTmxMap:addChild(self._pSplashSky,kZorder.kMax)

    -- 保留tmx地图对象
    self._pTmxMap:retain()
    
end

-- 创建地图（根据名字）
function MapManager:createMapWithTMX(tmxFileNames, bDebug, bDebugBlockLayerInfo)
    if self._pTmxMap == nil then
        if type(tmxFileNames) == "table" then  -- 多张地图拼接
            local name = string.sub(tmxFileNames[1],1, string.len(tmxFileNames[1])-1)
            self._pTmxMap = ccexp.TMXTiledMap:create(name..".tmx")
        else    -- 单张地图
            self._pTmxMap = ccexp.TMXTiledMap:create(tmxFileNames..".tmx")
        end
        self._pTmxMap:setAnchorPoint(cc.p(0,0))
        self._pTmxMap:setPosition(cc.p(0,0))
        self._sMapIndexSize = self._pTmxMap:getMapSize()
        self._sTiledPixelSize = self._pTmxMap:getTileSize()
        self._sMapRectPixelSize = cc.size(self._sMapIndexSize.width*self._sTiledPixelSize.width, self._sMapIndexSize.height*self._sTiledPixelSize.height)
        for index = 1,nMapAreaRowNum*nMapAreaColNum do
            local w = self._sMapRectPixelSize.width/nMapAreaColNum
            local h = self._sMapRectPixelSize.height/nMapAreaRowNum
            local x = ((index-1)%nMapAreaColNum)*w
            local y = math.modf(self._sMapRectPixelSize.height - h - math.modf((index-1)/nMapAreaColNum)*h)
            local rect = cc.rect(x,y,w,h)
            table.insert(self._tMapArea,rect)
        end

        self:initMapAttris()
        
        self._f3DZ = 6000/self._sMapIndexSize.height
        
        if bDebug == true then
            self._pDebugLayer = require("MapDebugLayer"):create()
            self._pTmxMap:addChild(self._pDebugLayer, kZorder.kMapDebugLayer)            
        end
        if bDebugBlockLayerInfo then
            self:setBlockVisible(bDebugBlockLayerInfo)
        else
            self:setBlockVisible(false)
        end
        
    end
end

-- 创建地图特效
function MapManager:createMapEffect()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        local infos = StagesManager:getInstance():getCurStageMapInfo().MapEffect
        if infos ~= "none" and infos ~= "" then
            for k,v in pairs(infos) do 
                if v.type == 1.0 then  -- csb动画
                    self:createAni2D(v.name, v.x, v.y)
                elseif v.type == 2.0 then  -- 粒子特效
                    self:createParticle(v.name, v.x, v.y)
                end 
            end
        end
    end
end

-- 创建人物行走箭头提示标（用来提示野怪区域的中心点）
function MapManager:createGoDirectionAni()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        self._pGoDirectionAni = cc.CSLoader:createNode("GoDirectionTip.csb")
        self._pGoDirectionAni:setLocalZOrder(kZorder.kGoDirection)
        self._pTmxMap:addChild(self._pGoDirectionAni)
        local action = cc.CSLoader:createTimeline("GoDirectionTip.csb")
        action:gotoFrameAndPlay(0, action:getDuration(), true)
        self._pGoDirectionAni:runAction(action)          
    end
end

-- 计算天气
function MapManager:calculateSkyType()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        -- 获取系统时间：根据系统日期来决定今天的天气
        local tDate = os.date("*t",os.time())
        if tDate.hour >= 22 or tDate.hour <= 4 then  -- 深夜
            if tDate.hour % 3 == 0 then -- 晴天
                self._kCurSkyType = kType.kSky.kNightSunShine
            elseif tDate.hour % 3 == 1 then  -- 多云
                self._kCurSkyType = kType.kSky.kNightCloudy
            elseif tDate.hour % 3 == 2 then  -- 下雨 或者 多云下雨
                if tDate.min <= 30 then
                    self._kCurSkyType = kType.kSky.kNightRainy
                else
                    self._kCurSkyType = kType.kSky.kNightCloudyRainy
                end
                
            end
        else                                -- 白天
            if tDate.hour % 3 == 0 then     -- 晴天
                self._kCurSkyType = kType.kSky.kDaySunShine
            elseif tDate.hour % 3 == 1 then -- 多云
                self._kCurSkyType = kType.kSky.kDayCloudy
            elseif tDate.hour % 3 == 2 then -- 下雨 或者 多云下雨
                if tDate.min <= 30 then
                    self._kCurSkyType = kType.kSky.kDayRainy
                else
                    self._kCurSkyType = kType.kSky.kDayCloudyRainy
                end
            end
        end

    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then        -- 战斗场景只有白天
        local copyMapInfo = StagesManager:getCurStageMapInfo()
        if copyMapInfo.HasCloud == 1 then
            self._kCurSkyType = kType.kSky.kDayCloudy
            if copyMapInfo.HasRain == 1 then
                self._kCurSkyType = kType.kSky.kDayCloudyRainy
            end
        else
            if copyMapInfo.HasRain == 1 then
                self._kCurSkyType = kType.kSky.kDayRainy
            else
                self._kCurSkyType = kType.kSky.kDaySunShine
            end
        end

    end
    
    -- 测试：
    --self._kCurSkyType = kType.kSky.kNightCloudyRainy
    
    return
end

-- 创建天空层
function MapManager:createSky()
    -------------------------------------白天----------------------------------------------------------------
    if self._kCurSkyType == kType.kSky.kDaySunShine then  --[白日]晴天
        if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then  -- 光照（只限家园中有）
            local sunshine1 = cc.CSLoader:createNode("SunShine.csb")
            sunshine1:setPosition(cc.p(640,1344))
            self._pTmxMap:addChild(sunshine1,kZorder.kSky)
            local act = cc.CSLoader:createTimeline("SunShine.csb")
            act:gotoFrameAndPlay(0, act:getDuration(), true) 
            sunshine1:runAction(act)

            local sunshine2 = cc.CSLoader:createNode("SunShine.csb")
            sunshine2:setPosition(cc.p(-20,1472))
            self._pTmxMap:addChild(sunshine2,kZorder.kSky)
            local act = cc.CSLoader:createTimeline("SunShine.csb")
            act:gotoFrameAndPlay(0, act:getDuration(), true)
            act:setTimeSpeed(0.8)
            sunshine2:runAction(act)
            
            -- 测试：
            --self._pTmxMap:getLayer("MapLayer1"):getTileAt(cc.p(0,self._sMapIndexSize.height-1)):setColor(cc.c3b(255,81,82))  -- 叠色
            
        end
    elseif self._kCurSkyType == kType.kSky.kDayCloudy then  --[白日]多云
        local row = 2
        local col = 3
        for r=1,row do
            for c=1,col do 
                local cloud = cc.Sprite:createWithSpriteFrameName("CloudTransforRes/loadingCloud.png")
                local x = getRandomNumBetween(self._sMapRectPixelSize.width/col*(c-1),self._sMapRectPixelSize.width/col*(c-1)+self._sMapRectPixelSize.width/col)
                local y = getRandomNumBetween(self._sMapRectPixelSize.height/row*(r-1),self._sMapRectPixelSize.height/row*(r-1)+self._sMapRectPixelSize.height/row)
                cloud:setPosition(cc.p(x, y))
                local time = getRandomNumBetween(200,300)
                local direction = getRandomNumBetween(0,10)
                if direction <= 5 then
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)))))
                else
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)))))
                end
                local opacity = getRandomNumBetween(100,200)
                cloud:setOpacity(opacity)
                self._pTmxMap:addChild(cloud,kZorder.kSky)
            end
        end
    elseif self._kCurSkyType == kType.kSky.kDayRainy then  --[白日]下雨
        local rain = cc.ParticleSystemQuad:create("ParticleRain.plist")
        local rainParent = cc.ParticleBatchNode:createWithTexture(rain:getTexture())
        rainParent:setScaleY(2.5)
        rain:setPositionType(cc.POSITION_TYPE_GROUPED)
        rainParent:addChild(rain)
        rainParent:setPosition(cc.p(self._sMapRectPixelSize.width/2, self._sMapRectPixelSize.height+10))
        self._pTmxMap:addChild(rainParent,kZorder.kSky)
        local function thunderSky(dt)
            self:splashMap(1.0, true)
            AudioManager:getInstance():playEffect("SkyThunderSound")
        end
        self._nRainUpdateID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(thunderSky, 15.0, false)
        AudioManager:getInstance():playEffect("RainSound",true,nil,true)
    elseif self._kCurSkyType == kType.kSky.kDayCloudyRainy then  --[白日]多云下雨
        -- 多云
        local row = 2
        local col = 3
        for r=1,row do
            for c=1,col do 
                local cloud = cc.Sprite:createWithSpriteFrameName("CloudTransforRes/loadingCloud.png")
                local x = getRandomNumBetween(self._sMapRectPixelSize.width/col*(c-1),self._sMapRectPixelSize.width/col*(c-1)+self._sMapRectPixelSize.width/col)
                local y = getRandomNumBetween(self._sMapRectPixelSize.height/row*(r-1),self._sMapRectPixelSize.height/row*(r-1)+self._sMapRectPixelSize.height/row)
                cloud:setPosition(cc.p(x, y))
                local time = getRandomNumBetween(200,300)
                local direction = getRandomNumBetween(0,10)
                if direction <= 5 then
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)))))
                else
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)))))
                end
                local opacity = getRandomNumBetween(100,200)
                cloud:setOpacity(opacity)
                self._pTmxMap:addChild(cloud,kZorder.kSky)
            end
        end
        -- 下雨
        local rain = cc.ParticleSystemQuad:create("ParticleRain.plist")
        local rainParent = cc.ParticleBatchNode:createWithTexture(rain:getTexture())
        rainParent:setScaleY(2.5)
        rain:setPositionType(cc.POSITION_TYPE_GROUPED)
        rainParent:addChild(rain)
        rainParent:setPosition(cc.p(self._sMapRectPixelSize.width/2, self._sMapRectPixelSize.height+10))
        self._pTmxMap:addChild(rainParent,kZorder.kSky)
        local function thunderSky(dt)
            self:splashMap(1.0, true)
            AudioManager:getInstance():playEffect("SkyThunderSound")
        end
        self._nRainUpdateID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(thunderSky, 15.0, false)
        AudioManager:getInstance():playEffect("RainSound",true,nil,true)
    elseif self._kCurSkyType == kType.kSky.kNightSunShine then  --[深夜]晴天
        self._pTmxMap:getLayer("MapLayer1"):getTileAt(cc.p(0,self._sMapIndexSize.height-1)):setColor(cMapNight)  -- 叠色
    elseif self._kCurSkyType == kType.kSky.kNightCloudy then  --[深夜]多云
        self._pTmxMap:getLayer("MapLayer1"):getTileAt(cc.p(0,self._sMapIndexSize.height-1)):setColor(cMapNight)  -- 叠色
        local row = 2
        local col = 3
        for r=1,row do
            for c=1,col do 
                local cloud = cc.Sprite:createWithSpriteFrameName("CloudTransforRes/loadingCloud.png")
                cloud:setColor(cMapNight)
                local x = getRandomNumBetween(self._sMapRectPixelSize.width/col*(c-1),self._sMapRectPixelSize.width/col*(c-1)+self._sMapRectPixelSize.width/col)
                local y = getRandomNumBetween(self._sMapRectPixelSize.height/row*(r-1),self._sMapRectPixelSize.height/row*(r-1)+self._sMapRectPixelSize.height/row)
                cloud:setPosition(cc.p(x, y))
                local time = getRandomNumBetween(200,300)
                local direction = getRandomNumBetween(0,10)
                if direction <= 5 then
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)))))
                else
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)))))
                end
                local opacity = getRandomNumBetween(100,200)
                cloud:setOpacity(opacity)
                self._pTmxMap:addChild(cloud,kZorder.kSky)
            end
        end
    elseif self._kCurSkyType == kType.kSky.kNightRainy then  --[深夜]下雨
        self._pTmxMap:getLayer("MapLayer1"):getTileAt(cc.p(0,self._sMapIndexSize.height-1)):setColor(cMapNight)  -- 叠色
        local rain = cc.ParticleSystemQuad:create("ParticleRain.plist")
        local rainParent = cc.ParticleBatchNode:createWithTexture(rain:getTexture())
        rainParent:setScaleY(2.5)
        rain:setPositionType(cc.POSITION_TYPE_GROUPED)
        -- 叠色
        rain:setStartColor(cc.c4f(cMapNight.r/255,cMapNight.g/255,cMapNight.b/255,1.0))
        rain:setEndColor(cc.c4f(cMapNight.r/255,cMapNight.g/255,cMapNight.b/255,1.0))
        rainParent:addChild(rain)
        rainParent:setPosition(cc.p(self._sMapRectPixelSize.width/2, self._sMapRectPixelSize.height+10))
        self._pTmxMap:addChild(rainParent,kZorder.kSky)
        local function thunderSky(dt)
            self:splashMap(1.0, true)
            AudioManager:getInstance():playEffect("SkyThunderSound")
        end
        self._nRainUpdateID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(thunderSky, 15.0, false)
        AudioManager:getInstance():playEffect("RainSound",true,nil,true)
    elseif self._kCurSkyType == kType.kSky.kNightCloudyRainy then  --[深夜]多云下雨
        self._pTmxMap:getLayer("MapLayer1"):getTileAt(cc.p(0,self._sMapIndexSize.height-1)):setColor(cMapNight)  -- 叠色
        -- 多云
        local row = 2
        local col = 3
        for r=1,row do
            for c=1,col do 
                local cloud = cc.Sprite:createWithSpriteFrameName("CloudTransforRes/loadingCloud.png")
                cloud:setColor(cMapNight)
                local x = getRandomNumBetween(self._sMapRectPixelSize.width/col*(c-1),self._sMapRectPixelSize.width/col*(c-1)+self._sMapRectPixelSize.width/col)
                local y = getRandomNumBetween(self._sMapRectPixelSize.height/row*(r-1),self._sMapRectPixelSize.height/row*(r-1)+self._sMapRectPixelSize.height/row)
                cloud:setPosition(cc.p(x, y))
                local time = getRandomNumBetween(200,300)
                local direction = getRandomNumBetween(0,10)
                if direction <= 5 then
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)))))
                else
                    cloud:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(time,cc.p(self._sMapRectPixelSize.width,0)), cc.MoveBy:create(time,cc.p(-self._sMapRectPixelSize.width,0)))))
                end
                local opacity = getRandomNumBetween(100,200)
                cloud:setOpacity(opacity)
                self._pTmxMap:addChild(cloud,kZorder.kSky)
            end
        end
        -- 下雨
        local rain = cc.ParticleSystemQuad:create("ParticleRain.plist")
        local rainParent = cc.ParticleBatchNode:createWithTexture(rain:getTexture())
        rainParent:setScaleY(2.5)
        rain:setPositionType(cc.POSITION_TYPE_GROUPED)
        -- 叠色
        rain:setStartColor(cc.c4f(cMapNight.r/255,cMapNight.g/255,cMapNight.b/255,1.0))
        rain:setEndColor(cc.c4f(cMapNight.r/255,cMapNight.g/255,cMapNight.b/255,1.0))
        rainParent:addChild(rain)
        rainParent:setPosition(cc.p(self._sMapRectPixelSize.width/2, self._sMapRectPixelSize.height+10))
        self._pTmxMap:addChild(rainParent,kZorder.kSky)
        local function thunderSky(dt)
            self:splashMap(1.0, true)
            AudioManager:getInstance():playEffect("SkyThunderSound")
        end
        self._nRainUpdateID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(thunderSky, 15.0, false)
        AudioManager:getInstance():playEffect("RainSound",true,nil,true)
    end

end

-- 创建地图粒子特效动画
function MapManager:createParticle(fileName,posX,posY)
    local paricle = cc.ParticleSystemQuad:create(fileName..".plist")
    local parent = cc.ParticleBatchNode:createWithTexture(paricle:getTexture())
    paricle:setPositionType(cc.POSITION_TYPE_GROUPED)
    
    -- 叠色
    if self._kCurSkyType == kType.kSky.kNightSunShine or self._kCurSkyType == kType.kSky.kNightCloudy or self._kCurSkyType == kType.kSky.kNightRainy or self._kCurSkyType == kType.kSky.kNightCloudyRainy then
        paricle:setStartColor(cc.c4f(cMapNight.r/255,cMapNight.g/255,cMapNight.b/255,1.0))
        paricle:setEndColor(cc.c4f(cMapNight.r/255,cMapNight.g/255,cMapNight.b/255,1.0))
    end
    
    parent:addChild(paricle)
    parent:setPosition(posX,posY)
    self._pTmxMap:addChild(parent)
    parent:setLocalZOrder(kZorder.kMinMapAni + self._sMapRectPixelSize.height - parent:getPositionY())
end

-- 创建地图序列帧动画
function MapManager:createAni2D(fileName,posX,posY)
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(fileName)
    local ani = cc.CSLoader:createNode(fileName..".csb")
    
    -- 叠色
    if self._kCurSkyType == kType.kSky.kNightSunShine or self._kCurSkyType == kType.kSky.kNightCloudy or self._kCurSkyType == kType.kSky.kNightRainy or self._kCurSkyType == kType.kSky.kNightCloudyRainy then
        ani:setColor(cMapNight)
    end
    
    self._pTmxMap:addChild(ani)
    ani:setPosition(posX,posY)
    ani:setLocalZOrder(kZorder.kMinMapAni + self._sMapRectPixelSize.height - ani:getPositionY())

    local action = cc.CSLoader:createTimeline(fileName..".csb")
    action:gotoFrameAndPlay(0, action:getDuration(), true)
    ani:runAction(action)
end

-- 获取任一矩形所在矩形分块的区域索引值
function MapManager:getMapAreaIndexByPos(pos)
    local perWidth = self._sMapRectPixelSize.width/nMapAreaColNum
    local perHeight = self._sMapRectPixelSize.height/nMapAreaRowNum
    local row = nMapAreaRowNum - math.modf(pos.y / perHeight)
    local col = math.modf(pos.x / perWidth) + 1
    local index = 0
    if row >= 1 then
        index = ((row - 1)*nMapAreaColNum + col)
    else
        index = col
    end
    return index
end

-- 将OpenGL的坐标值转化为Tile中的行列值（以左上角为0,0点）
function MapManager:convertPiexlToIndex(pos)
    local x = math.modf(pos.x / self._sTiledPixelSize.width)
    local y = math.modf(self._sMapIndexSize.height - pos.y / self._sTiledPixelSize.height)
    return cc.p(x,y)
end

-- 将Tile中的行列值转化为OpenGL的坐标值（以Tile的中心点为准）
function MapManager:convertIndexToPiexl(index)
    local x = index.x*self._sTiledPixelSize.width + self._sTiledPixelSize.width/2
    local y = (self._sMapIndexSize.height - index.y - 1)*self._sTiledPixelSize.height + 1
    return cc.p(x,y)
end

-- 将屏幕坐标转换成地图坐标
function MapManager:convertScreenPosToMapPos(pos)
    local posMapX, posMapY = self._pTmxMap:getPosition()
    local posResult = cc.p( - posMapX + pos.x, - posMapY + pos.y)
    return posResult
end

-- 将地图坐标转换成屏幕坐标
function MapManager:convertMapPosToScreenPos(pos)
    local posMapX, posMapY = self._pTmxMap:getPosition()
    local posResult = cc.p( pos.x + posMapX, pos.y + posMapY )
    return posResult
end

-- 初始化地图的属性
function MapManager:initMapAttris(pos)
    local pMapLayer = self._pTmxMap:getLayer("BlockLayer")
    for row = 1, self._pTmxMap:getMapSize().height do
        -- 新的一行
        local temp = {}
        table.insert(self._ttTiledAttris,temp)
        for col = 1, self._pTmxMap:getMapSize().width do
            local index = cc.p(col-1, row-1)
            local GID = pMapLayer:getTileGIDAt(index)  -- 获取地图中的地图块在图块集中对应的索引值（图块集的索引值从1开始计数，即不为0的为有效数据）
            if GID ~= 0 then -- 不为0的为有效数据
                local properties = self._pTmxMap:getPropertiesForGID(GID) -- 获得地图中当前图块的属性列表
                if properties["Barrier"] == "true" then
                    table.insert(self._ttTiledAttris[row], kType.kTiledAttri.kBarrier)
                else
                    table.insert(self._ttTiledAttris[row], kType.kTiledAttri.kFree)
                end
            else -- 为0说明该处没有铺设任何的图块，则默认表示为 不可行eTiledAttriBarrier
                table.insert(self._ttTiledAttris[row], kType.kTiledAttri.kBarrier)
            end
        end
    end
    mmo.AStarHelper:getInst():InitMapAttris(self._ttTiledAttris)
    
    ---------------家园中其他玩家的初始位置收集----------------------------------------------------------------------------------------------
    local pOtherPlotLayer = self._pTmxMap:getLayer("OtherPlotLayer")
    if pOtherPlotLayer then
        for row = 1, self._pTmxMap:getMapSize().height do
            for col = 1, self._pTmxMap:getMapSize().width do
                local index = cc.p(col-1, row-1)
                local GID = pOtherPlotLayer:getTileGIDAt(index)  -- 获取地图中的地图块在图块集中对应的索引值（图块集的索引值从1开始计数，即不为0的为有效数据）
                if GID ~= 0 then -- 不为0的为有效数据
                    table.insert(self._tOthersPlots,index)
                end
            end
        end
        pOtherPlotLayer:setVisible(false)
    end
    ---------------金钱副本中盗宝贼寻路位置收集----------------------------------------------------------------------------------------------
    local pThiefPlotLayer = self._pTmxMap:getLayer("ThiefPlotLayer")
    if pThiefPlotLayer then
        for row = 1, self._pTmxMap:getMapSize().height do
            for col = 1, self._pTmxMap:getMapSize().width do
                local index = cc.p(col-1, row-1)
                local GID = pThiefPlotLayer:getTileGIDAt(index)  -- 获取地图中的地图块在图块集中对应的索引值（图块集的索引值从1开始计数，即不为0的为有效数据）
                if GID ~= 0 then -- 不为0的为有效数据
                    table.insert(self._tThiefPlots,index)
                end
            end
        end
        pThiefPlotLayer:setVisible(false)
    end

    return true
end

-- 设置BlockLayer界面是否显示
function MapManager:setBlockVisible(enable)
    -- 显示/隐藏BlockLayer属性图块层
    self._pTmxMap:getLayer("BlockLayer"):setVisible(enable)
end

-- 获取单个Tiled地图块属性值
function MapManager:getTiledAttriAt(index)
    local nRow = index.y+1
    local nCol = index.x+1
    if (nRow <=0 ) or (nCol <= 0) or (nRow > self._sMapIndexSize.height) or (nCol > self._sMapIndexSize.width) then
        return kType.kTiledAttri.kNone
    end
    return self._ttTiledAttris[nRow][nCol]
end

-- 计算当前屏幕中心与目标地点之间的位移差
function MapManager:calculateUnFollowMoveDistance(pos)
    local fMapX = self._pTmxMap:getPositionX()
    local fMapY = self._pTmxMap:getPositionY()
    local fObjX = pos.x
    local fObjY = pos.y

    local sMapSize = self._sMapRectPixelSize
    local sVisibleSize = cc.size(mmo.VisibleRect:width(), mmo.VisibleRect:height())

    if fObjX > sMapSize.width - sVisibleSize.width/2 then
        fObjX = sMapSize.width - sVisibleSize.width/2
    elseif fObjX < sVisibleSize.width/2 then
        fObjX = sVisibleSize.width/2
    end
    fMapX = (sVisibleSize.width/2 - fMapX) - fObjX

    if fObjY > sMapSize.height - sVisibleSize.height/2 then
        fObjY = sMapSize.height - sVisibleSize.height/2
    elseif fObjY < sVisibleSize.height/2 then
        fObjY = sVisibleSize.height/2
    end
    fMapY = (sVisibleSize.height/2 - fMapY) - fObjY
    return cc.p(fMapX, fMapY)
end

-- 计算当前屏幕中心跟随目标情况下的坐标
function MapManager:calculateUnFollowMovePos(pos)
    local fMapX = self._pTmxMap:getPositionX()
    local fMapY = self._pTmxMap:getPositionY()
    local fObjX = pos.x
    local fObjY = pos.y

    local sMapSize = self._sMapRectPixelSize
    local sVisibleSize = cc.size(mmo.VisibleRect:width(), mmo.VisibleRect:height())

    if fObjX > sMapSize.width - sVisibleSize.width/2 then
        fObjX = sMapSize.width - sVisibleSize.width/2
    elseif fObjX < sVisibleSize.width/2 then
        fObjX = sVisibleSize.width/2
    end
    fMapX = -(fObjX - sVisibleSize.width/2)

    if fObjY > sMapSize.height - sVisibleSize.height/2 then
        fObjY = sMapSize.height - sVisibleSize.height/2
    elseif fObjY < sVisibleSize.height/2 then
        fObjY = sVisibleSize.height/2
    end
    fMapY = -(fObjY - sVisibleSize.height/2)
    
    return cc.p(fMapX, fMapY)
end

-- 设置地图是否为自动跟随主角
function MapManager:setMapFollowMainRole(bFollow)
    self._pTmxMap:stopActionByTag(nMapFollowTag)
    if bFollow == true then
        local pFollowAction = cc.Follow:create(RolesManager:getInstance()._pMainPlayerRole, cc.rect(0,0,self._sMapRectPixelSize.width, self._sMapRectPixelSize.height))
        pFollowAction:setTag(nMapFollowTag)
        self._pTmxMap:runAction(pFollowAction)
    end
end

-- 地图镜头移动到指定位置
-- 参数order：播放顺序：1.先移动再缩放   2.先缩放再移动    3.只移动    4.只缩放
-- 参数durationMove：移动完成的时间
-- 参数targetPos：要移动到的目标位置，如果值为(-1,-1)，则认为是当前玩家角色的位置
-- 参数durationScale：缩放完成的时间
-- 参数scale：缩放的比例
-- 参数posScaleCenter：（可选，不用时传nil）在镜头先scale的时候，此项有效，先scale时的中心点
-- 参数bResumeFollowAfterAction：动作结束后，是否恢复镜头的自动跟随功能
-- 参数callfunc：动作结束时的回调函数
function MapManager:moveMapCameraByPos(order, durationMove, targetPos, durationScale, scale, posScaleCenter, bResumeFollowAfterAction, callfunc)
    if order == 1 then -- 先移动再缩放
        self._bIsCameraMoving = true
        -- 停止地图跟随动作
        self:setMapFollowMainRole(false)
        -- 计算位移差
        if targetPos.x == -1 and targetPos.y == -1 then  -- 说明是要移动到当前玩家的位置
            local posX, posY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
            targetPos = cc.p(posX, posY)
        end
        -- 计算当前屏幕中心与目标地点之间的位移差
        local distance = self:calculateUnFollowMoveDistance(targetPos)
        -- 执行结束后的回调
        local actionOverCallBack = function()
            local scaleOver = function()
                if scale == 1.0 then
                    self._bShake = false
                    self._posShakeCameraOnScreen = cc.p(0,0)
                end
                
                if bResumeFollowAfterAction == true then
                    self:setMapFollowMainRole(true)
                    self._bIsCameraMoving = false
                end

                if callfunc then
                    callfunc()
                end
            end

            local act = cc.Sequence:create(cc.EaseExponentialOut:create(cc.ScaleTo:create(durationScale, scale)),cc.CallFunc:create(scaleOver))
            -- 相机动作
            self._bShake = true
            self._posShakeCameraOnScreen = self:convertMapPosToScreenPos(targetPos)
            self._pMapCamera:stopAllActions()
            self._pMapCamera:runAction(act)
        end
        -- 移动
        local act = cc.Sequence:create(cc.EaseExponentialOut:create(cc.MoveBy:create(durationMove, cc.p(distance.x, distance.y))), cc.CallFunc:create(actionOverCallBack))
        self._pTmxMap:runAction(act)
        local act = cc.DelayTime:create(durationScale+durationMove+0.1)
        act:setTag(nTriggerItemTag) -- 暂时这样写
        self._pTmxMap:runAction(act)

    elseif order == 2 then  -- 先缩放再移动
        self._bIsCameraMoving = true
        if posScaleCenter.x == -1 and posScaleCenter.y == -1 then  -- 说明当前玩家
            local posX, posY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
            posScaleCenter = cc.p(posX, posY)
        end
        
        -- 执行结束后的回调
        local actionOverCallBack = function()            
            local moveOver = function()
                if scale == 1.0 then
                    self._bShake = false
                    self._posShakeCameraOnScreen = cc.p(0,0)
                end
                
                if bResumeFollowAfterAction == true then
                    self:setMapFollowMainRole(true)
                    self._bIsCameraMoving = false
                end
                
                if callfunc then
                    callfunc()
                end
            end
            -- 停止地图跟随动作
            self:setMapFollowMainRole(false)
            -- 计算位移差
            if targetPos.x == -1 and targetPos.y == -1 then  -- 说明是要移动到当前玩家的位置
                local posX, posY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
                targetPos = cc.p(posX, posY)
            end
            -- 计算当前屏幕中心与目标地点之间的位移差
            local distance = self:calculateUnFollowMoveDistance(targetPos)
            
            -- 移动
            local act = cc.Sequence:create(cc.EaseExponentialOut:create(cc.MoveBy:create(durationMove, cc.p(distance.x, distance.y))), cc.CallFunc:create(moveOver))
            self._pTmxMap:runAction(act)
            
        end
        -- 缩放
        local act = cc.Sequence:create(cc.EaseExponentialOut:create(cc.ScaleTo:create(durationScale, scale)),cc.CallFunc:create(actionOverCallBack))
        self._bShake = true
        self._posShakeCameraOnScreen = self:convertMapPosToScreenPos(posScaleCenter)
        self._pMapCamera:stopAllActions()
        self._pMapCamera:runAction(act)
        local act = cc.DelayTime:create(durationScale+durationMove+0.1)
        act:setTag(nTriggerItemTag) -- 暂时这样写
        self._pTmxMap:runAction(act)

    elseif order == 3 then  -- 只移动
        self._bIsCameraMoving = true
        -- 停止地图跟随动作
        self:setMapFollowMainRole(false)
        -- 计算位移差
        if targetPos.x == -1 and targetPos.y == -1 then  -- 说明是要移动到当前玩家的位置
            local posX, posY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
            targetPos = cc.p(posX, posY)
        end
        -- 计算当前屏幕中心与目标地点之间的位移差
        local distance = self:calculateUnFollowMoveDistance(targetPos)
        -- 执行结束后的回调
        local actionOverCallBack = function()
        
            if bResumeFollowAfterAction == true then
                self:setMapFollowMainRole(true)
                self._bIsCameraMoving = false
            end
            
            if callfunc then
                callfunc()
            end
        end
        -- 移动
        local act = cc.Sequence:create(cc.EaseExponentialOut:create(cc.MoveBy:create(durationMove, cc.p(distance.x, distance.y))), cc.CallFunc:create(actionOverCallBack))
        self._pTmxMap:runAction(act)
        local act = cc.DelayTime:create(durationMove+0.1)
        act:setTag(nTriggerItemTag) -- 暂时这样写
        self._pTmxMap:runAction(act)
    elseif order == 4 then  -- 只缩放
        self._bIsCameraMoving = true
        if posScaleCenter.x == -1 and posScaleCenter.y == -1 then  -- 说明当前玩家
            local posX, posY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
            posScaleCenter = cc.p(posX, posY)
        end
        
        -- 执行结束后的回调
        local actionOverCallBack = function()       
            if scale == 1.0 then
                self._bShake = false
                self._posShakeCameraOnScreen = cc.p(0,0)
                self._bIsCameraMoving = false
            end   
            if callfunc then
                callfunc()
            end
        end
        -- 缩放
        local act = cc.Sequence:create(cc.EaseExponentialOut:create(cc.ScaleTo:create(durationScale, scale)),cc.CallFunc:create(actionOverCallBack))
        self._bShake = true
        self._posShakeCameraOnScreen = self:convertMapPosToScreenPos(posScaleCenter)
        self._pMapCamera:stopAllActions()
        self._pMapCamera:runAction(act)
        local act = cc.DelayTime:create(durationScale+0.1)
        act:setTag(nTriggerItemTag) -- 暂时这样写
        self._pTmxMap:runAction(act)
    end

end

-- 地图镜头移动到指定地图索引位置
-- 参数order：播放顺序：1.先移动再缩放   2.先缩放再移动    3.只移动    4.只缩放
-- 参数durationMove：移动完成的时间
-- 参数targetPosIndex：要移动到的目标索引位置，如果值为(-1,-1)，则认为是当前玩家角色的位置
-- 参数durationScale：缩放完成的时间
-- 参数scale：缩放的比例
-- 参数posScaleCenter：（可选，不用时传nil）在镜头先scale的时候，此项有效，先scale时的中心点
-- 参数bResumeFollowAfterAction：动作结束后，是否恢复镜头的自动跟随功能
-- 参数callfunc：动作结束时的回调函数
function MapManager:moveMapCameraByPosIndex(order, durationMove, targetPosIndex, durationScale, scale, posScaleCenter, bResumeFollowAfterAction, callfunc)
    local targetPos = self:convertIndexToPiexl(cc.p(targetPosIndex.x, targetPosIndex.y))
    self:moveMapCameraByPos(order, durationMove, targetPos, durationScale, scale, posScaleCenter, bResumeFollowAfterAction, callfunc)
end

-- 地图镜头是否正在移动
function MapManager:isCameraMoving()
    return self._bIsCameraMoving
end


-- 清除切换地图的相关传送信息
function MapManager:clearNextMapInfo()
    self._strNextMapName = ""
    self._strNextMapPvrName = ""
    self._nNextMapDoorIDofEntity = 0
end

-- 震屏
function MapManager:shakeMap(params, posOnMap)
    if MonstersManager:getInstance()._bIsBossDead == true then    -- 如果boss死亡，则屏蔽所有震屏
        return
    elseif RolesManager:getInstance()._pPvpPlayerRole then    -- 如果pvp对手死亡，则屏蔽所有震屏
        if RolesManager:getInstance()._pPvpPlayerRole._nCurHp <= 0 then
            return
        end
    elseif MonstersManager:getInstance()._pBoss then    -- 如果boss死亡，则屏蔽所有震屏
        if MonstersManager:getInstance()._pBoss._nCurHp <= 0 then
            return
        end
    end
    
    if params and params[1] ~= 0 then
        self._bShake = true
        local nShakeStrenth = params[1]         -- 震屏强度
        local nShakeDuration = params[2]        -- 每次震屏的时间间隔
        local nShakeTimes = params[3]           -- 震屏次数
        self._posShakeCameraOnScreen = self:convertMapPosToScreenPos(posOnMap)      -- 将地图上的震源坐标转换成屏幕坐标
        
        local shakeOver = function()
            self._bShake = false
            self._posShakeCameraOnScreen = cc.p(0,0)
        end
        self._pMapCamera:setScale(1.0)
        self._pMapCamera:stopActionByTag(nMapShakeActionTag)
        local act = cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(cc.ScaleTo:create(nShakeDuration/2, nShakeStrenth), cc.ScaleTo:create(nShakeDuration/2, 1.0)),nShakeTimes), cc.CallFunc:create(shakeOver))
        act:setTag(nMapShakeActionTag)
        self._pMapCamera:runAction(act)

    end
    
end

-- 闪屏
function MapManager:splashMap(isSplash, isContinuous)    
    if isSplash == 1.0 then
        self._pSplashSky:stopAllActions()
        if isContinuous == true then    -- 连续闪电（一般用于天气）
            local delayProcess1 = getRandomNumBetween(10,30)
            self._pSplashSky:runAction(cc.Sequence:create(cc.DelayTime:create(delayProcess1/100),cc.FadeIn:create(0),cc.FadeOut:create(0.2)))
            local delayProcess2 = getRandomNumBetween(20,40)
            self._pSplashSky:runAction(cc.Sequence:create(cc.DelayTime:create(delayProcess2/100),cc.FadeIn:create(0),cc.FadeOut:create(0.2)))
            local delayProcess3 = getRandomNumBetween(30,50)
            self._pSplashSky:runAction(cc.Sequence:create(cc.DelayTime:create(delayProcess3/100),cc.FadeIn:create(0),cc.FadeOut:create(0.2)))
        else    -- 非连续型（一般用于技能）
            self._pSplashSky:runAction(cc.Sequence:create(cc.FadeIn:create(0),cc.FadeOut:create(0.2)))
        end
    end
end

-- 屏幕卡顿
function MapManager:screenKartun(time)    
    if time ~= 0 then
        -- 开始卡顿
        if self._pKartunActionNode:getNumberOfRunningActions() == 0 then
            local nodes = self._pKartunActionNode:getActionManager():pauseAllRunningActions()
            local kartunOver = function(sender,table)
                -- 恢复卡顿
                self._pKartunActionNode:getActionManager():resumeTargets(table[1])
            end
            self._pKartunActionNode:stopAllActions()
            self._pKartunActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(kartunOver,{nodes})))
        end

    end
end


-- 人物行进提示跟随与角度计算
function MapManager:procGoDirectionAni()
    if self._pGoDirectionAni ~= nil and RolesManager:getInstance()._pMainPlayerRole ~= nil then
        if table.getn(MonstersManager:getInstance()._tCurWaveMonsters) == 0 then
            local stageMapInfo = StagesManager:getInstance():getCurStageMapInfo()
            local centerPosIndex = stageMapInfo["MonsterArea"..(MonstersManager:getInstance()._nCurMonsterAreaIndex + 1).."CenterPosIndex"]
            if centerPosIndex ~= nil then
                self._nNextMonsterAreaCenterPos = self:convertIndexToPiexl(cc.p(centerPosIndex[1], centerPosIndex[2]))
                -- 计算角度
                local posMainRoleX, posMainRoleY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
                self._pGoDirectionAni:setPosition(posMainRoleX, posMainRoleY)
                local angle = mmo.HelpFunc:gAngleAnalyseForRotation(self._nNextMonsterAreaCenterPos.x, self._nNextMonsterAreaCenterPos.y, posMainRoleX, posMainRoleY)
                angle = (math.modf(-angle+90))%360  -- 补一个起始差值
                self._pGoDirectionAni:setRotation(angle)
                self._pGoDirectionAni:setVisible(true)
            end
        else
            self._pGoDirectionAni:setVisible(false)
            self._nNextMonsterAreaCenterPos = cc.p(0,0)
        end
    end
end

function MapManager:isFinalMapInBattle()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        if table.getn(EntitysManager:getInstance()._tDoors[2]) == 0 then    -- 没有结束的传送门，说明已经是最后一张地图
            return true
        end
        return false
    end
    return true
end

