--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SkillsManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/8
-- descrip:   技能管理器
--===================================================
SkillsManager = {}

-- 主动技能数量
activeSkillNum = TableConstants.ActiveSkillNumber.Value + 1
-- 被动技能数量
passiveSkillNum = TableConstants.PassiveSkillNumber.Value
-- 天赋数量
talentSkillNum = TableConstants.TalentNumber.Value

local instance = nil

-- 单例
function SkillsManager:getInstance()
    if not instance then
        instance = SkillsManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function SkillsManager:clearCache()
    
    self._pDebugLayer = nil                                     -- 调试层对象
    ---------------------------------- 主角玩家的技能 -----------------------------------------------------
    self._tMainRoleSkills = {}                                  -- 玩家主角技能集合
    ---------------------------------- 主角玩家宠物的技能（只创建保留当前上阵的宠物技能） ------------------------------------------
    self._tCurMainPetRoleSkills = {}                            -- 玩家当前宠物技能集合 格式：{skill1,skill2,skill3,skill4}
    ---------------------------------- 好友技能 ------------------------------------------------------------------
    self._pFriendSkill = nil                                    -- 玩家当前配置的好友援助技能
    ---------------------------------- PVP对手的技能 ------------------------------------------------------
    self._tPvpRoleSkills = {}                                   -- Pvp对手技能集合
    self._tPvpRoleSkillsLevels = {}
    self._tPvpRoleSkillsLevels.actvSkills = {}                  -- Pvp角色主动技能等级 {{id=1,level=1},{},{}.....}
    self._tPvpRoleSkillsLevels.pasvSkills = {}                  -- Pvp角色被动技能等级{{id=1,level=1},{},{}.....}
    self._tPvpRoleSkillsLevels.consSkills = {}                  -- Pvp角色天赋技能等级{{id=1,level=1},{},{}.....}
    self._tPvpRoleMountAngerSkills = {}                         -- 服务器返回的Pvp角色当前已经装备怒气技能 {{id=1,level=1}}    只有一项，如果length为0，就是未装配
    self._tPvpRoleMountActvSkills = {}                          -- 服务器返回的Pvp角色当前已经装备的主动技能 {{id=1,level=1},{},{}.....}
    self._tPvpRoleMountPasvSkills = {}                          -- 服务器返回的Pvp角色当前已经装备的被动技能 {{id=1,level=1},{},{}.....}
    ---------------------------------- PVP玩家宠物的技能（只创建保留当前上阵的宠物技能） ------------------------------------------
    self._tCurPvpPetRoleSkills = {}                             -- PVP当前宠物技能集合 格式：{skill1,skill2,skill3,skill4}
    ---------------------------------- 野怪的技能 -----------------------------------------------------------
    self._tMonstersSkills = {}                                  -- 野怪技能集合{{波，波，波...},{波，波，波....},{波，波，波....}...}
    ---------------------------------- 实体的技能 ----------------------------------------------------------
    self._tEntitysSkills = {}                                   -- 实体技能集合
    ---------------------------------- 永远放在最后 ------------------------------------------------------
    if self._pActSkillData then
    	return
    else 
        self._pActSkillData = nil                               -- 数据表 
        self:initSkillTableData()                               -- 数据表初始化
    end
    self._tMainRoleSkillsLevels = {}                            -- 玩家角色激活的【所有技能】
    self._tMainRoleSkillsLevels.actvSkills = {}                 -- 玩家角色主动技能等级 {{id=1,level=1},{},{}.....}
    self._tMainRoleSkillsLevels.pasvSkills = {}                 -- 玩家角色被动技能等级{{id=1,level=1},{},{}.....}
    self._tMainRoleSkillsLevels.consSkills = {}                 -- 玩家角色天赋技能等级{{id=1,level=1},{},{}.....}

    self._tMainRoleMountSkills = {}                             -- 服务器返回的玩家角色当前已经装备的技能(包括主动和怒气) {{id=1,level=1},{},{}.....}
    self._tMainRoleMountAngerSkills = {}                        -- 服务器返回的玩家角色当前已经装备怒气技能 {{id=1,level=1}}    只有一项，如果length为0，就是未装配
    self._tMainRoleMountActvSkills = {}                         -- 服务器返回的玩家角色当前已经装备的主动技能 {{id=1,level=1},{},{}.....}
    self._tMainRoleMountPasvSkills = {}                         -- 服务器返回的玩家角色当前已经激活的被动技能 {{id=1,level=1},{},{}.....}
    
    self._bGetInitData = false                                  -- 是否接受服务器第一次数据

end

-- 循环处理
function SkillsManager:update(dt)
  -------------------------------------移除释放逻辑------------------------------------
    -- 玩家主角技能集合的遍历
    for k,v in pairs(self._tMainRoleSkills) do
        if v._bActive == false then -- 若已失效，则立即移除并删除
            v:removeFromParent(true)
            table.remove(self._tMainRoleSkills,k)
            break
        end
    end

    -- 玩家主角宠物的技能集合的遍历
    for k,v in pairs(self._tCurMainPetRoleSkills) do
        if v._bActive == false then  -- 若已失效，则立即移除并删除
            v:removeFromParent(true)
            table.remove(self._tCurMainPetRoleSkills,k)
            break
        end
    end

    -- 好友技能的遍历
    if self._pFriendSkill then
        if self._pFriendSkill._bActive == false then-- 若已失效，则立即移除并删除
            self._pFriendSkill:removeFromParent(true)
            self._pFriendSkill = nil
        end
    end

    -- PVP对手技能集合的遍历
    for k,v in pairs(self._tPvpRoleSkills) do
        if v._bActive == false then  -- 若已失效，则立即移除并删除
            v:removeFromParent(true)
            table.remove(self._tPvpRoleSkills,k)
            break
        end
    end

    -- PVP对手宠物技能集合的遍历
    for k,v in pairs(self._tCurPvpPetRoleSkills) do
        if v._bActive == false then  -- 若已失效，则立即移除并删除
            v:removeFromParent(true)
            table.remove(self._tCurPvpPetRoleSkills,k)
            break
        end
    end

    -- 野怪技能集合的遍历
    local nCurMonsterAreaIndex = MonstersManager:getInstance()._nCurMonsterAreaIndex
    local nCurMonsterWaveIndex = MonstersManager:getInstance()._nCurMonsterWaveIndex
    if nCurMonsterAreaIndex > 0 and nCurMonsterWaveIndex > 0 then
        for k,v in pairs(self._tMonstersSkills[nCurMonsterAreaIndex][nCurMonsterWaveIndex]) do
            if v._bActive == false then  -- 若已失效，则立即移除并删除 
                v:removeFromParent(true)
                table.remove(self._tMonstersSkills[nCurMonsterAreaIndex][nCurMonsterWaveIndex],k)
                break
            end
        end
    end

    -- 实体技能集合的遍历
    for k,v in pairs(self._tEntitysSkills) do
        if v._bActive == false then  -- 若已失效，则立即移除并删除
            v:removeFromParent(true)
            table.remove(self._tEntitysSkills,k)
            break
        end
    end
    
    -----------------------------------正常运作逻辑---------------------------------------------------------------
    
    -- 玩家主角技能集合的遍历
    for k,v in pairs(self._tMainRoleSkills) do
        if v._bActive == true then
            v:update(dt)
        end
    end
    
    -- 玩家主角宠物的技能集合的遍历
    for k,v in pairs(self._tCurMainPetRoleSkills) do
        if v._bActive == true then
            v:update(dt)
        end
    end
    
    -- 好友技能的遍历
    if self._pFriendSkill then
        if self._pFriendSkill._bActive == true then
            self._pFriendSkill:update(dt)
        end
    end
    
    -- PVP对手技能集合的遍历
    for k,v in pairs(self._tPvpRoleSkills) do
        if v._bActive == true then
            v:update(dt)
        end
    end
    
    -- PVP对手宠物技能集合的遍历
    for k,v in pairs(self._tCurPvpPetRoleSkills) do
        if v._bActive == true then
            v:update(dt)
        end
    end
    
    -- 野怪技能集合的遍历
    local nCurMonsterAreaIndex = MonstersManager:getInstance()._nCurMonsterAreaIndex
    local nCurMonsterWaveIndex = MonstersManager:getInstance()._nCurMonsterWaveIndex
    if nCurMonsterAreaIndex > 0 and nCurMonsterWaveIndex > 0 then
        for k,v in pairs(self._tMonstersSkills[nCurMonsterAreaIndex][nCurMonsterWaveIndex]) do
            if v._bActive == true then
                v:update(dt)
            end
        end
    end

    -- 实体技能集合的遍历
    for k,v in pairs(self._tEntitysSkills) do
        if v._bActive == true then
            v:update(dt)
        end
    end
    
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

-- 创建调试层
function SkillsManager:createAllSkills(bDebug)
    -------------------------------- 创建主角的技能集合 ---------------------------------------
    local pMainRole = RolesManager:getInstance()._pMainPlayerRole 
    -- 添加玩家角色的主动技能集合
    for k,v in pairs(self._tMainRoleMountActvSkills) do
        local pSkillInfo = self:getMainRoleSkillDataByID(v.id,v.level)
        local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
        local pSkill = require(pClassName):create(pMainRole, pSkillInfo)
        table.insert(self._tMainRoleSkills,pSkill)
        pMainRole._tSkills[k+1] = pSkill
        MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
    end 
    
    -- 添加玩家角色普通攻击 技能
    local pSkillInfo = self:getMainRoleSkillDataByID((RolesManager:getInstance()._pMainRoleInfo.roleCareer-1)*activeSkillNum + 1,0)
    local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
    local pSkill = require(pClassName):create(pMainRole, pSkillInfo)
    table.insert(self._tMainRoleSkills,pSkill)
    pMainRole._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack] = pSkill
    MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
    
    -- 添加玩家角色怒气攻击 技能
    for k,v in pairs(self._tMainRoleMountAngerSkills) do
        local pSkillInfo = self:getMainRoleSkillDataByID(v.id,v.level)
        local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
        local pSkill = require(pClassName):create(pMainRole, pSkillInfo)
        table.insert(self._tMainRoleSkills,pSkill)
        pMainRole._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] = pSkill
        MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
    end
    
    -- 添加玩家角色的被动技能数据集合的缓存
    for kPassive, vPassive in pairs(self._tMainRoleSkillsLevels.pasvSkills ) do 
        if vPassive.level > 0 then
            local skillData = self:getMainRoleSkillDataByID(vPassive.id, vPassive.level)
            pMainRole._tPassiveSkillInfos[skillData.TypeID] = skillData
        end
    end
    
    -------------------------------- 创建PVP对手的技能集合 ---------------------------------------
    local pPvpRole = RolesManager:getInstance()._pPvpPlayerRole
    if pPvpRole then
        for k,v in pairs(self._tPvpRoleMountActvSkills) do
            local pSkillInfo = self:getPvpRoleSkillDataByID(v.id,v.level)
            local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
            local pSkill = require(pClassName):create(pPvpRole, pSkillInfo)
            table.insert(self._tPvpRoleSkills,pSkill)
            pPvpRole._tSkills[k+1] = pSkill
            MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
        end
        
        -- 添加Pvp对手的普通攻击 技能
        local pSkillInfo = self:getPvpRoleSkillDataByID((RolesManager:getInstance()._pPvpRoleInfo.roleCareer-1)*activeSkillNum + 1,0)
        local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
        local pSkill = require(pClassName):create(pPvpRole, pSkillInfo)
        table.insert(self._tPvpRoleSkills,pSkill)
        pPvpRole._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack] = pSkill
        MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
        
        -- 添加玩家角色怒气攻击 技能
        for k,v in pairs(self._tPvpRoleMountAngerSkills) do
            local pSkillInfo = self:getPvpRoleSkillDataByID(v.id,v.level)
            local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
            local pSkill = require(pClassName):create(pPvpRole, pSkillInfo)
            table.insert(self._tPvpRoleSkills,pSkill)
            pPvpRole._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] = pSkill
            MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
        end
        
        -- 添加PVP对手的被动技能数据集合的缓存
        for kPassive, vPassive in pairs(self._tPvpRoleSkillsLevels.pasvSkills ) do 
            if vPassive.level > 0 then
                local skillData = self:getPvpRoleSkillDataByID(vPassive.id, vPassive.level)
                pPvpRole._tPassiveSkillInfos[skillData.TypeID] = skillData
            end
        end
    end
    
    -------------------------------- 创建主角宠物的技能集合 ---------------------------------------
    local pMainPetRole = PetsManager:getInstance()._pMainPetRole 
    -- 添加玩家角色的技能集合
    if pMainPetRole then
        local skillIDsIndexInTable = math.ceil((pMainPetRole._nLevel+0.1)/10)     -- （向下取整）每隔10级为一个组技能集合阶段
        local tSkillIDs = {}
        for k,v in pairs(pMainPetRole._pRoleInfo.SkillRequiredLv) do
            if pMainPetRole._kQuality >= v then
                table.insert(tSkillIDs, pMainPetRole._pRoleInfo.SkillIDs[skillIDsIndexInTable][k])
            end
        end
        for kID,vID in pairs(tSkillIDs) do
            local pSkillInfo = TablePetsSkills[vID]
            local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.PvrName)
            local pSkill = require(pClassName):create(pMainPetRole, pSkillInfo)
            table.insert(self._tCurMainPetRoleSkills,pSkill)
            table.insert(pMainPetRole._tSkills,pSkill)
            MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
        end
    end
    
    -------------------------------- 创建PVP宠物的技能集合 ---------------------------------------
    local pPvpPetRole = PetsManager:getInstance()._pPvpPetRole 
    -- 添加PVP角色宠物的技能集合
    if pPvpPetRole then
        local skillIDsIndexInTable = math.ceil((pPvpPetRole._nLevel+0.1)/10)     -- （向下取整）每隔10级为一个组技能集合阶段
        local tSkillIDs = {}
        for k,v in pairs(pPvpPetRole._pRoleInfo.SkillRequiredLv) do
            if pPvpPetRole._kQuality >= v then
                table.insert(tSkillIDs, pPvpPetRole._pRoleInfo.SkillIDs[skillIDsIndexInTable][k])
            end
        end
        for kID,vID in pairs(tSkillIDs) do
            local pSkillInfo = TablePetsSkills[vID]
            local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.PvrName)
            local pSkill = require(pClassName):create(pPvpPetRole, pSkillInfo)
            table.insert(self._tCurPvpPetRoleSkills,pSkill)
            table.insert(pPvpPetRole._tSkills,pSkill)
            MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
        end
    end
    -------------------------------- 创建好友技能 ---------------------------------------
    if RolesManager:getInstance()._pFriendRole then
        local pSkillInfo = TableFriendSkills[FriendManager:getInstance():getFriendSkillId()]
        local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.PvrName)
        local pSkill = require(pClassName):create(RolesManager:getInstance()._pFriendRole, pSkillInfo)
        self._pFriendSkill = pSkill
        RolesManager:getInstance()._pFriendRole._pSkill = pSkill
        MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
    end

    -------------------------------- 创建其他玩家的技能集合 ---------------------------------------
    
    -------------------------------- 创建Monster的技能集合 ----------------------------------------   
    for areaIndex = 1, #MonstersManager:getInstance()._tMonsters do
        self._tMonstersSkills[areaIndex] = {}  -- 插入新的一个区域
        for kMonsterWave, vMonsterWave in pairs(MonstersManager:getInstance()._tMonsters[areaIndex]) do
            self._tMonstersSkills[areaIndex][kMonsterWave] = {}  -- 插入当前区域的新的一波
            for kMonster, vMonster in pairs(vMonsterWave) do
                for kSkillID,vSkillID in pairs(vMonster._pRoleInfo.SkillIDs) do
                    -- 创建野怪技能
                    local pMonsterSkill = self:createMonsterSkill(kSkillID,vSkillID,vMonster)
                    -- 添加到集合
                    table.insert(self._tMonstersSkills[areaIndex][kMonsterWave],pMonsterSkill)
                end 
            end
        end
    end
    -------------------------------- 创建Entitys的技能集合 ---------------------------------------- 
    for kEntity, vEntity in pairs(EntitysManager:getInstance()._tEntitys) do
        if vEntity._pEntityInfo.SkillID ~= 0 and vEntity._pEntityInfo.SkillID ~= nil then  -- 配有技能
            local pEntitySkill = nil
            local pEntitySkillInfo = TableEntitysSkills[vEntity._pEntityInfo.SkillID]
            if vEntity._kEntityType == kType.kEntity.kPoisonPool then
                pEntitySkill = require("PoisonPoolSkill"):create(vEntity, pEntitySkillInfo)
            elseif vEntity._kEntityType == kType.kEntity.kSwamp then
                pEntitySkill = require("SwampSkill"):create(vEntity, pEntitySkillInfo)
            elseif vEntity._kEntityType == kType.kEntity.kBomb then
                pEntitySkill = require("BombSkill"):create(vEntity, pEntitySkillInfo)
            elseif vEntity._kEntityType == kType.kEntity.kSpikeRock then
                pEntitySkill = require("SpikeRockSkill"):create(vEntity, pEntitySkillInfo)
            elseif vEntity._kEntityType == kType.kEntity.kRollHammer then
                pEntitySkill = require("RollHammerSkill"):create(vEntity, pEntitySkillInfo)
            elseif vEntity._kEntityType == kType.kEntity.kFireMachine then
                pEntitySkill = require("FireMachineSkill"):create(vEntity, pEntitySkillInfo)
            end
            if pEntitySkill then
                MapManager:getInstance()._pTmxMap:addChild(pEntitySkill, kZorder.kMinSkill)             
                table.insert(self._tEntitysSkills,pEntitySkill)
                vEntity._pSkill = pEntitySkill
            end
        end
    end 
    ---------------------------------------------------------------------------------------------
    if bDebug == true then
        self._pDebugLayer = require("SkillsDebugLayer"):create()
        MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kSkillDebugLayer)
    end
end

function SkillsManager:createMonsterSkill(indexOfSkillIDs, id, monster)
    local pSkillInfo = TableMonsterSkills[id]
    local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
    local pMonsterSkill = nil
    pMonsterSkill = require(pClassName):create(monster, pSkillInfo)  
    monster._tSkills[indexOfSkillIDs] = pMonsterSkill
    monster._tReverseIDSkills[id] = pMonsterSkill
    MapManager:getInstance()._pTmxMap:addChild(pMonsterSkill, kZorder.kMinSkill)
    return pMonsterSkill
end

-- 设置是否强制所有技能的positionZ为最小值
function SkillsManager:setForceMinPositionZ(bForce, value)
    -- 玩家主角技能集合的遍历
    for k,v in pairs(self._tMainRoleSkills) do
        v._bForceMinPositionZ = bForce
        if bForce == true then
            v._nForceMinPositionZValue = value
        else
            v._nForceMinPositionZValue = 0
        end
        v:refreshZorder()
    end
    -- Pvp对手技能集合的遍历
    for k,v in pairs(self._tPvpRoleSkills) do
        v._bForceMinPositionZ = bForce
        if bForce == true then
            v._nForceMinPositionZValue = value
        else
            v._nForceMinPositionZValue = 0
        end
        v:refreshZorder()
    end
    
    -- 玩家主角宠物技能集合的遍历
    for k,v in pairs(self._tCurMainPetRoleSkills) do
        v._bForceMinPositionZ = bForce
        if bForce == true then
            v._nForceMinPositionZValue = value
        else
            v._nForceMinPositionZValue = 0
        end
        v:refreshZorder()
    end
    
    -- PVP主角宠物技能集合的遍历
    for k,v in pairs(self._tCurPvpPetRoleSkills) do
        v._bForceMinPositionZ = bForce
        if bForce == true then
            v._nForceMinPositionZValue = value
        else
            v._nForceMinPositionZValue = 0
        end
        v:refreshZorder()
    end
    
    -- 野怪技能集合的遍历
    local nCurMonsterAreaIndex = MonstersManager:getInstance()._nCurMonsterAreaIndex
    local nCurMonsterWaveIndex = MonstersManager:getInstance()._nCurMonsterWaveIndex
    if nCurMonsterAreaIndex > 0 and nCurMonsterWaveIndex > 0 then
        for k,v in pairs(self._tMonstersSkills[nCurMonsterAreaIndex][nCurMonsterWaveIndex]) do
            v._bForceMinPositionZ = bForce
            if bForce == true then
                v._nForceMinPositionZValue = value
            else
                v._nForceMinPositionZValue = 0
            end
            v:refreshZorder()
        end
    end
    
    -- 实体技能集合的遍历
    for k,v in pairs(self._tEntitysSkills) do
        v._bForceMinPositionZ = bForce
        if bForce == true then
            v._nForceMinPositionZValue = value
        else
            v._nForceMinPositionZValue = 0
        end
        v:refreshZorder()
    end
    
end

-- （主角玩家的宠物）切换到下一个宠物的技能
-- 参数：如果index有值，则切换到指定index的宠物的技能
--       如果index没有值，则按照顺序切换到下一个宠物的技能
function SkillsManager:changeToNextMainPetRoleSkillsOnMap()
    local pMainPetRole = PetsManager:getInstance()._pMainPetRole
    if pMainPetRole then
        self._tCurMainPetRoleSkills = {}
        -- 添加玩家角色的技能集合
        local skillIDsIndexInTable = math.ceil((pMainPetRole._nLevel+0.1)/10)     -- （向下取整）每隔10级为一个组技能集合阶段
        local tSkillIDs = {}
        for k,v in pairs(pMainPetRole._pRoleInfo.SkillRequiredLv) do
            if pMainPetRole._kQuality >= v then
                table.insert(tSkillIDs, pMainPetRole._pRoleInfo.SkillIDs[skillIDsIndexInTable][k])
            end
        end
        for kID,vID in pairs(tSkillIDs) do
            local pSkillInfo = TablePetsSkills[vID]
            local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.PvrName)
            local pSkill = require(pClassName):create(pMainPetRole, pSkillInfo)
            table.insert(self._tCurMainPetRoleSkills,pSkill)
            table.insert(pMainPetRole._tSkills,pSkill)
            MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
        end
    end
    
end

-- （PVP玩家的宠物）切换到下一个宠物的技能
-- 参数：如果index有值，则切换到指定index的宠物的技能
--       如果index没有值，则按照顺序切换到下一个宠物的技能
function SkillsManager:changeToNextPvpPetRoleSkillsOnMap()
    local pPvpPetRole = PetsManager:getInstance()._pPvpPetRole 
    if pPvpPetRole then
        -- 添加PVP角色宠物的技能集合
        local skillIDsIndexInTable = math.ceil((pPvpPetRole._nLevel+0.1)/10)     -- （向下取整）每隔10级为一个组技能集合阶段
        local tSkillIDs = {}
        for k,v in pairs(pPvpPetRole._pRoleInfo.SkillRequiredLv) do
            if pPvpPetRole._kQuality >= v then
                table.insert(tSkillIDs, pPvpPetRole._pRoleInfo.SkillIDs[skillIDsIndexInTable][k])
            end
        end
        for kID,vID in pairs(tSkillIDs) do
            local pSkillInfo = TablePetsSkills[vID]
            local pClassName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.ClassName
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.PvrName)
            local pSkill = require(pClassName):create(pPvpPetRole, pSkillInfo)
            table.insert(self._tCurPvpPetRoleSkills,pSkill)
            table.insert(pPvpPetRole._tSkills,pSkill)
            MapManager:getInstance()._pTmxMap:addChild(pSkill, kZorder.kMinSkill)
        end
    end
    
end

-------------------------------------------------------技能数据表操作相关－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
 
function SkillsManager:initSkillTableData()
    self._pActSkillData = {}

    for i=1,table.getn(TableRoleSkills) do
        if self._pActSkillData[TableRoleSkills[i].RoleID] == nil then
            self._pActSkillData[TableRoleSkills[i].RoleID] = {}
        end

        if self._pActSkillData[TableRoleSkills[i].RoleID][TableRoleSkills[i].ID] == nil then
            self._pActSkillData[TableRoleSkills[i].RoleID][TableRoleSkills[i].ID] = {}
        end

        self:setSkillTempleteData(TableRoleSkills[i])
        self._pActSkillData[TableRoleSkills[i].RoleID][TableRoleSkills[i].ID][TableRoleSkills[i].Level] = TableRoleSkills[i]
    end
    
    for i=1,table.getn(TableRolePassiveSkills) do
        if self._pActSkillData[TableRolePassiveSkills[i].RoleID] == nil then
            self._pActSkillData[TableRolePassiveSkills[i].RoleID] = {}
        end

        if self._pActSkillData[TableRolePassiveSkills[i].RoleID][TableRolePassiveSkills[i].ID] == nil then
            self._pActSkillData[TableRolePassiveSkills[i].RoleID][TableRolePassiveSkills[i].ID] = {}
        end

        self:setSkillTempleteData(TableRolePassiveSkills[i])
        self._pActSkillData[TableRolePassiveSkills[i].RoleID][TableRolePassiveSkills[i].ID][TableRolePassiveSkills[i].Level] = TableRolePassiveSkills[i]
    end
    
    for i=1,table.getn(TableRoleTalent) do
        if self._pActSkillData[TableRoleTalent[i].RoleID] == nil then
            self._pActSkillData[TableRoleTalent[i].RoleID] = {}
        end

        if self._pActSkillData[TableRoleTalent[i].RoleID][TableRoleTalent[i].ID] == nil then
            self._pActSkillData[TableRoleTalent[i].RoleID][TableRoleTalent[i].ID] = {}
        end

        self:setSkillTempleteData(TableRoleTalent[i])
        self._pActSkillData[TableRoleTalent[i].RoleID][TableRoleTalent[i].ID][TableRoleTalent[i].Level] = TableRoleTalent[i]
    end
end

function SkillsManager:updateMountPasvSkills()
    local mountPasvSkills = {}
    for i=1,table.getn(self._tMainRoleSkillsLevels.pasvSkills) do
        local level = self._tMainRoleSkillsLevels.pasvSkills[i].level
        if level > 0 then
            table.insert(mountPasvSkills,self._tMainRoleSkillsLevels.pasvSkills[i])
        end
    end

    self._tMainRoleMountPasvSkills = mountPasvSkills
end

function SkillsManager:setSkillTempleteData(skillData)
    skillData.skillIcon = TableTempleteSkills[skillData.TempleteID].SkillIcon
    skillData.SkillName = TableTempleteSkills[skillData.TempleteID].SkillName
end

function SkillsManager:getMainRoleSkillDataByID(id,level)
    if level == -1 then
    	return nil
    end
    return self._pActSkillData[RolesManager:getInstance()._pMainRoleInfo.roleCareer][id][level]
end

function SkillsManager:getPvpRoleSkillDataByID(id,level)
    if level == -1 then
        return nil
    end
    return self._pActSkillData[RolesManager:getInstance()._pPvpRoleInfo.roleCareer][id][level]
end

function SkillsManager:setMainRoleSkillLevelByID(id,level)
   
    for i=1,table.getn(self._tMainRoleMountSkills) do
        if self._tMainRoleMountSkills[i].id == id then
            self._tMainRoleMountSkills[i].level = level
            --return
        end
    end
    
    for i=1,table.getn(self._tMainRoleMountAngerSkills) do
        if self._tMainRoleMountAngerSkills[i].id == id then
            self._tMainRoleMountAngerSkills[i].level = level
            --return
        end
    end
    
    for i=1,table.getn(self._tMainRoleMountActvSkills) do
        if self._tMainRoleMountActvSkills[i].id == id then
            self._tMainRoleMountActvSkills[i].level = level
            --return
        end
    end
    
    for i=1,table.getn(self._tMainRoleMountActvSkills) do
        if self._tMainRoleMountActvSkills[i].id == id then
            self._tMainRoleMountActvSkills[i].level = level
            --return
        end
    end
    
    for i=1,table.getn(self._tMainRoleSkillsLevels.actvSkills) do
        if self._tMainRoleSkillsLevels.actvSkills[i].id == id then
            self._tMainRoleSkillsLevels.actvSkills[i].level = level
            --return
        end
    end

    for i=1,table.getn(self._tMainRoleSkillsLevels.pasvSkills) do
        if self._tMainRoleSkillsLevels.pasvSkills[i].id == id then
            self._tMainRoleSkillsLevels.pasvSkills[i].level = level
            --return 
        end
    end

    for i=1,table.getn(self._tMainRoleSkillsLevels.consSkills) do
        if self._tMainRoleSkillsLevels.consSkills[i].id == id then
            self._tMainRoleSkillsLevels.consSkills[i].level = level
            --return 
        end
    end

end

function SkillsManager:getMainRoleBeMountById(id)
	for i=1,table.getn(self._tMainRoleMountSkills) do
        if self._tMainRoleMountSkills[i].id == id then
       	    return true
       end
    end
    
    return false
end

function SkillsManager:getMainRoleGenAttackSkillDataByRoleId( id )
    return self._pActSkillData[RolesManager:getInstance()._pMainRoleInfo.roleCareer][1+activeSkillNum*(RolesManager:getInstance()._pMainRoleInfo.roleCareer-1)][0]
end

function SkillsManager:getMainRoleSkillIconByID(id)
    return self._pActSkillData[RolesManager:getInstance()._pMainRoleInfo.roleCareer][id][1].skillIcon
end

function SkillsManager:getSkillIconByID(roleCareer,id,level)
    return self._pActSkillData[roleCareer][id][level]
end

function SkillsManager:getMainRoleOpenLevelByID(id)
    return self._pActSkillData[RolesManager:getInstance()._pMainRoleInfo.roleCareer][id][1].RequiredLevel
end

function SkillsManager:getMainRoleLevelByID(id)
    for i=1,table.getn(self._tMainRoleSkillsLevels.actvSkills) do
        if self._tMainRoleSkillsLevels.actvSkills[i].id == id then
            return self._tMainRoleSkillsLevels.actvSkills[i].level
		end
	end
	
    for i=1,table.getn(self._tMainRoleSkillsLevels.pasvSkills) do
        if self._tMainRoleSkillsLevels.pasvSkills[i].id == id then
            return self._tMainRoleSkillsLevels.pasvSkills[i].level
        end
    end
    
    for i=1,table.getn(self._tMainRoleSkillsLevels.consSkills) do
        if self._tMainRoleSkillsLevels.consSkills[i].id == id then
            return self._tMainRoleSkillsLevels.consSkills[i].level
        end
    end
    
    return -1
end

function SkillsManager:checkSkills()
    local activeSkillNum = TableConstants.ActiveSkillNumber.Value + 1
    local activeSkillIdStart = 1
    local roleId = RolesManager:getInstance()._pMainRoleInfo.roleCareer
    for i=activeSkillIdStart,activeSkillNum-1 do
        local icon = SkillsManager:getInstance():getMainRoleSkillIconByID(activeSkillNum*(roleId-1) + i + 1)
        local level = SkillsManager:getInstance():getMainRoleLevelByID(activeSkillNum*(roleId-1)  + i + 1)
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(activeSkillNum*(roleId-1)  + i + 1 , level)
        -- 是否可升级
        if level < 20 then
            local nextRequireLevel = SkillsManager:getInstance():getMainRoleSkillDataByID(activeSkillNum*(roleId-1)  + i + 1 , level+1).RequiredLevel
            if nextRequireLevel <= RolesManager._pMainRoleInfo.level then
                NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "技能按钮" , value = true})
            end
        end

    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

