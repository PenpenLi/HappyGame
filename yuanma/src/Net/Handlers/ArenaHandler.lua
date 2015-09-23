--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ArenaHandler.lua
-- author:    wuqd
-- created:   2015/04/23
-- descrip:   竞技场handler
--===================================================
local ArenaHandler = class("ArenaHandler")

-- 构造函数
function ArenaHandler:ctor()     
    -- 获取竞技场信息
    NetHandlersManager:registHandler(21601, self.handleMsgQueryArenaInfo)
    -- 挑战回复
    NetHandlersManager:registHandler(21603, self.handleMsgArenaFight)
    -- 上传战斗结果
    NetHandlersManager:registHandler(21605, self.handleMsgArenaFightResult)
    -- 获取排行榜回复
    NetHandlersManager:registHandler(21607,self.handleMsgArenaRank)
    -- 刷新对手回复
    NetHandlersManager:registHandler(21609,self.handleMsgRefreshEnemy)
    -- 竞技场领奖
    NetHandlersManager:registHandler(21611,self.handleMsgDrawBox)
end

-- 创建函数
function ArenaHandler:create()
    print("ArenaHandler create")
    local handler = ArenaHandler.new()
    return handler
end

-- 获取竞技场信息
function ArenaHandler:handleMsgQueryArenaInfo(msg)
    print("ArenaHandler 21601")
    if msg.header.result == 0 then 
        local event = 
            {
              pageInfo = msg["body"].pageInfo,
              roleList = msg["body"].roleList
            }
        ArenaManager:getInstance()._nCurPvpRank = msg["body"].pageInfo.rank
        DialogManager:getInstance():showDialog("ArenaDialog",event)       
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

-- 挑战请求回复
function ArenaHandler:handleMsgArenaFight(msg)
    print("ArenaHandler 21603")
    if msg.header.result == 0 then
        local event = 
        {
            -- 对手信息
            roleInfo = msg["body"].roleInfo
        }
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kFightResp,event)
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

-- 战斗结果回复
function ArenaHandler:handleMsgArenaFightResult(msg)
    print("ArenaHandler 21605")
    if msg.header.result == 0 then
        local event = 
        {
           isWin = msg["body"].argsBody.isWin,
           currRank = msg["body"].currRank,
           items = msg["body"].items,
           finances = msg["body"].finances,
        }
        DialogManager:getInstance():showDialog("ArenaFightReturnDialog",event)
    else
        print("返回错误码："..msg.header.result)
        LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
    end
end

-- 获取排行榜
function ArenaHandler:handleMsgArenaRank(msg)
    print("ArenaHandler 21607")
    if msg.header.result == 0 then
        local event = 
        {
           roleList = msg["body"].roleList
        }
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kQueryArenaRankResp,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 刷新回复
function ArenaHandler:handleMsgRefreshEnemy(msg)
    print("ArenaHandler 21609")
    if msg.header.result == 0 then
        local event = 
        {
           roleList = msg["body"].roleList
           
        }
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kRefreshEnemyResp,event)
    else
        print("返回错误码："..msg.header.result)
    end
end 

-- 竞技场领奖
function ArenaHandler:handleMsgDrawBox(msg)
    print("ArenaHandler 21611")
    if msg.header.result == 0 then
        --BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
        -- 领奖弹框
        DialogManager:getInstance():showDialog("GetItemsDialog",msg["body"].awardInfo)  
        local event = 
        {
            boxCount = msg["body"].boxCount,
            remainTime = msg["body"].remainTime,
        }
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kDrawArenaBoxResp,event)
    else
        print("返回错误码："..msg.header.result)
    end
end

return ArenaHandler