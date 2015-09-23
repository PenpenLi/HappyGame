--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EntitysManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   实体管理器
--===================================================
EntitysManager = {}

local instance = nil

-- 单例
function EntitysManager:getInstance()
    if not instance then
        instance = EntitysManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function EntitysManager:clearCache()  
    self._pDebugLayer = nil             -- 矩形调试层
    self._tEntitys = {}                 -- 实体集合(包括了所有实体)
    self._tDoors = {{},{}}              -- 传送门实体集合（按照开始时传送门集合和结束时传送门集合）
    self._tRoadBlockEntitys = {}        -- 屏障实体集合(按野怪区域划分)
    for i = 1, 20 do                    -- 暂定最多有野怪区域20个(足够)
        table.insert(self._tRoadBlockEntitys,{})
    end
    
end

-- 循环处理
function EntitysManager:update(dt)
    --如果当前正在显示新手，则立即返回
    if NewbieManager:getInstance():isShowingNewbie() == true then
        return
    end
    
    -- 遍历所有实体对象
    self:updateEntitys(dt)
    
    -- 监控路障和传送门
    self:updateRoadBlocksAndDoors(dt)
    
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

-- 创建所有实物
function EntitysManager:createEntitysOnMap(bDebug)
    local pTmxMap = MapManager:getInstance()._pTmxMap
    local pEntitysLayer = pTmxMap:getObjectGroup("EntitysLayer")
    local pBottomLayer = pTmxMap:getObjectGroup("EntitysBottomLayer")
    local pBodyLayer = pTmxMap:getObjectGroup("EntitysBodyLayer")
    local pUndefLayer = pTmxMap:getObjectGroup("EntitysUndefLayer")

    -- 获取地图上的entity对象（花草、树木、建筑、摆设等等）（包括碰撞矩形等等）
    local indexFirst = 1
    local obj = pEntitysLayer:getObject(tostring(indexFirst))
    while obj ~= nil and obj["x"] ~= nil do   -- 收集实体上的矩形集合
        local tBottoms = {}
        local tBodys = {}
        local tUndefs = {}
        local posObj = cc.p(obj["x"], obj["y"])
        
        local indexSecond = 1
        local name = indexFirst.."_"..indexSecond
        
        -- 收集所有实体bottom矩形
        local bottomObj = pBottomLayer:getObject(name)
        while bottomObj ~= nil and bottomObj["x"] ~= nil do   -- 收集实体上的矩形集合
            table.insert(tBottoms, cc.rect(bottomObj["x"], bottomObj["y"], bottomObj["width"], bottomObj["height"]))
            indexSecond = indexSecond + 1
            name = indexFirst.."_"..indexSecond
            bottomObj = pBottomLayer:getObject(name)
        end

        indexSecond = 1
        name = indexFirst.."_"..indexSecond  
        
        -- 收集所有实体body矩形
        local bodyObj = pBodyLayer:getObject(name)
        while bodyObj ~= nil and bodyObj["x"] ~= nil do   -- 收集实体上的矩形集合
            table.insert(tBodys, cc.rect(bodyObj["x"], bodyObj["y"], bodyObj["width"], bodyObj["height"]))
            indexSecond = indexSecond + 1
            name = indexFirst.."_"..indexSecond
            bodyObj = pBodyLayer:getObject(name)
        end
        
        indexSecond = 1
        name = indexFirst.."_"..indexSecond  
        
        -- 收集所有实体undef矩形
        local undefObj = pUndefLayer:getObject(name)
        while undefObj ~= nil and undefObj["x"] ~= nil do   -- 收集实体上的矩形集合
            table.insert(tUndefs, cc.rect(undefObj["x"], undefObj["y"], undefObj["width"], undefObj["height"]))
            indexSecond = indexSecond + 1
            name = indexFirst.."_"..indexSecond
            undefObj = pUndefLayer:getObject(name)
        end

        local tAttrisInfo = TableEntitys[tonumber(obj["ID"])]

        -- 创建实体        
        local pEntity = self:createEntity(tAttrisInfo, posObj, tBottoms, tBodys, tUndefs, indexFirst)

        indexFirst = indexFirst + 1
        obj = pEntitysLayer:getObject(tostring(indexFirst))    
    end


    if bDebug == true then
        self._pDebugLayer = require("EntitysDebugLayer"):create()
        MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kEntityDebugLayer)
    end
end

-- 创建单个实体
function EntitysManager:createEntity(tAttrisInfo, posObj, tBottoms, tBodys, tUndefs, ID)
    local pEntity = nil
    if tAttrisInfo.TypeID == kType.kEntity.kDoor then
        -- 传送门实体
        pEntity = require("DoorEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kRoadBlock then
        -- 路障实体
        pEntity = require("RoadBlockEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kCanbeDestroyed then
        -- 可被摧毁实体
        pEntity = require("CanbeDestroyedEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kPoisonPool then
        -- 毒池塘实体
        pEntity = require("PoisonPoolEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kSwamp then
        -- 沼泽实体
        pEntity = require("SwampEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kRollHammer then
        -- 旋转锤实体
        pEntity = require("RollHammerEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kBomb then
        -- 地雷实体
        pEntity = require("BombEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kSpikeRock then
        -- 地刺实体
        pEntity = require("SpikeRockEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    elseif tAttrisInfo.TypeID == kType.kEntity.kFireMachine then
        -- 喷火机关实体
        pEntity = require("FireMachineEntity"):create(tAttrisInfo, tBottoms, tBodys, tUndefs)
    end
    pEntity._nID = ID
    
    -- 添加实体到地图
    local size = pEntity._pAni:getChildByName("Default"):getContentSize()
    pEntity:setPosition(posObj.x + size.width/2, posObj.y)
    MapManager:getInstance()._pTmxMap:addChild(pEntity,kZorder.kEntity)           
    -- 添加到集合
    table.insert(self._tEntitys, pEntity)
    ----------------------------------------------------------------------------------------
    if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
        -- 如果是路障（屏障），则添加到按野怪区域划分的集合中
        if tAttrisInfo.MonsterAreaID ~= nil and tAttrisInfo.MonsterAreaID ~= 0 then
            table.insert(self._tRoadBlockEntitys[tAttrisInfo.MonsterAreaID], pEntity)
        end
        -- 如果是传送门，则添加到开始集合或者结束集合中
        local stageMapInfo = StagesManager:getInstance():getCurStageMapInfo()
        local doorsIDs = stageMapInfo.Doors
        for k,v in pairs(doorsIDs) do
            for kID, vID in pairs(v) do
                if vID == pEntity._nID then
                    self._tDoors[k][kID] = pEntity
                end
            end
        end
    end
    -----------------------------------------------------------------------------------------
    return pEntity
end

-- 根据ID获取实体对象
function EntitysManager:getEntityByID(id)    
    local pEntity = nil
    for k,v in pairs(self._tEntitys) do
        if v._nID == id then -- 存在
            pEntity = v
            break
        end
    end
    return pEntity
end

-- 遍历实体对象
function EntitysManager:updateEntitys(dt)
    for k,v in pairs(self._tEntitys) do
        if v._bActive == false then -- 若已失效，则立即移除并删除
            -- 删除之前，需要把实体的bottom矩形和body矩形从RectsManager中删除
            RectsManager:getInstance():removeRectsByRects(v._tBottoms,1)
            RectsManager:getInstance():removeRectsByRects(v._tBodys,2)
            RectsManager:getInstance():removeRectsByRects(v._tUndefs,3)
            v:removeFromParent(true)
            table.remove(self._tEntitys,k)
            break
        end
    end
    
    -- 战斗结果已经得出，则逻辑可以屏蔽，避免结算时影响体验
    if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
        if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
            return
        end
    end
    
    for k,v in pairs(self._tEntitys) do
        if v._bActive == true then
            if v:isVisible() == true then
                v:updateEntity(dt)        
            end
        end
    end
    
end

-- 监控路障和传送门
function EntitysManager:updateRoadBlocksAndDoors(dt)
    if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
        local pMonstersManager = MonstersManager:getInstance()
        -- 如果当前波的野怪数目为0，并且当前野怪区域中的下一波已经没有野怪了，则屏障消失
        if table.getn(pMonstersManager._tCurWaveMonsters) == 0 and pMonstersManager._nCurMonsterAreaIndex ~= 0 then
            if pMonstersManager._tMonsters[pMonstersManager._nCurMonsterAreaIndex] == nil or pMonstersManager._tMonsters[pMonstersManager._nCurMonsterAreaIndex][pMonstersManager._nCurMonsterWaveIndex + 1] == nil then  -- 当前野怪区域已经没有下一波了，则屏障消失 
                local roadBlockEntitys = self._tRoadBlockEntitys[pMonstersManager._nCurMonsterAreaIndex]
                for k,v in pairs(roadBlockEntitys) do 
                    v:setRoadBlockEntitysActive(false) -- 屏障消失
                end
                self._tRoadBlockEntitys[pMonstersManager._nCurMonsterAreaIndex] = {}
                -- 在已经没有下一波的情况下，判断是否当前战斗地图中所有野怪已经全部被干掉了
                if table.getn(pMonstersManager._tMonsters) == pMonstersManager._nCurMonsterAreaIndex then
                    -- 战斗结束
                    -- 出现传送门
                    local doors = self._tDoors[2]
                    if doors ~= nil then
                        for k,v in pairs(doors) do
                            v:appear()
                        end
                    end

                end
            end
        end 
    end

end

-- 全部移除
function EntitysManager:removeAllEntitys()
    for k,v in pairs(self._tEntitys) do 
        v:removeFromParent(true)
    end
end
