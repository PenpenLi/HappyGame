--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePetRoleDeadState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   战斗中玩家宠物角色死亡状态
--===================================================
local BattlePetRoleDeadState = class("BattlePetRoleDeadState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePetRoleDeadState:ctor()
    self._strName = "BattlePetRoleDeadState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePetRole.kDead  -- 状态类型ID
    self._fBeatenAngle = 0                             -- 受击角度
    self._fBeatenOffset = 0                            -- 飞出距离

end

-- 创建函数
function BattlePetRoleDeadState:create()
    local state = BattlePetRoleDeadState.new()
    return state
end

-- 进入函数
function BattlePetRoleDeadState:onEnter(args)
    --print(self:getMaster()._strCharTag.."宠物角色死亡状态")
    -- mmo.DebugHelper:showJavaLog("--STATE--PET--:Dead")
    
    if self:getMaster() then
        
        -- args[1] 是否为技能   args[2] skill对象
        if args[1] == true then  -- 由技能致死
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

        self:getMaster()._pShadow:setVisible(false)

        -- 刷新动作
        self:getMaster():playDeadAction()
      
        -- 死亡动画
        self:getMaster():playDeadEffect()

        -- 准备切换到下一个宠物
        local deadOver = function()
            self:getMaster():removeAllEffects()  -- 移除所有特效
            if self:getMaster()._strCharTag == "main" then
                local pBattleUILayerDelegate = self:getMaster()._pBattleUIDelegate  -- 死去宠物的ui_delegate
                self:getPetsManager():changeToNextMainPetRoleOnMap()            -- 切换宠物对象
                self:getSkillsManager():changeToNextMainPetRoleSkillsOnMap()    -- 切换宠物技能缓存
                -- 关联主角宠物信息到ui
                if self:getPetsManager()._pMainPetRole then
                    self:getPetsManager()._pMainPetRole:setBattleUILayerDelegate(pBattleUILayerDelegate)
                else
                    if pBattleUILayerDelegate then
                        pBattleUILayerDelegate._pMainPetUINode:removeFromParent(true)
                        pBattleUILayerDelegate._pMainPetUINode = nil
                        -- 宠物死光了，则共鸣按钮隐藏
                        pBattleUILayerDelegate._pResonanceSkillAttackButton._pSkillBg:setVisible(false)
                    end
                end
            elseif self:getMaster()._strCharTag == "pvp" then
                self:getPetsManager():changeToNextPvpPetRoleOnMap()             -- 切换宠物对象
                self:getSkillsManager():changeToNextPvpPetRoleSkillsOnMap()     -- 切换宠物技能缓存
            end
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
    
    return
end

-- 退出函数
function BattlePetRoleDeadState:onExit()
    return
end

-- 更新逻辑
function BattlePetRoleDeadState:update(dt)     
    return
end

-- Proc受击瞬间的方向刷新
function BattlePetRoleDeadState:refreshBeatenDirection()
    if self:getMaster() then
        self:getMaster():setAngle3D(self._fBeatenAngle)
        self:getMaster()._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(self._fBeatenAngle)
    end
    return
end

-- 反方向后退位移
function BattlePetRoleDeadState:toBackDistanceWithTime(time)
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

return BattlePetRoleDeadState
