--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  LayerManager.lua
-- author:    liyuhang
-- created:   2015/1/26
-- descrip:   layer管理器，主要负责操作场景layer
--===================================================
LayerManager = {}

---------------------场景layer------------------------
---- session类型 ， 是否显示进度界面
LOGIN_SENCE_LAYER   = {kSession.kLogin  ,false}
WORLD_SENCE_LAYER   = {kSession.kWorld  ,true }
BATTLE_SENCE_LAYER  = {kSession.kBattle ,true }
GUIDE_SENCE_LAYER   = {kSession.kGuide ,true }
SELECTROLE_SENCE_LYAER = {kSession.kSelect, true}
------------------------------------------------------

-- 单例
function LayerManager:getInstance()
    if not instance then
        instance = LayerManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function LayerManager:clearCache()
    self._pAppSence = nil                         -- 游戏scene
    self._kRunningSenseLayerType = nil            -- 待切换的目标session相关信息
    self._tArgs = {}                              -- 传递参数
end

-- 设置root场景
function LayerManager:setRootSence( root )
    self._pAppSence = root
end

-- 获取当前场景layer的sessionid
function LayerManager:getCurSenceLayerSessionId()
    if self._pAppSence then
        return self._pAppSence._kCurSessionKind
    end
    return kSession.kNone
end

-- 切换场景（设置切换场景时的信息）
function LayerManager:gotoRunningSenceLayer(targetSenceLayerDef,args,debug)
    self._kRunningSenseLayerType = targetSenceLayerDef
    if args ~= nil then
        self._tArgs = args
    end
    if debug ~= true then
        if self._pAppSence:getLayerByName("LoadingLayer") == nil then 
            self._pAppSence:showLayer(require("LoadingLayer"):create(self._kRunningSenseLayerType[1], self._kRunningSenseLayerType[2], self._tArgs), kZorder.kTransitionLayer)
        end
    end

end

-- 释放对话框和层
function LayerManager:releaseLayersAndDialogs()
	    -- 切换到对应会话类型
    if self._pAppSence._kCurSessionKind == kSession.kLogin then
        self._pAppSence:closeLayerByNameWithNoAni("StoryLayer")
        self._pAppSence:closeLayerByNameWithNoAni("RoleCreateLayer")
        self._pAppSence:closeLayerByNameWithNoAni("RoleSelectLayer")
        self._pAppSence:closeLayerByNameWithNoAni("RoleLayer")
        self._pAppSence:closeLayerByNameWithNoAni("LoginLayer")
        self._pAppSence:closeLayerByNameWithNoAni("NoticeLayer")
        self._pAppSence:closeAllDialogsWithNoAni()
    elseif self._pAppSence._kCurSessionKind == kSession.kWorld then
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:aaa_111")
        self._pAppSence:closeLayerByNameWithNoAni("NoticeLayer")
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:aaa_222")
        self._pAppSence:closeLayerByNameWithNoAni("WorldUILayer")
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:aaa_333")
        self._pAppSence:closeLayerByNameWithNoAni("WorldLayer")
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:aaa_444")
        self._pAppSence:closeAllDialogsWithNoAni()
        self:clearManagerCache()        -- 清空管理器缓存
    elseif self._pAppSence._kCurSessionKind == kSession.kBattle then
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:444_111")
        self._pAppSence:closeLayerByNameWithNoAni("NoticeLayer")
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:444_222")
        self._pAppSence:closeLayerByNameWithNoAni("BattleUILayer")
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:444_333")
        self._pAppSence:closeLayerByNameWithNoAni("BattleLayer")
        -- mmo.DebugHelper:showJavaLog("mmo:LoadingLayer:444_444")
        self._pAppSence:closeAllDialogsWithNoAni()
        self:clearManagerCache()        -- 清空管理器缓存
    elseif self._pAppSence._kCurSessionKind == kSession.kGuide then
        self._pAppSence:closeLayerByNameWithNoAni("StoryLayer")
        self._pAppSence:closeAllDialogsWithNoAni()
    elseif self._pAppSence._kCurSessionKind == kSession.kSelect then
        self._pAppSence:closeLayerByNameWithNoAni("StoryLayer")
        self._pAppSence:closeLayerByNameWithNoAni("RoleCreateLayer")
        self._pAppSence:closeLayerByNameWithNoAni("RoleSelectLayer")
        self._pAppSence:closeLayerByNameWithNoAni("RoleLayer")
        self._pAppSence:closeLayerByNameWithNoAni("LoginLayer")
        self._pAppSence:closeAllDialogsWithNoAni()
    end
    self._pAppSence._kCurSessionKind = self._kRunningSenseLayerType[1]
    self._kRunningSenseLayerType = nil
    self._tArgs = {}
    
end

-- 清空数据缓存
function LayerManager:clearManagerCache()
    MapManager:getInstance():clearCache()
    RectsManager:getInstance():clearCache()
    TriggersManager:getInstance():clearCache()
    RolesManager:getInstance():clearCache()
    PetsManager:getInstance():clearCache()
    MonstersManager:getInstance():clearCache()
    EntitysManager:getInstance():clearCache()
    SkillsManager:getInstance():clearCache()
    BattleManager:getInstance():clearCache()
    AIManager:getInstance():clearCache()
    StagesManager:getInstance():clearCache()
    TalksManager:getInstance():clearCache()
end

-- 由loading的doWhenCloseOver调用，切换到目标session
function LayerManager:transforToTargetSession()
    -- 切换到对应会话类型
    if self._pAppSence._kCurSessionKind == kSession.kLogin then
        mmo.HelpFunc:setMaxTouchesNum(1)
        self._pAppSence:showLayer(require("LoginLayer"):create())
        AudioManager:getInstance():playMusic("LoginBackGround", true) -- 背景音乐
        self._pAppSence:showLayer(require("NoticeLayer"):create(),kZorder.kSystemMessageLayer)
    elseif self._pAppSence._kCurSessionKind == kSession.kWorld then
        mmo.HelpFunc:setMaxTouchesNum(1)
        self._pAppSence:showLayer(require("WorldLayer"):create())
        self._pAppSence:showLayer(require("WorldUILayer"):create(),kZorder.kMainUiLayer)
        self._pAppSence:showLayer(require("NoticeLayer"):create(),kZorder.kSystemMessageLayer)
        AudioManager:getInstance():playMusic("WorldBackGround", true) -- 背景音乐
    elseif self._pAppSence._kCurSessionKind == kSession.kBattle then
        mmo.HelpFunc:setMaxTouchesNum(2)
        self._pAppSence:showLayer(require("BattleLayer"):create())
        self._pAppSence:showLayer(require("BattleUILayer"):create(),kZorder.kMainUiLayer)
        self._pAppSence:showLayer(require("NoticeLayer"):create(),kZorder.kSystemMessageLayer)
        AudioManager:getInstance():playMusic("BattleBackGround", true) -- 背景音乐
    elseif self._pAppSence._kCurSessionKind == kSession.kGuide then
        mmo.HelpFunc:setMaxTouchesNum(1)
        self._pAppSence:showLayer(require("StoryLayer"):create())
        AudioManager:getInstance():stopMusic()
    elseif self._pAppSence._kCurSessionKind == kSession.kSelect then
        mmo.HelpFunc:setMaxTouchesNum(1)
        self._pAppSence:showLayer(require("RoleLayer"):create(1))
        self._pAppSence:showLayer(require("RoleSelectLayer"):create())
    end
end


