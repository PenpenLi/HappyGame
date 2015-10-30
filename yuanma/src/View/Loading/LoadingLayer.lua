--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  LoadingLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   Loading层
--===================================================
local LoadingLayer = class("LoadingLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function LoadingLayer:ctor()
    self._strName = "LoadingLayer"                  -- 层名称
    self._pBg = nil                                 -- 背景
    self._pLoadingText = nil                        -- loading文字
    self._pLoadingPercentText = nil                 -- loading百分比文字
    self._pTips = nil                               -- 温馨提示
    self._kTargetSessionKind = kSession.kNone       -- 目标session
    self._bShow = false                             -- 是否显示
    self._nCounter = 0                              -- 计数器
    self._bAsyncStart = false                       -- 异步资源加载是否开始
    self._nStep = 0                                 -- 当前步数
    self._nTotalAsyncStep = 0                       -- 异步步数
    self._nTotalSyncStep = 0                        -- 同步步数
    self._fPercent = 0                              -- 当前百分比
    self._tArgs = {}                                -- 切换到session的参数
    self._nUpdateLock = -1
    
    self._bPreSessionReleaseOver = false            -- 标记从前一个场景过来后，前一个场景的资源是否已经释放并清空过记录
    self._bInitSessionArgsOver = false              -- 标记从前一个场景过来后，是否已经初始化完毕下一个场景的参数

end

-- 创建函数（参数：目标session的类型，是否显示）
function LoadingLayer:create(targetSessionKind,show,args)
    local layer = LoadingLayer.new()
    layer:dispose(targetSessionKind, show, args)
    return layer
end

-- 处理函数
function LoadingLayer:dispose(targetSessionKind, show, args)
    --------------------初始化--------------------------------
    cc.Director:getInstance():getScheduler():setTimeScale(1.0)
    if show == true then
        ResPlistManager:getInstance():addSpriteFrames("loading.plist")   -- 加载loading合图资源
        ResPlistManager:getInstance():addSpriteFrames("CloudTransfor.plist")    -- 加载云层合图资源
    end
    self:initInfo(targetSessionKind, show, args)
    self:initUI()
    
    -- 触摸注册
    local function onTouchBegin(touch,event)
        return true
    end
    local function onTouchMoved(touch,event)
    end
    local function onTouchEnded(touch,event)
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
            if show == false then
                self._nUpdateLock = 0
            end
        elseif event == "exit" then
            self:onExitLoadingLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function LoadingLayer:onExitLoadingLayer()
    self:onExitLayer()
    
    -- 释放掉loading合图资源
    ResPlistManager:getInstance():removeSpriteFrames("loading.plist")
    ResPlistManager:getInstance():removeSpriteFrames("CloudTransfor.plist")

end



-- 初始化信息
function LoadingLayer:initInfo(targetSessionKind, show, args)
    -- 目标session
    self._kTargetSessionKind = targetSessionKind
    -- 是否显示
    self._bShow = show
    -- 切换到session的参数
    self._tArgs = args
    
end

-- 初始化UI
function LoadingLayer:initUI()
    if self._bShow then

        -- 加载背景
        self._pBg = cc.Sprite:createWithSpriteFrameName("loadingBG1.png")
        self._pBg:setPosition(mmo.VisibleRect:center())
        self:addChild(self._pBg)

        -- loading字样
        self._pLoadingText = cc.Label:createWithTTF("", strCommonFontName, 30)
        self._pLoadingText:setTextColor(cFontWhite)
        self._pLoadingText:enableOutline(cFontOutline,2)
        self._pLoadingText:setPosition(mmo.VisibleRect:width()-30*3, 30)
        self._pLoadingText:setAnchorPoint(1.0,0.5)
        self:addChild(self._pLoadingText)

        -- loading百分比字样
        self._pLoadingPercentText = cc.Label:createWithTTF("", strCommonFontName, 30)
        self._pLoadingPercentText:setTextColor(cFontWhite)
        self._pLoadingPercentText:enableOutline(cFontOutline,2)
        self._pLoadingPercentText:setPosition(mmo.VisibleRect:width()-30*3, 30)
        self._pLoadingPercentText:setAnchorPoint(0,0.5)
        self:addChild(self._pLoadingPercentText)

        -- 温馨提示
        self._pTips = cc.Label:createWithTTF("温馨提示：经常洗澡有助于保持个人卫生！", strCommonFontName, 30)
        self._pTips:setTextColor(cFontWhite)
        self._pTips:enableOutline(cFontOutline,2)
        self._pTips:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/4)
        self:addChild(self._pTips)
        
        -- 云渐入
        self:cloudIn()
        
    end
    
end

-- 云（进入）
function LoadingLayer:cloudIn()
    -- 进入（云进入）
    -- 背景渐现
    self._pBg:setOpacity(0)
    self._pLoadingText:setOpacity(0)
    self._pLoadingPercentText:setOpacity(0)
    self._pTips:setOpacity(0)
    self._pBg:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),cc.FadeIn:create(0.2)))
    self._pLoadingText:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),cc.FadeIn:create(0.2)))
    self._pLoadingPercentText:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),cc.FadeIn:create(0.2)))
    self._pTips:runAction(cc.Sequence:create(cc.DelayTime:create(2.2),cc.FadeIn:create(0.2)))
    -- 云遮盖特效
    local pAni = cc.CSLoader:createNode("CloudTransfor.csb")
    pAni:setPosition(mmo.VisibleRect:center())
    self:addChild(pAni)
    local action = cc.CSLoader:createTimeline("CloudTransfor.csb")
    action:gotoFrameAndPlay(0, 90, false)
    action:setTimeSpeed(0.8)
    pAni:runAction(action)
    local endMapCamera = function()
        MapManager:getInstance():endMapCameraWithScale()  -- 相机scale
    end
    local inOver = function()
        self._nUpdateLock = 0
    end
    pAni:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(endMapCamera),cc.DelayTime:create(1.5),cc.FadeOut:create(0.5),cc.CallFunc:create(inOver)))

end

-- 云（散去）
function LoadingLayer:cloudOut()
    -- 创建新的场景
    LayerManager:getInstance():transforToTargetSession()
    local show = function()
        -- 背景渐现
        self._pBg:setOpacity(255)
        self._pLoadingText:setOpacity(255)
        self._pLoadingPercentText:setOpacity(255)
        self._pTips:setOpacity(255)
        self._pBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeOut:create(0.1)))
        self._pLoadingText:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeOut:create(0.1)))
        self._pLoadingPercentText:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeOut:create(0.1)))
        self._pTips:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeOut:create(0.1)))
        -- 云遮盖特效
        local pAni = cc.CSLoader:createNode("CloudTransfor.csb")
        pAni:setPosition(mmo.VisibleRect:center())
        pAni:setOpacity(0)
        self:addChild(pAni)
        local action = cc.CSLoader:createTimeline("CloudTransfor.csb")
        action:gotoFrameAndPlay(90, 160, false)
        action:setTimeSpeed(0.8)
        pAni:runAction(action)
        pAni:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.5)))
        local cloudDiappear = function()
            MapManager:getInstance():initMapCameraWithScale()  -- 初始化相机scale
        end
        local outOver = function()
            self:close()
        end
        pAni:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(cloudDiappear),cc.DelayTime:create(1.0),cc.CallFunc:create(outOver)))
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(show)))
    
end

-- 循环更新
function LoadingLayer:update(dt)

    -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:000")
    
    if self._nUpdateLock == -1 then
        return
    end

    self._nUpdateLock = self._nUpdateLock + 1

    ------- 释放前一个session的合图信息和纹理资源，并清空记录
    -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:111")
    self:procUnLoadingRes()

    ------- 设置目标session的参数
    -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:222")
    self:procSessionArgs()

    ------- 加载目标session要用到的基本资源
    if self._kTargetSessionKind == kSession.kLogin then
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:333")
        self:procLoadingLogin()
    elseif self._kTargetSessionKind == kSession.kWorld then
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:444")
        self:procLoadingWorld()
    elseif self._kTargetSessionKind == kSession.kBattle then
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:555")
        self:procLoadingBattle()
    elseif self._kTargetSessionKind == kSession.kGuide then
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:666")
        self:procLoadingStory()
    elseif self._kTargetSessionKind == kSession.kSelect then
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:777")
        self:procLoadingSelectLayer()
    end

    return
end

-- 初始化session参数
function LoadingLayer:procSessionArgs() 
    if self._nUpdateLock <= 5 then
        return
    end
    if self._bInitSessionArgsOver == false then
        self._bInitSessionArgsOver = true
        ------------------------- 进入战斗地图前的数据对接 ----------------------------------------
        -- 【战斗数据对接】
        if self._kTargetSessionKind == kSession.kBattle then
            MapManager:getInstance()._strNextMapName = self._tArgs._strNextMapName
            MapManager:getInstance()._strNextMapPvrName = self._tArgs._strNextMapPvrName
            MapManager:getInstance()._nNextMapDoorIDofEntity = self._tArgs._nNextMapDoorIDofEntity
            -- 主角玩家数据
            RolesManager:getInstance()._pMainRoleInfo = self._tArgs._pMainRoleInfo
            RolesManager:getInstance()._nMainPlayerRoleCurHp = self._tArgs._nMainPlayerRoleCurHp            -- 必要的时候这里会有数据（比如从战斗地图切换到另一张战斗地图，血值需要共享上一张战斗的值）
            RolesManager:getInstance()._nMainPlayerRoleCurAnger = self._tArgs._nMainPlayerRoleCurAnger      -- 必要的时候这里会有数据（比如从战斗地图切换到另一张战斗地图，怒气值需要共享上一张战斗的值）
            if self._tArgs._nMainPetRoleCurHp then
                PetsManager:getInstance()._nMainPetRoleCurHp =  self._tArgs._nMainPetRoleCurHp              -- 必要的时候这里会有数据（比如从战斗地图切换到另一张战斗地图，血值需要共享上一张战斗的值）
            end
            RolesManager:getInstance()._tOtherPlayerRolesCurHp = {}
            for k, v in pairs(self._tArgs._tOtherPlayerRolesCurHp) do 
                RolesManager:getInstance()._tOtherPlayerRolesCurHp[k] = v
            end
            RolesManager:getInstance()._tOtherPlayerRolesCurAnger = {}
            for k, v in pairs(self._tArgs._tOtherPlayerRolesCurAnger) do 
                RolesManager:getInstance()._tOtherPlayerRolesCurAnger[k] = v
            end
            PetsManager:getInstance()._tOtherPetRolesCurHp = {}
            for k, v in pairs(self._tArgs._tOtherPetRolesCurHp) do 
                PetsManager:getInstance()._tOtherPetRolesCurHp[k] = v
            end
            -- 设置当前副本类型
            StagesManager:getInstance()._nCurCopyType = self._tArgs._nCurCopyType
            -- 采用关卡表中的副本数据
            StagesManager:getInstance()._nCurStageID = self._tArgs._nCurStageID
            StagesManager:getInstance()._nCurStageMapID = self._tArgs._nCurStageMapID
            StagesManager:getInstance()._nBattleId = self._tArgs._nBattleId
            BattleManager:getInstance()._fTimeMax = self._tArgs._fTimeMax
            BattleManager:getInstance()._bIsAutoBattle = self._tArgs._bIsAutoBattle
            MonstersManager:getInstance()._tMonsterDeadNum = self._tArgs._tMonsterDeadNum
            -- 副本标示id，用于做验证 
            StagesManager:getInstance()._nIdentity = self._tArgs._nIdentity
            -- 对手pvp数据
            RolesManager:getInstance()._pPvpRoleInfo = self._tArgs._pPvpRoleInfo
            SkillsManager:getInstance()._tPvpRoleMountAngerSkills = self._tArgs._tPvpRoleMountAngerSkills
            SkillsManager:getInstance()._tPvpRoleMountActvSkills = self._tArgs._tPvpRoleMountActvSkills
            SkillsManager:getInstance()._tPvpRoleSkillsLevels.pasvSkills = self._tArgs._tPvpPasvSkills
            -- 设置挑战对手的宠物信息
            if self._tArgs._tPvpPetRoleInfosInQueue ~= nil then
                PetsManager:getInstance()._tPvpPetRoleInfosInQueue = self._tArgs._tPvpPetRoleInfosInQueue
            end
            -- 传递pvp宠物共鸣信息
            RolesManager:getInstance()._tPvpPetCooperates = self._tArgs._tPvpPetCooperates
            --爬塔副本的战斗结算数据
            BattleManager:getInstance()._tTowerCopyStepResultInfos = self._tArgs._tTowerCopyStepResultInfos
            -- 其他玩家信息传递
            RolesManager:getInstance()._tOtherPlayerRolesInfosOnBattleMap = self._tArgs._tOtherPlayerRolesInfosOnBattleMap
            SkillsManager:getInstance()._tOtherPlayerRolesMountAngerSkillsInfos = self._tArgs._tOtherPlayerRolesMountAngerSkillsInfos
            SkillsManager:getInstance()._tOtherPlayerRolesMountActvSkillsInfos = self._tArgs._tOtherPlayerRolesMountActvSkillsInfos
            SkillsManager:getInstance()._tOtherPlayerRolesPasvSkillsInfos = self._tArgs._tOtherPlayerRolesPasvSkillsInfos
            -- 传递其他玩家宠物共鸣信息
            RolesManager:getInstance()._tOtherPetCooperates = self._tArgs._tOtherPetCooperates
            -- 是否为新手引导中第一场战斗
            BattleManager:getInstance()._bIsFirstBattleOfNewbie = self._tArgs._bIsFirstBattleOfNewbie

            -------------------------- 记录当前stage的起始（第一关）的战斗数据（用于重玩功能） -------------------------------------
            
            if self._tArgs._nCurCopyType ~= kType.kCopy.kStory and self._tArgs._nCurCopyType ~= kType.kCopy.kGold and
               self._tArgs._nCurCopyType ~= kType.kCopy.kStuff and self._tArgs._nCurCopyType ~= kType.kCopy.kChallenge and
               self._tArgs._nCurCopyType ~= kType.kCopy.kMaze then
                 return   -- 不支持重玩功能的副本直接跳过即可
            end
            
            BattleManager:getInstance()._tBattleArgs = self._tArgs
            
            -- 采用关卡表中的副本数据
            BattleManager:getInstance()._tBattleArgs._nCurCopyType = StagesManager:getInstance()._nCurCopyType
            BattleManager:getInstance()._tBattleArgs._nCurStageMapID = StagesManager:getInstance():getCurStageDataInfo().MapID
            
            -- 地图信息
            BattleManager:getInstance()._tBattleArgs._strNextMapName = StagesManager:getInstance():getStageMapInfoByCopyTypeAndMapID(StagesManager:getInstance()._nCurCopyType, StagesManager:getInstance():getCurStageDataInfo().MapID).MapsName
            BattleManager:getInstance()._tBattleArgs._strNextMapPvrName = StagesManager:getInstance():getStageMapInfoByCopyTypeAndMapID(StagesManager:getInstance()._nCurCopyType, StagesManager:getInstance():getCurStageDataInfo().MapID).MapsPvrName
            BattleManager:getInstance()._tBattleArgs._nNextMapDoorIDofEntity = StagesManager:getInstance():getStageMapInfoByCopyTypeAndMapID(StagesManager:getInstance()._nCurCopyType, StagesManager:getInstance():getCurStageDataInfo().MapID).Doors[1][1]
            BattleManager:getInstance()._tBattleArgs._nBattleId = StagesManager:getInstance():getCurStageDataInfo().ID
            BattleManager:getInstance()._tBattleArgs._fTimeMax = StagesManager:getInstance():getCurStageDataInfo().Timeing
            
            -- 主角玩家数据
            BattleManager:getInstance()._tBattleArgs._nMainPlayerRoleCurHp = nil
            BattleManager:getInstance()._tBattleArgs._nMainPlayerRoleCurAnger = nil
            BattleManager:getInstance()._tBattleArgs._nMainPetRoleCurHp = nil
            
            -- 参数信息
            BattleManager:getInstance()._tBattleArgs._bIsAutoBattle = false
            BattleManager:getInstance()._tBattleArgs._tMonsterDeadNum = {}
            ---------------------------------------------------------------------------------------------------------------------
            
           
        end
        
        self._nUpdateLock = 0
    end

end

-- 刷新UI内容
function LoadingLayer:updateUI()  
    self._nCounter = self._nCounter + 1
    
    if self._nCounter % 120 < 20 then
        self._pLoadingText:setString(".玩命加载中")
    elseif self._nCounter % 120 < 40 then
        self._pLoadingText:setString("..玩命加载中")
    elseif self._nCounter % 120 < 60 then
        self._pLoadingText:setString("...玩命加载中")
    elseif self._nCounter % 120 < 80 then
        self._pLoadingText:setString("....玩命加载中")
    elseif self._nCounter % 120 < 100 then
        self._pLoadingText:setString(".....玩命加载中")
    else
        self._pLoadingText:setString("......玩命加载中")
    end
    
    ---------计算百分比值----------------------------------------------------------------------------------------------------------------------
    self._fPercent = math.modf(100*self._nStep/(self._nTotalAsyncStep + self._nTotalSyncStep))
    self._pLoadingPercentText:setString(self._fPercent.."%")
    if self._fPercent == 100 then
        self:cloudOut()
        self._nUpdateLock = -1
    end
    
end

function LoadingLayer:procUnLoadingRes()
    if self._nUpdateLock <= 5 then
        return
    end
    if self._bPreSessionReleaseOver == false then
        -- 置标记位
        self._bPreSessionReleaseOver = true
        
        -- 移除之前的层和Dialog
        LayerManager:getInstance():releaseLayersAndDialogs()

        -- 清空缓存和记录
        ResPlistManager:getInstance():clearPvrName()
        
        -- 暂停所有音效
        AudioManager:getInstance():stopAllEffects()
        
        -- 清空音乐缓存
        AudioManager:getInstance():purgeAudioEngineData()
        
        -- 释放所有3D缓存信息
        --mmo.HelpFunc:removeAllSprite3DData()
        
        -- 移除所有TimelineActions
        --mmo.HelpFunc:removeAllTimelineActions()

        -- 移除所有没有用到的缓存
        --ResPlistManager:getInstance():removeSpriteFramesInLoading()

        -- 加载必要的资源
        --ResPlistManager:getInstance():addNecessarySpriteFrames()

        --collectMems()
        self._nUpdateLock = 0
    end
end

function LoadingLayer:procLoadingStory()
    if self._nUpdateLock <= 5 then
        return
    end
    ResPlistManager:getInstance():collectPvrNameForLogin()
    ResPlistManager:getInstance():loadPvr()
    print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    self:cloudOut()
    self._nUpdateLock = -1
end

function LoadingLayer:procLoadingSelectLayer()
    if self._nUpdateLock <= 5 then
        return
    end
    ResPlistManager:getInstance():collectPvrNameForLogin()
    ResPlistManager:getInstance():loadPvr()
    print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
    self:cloudOut()
    self._nUpdateLock = -1
end

function LoadingLayer:procLoadingLogin()
    if self._nUpdateLock <= 5 then
        return
    end
    if self._bShow == false then
        ResPlistManager:getInstance():collectPvrNameForLogin()
        ResPlistManager:getInstance():loadPvr()
        LayerManager:getInstance():transforToTargetSession()  -- 创建新的场景
        self:close()
    end
    self._nUpdateLock = -1
end

function LoadingLayer:procLoadingWorld()
    if self._nUpdateLock <= 5 then
        return
    end
    if self._bShow == true then
        -- 异步加载回调
        local function imageLoaded(texture) self._nStep = self._nStep + 1  print("异步回调"..self._nStep.."次") end

        if self._bAsyncStart == true then
            -- 异步加载已递增到同步的步数
            if self._nStep >= self._nTotalAsyncStep then
                -- 测试：是否显示调试信息----------------------------------------------------
                local bShowDebugInfos = bOpenWorldMapDebugRect
                
                if self._nStep == self._nTotalAsyncStep then -- 同步第1次
                    ResPlistManager:getInstance():loadPvr()
                elseif self._nStep == self._nTotalAsyncStep + 1 then -- 同步第2次
                    -- 创建世界地图地图，并显示网格
                    self:getMapManager():calculateSkyType()
                    self:getMapManager():createMap(bShowDebugInfos, false)
                elseif self._nStep == self._nTotalAsyncStep + 2 then -- 同步第3次
                    -- 创建地图上所有碰撞矩形（同时初始化所有的触发事件）
                    self:getRectsManager():createRectsOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep + 3 then -- 同步第4次
                    -- 创建地图上所有的实物
                    self:getEntitysManager():createEntitysOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep + 4 then -- 同步第5次
                    -- 创建所有触发器
                    self:getTriggersManager():createTriggersOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep + 5 then -- 同步第6次
                    -- 创建所有NPC
                    self:getRolesManager():createNpcRolesOnWorldMap()
                elseif self._nStep == self._nTotalAsyncStep + 6 then -- 同步第7次
                    -- 创建主角，绑定主角到地图
                    self:getRolesManager():createMainPlayerRoleOnMap(bShowDebugInfos)
                    -- 创建其他玩家
                    self:getRolesManager():createOtherPlayerRoleOnMap()
                    -- 创建其他玩家的宠物
                    self:getPetsManager():createOtherPetRolesOnMap()
                elseif self._nStep == self._nTotalAsyncStep + 7 then -- 同步第8次
                    -- 创建主角宠物，绑定宠物到地图
                    self:getPetsManager():createMainPetRoleOnMap(bShowDebugInfos)
                end
                self._nStep = self._nStep + 1
            end
        else
            -- 收集纹理名称
            ResPlistManager:getInstance():collectPvrNameForWorld()
            -- 注册加载回调（异步步数）
            ResPlistManager:getInstance():loadPicAsync(imageLoaded)
            -- 标记异步注册结束并开始等待异步回调步数的递增
            self._bAsyncStart = true
            -- 异步一共步数
            self._nTotalAsyncStep = #(ResPlistManager:getInstance()._tPvrNameCollector) 
            -- 同步一共步数
            self._nTotalSyncStep = 8
            
        end

        self:updateUI()  -- 更新UI
    end    
end

function LoadingLayer:procLoadingBattle()
    if self._nUpdateLock <= 5 then
        return
    end
    if self._bShow == true then
        -- 异步加载回调
        local function imageLoaded(texture) self._nStep = self._nStep + 1  print("异步回调"..self._nStep.."次") end

        if self._bAsyncStart == true then
            -- 异步加载已递增到同步的步数
            if self._nStep >= self._nTotalAsyncStep then
                -- 测试：是否显示调试信息 ----------------------------------------------------
                local bShowDebugInfos = bOpenBattleMapDebugRect
                
                -- 开始创建游戏对象
                if self._nStep == self._nTotalAsyncStep then -- 同步第1次
                    ResPlistManager:getInstance():loadPvr()
                elseif self._nStep == self._nTotalAsyncStep+1 then -- 同步第2次  创建地图
                    -- 创建战斗地图，并显示网格
                    self:getMapManager():calculateSkyType()
                    self:getMapManager():createMap(bShowDebugInfos, false) 
                elseif self._nStep == self._nTotalAsyncStep+2 then -- 同步第3次  创建碰撞矩形
                    -- 创建地图上所有碰撞矩形（同时初始化所有的触发事件）
                    self:getRectsManager():createRectsOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep+3 then -- 同步第4次  创建实体
                    -- 创建地图上所有的实物
                    self:getEntitysManager():createEntitysOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep+4 then -- 同步第5次  创建触发器
                    -- 创建所有触发器
                    self:getTriggersManager():createTriggersOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep+5 then -- 同步第6次  创建NPC
                    -- 创建所有NPC
                    self:getRolesManager():createNpcRolesOnBattleMap()
                elseif self._nStep == self._nTotalAsyncStep+6 then -- 同步第7次  创建主角和好友
                    -- 创建主角，绑定主角到地图
                    self:getRolesManager():createMainPlayerRoleOnMap(bShowDebugInfos)
                    -- 创建好友角色，绑定角色到地图
                    self:getRolesManager():createFriendRoleOnMap()
                elseif self._nStep == self._nTotalAsyncStep+7 then -- 同步第8次  创建pvp对手
                    -- 创建pvp对手，绑定pvp对手到地图
                    self:getRolesManager():createPvpPlayerRoleOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep+8 then -- 同步第9次  主角宠物
                    -- 创建主角宠物，绑定宠物到地图
                    self:getPetsManager():createMainPetRoleOnMap(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep+9 then -- 同步第10次  创建pvp对手宠物
                    -- 创建pvp对手宠物，绑定宠物到地图
                    self:getPetsManager():createPvpPetRoleOnMap(bShowDebugInfos)
                    -- 创建其他玩家
                    self:getRolesManager():createOtherPlayerRoleOnMap()
                    -- 创建其他玩家的宠物
                    self:getPetsManager():createOtherPetRolesOnMap()
                elseif self._nStep == self._nTotalAsyncStep+10 then -- 同步第11次  创建野怪          
                    -- 创建野怪
                    self:getMonstersManager():createAllMonsterRoles(bShowDebugInfos)
                elseif self._nStep == self._nTotalAsyncStep+11 then -- 同步第12次  创建技能                
                    -- 创建技能
                    self:getSkillsManager():createAllSkills(bShowDebugInfos)
                end
                self._nStep = self._nStep + 1
            end
        else
            -- 收集纹理名称
            ResPlistManager:getInstance():collectPvrNameForBattle()
            -- 注册加载回调（异步步数）
            ResPlistManager:getInstance():loadPicAsync(imageLoaded)
            -- 标记异步注册结束并开始等待异步回调步数的递增
            self._bAsyncStart = true
            -- 异步一共步数
            self._nTotalAsyncStep = #(ResPlistManager:getInstance()._tPvrNameCollector) 
            -- 同步一共步数
            self._nTotalSyncStep = 12
        end
        
        -- 更新UI
        self:updateUI()
    end    
end

-- 显示结束时的回调
function LoadingLayer:doWhenShowOver()  
    return
end

-- 关闭结束时的回调
function LoadingLayer:doWhenCloseOver()
    return
end

return LoadingLayer
