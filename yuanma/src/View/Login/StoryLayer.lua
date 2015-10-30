--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryLayer.lua
-- author:    liyuhang
-- created:   2015/6/23
-- descrip:   剧情层
--===================================================

-------------------------------------------------------- 第一场引导战斗数据配置区域 -------------------------------------------------
--------------------------------- 主角玩家的详细信息 ---------------------------
local mainRoleInfo = {
    ["level"] = 20,
    ["equipemts"] = {
        [1] = {     -- 头
            ["position"] = 0,
            ["id"] = 100001,
            ["equipment"] = {
                [1] = {
                    ["fightingPower"] = 228,
                    ["stones"] = {
                    },
                    ["majorAttr"] = {
                        ["attrType"] = 1,
                        ["attrValue"] = 57,
                    },
                    ["minorAttr"] = {
                    },
                },
            },
            ["value"] = 0,
            ["baseType"] = 1,
        },
         [2] = {        -- 身
             ["position"] = 0,
             ["id"] = 100053,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 324,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 1,
                         ["attrValue"] = 81,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [3] = {    -- 手
             ["position"] = 0,
             ["id"] = 100021,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 1428,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 3,
                         ["attrValue"] = 84,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [4] = {    -- 胳膊
             ["position"] = 0,
             ["id"] = 100031,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 918,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 3,
                         ["attrValue"] = 54,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [5] = {    -- 武器
             ["position"] = 0,
             ["id"] = 100201,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 3080,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 2,
                         ["attrValue"] = 77,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [6] = {        -- 项链
             ["position"] = 0,
             ["id"] = 100051,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 2337,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 4,
                         ["attrValue"] = 57,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [7] = {        -- 戒指
             ["position"] = 0,
             ["id"] = 100061,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 3696,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 5,
                         ["attrValue"] = 88,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [8] = {        -- 时装背
             ["position"] = 0,
             ["id"] = 100071,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 2720,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 2,
                         ["attrValue"] = 68,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [9] = {        -- 时装身
             ["position"] = 0,
             ["id"] = 100081,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 2277,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 16,
                         ["attrValue"] = 69,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
         [10] = {       -- 时装光环
             ["position"] = 0,
             ["id"] = 100091,
             ["equipment"] = {
                 [1] = {
                     ["fightingPower"] = 2337,
                     ["stones"] = {
                     },
                     ["majorAttr"] = {
                         ["attrType"] = 4,
                         ["attrValue"] = 57,
                     },
                     ["minorAttr"] = {
                     },
                 },
             },
             ["value"] = 0,
             ["baseType"] = 1,
         },
     },
     ["roleName"] = RolesManager:getInstance()._pMainRoleInfo.roleName,
     ["roleCareer"] = RolesManager:getInstance()._pMainRoleInfo.roleCareer,
     ["reviveCount"] = 0,
     ["roleId"] = 10008,
     ["exp"] = 0,
     ["finances"] = {
         [1] = {
             ["amount"] = 100000,
             ["finance"] = 2,
         },
         [2] = {
             ["amount"] = 9999,
             ["finance"] = 1,
         },
         [3] = {
             ["amount"] = 2000,
             ["finance"] = 3,
         },
         [4] = {
             ["amount"] = 100000,
             ["finance"] = 4,
         },
     },
     ["fashionOptions"] = {
         [1] = false,
         [2] = false,
         [3] = false,
     },
     ["strength"] = 120,
     ["roleAttrInfo"] = {
         ["coldAttack"] = 0,
         ["hp"] = 9999999,
         ["resistance"] = 0,
         ["lifePerSecond"] = 0,
         ["penetration"] = 0,
         ["block"] = 0,
         ["fightingPower"] = 25681,
         ["lifeSteal"] = 0,
         ["attack"] = 175,
         ["critRate"] = 118,
         ["fireAttack"] = 0,
         ["defend"] = 162,
         ["critDmage"] = 92,
         ["speed"] = 200,
         ["attrEnhanced"] = 0,
         ["furyRegeneration"] = 0,
         ["dodgeRate"] = 0,
         ["lightningAttack"] = 0,
         ["resilience"] = 0,
     },
}

--------------------------------------------------------------------------------------------------------------------------------------

local enterBattle = function()
    -- 备份玩家的真实信息，以便第一场战斗结束后进行恢复
    RolesManager:getInstance()._pMainRoleInfoBakOfNewbie = RolesManager:getInstance()._pMainRoleInfo
    -- 战斗数据组装
    -- 【战斗数据对接】
    local copyIndex = 1
    local copyDataInfo = TableStoryCopys[copyIndex]
    local copyFirstMapInfo = TableStoryCopysMaps[copyDataInfo.MapID]
    local args = {}
    args._strNextMapName = copyFirstMapInfo.MapsName
    args._strNextMapPvrName = copyFirstMapInfo.MapsPvrName
    args._nNextMapDoorIDofEntity = copyFirstMapInfo.Doors[1][1]
    args._pMainRoleInfo = mainRoleInfo
    args._nMainPlayerRoleCurHp = nil      -- 从副本进入时，这里为无效值
    args._nMainPlayerRoleCurAnger = nil   -- 从副本进入时，这里为无效值
    args._nMainPetRoleCurHp = nil         -- 从副本进入时，这里为无效值
    args._tOtherPlayerRolesCurHp = {}      -- 从副本进入时，这里为无效值
    args._tOtherPlayerRolesCurAnger = {}   -- 从副本进入时，这里为无效值
    args._tOtherPetRolesCurHp = {}         -- 从副本进入时，这里为无效值
    args._nCurCopyType =TableStoryCopys[copyIndex].CopysType
    args._nCurStageID = TableStoryCopys[copyIndex].ID
    args._nCurStageMapID = TableStoryCopys[copyIndex].MapID
    args._nBattleId = TableStoryCopys[copyIndex].ID
    args._fTimeMax = TableStoryCopys[copyIndex].Timeing
    args._bIsAutoBattle = false
    args._tMonsterDeadNum = {}
    args._nIdentity = 0
    args._tTowerCopyStepResultInfos = {}
    args._pPvpRoleInfo = nil
    args._tPvpRoleMountAngerSkills = {}
    args._tPvpRoleMountActvSkills = {}
    args._tPvpPasvSkills = {}
    args._tPvpPetRoleInfosInQueue = {}
    args._tPvpPetCooperates = {}
    args._tOtherPlayerRolesInfosOnBattleMap = {}
    args._tOtherPlayerRolesMountAngerSkillsInfos = {}
    args._tOtherPlayerRolesMountActvSkillsInfos = {}
    args._tOtherPlayerRolesPasvSkillsInfos = {}
    args._tOtherPetCooperates = {}
    args._bIsFirstBattleOfNewbie = true

    if mainRoleInfo.roleCareer == kCareer.kWarrior then
        SkillsManager:getInstance()._tMainRoleMountActvSkills = 
        {
            ------------------------------- 战士相关技能 ---------------------------------------
            -- 钢气斩
            {
              id=2,
              level=1
            },
            --一断剑
            {
              id=5,
              level=1
            },
           -- 万仞山
            {
              id=8,
              level=1
            },
            -- 炎螺旋
            {
              id=11,
              level=1
            },
        }
        SkillsManager:getInstance()._tMainRoleMountAngerSkills = 
        {
            ------------------------------- 战士相关怒气技能 ---------------------------------------
            -- 绝剑·空裂          
            {
                id=14,
                level=1
            },
        
        }
        SkillsManager:getInstance()._tMainRoleSkillsLevels.pasvSkills = 
        {
            ------------------------------- 战士相关被动技能 ---------------------------------------
        }
    elseif mainRoleInfo.roleCareer == kCareer.kMage then
        SkillsManager:getInstance()._tMainRoleMountActvSkills = 
        {
            ------------------------------- 法师相关技能 ---------------------------------------
            -- 道法烈焰
            {
                id=18,
                level=1
            },
            -- 道法凝冰
            {
                id=21,
               level=1
            },
             --道法天雷
            {
               id=24,
               level=1
            },
            {
                id=27,
                level=1
            },
            
        }
        SkillsManager:getInstance()._tMainRoleMountAngerSkills = 
        {
            ------------------------------- 法师相关怒气技能 ---------------------------------------            
                {
                    id=30,
                    level=1
                },
        }
        SkillsManager:getInstance()._tMainRoleSkillsLevels.pasvSkills = 
        {
            ------------------------------- 法师相关被动技能 ---------------------------------------
        }
    elseif mainRoleInfo.roleCareer == kCareer.kThug then
        SkillsManager:getInstance()._tMainRoleMountActvSkills = 
        {
            ------------------------------- 刺客相关技能 ---------------------------------------
            --飞镖
            {
               id=34,
               level=1
            },
            -- 连影杀
            {
               id=37,
               level=1
            },
            -- 罗天坠
           {
              id=40,
              level=1
            },
            {
               id=43,
               level=1
            },
        }
        SkillsManager:getInstance()._tMainRoleMountAngerSkills = 
        {
            ------------------------------- 刺客相关怒气技能 ---------------------------------------            
                {
                    id=46,
                    level=1
                },
        }
        SkillsManager:getInstance()._tMainRoleSkillsLevels.pasvSkills = 
        {
            ------------------------------- 刺客相关被动技能 ---------------------------------------
        }
    end
    -- 进入战斗
    LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER, args)
end

---------------------------------------------------------------------------------------------------------------------------------------

local StoryLayer = class("StoryLayer",function()
    return require("Layer"):create()
end)
function StoryLayer:ctor()
    self._strName = "StoryLayer"          -- 层名称
    self._pTouchListener = nil            -- 触摸监听器
    self._pBg = nil                       -- 大背景
    self._pNameLbllbl = nil
    self._pVideoPlayer = nil              -- 视频对象
end

-- 创建函数
function StoryLayer:create(operateType)
    local layer = StoryLayer.new()
    layer:dispose(operateType)
    return layer
end

-- 处理函数
function StoryLayer:dispose()

    -- 初始化BG
    self:initBG()

    -- 初始化触摸
    self:initTouches()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "enter" then
            self:initVideo()   -- 初始化视频播放
        elseif event == "exit" then
            self:onExitStoryLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function StoryLayer:onExitStoryLayer()    
    self:onExitLayer()

end

-- 循环更新
function StoryLayer:update(dt)
    if self._pVideoPlayer then
        if mmo.HelpFunc:isNeedToRestartVideo() == true then
            mmo.HelpFunc:setNeedToRestartVideo(false)
            self._pVideoPlayer:removeFromParent(true)
            self._pVideoPlayer = nil
            self:createVideo()
        end
        
    end
end


-- 初始化视频播放
function StoryLayer:initVideo()
    -- 如果是移动平台，则需要进行视频播放
    if isMobilePlatform() == true and bSkipGuideCGMove == false then
        -- mask
        local pMask = cc.LayerColor:create(cc.c4b(0,0,0,255))
        local pLoadingText = cc.Label:createWithTTF("玩命加载中，请稍后......", strCommonFontName, 40)
        pLoadingText:setTextColor(cFontWhite)
        pLoadingText:enableOutline(cFontOutline,2)
        pLoadingText:setPosition(cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2))
        pMask:addChild(pLoadingText)
        self:addChild(pMask,9999)
        local startPlayVedio = function()
            self:createVideo()
        end
        -- 渐亮
        pMask:runAction( cc.Sequence:create(cc.DelayTime:create(3.0), cc.CallFunc:create(startPlayVedio)) )
    end
    
end

-- 初始化触摸相关
function StoryLayer:initTouches()
    local posTouchBeginX = -1
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        posTouchBeginX = location.x

        return true
    end
    local function onTouchMoved(touch,event)
       
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)   
        
        print("===========================================================================")
        print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        print("===========================================================================")
        
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

end

-- 初始化BG
function StoryLayer:initBG()
    -- 登录系统背景
    self._pBg = cc.Sprite:createWithSpriteFrameName("LoginBgRes/jscj_bg.png")
    self._pBg:setPosition(mmo.VisibleRect:center())
    self:addChild(self._pBg)

    local paricle = cc.ParticleSystemQuad:create("SetEffect01.plist")
    local parent = cc.ParticleBatchNode:createWithTexture(paricle:getTexture())
    paricle:setPositionType(cc.POSITION_TYPE_GROUPED)
    parent:setScale(2)
    parent:addChild(paricle)
    parent:setPosition(self._pBg:getContentSize().width/2, self._pBg:getContentSize().height/2)
    self._pBg:addChild(parent)
    
    self._pNameLbllbl = cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pNameLbllbl:setLineHeight(20)
    self._pNameLbllbl:setAdditionalKerning(-2)
    self._pNameLbllbl:setTextColor(cc.c4b(255, 255, 255, 255))
    self._pNameLbllbl:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self._pNameLbllbl:setPositionX(self._pBg:getContentSize().width/2)
    self._pNameLbllbl:setPositionY(self._pBg:getContentSize().height/2)
    self._pNameLbllbl:setWidth(185)
    --self._pNameLbllbl:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pNameLbllbl:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pNameLbllbl:setAnchorPoint(0,1)
    self._pNameLbllbl:setString("剧情动画！！！")
    self._pBg:addChild(self._pNameLbllbl)
    
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            NewbieManager:getInstance():setPlayStoryAniOver()
            enterBattle()   -- 准备进入战斗
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    self._pGoBtn = nil
    self._pGoBtn = ccui.Button:create(
        "ccsComRes/common001.png",
        "ccsComRes/common002.png",
        "ccsComRes/common001.png",
        ccui.TextureResType.plistType)
    self._pGoBtn:setTouchEnabled(true)
    self._pGoBtn:setPosition(220,50)
    self._pGoBtn:setAnchorPoint(cc.p(0, 0))
    self._pGoBtn:setZoomScale(nButtonZoomScale)
    self._pGoBtn:setPressedActionEnabled(true)
    --self._pScrollItemsView:addChild(self._pBuyCellBtn)
    self._pGoBtn:addTouchEventListener(onTouchButton)
    self._pGoBtn:setVisible(true)
    self._pGoBtn:setTitleText("跳过动画")
    self._pGoBtn:setTitleFontSize(24)
    self._pGoBtn:setTitleFontName(strCommonFontName)
    --self._pGoBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    local  onTouchSkipButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            NewbieManager:getInstance():setPlayStoryAniOver()
            NewbieManager:getInstance():setSkipStory()
            LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    self._pSkipBtn = nil
    self._pSkipBtn = ccui.Button:create(
        "ccsComRes/common001.png",
        "ccsComRes/common002.png",
        "ccsComRes/common001.png",
        ccui.TextureResType.plistType)
    self._pSkipBtn:setTouchEnabled(true)
    self._pSkipBtn:setPosition(220,250)
    self._pSkipBtn:setAnchorPoint(cc.p(0, 0))
    self._pSkipBtn:setZoomScale(nButtonZoomScale)
    self._pSkipBtn:setPressedActionEnabled(true)
    --self._pScrollItemsView:addChild(self._pBuyCellBtn)
    self._pSkipBtn:addTouchEventListener(onTouchSkipButton)
    self._pSkipBtn:setVisible(true)
    self._pSkipBtn:setTitleText("跳过引导")
    self._pSkipBtn:setTitleFontSize(24)
    self._pSkipBtn:setTitleFontName(strCommonFontName)
    --self._pSkipBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    self._pBg:addChild(self._pGoBtn)
    self._pBg:addChild(self._pSkipBtn)
    
    -- 查询任务列表
    if TasksManager:getInstance()._bGetInitData == false then
        TaskCGMessage:sendMessageQueryTasks21700()
    end
end

-- 显示（带动画）
function StoryLayer:showWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:setVisible(true)
    self:stopAllActions()

    local pPreposMask = cc.Layer:create()
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)

    local showOver = function()
        self:doWhenShowOver()
        if self._pTouchListener ~= nil then
            self._pTouchListener:setEnabled(true)
        end
        pPreposMask:removeFromParent(true)
    end
    pPreposMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(showOver)))
    return
end


-- 关闭（带动画）
function StoryLayer:closeWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:stopAllActions()

    local closeOver = function()
        self:doWhenCloseOver()
        self:removeFromParent(true)
    end
    local pPreposMask = cc.Layer:create()
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)
    pPreposMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(closeOver)))

    return
end

-- 显示结束时的回调
function StoryLayer:doWhenShowOver()    
    return
end

-- 关闭结束时的回调
function StoryLayer:doWhenCloseOver()
    --LayerManager:getInstance():transformToLoading()
end

-- 创建并播放视频
function StoryLayer:createVideo()
    if self._pVideoPlayer == nil then
        self._pVideoPlayer = ccexp.VideoPlayer:create()
        self._pVideoPlayer:setPosition(cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2))
        self._pVideoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
        self._pVideoPlayer:setContentSize(cc.size(mmo.VisibleRect:width(),mmo.VisibleRect:height()))
        self._pVideoPlayer:setFullScreenEnabled(true)
        self:addChild(self._pVideoPlayer)
        self._pVideoPlayer:setFileName("res/mp4/StoryMovie.mp4")
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
        elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
            self._pVideoPlayer:removeFromParent(true)
            self._pVideoPlayer = nil
            mmo.HelpFunc:setIsPlayingVideo(false)
            -- 动画结束(需要延时调用，因为ios8.4以后的版本在设备黑屏回来时需要断线重连，需要给断线重连一定的时间)
            local timeUp = function()
                NewbieManager:getInstance():setPlayStoryAniOver()
                enterBattle()   -- 准备进入战斗
            end
            self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(timeUp)))

        end
    end
    self._pVideoPlayer:addEventListener(onVideoEventCallback)
end

return StoryLayer
