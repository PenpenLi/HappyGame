--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OperateBattleCopy.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/8
-- descrip:   显示战斗副本界面操作（用于任务中的操作队列）
--===================================================
local OperateBattleCopy = class("OperateBattleCopy", function()
	return require("Operate"):create()
end)

-- 构造函数
function OperateBattleCopy:ctor()
    self._strName = "OperateBattleCopy"       -- 操作名称
    self._kBattleCopyType = kType.kCopy.kNone -- 战斗副本类型
    self._pParams = nil                       -- 要跳转到的战斗关卡参数信息
    
end

-- 创建函数
function OperateBattleCopy:create(args)
    local op = OperateBattleCopy.new()
    op:dispose(args)
    return op
end

-- 初始化处理
function OperateBattleCopy:dispose(args)
    self._kBattleCopyType = args.copyType
    self._pParams = args.params
    
end

-- 开始
function OperateBattleCopy:onEnter()
    self:onBaseEnter()
    
    if self._kBattleCopyType == kType.kCopy.kGold then  -- 金钱副本
        MessageGameInstance:sendMessageQueryBattleList21000({kType.kCopy.kGold,kType.kCopy.kStuff})
        
        if self._pParams ~= nil and self._pParams[2] ~= nil then
            TasksManager:getInstance():setAutoScrollById( self._pParams[2])
        end
        
    elseif self._kBattleCopyType == kType.kCopy.kStuff then -- 材料副本
        MessageGameInstance:sendMessageQueryBattleList21000({kType.kCopy.kGold,kType.kCopy.kStuff})
        
        if self._pParams ~= nil and self._pParams[2] ~= nil then
            TasksManager:getInstance():setAutoScrollById( self._pParams[2])
        end
    elseif self._kBattleCopyType == kType.kCopy.kMaze then  -- 迷宫副本
        DialogManager:getInstance():showDialog("CopysPortalDialog")
        MessageGameInstance:sendMessageQueryBattleList21000({kType.kCopy.kMaze})

        if self._pParams ~= nil and self._pParams[2] ~= nil then
            TasksManager:getInstance():setAutoScrollById( self._pParams[2])
        end
    elseif self._kBattleCopyType == kType.kCopy.kChallenge then -- 挑战副本
        DialogManager:getInstance():showDialog("CopysPortalDialog")
        MessageGameInstance:sendMessageQueryBattleList21000({kType.kCopy.kChallenge})
        
        if self._pParams ~= nil and self._pParams[2] ~= nil then
            TasksManager:getInstance():setAutoScrollById( self._pParams[2])
        end
    elseif self._kBattleCopyType == kType.kCopy.kTower then -- 爬塔副本
        DialogManager:getInstance():showDialog("CopysPortalDialog")
        MessageGameInstance:sendMessageQueryTowerBattleList21012()
        
    elseif self._kBattleCopyType == kType.kCopy.kMapBoss then   -- 地图boss副本
        DialogManager:getInstance():showDialog("CopysPortalDialog")
        MessageGameInstance:sendMessageQueryTowerBattleList21012()
        
    elseif self._kBattleCopyType == kType.kCopy.kMidNight then  -- 午夜惊魂副本
    
    elseif self._kBattleCopyType == kType.kCopy.kPVP then   -- PVP排行榜副本
        ArenaCGMessage:queryArenaInfoReq21600()
        
    elseif self._kBattleCopyType == kType.kCopy.kHuaShan then   -- 华山论剑副本
    
    elseif self._kBattleCopyType == kType.kCopy.kStory then -- 剧情副本
        if self._pParams[1] ~= -1 and self._pParams[2] ~= -1 then
            DialogManager:getInstance():showDialog("StoryCopyDialog",{self._pParams[1], self._pParams[2]})
        else
            DialogManager:getInstance():showDialog("StoryCopyDialog")
        end
    elseif self._kBattleCopyType == kType.kCopy.kTeamAIFight then -- 组队（AI版）副本

    end
    
    self._bIsOver = true    -- 结束
    
    return
end

-- 结束
function OperateBattleCopy:onExit()
    self:onBaseExit()
    
    return
end

-- 循环更新
function OperateBattleCopy:onUpdate(dt)
    self:onBaseUpdate(dt)
    
    
    return
end

-- 复位
function OperateBattleCopy:reset()
    self:baseReset()
    
    return
end

-- 检测结束标记
function OperateBattleCopy:checkOver(dt)
    if self._bIsOver == true then
        self:onExit()
    end
    return
end

return OperateBattleCopy
