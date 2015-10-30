--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetsManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/23
-- descrip:   宠物角色管理器
--===================================================
PetsManager = {}

local instance = nil

-- 单例
function PetsManager:getInstance()
    if not instance then
        instance = PetsManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function PetsManager:clearCache()
    self._pDebugLayer = nil                             -- 调试层对象 
    ----------------------------- 主角玩家的宠物 -------------------------------------
    self._pMainPetRole = nil                            -- 主角的宠物对象
    self._posMainPetRoleStartPosIndex = cc.p(-1,-1)     -- 主角的宠物起始位置
    self._nMainPetRoleCurHp = nil                       -- 必要的时候这里会有数据，在主角宠物初始化的时候如果这里有值则以这里的数值为主（比如从战斗地图切换到另一张战斗地图，血值需要共享上一张战斗的值）
    ----------------------------- PVP对手玩家的宠物 -------------------------------------
    self._pPvpPetRole = nil                             -- pvp对手玩家宠物对象
    self._posPvpPetRoleStartPosIndex = cc.p(-1,-1)      -- pvp对手玩家宠物起始位置
    self._tPvpPetRoleInfosInQueue = {}                  -- pvp对手玩家宠物上阵队列中的信息集合（最多3个）
    self._nCurPvpPetRoleIndexInQueue = 1                -- 当前pvp宠物在上阵队列中的index
    ----------------------------- 其他在线玩家的宠物 ------------------------------------
    self._tOtherPetRoles = {}                           -- 其他玩家的宠物集合
    self._tOtherPetRolesInfos = {}                      -- 其他玩家的宠物信息集合
    self._tOtherPetRolesMasters = {}                    -- 其他玩家的宠物的主人集合
    self._tOtherPetRolesCurHp = {}                      -- 其他玩家的宠物的血量备份(切换场景时会被重置)  必要的时候这里会有数据，在主角宠物初始化的时候如果这里有值则以这里的数值为主（比如从战斗地图切换到另一张战斗地图，血值需要共享上一张战斗的值）
    ----------------------------- 永远放在最下面  ---------------------------------------
    -- 下面是需要保留的数据
    if self._tMainPetRoleInfosInQueue ~= nil and table.getn(self._tMainPetRoleInfosInQueue) ~= 0 then    -- 主角的宠物数据信息集合（最多3个）
        return
    else
        self._tMountPetsIdsInQueue = {}                     -- 当前主角宠物上阵队列中的宠物id集合
        self._tMainPetRoleInfosInQueue = {}                 -- 当前主角宠物上阵队列中的信息集合
        self._nCurMainPetRoleIndexInQueue = 1               -- 当前主角宠物在上阵队列中的index
    end
    self._tMainPetsInfos = {}                               -- 所拥有的所有宠物信息（服务器返回）集合

end

-- 循环处理
function PetsManager:update(dt)
    -- 战斗结果已经得出，则逻辑可以屏蔽，避免结算时影响体验
    if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
        if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
            return
        end
    end
    --如果当前正在显示新手，则立即返回
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        if NewbieManager:getInstance():isShowingNewbie() == true then
            return
        end
    end

    -- 主角的宠物
    self:updateMainPetRole(dt)
    -- PVP对手的宠物
    self:updatePvpPetRole(dt)
    -- 其他玩家的宠物
    self:updateOtherPetRole(dt)
    
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

-- 创建主角宠物
function PetsManager:createMainPetRoleOnMap(bDebug)
    -- 每次回到家园时，主角宠物均为队列中的第一个
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        self._nCurMainPetRoleIndexInQueue = 1
    end
    
    if table.getn(self._tMainPetRoleInfosInQueue) ~= 0 and self._nCurMainPetRoleIndexInQueue <= table.getn(self._tMainPetRoleInfosInQueue) then
        if self._pMainPetRole == nil then
            -- 宠物共鸣信息集合
            local cooperateInfo = {}
            -- 查找是否存在宠物共鸣影响（如果存在，则获取信息）
            if #RolesManager:getInstance()._tMainPetCooperates > 0 then 
                for k,v in pairs(RolesManager:getInstance()._tMainPetCooperates[1].RequiredPet) do 
                    if self._tMainPetRoleInfosInQueue[self._nCurMainPetRoleIndexInQueue].petId == v then
                        cooperateInfo = RolesManager:getInstance()._tMainPetCooperates[1]
                        break
                    end
                end
            end
            -- 创建主角的宠物
            self._pMainPetRole = require("PetRole"):create(self._tMainPetRoleInfosInQueue[self._nCurMainPetRoleIndexInQueue],"main", RolesManager:getInstance()._pMainPlayerRole,cooperateInfo)
            self._pMainPetRole._nIndexInQueue = self._nCurMainPetRoleIndexInQueue
            RolesManager:getInstance()._pMainPlayerRole._pCurPetRole = self._pMainPetRole
            -- 宠物关联
            -- 如果当前血值有固定好的数值，则以这些指定数值为准（比如从战斗地图切换到另一张战斗地图，相应的数值需要共享上一张战斗的值）
            if self._nMainPetRoleCurHp then
                self._pMainPetRole._nCurHp = self._nMainPetRoleCurHp
            end

            -- 获取主角宠物的位置
            local nDoorId = MapManager:getInstance()._nNextMapDoorIDofEntity
            if nDoorId ~= 0 then
                -- 获取传送门校正后的位置
                local rect = EntitysManager:getInstance():getEntityByID(nDoorId):getBodyRectInMap()
                local pos = cc.p(rect.x + rect.width/2, rect.y)
                local index = MapManager:getInstance():convertPiexlToIndex(pos) 
                self._posMainPetRoleStartPosIndex = cc.p(index.x, index.y - 1)
            else
                if RolesManager:getInstance()._posMainRoleLastPosIndexOnWorldMap then   -- 存在记录的位置
                    self._posMainPetRoleStartPosIndex = RolesManager:getInstance()._posMainRoleLastPosIndexOnWorldMap       -- 与主角位置一致
                else    -- 不存在记录的位置，则直接从地图文件中获取即可
                    local pCustomsLayer = MapManager:getInstance()._pTmxMap:getObjectGroup("CustomsLayer")
                    local posMainPetRoleStart = pCustomsLayer:getObject("MainPetStartPos")
                    -- 获取位置的行列索引值
                    self._posMainPetRoleStartPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(posMainPetRoleStart["x"], posMainPetRoleStart["y"]))
                end
            end
            -- 添加主角宠物到地图
            self._pMainPetRole:setPositionByIndex(cc.p(self._posMainPetRoleStartPosIndex.x + 2, self._posMainPetRoleStartPosIndex.y))
            self._pMainPetRole:setPositionZ(self._posMainPetRoleStartPosIndex.y*(MapManager:getInstance()._f3DZ))
            MapManager:getInstance()._pTmxMap:addChild(self._pMainPetRole, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - self._pMainPetRole:getPositionY())
            -- 刷新相机
            self._pMainPetRole:refreshCamera()
            
        end

        if bDebug == true then
            if self._pDebugLayer == nil then
                self._pDebugLayer = require("PetsDebugLayer"):create()
                MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kRoleDebugLayer)
            end
        end

        return self._pMainPetRole    
    end
    return nil
end

function PetsManager:removeMainPetRoleFromMap()
    -- 移除角色
    if self._pMainPetRole ~= nil then
        self._pMainPetRole:removeFromParent(true)
        self._pMainPetRole = nil
    end
end

-- 创建Pvp宠物
function PetsManager:createPvpPetRoleOnMap(bDebug)
    if table.getn(self._tPvpPetRoleInfosInQueue) ~= 0 then
        if self._pPvpPetRole == nil then
            -- 宠物共鸣信息集合
            local cooperateInfo = {}
            -- 查找是否存在宠物共鸣影响（如果存在，则获取信息）
            if RolesManager:getInstance()._tPvpPetCooperates[1] then
                for k,v in pairs(RolesManager:getInstance()._tPvpPetCooperates[1].RequiredPet) do 
                    if self._tPvpPetRoleInfosInQueue[self._nCurPvpPetRoleIndexInQueue].petId == v then
                        cooperateInfo = RolesManager:getInstance()._tPvpPetCooperates[1]
                        break
                    end
                end            
            end
            -- 创建pvp的宠物
            self._pPvpPetRole = require("PetRole"):create(self._tPvpPetRoleInfosInQueue[self._nCurPvpPetRoleIndexInQueue],"pvp",RolesManager:getInstance()._pPvpPlayerRole,cooperateInfo)
            self._pPvpPetRole._nIndexInQueue = 1
            RolesManager:getInstance()._pPvpPlayerRole._pCurPetRole = self._pPvpPetRole
            -- 获取pvp宠物的位置
            local pCustomsLayer = MapManager:getInstance()._pTmxMap:getObjectGroup("CustomsLayer")
            local posPvpPetRoleStart = pCustomsLayer:getObject("PvpPetStartPos")
            -- 获取位置的行列索引值
            self._posPvpPetRoleStartPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(posPvpPetRoleStart["x"], posPvpPetRoleStart["y"]))
            -- 添加pvp宠物到地图
            self._pPvpPetRole:setPositionByIndex(cc.p(self._posPvpPetRoleStartPosIndex.x + 2, self._posPvpPetRoleStartPosIndex.y))
            self._pPvpPetRole:setPositionZ(self._posPvpPetRoleStartPosIndex.y*(MapManager:getInstance()._f3DZ))
            MapManager:getInstance()._pTmxMap:addChild(self._pPvpPetRole, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - self._pPvpPetRole:getPositionY())
            -- 刷新相机
            self._pPvpPetRole:refreshCamera()
        end

        if bDebug == true then
            if self._pDebugLayer == nil then
                self._pDebugLayer = require("PetsDebugLayer"):create()
                MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kRoleDebugLayer)
            end
        end
        
        return self._pPvpPetRole
    end
    return nil
end

-- 创建其他玩家角色宠物
function PetsManager:createOtherPetRolesOnMap()
    -- 清空地图上显示对象的元素记录
    self._tOtherPetRoles = {}
    for kInfo, vInfo in pairs(self._tOtherPetRolesInfos) do
        -- 宠物共鸣信息集合
        local cooperateInfo = {}
        -- 查找是否存在宠物共鸣影响（如果存在，则获取信息）
        if RolesManager:getInstance()._tOtherPetCooperates[kInfo] and RolesManager:getInstance()._tOtherPetCooperates[kInfo][1] then
            for k,v in pairs(RolesManager:getInstance()._tOtherPetCooperates[kInfo][1].RequiredPet) do 
                if vInfo[1].petInfo.petId == v then
                    cooperateInfo = RolesManager:getInstance()._tOtherPetCooperates[kInfo][1]
                    break
                end
            end
        end
        -- 创建其他玩家宠物
        local role = require("OtherPetRole"):create(vInfo[1].petInfo,"main",self._tOtherPetRolesMasters[kInfo],cooperateInfo)
        role._nIndexInQueue = 1
        role._pMaster._pCurPetRole = role
        -- 如果当前血值有固定好的数值，则以这些指定数值为准（比如从战斗地图切换到另一张战斗地图，相应的数值需要共享上一张战斗的值）
        if self._tOtherPetRolesCurHp[kInfo] then
            role._nCurHp = self._tOtherPetRolesCurHp[kInfo]
        end
        local posIndex = AIManager:getInstance():objBlinkToRandomPosAccordingToTargetObj(role,role._pMaster,1,3)
        -- 添加宠物到地图
        role:setPositionByIndex(posIndex)
        role:setPositionZ(role._pMaster:getPositionIndex().y*(MapManager:getInstance()._f3DZ))
        MapManager:getInstance()._pTmxMap:addChild(role, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - role:getPositionY())
        table.insert(self._tOtherPetRoles,role)      
    end

end

-- 移除所有 其他玩家宠物角色
function PetsManager:removeAllOtherPetRolesOnWorldMap()
    for kRole, vRole in pairs(self._tOtherPetRoles) do
        vRole:removeFromParent(true)
    end
    self._tOtherPetRoles = {}
    self._tOtherPetRolesInfos = {}
    self._tOtherPetRolesMasters = {}

end

-- 切换到下一个宠物
-- 参数：如果index有值，则切换到指定index的宠物
--       如果index没有值，则按照顺序切换到下一个宠物
function PetsManager:changeToNextMainPetRoleOnMap(index)    
    if index == nil then
        self._nCurMainPetRoleIndexInQueue = self._nCurMainPetRoleIndexInQueue + 1         -- 当前宠物index自加
    else
        self._nCurMainPetRoleIndexInQueue = index      -- 指定index为当前宠物
    end
    -- 创建宠物
    if self._nCurMainPetRoleIndexInQueue <= table.getn(self._tMainPetRoleInfosInQueue) then
        -- 备份宠物当前位置
        local posMainPet = cc.p(self._pMainPetRole:getPositionX(),self._pMainPetRole:getPositionY())
        local posMainPetZ = self._pMainPetRole:getPositionZ()
        -- 移除角色
        self._pMainPetRole:removeFromParent(true)
        self._pMainPetRole = nil

        -- 宠物共鸣信息集合
        local cooperateInfo = {}
        -- 查找是否存在宠物共鸣影响（如果存在，则获取信息）
        for k,v in pairs(RolesManager:getInstance()._tMainPetCooperates[1].RequiredPet) do 
            if self._tMainPetRoleInfosInQueue[self._nCurMainPetRoleIndexInQueue].petId == v then
                cooperateInfo = RolesManager:getInstance()._tMainPetCooperates[1]
                break
            end
        end
        -- 创建主角的宠物
        self._pMainPetRole = require("PetRole"):create(self._tMainPetRoleInfosInQueue[self._nCurMainPetRoleIndexInQueue],"main", RolesManager:getInstance()._pMainPlayerRole,cooperateInfo)
        self._pMainPetRole._nIndexInQueue = self._nCurMainPetRoleIndexInQueue
        RolesManager:getInstance()._pMainPlayerRole._pCurPetRole = self._pMainPetRole
        -- 添加主角宠物到地图
        self._pMainPetRole:setPosition(posMainPet)
        self._pMainPetRole:setPositionZ(posMainPetZ)
        if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
            self._pMainPetRole:addBuffByID(TableConstants.ReviveBuff.Value)  -- 添加一个虚影buff
        end
        MapManager:getInstance()._pTmxMap:addChild(self._pMainPetRole, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - self._pMainPetRole:getPositionY())
        -- 刷新相机
        self._pMainPetRole:refreshCamera()
    else
        -- 移除角色
        self._pMainPetRole:removeFromParent(true)
        self._pMainPetRole = nil
        RolesManager:getInstance()._pMainPlayerRole._pCurPetRole = nil
    end

end


-- 切换到下一个宠物
-- 参数：如果index有值，则切换到指定index的宠物
--       如果index没有值，则按照顺序切换到下一个宠物
function PetsManager:changeToNextPvpPetRoleOnMap(index)
    if index == nil then
        self._nCurPvpPetRoleIndexInQueue = self._nCurPvpPetRoleIndexInQueue + 1         -- 当前宠物index自加
    else
        self._nCurPvpPetRoleIndexInQueue = index      -- 指定index为当前宠物
    end
    -- 创建宠物
    if self._nCurPvpPetRoleIndexInQueue <= table.getn(self._tPvpPetRoleInfosInQueue) then
        -- 备份宠物当前位置
        local posPvpPet = cc.p(self._pPvpPetRole:getPositionX(),self._pPvpPetRole:getPositionY())
        local posPvpPetZ = self._pPvpPetRole:getPositionZ()
        -- 移除角色
        self._pPvpPetRole:removeFromParent(true)
        self._pPvpPetRole = nil

        -- 宠物共鸣信息集合
        local cooperateInfo = {}
        -- 查找是否存在宠物共鸣影响（如果存在，则获取信息）




        if RolesManager:getInstance()._tPvpPetCooperates[1] then
            for k,v in pairs(RolesManager:getInstance()._tPvpPetCooperates[1].RequiredPet) do 
                if self._tPvpPetRoleInfosInQueue[self._nCurPvpPetRoleIndexInQueue].petId == v then
                        cooperateInfo = RolesManager:getInstance()._tPvpPetCooperates[1]
                    break
                 end
            end            
        end

        -- 创建pvp的宠物
        self._pPvpPetRole = require("PetRole"):create(self._tPvpPetRoleInfosInQueue[self._nCurPvpPetRoleIndexInQueue],"pvp",RolesManager:getInstance()._pPvpPlayerRole,cooperateInfo)
        self._pPvpPetRole._nIndexInQueue = self._nCurPvpPetRoleIndexInQueue
        RolesManager:getInstance()._pPvpPlayerRole._pCurPetRole = self._pPvpPetRole
        -- 添加pvp宠物到地图
        self._pPvpPetRole:setPosition(posPvpPet)
        self._pPvpPetRole:setPositionZ(posPvpPetZ)
        if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
            self._pPvpPetRole:addBuffByID(TableConstants.ReviveBuff.Value)  -- 添加一个虚影buff
        end
        MapManager:getInstance()._pTmxMap:addChild(self._pPvpPetRole, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - self._pPvpPetRole:getPositionY())
        -- 刷新相机
        self._pPvpPetRole:refreshCamera()
    else
        -- 移除角色
        self._pPvpPetRole:removeFromParent(true)
        self._pPvpPetRole = nil
        RolesManager:getInstance()._pPvpPlayerRole._pCurPetRole = nil
    end

end

-- 切换到下一个宠物（其他玩家）
-- 参数：pet：当前准备移除的pet对象
-- 返回：新创建出来的宠物对象
function PetsManager:changeToNextOtherPetRoleOnMap(pet)
    local indexInQueue = pet._nIndexInQueue
    indexInQueue = indexInQueue + 1         -- 当前宠物index自加
    -- 创建宠物
    if indexInQueue <= table.getn(pet._pMaster._pRoleInfo.pets) then
        -- 备份宠物当前位置
        local posPet = cc.p(pet:getPositionX(),pet:getPositionY())
        local posPetZ = pet:getPositionZ()
        local info = pet._pMaster._pRoleInfo.pets[indexInQueue].petInfo
        local master = pet._pMaster
        local deadPetCooperateInfo = pet._pCooperateInfo
        -- 移除角色
        for k,v in pairs(self._tOtherPetRoles) do
            if pet == v then
                table.remove(self._tOtherPetRoles,k)
                table.remove(self._tOtherPetRolesInfos,k)
                table.remove(self._tOtherPetRolesMasters,k)
                break
            end            
        end
        pet:removeFromParent(true)
        pet = nil

        -- 宠物共鸣信息集合
        local cooperateInfo = {}
        -- 查找是否存在宠物共鸣影响（如果存在，则获取信息）
        if deadPetCooperateInfo then
            if type(deadPetCooperateInfo.RequiredPet) == "table" then
                for k,v in pairs(deadPetCooperateInfo.RequiredPet) do 
                    if info.petId == v then
                        cooperateInfo = deadPetCooperateInfo
                        break
                    end
                end
            end
        end
        -- 创建其他玩家宠物
        pet = require("OtherPetRole"):create(info,"main",master,cooperateInfo)
        pet._nIndexInQueue = indexInQueue
        pet._pMaster._pCurPetRole = pet
        -- 添加宠物到地图
        pet:setPosition(posPet)
        pet:setPositionZ(posPetZ)
        if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
            pet:addBuffByID(TableConstants.ReviveBuff.Value)  -- 添加一个虚影buff
        end
        MapManager:getInstance()._pTmxMap:addChild(pet, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - pet:getPositionY())
        table.insert(self._tOtherPetRoles,pet) 
        -- 刷新相机
        pet:refreshCamera()
    else
        -- 移除角色
        for k,v in pairs(self._tOtherPetRoles) do
            if pet == v then
                table.remove(self._tOtherPetRoles,k)
                table.remove(self._tOtherPetRolesInfos,k)
                table.remove(self._tOtherPetRolesMasters,k)
                break
            end            
        end
        pet:removeFromParent(true)
        pet = nil
    end
    return pet
end

-- 设置指定其他玩家的当前宠物死亡(由otherPlayerRole的死亡引起的)
function PetsManager:setCurOtherPetDeadByOtherPlayerRole(otherPlayerRole)
    for k,v in pairs(self._tOtherPetRoles) do
        if v._pMaster == otherPlayerRole then
            v._nCurHp = 0
            v:getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kDead, true, {false,nil,true})
            break
        end
    end
    return
end

-- 移除指定的otherPet，不再出现队列中的其他宠物
function PetsManager:removeOtherPet(pet)
    -- 移除角色
    for k,v in pairs(self._tOtherPetRoles) do
        if pet == v then
            table.remove(self._tOtherPetRoles,k)
            table.remove(self._tOtherPetRolesInfos,k)
            table.remove(self._tOtherPetRolesMasters,k)
            break
        end            
    end
    pet:removeFromParent(true)
    pet = nil

end

function PetsManager:updateMainPetRole(dt)
    -- 主角宠物
    if self._pMainPetRole ~= nil then
        if self._pMainPetRole._bActive == true then
            self._pMainPetRole:updatePetRole(dt)
        end
    end
    return
end

function PetsManager:updatePvpPetRole(dt)
    -- pvp对手宠物
    if self._pPvpPetRole ~= nil then
        if self._pPvpPetRole._bActive == true then
            self._pPvpPetRole:updatePetRole(dt)
        end
    end
    return
end

function PetsManager:updateOtherPetRole(dt)
    -- 其他玩家宠物
    for k,v in pairs(self._tOtherPetRoles) do
        if v._bActive == true then
            v:updatePetRole(dt)
        end
    end
    return
end

-- 设置是否强制所有角色的positionZ为最小值
-- 【主要用于避免弹框时地图上的3d模型与ui层上的3d模型发生异常重叠，弹出有3d模型的对话框时，这里设置需要设置为true】
-- 【关闭时候，需要手动设置为false】
function PetsManager:setForceMinPositionZ(bForce, value)
    -- 玩家角色宠物
    if self._pMainPetRole then
        self._pMainPetRole._bForceMinPositionZ = bForce
        if bForce == true then
            self._pMainPetRole._nForceMinPositionZValue = value
        else
            self._pMainPetRole._nForceMinPositionZValue = 0
        end
        self._pMainPetRole:refreshZorder()
    end 

    -- Pvp对手宠物
    if self._pPvpPetRole then
        self._pPvpPetRole._bForceMinPositionZ = bForce
        if bForce == true then
            self._pPvpPetRole._nForceMinPositionZValue = value
        else
            self._pPvpPetRole._nForceMinPositionZValue = 0
        end
        self._pPvpPetRole:refreshZorder()
    end
    
    -- 其他玩家角色
    local tOtherPetsArray = self._tOtherPetRoles
    for i=1,#tOtherPetsArray do
        tOtherPetsArray[i]._bForceMinPositionZ = bForce
        if bForce == true then
            tOtherPetsArray[i]._nForceMinPositionZValue = value
        else
            tOtherPetsArray[i]._nForceMinPositionZValue = 0
        end
        tOtherPetsArray[i]:refreshZorder()
    end
    
end

-- 处理战斗结果
function PetsManager:disposeWhenBattleResult()
    -- 主角宠物
    if self._pMainPetRole ~= nil then
        if self._pMainPetRole._bActive == true then
            if self._pMainPetRole:isUnusualState() == false then     -- 正常状态
                self._pMainPetRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kStand, true)
                --print("宠物回到站立！")
            end
        end
    end
--[[
    -- 其他玩家角色
    local tOtherPetsArray = self._tOtherPetRoles
    for i=1,#tOtherPetsArray do
        if tOtherPetsArray[i]._bActive == true then        
            if tOtherPetsArray[i]:isUnusualState() == false then     -- 正常状态
                tOtherPetsArray[i]:getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPetRole):setCurStateByTypeID(kType.kState.kBattleOtherPetRole.kStand, true)
            end
        end
    end
]]

end

-- 判断指定矩形是否与当前主角玩家宠物的bottom发生碰撞
function PetsManager:isRectCollidingOnMainPetBottoms(rect)
    local bCollide = false
    local bottom = self._pMainPetRole:getBottomRectInMap()
    if cc.rectIntersectsRect(rect, bottom) == true then
        bCollide = true
    end
    return bCollide
end

-- 判断指定矩形是否与当前PVP玩家宠物的bottom发生碰撞
function PetsManager:isRectCollidingOnPvpPetBottoms(rect)
    local bCollide = false
    if self._pPvpPetRole then
        local bottom = self._pPvpPetRole:getBottomRectInMap()
        if cc.rectIntersectsRect(rect, bottom) == true then
            bCollide = true
        end
    end
    return bCollide
end

--------------------------------------------宠物数据表bean相关操作-----------------------------------------------------
function PetsManager:getPetInfoWithId(id , step , level)
	local dataInfo = {}
    dataInfo.data = clone(TablePets[id])
    dataInfo.templete = TableTempletePets[dataInfo.data.TempleteID[step]]
    dataInfo.step = step
    dataInfo.level = level
    dataInfo.id = id
    
    if self:isPetField(id) == true then
        for k, v in pairs(RolesManager:getInstance()._tMainPetCooperatePropties) do
            if k == 1 then
                dataInfo.data.Hp = dataInfo.data.Hp * v
            elseif k == 2 then
                dataInfo.data.Attack = dataInfo.data.Attack * v
            elseif k == 3 then
                dataInfo.data.Defend = dataInfo.data.Defend * v
            elseif k == 4 then
                dataInfo.data.CriticalChance = dataInfo.data.CriticalChance * v
            elseif k == 5 then
                dataInfo.data.CriticalDmage = dataInfo.data.CriticalDmage * v
            elseif k == 6 then
                dataInfo.data.Resilience = dataInfo.data.Resilience * v
            elseif k == 7 then
                dataInfo.data.Resistance = dataInfo.data.Resistance * v
            elseif k == 8 then
                dataInfo.data.Block = dataInfo.data.Block * v
            elseif k == 9 then
                dataInfo.data.Penetration = dataInfo.data.Penetration * v
            elseif k == 10 then
                dataInfo.data.DodgeChance = dataInfo.data.DodgeChance * v
            elseif k == 11 then
                dataInfo.data.AbilityPower = dataInfo.data.AbilityPower * v
            end
        end
    end
    
    return dataInfo
end

function PetsManager:isPetField(id)

    for i=1 ,table.getn(self._tMountPetsIdsInQueue) do
        if self._tMountPetsIdsInQueue[i] == id then
			return true
		end
	end
	
    return false
end

function PetsManager:setMountPets(ids)
    self._tMountPetsIdsInQueue = ids
    
    self._tMainPetRoleInfosInQueue = {}
    for i=1,table.getn(self._tMountPetsIdsInQueue) do
        self._tMainPetRoleInfosInQueue[i] = self:getMyPetDataWithId(self._tMountPetsIdsInQueue[i])
    end
    
    if table.getn(self._tMainPetRoleInfosInQueue) > 0 then
        if self._pMainPetRole == nil then
        	self:createMainPetRoleOnMap(false)
        else
            self:changeToNextMainPetRoleOnMap(1)
        end
    else
        self:removeMainPetRoleFromMap()
    end
    
end

function PetsManager:isPetGot(id)
    for i=1 ,table.getn(self._tMainPetsInfos) do
        if self._tMainPetsInfos[i].petId == id then
            return true
        end
    end

    return false
end

function PetsManager:getPetExpById(id)
    for i=1 ,table.getn(self._tMainPetsInfos) do
        if self._tMainPetsInfos[i].petId == id then
            local level = self._tMainPetsInfos[i].level
            local lastExp = 0
            for i=1,level-1 do
                lastExp = lastExp + TablePetsLevel[i].PetsExp
            end
            return self._tMainPetsInfos[i].exp - lastExp
        end
    end

    return 0
end

function PetsManager:getMyPetDataWithId(id)
    for i=1 ,table.getn(self._tMainPetsInfos) do
        if self._tMainPetsInfos[i].petId == id then
            return self._tMainPetsInfos[i]
        end
    end

    return {petId = id , level = 1 , step = 0 , exp = 0}
end

function PetsManager:getPetChipDataWithId(id)
    local myData = self:getMyPetDataWithId(id)
    
    local step = myData.step
    if myData.step == 0 then
    	step = 1
    end

	local dataInfo = {}
    dataInfo.data = TablePets[id]
    dataInfo.templete = TableTempletePets[dataInfo.data.TempleteID[step]]
    dataInfo.step = myData.step
    dataInfo.level = myData.level
    dataInfo.id = id
    return dataInfo
end

function PetsManager:AdvancePetWithId(id, step)
    for i=1 ,table.getn(self._tMainPetsInfos) do
        if self._tMainPetsInfos[i].petId == id then
            self._tMainPetsInfos[i].step = step
        end
    end
    
    self:setMountPets(self._tMountPetsIdsInQueue)
    
    if table.getn(self._tMainPetRoleInfosInQueue) > 0 and id == self._tMainPetRoleInfosInQueue[1].petId then
        self:changeToNextMainPetRoleOnMap(1)
    end
end

--宠物共鸣判断
function PetsManager:updatePetCooperate()
    RolesManager:getInstance()._tMainPetCooperates = {}
    RolesManager:getInstance()._tMainPetCooperatePropties = {}

    for i=1,table.getn(TablePetsResonance) do
        local beActived = true
        local tableData = TablePetsResonance[i]
        local requirePets = tableData.RequiredPet
        local requirePetQ = tableData.RequiredQ
        
        for j=1,table.getn(requirePets) do
            local pet = self:getMyPetDataWithId(requirePets[j])
            if pet.step < requirePetQ or self:isPetField(requirePets[j]) == false then
                beActived = false
            	break
            end
        end
        
        if beActived == true then
            table.insert(RolesManager:getInstance()._tMainPetCooperates,tableData)
        end
	end
	
    for i=1,table.getn(RolesManager:getInstance()._tMainPetCooperates) do
    	for j=1,table.getn(RolesManager:getInstance()._tMainPetCooperates[i].Property) do
            local localProptyData = RolesManager:getInstance()._tMainPetCooperates[i].Property[j]
    		if RolesManager:getInstance()._tMainPetCooperatePropties[localProptyData[1]] == nil then
    			RolesManager:getInstance()._tMainPetCooperatePropties[localProptyData[1]] = localProptyData[2] + 1
    	    else
    	       RolesManager:getInstance()._tMainPetCooperatePropties[localProptyData[1]] = RolesManager:getInstance()._tMainPetCooperatePropties[localProptyData[1]] + localProptyData[2]
    		end
    	end
    end
    
    return
end
-------------------------------------------------------------------------------------------------------------------

