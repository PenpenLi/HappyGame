--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TriggersManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   触发器管理器
--===================================================
TriggersManager = {}

local instance = nil

-- 单例
function TriggersManager:getInstance()
    if not instance then
        instance = TriggersManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function TriggersManager:clearCache()
    self._pDebugLayer = nil         -- 矩形调试层
    self._tTriggers = {}            -- 触发器集合{第1组触发器，第2组触发器，......}
    self._tTriggersByID = {}        -- 下标由触发器ID标识的触发器{[1] = ...，[5] = ..., ......}
    self._tTriggersRects = {}       -- 所有触发器矩形的集合，按照地图区域存储，其中每一个区域为{{["ID"] = 1,["rect"] = ...},...}
    for i = 1, (nMapAreaRowNum * nMapAreaColNum) do
        table.insert(self._tTriggersRects,{})
    end
    self._pHelper = mmo.TriggersHelper:getInst()
    self._pHelper:clearCache(nMapAreaRowNum, nMapAreaColNum) -- 清空c++中的缓存
    
end

-- 循环处理
function TriggersManager:update(dt)    
    for k,v in pairs(self._tTriggers) do
        v:update(dt)
    end
    
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

-- 创建触发器到地图
function TriggersManager:createTriggersOnMap(bDebug)
    local pTmxMap = MapManager:getInstance()._pTmxMap
    local pTriggersLayer = pTmxMap:getObjectGroup("TriggersLayer")
    
    -- 先确定triggerRects的结构,[]中是地图中配置好的trigger的数据表id号
    local triggerRects = {}  -- { [1] = {rect1,rect2,rect3......}, [5] = {rect1,rect2, rect3......}, ......}
    do
        local indexFirst = 1
        local indexSecond = 1
        local name = indexFirst.."_"..indexSecond
        local obj = pTriggersLayer:getObject(name)
        while obj ~= nil and obj["x"] ~= nil do
            triggerRects[tonumber(obj["ID"])] = {}
            indexFirst = indexFirst + 1
            name = indexFirst.."_"..indexSecond
            obj = pTriggersLayer:getObject(name)
        end
    end
    
    
    -- 获取触发器矩形集合（按照地图区域划分的形式存放）
    local triggerObj = pTriggersLayer:getObjects()
    for k,v in pairs(triggerObj) do
        -- 给矩形分区
        local rect = cc.rect(v.x, v.y, v.width, v.height)
        local triggerId = tonumber(v["ID"])
        table.insert(triggerRects[triggerId],rect)

        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rect.x, rect.y))
        if index1 ~= 0 then
            table.insert(self._tTriggersRects[index1],{["ID"] = triggerId, ["rect"] = rect})
            self._pHelper:insertTriggerRect(index1, rect)
        end

        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rect.x + rect.width, rect.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(self._tTriggersRects[index2],{["ID"] = triggerId, ["rect"] = rect})
            self._pHelper:insertTriggerRect(index2, rect)
        end

        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rect.x, rect.y + rect.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(self._tTriggersRects[index3],{["ID"] = triggerId, ["rect"] = rect})
            self._pHelper:insertTriggerRect(index3, rect)
        end

        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rect.x + rect.width, rect.y + rect.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(self._tTriggersRects[index4],{["ID"] = triggerId, ["rect"] = rect})
            self._pHelper:insertTriggerRect(index4, rect)
        end
        
    end
    
    -- 获取地图上的trigger对象 
    local indexFirst = 1
    local indexSecond = 1
    local name = indexFirst.."_"..indexSecond
    local obj = pTriggersLayer:getObject(name)
    while obj ~= nil and obj["x"] ~= nil do
        -- 创建触发器
        local info = TableTriggers[tonumber(obj["ID"])]
        self:createTrigger(info, triggerRects[tonumber(obj["ID"])])
        
        indexFirst = indexFirst + 1
        name = indexFirst.."_"..indexSecond
        obj = pTriggersLayer:getObject(name)
    end
    
    if bDebug == true then
        self._pDebugLayer = require("TriggersDebugLayer"):create()
        MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kTriggerDebugLayer)
    end

end

-- 创建触发器（根据矩形信息和table格式的触发器信息）
function TriggersManager:createTrigger(tInfo, rects)
    local pTrigger = require("Trigger"):create()
    pTrigger._nID = table.getn(self._tTriggers) + 1
    pTrigger._tRects = rects
    if tInfo.IsRuntimeCheck == 1 then
        pTrigger._bRuntimeCheck = true
    elseif tInfo.IsRuntimeCheck == 2 then
        pTrigger._bRuntimeCheck = false
    end
    pTrigger._strName = tInfo.Name

    local params = tInfo.Params
    local index = 1
    while index <= table.getn(params) do
        local type = params[index][1]
        local item = nil    -- 触发器动作项
        if type == kType.kTriggerItemType.kDelay then
            local delay = params[index][2]
            item = require("DelayTriggerItem"):create(index, delay)
        elseif type == kType.kTriggerItemType.kCamera then
            local col = params[index][2]
            local row = params[index][3]
            local pos = cc.p(0,0)
            if ((col == -1) and (row == -1)) then  -- 说明是镜头回到玩家的位置
                pos = cc.p(-1,-1)
            else
                pos = MapManager:getInstance():convertIndexToPiexl(cc.p(col, row))
            end
            local moveDuration = params[index][4]
            local scale = params[index][5]
            local scaleDuration = params[index][6]
            local resumeFollowAfterAction = params[index][7]
            local order = params[index][8]
            local posScaleCenter = nil
            if order == 2 or order == 4 then
                -- posScaleCenter可选，在镜头先scale的时候，此项有效
                local x,y = params[index][9], params[index][10]
                if x == -1 and y == -1 then
                    posScaleCenter = cc.p(-1,-1)-- 说明是玩家的位置为scale的中心点
                else
                    posScaleCenter = MapManager:getInstance():convertIndexToPiexl(cc.p(x,y))
                end
            end
            item = require("CameraTriggerItem"):create(index, pos, moveDuration, scale, scaleDuration, resumeFollowAfterAction, order, posScaleCenter)
        elseif type == kType.kTriggerItemType.kDoor then
            local doorEntityID = params[index][2]
            local nextMapDoorIDofEntity = params[index][3]
            local sendDelay = params[index][4]
            local mapIds = params[index][5]
            item = require("DoorTriggerItem"):create(index, doorEntityID, nextMapDoorIDofEntity, sendDelay, mapIds)
            -- 将传送门挂载到对应实体上，即触发器的宿主（传送门）
            local door = EntitysManager:getInstance():getEntityByID(doorEntityID)
            door._pTrigger = pTrigger
            pTrigger._bIsVisibleOnDebug = door:isVisible()     -- 默认传送门的触发器调试信息为不可见，随着door实体可见性的变化而变化
        elseif type == kType.kTriggerItemType.kMonsterArea then
            local monsterAreaIndex = params[index][2]
            item = require("MonsterAreaTriggerItem"):create(index, monsterAreaIndex)
        elseif type == kType.kTriggerItemType.kDialog then
            local dialogName = params[index][2]
            item = require("DialogTriggerItem"):create(index, dialogName)
        elseif type == kType.kTriggerItemType.kTalks then
            local talksID = params[index][2]
            item = require("TalksTriggerItem"):create(index, talksID)
        end

        item._pOwnerTrigger = pTrigger   -- 记录持有者（即Trigger）
        table.insert(pTrigger._tTriggerItems, item)
        index = index + 1
    end

    -- 添加到集合
    table.insert(self._tTriggers, pTrigger)
    self._tTriggersByID[tInfo.ID] = pTrigger

    return pTrigger
end

-- 循环处理
function TriggersManager:refreshDebugLayer()
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:show()
    end
end
