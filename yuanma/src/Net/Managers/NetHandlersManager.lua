--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NetHandlersManager.lua
-- author:    liyuhang
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   网络Handler管理器
--===================================================

NetHandlersManager = {}

local instance = nil

-- 单例
function NetHandlersManager:getInstance()
    if not instance then
        instance = NetHandlersManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function NetHandlersManager:clearCache()
    self._handlerMap = {}            -- 网络消息注册分发
end

-- 注册网络事件监听
function NetHandlersManager:registNetHandlers()
    -- 注册登录handler
    require("LoginHandler"):create()    
    -- 注册背包handler
    require("BagCommonHandler"):create()
    -- 注册装备handler
    require("EquipmentHandler"):create()
    -- 注册金融handler
    require("FinanceNoticeHandler"):create()
    -- 注册宝石handler
    require("GemSystemHandler"):create()
    -- 注册境界handler
    require("FairyLandHandler"):create()
    -- 注册商城Handler
    require("ShopSystemHandler"):create()
    -- 注册剑灵Handler
    require("BladeSoulHandler"):create()
    -- 注册副本Handler
    require("GameInstanceHandler"):create()
    -- 注册群芳阁Handler
    require("BeautyClubHandler"):create()
    -- 注册心跳Handler
    require("HeartBeatHandler"):create()
    -- SkillHandler
    require("SkillHandler"):create()
    -- PetHandler
    require("PetHandler"):create()
    -- 任务Handler
    require("TaskHandler"):create()
    -- 好友Handler
    require("FriendHandler"):create()
    -- notice 通知Handler
    require("NoticeCommonHandler"):create()
    -- 注册竞技场Handler
    require("ArenaHandler"):create()
    --注册跑马灯的Handler
    require("DisPlayNoticeHandler"):create()
    --注册午夜惊魂的Handler
    require("NightHandler"):create()
    --注册华山论剑的Handler
    require("HuaShanHandler"):create()
    --注册buff的Handler
    require("BuffHandler"):create()
    -- 注册邮箱的Handler
    require("EmailHandler"):create()
    -- 注册宝箱的Handler
    require("OpenItemHandler"):create()
    -- 注册复活的Handler
    require("ReviveHandler"):create()
    -- 注册聊天的Handler
    require("ChatHandler"):create()
    -- 注册新手的Handler
    require("NewbieHandler"):create()
    -- 注册酒馆的handler
    require("DrunkeryHandler"):create()
    -- 注册家族的Handler
    require("FamilyHandler"):create()
    -- 注册其他玩家信息的Handler
    require("OtherPlayersHandler"):create()
    -- 注册藏经阁Handler
    require("SturaLibraryHandler"):create()
    -- 注册活动的Handler
    require("ActivityHandler"):create()
end

-- 执行监听回调
function NetHandlersManager:executeHandler(msgName)
    local Messagetable = _G[msgName]
    if Messagetable ~= nil then
        print("----- 收到回复："..Messagetable["header"].cmdNum.."，第["..msgName.."]条 -----" .. "result is " .. Messagetable["header"].result)
        --print_lua_table(Messagetable,0)
        local handle = self._handlerMap[Messagetable["header"].cmdNum]
        handle(handle,Messagetable)
    end
    _G[msgName] = nil
end

-- 注册网络事件监听
function NetHandlersManager:registHandler(msgNum,handle)
    print("----- 注册协议监听："..msgNum.." ----- OK -----")
    self._handlerMap[msgNum] = handle
end
