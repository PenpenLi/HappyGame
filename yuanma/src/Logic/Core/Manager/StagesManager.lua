--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StagesManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/24
-- descrip:   关卡管理器
--===================================================
StagesManager = {}

local instance = nil

-- 单例
function StagesManager:getInstance()
    if not instance then
        instance = StagesManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function StagesManager:clearCache()
    self._nCurCopyType = kType.kCopy.kNone                  -- 当前关卡的副本类型
    self._nCurStageID = 0                                   -- 当前关卡在数据表中的关卡ID项
    self._nCurStageMapID = 0                                -- 当前关卡在地图表中的地图ID项
    self._tCopysMapTable =                                  -- 所有副本地图表
    {
        [kType.kCopy.kGold] = TableGoldCopysMaps,           -- 金钱副本地图表
        [kType.kCopy.kStuff] = TableStuffCopysMaps,         -- 材料副本地图表
        [kType.kCopy.kMaze] = TableMazeCopysMaps,           -- 迷宫副本地图表
        [kType.kCopy.kChallenge] = TableChallengeCopysMaps, -- 挑战副本地图表
        [kType.kCopy.kTower] = TableTowerCopysMaps,         -- 爬塔副本地图表
        [kType.kCopy.kMapBoss] = TableMapBossCopysMaps,     -- 地图boss副本地图表
        [kType.kCopy.kMidNight] = TableMidNightCopysMaps,   -- 午夜惊魂副本地图表
        [kType.kCopy.kPVP] = TablePVPCopysMaps,             -- 排行榜副本地图表
        [kType.kCopy.kHuaShan] = TableHuaShanCopysMaps,     -- 华山论剑副本地图表
        [kType.kCopy.kStory] = TableStoryCopysMaps,         -- 剧情副本地图表
    }
    self._tCopysDataTable =                                 -- 所有副本数据表
    {
        [kType.kCopy.kGold] = TableGoldCopys,               -- 金钱副本数据表
        [kType.kCopy.kStuff] = TableStuffCopys,             -- 材料副本数据表
        [kType.kCopy.kMaze] = TableMazeCopys,               -- 迷宫副本数据表
        [kType.kCopy.kChallenge] = TableChallengeCopys,     -- 挑战副本数据表
        [kType.kCopy.kTower] = TableTowerCopys,             -- 爬塔副本数据表
        [kType.kCopy.kMapBoss] = TableMapBossCopys,         -- 地图boss副本数据表
        [kType.kCopy.kMidNight] = TableMidNightCopys,       -- 午夜惊魂副本数;据表
--        [kType.kCopy.kPVP] = TablePVPCopys,             -- 排行榜副本数据表
--     [kType.kCopy.kHuaShan] = TableHuaShanCopys,          -- 华山论剑副本数据表
       [kType.kCopy.kStory] = TableStoryCopys,              -- 剧情副本数据表
    }
    self._nBattleId = 0                                     -- 当前副本中的服务器关卡编号（与服务器通信）
    self._nIdentity = 0                                     -- 副本标示id，用于做验证 
    
end

-- 循环处理
function StagesManager:update(dt)
    -- 战斗结果已经得出，则不再做任何战斗逻辑表现
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    
    
end

-- 获取当前关卡的数据信息
function StagesManager:getCurStageDataInfo()
    local tOffect =   {
        [kType.kCopy.kGold] = 0,                    -- 金钱副本数据表
        [kType.kCopy.kStuff] = 100,                 -- 材料副本数据表
        [kType.kCopy.kMaze] = 300,                  -- 迷宫副本数据表
        [kType.kCopy.kChallenge] = 400,             -- 挑战副本数据表
        [kType.kCopy.kTower] = 500,                 -- 爬塔副本数据表
        [kType.kCopy.kMapBoss] = 600,               -- 地图boss副本数据表
        --     [kType.kCopy.kMidNight] = TableMidNightCopys,   -- 午夜惊魂副本数据表
        --     [kType.kCopy.kPVP] = TablePVPCopys,             -- 排行榜副本数据表
        --     [kType.kCopy.kHuaShan] = TableHuaShanCopys,     -- 华山论剑副本数据表
        [kType.kCopy.kStory] = 10000,               -- 剧情副本数据表
    }
    return self._tCopysDataTable[self._nCurCopyType][self._nCurStageID-tOffect[self._nCurCopyType]]
end

-- 获取当前关卡的地图信息
function StagesManager:getCurStageMapInfo()
    return self._tCopysMapTable[self._nCurCopyType][self._nCurStageMapID]
end

-- 获取指定类型副本的指定地图id的信息
function StagesManager:getStageMapInfoByCopyTypeAndMapID(copyType, mapID)
    return self._tCopysMapTable[copyType][mapID]
end

-- 获取指定副本的数据信息（所有关卡）
function StagesManager:getCopyDataInfo(copyType)
    return self._tCopysDataTable[copyType]
end

-- 获取指定副本的地图信息（所有关卡）
function StagesManager:getCopyMapInfo(copyType)
    return self._tCopysMapTable[copyType]
end

