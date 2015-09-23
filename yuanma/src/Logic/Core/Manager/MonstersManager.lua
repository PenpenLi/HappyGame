--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonstersManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   怪物管理器
--===================================================
MonstersManager = {}

local instance = nil

-- 单例
function MonstersManager:getInstance()
    if not instance then
        instance = MonstersManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function MonstersManager:clearCache()  
    self._pDebugLayer = nil                             -- 调试层对象 
    self._tMonsters = {}                                -- 怪物集合{{波，波，波...},{波，波，波....},{波，波，波....}...}
    self._pBoss = nil                                   -- BOSS（每张地图最多只有一个BOSS）
    self._tCurWaveMonsters = {}                         -- 当前波的怪物集合
    self._tMonsterDeadNum = {}                          -- 统计当前按照ID分类的死亡的所有野怪的数量如：{[1] = 5,[7] = 10......}
    self._nMonsterSeqNum = 0                            -- 野怪id生成器
    self._nCurMonsterAreaIndex = 0                      -- 当前关卡Monster区域的index
    self._nCurMonsterWaveIndex = 0                      -- 当前关卡Monster区域中的波index
    self._nGoldDropTotalNum = 0                         -- 掉落金币累积数量
    self._bIsBossDead = false                           -- 标记boss是否死亡
    
end

-- 循环处理
function MonstersManager:update(dt)  
    -- monsters
    self:updateMonsters(dt)
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

-- 创建所有野怪
function MonstersManager:createAllMonsterRoles(debug)
    local stageMapInfo = StagesManager:getInstance():getCurStageMapInfo()
    local areaIndex = 1
    while stageMapInfo["MonsterArea"..areaIndex] ~= nil do
        self._tMonsters[areaIndex] = {}  -- 插入新的一个区域
        for kMonsterWave,vMonsterWave in pairs(stageMapInfo["MonsterArea"..areaIndex]) do
            self._tMonsters[areaIndex][kMonsterWave] = {}  -- 插入当前区域的新的一波
            for kStageMonster, vStageMonster in pairs(vMonsterWave) do
                -- 创建角色 
                local pMonsterRole = self:createMonsterRole(vStageMonster.monsterID, vStageMonster.posIndexX, vStageMonster.posIndexY)
                -- 添加到集合
                table.insert(self._tMonsters[areaIndex][kMonsterWave], pMonsterRole)  -- 把野怪插入到当前区域的当前波中
            end
        end
        areaIndex = areaIndex + 1
    end
    
    if debug then
        if self._pDebugLayer == nil then
            self._pDebugLayer = require("MonstersDebugLayer"):create()
            MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kRoleDebugLayer)
        end
    end
    
end

-- 创建所有野怪
function MonstersManager:createMonsterRole(stageMonsterID, stageMonsterPosIndexX, stageMonsterPosIndexY)
    -- 创建角色
    local monsterInfo = TableMonster[stageMonsterID]
    local pMonsterRole = require("MonsterRole"):create(monsterInfo)
    if pMonsterRole._nMonsterType == kType.kMonster.kBOSS or pMonsterRole._nMonsterType == kType.kMonster.kThiefBOSS then
        self._pBoss = pMonsterRole      -- BOSS
    end
    -- 生成角色ID
    self._nMonsterSeqNum = self._nMonsterSeqNum + 1
    pMonsterRole._nID = self._nMonsterSeqNum
    pMonsterRole._nTypeID = stageMonsterID
    -- 添加角色到地图
    pMonsterRole:setPositionByIndex(cc.p(stageMonsterPosIndexX, stageMonsterPosIndexY))
    pMonsterRole:setPositionZ(stageMonsterPosIndexY*(MapManager:getInstance()._f3DZ))
    MapManager:getInstance()._pTmxMap:addChild(pMonsterRole,kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - pMonsterRole:getPositionY())
    return pMonsterRole
end

-- 更新野怪
function MonstersManager:updateMonsters(dt)
    -- 野怪移除逻辑更新
    if table.getn(self._tCurWaveMonsters) ~= 0 then   -- 当前波存在没有消灭掉的野怪
        for kMonster, vMonster in pairs(self._tCurWaveMonsters) do
            if vMonster._bActive == false then-- 若已失效，则立即移除并删除
                if vMonster._nMonsterType == kType.kMonster.kBOSS or vMonster._nMonsterType == kType.kMonster.kThiefBOSS then
                    self._pBoss = nil
                end
                vMonster:removeFromParent(true)
                table.remove(self._tCurWaveMonsters,kMonster)                
                break
            end
        end
    end
    
    -- 战斗结果已经得出，则逻辑可以屏蔽，避免结算时影响体验
    if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
        if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
            return
        end
    end
    
    --如果当前正在显示新手，则立即返回
    if NewbieManager:getInstance():isShowingNewbie() == true then
        return
    end
    
    -- 野怪战斗逻辑更新
    if table.getn(self._tCurWaveMonsters) ~= 0 then   -- 当前波存在没有消灭掉的野怪
        for kMonster, vMonster in pairs(self._tCurWaveMonsters) do
            if vMonster._bActive == true then
                vMonster:updateMonsterRole(dt)
            end
        end
    else  -- 当前波已经没有野怪了
        if self._nCurMonsterAreaIndex ~= 0 then
            if self._tMonsters[self._nCurMonsterAreaIndex][self._nCurMonsterWaveIndex + 1] ~= nil then  -- 当前野怪区域还有下一波
                self:appearMonstersWithAreaAndWave(self._nCurMonsterAreaIndex, self._nCurMonsterWaveIndex + 1)
            end
        end
    end

    return
end

-- 出现野怪（按照指定的区域和波index）
function MonstersManager:appearMonstersWithAreaAndWave(areaIndex, waveIndex)
    self._nCurMonsterAreaIndex = areaIndex
    self._nCurMonsterWaveIndex = waveIndex
    -- 当前区域的当前波的怪集合
    self._tCurWaveMonsters = self._tMonsters[self._nCurMonsterAreaIndex][self._nCurMonsterWaveIndex]
    for k,v in pairs(self._tCurWaveMonsters) do
    	v:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kAppear)
    end
    
    if NewbieManager:getInstance()._bSkipGuide == false then
        if NewbieManager:getInstance()._pLastID == "Guide_1_1" then
            NewbieManager:getInstance():showNewbieByID("Guide_1_2")
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._bStickDisabled = true  -- 摇杆禁用
            RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
        end
        if NewbieManager:getInstance()._pLastID == "Guide_1_2" then
            if self._nCurMonsterAreaIndex == 2 and self._nCurMonsterWaveIndex == 1 then
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._bStickDisabled = true
                RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
                NewbieManager:getInstance():showNewbieByID("Guide_1_3")
                local showOver = function()
                    cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._bStickDisabled = false
                end
                cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(NewbieManager:getInstance()._pCurInfo.ShowDelay),cc.CallFunc:create(showOver)))
            end
            return
        end
        
    end
    
    
end

-- 处理战斗结果
function MonstersManager:disposeWhenBattleResult()
    for kMonster, vMonster in pairs(self._tCurWaveMonsters) do
        if vMonster._bActive == true then
            if vMonster:isUnusualState() == false then     -- 正常状态
                vMonster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kStand, true)
                --print("野怪回到站立！")
            end
        end
    end
end

-- 判断指定矩形是否与当前波中野怪的bottom发生碰撞
function MonstersManager:isRectCollidingOnCurWaveMonstersBottoms(rect)
    local bCollide = false
    for k,v in pairs(self._tCurWaveMonsters) do
        if v._bActive == true then
            local bottom = v:getBottomRectInMap()
            if cc.rectIntersectsRect(rect, bottom) == true then
                bCollide = true
                break
            end
        end
    end
    return bCollide
end

-- 设置是否强制所有角色的positionZ为最小值
-- 【主要用于避免弹框时地图上的3d模型与ui层上的3d模型发生异常重叠，弹出有3d模型的对话框时，这里设置需要设置为true】
-- 【关闭时候，需要手动设置为false】
function MonstersManager:setForceMinPositionZ(bForce, value)
    if table.getn(self._tCurWaveMonsters) ~= 0 then   -- 当前波存在没有消灭掉的野怪
        for kMonster, vMonster in pairs(self._tCurWaveMonsters) do
            vMonster._bForceMinPositionZ = bForce
            if bForce == true then
                vMonster._nForceMinPositionZValue = value
            else
                vMonster._nForceMinPositionZValue = 0
            end
            vMonster:refreshZorder()
        end
    end
end

-- 清除当前地图当前波的所有monster
function MonstersManager:deleteCurWaveMonsters()
    for kMonster, vMonster in pairs(self._tCurWaveMonsters) do 
        vMonster:removeFromParent(true)
    end
    self._tCurWaveMonsters = {}
end

-- 设置当前地图当前波的所有monster阵亡
function MonstersManager:setCurWaveMonstersAllDead()
    for kMonster, vMonster in pairs(self._tCurWaveMonsters) do
        if vMonster._bActive == true then
            if vMonster._nCurHp ~= 0 then
                vMonster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDead, true, {false})
            end
        end
    end
end

-- 消灭所有monster，如果当前波中有boss，则boss死一个来带动其他的monster死亡即可
function MonstersManager:debugCurWaveMonstersAllDead()
    for kMonster, vMonster in pairs(self._tCurWaveMonsters) do
        if vMonster._bActive == true then
            if vMonster._nCurHp ~= 0 and vMonster == self._pBoss then
                vMonster._nCurHp = 0
                vMonster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDead, true, {false})
                return
            end
        end
    end
    for kMonster, vMonster in pairs(self._tCurWaveMonsters) do
        if vMonster._bActive == true then
            if vMonster._nCurHp ~= 0 then
                vMonster._nCurHp = 0
                vMonster:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDead, true, {false})
            end
        end
    end
end

-- 全部移除
function MonstersManager:removeAllMonsters()
    for kArea,vArea in pairs(self._tMonsters) do
        for kWave,vWave in pairs(vArea) do
            for k,v in pairs(vWave) do
                v:removeFromParent(true)
            end
        end
    end
    self._tMonsters = {}
end
