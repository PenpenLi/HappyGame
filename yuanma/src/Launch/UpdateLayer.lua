--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  UpdateLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/16
-- descrip:   热更新层
--===================================================
local UpdateLayer = class("UpdateLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function UpdateLayer:ctor()
    self._strName = "UpdateLayer"       -- 层名称
    self._pTouchListener = nil          -- 触摸监听器
    self._pAssetsManager = nil          -- 资源管理器
    self._pCircle = nil                 -- 无限菊花
    self._pCircle2 = nil                 -- 无限菊花2
    self._pCircle3 = nil                 -- 无限菊花3
    self._pProgressBarFrame = nil       -- 进度条框
    self._pProgressBar = nil            -- 进度条对象
    self._pProgressText = nil           -- 进度文字
    self._pProgressNum = nil            -- 进度数
    self._pHyperlinkButton = nil        -- 超链接按钮
    self._bRetryButton = nil            -- 重试按钮（热更新时，网络异常）
    self._strPathToSave = ""            -- 要存放的路径
    self._pMask = nil                   -- 蒙版
    self._platformType = nil            -- 平台类型（ios或者android）

end

-- 创建函数
function UpdateLayer:create()
    local layer = UpdateLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function UpdateLayer:dispose()
    ----------------------初始化--------------------------------    
    cc.Director:getInstance():getTextureCache():addImage("res/pics/check_update.pvr.ccz")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/pics/check_update.plist")    
    
    -- 加载背景
    local pBg = cc.Sprite:createWithSpriteFrameName("downLoadBg.png")
    pBg:setPosition(mmo.VisibleRect:center())
    self:addChild(pBg)
    
    -- 进度条
    self._pProgressBarFrame = cc.Sprite:createWithSpriteFrameName("downBarFrame.png")
    self._pProgressBarFrame:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2)
    self._pProgressBarFrame:setScaleX(-1)
    self:addChild(self._pProgressBarFrame)
    local progressSprite = cc.Sprite:createWithSpriteFrameName("downBar.png")
    self._pProgressBar = cc.ProgressTimer:create(progressSprite)        
    self._pProgressBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pProgressBar:setMidpoint(cc.p(1,0))
    self._pProgressBar:setBarChangeRate(cc.p(1,0))
    self._pProgressBar:setPosition(self._pProgressBarFrame:getBoundingBox().width/2,self._pProgressBarFrame:getBoundingBox().height/2)
    self._pProgressBar:setPercentage(0)
    self._pProgressBarFrame:addChild(self._pProgressBar)

    -- 进度文字提示
    self._pProgressText = cc.Label:createWithTTF("正在检查更新......","res/fonts/simhei.ttf",18)
    self._pProgressText:setAnchorPoint(cc.p(0, 0))
    self._pProgressText:setPosition(cc.p(self._pProgressBarFrame:getPositionX() - self._pProgressBarFrame:getBoundingBox().width/2 + 50, self._pProgressBarFrame:getPositionY() + self._pProgressBarFrame:getBoundingBox().height/2 + 3))
    self:addChild(self._pProgressText)

    -- 进度数字
    self._pProgressNum = cc.Label:createWithTTF("0%","res/fonts/simhei.ttf",18)
    self._pProgressNum:setAnchorPoint(cc.p(1.0, 0))
    self._pProgressNum:setPosition(cc.p(self._pProgressBarFrame:getPositionX() + self._pProgressBarFrame:getBoundingBox().width/2 - 20, self._pProgressBarFrame:getPositionY() + self._pProgressBarFrame:getBoundingBox().height/2 + 3))
    self:addChild(self._pProgressNum)
    
    -- 无限旋转的菊花
    self._pCircle = cc.Sprite:createWithSpriteFrameName("circle.png")
    self._pCircle:setScale(0.13)
    self._pCircle:setPosition(cc.p(self._pProgressText:getPositionX() - self._pCircle:getBoundingBox().width/2 - 5, self._pProgressBarFrame:getPositionY() + self._pProgressBarFrame:getBoundingBox().height/2 + self._pCircle:getBoundingBox().height/2 + 11))
    self._pCircle:stopAllActions()
    self._pCircle:setRotation(0)
    self._pCircle:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.2,35.0)))
    self:addChild(self._pCircle)

    self._pCircle2 = cc.Sprite:createWithSpriteFrameName("circle.png")
    self._pCircle2:setPosition(cc.p(self._pProgressText:getPositionX() - self._pCircle:getBoundingBox().width/2 - 5, self._pProgressBarFrame:getPositionY() + self._pProgressBarFrame:getBoundingBox().height/2 + self._pCircle:getBoundingBox().height/2 + 11))
    self._pCircle2:stopAllActions()
    self._pCircle2:setRotation(90)
    self._pCircle2:setScale(0.3)
    self._pCircle2:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.35,-35.0)))
    self:addChild(self._pCircle2)

    self._pCircle3 = cc.Sprite:createWithSpriteFrameName("circle.png")
    self._pCircle3:setPosition(cc.p(self._pProgressText:getPositionX() - self._pCircle:getBoundingBox().width/2 - 5, self._pProgressBarFrame:getPositionY() + self._pProgressBarFrame:getBoundingBox().height/2 + self._pCircle:getBoundingBox().height/2 + 11))
    self._pCircle3:stopAllActions()
    self._pCircle3:setRotation(180)
    self._pCircle3:setScale(0.3)
    self._pCircle3:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,-35.0)))
    self:addChild(self._pCircle3)
    
    -- 平台获取
    self._platformType = cc.Application:getInstance():getTargetPlatform()
    
    -- mask
    self._pMask = cc.LayerColor:create(cc.c4b(0,0,0,0))
    self:addChild(self._pMask,1)

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
        if nil ~= self._pAssetsManager then
            self._pAssetsManager:release()
            self._pAssetsManager = nil
        end
        if event == "exit" then
            self:onExitUpdateLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function UpdateLayer:onExitUpdateLayer()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("res/pics/check_update.pvr.ccz")
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/pics/check_update.plist")
    
    return
end

function UpdateLayer:initAssetsManager(urlPackage)

    -- 创建目录
    self._strPathToSave = createDownloadDir()

    local function onError(errorCode)
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            self._pProgressText:setString("无新版本需要更新！")
            
            -- 重试按钮
            self._bRetryButton = ccui.Button:create("buttonNormal.png","buttonPress.png","buttonPress.png",ccui.TextureResType.plistType)
            self._bRetryButton:setTitleFontSize(25)
            self._bRetryButton:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2 - 200)
            self:addChild(self._bRetryButton)
            self._bRetryButton:setTitleText("点击重试")
            local function retryCallBack(sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")
                    self._pProgressText:setString("正在重试，请稍后......")
                elseif eventType == ccui.TouchEventType.canceled then
                    self._pProgressText:setString("无新版本需要更新！")
                elseif eventType == ccui.TouchEventType.ended then
                    local needUpdate = self:checkUpdate()
                    self:show(needUpdate,true)
                end
            end
            self._bRetryButton:addTouchEventListener(retryCallBack)
            
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            self._pProgressText:setString("网络异常，请检查网络环境！")
        
            -- 重试按钮
            self._bRetryButton = ccui.Button:create("buttonNormal.png","buttonPress.png","buttonPress.png",ccui.TextureResType.plistType)
            self._bRetryButton:setTitleFontSize(25)
            self._bRetryButton:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2 - 200)
            self:addChild(self._bRetryButton)
            self._bRetryButton:setTitleText("点击重试")
            local function retryCallBack(sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")
                    self._pProgressText:setString("正在重试，请稍后......")
                elseif eventType == ccui.TouchEventType.canceled then
                    self._pProgressText:setString("网络异常，请检查网络环境！")
                elseif eventType == ccui.TouchEventType.ended then
                    local needUpdate = self:checkUpdate()
                    self:show(needUpdate, true)
                end
            end
            self._bRetryButton:addTouchEventListener(retryCallBack)
            
        elseif errorCode == 4 then
            self._pProgressText:setString("您的游戏版本过低，请下载安装最新版本游戏包后再运行游戏！")
            
            -- 先清空本地缓存
            local strPathToSave = createDownloadDir()
            deleteDownloadDir(strPathToSave)
            cc.UserDefault:getInstance():setIntegerForKey("current-version-code",0)
            cc.UserDefault:getInstance():setIntegerForKey("downloaded-version-code",0)
            createDownloadDir()
            
            -- 超链接按钮
            self._pHyperlinkButton = ccui.Button:create("buttonNormal.png","buttonPress.png","buttonPress.png",ccui.TextureResType.plistType)
            self._pHyperlinkButton:setTitleFontSize(25)
            self._pHyperlinkButton:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2 - 200)
            self:addChild(self._pHyperlinkButton)
            if (cc.PLATFORM_OS_IPHONE == self._platformType) or (cc.PLATFORM_OS_IPAD == self._platformType) then
                self._pHyperlinkButton:setTitleText("点击跳转")
            elseif (cc.PLATFORM_OS_ANDROID == self._platformType) then        -- android开始下载最新apk
                self._pHyperlinkButton:setTitleText("点击下载")
            else
                self._pHyperlinkButton:setVisible(false)
            end
            local function hyperlinkCallBack(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    if (cc.PLATFORM_OS_IPHONE == self._platformType) or (cc.PLATFORM_OS_IPAD == self._platformType) then  -- ios直接打开url
                        cc.Application:getInstance():openURL(strForceDownloadIPAHyperlink)
                    elseif (cc.PLATFORM_OS_ANDROID == self._platformType) then        -- android开始下载渠道最新apk
                        cc.Application:getInstance():openURL(strForceDownloadApkHyperlink[mmo.HelpFunc:getPlatform()])
                    end
                  elseif eventType == ccui.TouchEventType.began then
                         AudioManager:getInstance():playEffect("ButtonClick")
                end
            end
            self._pHyperlinkButton:addTouchEventListener(hyperlinkCallBack)
            
        end
        self._pProgressNum:setVisible(false)
        self._pCircle:setVisible(false)
        self._pCircle2:setVisible(false)
        self._pCircle3:setVisible(false)
    end

    local function onProgress( percent )
        self._pProgressNum:setString(percent.."%")
        self._pProgressBar:setPercentage(percent)
    end

    local function onSuccess()

        local theirPackageVersion = cc.UserDefault:getInstance():getIntegerForKey("current-version-code")
        local goingDownloadVersion = cc.UserDefault:getInstance():getIntegerForKey("downloaded-version-code")
        
        if goingDownloadVersion == theirPackageVersion then -- 版本号已经相同，则可以进入游戏
            local blackOver = function()
                self:entryGame()
            end
            -- 渐黑
            self._pMask:setOpacity(0)
            self._pMask:runAction( cc.Sequence:create(cc.EaseInOut:create(cc.FadeTo:create(1.0, 255), 5.0), cc.CallFunc:create(blackOver)) )
            self._pProgressText:setString("更新完成！正在玩命加载中，请稍后......")

        else    -- 仍旧需要继续更新
            self:updateFromUrl()
        end

    end

    if self._pAssetsManager ~= nil then
        self._pAssetsManager:release()
        self._pAssetsManager = nil
    end
    self._pAssetsManager = cc.AssetsManager:new(urlPackage, strVersionUrl, self._strPathToSave)
    self._pAssetsManager:retain()
    self._pAssetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR)
    self._pAssetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    self._pAssetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    self._pAssetsManager:setConnectionTimeout(3)
    
end

-- 显示更新信息
function UpdateLayer:show(needUpdate, directlyShow)
    
    if needUpdate == true then  -- 需要检查更新
        local showMaskOver = function()
            -- 更新入口
            -- self:resetLocal()
            self:updateFromUrl()
        end
        if directlyShow == true then    -- 直接显示
            showMaskOver()
        else
            -- 渐亮
            self._pMask:setOpacity(255)
            self._pMask:runAction( cc.Sequence:create(cc.EaseInOut:create(cc.FadeTo:create(1.0, 0), 5.0), cc.CallFunc:create(showMaskOver)) )
        end
        
    else   -- 不需要更新，直接进入游戏
        self:entryGame()
    end

    return
end

-- 从url上进行更新
function UpdateLayer:checkUpdate()
    self._pProgressText:setString("正在更新资源，请耐心等待......")
    self:initAssetsManager()
    return self._pAssetsManager:checkUpdate()
end

-- 从url上进行更新
function UpdateLayer:updateFromUrl()
    local theirPackageVersion = cc.UserDefault:getInstance():getIntegerForKey("current-version-code")
    local goingDownloadVersion = cc.UserDefault:getInstance():getIntegerForKey("downloaded-version-code")
    self._pProgressText:setString("正在更新资源，请耐心等待......".."("..(goingDownloadVersion+1).."/"..theirPackageVersion..")")
    self:initAssetsManager(strPackageUrl..versionRegion.."_"..(goingDownloadVersion+1).."_package.zip")
    self._pAssetsManager:update()
    return
end

-- 清空本地下载
function UpdateLayer:resetLocal()
    self._pProgressText:setString("")
    deleteDownloadDir(self._strPathToSave)
    self:initAssetsManager()
    self._pAssetsManager:deleteVersion()
    createDownloadDir()
    return
end

-- 直接进入游戏
function UpdateLayer:entryGame()

    -- 初始化游戏文件（代码和资源）
    self:initialGameFiles()
    
    -- 初始化游戏主场景（正常进入游戏）
    self:initialGameScene()
    
    -- 打印本地读写目录
    cclog("本地读写目录：")
    cclog(self._strPathToSave)

    return
end

-- 初始化游戏文件（代码和资源）
function UpdateLayer:initialGameFiles()

    require("src/paths")
    require("defs")
    require("requirs")
    require("cleans")
    require("funcs")    

    -- 加载公共UI库合图资源(一次加载，永驻内存，不需释放)
    ResPlistManager:getInstance():addNecessarySpriteFrames()

    -- 清空所有逻辑管理器的缓存数据
    cleansAllLogicManagersCache()

    -- 初始化设备信息
    LoginManager:getInstance():initDeviceInfo()

    -- 初始化APP信息
    LoginManager:getInstance():initAppInfo()

    -- 注册网络消息handler
    NetHandlersManager:getInstance():registNetHandlers()

    -- 加载网络协议文件
    loadMessageProcotolFiles()
    
    return
end

-- 初始化游戏主场景（正常进入游戏）
function UpdateLayer:initialGameScene()

    -- 创建主游戏场景
    local pScene = require("GameScene"):create()
    pScene._bSkipHeartBeat = true -- 暂时屏蔽心跳

    --设置 layer，dialog manager的root
    LayerManager:getInstance():setRootSence(pScene)
    DialogManager:getInstance():setRootSence(pScene)

    -- 设置目标场景     
    LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER)
    --LayerManager:getInstance():transformToLoading()

    -- 切换场景
    cc.Director:getInstance():replaceScene(pScene)    
    
    return
end

return UpdateLayer
