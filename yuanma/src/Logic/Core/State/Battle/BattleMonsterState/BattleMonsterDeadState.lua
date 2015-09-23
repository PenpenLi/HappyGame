--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterDeadState.lua
-- author:    liyuhan
-- created:   2015/1/17
-- descrip:   战斗中怪物角色死亡状态
--===================================================
local BattleMonsterDeadState = class("BattleMonsterDeadState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterDeadState:ctor()
    self._strName = "BattleMonsterDeadState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kDead  -- 状态类型ID
    self._fBeatenAngle = 0                             -- 受击角度
    self._fBeatenOffset = 0                            -- 飞出距离

end

-- 创建函数
function BattleMonsterDeadState:create()
    local state = BattleMonsterDeadState.new()
    return state
end

-- 进入函数
function BattleMonsterDeadState:onEnter(args)     
    if self:getMaster() then
        ---------------------------------- 判断是否会发生变身（即在原地创建新的野怪）---------------------------------------------
        if self:getMaster()._pRoleInfo.ShapeChangeID ~= -1 then
            -----------------------------------------------变身-----------------------------------------------------------------------
            -- 变身特效
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr("ChangeRole")  -- 记录并加载到纹理缓存中
            self:getMaster():playShapeChangeEffect()
            -- 创建新的野怪
            local pMonstersMananger = self:getMonstersManager()
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteMonster[TableMonster[self:getMaster()._pRoleInfo.ShapeChangeID].TempleteID].Texture)  -- 记录并加载到纹理缓存中
            local pMonsterRole = pMonstersMananger:createMonsterRole(self:getMaster()._pRoleInfo.ShapeChangeID, self:getMaster():getPositionIndex().x, self:getMaster():getPositionIndex().y)
            table.insert(pMonstersMananger._tMonsters[pMonstersMananger._nCurMonsterAreaIndex][pMonstersMananger._nCurMonsterWaveIndex], pMonsterRole)
            -- 创建野怪技能
            local pSkillsManager = self:getSkillsManager()
            for kSkillID,vSkillID in pairs(pMonsterRole._pRoleInfo.SkillIDs) do
                ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(TableTempleteSkills[TableMonsterSkills[vSkillID].TempleteID].DetailInfo.PvrName)   -- 记录并加载到纹理缓存中
                -- 创建野怪技能
                local pMonsterSkill = pSkillsManager:createMonsterSkill(kSkillID,vSkillID,pMonsterRole)
                -- 添加到集合
                table.insert(pSkillsManager._tMonstersSkills[pMonstersMananger._nCurMonsterAreaIndex][pMonstersMananger._nCurMonsterWaveIndex],pMonsterSkill)
            end 
            -- 野怪出场
            pMonsterRole:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kAppear)
            -- 刷新相机
            self:getMaster():refreshCamera()
            ------------------------------------------------------------------------------------------------------------------------

            --怪物积分增加
            BattleManager:getInstance():setUpNumGread(self:getMaster()._pRoleInfo.BonusPoints)

            self:getMaster()._pShadow:setVisible(false)
            
            if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kGold then  -- 累积野怪对应金币数
                MonstersManager:getInstance()._nGoldDropTotalNum = math.modf(MonstersManager:getInstance()._nGoldDropTotalNum + (self:getMaster()._pRoleInfo.BonusPoints * TableConstants.GoldCopiesRatio.Value))            
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pGoldDropNode:showAniWithNum(MonstersManager:getInstance()._nGoldDropTotalNum)
            end

            -- 按照typeID记录死亡个数
            if self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] == nil then
                self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] = 0
            end
            self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] = self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] + 1

            -- 立刻移除所有buff
            self:getMaster():getBuffControllerMachine():removeAllBuffsRightNow()
            
            -- 复位技能状态
            for k,v in pairs(self:getMaster()._tSkills) do 
                 v:stopAllActionNodes()
                 v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill):setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
                 v._pMaster = nil
                 v._pAni = nil
                 v._bActive = false             -- 技能等待管理器删除回收
            end
            self:getMaster()._tSkills = {}

            -- 移除所有特效
            self:getMaster():removeAllEffects()

            -- 角色等待管理器删除回收
            self:getMaster()._bActive = false
            self._pOwnerMachine._pMaster._pAni = nil
            self._pOwnerMachine._pMaster = nil
 
        else
            ------------------------------------------- 正常的死亡逻辑 ----------------------------------------------------------
            --怪物积分增加
            BattleManager:getInstance():setUpNumGread(self:getMaster()._pRoleInfo.BonusPoints)

            self:getMaster()._pShadow:setVisible(false)
            
            if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kGold then  -- 累积野怪对应金币数
                MonstersManager:getInstance()._nGoldDropTotalNum = math.modf(MonstersManager:getInstance()._nGoldDropTotalNum + (self:getMaster()._pRoleInfo.BonusPoints * TableConstants.GoldCopiesRatio.Value))            
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pGoldDropNode:showAniWithNum(MonstersManager:getInstance()._nGoldDropTotalNum)
            end
            
            -- args[1] 是否为技能   args[2] skill对象
            if args[1] == true and self:getMaster()._pRoleInfo.CanDeadFly == 1 then  -- 由技能致死
                local pAttackerSkill = args[2]
                -- 受击的角度计算
                self._fBeatenAngle = mmo.HelpFunc:gAngleAnalyseForRotation(self:getMaster():getPositionX(), self:getMaster():getPositionY(), pAttackerSkill:getMaster():getPositionX(), pAttackerSkill:getMaster():getPositionY())
                -- 获得飞出距离
                self._fBeatenOffset = TableConstants.DeadFlyDistance.Value
                -- 刷新角色角度
                self:refreshBeatenDirection()
                -- 后退位移
                self:toBackDistanceWithTime(TableConstants.BeatedFlyTime.Value)
            end

            -- 如果是BOSS，则需要慢镜头
            if self:getMaster()._nMonsterType == kType.kMonster.kBOSS or self:getMaster()._nMonsterType == kType.kMonster.kThiefBOSS then
                MonstersManager:getInstance()._bIsBossDead = true  -- boss死亡
                local cameraOver = function()
                    cc.Director:getInstance():getScheduler():setTimeScale(0.3)
                end
                -- 相机拉近，给boss一个特写
                local posX, posY = self:getMaster():getPosition()
                self:getMapManager():moveMapCameraByPos(1, 0.5, cc.p(posX,posY), 0.5, 0.7, nil, false, cameraOver)
                -- 特写标记
                self:getMapManager()._bBossDeadFilming = true
                -- 强制设置所有角色positionZ到最小值
                MonstersManager:getInstance():setForceMinPositionZ(true, -5000)
                RolesManager:getInstance():setForceMinPositionZ(true, -5000)
                PetsManager:getInstance():setForceMinPositionZ(true, -5000)
                SkillsManager:getInstance():setForceMinPositionZ(true, -5000)
            end
            
            -- 刷新动作
            self:getMaster():playDeadAction()
        
            -- 死亡动画
            self:getMaster():playDeadEffect()
        
            -- 按照typeID记录死亡个数
            if self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] == nil then
                self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] = 0
            end
            self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] = self:getMonstersManager()._tMonsterDeadNum[self:getMaster()._nTypeID] + 1
            
            -- 添加动作回调
            local deadOver = function()
                self:getMaster():removeAllEffects()-- 移除所有特效
                -- 判断是否为BOSS，如果是，则血条消失
                if self:getMaster()._nMonsterType == kType.kMonster.kBOSS or self:getMaster()._nMonsterType == kType.kMonster.kThiefBOSS then
                    cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pBossHpBG:setVisible(false)
                    cc.Director:getInstance():getScheduler():setTimeScale(1.0)   -- 如果是BOSS，死亡结束后恢复正常镜头速度
                    -- 相机复原，回到正常比例
                    self:getMapManager():moveMapCameraByPos(2, 0.5, cc.p(-1,-1), 0.5, 1.0, cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY()), true)
                    -- 特写标记
                    self:getMapManager()._bBossDeadFilming = false
                    -- 恢复设置所有角色positionZ到最小值
                    MonstersManager:getInstance():setForceMinPositionZ(false)
                    RolesManager:getInstance():setForceMinPositionZ(false)
                    PetsManager:getInstance():setForceMinPositionZ(false)
                    SkillsManager:getInstance():setForceMinPositionZ(false)
                    -- 同时所有小怪全部阵亡
                    MonstersManager:getInstance():setCurWaveMonstersAllDead()
                end
                -- 角色等待管理器删除回收
                self:getMaster()._bActive = false
                self._pOwnerMachine._pMaster._pAni = nil
                self._pOwnerMachine._pMaster = nil
                
            end
            -- 设置透明度和positionZ层级  
            self:getMaster()._pAni:runAction(cc.Sequence:create(cc.FadeOut:create(1.5), cc.CallFunc:create(deadOver)))
            
            -- 立刻移除所有buff
            self:getMaster():getBuffControllerMachine():removeAllBuffsRightNow()
            
            -- 复位技能状态
            for k,v in pairs(self:getMaster()._tSkills) do 
                 v:stopAllActionNodes()
                 v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill):setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
                 v._pMaster = nil
                 v._pAni = nil
                 v._bActive = false             -- 技能等待管理器删除回收
            end
            self:getMaster()._tSkills = {}
            -- 死亡声
            AudioManager:getInstance():playEffect(self:getMaster()._pTempleteInfo.DeadVoice)
        end

    end
    
    return
end

-- 退出函数
function BattleMonsterDeadState:onExit()
    return
end

-- 更新逻辑
function BattleMonsterDeadState:update(dt)    
    return
end

-- Proc受击瞬间的方向刷新
function BattleMonsterDeadState:refreshBeatenDirection()
    -- 特殊野怪不能转向
    if self:getMaster() then
        self:getMaster():setAngle3D(self._fBeatenAngle)
        self:getMaster()._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(self._fBeatenAngle)
    end

    return
end

-- 反方向后退位移
function BattleMonsterDeadState:toBackDistanceWithTime(time)
    if self:getMaster() then
        local rect = self:getMaster():getBottomRectInMap() 
        local toX = rect.x
        local toY = rect.y
        local width = rect.width
        local height = rect.height
        local direction = self:getMaster()._kDirection
        local offset = 0
        local test = 37
        if direction == kDirection.kDown then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX,toY + offset, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toY = toY + (offset - test)
        elseif direction == kDirection.kUp then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX,toY - offset, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toY = toY - (offset - test)
        elseif direction == kDirection.kRight then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX - offset,toY, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX - (offset - test)
        elseif direction == kDirection.kLeft then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + offset,toY, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX + (offset - test)
        elseif direction == kDirection.kRightDown then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX - offset / 1.414, toY + offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX - (offset - test) / 1.414
            toY = toY + (offset - test) / 1.414
        elseif direction == kDirection.kRightUp then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX - offset / 1.414, toY - offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX - (offset - test) / 1.414
            toY = toY - (offset - test) / 1.414
        elseif direction == kDirection.kLeftDown then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + offset / 1.414, toY + offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX + (offset - test) / 1.414
            toY = toY + (offset - test) / 1.414
        elseif direction == kDirection.kLeftUp then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + offset / 1.414, toY - offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX + (offset - test) / 1.414
            toY = toY - (offset - test) / 1.414
        end
        local act = cc.EaseSineOut:create(cc.MoveTo:create(time,cc.p(toX + width/2,toY)))
        self:getMaster():stopActionByTag(nRoleBackActionTag)
        act:setTag(nRoleBackActionTag)
        self:getMaster():runAction(act)

    end
    
end

return BattleMonsterDeadState
