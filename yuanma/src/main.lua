--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  main.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   主函数（入口）
--===================================================
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

-- CC_USE_DEPRECATED_API = true
require "cocos.init"

-- 资源的版本区间号（大版本的区间号，只要不同于url中当前大版本区间号，均认为需要强行下载新包）
versionRegion = 1
-- 强制下载IOS的链接
strForceDownloadIPAHyperlink = "http://www.cocos2d-x.org/"
-- 强制下载APK的链接（分渠道）
strForceDownloadApkHyperlink = {
    -- 巨人移动账号系统 
    [1] = "http://www.ztgame.com/",
    -- 奇虎360
    [20] = "http://www.360.cn/",
    -- 百度手机助手
    [23] = "https://www.baidu.com/",
    -- 九游UC
    [26] = "http://www.uc.cn/",
    -- 小米
    [28] = "http://www.mi.com/",
    -- 腾讯/应用宝 
    [57] = "http://www.qq.com/",
}

-- 热更新version号的url地址
strVersionUrl = "http://115.159.54.142:8000/version/checkversion"       -- 开发
--strVersionUrl = "http://115.159.54.142:8800/version/checkversion"       -- 巨人
-- 热更新package包的url地址
strPackageUrl = "http://115.159.54.142:8000/client/"                    -- 开发
--strPackageUrl = "http://115.159.54.142:8800/client/"                    -- 巨人

-- 是否开启FPS调试信息
bOpenDisplayStats = true

-- 是否开始屏幕调试信息
bOpenScreenLog = true

-- 是否开启家园地图矩形调试信息
bOpenWorldMapDebugRect = false

-- 是否开启战斗地图矩形调试信息
bOpenBattleMapDebugRect = false

-- 是否开启手机与电脑的相同登录方式
bOpenMobileAndWinMacSameLoginWay = true

-- 是否跳过splash动画
bSkipSplashMove = true

-- 是否跳过新手CG动画
bSkipGuideCGMove = true

-- 是否开启剧情副本（章节调试全开功能按钮）
bStoryCopyTestBtn = true

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    -- 内存回收
    collectgarbage("collect")
    
    -- 避免内存泄露
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- 资源版本区间号的设置
    local cacheMyVersionRegion = cc.UserDefault:getInstance():getIntegerForKey("myVersionRegion")
    if cacheMyVersionRegion < versionRegion then
        local strPathToSave = createDownloadDir()
        deleteDownloadDir(strPathToSave)
        cc.UserDefault:getInstance():setIntegerForKey("current-version-code",0)
        cc.UserDefault:getInstance():setIntegerForKey("downloaded-version-code",0)
        createDownloadDir()
    end
    cc.UserDefault:getInstance():setIntegerForKey("myVersionRegion", versionRegion)
    cc.UserDefault:getInstance():flush()
    
    -- 初始化director
    local director = cc.Director:getInstance()

    -- 开启FPS调试信息
    director:setDisplayStats(bOpenDisplayStats)

    -- 设置游戏帧频率
    director:setAnimationInterval(1.0 / 60)  -- 60
    
    -- 设置屏幕适配方案
    director:getOpenGLView():setDesignResolutionSize(1024, 768, 3)
    
    -- 正交投影，禁止使用透视投影，以免3D模型产生透视感，设置成2D，即0
    director:setProjection(cc.DIRECTOR_PROJECTION2_D)
    --director:setDepthTest(true)
    
    cc.AnimationCache:destroyInstance()
    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    director:getTextureCache():removeAllTextures()
    
    -- 创建游戏场景
    local pScene = cc.Scene:create()
    
    -- 正常进入游戏模式
    pScene:addChild(require("src/Launch/SplashLayer"):create())

    -- 快速进入战斗开发模式
    --pScene:addChild(require("src/Launch/BattleDebugLayer"):create())
    
    -- 切换场景
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(pScene)
    else
        cc.Director:getInstance():runWithScene(pScene)
    end

end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
