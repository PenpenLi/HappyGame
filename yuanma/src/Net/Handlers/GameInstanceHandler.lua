--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GameInstanceHandler.lua
-- author:    liyuhang
-- created:   2015/2/6
-- descrip:   登录相关网络handler
--===================================================
local GameInstanceHandler = class("GameInstanceHandler")

-- 构造函数
function GameInstanceHandler:ctor()     
    -- 获取游戏副本列表
    NetHandlersManager:registHandler(21001, self.handleMsgQueryBattleList)
    -- 请求进入副本战斗
    NetHandlersManager:registHandler(21003, self.handleMsgEntryBattle)
    -- 上传战斗结果
    NetHandlersManager:registHandler(21005, self.handleMsgUploadBattleResult)
    -- 上传选卡结果
    NetHandlersManager:registHandler(21007, self.handleMsgPickCard)
    -- 获取剧情副本
    NetHandlersManager:registHandler(21009, self.handleMsgQueryStoryBattleList21009)
    -- 领取宝箱结果
    NetHandlersManager:registHandler(21011, self.handleMsgDrawStoryBox21011)
    -- 获取剧情副本回复
    NetHandlersManager:registHandler(21013, self.handleQueryTowerBattleList21013)
    --获取翻卡数据恢复
    NetHandlersManager:registHandler(21017, self.handleQueryPickCardState21017)
    --获取关卡状态
    NetHandlersManager:registHandler(21019, self.handleQueryBattleInfo21019)
    
end

-- 创建函数
function GameInstanceHandler:create()
    print("GameInstanceHandler create")
    local handler = GameInstanceHandler.new()
    return handler
end

-- 请求游戏副本列表
function GameInstanceHandler:handleMsgQueryBattleList(msg)
    print("GameInstanceHandler 21001")
    if msg.header.result == 0 then 
        DialogManager:getInstance():showDialog("CopysDialog",{msg["body"].argsBody.copyTypes,3})
        
        local event = {battleExts = msg["body"].battleExts}
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryBattleList, event)
        
        if TasksManager:getInstance()._bNeedScroll == true then
            NetRespManager:getInstance():dispatchEvent(kNetCmd.kGameCopysScroll,{id = TasksManager:getInstance()._nScrollCopyId})
            TasksManager:getInstance():setAutoScrollOver()
        end
        
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 请求进入副本战斗
function GameInstanceHandler:handleMsgEntryBattle(msg)
    print("GameInstanceHandler 21003")
    if msg.header.result == 0 then 
       local event = msg["body"]
       NetRespManager:getInstance():dispatchEvent(kNetCmd.kEntryBattle, event)
       
       NewbieManager:showOutAndRemoveWithRunTime()
       
       RolesManager._pMainRoleInfo.strength = event.strength
       NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, event)
          -- 测试代码
          --MessageGameInstance:sendMessageUploadBattleResult21004(1, {monsters = {{id = 1,count = 1000},{id = 2,count = 1000},{id = 3,count = 1000}}}) 
        if msg["body"].cheerTime ~= 0 then
            FriendManager:setFriendHelpCheerTime(msg["body"].cheerTime,msg["body"].argsBody.friendId) 	
        end
      if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
            BattleManager:getInstance():entryTowerBattleCopy()
      end
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

-- 上传战斗结果数据
function GameInstanceHandler:handleMsgUploadBattleResult(msg)
    print("GameInstanceHandler 21005")
    if msg.header.result == 0 then 
        BattleManager:getInstance():uploadBattleResult(msg)
    else
        print("返回错误码："..msg.header.result)
        --LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
    end
end

-- 上传选卡结果
function GameInstanceHandler:handleMsgPickCard(msg)
    print("GameInstanceHandler 21007")
    if msg.header.result == 0 then 
        local event = msg["body"].cardInfo
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kPickCard, event)
        
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 获取剧情副本回复
function GameInstanceHandler:handleMsgQueryStoryBattleList21009(msg)
    print("GameInstanceHandler 21009")
    if msg.header.result == 0 then 
        TasksManager:getInstance():setStoryCopyInfo(msg["body"].stories)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryStory,msg["body"])
        
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 领取宝箱回复
function GameInstanceHandler:handleMsgDrawStoryBox21011(msg)
    print("GameInstanceHandler 21011")
    if msg.header.result == 0 then 
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kDrawStoryBox,msg["body"].argsBody)
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

function GameInstanceHandler:handleQueryTowerBattleList21013(msg)
    print("GameInstanceHandler 21013")
    if msg.header.result == 0 then 
        local event = msg["body"]
        DialogManager:getInstance():showDialog("TowerCopyDialog",{event.towerInfo,event.identity})
    else
        print("返回错误码："..msg.header.result)
    end
end

function GameInstanceHandler:handleQueryPickCardState21017(msg)
    print("GameInstanceHandler 21017")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kPickCardState,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

function GameInstanceHandler:handleQueryBattleInfo21019(msg)
    print("GameInstanceHandler 21019")
    if msg.header.result == 0 then 
        local event = msg["body"]
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kItemSourceGo,event)
    else
        print("返回错误码："..msg.header.result)
    end
end


return GameInstanceHandler