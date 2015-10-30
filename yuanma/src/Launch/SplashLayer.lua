--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SplashLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   闪屏层
--===================================================
local SplashLayer = class("SplashLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function SplashLayer:ctor()
    self._strName = "SplashLayer"       -- 层名称
    self._pTouchListener = nil          -- 触摸监听器
    self._pUpdateNode = nil             -- 更新模块
    self._fTimeDelay = 2.0              -- 延时时间
    self._pVideoPlayer = nil            -- 视频对象
    self._nScheduleID = nil             -- 定时器id

end

-- 创建函数
function SplashLayer:create()
    local layer = SplashLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function SplashLayer:dispose()    
    -- mask
    local pMask = cc.LayerColor:create(cc.c4b(0,0,0,255))
    local pLoadingText = cc.Label:createWithTTF("玩命加载中，请稍后......", "res/fonts/simhei.ttf", 40)
    pLoadingText:setTextColor(cc.c4b(255, 255, 255, 255))
    pLoadingText:enableOutline(cc.c4b(87, 63, 60, 255),2)
    pLoadingText:setPosition(cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2))
    pMask:addChild(pLoadingText)
    self:addChild(pMask,9999)

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
        
    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "enter" then
            self:showGiantCfanimSplash()
            ------------------- 循环处理 -----------------------
            local update = function(dt)
                if self._pVideoPlayer then
                    if mmo.HelpFunc:isNeedToRestartVideo() == true then
                        mmo.HelpFunc:setNeedToRestartVideo(false)
                        self._pVideoPlayer:removeFromParent(true)
                        self._pVideoPlayer = nil
                        self:createVideo()
                    end
                end
            end
            -- 注册定时器
            self._nScheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update,0,false)
        elseif event == "exit" then
            self:onExitSplashLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function SplashLayer:onExitSplashLayer()
    -- 注销定时器
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._nScheduleID)
    
end

-- 播放巨人splash动画
function SplashLayer:showGiantCfanimSplash()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- 电脑平台直接检查更新即可
    if ((cc.PLATFORM_OS_IPHONE ~= targetPlatform) and (cc.PLATFORM_OS_IPAD ~= targetPlatform) and (cc.PLATFORM_OS_ANDROID ~= targetPlatform)) then
        -- 检测热更新界面
        self:checkUpdate()
    elseif ((cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform)) then 
        if bSkipSplashMove == false then  -- 移动平台时，如果不需要跳过splash动画，则直接播放
            local startPlayVedio = function()
                self:createVideo()      -- 创建播放视频
            end
            -- 延时1s后开始播放巨人的splash视频
            self:runAction( cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(startPlayVedio)) )
        elseif bSkipSplashMove == true then  -- 移动平台时，如果需要跳过splash动画，则直接检测热更新
            -- 检测热更新界面
            self:checkUpdate()
        end
    end
end

-- 检测热更新界面
function SplashLayer:checkUpdate()
    -- 检测版本更新，如果有更新，切换到更新界面
    local checking = function()
        self._pUpdateNode = require("src/Launch/UpdateLayer"):create()
        self:getParent():addChild(self._pUpdateNode)
        self._pUpdateNode:setVisible(true)
        local needUpdate = self._pUpdateNode:checkUpdate()
        self._pUpdateNode:show(needUpdate)
        --self:removeFromParent(true)
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(checking)))
end

function SplashLayer:createVideo()
    if self._pVideoPlayer == nil then
        self._pVideoPlayer = ccexp.VideoPlayer:create()
        self._pVideoPlayer:setPosition(cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2))
        self._pVideoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
        self._pVideoPlayer:setContentSize(cc.size(mmo.VisibleRect:width(),mmo.VisibleRect:height()))
        self._pVideoPlayer:setFullScreenEnabled(true)
        self:addChild(self._pVideoPlayer)
        self._pVideoPlayer:setFileName("res/mp4/SplashMovie.mp4")
        self._pVideoPlayer:play()
    else
        self._pVideoPlayer:play()
    end
    local function onVideoEventCallback(sener, eventType)
        if eventType == ccexp.VideoPlayerEvent.PLAYING then
            self._pVideoPlayer:setVisible(true)
            mmo.HelpFunc:setIsPlayingVideo(true)
        elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
            self._pVideoPlayer:resume()
        elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
            self._pVideoPlayer:play()
            self._pVideoPlayer:seekTo(0)
        elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            self._pVideoPlayer:removeFromParent(true)
            self._pVideoPlayer = nil
            mmo.HelpFunc:setIsPlayingVideo(false)
            -- 检测热更新界面
            self:checkUpdate()
        end
    end
    self._pVideoPlayer:addEventListener(onVideoEventCallback)
    self._pVideoPlayer:setTouchEnabled(false)
end

return SplashLayer
