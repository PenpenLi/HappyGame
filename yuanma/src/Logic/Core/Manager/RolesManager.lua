--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RolesManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   角色管理器
--===================================================
RolesManager = {}

local instance = nil

-- 单例
function RolesManager:getInstance()
    if not instance then
        instance = RolesManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function RolesManager:clearCache()  
    self._pDebugLayer = nil                             -- 调试层对象 
    ----------------------------- 主角玩家 -------------------------------------
    self._pMainPlayerRole = nil                         -- 主角玩家对象
    self._nRoleCurLevel = nil                           -- 主角当强等级，为了做升级的差值
    self._posMainPlayerRoleStartPosIndex = cc.p(-1,-1)  -- 主角起始位置
    self._nMainPlayerRoleCurHp = nil                    -- 必要的时候这里会有数据，在主角初始化的时候如果这里有值则以这里的数值为主（比如从战斗地图切换到另一张战斗地图，血值需要共享上一张战斗的值）
    self._nMainPlayerRoleCurAnger = nil                 -- 必要的时候这里会有数据，在主角初始化的时候如果这里有值则以这里的数值为主（比如从战斗地图切换到另一张战斗地图，怒气值需要共享上一张战斗的值）
    ----------------------------- PVP对手玩家 -------------------------------------
    self._pPvpPlayerRole = nil                          -- pvp对手玩家对象
    self._posPvpPlayerRoleStartPosIndex = cc.p(-1,-1)   -- pvp对手玩家起始位置
    self._pPvpRoleInfo = nil                            -- pvp对手玩家信息
    ----------------------------- 其他在线玩家 ------------------------------------
    self._tOtherPlayerRoles = {}                        -- 其他玩家集合
    ----------------------------- NPC角色 ------------------------------------
    self._tNpcRoles = {}                                -- NPC集合
    ----------------------------- 援助好友 --------------------------------------------
    self._pFriendRole = nil                             -- 援助好友对象
    ----------------------------- 永远放在最下面  ---------------------------------------
    -- 下面是需要保留的数据
    if self._pMainRoleInfo then                         -- 主角玩家数据信息
        return
    else
        self._pMainRoleInfo = nil
    end
    self._posMainRoleLastPosIndexOnWorldMap = nil       -- 主角玩家在家园地图上的最后位置（记录，方便再次回到家园时的位置复原）
    ----------------------------- 其他在线玩家 ------------------------------------
    self._tOtherPlayerRolesInfos = {}                   -- 其他玩家信息集合
    
    
end

-- 循环处理
function RolesManager:update(dt)
    -- 战斗结果已经得出，则逻辑可以屏蔽，避免结算时影响体验
    if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
        if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
            return
        end
    end
    
    -- 主角
    self:updateMainPlayerRole(dt)
    -- PVP对手
    self:updatePvpPlayerRole(dt)
    -- 其他玩家
    self:updateOtherPlayerRoles(dt)
    -- NPC
    self:updateNpcRoles(dt)
    -- 好友
    self:updateFriendRole(dt)
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

function RolesManager:createMainPlayerRoleOnMap(bDebug)    
    if self._pMainPlayerRole == nil then
        -- 创建主角
        self._pMainPlayerRole = require("PlayerRole"):create(self._pMainRoleInfo,"main")
        -- 如果当前血值和怒气值有固定好的数值，则以这些指定数值为准（比如从战斗地图切换到另一张战斗地图，相应的数值需要共享上一张战斗的值）
        if self._nMainPlayerRoleCurHp then
            self._pMainPlayerRole._nCurHp = self._nMainPlayerRoleCurHp
        end
        if self._nMainPlayerRoleCurAnger then
            self._pMainPlayerRole._nCurAnger = self._nMainPlayerRoleCurAnger
        end

        -- 获取主角的位置
        local nDoorId = MapManager:getInstance()._nNextMapDoorIDofEntity
        if nDoorId ~= 0 then
            -- 获取传送门校正后的位置
            local rect = EntitysManager:getInstance():getEntityByID(nDoorId):getBodyRectInMap()
            local pos = cc.p(rect.x + rect.width/2, rect.y)
            local index = MapManager:getInstance():convertPiexlToIndex(pos) 
            self._posMainPlayerRoleStartPosIndex = cc.p(index.x, index.y-0.5)
        else
            if self._posMainRoleLastPosIndexOnWorldMap then   -- 存在记录的位置
                self._posMainPlayerRoleStartPosIndex = self._posMainRoleLastPosIndexOnWorldMap
            else    -- 不存在记录的位置，则直接从地图文件中获取即可
                local pCustomsLayer = MapManager:getInstance()._pTmxMap:getObjectGroup("CustomsLayer")
                local posMainRoleStart = pCustomsLayer:getObject("MainRoleStartPos")
                -- 获取位置的行列索引值
                self._posMainPlayerRoleStartPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(posMainRoleStart["x"], posMainRoleStart["y"]))
            end

        end
        -- 添加主角到地图
        self._pMainPlayerRole:setPositionByIndex(self._posMainPlayerRoleStartPosIndex)
        self._pMainPlayerRole:setPositionZ(self._posMainPlayerRoleStartPosIndex.y*(MapManager:getInstance()._f3DZ))
        MapManager:getInstance()._pTmxMap:addChild(self._pMainPlayerRole, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - self._pMainPlayerRole:getPositionY())
        -- 设置屏幕自动跟随主角
        MapManager:getInstance():setMapFollowMainRole(true)        

    end

    if bDebug == true then
        if self._pDebugLayer == nil then
            self._pDebugLayer = require("RolesDebugLayer"):create()
            MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kRoleDebugLayer)
        end
    end
    
    return self._pMainPlayerRole
end

function RolesManager:createPvpPlayerRoleOnMap(bDebug)  
    if self._pPvpRoleInfo ~= nil then
        if self._pPvpPlayerRole == nil then
            -- 创建Pvp对手
            self._pPvpPlayerRole = require("PlayerRole"):create(self._pPvpRoleInfo,"pvp")
            -- 获取pvp对手的位置
            local pCustomsLayer = MapManager:getInstance()._pTmxMap:getObjectGroup("CustomsLayer")
            local posPvpRoleStart = pCustomsLayer:getObject("PvpRoleStartPos")
            -- 获取位置的行列索引值
            local posPvpPlayerRoleStartPosIndex = MapManager:getInstance():convertPiexlToIndex(cc.p(posPvpRoleStart["x"], posPvpRoleStart["y"]))
            -- 添加pvp对手到地图
            self._pPvpPlayerRole:setPositionByIndex(posPvpPlayerRoleStartPosIndex)
            self._pPvpPlayerRole:setPositionZ(posPvpPlayerRoleStartPosIndex.y*(MapManager:getInstance()._f3DZ))
            MapManager:getInstance()._pTmxMap:addChild(self._pPvpPlayerRole, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - self._pPvpPlayerRole:getPositionY())
        end

        if bDebug == true then
            if self._pDebugLayer == nil then
                self._pDebugLayer = require("RolesDebugLayer"):create()
                MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kRoleDebugLayer)
            end
        end

        return self._pPvpPlayerRole
    end
    return nil
end

function RolesManager:createOtherPlayerRoleOnMap()
    -- 清空地图上显示对象的元素记录
    self._tOtherPlayerRoles = {}
    -- 清空复位宠物相关的记录
    PetsManager:getInstance()._tOtherPetRolesMasters = {}
    PetsManager:getInstance()._tOtherPetRolesInfos = {}
    for kInfo, vInfo in pairs(self._tOtherPlayerRolesInfos) do 
        -- 创建角色
        local role = require("OtherPlayerRole"):create(vInfo)
        -- 获取角色的位置
        local posIndex = MapManager:getInstance()._tOthersPlots[getRandomNumBetween(1,table.getn(MapManager:getInstance()._tOthersPlots))]
        -- 添加角色到地图
        role:setPositionByIndex(posIndex)
        role:setPositionZ(posIndex.y*(MapManager:getInstance()._f3DZ))
        MapManager:getInstance()._pTmxMap:addChild(role, kZorder.kMinRole + MapManager:getInstance()._sMapRectPixelSize.height - role:getPositionY())    
        table.insert(self._tOtherPlayerRoles,role)
        -- 记录当前角色为宠物的主人
        if table.getn(vInfo.pets) ~= 0 then
            table.insert(PetsManager:getInstance()._tOtherPetRolesMasters, role)
            table.insert(PetsManager:getInstance()._tOtherPetRolesInfos, vInfo.pets)        -- 记录宠物的信息
        end
    end
    
end

-- 移除所有 其他玩家角色
function RolesManager:removeAllOtherPlayerRolesOnMap()
    for kRole, vRole in pairs(self._tOtherPlayerRoles) do
        vRole:removeFromParent(true)
    end
    self._tOtherPlayerRoles = {}
    self._tOtherPlayerRolesInfos = {}
end

function RolesManager:createNpcRolesOnMap()
    local pTmxMap = MapManager:getInstance()._pTmxMap
    local pNpcsLayer = pTmxMap:getObjectGroup("NpcsLayer")
    local pBottomLayer = pTmxMap:getObjectGroup("NpcsBottomLayer")
    local pBodyLayer = pTmxMap:getObjectGroup("NpcsBodyLayer")

    -- 获取地图上的npc对象（包括碰撞矩形等等）
    local index = 1
    local name = tostring(index)
    local map = pNpcsLayer:getObject(name)
    while map ~= nil and map["x"] ~= nil do
        local posObj = cc.p(map["x"], map["y"])
        local recBottom = cc.rect(0,0,0,0)
        local recBody = cc.rect(0,0,0,0)
        
        -- 创建npc
        local bottom = pBottomLayer:getObject(name)
        if bottom ~= nil and bottom["x"] ~= nil then
            recBottom = cc.rect(bottom["x"], bottom["y"], bottom["width"], bottom["height"])
        end
        local body = pBodyLayer:getObject(name)
        if body ~= nil and body["x"] ~= nil then
            recBody = cc.rect(body["x"], body["y"], body["width"], body["height"])
        end

        local tAttrisInfo = TableNpcRoles[tonumber(map["ID"])]
        local nID = index

        -- 创建Npc角色
        self:createNpcRole(tAttrisInfo, posObj, recBottom, recBody, nID)

        index = index + 1
        name = tostring(index)
        map = pNpcsLayer:getObject(name)
    end

    return
end

function RolesManager:createNpcRole(tAttrisInfo, pos, recBottom, recBody, id)
    local pNpcRole = nil
    -- 创建角色
    pNpcRole = require("NpcRole"):create(tAttrisInfo, recBottom, recBody)
    pNpcRole._nID = id
    -- NPC角色位置
    pNpcRole:setPosition(recBottom.x + recBottom.width/2, pos.y)
    pNpcRole:setPositionZ(pNpcRole:getPositionIndex().y*(MapManager:getInstance()._f3DZ))
    -- 添加NPC角色到地图
    MapManager:getInstance()._pTmxMap:addChild(pNpcRole,kZorder.kNpcRole)
    -- 添加到集合
    table.insert(self._tNpcRoles, pNpcRole)
    return pNpcRole
end

function RolesManager:createFriendRoleOnMap()
    -- 创建好友（根据角色信息创建）到地图 
    if FriendManager:getInstance():getFriendSkillId() ~= -1 then
        self._pFriendRole = require("FriendRole"):create(FriendManager:getInstance()._nMountFriendSkill)
        MapManager:getInstance()._pTmxMap:addChild(self._pFriendRole, kZorder.kMinRole)  
    end
end

function RolesManager:getNpcRoleByID(id)
    local pNpcRole = nil
    for k,v in pairs(self._tNpcRoles) do
        if v._nID == id then -- 存在
            pNpcRole = v
        end
    end
    return pNpcRole
end

function RolesManager:updateMainPlayerRole(dt)
    -- 主角
    if self._pMainPlayerRole ~= nil then
        if self._pMainPlayerRole._bActive == true then
            self._pMainPlayerRole:updatePlayerRole(dt)
        end
    end
    return
end

function RolesManager:updatePvpPlayerRole(dt)
    -- pvp对手
    if self._pPvpPlayerRole ~= nil then
        if self._pPvpPlayerRole._bActive == true then
            self._pPvpPlayerRole:updatePlayerRole(dt)
        end
    end
    return
end

function RolesManager:updateOtherPlayerRoles(dt)
    -- 其他玩家
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        for k,v in pairs(self._tOtherPlayerRoles) do
            if v._bActive == true then
                v:updatePlayerRole(dt)
            end
        end
    end
    return
end

function RolesManager:updateNpcRoles(dt)
    -- NPC玩家
    for k,v in pairs(self._tNpcRoles) do
        if v._bActive == true then
            v:updateNpcRole(dt)
        else  -- 若已失效，则立即移除并删除
            v:removeFromParent(true)
            table.remove(self._tNpcRoles,k)
            break
        end
    end
    return
end

function RolesManager:updateFriendRole(dt)
    -- 好友
    if self._pFriendRole and self._pFriendRole:isVisible() == true then
        if self._pFriendRole._bActive == true then
            self._pFriendRole:updateFriendRole(dt)
        else  -- 若已失效，则立即移除并删除
            self._pFriendRole:removeFromParent(true)
            self._pFriendRole = nil
        end
    end
    return
end

--根据装备位查询此部位是否装备  没有返回nil 有则返回装备信息
function RolesManager:selectHasEquipmentByType(eType)
    if eType > kEqpLocation.kNone and eType <= kEqpLocation.kTotoalNum then
        for i=1,table.getn(self._pMainRoleInfo.equipemts) do
            local tTempInfo = GetCompleteItemInfo(self._pMainRoleInfo.equipemts[i])
            local pPart = tTempInfo.dataInfo.Part -- 部位
            if eType == pPart then
                return tTempInfo
            end
        end
    end
    return nil
end

-- mainRole set方法
function RolesManager:setMainRole( roleInfo )
    self._pMainRoleInfo = roleInfo
    if self._pMainPlayerRole then
        self._pMainPlayerRole:refreshEquipsWithRoleInfo(roleInfo)   -- 刷新装备信息
        self._pMainPlayerRole._pRoleInfo = roleInfo                 -- 刷新角色信息
    end
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
end

-- pvpRole set方法
function RolesManager:setPvpRole( roleInfo )
    self._pPvpRoleInfo = roleInfo
    if self._pPvpPlayerRole then
        self._pPvpPlayerRole:refreshEquipsWithRoleInfo(roleInfo)   -- 刷新装备信息
        self._pPvpPlayerRole._pRoleInfo = roleInfo                 -- 刷新角色信息
    end
end

-- 设置是否强制所有角色的positionZ为最小值
-- 【主要用于避免弹框时地图上的3d模型与ui层上的3d模型发生异常重叠，弹出有3d模型的对话框时，这里设置需要设置为true】
-- 【关闭时候，需要手动设置为false】
function RolesManager:setForceMinPositionZ(bForce, value)
    -- 玩家角色
    if self._pMainPlayerRole then
        self._pMainPlayerRole._bForceMinPositionZ = bForce
        if bForce == true then
            self._pMainPlayerRole._nForceMinPositionZValue = value
        else
            self._pMainPlayerRole._nForceMinPositionZValue = 0
        end
        self._pMainPlayerRole:refreshZorder()
    end
   
    -- Pvp对手
    if self._pPvpPlayerRole then
        self._pPvpPlayerRole._bForceMinPositionZ = bForce
        if bForce == true then
            self._pPvpPlayerRole._nForceMinPositionZValue = value
        else
            self._pPvpPlayerRole._nForceMinPositionZValue = 0
        end
        self._pPvpPlayerRole:refreshZorder()
    end
    
    -- NPC角色
    local tNpcArray = self._tNpcRoles
    for i=1,#tNpcArray do
        tNpcArray[i]._bForceMinPositionZ = bForce
        if bForce == true then
            tNpcArray[i]._nForceMinPositionZValue = value
        else
            tNpcArray[i]._nForceMinPositionZValue = 0
        end
        tNpcArray[i]:refreshZorder()
    end
    
    -- 其他玩家角色
    local tOtherPlayersArray = self._tOtherPlayerRoles
    for i=1,#tOtherPlayersArray do
        tOtherPlayersArray[i]._bForceMinPositionZ = bForce
        if bForce == true then
            tOtherPlayersArray[i]._nForceMinPositionZValue = value
        else
            tOtherPlayersArray[i]._nForceMinPositionZValue = 0
        end
        tOtherPlayersArray[i]:refreshZorder()
    end
    
end

-- 处理战斗结果
function RolesManager:disposeWhenBattleResult()
    if self._pMainPlayerRole ~= nil then
        if self._pMainPlayerRole._bActive == true then
        
            if self._pMainPlayerRole:isUnusualState() == false then     -- 正常状态
                self._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand, true)
                --print("人物回到站立！")
            end
            
            self._pMainPlayerRole._refGenAttackButton:add()
            for k, v in pairs(self._pMainPlayerRole._tRefSkillButtons) do 
                v:add()
            end
            self._pMainPlayerRole._refStick:add()
        end
    end
end

-- 判断指定矩形是否与当前主角玩家的bottom发生碰撞
function RolesManager:isRectCollidingOnMainPlayerBottoms(rect)
    local bCollide = false
    local bottom = self._pMainPlayerRole:getBottomRectInMap()
    if cc.rectIntersectsRect(rect, bottom) == true then
        bCollide = true
    end
    return bCollide
end

-- 判断指定矩形是否与当前PVP玩家的bottom发生碰撞
function RolesManager:isRectCollidingOnPvpPlayerBottoms(rect)
    local bCollide = false
    if self._pPvpPlayerRole then
        local bottom = self._pPvpPlayerRole:getBottomRectInMap()
        if cc.rectIntersectsRect(rect, bottom) == true then
            bCollide = true
        end
    end
    return bCollide
end

