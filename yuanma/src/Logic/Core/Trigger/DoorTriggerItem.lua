--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DoorTriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   触发器传送门动作项
--===================================================
local DoorTriggerItem = class("DoorTriggerItem",function()
    return require("TriggerItem"):create()
end)

-- 构造函数
function DoorTriggerItem:ctor()
    self._kType = kType.kTriggerItemType.kDoor   -- 触发器动作项的类型
    self._nDoorEntityID = 0                      -- 所归属的传送门实体ID
    self._nCopyType = kType.kCopy.kNone          -- 传送到的副本类型
    self._nStageID = 0                           -- 传送到的副本的关卡ID
    self._nStageMapID = 0                        -- 传送到的副本的地图ID
    self._strNextMapName = ""                    -- 传送到的下一地图的文件名称
    self._strNextMapPvrName = ""                 -- 传送到的下一地图的pvr名称
    self._nNextMapDoorIDofEntity = 0             -- 传送到的下一地图的传送门ID（在Entitys中的ID）,ID从1开始计数
    self._fSendDelay = 0                         -- 传送前的延时时间
end

-- 创建函数
function DoorTriggerItem:create(index, doorEntityID, nextMapDoorIDofEntity, sendDelay, mapIds)
    local item = DoorTriggerItem.new()
    item._nIndex = index
    item._nDoorEntityID = doorEntityID
    item._nNextMapDoorIDofEntity = nextMapDoorIDofEntity
    item._fSendDelay = sendDelay
    
    -- 随机地图
    local mapID = mapIds[getRandomNumBetween(1,table.getn(mapIds))]
    
    item._nCopyType = item:getStagesManager()._nCurCopyType
    item._nStageID = item:getStagesManager()._nCurStageID
    item._nStageMapID = mapID
    item._strNextMapName = item:getStagesManager():getCopyMapInfo(item._nCopyType)[item._nStageMapID].MapsName
    item._strNextMapPvrName = item:getStagesManager():getCopyMapInfo(item._nCopyType)[item._nStageMapID].MapsPvrName

    return item
end

-- 作用函数
function DoorTriggerItem:work()
    if self._pOwnerTrigger._nCurStep == self._nIndex and  -- 列表中上一个动作运行结束以后才可以进入到当前动作的执行
        self:getMapManager()._pTmxMap:getActionByTag(nTriggerItemTag) == nil then
        
        -- 执行结束后的回调
        local actionOverCallBack = function()
            self._pOwnerTrigger:addCurStep()

            --战斗数据组装
            -- 【战斗数据对接】
            local args = {}
            args._strNextMapName = self._strNextMapName
            args._strNextMapPvrName = self._strNextMapPvrName
            args._nNextMapDoorIDofEntity = self._nNextMapDoorIDofEntity
            args._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo
            args._nMainPlayerRoleCurHp = RolesManager:getInstance()._pMainPlayerRole._nCurHp      -- 血值需要传入下一张战斗地图
            args._nMainPlayerRoleCurAnger = RolesManager:getInstance()._pMainPlayerRole._nCurAnger      -- 怒气值需要传入下一张战斗地图
            if PetsManager:getInstance()._pMainPetRole then
                args._nMainPetRoleCurHp = PetsManager:getInstance()._pMainPetRole._nCurHp               -- 血值需要传入下一张战斗地图
            end
            args._nCurCopyType = self._nCopyType
            args._nCurStageID = self._nStageID
            args._nCurStageMapID = self._nStageMapID
            args._nBattleId = StagesManager:getInstance()._nBattleId
            args._fTimeMax = BattleManager:getInstance()._fTimeCounter
            args._bIsAutoBattle = BattleManager:getInstance()._bIsAutoBattle
            args._tMonsterDeadNum = MonstersManager:getInstance()._tMonsterDeadNum
            args._nIdentity = StagesManager:getInstance()._nIdentity
            args._tTowerCopyStepResultInfos = BattleManager:getInstance()._tTowerCopyStepResultInfos
            args._pPvpRoleInfo = nil
            args._tPvpRoleMountAngerSkills = {}
            args._tPvpRoleMountActvSkills = {}
            args._tPvpPasvSkills = {}
            args._tPvpPetRoleInfosInQueue = {}

            --切换战斗场景
            LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)

        end
        -- 准备切换地图
        local act = cc.Sequence:create(cc.DelayTime:create(self._fSendDelay), cc.CallFunc:create(actionOverCallBack))
        act:setTag(nTriggerItemTag)
        self:getMapManager()._pTmxMap:runAction(act)
        
        cc.Director:getInstance():getRunningScene():closeAllDialogsWithNoAni()
        
        
        if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
            -- 场景触摸被禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldLayer")._pTouchListener:setEnabled(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pTouchListener:setEnabled(false)
            -- 角色恢复到默认站立状态
            self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand)
            -- 摇杆禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pStick:setIsWorking(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pStick:hide()        
        elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
            -- 战斗场景中时间暂停
            BattleManager:getInstance():pauseTime()
            -- 场景触摸被禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleLayer")._pTouchListener:setEnabled(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pTouchListener:setEnabled(false)
            -- 角色恢复到默认站立状态
            self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
            -- 摇杆禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:setIsWorking(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:hide()        
        end

    end
end

return DoorTriggerItem
