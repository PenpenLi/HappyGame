--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CanbeDestroyedEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/2
-- descrip:   可摧毁性的实体
--===================================================
local CanbeDestroyedEntity = class("CanbeDestroyedEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("Entity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function CanbeDestroyedEntity:ctor()
    self._strName = "CanbeDestroyedEntity"                -- 实体名字
    self._kEntityType = kType.kEntity.kCanbeDestroyed     -- 实体对象类型
    self._pHurtedEffectAnis = {}                          -- 实体受击特效动画

end

-- 创建函数
function CanbeDestroyedEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = CanbeDestroyedEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function CanbeDestroyedEntity:dispose()

    -- 初始化特效
    self:initEffects()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitCanbeDestroyedEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function CanbeDestroyedEntity:onExitCanbeDestroyedEntity()    
    -- 执行父类退出方法
    self:onExitEntity()
end

-- 循环更新
function CanbeDestroyedEntity:updateEntity(dt)
    self:updateGameObj(dt)

end

-- 初始化特效
function CanbeDestroyedEntity:initEffects()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        if self._pEntityInfo.CanBeHurted == 1 then  -- 当前实体对象如果可以被攻击，则加载四种受击特效
            -- 四种受击特效
            self._pHurtedEffectAnis[kType.kSkill.kElement.kPhysic] = cc.CSLoader:createNode("HurtedPhysicEffect.csb")
            self._pHurtedEffectAnis[kType.kSkill.kElement.kFire] = cc.CSLoader:createNode("HurtedFireEffect.csb")
            self._pHurtedEffectAnis[kType.kSkill.kElement.kIce] = cc.CSLoader:createNode("HurtedIceEffect.csb")
            self._pHurtedEffectAnis[kType.kSkill.kElement.kThunder] = cc.CSLoader:createNode("HurtedThunderEffect.csb")
            self:getMapManager()._pTmxMap:addChild(self._pHurtedEffectAnis[kType.kSkill.kElement.kPhysic])
            self:getMapManager()._pTmxMap:addChild(self._pHurtedEffectAnis[kType.kSkill.kElement.kFire])
            self:getMapManager()._pTmxMap:addChild(self._pHurtedEffectAnis[kType.kSkill.kElement.kIce])
            self:getMapManager()._pTmxMap:addChild(self._pHurtedEffectAnis[kType.kSkill.kElement.kThunder])

            self._pHurtedEffectAnis[kType.kSkill.kElement.kPhysic]:setVisible(false)
            self._pHurtedEffectAnis[kType.kSkill.kElement.kFire]:setVisible(false)
            self._pHurtedEffectAnis[kType.kSkill.kElement.kIce]:setVisible(false)
            self._pHurtedEffectAnis[kType.kSkill.kElement.kThunder]:setVisible(false)

        end
    end

end

-- 移除特效动画
function CanbeDestroyedEntity:removeAllEffects()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        if self._pEntityInfo.CanBeHurted == 1 then  -- 当前实体对象如果可以被攻击，则加载四种受击特效
            self._pHurtedEffectAnis[kType.kSkill.kElement.kPhysic]:removeFromParent(true)
            self._pHurtedEffectAnis[kType.kSkill.kElement.kFire]:removeFromParent(true)
            self._pHurtedEffectAnis[kType.kSkill.kElement.kIce]:removeFromParent(true)
            self._pHurtedEffectAnis[kType.kSkill.kElement.kThunder]:removeFromParent(true)
        end
    end
end

-- 播放受击特效
function CanbeDestroyedEntity:playHurtedEffect(type, intersection, isCritical, isBlock)
    local csbName = ""
    if type == kType.kSkill.kElement.kPhysic then
        csbName = "HurtedPhysicEffect.csb"
    elseif type == kType.kSkill.kElement.kFire then
        csbName = "HurtedFireEffect.csb"
    elseif type == kType.kSkill.kElement.kIce then
        csbName = "HurtedIceEffect.csb"
    elseif type == kType.kSkill.kElement.kThunder then
        csbName = "HurtedThunderEffect.csb"
    end

    local action = cc.CSLoader:createTimeline(csbName)

    -- 刷新zorder
    self._pHurtedEffectAnis[type]:setPosition(intersection.x + intersection.width/2,intersection.y + intersection.height/2)
    self._pHurtedEffectAnis[type]:setLocalZOrder(self:getLocalZOrder()+1)

    self._pHurtedEffectAnis[type]:setVisible(true)
    self._pHurtedEffectAnis[type]:stopAllActions()    
    action:gotoFrameAndPlay(0, action:getDuration(), false)   
    self._pHurtedEffectAnis[type]:runAction(action)
    --self._pHurtedEffectAnis[type]:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()),cc.Hide:create()))

    -- 受击音效
    if type == kType.kSkill.kElement.kPhysic then
        AudioManager:getInstance():playEffect("PhysicSound")
    elseif type == kType.kSkill.kElement.kFire then
        AudioManager:getInstance():playEffect("FireSound")
    elseif type == kType.kSkill.kElement.kIce then
        AudioManager:getInstance():playEffect("IceSound")
    elseif type == kType.kSkill.kElement.kThunder then
        AudioManager:getInstance():playEffect("ThunderSound")
    end

end

-- 掉血
function CanbeDestroyedEntity:loseHp()
    if self._pEntityInfo.CanBeHurted == 1 then
        self._pAni:runAction(cc.Sequence:create(cc.TintTo:create(0.2, 255, 0, 0),cc.TintTo:create(0.2, 255, 255, 255))) 
        self._nCurHp = self._nCurHp - 1
        if self._nCurHp <= 0 then
            self._nCurHp = 0
        end
    end
end

-- 受击接口
function CanbeDestroyedEntity:beHurtedBySkill(skill, intersection)
    if self:getTalksManager():isCurTalksFinished() == false then        -- 正在显示剧情对话，则无视伤害
        return
    end
    if self._pEntityInfo.CanBeHurted == 1 then
        if self:getStateMachineByTypeID(kType.kStateMachine.kBattleEntity)._pCurState._kTypeID == kType.kState.kBattleEntity.kDestroy or self._nCurHp <= 0 then
            return
        end

        -- 不考虑加血等回复情况   kType.kAttackMode.kRevert
        if skill._pSkillInfo.AttackMode == kType.kAttackMode.kDamage then
            if skill._pSkillInfo.ElementType then 
                self:playHurtedEffect(skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex], intersection, false, false)
            end
            
            self:loseHp()
            
            -- 攻击者增加怒气
            if skill:getMaster()._kRoleType == kType.kRole.kPlayer then
                local angerValue = 0    -- 怒气值
                if skill == skill:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack] then -- 普通攻击
                    angerValue = TableConstants.GenAngerSpeed.Value * skill._pSkillInfo.HurtFactor[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] * skill:getMaster():getAttriValueByType(kAttribute.kFuryRegeneration)
                elseif skill ~= skill:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] then  -- 技能攻击
                    angerValue = TableConstants.SkillAngerSpeed.Value * skill._pSkillInfo.HurtFactor[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] * skill:getMaster():getAttriValueByType(kAttribute.kFuryRegeneration)
                end
                skill:getMaster():addAnger(angerValue)
                if skill:getMaster()._strCharTag == "main" then
                    self:getBattleManager():getBattleUILayer():showHitAni() -- 显示连击
                end
            elseif skill:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
                local angerValue = 0    -- 怒气值
                if skill == skill:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack] then -- 普通攻击
                    angerValue = TableConstants.GenAngerSpeed.Value * skill._pSkillInfo.HurtFactor[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] * skill:getMaster():getAttriValueByType(kAttribute.kFuryRegeneration)
                elseif skill ~= skill:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] then  -- 技能攻击
                    angerValue = TableConstants.SkillAngerSpeed.Value * skill._pSkillInfo.HurtFactor[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] * skill:getMaster():getAttriValueByType(kAttribute.kFuryRegeneration)
                end
                skill:getMaster():addAnger(angerValue)
            end
            
        end

        if self._nCurHp == 0  then
            self:getStateMachineByTypeID(kType.kStateMachine.kBattleEntity):setCurStateByTypeID(kType.kState.kBattleEntity.kDestroy, true)
            return
        end
    end
end

return CanbeDestroyedEntity
