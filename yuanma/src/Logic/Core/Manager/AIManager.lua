--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  AIManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/15
-- descrip:   战斗AI管理器
--===================================================
AIManager = {}

local instance = nil

-- 单例
function AIManager:getInstance()
    if not instance then
        instance = AIManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function AIManager:clearCache()
    
end

-- 循环处理
function AIManager:update(dt)
    -- 战斗结果已经得出，则不再做任何战斗逻辑表现
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    
    
end

----------------------------------------- 基础模块相关 ----------------------------------------------------------
-- 根据obj获取sideType
function AIManager:getsideType(obj)
    -- 判定obj是 “我方” 或者 “敌方” 
    local sideType = ""   -- "us-side"  "foe-side"
    
    if obj._kGameObjType == kType.kGameObj.kRole then
        if obj._kRoleType == kType.kRole.kPlayer then
            if obj._strCharTag == "main" then
                sideType = "us-side"
            elseif obj._strCharTag == "pvp" then
                sideType = "foe-side"
            end
        elseif obj._kRoleType == kType.kRole.kPet then
            if obj._strCharTag == "main" then
                sideType = "us-side"
            elseif obj._strCharTag == "pvp" then
                sideType = "foe-side"
            end
        elseif obj._kRoleType == kType.kRole.kFriend then
            sideType = "us-side"
        elseif obj._kRoleType == kType.kRole.kMonster then
            sideType = "foe-side"
        end
    elseif obj._kGameObjType == kType.kGameObj.kEntity then
        sideType = "foe-side"
    end
    
    return sideType
end

-- 根据sideType获取对应groupType的群体集合
function AIManager:getGroup(obj, sideType, groupType)
    local group = {}
    if sideType == "us-side" then   -- "我方"
        if groupType == kType.kTargetGroupType.kOpposite then   -- 对方
            for k, v in pairs(MonstersManager:getInstance()._tCurWaveMonsters) do
                table.insert(group, v)
            end
            for k, v in pairs(EntitysManager:getInstance()._tEntitys) do
                -- 可以被打
                if v._pEntityInfo.CanBeHurted == 1 then
                    table.insert(group, v)
                end
            end
            if RolesManager:getInstance()._pPvpPlayerRole then
                table.insert(group, RolesManager:getInstance()._pPvpPlayerRole)
            end
            if PetsManager:getInstance()._pPvpPetRole then
                table.insert(group, PetsManager:getInstance()._pPvpPetRole)
            end
        elseif groupType == kType.kTargetGroupType.kSelfs then    -- 己方
            if obj ~= RolesManager:getInstance()._pMainPlayerRole then
                table.insert(group,RolesManager:getInstance()._pMainPlayerRole)
            end
            if PetsManager:getInstance()._pMainPetRole then
                if obj ~= PetsManager:getInstance()._pMainPetRole then
                    table.insert(group, PetsManager:getInstance()._pMainPetRole)
                end
            end
        elseif groupType == kType.kTargetGroupType.kOneSelf then    -- 自己
            table.insert(group,obj)
        end
    elseif sideType == "foe-side" then  -- "敌方"
        if groupType == kType.kTargetGroupType.kOpposite then   -- 对方
            table.insert(group, RolesManager:getInstance()._pMainPlayerRole)
            if PetsManager:getInstance()._pMainPetRole then
                table.insert(group, PetsManager:getInstance()._pMainPetRole)
            end
        elseif groupType == kType.kTargetGroupType.kSelfs then    -- 己方
            if RolesManager:getInstance()._pPvpPlayerRole then
                if obj ~= RolesManager:getInstance()._pPvpPlayerRole then
                    table.insert(group, RolesManager:getInstance()._pPvpPlayerRole)
                end
            end
            if PetsManager:getInstance()._pPvpPetRole then
                if obj ~= PetsManager:getInstance()._pPvpPetRole then
                    table.insert(group, PetsManager:getInstance()._pPvpPetRole)
                end
            end
            for k, v in pairs(MonstersManager:getInstance()._tCurWaveMonsters) do
                if obj ~= v then
                    table.insert(group, v)
                end
            end
        elseif groupType == kType.kTargetGroupType.kOneSelf then    -- 自己
            table.insert(group,obj)
        end
    end    
    
    return group
end

-- 根据obj获取搜索方向
function AIManager:getSearchDirection(obj)
    local searchDirection = kDirection.kNone
    if obj._kDirection == kDirection.kLeftUp or 
       obj._kDirection == kDirection.kUp or
       obj._kDirection == kDirection.kRightUp then
        -- 搜索范围为角色以上的区域
        searchDirection = kDirection.kUp
    elseif obj._kDirection == kDirection.kLeft then
        -- 搜索范围为角色以左的区域
        searchDirection = kDirection.kLeft
    elseif obj._kDirection == kDirection.kRight then
        -- 搜索范围为角色以右的区域
        searchDirection = kDirection.kRight
    elseif obj._kDirection == kDirection.kLeftDown or 
           obj._kDirection == kDirection.kDown or
           obj._kDirection == kDirection.kRightDown then
        -- 搜索范围为角色以下的区域
        searchDirection = kDirection.kDown
    end
    return searchDirection
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- 角色根据目标的方位自动转向（适用攻击前的方向刷新）
-- 参数：attacker 角色对象                skill 角色的技能     
function AIManager:roleRefreshDirectionWhenAttackEnemys(attacker, skill)
    if attacker == nil or skill == nil then
        return
    end
    -- 先判定attacker是 “我方” 或者 “敌方” 
    local sideType = self:getsideType(attacker)
    -- 确定受击群里类型
    local enemys = self:getGroup(attacker, sideType, skill._pSkillInfo.TargetGroupType)
    -- 确定搜索方向
    local searchDirection = self:getSearchDirection(attacker)    

    -- 查找技能警戒范围内的目标集合
    local warningRange = skill._pSkillInfo.WarnRange
    local posAttackerX, posAttackerY = attacker:getPosition()
    local targetsInDirection = {}
    local targets = {}
    for kIndex, enemy in pairs(enemys) do
        if enemy._nCurHp > 0 then  -- 非死亡状态
            local posEnemyX, posEnemyY = enemy:getPosition()
            local distance2 = (posAttackerX - posEnemyX)*(posAttackerX - posEnemyX) + (posAttackerY - posEnemyY)*(posAttackerY - posEnemyY)
            local attackerWarningRange2 = warningRange*warningRange
            if distance2 <= attackerWarningRange2 then
                local skip = false
                if searchDirection == kDirection.kUp then
                    if posEnemyY < posAttackerY then  -- 如果enemy在attacker的下方，则忽略掉
                        skip = true
                    end
                elseif searchDirection == kDirection.kDown then
                    if posEnemyY > posAttackerY then  -- 如果enemy在attacker的上方，则忽略掉
                        skip = true
                    end
                elseif searchDirection == kDirection.kLeft then
                    if posEnemyX > posAttackerX then  -- 如果enemy在attacker的右方，则忽略掉
                        skip = true
                    end
                elseif searchDirection == kDirection.kRight then
                    if posEnemyX < posAttackerX then  -- 如果enemy在attacker的左方，则忽略掉
                        skip = true
                    end
                end
                if not skip then
                    -- 收集在当前方向中的目标集合
                    table.insert(targetsInDirection,{["enemy"] = enemy, ["distance2"] = distance2})
                end
                -- 收集警戒范围内所有的目标集合
                table.insert(targets,{["enemy"] = enemy, ["distance2"] = distance2})
            end
        end
    end
    -- 跟符合条件的目标刷新玩家角色的角度
    if table.getn(targetsInDirection) ~= 0 then -- 存在当前方向中的目标，优先攻击方向中的目标
        table.sort(targetsInDirection,fromSmallToBigOnDistance2)  -- 按照目标对象与自身的距离2次幂从小到大排序
        if targetsInDirection[1].enemy ~= attacker then
            local fAttackAngle = mmo.HelpFunc:gAngleAnalyseForRotation(attacker:getPositionX(), attacker:getPositionY(), targetsInDirection[1].enemy:getPositionX(), targetsInDirection[1].enemy:getPositionY())
            attacker:setAngle3D(fAttackAngle)
            attacker._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(fAttackAngle)
        end
    elseif table.getn(targets) ~= 0 then  -- 虽然不存在当前方向中的目标，但是存在警戒范围内的目标
        table.sort(targets,fromSmallToBigOnDistance2)  -- 按照目标对象与自身的距离2次幂从小到大排序
        if targets[1].enemy ~= attacker then
            local fAttackAngle = mmo.HelpFunc:gAngleAnalyseForRotation(attacker:getPositionX(), attacker:getPositionY(), targets[1].enemy:getPositionX(), targets[1].enemy:getPositionY())
            attacker:setAngle3D(fAttackAngle)
            attacker._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(fAttackAngle)
        end
    end

end

-- 对象搜索视野范围内的最近目标集合与指定技能（或者普通攻击）的警戒范围内的目标集合
-- 参数：attacker：攻击者    skill：攻击者技能   
--       needNearestInWarningRangeToMasterForPet：是否需要获得在警戒范围内离宠物主人最近的目标集合（可以省略，只有在attacker为宠物的时候才可用）
-- 返回： 第1个参数是视野范围内的目标集合（当attacker为宠物时，则该返回参数表示：宠物警戒范围内的离主人最近的目标集合）
--       第2个参数是指定技能（或者普通攻击）警戒范围内的目标集合
function AIManager:objSearchNearestEnemysInViewAndSkillWarningRange(attacker, skill, needNearestInViewRangeToMasterForPet, needNearestInWarningRangeToMasterForPet)
    if attacker == nil or skill == nil then
        return {},{}
    end
    -- 先判定attacker是 “我方” 或者 “敌方” 
    local sideType = self:getsideType(attacker)
    -- 确定受击群里类型
    local enemys = self:getGroup(attacker, sideType, skill._pSkillInfo.TargetGroupType)

    -- 查找视野范围和技能警戒范围内的野怪集合
    local targetsInView = {}
    local targetsInWarning = {}
    local viewRange = 0         -- 视野范围，如果是PlayerRole，则viewRange会保持为0，即无限大
    if attacker._kGameObjType == kType.kGameObj.kRole then
        if attacker._kRoleType ~= kType.kRole.kPlayer then
            viewRange = attacker._pRoleInfo.ViewRange
        end
    elseif attacker._kGameObjType == kType.kGameObj.kEntity then
        viewRange = attacker._pEntityInfo.ViewRange
    end
    local warningRange = skill._pSkillInfo.WarnRange
    local posAttackerX, posAttackerY = 0, 0
    if attacker._kGameObjType == kType.kGameObj.kRole then
        posAttackerX , posAttackerY = attacker:getPosition()
    elseif attacker._kGameObjType == kType.kGameObj.kEntity then  -- 如果发起攻击的enemy是实体，则实体的位置点一律使用中心点，而非脚下点（仅需在实体搜索攻击目标时规定这种判定即可）
        posAttackerX , posAttackerY = attacker:getPosition()
        posAttackerY = posAttackerY + attacker:getHeight()/2
    end
    
    ------- 考虑如果attacker是宠物时需要的参数 ------------------------
    local petMaster = nil
    local posPetMasterX = -1
    local posPetMasterY = -1
    local targetsInViewForPet = {}
    local targetsInWarningForPet = {}
    if attacker._kGameObjType == kType.kGameObj.kRole and attacker._kRoleType == kType.kRole.kPet then
        if attacker._strCharTag == "main" then
            petMaster = PetsManager:getInstance()._pMainPetRole
        elseif attacker._strCharTag == "pvp" then
            petMaster = PetsManager:getInstance()._pPvpPetRole
        end
        posPetMasterX, posPetMasterY = petMaster:getPosition()
    end
    ------------------------------------------------------------------
    for kEnemy, vEnemy in pairs(enemys) do 
        if vEnemy._nCurHp > 0 then  -- 非死亡状态
            local posEnemyX, posEnemyY = vEnemy:getPosition()
            local distance2 = (posEnemyX - posAttackerX)*(posEnemyX - posAttackerX) + (posEnemyY - posAttackerY)*(posEnemyY - posAttackerY)
            local attackerViewRange2 = viewRange*viewRange
            local attackerWarningRange2 = warningRange*warningRange
            if attackerViewRange2 == 0 or distance2 <= attackerViewRange2 then -- 非PlayerRole
                -- 受击视野范围内所有的目标集合
                if attacker._kGameObjType == kType.kGameObj.kRole and attacker._kRoleType == kType.kRole.kPet and needNearestInViewRangeToMasterForPet == true then
                    local distanceBetweenPetMasterAndEnemy2 = (posEnemyX - posPetMasterX)*(posEnemyX - posPetMasterX) + (posEnemyY - posPetMasterY)*(posEnemyY - posPetMasterY)
                    table.insert(targetsInViewForPet,{["enemy"] = vEnemy, ["distance2"] = distanceBetweenPetMasterAndEnemy2}) 
                else
                    table.insert(targetsInView,{["enemy"] = vEnemy, ["distance2"] = distance2})    
                end
                if distance2 <= attackerWarningRange2 then
                    -- 收集警戒范围内所有的目标集合
                    table.insert(targetsInWarning,{["enemy"] = vEnemy, ["distance2"] = distance2})
                    -- 如果attacker为宠物，则需要手机宠物视野范围内的离主人最近的目标集合
                    if attacker._kGameObjType == kType.kGameObj.kRole and attacker._kRoleType == kType.kRole.kPet and needNearestInWarningRangeToMasterForPet == true then
                        local distanceBetweenPetMasterAndEnemy2 = (posEnemyX - posPetMasterX)*(posEnemyX - posPetMasterX) + (posEnemyY - posPetMasterY)*(posEnemyY - posPetMasterY)
                        table.insert(targetsInWarningForPet,{["enemy"] = vEnemy, ["distance2"] = distanceBetweenPetMasterAndEnemy2})
                    end
                end
            end
        end
    end

    if table.getn(targetsInView) ~= 0 then -- 判断是否存在视野范围内的目标
        table.sort(targetsInView,fromSmallToBigOnDistance2)  -- 按照目标对象与自身的距离2次幂从小到大排序
    end
    if table.getn(targetsInWarning) ~= 0 then  -- 判断是否存在警戒范围内的目标
        table.sort(targetsInWarning,fromSmallToBigOnDistance2)  -- 按照目标对象与自身的距离2次幂从小到大排序
    end
    
    if table.getn(targetsInViewForPet) ~= 0 then -- 判断是否存在视野范围内的目标
        table.sort(targetsInViewForPet,fromSmallToBigOnDistance2)  -- 按照目标对象与宠物主人的距离2次幂从小到大排序
    end
    if table.getn(targetsInWarningForPet) ~= 0 then  -- 判断是否存在警戒范围内的目标
        table.sort(targetsInWarningForPet,fromSmallToBigOnDistance2)  -- 按照目标对象与宠物主人的距离2次幂从小到大排序
    end
    
    if attacker._kGameObjType == kType.kGameObj.kRole and attacker._kRoleType == kType.kRole.kPet then
        if needNearestInViewRangeToMasterForPet == true then
            targetsInView = targetsInViewForPet
        end
        if needNearestInWarningRangeToMasterForPet == true then
            targetsInWarning = targetsInWarningForPet
        end
    end

    return targetsInView, targetsInWarning  
end

-- 对象搜索指定范围内的最近目标集合（适用于伤害型搜索）（attacker为主角时用于自身反击-火buff等等等等）
-- 返回： 指定范围range内的目标集合
function AIManager:objSearchNearestEnemysInRangeForDamage(attacker, range, needNearestInRangeToMasterForPet, groupType)
    if attacker == nil then
        return {}
    end
    -- 先判定attacker是 “我方” 或者 “敌方” 
    local sideType = self:getsideType(attacker)
    -- 确定受击群里类型
    local targetGroupType = nil
    if groupType == nil then
        targetGroupType = kType.kTargetGroupType.kOpposite
    else
        targetGroupType = groupType
    end
    local enemys = self:getGroup(attacker, sideType, targetGroupType)
    -- 查找范围内的集合
    local targetsInRange = {}
    local posAttackerX, posAttackerY = 0, 0
    if attacker._kGameObjType == kType.kGameObj.kRole then
        posAttackerX , posAttackerY = attacker:getPosition()
    elseif attacker._kGameObjType == kType.kGameObj.kEntity then  -- 如果发起攻击的enemy是实体，则实体的位置点一律使用中心点，而非脚下点（仅需在实体搜索攻击目标时规定这种判定即可）
        posAttackerX , posAttackerY = attacker:getPosition()
        posAttackerY = posAttackerY + attacker:getHeight()/2
    end

    ------- 考虑如果attacker是宠物时需要的参数 ------------------------
    local petMaster = nil
    local posPetMasterX = -1
    local posPetMasterY = -1
    local targetsInViewForPet = {}
    local targetsInWarningForPet = {}
    if attacker._kGameObjType == kType.kGameObj.kRole and attacker._kRoleType == kType.kRole.kPet then
        if attacker._strCharTag == "main" then
            petMaster = PetsManager:getInstance()._pMainPetRole
        elseif attacker._strCharTag == "pvp" then
            petMaster = PetsManager:getInstance()._pPvpPetRole
        end
        posPetMasterX, posPetMasterY = petMaster:getPosition()
    end
    ------------------------------------------------------------------

    -- 查找范围内的集合
    for kEnemy, vEnemy in pairs(enemys) do 
        if vEnemy._nCurHp > 0 then  -- 非死亡状态
            local posEnemyX, posEnemyY = vEnemy:getPosition()
            local distance2 = (posEnemyX - posAttackerX)*(posEnemyX - posAttackerX) + (posEnemyY - posAttackerY)*(posEnemyY - posAttackerY)
            local range2 = range*range
            if distance2 <= range2 then
                -- 受击范围内所有的目标集合
                if attacker._kGameObjType == kType.kGameObj.kRole and attacker._kRoleType == kType.kRole.kPet and needNearestInRangeToMasterForPet == true then
                    local distanceBetweenPetMasterAndEnemy2 = (posEnemyX - posPetMasterX)*(posEnemyX - posPetMasterX) + (posEnemyY - posPetMasterY)*(posEnemyY - posPetMasterY)
                    table.insert(targetsInRange,{["enemy"] = vEnemy, ["distance2"] = distanceBetweenPetMasterAndEnemy2}) 
                else
                    table.insert(targetsInRange,{["enemy"] = vEnemy, ["distance2"] = distance2})    
                end
            end
        end
    end

    if table.getn(targetsInRange) ~= 0 then  
        table.sort(targetsInRange,fromSmallToBigOnDistance2) 
    end

    return targetsInRange
end

-- 角色玩家根据自身技能CD的情况，决定当前时刻可以使用的技能的skillWayIndex
-- 返回：角色当前时刻已经CD结束了的技能的skillWayIndex
function AIManager:playerRoleDecideSkill(playerRole)    
    local skillWayIndex = 0
    -- 确定当前准备使用的技能
    for i = kType.kSkill.kWayIndex.kPlayerRole.kSkill1, kType.kSkill.kWayIndex.kPlayerRole.kSkill4 do
        if playerRole._tSkills[i] and playerRole._tSkills[i]:isCDOver() == true then
            skillWayIndex = i
            break
        end
    end
    if skillWayIndex == 0 then  -- 如果没有冷却结束的技能，则考虑怒气技能
        if playerRole._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] and playerRole._nCurAnger >= playerRole._nAngerMax then  -- 如果怒气技能可以使用了，则释放怒气技能
            skillWayIndex = kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack
        end
    end
    if skillWayIndex == 0 then  -- 如果没有冷却结束的技能，则考虑普通攻击
        skillWayIndex = kType.kSkill.kWayIndex.kPlayerRole.kGenAttack   
    end
    return skillWayIndex
end

-- 判定宠物角色当前是否可以进入战斗模式
-- 返回： true：表示可以进入战斗状态，false：表示不可进入战斗状态
function AIManager:isPetCanEnterBattleModeForDamage(pet, groupType)
    if pet == nil then
        return false
    end
    -- 先判定attacker是 “我方” 或者 “敌方” 
    local sideType = self:getsideType(pet)
    -- 确定受击群里类型
    local targetGroupType = nil
    if groupType == nil then
        targetGroupType = kType.kTargetGroupType.kOpposite
    end
    local enemys = self:getGroup(pet, sideType, targetGroupType)
    -- 确定视野范围内是否存在敌人，如果存在，返回true，表示可以进入战斗状态，否则false，表示不可进入战斗状态
    local posPetRoleX, posPetRoleY = pet:getPosition()
    for kEnemy, vEnemy in pairs(enemys) do 
        if vEnemy._nCurHp > 0 then  -- 非死亡状态
            local posEnemyX, posEnemyY = vEnemy:getPosition()
            local distance2 = (posEnemyX - posPetRoleX) * (posEnemyX - posPetRoleX) + (posEnemyY - posPetRoleY) * (posEnemyY - posPetRoleY)
            local viewRange2 = pet._pRoleInfo.ViewRange * pet._pRoleInfo.ViewRange
            if distance2 <= viewRange2 then
                return true
            end
        end
    end
    return false
end

-- 判断点是否与目标群发生碰撞
-- 参数1：攻击者
-- 参数2：攻击者技能
-- 参数3：点位置
function AIManager:isPointCollidingOnEnemys(attacker, skill, pos)
    if attacker == nil or skill == nil then
        return false
    end
    -- 先判定attacker是 “我方” 或者 “敌方” 
    local sideType = self:getsideType(attacker)
    -- 确定受击群里类型
    local enemys = self:getGroup(attacker, sideType, skill._pSkillInfo.TargetGroupType)

    -- 先判定受击的enemys集合
    local isColliding = false
    for kEnemy,vEnemy in pairs(enemys) do
        if vEnemy._nCurHp > 0 then  -- 非死亡状态
            isColliding = vEnemy:isCollidingBodyOnPoint(pos)
            if isColliding == true then
                break
            end 
        end
    end

    return isColliding
end

-- 判断矩形是否与目标群发生碰撞
-- 参数1：攻击者
-- 参数2：攻击者技能
-- 参数3：矩形信息
function AIManager:isRectCollidingOnEnemys(attacker, skill, rec)
    if attacker == nil or skill == nil then
        return false
    end
    -- 先判定attacker是 “我方” 或者 “敌方” 
    local sideType = self:getsideType(attacker)
    -- 确定受击群里类型
    local enemys = self:getGroup(attacker, sideType, skill._pSkillInfo.TargetGroupType)

    -- 先判定受击的enemys集合
    local directions = 0
    for kEnemy,vEnemy in pairs(enemys) do
        if vEnemy._nCurHp > 0 then  -- 非死亡状态
            directions = vEnemy:isCollidingBodyOnRect(rec)
            if directions ~= 0 then
                break
            end 
        end
    end
    
    if directions == 0 then
        return false
    else
        return true
    end
    
end

-- 盗宝贼Boss查找下一个适合的寻路点
function AIManager:thiefBossGetThiefNextPlotIndex(thief)
    local thiefNextPlotIndex = nil
    -- 搜索视野范围内是否有玩家,然后选择时机判定是否逃跑
    local posTargetX, posTargetY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
    local posX, posY = thief:getPosition()
    -- 玩家在视野范围内，则远离，否则原地待机
    if (posTargetX - posX)*(posTargetX - posX) + (posTargetY - posY)*(posTargetY - posY) <= thief._pRoleInfo.ViewRange*thief._pRoleInfo.ViewRange then
        -- 有玩家，则开始远离玩家，首先，选择合适的plot寻路点，收集符合当前状况的寻路点的集合
        local posIndex = thief:getPositionIndex()
        local tPlots = {}
        for k,v in pairs(MapManager:getInstance()._tThiefPlots) do
            local posThiefPlot = MapManager:getInstance():convertIndexToPiexl(v)
            local dis2 = (posThiefPlot.x - posTargetX)*(posThiefPlot.x - posTargetX) + (posThiefPlot.y - posTargetY)*(posThiefPlot.y - posTargetY)
            if (dis2 >= TableConstants.DisBetweenThiefPlotAndPlayer.Value*TableConstants.DisBetweenThiefPlotAndPlayer.Value) and (v.x ~= posIndex.x and v.y ~= posIndex.y) then
                table.insert(tPlots,v)
            end
        end
        if table.getn(tPlots) ~= 0 then -- 有符合条件的寻路点
            -- 随机一个
            local nThiefPlotsRandomIndex = getRandomNumBetween(1, table.getn(tPlots))
            -- 确定寻路点
            thiefNextPlotIndex = tPlots[nThiefPlotsRandomIndex]
        else  -- 没有符合条件的寻路点，则默认随机一个不重复位置的plot即可
            while true do
                -- 随机一个
                local nThiefPlotsRandomIndex = getRandomNumBetween(1, table.getn(MapManager:getInstance()._tThiefPlots)) 
                -- 只需要不重复位置的plot即可
                if (MapManager:getInstance()._tThiefPlots[nThiefPlotsRandomIndex].x ~= posIndex.x and MapManager:getInstance()._tThiefPlots[nThiefPlotsRandomIndex].y ~= posIndex.y) then
                    -- 确定寻路点
                    thiefNextPlotIndex = MapManager:getInstance()._tThiefPlots[nThiefPlotsRandomIndex]
                    break
                end
            end
        end
    end
    return thiefNextPlotIndex
end

-- 技能战斗矩形对目标群的碰撞与伤害调用
-- 参数1：攻击者
-- 参数2：攻击者的技能
function AIManager:skillCollidingOnEnemysAndHurt(attacker, skill)
    if attacker == nil or skill == nil then
        return
    end
    -- 先判定attacker是 “我方” 或者 “敌方” 
    local sideType = self:getsideType(attacker)
    -- 确定受击群里类型
    local enemys = self:getGroup(attacker, sideType, skill._pSkillInfo.TargetGroupType)
    -- 确定最大的目标数量上限,0表示无上限
    local nTargetMaxNum = skill._pSkillInfo.TargetMaxNum
    local rects = skill._tCurAttackRects
    local tDirections = {}              -- 碰撞的方向
    local tInterSections = {}           -- 碰撞产生的矩形区域集合
    local tHurtedEnemys = {}            -- 待受击的目标集合
    -- 先判定受击的enemys集合
    local enough = false
    for kEnemy,vEnemy in pairs(enemys) do
        if vEnemy._nCurHp > 0 then  -- 非死亡状态
            for kRect,vRect in pairs(rects) do
                if vEnemy._kGameObjType == kType.kGameObj.kRole then
                    local directions, intersection = vEnemy:isCollidingBodyOnRect(vRect)
                    if directions ~= 0 then
                        if nTargetMaxNum == 0 then  -- 无上限
                            table.insert(tDirections,directions)
                            table.insert(tInterSections,intersection)
                            table.insert(tHurtedEnemys,vEnemy)
                            break
                        else  -- 有上限
                            if (#tHurtedEnemys) < nTargetMaxNum then  -- 在限制数范围内的话  就继续添加
                                table.insert(tDirections,directions)
                                table.insert(tInterSections,intersection)
                                table.insert(tHurtedEnemys,vEnemy)
                            else        -- 已经超出限制数范围，则直接跳出整个循环
                                enough = true
                            end
                            break
                        end
                    end
                elseif vEnemy._kGameObjType == kType.kGameObj.kEntity then  -- 【可以被攻击的实体对象】中还需要判定是否与实体的undef发生碰撞，因为这种碰撞有可能也会给实体带来伤害【仅对实体有效】
                    local directions, intersection = vEnemy:isCollidingUndefOnRect(vRect)
                    if directions ~= 0 then
                        if nTargetMaxNum == 0 then  -- 无上限
                            table.insert(tDirections,directions)
                            table.insert(tInterSections,intersection)
                            table.insert(tHurtedEnemys,vEnemy)
                            break
                        else  -- 有上限
                            if (#tHurtedEnemys) < nTargetMaxNum then  -- 在限制数范围内的话  就继续添加
                                table.insert(tDirections,directions)
                                table.insert(tInterSections,intersection)
                                table.insert(tHurtedEnemys,vEnemy)
                            else        -- 已经超出限制数范围，则直接跳出整个循环
                                enough = true
                            end
                            break
                        end
                    end
                end
            end
            if enough == true then  -- 目标数已满，直接退出
                break
            end
        end
    end
    
    -- 震屏+给目标群体实施伤害
    if table.getn(tHurtedEnemys) == 0 then -- 【非命中】
        -- 空放的屏幕卡顿
        skill:getMapManager():screenKartun(skill._tTempleteInfo.MissScreenKartun["ScreenKartun"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex])
        -- 空放的角色卡顿
        skill:getMaster():roleKartun(skill._tTempleteInfo.MissRoleKartun["RoleKartun"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex])
        -- 空放的震屏
        skill:getMapManager():shakeMap(skill._tTempleteInfo.MissShock["Shock"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex],cc.p(skill:getPositionX(), skill:getPositionY()))
    else -- 【命中】
        -- 击中的屏幕卡顿
        skill:getMapManager():screenKartun(skill._tTempleteInfo.HitScreenKartun["ScreenKartun"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex])
        -- 击中的角色卡顿
        skill:getMaster():roleKartun(skill._tTempleteInfo.HitRoleKartun["RoleKartun"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex])
        -- 击中的震屏
        skill:getMapManager():shakeMap(skill._tTempleteInfo.HitShock["Shock"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex],cc.p(skill:getPositionX(), skill:getPositionY()))
        -- 伤害
        for k,v in pairs(tHurtedEnemys) do
            v:roleKartun(skill._tTempleteInfo.HitRoleKartun["RoleKartun"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex])
            v:beHurtedBySkill(skill,tInterSections[k])
            mmo.HelpFunc:playVibrator(20)
        end
    end
    -- 闪屏
    skill:getMapManager():splashMap(skill._tTempleteInfo.SplashShock["Splash"..skill._nCurFrameRegionIndex.."_"..skill._nCurFrameEventIndex])
    
    return    
end
