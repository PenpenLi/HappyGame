--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonsterRole.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/5
-- descrip:   野外怪物角色
--===================================================
local MonsterRole = class("MonsterRole",function()
    return require("Role"):create()
end)

-- 构造函数
function MonsterRole:ctor()
    ------------ 人物参数相关 ---------------------------------------
    self._strName = "MonsterRole"                -- 野怪名字
    self._kRoleType = kType.kRole.kMonster       -- 野怪对象类型
    self._nMonsterType = kType.kMonster.kNone    -- 野怪大类型，如：普通怪、BOSS
    self._pRoleInfo = nil                        -- 野怪信息
    self._pTempleteInfo = nil                    -- 野怪模板信息
    self._fAngle3D = 0                           -- 野怪模型的角度
    self._nTypeID = 0                            -- 野怪类型id，取自副本表中的monsterId
    ----------- 人物特效相关 -----------------------------------------
    self._pHurtedEffectAnis = {}                        -- 野怪受击特效动画
    self._pCriticalHitEffectAni = nil                   -- 野怪暴击特效动画
    self._pBlockHitEffectAni = nil                      -- 野怪格挡特效动画
    self._pMissHitEffectAni = nil                       -- 野怪闪避特效动画       
    self._pAppearEffectAni = nil                        -- 野怪出场特效动画         
    self._pDeadEffectAni = nil                          -- 野怪死亡特效动画
    self._pEarlyWarningEffectAnis = {}                  -- 野怪技能的提前预警特效动画
    self._pMonsterDeadAttachBuffWarningEffectAni = nil  -- 野怪身上挂着的[死亡附加buff提示特效]动画
    ----------- 人物属性相关 ----------------------------------------
    self._pBattleUIDelegate = nil                -- battleUILayer 代理对象
    self._nLevel = 0                             -- 野怪等级
    self._tSkills = {}                           -- 野怪技能集合（主动）
    self._nCurSpeed = 0                          -- 野怪移动速度
    self._tReverseIDSkills = {}                  -- 野怪反向索引技能集合（以技能表中的id号作为下标，唯一索引相应技能，用于使用技能时）
    self._tCurSkillChain = {}                    -- 野怪当前时刻的技能链
    self._nFireAttackValue = 0                   -- 野怪火属性攻击值
    self._nIceAttackValue = 0                    -- 野怪冰属性攻击值
    self._nThunderAttackValue = 0                -- 野怪雷属性攻击值
    self._nAbilityPowerValue = 0                 -- 野怪属性强化值
    self._pHpNode = nil                          -- 野怪血条节点
    self._pHpBar = nil                           -- 野怪血条
    self._pHpBarCache = nil                      -- 野怪缓冲血条
    self._nHpMax = 0                             -- 野怪最大Hp
    self._nCurHp = 0                             -- 野怪当前Hp
    self._pCurDefLevel = 0                       -- 野怪当前的默认防御等级
    self._nCurComboInterupt = 0                  -- 野怪当前连击保户值
    self._fCurHurtedRate = 1.0                   -- 野怪当前受到的伤害比例（用于与整体伤害相乘）
    self._fDebuffTimeRate = 1.0                  -- 野怪debuff持续时间比例（用于与所有debuff的持续时间相乘）
    ----------- 人物 Ref相关 ------------------------------------------
    self._pRefRoleIgnoreHurt = nil               -- 野怪是否无视伤害的引用计数
    self._pRefNotLoseHp = nil                    -- 野怪不掉血引用计数，其他正常（可以应值等等）
    self._pRefGhostOpacity = nil                 -- 野怪虚影半透的引用计数
    
end

-- 创建函数
function MonsterRole:create(pRoleInfo)
    local monster = MonsterRole.new()
    monster:dispose(pRoleInfo)
    return monster
end

-- 处理函数
function MonsterRole:dispose(pRoleInfo)    
    ------------------- 初始化 ----------------------
    -- 设置野怪信息
    self:initInfo(pRoleInfo)
    
    -- 初始化动画
    self:initAni()
    
    -- 初始化特效
    self:initEffects()
    
    -- 初始化Refs
    self:initRefs()

    -- 初始化人物身上默认bottom和body矩形信息
    self:initRects()
    
    -- 初始化血条
    self:initHpBar()
    
    -- 创建控制机
    self:initControllerMachine()
    
    -- 创建状态机
    self:initStateMachine()       
    
    -- 测试：添加波纹特效
    --self:addWaveEffect(kType.kBodyParts.kBody,1)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMonsterRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function MonsterRole:onExitMonsterRole()
    -- 执行父类退出方法
    self:onExitRole()
end

-- 循环更新
function MonsterRole:updateMonsterRole(dt)
    self:updateRole(dt)
    self:refreshEffect()
    self:refreshZorder()

end

-- 初始化信息
function MonsterRole:initInfo(pRoleInfo) 
    self._pRoleInfo = pRoleInfo
    self._nLevel = pRoleInfo.Level
    self._nCurSpeed = pRoleInfo.Speed
    self._nHpMax = self:getAttriValueByType(kAttribute.kHp)
    self._nCurHp = self:getAttriValueByType(kAttribute.kHp)
    self._nViewRange = pRoleInfo.ViewRange
    self._pCurDefLevel = TableTempleteMonster[pRoleInfo.TempleteID].DefenseLevel
    self._nCurComboInterupt = pRoleInfo.ComboInterupt
    self._nMonsterType = pRoleInfo.MonsterType
    self._nFireAttackValue = self:getAttriValueByType(kAttribute.kFireAttack)
    self._nIceAttackValue = self:getAttriValueByType(kAttribute.kColdAttack)
    self._nThunderAttackValue = self:getAttriValueByType(kAttribute.kLightningAttack)
    self._nAbilityPowerValue = self:getAttriValueByType(kAttribute.kAbilityPower)
    
    self._nCurFireSaving = 0
    self._nCurIceSaving = 0
    self._nCurThunderSaving = 0
    self._fSavingPatience = pRoleInfo.Patience

    local rate = 1 + ( (self:getAttriValueByType(kAttribute.kResistance)*TableConstants.AttrMaxResisMax.Value)/(self:getAttriValueByType(kAttribute.kResistance)+TableConstants.AttrMaxResisReduce.Value) )
    self._nFireSavingMax = pRoleInfo.FireMax*rate
    self._nIceSavingMax = pRoleInfo.ColdMax*rate
    self._nThunderSavingMax = pRoleInfo.LigtningMax*rate

    local rate = 1 + ( (self:getAttriValueByType(kAttribute.kResistance)*TableConstants.AttrRecResisMax.Value)/(self:getAttriValueByType(kAttribute.kResistance)+TableConstants.AttrRecResisReduce.Value) )
    self._nFireSavingRecover = pRoleInfo.FireRecover*rate
    self._nIceSavingRecover = pRoleInfo.ColdRecover*rate
    self._nThunderSavingRecover = pRoleInfo.LightningRecover*rate

    self._fDebuffTimeRate = ( (self:getAttriValueByType(kAttribute.kResistance)*TableConstants.DebuffShortenMax.Value)/(self:getAttriValueByType(kAttribute.kResistance)+TableConstants.DebuffShortenReduce.Value) ) 


end

-- 初始化动画
function MonsterRole:initAni()  
    self._pTempleteInfo = TableTempleteMonster[self._pRoleInfo.TempleteID]
    self._kAniType = self._pTempleteInfo.AniType
    self._strAniName = self._pTempleteInfo.Model

    local fullAniName = self._strAniName..".c3b"
    local fullTextureName = self._pTempleteInfo.Texture..".pvr.ccz"
    self._strBodyTexturePvrName = self._pTempleteInfo.Texture
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(self._pTempleteInfo.Texture)
    self._pAni = cc.Sprite3D:create(fullAniName)
    self._pAni:setTexture(fullTextureName)
    self:addChild(self._pAni)

    self._pAni:setScale(self._pTempleteInfo.Scale)
    
    -- 野怪有指定转向
    if self._pTempleteInfo.AppointedRotation ~= -1 then
        self:setAngle3D(self._pTempleteInfo.AppointedRotation)
        self._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(self._pTempleteInfo.AppointedRotation)
    end
    

end

-- 初始化特效
function MonsterRole:initEffects()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        
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
        
        -- 暴击，格挡，闪避 特效
        self._pCriticalHitEffectAni = cc.CSLoader:createNode("CriticalHitEffect.csb")
        self._pBlockHitEffectAni = cc.CSLoader:createNode("BlockHitEffect.csb")
        self._pMissHitEffectAni = cc.CSLoader:createNode("MissHitEffect.csb")  
        self:getMapManager()._pTmxMap:addChild(self._pCriticalHitEffectAni)
        self:getMapManager()._pTmxMap:addChild(self._pBlockHitEffectAni)
        self:getMapManager()._pTmxMap:addChild(self._pMissHitEffectAni)
        
        self._pCriticalHitEffectAni:setVisible(false)
        self._pBlockHitEffectAni:setVisible(false)
        self._pMissHitEffectAni:setVisible(false)
        
        -- 出场特效
        self._pAppearEffectAni = cc.CSLoader:createNode("MonsterDebutEffect.csb")
        self:getMapManager()._pTmxMap:addChild(self._pAppearEffectAni)
        self._pAppearEffectAni:setVisible(false)
        
        -- 死亡特效
        self._pDeadEffectAni = cc.CSLoader:createNode("DeadEffect.csb")
        self:getMapManager()._pTmxMap:addChild(self._pDeadEffectAni)
        self._pDeadEffectAni:setVisible(false)

        -- 身上挂着的[死亡附加buff提示特效]
        if self._pRoleInfo.DeadAttachBuffID ~= -1 then
            self._pMonsterDeadAttachBuffWarningEffectAni = cc.CSLoader:createNode("MonsterDeadAttachBuffWarningEffect"..TableBuff[self._pRoleInfo.DeadAttachBuffID].TypeID..".csb")
            self:getMapManager()._pTmxMap:addChild(self._pMonsterDeadAttachBuffWarningEffectAni)
            self._pMonsterDeadAttachBuffWarningEffectAni:setVisible(false)
        end

        -- 技能提前预警特效
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType1] = cc.CSLoader:createNode("EarlyWarningEffect1.csb")
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType2] = cc.CSLoader:createNode("EarlyWarningEffect2.csb")
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType3] = cc.CSLoader:createNode("EarlyWarningEffect3.csb")
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType4] = cc.CSLoader:createNode("EarlyWarningEffect4.csb")
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType5] = cc.CSLoader:createNode("EarlyWarningEffect4.csb")
        self:getMapManager()._pTmxMap:addChild(self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType1])
        self:getMapManager()._pTmxMap:addChild(self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType2])
        self:getMapManager()._pTmxMap:addChild(self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType3])
        self:getMapManager()._pTmxMap:addChild(self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType4])
        self:getMapManager()._pTmxMap:addChild(self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType5])
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType1]:setVisible(false)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType2]:setVisible(false)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType3]:setVisible(false)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType4]:setVisible(false)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType5]:setVisible(false)

    end

end

-- 移除特效动画
function MonsterRole:removeAllEffects()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then  
        self._pHurtedEffectAnis[kType.kSkill.kElement.kPhysic]:removeFromParent(true)
        self._pHurtedEffectAnis[kType.kSkill.kElement.kFire]:removeFromParent(true)
        self._pHurtedEffectAnis[kType.kSkill.kElement.kIce]:removeFromParent(true)
        self._pHurtedEffectAnis[kType.kSkill.kElement.kThunder]:removeFromParent(true)
        self._pCriticalHitEffectAni:removeFromParent(true)
        self._pBlockHitEffectAni:removeFromParent(true)
        self._pMissHitEffectAni:removeFromParent(true)
        self._pAppearEffectAni:removeFromParent(true)
        self._pDeadEffectAni:removeFromParent(true)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType1]:removeFromParent(true)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType2]:removeFromParent(true)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType3]:removeFromParent(true)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType4]:removeFromParent(true)
        self._pEarlyWarningEffectAnis[kType.kSkillEarlyWarning.kType5]:removeFromParent(true)
        if self._pMonsterDeadAttachBuffWarningEffectAni then
            self._pMonsterDeadAttachBuffWarningEffectAni:removeFromParent(true)
        end

    end
end

-- 初始化引用计数
function MonsterRole:initRefs()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        -- 创建无视攻击状态引用计数
        self._pRefRoleIgnoreHurt = require("RoleIgnoreBeatRef"):create(self)
        -- 角色不掉血引用计数，其他正常（可以应值等等）
        self._pRefNotLoseHp = require("RoleNotLoseHpRef"):create(self)
        -- 角色虚影半透的引用计数 
        self._pRefGhostOpacity = require("RoleGhostRef"):create(self)                    
    end
    
end

-- 显示野怪死亡附加buff
function MonsterRole:playMonsterDeadAttachBuffWarningEffect()
    if self._pMonsterDeadAttachBuffWarningEffectAni then
        self._pMonsterDeadAttachBuffWarningEffectAni:setVisible(true)
        self._pMonsterDeadAttachBuffWarningEffectAni:stopAllActions()
        local action = cc.CSLoader:createTimeline("MonsterDeadAttachBuffWarningEffect"..TableBuff[self._pRoleInfo.DeadAttachBuffID].TypeID..".csb")
        action:gotoFrameAndPlay(0, action:getDuration(), true)
        self._pMonsterDeadAttachBuffWarningEffectAni:runAction(action)
    end

end

-- 设置当前移动速度比例（有叠加效果）
-- 参数：0到1 表示  0%到100%
function MonsterRole:setCurSpeedPercent(percent)
    self._nCurSpeed = self._nCurSpeed * percent
end

-- 复位角色速度
function MonsterRole:resetSpeed()
    self._nCurSpeed = self._pRoleInfo.Speed
end

-- 设置当前可能受到的所有伤害的比例（有叠加效果）
-- 参数：0到1 表示  0%到100%
function MonsterRole:setCurHurtedPercent(percent)
    self._fCurHurtedRate = self._fCurHurtedRate * percent
end

-- 复位角色伤害比例
function MonsterRole:resetHurtedRate()
    self._fCurHurtedRate = 1.0
end

-- 播放受击特效
function MonsterRole:playHurtedEffect(type, intersection, isCritical, isBlock)
    if isBlock == true then
        self:showBlockEffect(intersection)
        return
    elseif isCritical == true then
        self:showCriticalEffect(intersection)
        return
    end

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

-- 播放技能预警特效
function MonsterRole:playSkillEarlyWarningEffect(skill, type)

    self._pEarlyWarningEffectAnis[type]:setVisible(true)
    
    local csbName = ""
    local pos = nil
    local zorder = nil
    local target = nil
    if type == kType.kSkillEarlyWarning.kType1 then
        csbName = "EarlyWarningEffect1.csb"
        pos = cc.p(self:getPositionX(), self:getPositionY() + self:getHeight()/2)
        zorder = kZorder.kMax
    elseif type == kType.kSkillEarlyWarning.kType2 then
        csbName = "EarlyWarningEffect2.csb"
        local tTargets = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self, skill._pSkillInfo.WarnRange, nil, skill._pSkillInfo.TargetGroupType)
        if table.getn(tTargets) ~= 0 then
            target = tTargets[1].enemy
            pos = cc.p(target:getPositionX(), target:getPositionY()+target:getHeight()/2)
        else
            pos = cc.p(self:getPositionX(), self:getPositionY()+self:getHeight()/2)
            self._pEarlyWarningEffectAnis[type]:setVisible(false)
        end
        zorder = kZorder.kMax
    elseif type == kType.kSkillEarlyWarning.kType3 then
        csbName = "EarlyWarningEffect3.csb"
        pos = cc.p(self:getPositionX(), self:getPositionY())
        zorder = kZorder.kMinRole
        local tTargets = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self, skill._pSkillInfo.WarnRange, nil, skill._pSkillInfo.TargetGroupType)
        local endPos = nil
        if table.getn(tTargets) ~= 0 then
            target = tTargets[1].enemy
            endPos = cc.p(target:getPositionX(), target:getPositionY())
        else
            endPos = cc.p(self:getPositionX(), self:getPositionY())
            self._pEarlyWarningEffectAnis[type]:setVisible(false)
        end
        local rotation = mmo.HelpFunc:gAngleAnalyseForRotation(endPos.x, endPos.y, pos.x, pos.y)
        rotation = (math.modf(-rotation+90))%360  -- 补一个起始差值
        self._pEarlyWarningEffectAnis[type]:setRotation(rotation)
    elseif type == kType.kSkillEarlyWarning.kType4 then
        csbName = "EarlyWarningEffect4.csb"
        pos = cc.p(self:getPositionX(), self:getPositionY())
        zorder = kZorder.kMinRole
    elseif type == kType.kSkillEarlyWarning.kType5 then
        csbName = "EarlyWarningEffect4.csb"
        local tTargets = self:getAIManager():objSearchNearestEnemysInRangeForDamage(self, skill._pSkillInfo.WarnRange, nil, skill._pSkillInfo.TargetGroupType)
        if table.getn(tTargets) ~= 0 then
            target = tTargets[1].enemy
            pos = cc.p(target:getPositionX(), target:getPositionY())
        else
            pos = cc.p(self:getPositionX(), self:getPositionY())
            self._pEarlyWarningEffectAnis[type]:setVisible(false)
        end
        zorder = kZorder.kMinRole
    end
    
    local action = cc.CSLoader:createTimeline(csbName)

    -- 刷新zorder
    self._pEarlyWarningEffectAnis[type]:setPosition(pos)
    self._pEarlyWarningEffectAnis[type]:setLocalZOrder(zorder)  
    self._pEarlyWarningEffectAnis[type]:stopAllActions()    
    action:gotoFrameAndPlay(0, action:getDuration(), false)
    self._pEarlyWarningEffectAnis[type]:runAction(action)
    self._pEarlyWarningEffectAnis[type]:runAction(cc.Sequence:create(cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()),cc.Hide:create()))

    local time = action:getDuration()*cc.Director:getInstance():getAnimationInterval()

    return time, target
end

-- 显示出场特效
function MonsterRole:playAppearEffect()
    -- 刷新zorder
    self._pAppearEffectAni:setPosition(self:getPositionX(), self:getPositionY() + self:getHeight()/2)
    self._pAppearEffectAni:setLocalZOrder(self:getLocalZOrder()+1)
    self._pAppearEffectAni:setScale(self:getHeight() / 200)
    self._pAppearEffectAni:setVisible(true)
    self._pAppearEffectAni:stopAllActions()
    local action = cc.CSLoader:createTimeline("MonsterDebutEffect.csb")
    action:gotoFrameAndPlay(0, action:getDuration(), false)   
    self._pAppearEffectAni:runAction(action)
    self._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()*0.5), cc.Show:create()))

end

-- 显示死亡特效
function MonsterRole:playDeadEffect()
    -- 刷新zorder
    self._pDeadEffectAni:setPosition(self:getPositionX(), self:getPositionY() + self:getHeight()/2)
    self._pDeadEffectAni:setLocalZOrder(self:getLocalZOrder()+1)
    self._pDeadEffectAni:setScale(self:getHeight() / 80)
    self._pDeadEffectAni:setVisible(true)
    self._pDeadEffectAni:stopAllActions()
    local action = cc.CSLoader:createTimeline("DeadEffect.csb")
    action:gotoFrameAndPlay(0, action:getDuration(), false)   
    self._pDeadEffectAni:runAction(action)

end

-- 显示掉金币特效（仅限金钱副本） 参数goldAmount = 1 少量金币   goldAmount = 2 大量金币
function MonsterRole:playGoldDropEffect(goldAmount)
    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kGold then
        -- 掉金币特效（仅限金钱副本）
        local pGoldDropEffectAni = cc.CSLoader:createNode("GoldDropEffect.csb")
        self:getMapManager()._pTmxMap:addChild(pGoldDropEffectAni)
        pGoldDropEffectAni:setPosition(self:getPositionX(), self:getPositionY() + self:getHeight()/2)
        pGoldDropEffectAni:setLocalZOrder(self:getLocalZOrder()+1)
        local action = cc.CSLoader:createTimeline("GoldDropEffect.csb")
        pGoldDropEffectAni:stopAllActions()
        if goldAmount == 1 then   -- 少量金币
            action:gotoFrameAndPlay(0, 40, false)
            pGoldDropEffectAni:runAction(action)
            pGoldDropEffectAni:runAction(cc.Sequence:create(cc.DelayTime:create(40*cc.Director:getInstance():getAnimationInterval()), cc.RemoveSelf:create()))
        elseif goldAmount == 2 then  -- 大量金币
            action:gotoFrameAndPlay(50, 125, false)
            pGoldDropEffectAni:runAction(action)
            pGoldDropEffectAni:runAction(cc.Sequence:create(cc.DelayTime:create(75*cc.Director:getInstance():getAnimationInterval()), cc.RemoveSelf:create()))
        end
        self:refreshCamera()
        -- 掉金币音效
        AudioManager:getInstance():playEffect("GoldDrop")
    end

end

-- 显示变身特效
function MonsterRole:playShapeChangeEffect()
    -- 变身特效
    local pShapeChangeEffectAni = cc.CSLoader:createNode("ChangeRole.csb")
    self:getMapManager()._pTmxMap:addChild(pShapeChangeEffectAni)
    pShapeChangeEffectAni:setPosition(self:getPositionX(), self:getPositionY() + self:getHeight()/2)
    pShapeChangeEffectAni:setLocalZOrder(self:getLocalZOrder()+1)
    local action = cc.CSLoader:createTimeline("ChangeRole.csb")
    pShapeChangeEffectAni:stopAllActions()
    action:gotoFrameAndPlay(0, action:getDuration(), false)
    pShapeChangeEffectAni:runAction(action)
    pShapeChangeEffectAni:runAction(cc.Sequence:create(cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()), cc.RemoveSelf:create()))
    self:refreshCamera()
    -- 变身音效
    AudioManager:getInstance():playEffect("ShapeChange")

end

-- 初始化人物身上默认bottom和body矩形信息
function MonsterRole:initRects()
    local tTempleteInfo = TableTempleteMonster[self._pRoleInfo.TempleteID]
    local rectBottom = tTempleteInfo.BottomRect
    local rectBody = tTempleteInfo.BodyRect
    self._recBottomOnObj = cc.rect(rectBottom[1], rectBottom[2], rectBottom[3], rectBottom[4])
    self._recBodyOnObj = cc.rect(rectBody[1], rectBody[2], rectBody[3], rectBody[4])
end

-- 刷新zorder和3d模型的positionZ
function MonsterRole:refreshZorder()    
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        -- 当前不为死亡状态时都会刷新zorder
        if self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID ~= kType.kState.kBattleMonster.kDead then
            if self._bForceMinPositionZ == true then   -- 强制positionZ
                self:setPositionZ(self._nForceMinPositionZValue)
            else                                    -- 非强制positionZ
                self:setPositionZ(self:getPositionIndex().y*(self:getMapManager()._f3DZ))
            end
            self:setLocalZOrder(kZorder.kMinRole + self:getMapManager()._sMapRectPixelSize.height - self:getPositionY())
        end
    end
end

-- 刷新特效
function MonsterRole:refreshEffect()
    -- 刷新野怪附加buff的位置
    if self._pMonsterDeadAttachBuffWarningEffectAni then
        self._pMonsterDeadAttachBuffWarningEffectAni:setPosition(self:getPositionX(), self:getPositionY())
        self._pMonsterDeadAttachBuffWarningEffectAni:setLocalZOrder(self:getLocalZOrder()+1)
    end
end

-- 设置battleuilayer 代理
function MonsterRole:setBattleUILayerDelegate( delegate )
    self._pBattleUIDelegate = delegate
    
    self._pBattleUIDelegate._pBossHpNode:setBossName(TableTempleteMonster[self._pRoleInfo.TempleteID].Name)
    self._pBattleUIDelegate._pBossHpNode:setBossHpMax(self._nHpMax)
    self._pBattleUIDelegate._pBossHpNode:setBossHpNum(self._pRoleInfo.HpBarNumber)
    self._pBattleUIDelegate._pBossHpNode:setBossHpCur(self._nHpMax, true)
   
end

-- 初始化人物血条
function MonsterRole:initHpBar()

    local pBG = cc.Sprite:createWithSpriteFrameName("BloodBarAniRes/BloodBarFrame.png")
    local pBar = cc.Sprite:createWithSpriteFrameName("BloodBarAniRes/BloodBar.png")
    local pBarCache = cc.Sprite:createWithSpriteFrameName("BloodBarAniRes/BloodBarCache.png")
    
    self._pHpNode = pBG
    self._pHpNode:setPosition(0,TableTempleteMonster[self._pRoleInfo.TempleteID].Height)
    
    self._pHpBar = cc.ProgressTimer:create(pBar)
    self._pHpBar:setAnchorPoint(0,0)
    self._pHpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pHpBar:setMidpoint(cc.p(0,0))
    self._pHpBar:setBarChangeRate(cc.p(1,0))
    self._pHpBar:setPercentage(self._nCurHp / self._nHpMax * 100)

    self._pHpBarCache = cc.ProgressTimer:create(pBarCache)
    self._pHpBarCache:setAnchorPoint(0,0)
    self._pHpBarCache:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pHpBarCache:setMidpoint(cc.p(0,0))
    self._pHpBarCache:setBarChangeRate(cc.p(1,0))
    self._pHpBarCache:setPercentage(self._nCurHp / self._nHpMax * 100)

    self._pHpNode:addChild(self._pHpBarCache)
    self._pHpNode:addChild(self._pHpBar)
    self._pHpNode:setVisible(false)
    self:addChild(self._pHpNode)

end

-- 获取身高
function MonsterRole:getHeight()
    local height = TableTempleteMonster[self._pRoleInfo.TempleteID].Height
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        if self._pControllerMachineDelegate then
            if self:getBuffControllerMachine():isBuffExist(kType.kController.kBuff.kBattleHpLimitUpBuff) == true then
                height = height*1.8  -- scale=1.8
            end
        end
    end
    return height
end

-- 设置血量
function MonsterRole:setHp(value,maxValue) 
    value = math.ceil(value)

    self._nCurHp = value
    self._nHpMax = maxValue

    if self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID ~= kType.kState.kBattleMonster.kDead then
        if self._nMonsterType == kType.kMonster.kNormal then    -- 普通怪
            self._pHpBar:setPercentage(self._nCurHp / self._nHpMax * 100)
            self._pHpBarCache:setPercentage(self._nCurHp / self._nHpMax * 100)
        elseif self._nMonsterType == kType.kMonster.kBOSS or self._nMonsterType == kType.kMonster.kThiefBOSS then    -- BOSS
            if self._pBattleUIDelegate then
                self._pBattleUIDelegate._pBossHpNode:setBossHpMax(self._nHpMax)
                self._pBattleUIDelegate._pBossHpNode:setBossHpCur(self._nCurHp)
                self._pBattleUIDelegate._pBossHpNode:setBossHpNum(self._pRoleInfo.HpBarNumber)
            end
        end
    end

end

-- 加血
function MonsterRole:addHp(value)
    if self._nCurHp <= 0 then
        return
    end
    if value <= 0 then
        return
    end
    value = math.ceil(value)
    
    self:showNum("+", value)
    self._nCurHp = self._nCurHp + value
    if self._nCurHp >= self._nHpMax then
        self._nCurHp = self._nHpMax 
    end
    
    if self._nMonsterType == kType.kMonster.kNormal then    -- 普通怪
        self._pHpBar:setPercentage(self._nCurHp / self._nHpMax * 100)
        self._pHpBarCache:setPercentage(self._nCurHp / self._nHpMax * 100)
        self._pHpNode:stopAllActions()
        self._pHpNode:runAction(cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(2.0), cc.Hide:create()))
    elseif self._nMonsterType == kType.kMonster.kBOSS or self._nMonsterType == kType.kMonster.kThiefBOSS then    -- BOSS
        if self._pBattleUIDelegate then
            self._pBattleUIDelegate._pBossHpNode:setBossHpCur(self._nCurHp)
        end
    end

end

-- 掉血
-- 参数1：掉血值
-- 参数2：是否暴击
function MonsterRole:loseHp(value, isCritical)
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    -- 如果处于非掉血状况，则直接返回
    if self._pRefNotLoseHp:getBeNotLoseHpOrNot() == true or value <= 0 then
        return
    end
    value = math.ceil(value)
    -- 变色
    local act = cc.Sequence:create(cc.TintTo:create(0.2, 255, 0, 0),cc.TintTo:create(0.2, self._pCurBuffColor["r"], self._pCurBuffColor["g"], self._pCurBuffColor["b"]))
    act:setTag(nRoleLoseHpActAction)
    self._pAni:runAction(act)
     
    self:showNum("-", value, isCritical)
    self._nCurHp = self._nCurHp - value
    if self._nCurHp <= 0 then
        self._nCurHp = 0 
    end
    
    if self._nMonsterType == kType.kMonster.kNormal then    -- 普通怪
        self._pHpBar:setPercentage(self._nCurHp / self._nHpMax * 100)
        self._pHpBarCache:stopAllActions()
        self._pHpBarCache:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, self._nCurHp/self._nHpMax*100.0)))
        self._pHpNode:stopAllActions()
        self._pHpNode:runAction(cc.Sequence:create(cc.Show:create(), cc.DelayTime:create(2.0), cc.Hide:create()))
    elseif self._nMonsterType == kType.kMonster.kBOSS or self._nMonsterType == kType.kMonster.kThiefBOSS then    -- BOSS
        if self._pBattleUIDelegate then
            self._pBattleUIDelegate._pBossHpNode:setBossHpCur(self._nCurHp)
        end
    end

end

-- 显示数字
function MonsterRole:showNum(flag, textNum, isCritical)
    local fntFileName = ""
    local numMaxScale = 1.6
    if flag == "+" then
        fntFileName = "fnt_add_blood.fnt" 
    else
        if isCritical == true then  -- 是暴击
            fntFileName = "fnt_lose_blood.fnt"  -- 红字
            numMaxScale = 2.2
        else
            fntFileName = "fnt_lose_blood1.fnt"  -- 黄字
        end
    end
    local pTextNum = cc.LabelBMFont:create(flag..textNum, fntFileName)
    self:addChild(pTextNum)
    pTextNum:setScale(0.2)
    pTextNum:setPosition(0,self:getHeight() + getRandomNumBetween(0,50))
    pTextNum:runAction(cc.Sequence:create( cc.EaseExponentialIn:create(cc.ScaleTo:create(0.15, numMaxScale)), cc.EaseExponentialIn:create(cc.ScaleTo:create(0.1, 0.8)), cc.DelayTime:create(0.3), cc.Spawn:create( cc.EaseExponentialInOut:create(cc.MoveBy:create(0.7,cc.p(0, 50))), cc.EaseExponentialInOut:create(cc.FadeOut:create(0.7))), cc.RemoveSelf:create()))
    self:refreshCamera()
end

-- 显示暴击特效
function MonsterRole:showCriticalEffect(intersection)
    -- 刷新zorder
    self._pCriticalHitEffectAni:setPosition(intersection.x + intersection.width/2,intersection.y + intersection.height/2)
    self._pCriticalHitEffectAni:setLocalZOrder(self:getLocalZOrder()+1)    
    
    self._pCriticalHitEffectAni:setVisible(true)
    self._pCriticalHitEffectAni:stopAllActions()    
    local action = cc.CSLoader:createTimeline("CriticalHitEffect.csb")
    action:gotoFrameAndPlay(0, action:getDuration(), false)   
    self._pCriticalHitEffectAni:runAction(action)

end

-- 显示格挡特效
function MonsterRole:showBlockEffect(intersection)
    -- 刷新zorder
    self._pBlockHitEffectAni:setPosition(intersection.x + intersection.width/2,intersection.y + intersection.height/2)
    self._pBlockHitEffectAni:setLocalZOrder(self:getLocalZOrder()+1)

    self._pBlockHitEffectAni:setVisible(true)
    self._pBlockHitEffectAni:stopAllActions()  
    local action = cc.CSLoader:createTimeline("BlockHitEffect.csb")   
    action:gotoFrameAndPlay(0, action:getDuration(), false)   
    self._pBlockHitEffectAni:runAction(action)

    -- 格挡时发生卡顿
    self:roleKartun(TableConstants.BlockKadun.Value)

end

-- 显示闪避特效
function MonsterRole:showMissEffect()    
    -- 刷新zorder
    self._pMissHitEffectAni:setPosition(self:getPositionX(), self:getPositionY() + self:getHeight()*0.8)
    self._pMissHitEffectAni:setLocalZOrder(self:getLocalZOrder()+1)

    self._pMissHitEffectAni:setVisible(true)
    self._pMissHitEffectAni:stopAllActions()
    local action = cc.CSLoader:createTimeline("MissHitEffect.csb")   
    action:gotoFrameAndPlay(0, action:getDuration(), false)   
    self._pMissHitEffectAni:runAction(action)

end

-- 创建Monster状态机
function MonsterRole:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleMonsterStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 创建人物角色控制机
function MonsterRole:initControllerMachine()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        self._pControllerMachineDelegate = require("ControllerMachineDelegate"):create()
        local pControllerMachine = require("BattleBuffControllerMachine"):create(self)
        self._pControllerMachineDelegate:addControllerMachine(pControllerMachine)
    end

end

-- 设置3D模型的角度
function MonsterRole:setAngle3D(angle)
    self._fAngle3D = (math.modf(angle+90))%360  -- 补一个起始差值
    local rotaion3D = self._pAni:getRotation3D()
    rotaion3D.y = self._fAngle3D
    self._pAni:setRotation3D(rotaion3D)
end

-- 获取3D模型的角度
function MonsterRole:getAngle3D()
    local fAngle3D = (math.modf(self._fAngle3D-90))%360
    return math.abs(fAngle3D)
end

-- 随机获取准备使用的技能链
function MonsterRole:initRandomSkillChain()
    -- 获取随机数确定当前要使用的技能链的index
    local randomNum = getRandomNumBetween(1,100) 
    local nCurSkillChainIndex = 0
    for k,v in pairs(self._pRoleInfo.SkillChainChance) do 
        if randomNum <= v then
            nCurSkillChainIndex = k
            break
        end
    end
    -- 确定技能链
    self._tCurSkillChain = self._pRoleInfo.SkillChain[nCurSkillChainIndex]
   
end

-- 播放出场动作
function MonsterRole:playAppearAction()
    -- 出场动作
    if self._pTempleteInfo.AppearActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.AppearActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.AppearActFrameRegion[2]
        local appear = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        appear:setSpeed(self._pTempleteInfo.AppearActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        appear:setTag(nRoleActAction)
        self._pAni:runAction(appear)
    end

end

-- 获取出场动作的时间间隔（单位：秒）
function MonsterRole:getAppearActionTime()
    local duration = (self._pTempleteInfo.AppearActFrameRegion[2] - self._pTempleteInfo.AppearActFrameRegion[1])/30
    local speed = self._pTempleteInfo.AppearActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放站立动作
function MonsterRole:playStandAction()
    -- 站立动作
    if self._pTempleteInfo.StandActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.StandActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.StandActFrameRegion[2]
        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        temp:setSpeed(self._pTempleteInfo.StandActFrameRegion[3])
        local stand = cc.RepeatForever:create(temp)
        self._pAni:stopActionByTag(nRoleActAction)
        stand:setTag(nRoleActAction)
        self._pAni:runAction(stand)
    end
end

-- 获取站立动作的时间间隔（单位：秒）
function MonsterRole:getStandActionTime()
    local duration = (self._pTempleteInfo.StandActFrameRegion[2] - self._pTempleteInfo.StandActFrameRegion[1])/30
    local speed = self._pTempleteInfo.StandActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放奔跑动作
function MonsterRole:playRunAction()
    -- 奔跑动作
    if self._pTempleteInfo.RunActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.RunActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.RunActFrameRegion[2]
        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        temp:setSpeed(self._pTempleteInfo.RunActFrameRegion[3])
        local run = cc.RepeatForever:create(temp)
        self._pAni:stopActionByTag(nRoleActAction)
        run:setTag(nRoleActAction)
        self._pAni:runAction(run)
    end

end

-- 获取奔跑动作的时间间隔（单位：秒）
function MonsterRole:getRunActionTime()
    local duration = (self._pTempleteInfo.RunActFrameRegion[2] - self._pTempleteInfo.RunActFrameRegion[1])/30
    local speed = self._pTempleteInfo.RunActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放受击动作
function MonsterRole:playBeatenAction()
    -- 受击动作
    if self._pTempleteInfo.BeatenActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.BeatenActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.BeatenActFrameRegion[2]
        local beaten = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        beaten:setSpeed(self._pTempleteInfo.BeatenActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        beaten:setTag(nRoleActAction)
        self._pAni:runAction(beaten)
    end

end

-- 获取受击动作的时间间隔（单位：秒）
function MonsterRole:getBeatenActionTime()
    local duration = (self._pTempleteInfo.BeatenActFrameRegion[2] - self._pTempleteInfo.BeatenActFrameRegion[1])/30
    local speed = self._pTempleteInfo.BeatenActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放倒地动作
function MonsterRole:playFallGroundAction()
    -- 倒地动作
    if self._pTempleteInfo.FallGroundActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.FallGroundActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.FallGroundActFrameRegion[2]
        local fallGround = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        fallGround:setSpeed(self._pTempleteInfo.FallGroundActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        fallGround:setTag(nRoleActAction)
        self._pAni:runAction(fallGround)
    end

end

-- 获取倒地动作的时间间隔（单位：秒）
function MonsterRole:getFallGroundActionTime()
    local duration = (self._pTempleteInfo.FallGroundActFrameRegion[2] - self._pTempleteInfo.FallGroundActFrameRegion[1])/30
    local speed = self._pTempleteInfo.FallGroundActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放起身动作
function MonsterRole:playUpGroundAction()
    -- 起身动作
    if self._pTempleteInfo.UpGroundActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.UpGroundActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.UpGroundActFrameRegion[2]
        local upGround = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        upGround:setSpeed(self._pTempleteInfo.UpGroundActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        upGround:setTag(nRoleActAction)
        self._pAni:runAction(upGround)
    end

end

-- 获取起身动作的时间间隔（单位：秒）
function MonsterRole:getUpGroundActionTime()
    local duration = (self._pTempleteInfo.UpGroundActFrameRegion[2] - self._pTempleteInfo.UpGroundActFrameRegion[1])/30
    local speed = self._pTempleteInfo.UpGroundActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放眩晕动作
function MonsterRole:playDizzyAction()
    -- 眩晕动作
    if self._pTempleteInfo.DizzyActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.DizzyActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.DizzyActFrameRegion[2]
        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        temp:setSpeed(self._pTempleteInfo.DizzyActFrameRegion[3])
        local dizzy = cc.RepeatForever:create(temp)
        self._pAni:stopActionByTag(nRoleActAction)
        dizzy:setTag(nRoleActAction)
        self._pAni:runAction(dizzy)
    end
    
end

-- 获取眩晕动作的时间间隔（单位：秒）
function MonsterRole:getDizzyActionTime()
    local duration = (self._pTempleteInfo.DizzyActFrameRegion[2] - self._pTempleteInfo.DizzyActFrameRegion[1])/30
    local speed = self._pTempleteInfo.DizzyActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放死亡动作
function MonsterRole:playDeadAction()
    -- 死亡动作
    if self._pTempleteInfo.DeadActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.DeadActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.DeadActFrameRegion[2]
        local dead = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        dead:setSpeed(self._pTempleteInfo.DeadActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        dead:setTag(nRoleActAction)
        self._pAni:runAction(dead)
    end 

end

-- 获取死亡动作的时间间隔（单位：秒）
function MonsterRole:getDeadActionTime()
    local duration = (self._pTempleteInfo.DeadActFrameRegion[2] - self._pTempleteInfo.DeadActFrameRegion[1])/30
    local speed = self._pTempleteInfo.DeadActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放攻击动作
function MonsterRole:playAttackAction(index)
    -- 攻击动作
    if self._pTempleteInfo.AttackActFrameRegions ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local region = self._pTempleteInfo.AttackActFrameRegions[index]
        local fStartFrame = region[1]
        local fEndFrame = region[2]
        local attack = nil
        if region[3] == false then       -- 单次动作
            attack = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
            attack:setSpeed(region[4])
        elseif region[3] == true then   -- 循环动作
            local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
            temp:setSpeed(region[4])
            attack = cc.RepeatForever:create(temp)
        end
        self._pAni:stopActionByTag(nRoleActAction)
        attack:setTag(nRoleActAction)
        self._pAni:runAction(attack)
    end

end

-- 获取攻击动作的时间间隔（单位：秒）
function MonsterRole:getAttackActionTime(index)
    local duration = (self._pTempleteInfo.AttackActFrameRegions[index][2] - self._pTempleteInfo.AttackActFrameRegions[index][1])/30
    local speed = self._pTempleteInfo.AttackActFrameRegions[index][4]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 是否为异常状态（如死亡、眩晕、冻结、出场、应值等）
function MonsterRole:isUnusualState()
    local state = self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState
    if state._kTypeID ~= kType.kState.kBattleMonster.kDead and
       state._kTypeID ~= kType.kState.kBattleMonster.kBeaten and
       state._kTypeID ~= kType.kState.kBattleMonster.kAppear and 
       state._kTypeID ~= kType.kState.kBattleMonster.kSuspend and 
       state._kTypeID ~= kType.kState.kBattleMonster.kFrozen and 
       state._kTypeID ~= kType.kState.kBattleMonster.kDizzy and
       self._nCurHp > 0 then
        return false
    end
    return true
end

-- 获取战斗中的属性值
function MonsterRole:getAttriValueByType(type)
    local value = 0
    local offset = self._fAttriValueOffsets[type]

    if type == kAttribute.kHp then  -- 生命值
        value = self._pRoleInfo.Hp
    elseif type == kAttribute.kAttack then  -- 攻击力
        value = self._pRoleInfo.Attack
    elseif type == kAttribute.kDefend then  -- 防御
        value = self._pRoleInfo.Defend
    elseif type == kAttribute.kCritChance then  -- 暴击几率
        value = self._pRoleInfo.CriticalChance
    elseif type == kAttribute.kCritDmage then -- 暴击伤害
        value = self._pRoleInfo.CriticalDmage
    elseif type == kAttribute.kResilience then -- 韧性
        value = self._pRoleInfo.Resilience
    elseif type == kAttribute.kResistance then -- 抗性
        value = self._pRoleInfo.Resistance
    elseif type == kAttribute.kBlock then -- 格挡
        value = self._pRoleInfo.Block
    elseif type == kAttribute.kPenetration then -- 穿透
        value = self._pRoleInfo.Penetration
    elseif type == kAttribute.kDodgeChance then -- 闪避
        value = self._pRoleInfo.DodgeChance
    elseif type == kAttribute.kAbilityPower then -- 属性强化
        value = self._pRoleInfo.AbilityPower
    elseif type == kAttribute.kFireAttack then -- 火属性攻击
        value = self._pRoleInfo.FireAttack
    elseif type == kAttribute.kColdAttack then -- 冰属性攻击
        value = self._pRoleInfo.ColdAttack
    elseif type == kAttribute.kLightningAttack then -- 雷属性攻击
        value = self._pRoleInfo.LightningAttack
    elseif type == kAttribute.kLifePerSecond then -- 再生
        value = self._pRoleInfo.LifeperSecond
    elseif type == kAttribute.kLifeSteal then -- 吸血比率
        value = self._pRoleInfo.LifeSteal
    end

    return value + offset
end

-- 设置战斗中的属性值的偏移变化值
function MonsterRole:addAttriValueOffset(type,value)
    self._fAttriValueOffsets[type] = self._fAttriValueOffsets[type] + value
end

-- 获取战斗中当前的防御等级
function MonsterRole:getCurDefenseLevel()
    return self._pCurDefLevel + self._nDefenseLevelOffset
end

-- 设置战斗中的需要添加的防御等级值变化偏移值
function MonsterRole:addDefenseLevelOffset(value)
    self._nDefenseLevelOffset = self._nDefenseLevelOffset + value
    if self._nDefenseLevelOffset <= 0 then
        self._nDefenseLevelOffset = 0
    end
end

-- 技能影响到的受击接口
function MonsterRole:beHurtedBySkill(skill, intersection)
    if self:getTalksManager():isCurTalksFinished() == false then        -- 正在显示剧情对话，则无视伤害
        return
    end
    -- 战斗结果已经得出，则不再有任何影响
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    
    if skill._pSkillInfo.AttackMode == kType.kAttackMode.kDamage then  -- 伤害
        
        if self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID == kType.kState.kBattleMonster.kDead or
           self._nCurHp <= 0 or self._pRefRoleIgnoreHurt:getBeIgnoreHurtOrNot() == true then
            return
        end
        
        local blockValue = 0        -- 格挡值
        local criticalValue = 1     -- 暴击值
        local isCritical = false    -- 是否为暴击
        local isBlock = false       -- 是否为格挡
        local isMiss = false        -- 是否为闪避
        local suckBloodRate = 0     -- 吸血率
        if skill:getMaster()._kGameObjType == kType.kGameObj.kRole then
            -- [防守方]闪避率 （只在攻击方为角色类型时考虑）
            local missRate = 1000*(self:getAttriValueByType(kAttribute.kDodgeChance)*TableConstants.DodgeChanceMax.Value)/(self:getAttriValueByType(kAttribute.kDodgeChance)+TableLevel[skill:getMaster()._nLevel].Flv*TableConstants.DodgeChanceReduce.Value)
            local randNum = getRandomNumBetween(1,1000)
            if randNum <= missRate then -- 闪避成功
                isMiss = true
                self:showMissEffect()
                return
            end
            -- [防守方]考虑格挡率
            local blockRate = 1000*(self:getAttriValueByType(kAttribute.kBlock)*TableConstants.BlockChanceMax.Value)/(self:getAttriValueByType(kAttribute.kBlock)+TableLevel[skill:getMaster()._nLevel].Flv*TableConstants.BlockChanceReduce.Value)
            local randNum = getRandomNumBetween(1,1000)
            if randNum <= blockRate then -- 格挡成功
                isBlock = true
                blockValue = self:getAttriValueByType(kAttribute.kBlock)*TableConstants.BlockByBlock.Value + self:getAttriValueByType(kAttribute.kDefend)*TableConstants.BlockByDefence.Value + TableConstants.BlockValueMin.Value
            end
            if self._bMustBlock == true then  -- 必须格挡
                isBlock = true
                blockValue = self:getAttriValueByType(kAttribute.kBlock)*TableConstants.BlockByBlock.Value + self:getAttriValueByType(kAttribute.kDefend)*TableConstants.BlockByDefence.Value + TableConstants.BlockValueMin.Value
            end
            -- [攻击方]考虑暴击率
            local a = skill:getMaster():getAttriValueByType(kAttribute.kCritChance)
            local b = (1-((self:getAttriValueByType(kAttribute.kResilience)*TableConstants.CriticalChanceResisMax.Value)/(self:getAttriValueByType(kAttribute.kResilience) + TableLevel[skill:getMaster()._nLevel].Flv*TableConstants.CriticalChanceResisReduce.Value)))
            local c = TableConstants.CriticalChanceMax.Value
            local d = TableLevel[self._nLevel].Flv*TableConstants.CriticalChanceReduce.Value
            local criticalRate = 1000*((a*b*c)/(a*b+d))
            if criticalRate <= 0 then
                criticalRate = 0
            end
            local randNum = getRandomNumBetween(1,1000)
            if randNum <= criticalRate then -- 暴击成功
                isCritical = true
                local a = 1+TableConstants.CriticalDmageMin.Value
                local b = skill:getMaster():getAttriValueByType(kAttribute.kCritDmage)  --攻击方暴击伤害
                local c = (1-((self:getAttriValueByType(kAttribute.kResilience)*TableConstants.CriticalDmageResisMax.Value)/(self:getAttriValueByType(kAttribute.kResilience)+TableLevel[skill:getMaster()._nLevel].Flv*TableConstants.CriticalDmageResisReduce.Value)))
                local d = TableConstants.CriticalDmageMax.Value
                local e = TableLevel[self._nLevel].Flv*TableConstants.CriticalDmageReduce.Value
                criticalValue = a+((b*c*d)/(b*c+e))
            end
            -- [攻击方]考虑吸血率
            suckBloodRate = (skill:getMaster():getAttriValueByType(kAttribute.kLifeSteal)*TableConstants.LifeStealRateMax.Value)/(skill:getMaster():getAttriValueByType(kAttribute.kLifeSteal)+TableLevel[self._nLevel].Flv*TableConstants.LifeStealRateReduce.Value)
            if suckBloodRate <= 0 then
                suckBloodRate = 0
            end
            
        end
        
        if skill._pSkillInfo.ElementType then 
            -- 考虑属性积蓄值的累加
            if skill:getMaster()._kGameObjType == kType.kGameObj.kRole then 
                if skill:getMaster()._kRoleType == kType.kRole.kMonster or skill:getMaster()._kRoleType == kType.kRole.kPet or skill:getMaster()._kRoleType == kType.kRole.kOtherPet then    -- 攻击方为野怪或者宠物，则只考虑技能的积蓄值计算
                    if skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kFire then
                        local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]*(((skill:getMaster()._nFireAttackValue*TableConstants.SkillAttrMax.Value)/(skill:getMaster()._nFireAttackValue+TableConstants.SkillAttrReduce.Value))+1)*(((skill:getMaster()._nAbilityPowerValue*TableConstants.SkillAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.SkillAttrApReduce.Value))+1)
                        self._nCurFireSaving = self._nCurFireSaving + saving
                    elseif skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kIce then
                        local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]*(((skill:getMaster()._nIceAttackValue*TableConstants.SkillAttrMax.Value)/(skill:getMaster()._nIceAttackValue+TableConstants.SkillAttrReduce.Value))+1)*(((skill:getMaster()._nAbilityPowerValue*TableConstants.SkillAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.SkillAttrApReduce.Value))+1)
                        self._nCurIceSaving = self._nCurIceSaving + saving
                    elseif skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kThunder then
                        local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]*(((skill:getMaster()._nThunderAttackValue*TableConstants.SkillAttrMax.Value)/(skill:getMaster()._nThunderAttackValue+TableConstants.SkillAttrReduce.Value))+1)*(((skill:getMaster()._nAbilityPowerValue*TableConstants.SkillAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.SkillAttrApReduce.Value))+1)
                        self._nCurThunderSaving = self._nCurThunderSaving + saving
                    end
                    self:playHurtedEffect(skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex], intersection, isCritical, isBlock)
                elseif skill:getMaster()._kRoleType == kType.kRole.kPlayer or skill:getMaster()._kRoleType == kType.kRole.kOtherPlayer then  -- 攻击方为玩家或者宠物，则需要分为普通攻击和技能攻击的积蓄值分别计算
                    if skill == skill:getMaster()._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kGenAttack] then
                        -- 普通攻击（先计算出现属性火冰雷物理的概率，然后判断是否触发）
                        local fireSavingRate = 1000*((skill:getMaster()._nFireAttackValue*TableConstants.GenAttrChanceMax.Value)/(skill:getMaster()._nFireAttackValue+TableLevel[self._nLevel].Flv*TableConstants.GenAttrChanceReduce.Value))*( ((skill:getMaster()._nAbilityPowerValue*TableConstants.GenAttrChanceApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.GenAttrChanceApReduce.Value))+1 )
                        local iceSavingRate = 1000*((skill:getMaster()._nIceAttackValue*TableConstants.GenAttrChanceMax.Value)/(skill:getMaster()._nIceAttackValue+TableLevel[self._nLevel].Flv*TableConstants.GenAttrChanceReduce.Value))*( ((skill:getMaster()._nAbilityPowerValue*TableConstants.GenAttrChanceApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.GenAttrChanceApReduce.Value))+1 )
                        local thunderSavingRate = 1000*((skill:getMaster()._nThunderAttackValue*TableConstants.GenAttrChanceMax.Value)/(skill:getMaster()._nThunderAttackValue+TableLevel[self._nLevel].Flv*TableConstants.GenAttrChanceReduce.Value))*( ((skill:getMaster()._nAbilityPowerValue*TableConstants.GenAttrChanceApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.GenAttrChanceApReduce.Value))+1 )
                        local randNum = getRandomNumBetween(1,1000)
                        if randNum <= fireSavingRate then   -- 火属性爆发成功
                            local saving = TableConstants.GenAttrRate.Value*skill:getMaster()._nFireAttackValue*(((skill:getMaster()._nAbilityPowerValue*TableConstants.GenAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.GenAttrApReduce.Value))+1)
                            self._nCurFireSaving = self._nCurFireSaving + saving
                            self:playHurtedEffect(kType.kSkill.kElement.kFire, intersection, isCritical, isBlock)
                        elseif randNum <= fireSavingRate+iceSavingRate then  -- 冰属性爆发成功
                            local saving = TableConstants.GenAttrRate.Value*skill:getMaster()._nIceAttackValue*(((skill:getMaster()._nAbilityPowerValue*TableConstants.GenAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.GenAttrApReduce.Value))+1)
                            self._nCurIceSaving = self._nCurIceSaving + saving
                            self:playHurtedEffect(kType.kSkill.kElement.kIce, intersection, isCritical, isBlock)
                        elseif randNum <= fireSavingRate+iceSavingRate+thunderSavingRate then  -- 雷属性爆发成功
                            local saving = TableConstants.GenAttrRate.Value*skill:getMaster()._nThunderAttackValue*(((skill:getMaster()._nAbilityPowerValue*TableConstants.GenAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.GenAttrApReduce.Value))+1)
                            self._nCurThunderSaving = self._nCurThunderSaving + saving
                            self:playHurtedEffect(kType.kSkill.kElement.kThunder, intersection, isCritical, isBlock)
                        else -- 没有任何属性爆发，只是普通的物理攻击
                            self:playHurtedEffect(kType.kSkill.kElement.kPhysic, intersection, isCritical, isBlock)
                        end

                    else -- 其他所有类型技能
                        if skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kFire then
                            local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]*(((skill:getMaster()._nFireAttackValue*TableConstants.SkillAttrMax.Value)/(skill:getMaster()._nFireAttackValue+TableConstants.SkillAttrReduce.Value))+1)*(((skill:getMaster()._nAbilityPowerValue*TableConstants.SkillAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.SkillAttrApReduce.Value))+1)
                            self._nCurFireSaving = self._nCurFireSaving + saving
                        elseif skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kIce then
                            local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]*(((skill:getMaster()._nIceAttackValue*TableConstants.SkillAttrMax.Value)/(skill:getMaster()._nIceAttackValue+TableConstants.SkillAttrReduce.Value))+1)*(((skill:getMaster()._nAbilityPowerValue*TableConstants.SkillAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.SkillAttrApReduce.Value))+1)
                            self._nCurIceSaving = self._nCurIceSaving + saving
                        elseif skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kThunder then
                            local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]*(((skill:getMaster()._nThunderAttackValue*TableConstants.SkillAttrMax.Value)/(skill:getMaster()._nThunderAttackValue+TableConstants.SkillAttrReduce.Value))+1)*(((skill:getMaster()._nAbilityPowerValue*TableConstants.SkillAttrApMax.Value)/(skill:getMaster()._nAbilityPowerValue+TableConstants.SkillAttrApReduce.Value))+1)
                            self._nCurThunderSaving = self._nCurThunderSaving + saving
                        end
                        self:playHurtedEffect(skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex], intersection, isCritical, isBlock)
                    end
                end
            
            elseif skill:getMaster()._kGameObjType == kType.kGameObj.kEntity then 
                if skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kFire then
                    local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
                    self._nCurFireSaving = self._nCurFireSaving + saving
                elseif skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kIce then
                    local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
                    self._nCurIceSaving = self._nCurIceSaving + saving
                elseif skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex] == kType.kSkill.kElement.kThunder then
                    local saving = skill._pSkillInfo.ElementalValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
                    self._nCurThunderSaving = self._nCurThunderSaving + saving
                end
                self:playHurtedEffect(skill._pSkillInfo.ElementType[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex], intersection, isCritical, isBlock)
            end

        end
        
        -----------------------------------------------------计算伤害--------------------------------------------------------------
        local loseHpValue = 0
        if skill:getMaster()._kGameObjType == kType.kGameObj.kRole then 
            -- 本次技能伤害系数
            local skillHurtFactor = skill._pSkillInfo.HurtFactor[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
            -- 本次技能固定伤害
            local skillHurtValue = skill._pSkillInfo.HurtValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
            -- 攻击方攻击力
            local attackerAttackPower = skill:getMaster():getAttriValueByType(kAttribute.kAttack)
            -- 被攻击方防御力
            local defenderDefendPower = self:getAttriValueByType(kAttribute.kDefend)
            -- 攻击方穿透
            local attackerPenetration = skill:getMaster():getAttriValueByType(kAttribute.kPenetration)
            -- f(防守方等级)
            local defFlv = TableLevel[self._nLevel].Flv
            -- f(攻击方等级)
            local attackFlv = TableLevel[skill:getMaster()._nLevel].Flv
            -- [计算伤害]
            local a = (skillHurtFactor*attackerAttackPower + skillHurtValue)*criticalValue
            local b = defenderDefendPower*(1-((attackerPenetration*TableConstants.PenetrationMax.Value)/(attackerPenetration+defFlv*TableConstants.PenetrationReduce.Value)))
            local c = TableConstants.DefendRateMax.Value
            local d = attackFlv*TableConstants.DefendRateReduce.Value
            local e = blockValue 
            loseHpValue = a*(1-((b*c)/(b+d)))-e
        elseif skill:getMaster()._kGameObjType == kType.kGameObj.kEntity then 
            -- 本次技能固定伤害
            local skillHurtValue = skill._pSkillInfo.HurtValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
            -- [计算伤害]
            loseHpValue = skillHurtValue

        end

        if loseHpValue <= 0 then
            loseHpValue = 0
        end
        loseHpValue = loseHpValue * self._fCurHurtedRate + self._fSunderArmorLoseHpRate*self._nHpMax
        self:loseHp(loseHpValue, isCritical)
        ---------------------------------------------------------------------------------------------------------------------------
        
        -- 攻击方吸血量
        if skill:getMaster()._kGameObjType == kType.kGameObj.kRole then 
            local suckHpValue = loseHpValue * suckBloodRate
            skill:getMaster():addHp(suckHpValue)
        end
        
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

        if self._nCurHp == 0  then
            -- 切换到死亡状态
            self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDead, true, {true,skill})
            -- 如果技能释放者是玩家角色或者宠物，则激活其【每杀死一个敌方单位】被动技能
            if skill:getMaster()._kRoleType == kType.kRole.kPlayer or skill:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
                skill:getMaster():addPassiveByTypeID(kType.kController.kPassive.kBattleDoWhenAnyEnemyDeadPassive)
            end
            -- 如果当前是金钱副本，则播放金币掉落动画及音效
            self:playGoldDropEffect(2)  -- 大量金币
            return
        end
        -- 如果当前是金钱副本，则播放金币掉落动画及音效
        self:playGoldDropEffect(1)  -- 少量金币

        -- 考虑是否产生buff
        if skill:getMaster()._kGameObjType == kType.kGameObj.kRole then 
            local buffID = skill._pSkillInfo.BuffIDs[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
            self:addBuffByID(buffID)
        end 

        -- 如果当前不为冻结状态，则考虑应值的情况 
        if self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID ~= kType.kState.kBattleMonster.kFrozen then
            -- 未被攻击的累积时间需要清零
            self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._fNoHurtTimeCounter = 0
            if skill._pSkillInfo.PowerValue then
                self._nCurComboInterupt = self._nCurComboInterupt - skill._pSkillInfo.PowerValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
                -- 如果连击保户值已经为0，则强制倒地
                if self._nCurComboInterupt <= 0 then
                    self._nCurComboInterupt = self._pRoleInfo.ComboInterupt
                    if self:isUnusualState() == false then  -- 非异常状态时，可以切入应值
                        self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kBeaten, false, {skill, 5})
                    end
                    -- 屏幕添加卡顿，并添加破甲buff
                    self:getMapManager():screenKartun(TableConstants.KartunTimeWhenPowerValueIsZero.Value)
                    -- 添加破甲buff
                    self:addBuffByID(4)
                    return
                end
            end

            local attackerSkill = skill
            local beatenRole = self
            if attackerSkill._pSkillInfo.AttackLevel then
                local nAttackAndDefDiff = attackerSkill._pSkillInfo.AttackLevel[attackerSkill._nCurFrameRegionIndex][attackerSkill._nCurFrameEventIndex] - beatenRole:getCurDefenseLevel()
                if nAttackAndDefDiff >= #TableTempleteAttackLevelDiff then
                    nAttackAndDefDiff = #TableTempleteAttackLevelDiff
                end
                --print("野怪被打的等级差值："..nAttackAndDefDiff)
                if nAttackAndDefDiff > 0 then  -- 差值>0，切入应值状态
                    if self:isUnusualState() == false then  -- 非异常状态时，可以切入应值
                        self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kBeaten, false, {attackerSkill, nAttackAndDefDiff})
                    end
                    return
                end
            end
        end

    elseif skill._pSkillInfo.AttackMode == kType.kAttackMode.kRevert then       -- 恢复
        -----------------------------------------------------计算回血--------------------------------------------------------------
        -- 本次技能伤害系数
        local skillHurtFactor = skill._pSkillInfo.HurtFactor[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
        -- 本次技能固定伤害
        local skillHurtValue = skill._pSkillInfo.HurtValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
        -- 攻击方攻击力
        local attackerAttackPower = skill:getMaster():getAttriValueByType(kAttribute.kAttack)
        -- [计算回复血量]
        local addHpValue = skillHurtFactor*attackerAttackPower+skillHurtValue
        self:addHp(addHpValue)
        ---------------------------------------------------------------------------------------------------------------------------
        -- 考虑是否产生buff
        if skill:getMaster()._kGameObjType == kType.kGameObj.kRole then
            local buffID = skill._pSkillInfo.BuffIDs[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
            self:addBuffByID(buffID)  
        end 
        
    end

end

-- buff影响到的受击接口
function MonsterRole:beHurtedByBuff(buff)
    if self:getTalksManager():isCurTalksFinished() == false then        -- 正在显示剧情对话，则无视伤害
        return
    end
    -- 战斗结果已经得出，则不再有任何影响
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    if self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID == kType.kState.kBattleMonster.kDead or
       self._pRefRoleIgnoreHurt:getBeIgnoreHurtOrNot() == true then
        return
    end
    
    local loseHpValue = 0
    local addHpValue = 0
    if buff._kTypeID == kType.kController.kBuff.kBattleFireBuff then
        loseHpValue = self._nHpMax * buff._fHurtRate
    elseif buff._kTypeID == kType.kController.kBuff.kBattlePoisonBuff then
        loseHpValue = buff._fLoseHpOnMaxHpRate * self._nHpMax
        loseHpValue = loseHpValue + buff._fHurtValue
    elseif buff._kTypeID == kType.kController.kBuff.kBattleAddHpBuff then
        addHpValue = buff._fAddHpOnLostHpRate * (self._nHpMax - self._nCurHp)
        addHpValue = addHpValue + buff._fAddHpValue
    elseif buff._kTypeID == kType.kController.kBuff.kBattleFightBackFireBuff then
        self._nCurFireSaving = self._nCurFireSaving + buff._fFireSavingValue
    elseif buff._kTypeID == kType.kController.kBuff.kBattleFightBackIceBuff then
        self._nCurIceSaving = self._nCurIceSaving + buff._fIceSavingValue
    elseif buff._kTypeID == kType.kController.kBuff.kBattleFightBackThunderBuff then
        self._nCurThunderSaving = self._nCurThunderSaving + buff._fThunderSavingValue
    end
    loseHpValue = loseHpValue * self._fCurHurtedRate
    addHpValue = addHpValue * 1.0
    
    if loseHpValue ~= 0 then
        self:loseHp(loseHpValue, false)
        if self._nCurHp == 0  then
            self:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDead, true, {false})
            -- 如果当前是金钱副本，则播放金币掉落动画及音效
            self:playGoldDropEffect(2)  -- 大量金币
            return
        end
        -- 如果当前是金钱副本，则播放金币掉落动画及音效
        self:playGoldDropEffect(1)  -- 少量金币
    end
    
    if addHpValue ~= 0 then
        self:addHp(addHpValue)
    end
    
end

return MonsterRole
