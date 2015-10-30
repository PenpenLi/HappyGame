--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PlayerRole.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   玩家角色
--===================================================
local PlayerRole = class("PlayerRole",function()
    return require("Role"):create()
end)

-- 构造函数
function PlayerRole:ctor()
    ------------ 人物参数相关 ---------------------------------------
    self._strName = "PlayerRole"                    -- 玩家角色名字
    self._kRoleType = kType.kRole.kPlayer           -- 角色对象类型
    self._strCharTag = ""                           -- 角色tag（主角：main PVP对手：pvp）
    self._pRoleInfo = nil                           -- 角色信息
    self._pTempleteInfo = nil                       -- 模板信息
    self._fAngle3D = 0                              -- 角色模型的角度
    self._pWeaponR = nil                            -- 右手武器
    self._pWeaponL = nil                            -- 左手武器
    self._pHalo = nil                               -- 时装光环
    self._pBack = nil                               -- 时装背装
    self._strBackTexturePvrName = ""                -- 时装-背纹理名称
    self._strWeaponTexturePvrName = ""              -- 武器纹理名称
    self._pName = ""                                -- 头顶名签
    ----------- 人物特效相关 -----------------------------------------
    self._pHurtedEffectAnis = {}                    -- 角色受击特效动画
    self._pCriticalHitEffectAni = nil               -- 角色暴击特效动画
    self._pBlockHitEffectAni = nil                  -- 角色格挡特效动画
    self._pMissHitEffectAni = nil                   -- 角色闪避特效动画                
    self._pDeadEffectAni = nil                      -- 角色死亡特效动画
    ----------- 人物属性相关 ----------------------------------------
    self._pBattleUIDelegate = nil                   -- battleUILayer 代理对象
    self._nLevel = 0                                -- 角色等级
    self._tSkills = {}                              -- 角色技能集合（主动）
    self._tPassiveSkillInfos = {}                   -- 角色技能信息集合（被动），根据键值存放（键：typeID）
    self._nFireAttackValue = 0                      -- 角色火属性攻击值
    self._nIceAttackValue = 0                       -- 角色冰属性攻击值
    self._nThunderAttackValue = 0                   -- 角色雷属性攻击值
    self._nAbilityPowerValue = 0                    -- 角色属性强化值
    self._nCurSpeed = 0                             -- 角色移动速度
    self._nHpMax = 0                                -- 角色最大Hp
    self._nCurHp = 0                                -- 角色当前Hp
    self._nAngerMax = 0                             -- 角色最大怒气值
    self._nCurAnger = 0                             -- 角色当前怒气
    self._pCurDefLevel = 0                          -- 角色当前的默认防御等级
    self._nCurComboInterupt = 0                     -- 角色当前连击保户值
    self._fCurHurtedRate = 1.0                      -- 角色当前受到的伤害比例（用于与整体伤害相乘）
    self._fDebuffTimeRate = 1.0                     -- 角色debuff持续时间比例（用于与所有debuff的持续时间相乘）
    ----------- 人物 Ref相关 ------------------------------------------
    self._refGenAttackButton = nil                  -- 角色普通攻击按钮是否可用的引用计数
    self._tRefSkillButtons = {}                     -- 角色技能攻击按钮是否可用的引用计数
    self._refStick = nil                            -- 角色摇杆是否可用的引用计数
    self._pRefRoleIgnoreHurt = nil                  -- 角色是否无视伤害的引用计数
    self._pRefNotLoseHp = nil                       -- 角色不掉血引用计数
    self._pRefGhostOpacity = nil                    -- 角色虚影半透的引用计数，其他正常（可以应值等等）
    ----------- 人物相关 ----------------------------------------------------
    self._pCurPetRole = nil                         -- 当前宠物
    
end

-- 创建函数
function PlayerRole:create(pRoleInfo,charTag)
    local role = PlayerRole.new()
    role:dispose(pRoleInfo,charTag)
    return role
end

-- 处理函数
function PlayerRole:dispose(pRoleInfo,charTag)    
    ------------------- 初始化 ----------------------
    -- 设置角色信息
    self:initInfo(pRoleInfo,charTag)
    
    -- 初始化动画
    self:initAni()
    
    -- 初始化特效
    self:initEffects()
    
    -- 初始化Refs
    self:initRefs()
    
    -- 初始化人物身上默认bottom和body矩形信息
    self:initRects()
    
    -- 创建控制机
    self:initControllerMachine()
    
    -- 创建状态机
    self:initStateMachine()
    
    -- 测试：添加波纹特效
    --self:addWaveEffect(kType.kBodyParts.kBody,1)
    --self:addWaveEffect(kType.kBodyParts.kBody,2)
    --self:addWaveEffect(kType.kBodyParts.kBack,3)
    --self:hideWaveEffect(kType.kBodyParts.kBody)
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPlayerRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function PlayerRole:onExitPlayerRole()
    -- 执行父类退出方法
    self:onExitRole()
    
end

-- 循环更新
function PlayerRole:updatePlayerRole(dt)
    self:updateRole(dt)
    self:refreshZorder()  

end

-- 初始化信息
function PlayerRole:initInfo(pRoleInfo, charTag)
    self._pRoleInfo = pRoleInfo
    -- 数据表中的参数项与从服务器获得的数据进行合并
    local dataFromTable = TablePlayerRoles[self._pRoleInfo.roleCareer]
    self._pRoleInfo.FireMax = dataFromTable.FireMax
    self._pRoleInfo.ColdMax = dataFromTable.ColdMax
    self._pRoleInfo.LigtningMax = dataFromTable.LigtningMax
    self._pRoleInfo.FireRecover = dataFromTable.FireRecover
    self._pRoleInfo.ColdRecover = dataFromTable.ColdRecover
    self._pRoleInfo.LightningRecover = dataFromTable.LightningRecover
    self._pRoleInfo.ComboInterupt = dataFromTable.ComboInterupt
    self._pRoleInfo.ComboInteruptRecover = dataFromTable.ComboInteruptRecover
    self._pRoleInfo.Patience = dataFromTable.Patience
    self._pRoleInfo.AngerMax = dataFromTable.AngerMax
    
    self._nLevel = self._pRoleInfo.level
    self._strCharTag = charTag
    self._pTempleteInfo = TableTempleteCareers[self._pRoleInfo.roleCareer]
    self._nCurSpeed = self:getAttriValueByType(kAttribute.kSpeed)
    self._nHpMax = self:getAttriValueByType(kAttribute.kHp)
    self._nCurHp = self:getAttriValueByType(kAttribute.kHp)
    self._nAngerMax = self._pRoleInfo.AngerMax
    self._nCurAnger = 0
    self._pCurDefLevel = TableTempleteCareers[self._pRoleInfo.roleCareer].DefenseLevel
    self._nCurComboInterupt = self._pRoleInfo.ComboInterupt
    self._nFireAttackValue = self:getAttriValueByType(kAttribute.kFireAttack)
    self._nIceAttackValue = self:getAttriValueByType(kAttribute.kColdAttack)
    self._nThunderAttackValue = self:getAttriValueByType(kAttribute.kLightningAttack)
    self._nAbilityPowerValue = self:getAttriValueByType(kAttribute.kAbilityPower)
    
    self._nCurFireSaving = 0
    self._nCurIceSaving = 0
    self._nCurThunderSaving = 0
    self._fSavingPatience = self._pRoleInfo.Patience
    
    local rate = 1 + ( (self:getAttriValueByType(kAttribute.kResistance)*TableConstants.AttrMaxResisMax.Value)/(self:getAttriValueByType(kAttribute.kResistance)+TableConstants.AttrMaxResisReduce.Value) )
    self._nFireSavingMax = self._pRoleInfo.FireMax*rate
    self._nIceSavingMax = self._pRoleInfo.ColdMax*rate
    self._nThunderSavingMax = self._pRoleInfo.LigtningMax*rate
    
    local rate = 1 + ( (self:getAttriValueByType(kAttribute.kResistance)*TableConstants.AttrRecResisMax.Value)/(self:getAttriValueByType(kAttribute.kResistance)+TableConstants.AttrRecResisReduce.Value) )
    self._nFireSavingRecover = self._pRoleInfo.FireRecover*rate
    self._nIceSavingRecover = self._pRoleInfo.ColdRecover*rate
    self._nThunderSavingRecover = self._pRoleInfo.LightningRecover*rate
    
    self._fDebuffTimeRate = ( (self:getAttriValueByType(kAttribute.kResistance)*TableConstants.DebuffShortenMax.Value)/(self:getAttriValueByType(kAttribute.kResistance)+TableConstants.DebuffShortenReduce.Value) ) 


end

-- 初始化动画
function PlayerRole:initAni()
    local templeteID = TableEquips[self._pRoleInfo.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[self._pRoleInfo.roleCareer]
    local tBodyTempleteInfo = TableTempleteEquips[templeteID]
    local templeteID = TableEquips[self._pRoleInfo.equipemts[kEqpLocation.kWeapon].id - 100000].TempleteID[self._pRoleInfo.roleCareer]
    local tWeaponTempleteInfo = TableTempleteEquips[templeteID]

    --先初始化人物信息
    for i=1,table.getn(self._pRoleInfo.equipemts) do --遍历装备集合
        GetCompleteItemInfo(self._pRoleInfo.equipemts[i],self._pRoleInfo.roleCareer)
    end

    -- 判断是否加载时装身
    if self._pRoleInfo.fashionOptions and self._pRoleInfo.fashionOptions[2] == true then -- 时装身        
        for i=1,table.getn(self._pRoleInfo.equipemts) do --遍历装备集合
            local nPart = self._pRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                tBodyTempleteInfo = self._pRoleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end

    if tBodyTempleteInfo ~= nil then
        self._kAniType = tBodyTempleteInfo.AniType
        self._strAniName = tBodyTempleteInfo.Model1

        -- 3D模型
        local fullAniName = self._strAniName..".c3b"
        local fullTextureName = tBodyTempleteInfo.Texture..".pvr.ccz"
        self._strBodyTexturePvrName = tBodyTempleteInfo.Texture
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tBodyTempleteInfo.Texture)
        self._pAni = cc.Sprite3D:create(fullAniName)
        self._pAni:setTexture(fullTextureName)
        self:addChild(self._pAni)
        -- 3D武器模型
        local pWeaponRC3bName = tWeaponTempleteInfo.Model1..".c3b"
        local pWeaponLC3bName = nil
        if tWeaponTempleteInfo.Model2 then
           pWeaponLC3bName = tWeaponTempleteInfo.Model2..".c3b"
        end
        local pWeaponTextureName = tWeaponTempleteInfo.Texture..".pvr.ccz"
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tWeaponTempleteInfo.Texture)
        self._strWeaponTexturePvrName = tWeaponTempleteInfo.Texture
        if pWeaponRC3bName then
            self._pWeaponR = cc.Sprite3D:create(pWeaponRC3bName)
            self._pWeaponR:setTexture(pWeaponTextureName)
            self._pWeaponR:setScale(tWeaponTempleteInfo.ModelScale1)
            local animation = cc.Animation3D:create(pWeaponRC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self._pWeaponR:runAction(act)
            self._pAni:getAttachNode("boneRightHandAttach"):addChild(self._pWeaponR)
        end
        if pWeaponLC3bName then
            self._pWeaponL = cc.Sprite3D:create(pWeaponLC3bName)
            self._pWeaponL:setTexture(pWeaponTextureName)
            self._pWeaponL:setScale(tWeaponTempleteInfo.ModelScale2)
            local animation = cc.Animation3D:create(pWeaponLC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self._pWeaponL:runAction(act)
            self._pAni:getAttachNode("boneLeftHandAttach"):addChild(self._pWeaponL)
        end
        
    else
        print("PlayerRole's equipment's body is null!!!")
    end
    
    -- 判断是否加载时装背
    local tFashionBackTempleteInfo = nil
    if self._pRoleInfo.fashionOptions and self._pRoleInfo.fashionOptions[1] == true then
        for i=1,table.getn(self._pRoleInfo.equipemts) do --遍历装备集合
            local nPart = self._pRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                tFashionBackTempleteInfo = self._pRoleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end
    if tFashionBackTempleteInfo then
        local fullAniName = tFashionBackTempleteInfo.Model1..".c3b"
        local fullTextureName = tFashionBackTempleteInfo.Texture..".pvr.ccz"
        self._strBackTexturePvrName = tFashionBackTempleteInfo.Texture
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionBackTempleteInfo.Texture)
        self._pBack = cc.Sprite3D:create(fullAniName)
        self._pBack:setTexture(fullTextureName)
        self._pBack:setScale(tFashionBackTempleteInfo.ModelScale1)
        local animation = cc.Animation3D:create(fullAniName)
        local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
        self._pBack:runAction(act)
        self._pAni:getAttachNode("boneBackAttach"):addChild(self._pBack)
    end

    -- 判断是否加载时装光环
    local tFashionHaloTempleteInfo = nil
    if self._pRoleInfo.fashionOptions and self._pRoleInfo.fashionOptions[3] == true then        
        for i=1,table.getn(self._pRoleInfo.equipemts) do --遍历装备集合
            local nPart = self._pRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionHalo then  -- 时装光环部位
                tFashionHaloTempleteInfo = self._pRoleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end
    if tFashionHaloTempleteInfo then
        local fullAniName = tFashionHaloTempleteInfo.Model1..".csb"
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionHaloTempleteInfo.Texture)
        self._pHalo = cc.CSLoader:createNode(fullAniName)
        self:addChild(self._pHalo,-1)
        local act = cc.CSLoader:createTimeline(fullAniName)
        act:gotoFrameAndPlay(0, act:getDuration(), true) 
        self._pHalo:stopAllActions()
        self._pHalo:runAction(act)
        self._pHalo:setScale(tFashionHaloTempleteInfo.ModelScale1)
    end

    self._pAni:setScale(TableTempleteCareers[self._pRoleInfo.roleCareer].ScaleInGame)

    -- 头顶字：Lv. X 姓名
    self._pName = cc.Label:createWithTTF("Lv."..self._pRoleInfo.level.." "..self._pRoleInfo.roleName, strCommonFontName, 18)
    self._pName:setTextColor(cFontWhite)
    self._pName:enableOutline(cFontOutline,2)
    self._pName:setPosition(cc.p(0,self:getHeight()+5))
    self:addChild(self._pName)
    if OptionManager:getInstance()._bPlayersNameShowOrNot == true then
        self._pName:setVisible(true)
    else
        self._pName:setVisible(false)
    end


    --设置材质特效信息
    self:setMaterialInfo()

    -- 叠色
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        if self:getMapManager()._kCurSkyType == kType.kSky.kNightSunShine or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudy or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightRainy or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudyRainy then
            
            self._pAni:setColor(cPeopleNight)
            if self._pWeaponR then
                self._pWeaponR:setColor(cPeopleNight)
            end
            if self._pWeaponL then
                self._pWeaponL:setColor(cPeopleNight)
            end
            if self._pBack then
                self._pBack:setColor(cPeopleNight)
            end
            if self._pHalo then
                self._pHalo:setColor(cPeopleNight)
            end
        end
    end

end

-- 初始化特效
function PlayerRole:initEffects()
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
        
        -- 死亡特效
        self._pDeadEffectAni = cc.CSLoader:createNode("DeadEffect.csb")
        self:getMapManager()._pTmxMap:addChild(self._pDeadEffectAni)
        self._pDeadEffectAni:setVisible(false)

    end

end

-- 移除特效动画
function PlayerRole:removeAllEffects()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then  
        self._pHurtedEffectAnis[kType.kSkill.kElement.kPhysic]:removeFromParent(true)
        self._pHurtedEffectAnis[kType.kSkill.kElement.kFire]:removeFromParent(true)
        self._pHurtedEffectAnis[kType.kSkill.kElement.kIce]:removeFromParent(true)
        self._pHurtedEffectAnis[kType.kSkill.kElement.kThunder]:removeFromParent(true)
        self._pCriticalHitEffectAni:removeFromParent(true)
        self._pBlockHitEffectAni:removeFromParent(true)
        self._pMissHitEffectAni:removeFromParent(true)
        self._pDeadEffectAni:removeFromParent(true)
    end
end

-- 初始化引用计数
function PlayerRole:initRefs()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        -- 创建普通攻击按钮的引用计数
        self._refGenAttackButton = require("RoleGenAttackButtonRef"):create(self)
        -- 创建技能攻击按钮的引用计数
        if self._strCharTag == "main" then
            for i=1,table.getn(self:getSkillsManager()._tMainRoleMountActvSkills) do
                self._tRefSkillButtons[i] = require("RoleSkillButtonRef"):create(i,self)
            end
        elseif self._strCharTag == "pvp" then
            for i=1,table.getn(self:getSkillsManager()._tPvpRoleMountActvSkills) do
                self._tRefSkillButtons[i] = require("RoleSkillButtonRef"):create(i,self)
            end
        end
        -- 创建摇杆的引用计数
        self._refStick = require("RoleStickRef"):create(self)
        -- 创建无视攻击状态引用计数
        self._pRefRoleIgnoreHurt = require("RoleIgnoreBeatRef"):create(self)
        -- 角色不掉血引用计数，其他正常（可以应值等等）
        self._pRefNotLoseHp = require("RoleNotLoseHpRef"):create(self)    
        -- 角色虚影半透的引用计数 
        self._pRefGhostOpacity = require("RoleGhostRef"):create(self)   
        
    end
end

-- 播放受击特效
function PlayerRole:playHurtedEffect(type, intersection, isCritical, isBlock)
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

-- 显示死亡特效
function PlayerRole:playDeadEffect()
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

-- 初始化人物身上默认bottom和body矩形信息
function PlayerRole:initRects()
    local tTempleteInfo = TableTempleteCareers[self._pRoleInfo.roleCareer]
    local rectBottom = tTempleteInfo.BottomRect
    local rectBody = tTempleteInfo.BodyRect
    self._recBottomOnObj = cc.rect(rectBottom[1], rectBottom[2], rectBottom[3], rectBottom[4])
    self._recBodyOnObj = cc.rect(rectBody[1], rectBody[2], rectBody[3], rectBody[4])
end

-- 刷新zorder和3d模型的positionZ
function PlayerRole:refreshZorder()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        if self._bForceMinPositionZ == true then   -- 强制positionZ
            self:setPositionZ(self._nForceMinPositionZValue)
        else                                    -- 非强制positionZ
            self:setPositionZ(self:getPositionIndex().y*(self:getMapManager()._f3DZ))
        end
        self:setLocalZOrder(kZorder.kMinRole + self:getMapManager()._sMapRectPixelSize.height - self:getPositionY())
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        -- 当前不为死亡状态时都会刷新zorder
        if self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kDead then
            if self._bForceMinPositionZ == true then   -- 强制positionZ
                self:setPositionZ(self._nForceMinPositionZValue)
            else                                    -- 非强制positionZ
                self:setPositionZ(self:getPositionIndex().y*(self:getMapManager()._f3DZ))
            end
            self:setLocalZOrder(kZorder.kMinRole + self:getMapManager()._sMapRectPixelSize.height - self:getPositionY())
        end
    end
end

-- 设置battleuilayer 代理
function PlayerRole:setBattleUILayerDelegate( delegate )
    self._pBattleUIDelegate = delegate

    if self._strCharTag == "main" then
        self._pBattleUIDelegate._pMainPlayerUINode:setMaxHp(self._nHpMax)
        self._pBattleUIDelegate._pMainPlayerUINode:setCurHp(self._nHpMax,true)
        self._pBattleUIDelegate._pAngerSkillUINode:setAngerMax(self._nAngerMax)
        self._pBattleUIDelegate._pAngerSkillUINode:setAngerCur(self._nCurAnger)
    elseif self._strCharTag == "pvp" then
        self._pBattleUIDelegate._pBossHpNode:setBossName(self._pRoleInfo.roleName)
        self._pBattleUIDelegate._pBossHpNode:setBossHpMax(self._nHpMax)
        self._pBattleUIDelegate._pBossHpNode:setBossHpCur(self._nHpMax)
        self._pBattleUIDelegate._pBossHpNode:setBossHpNum(1) --pvp人物一格血
    end
    
end

-- 刷新装备（表现上）
function PlayerRole:refreshEquipsWithRoleInfo(roleInfo)
    local templeteID = TableEquips[roleInfo.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[roleInfo.roleCareer]
    local tBodyTempleteInfo = TableTempleteEquips[templeteID]
    local templeteID = TableEquips[roleInfo.equipemts[kEqpLocation.kWeapon].id - 100000].TempleteID[roleInfo.roleCareer]
    local tWeaponTempleteInfo = TableTempleteEquips[templeteID]

    

  --先初始化人物信息
     for i=1,table.getn(roleInfo.equipemts) do --遍历装备集合
        GetCompleteItemInfo(roleInfo.equipemts[i],roleInfo.roleCareer)
     end


    -- 判断是否加载时装身
    if roleInfo.fashionOptions and roleInfo.fashionOptions[2] == true then -- 时装身        
        for i=1,table.getn(roleInfo.equipemts) do --遍历装备集合
            local nPart = roleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                 tBodyTempleteInfo = roleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end

    -- 先移除之前的对象
    if self._pAni then
        self:removeChild(self._pAni, true)
        self._pAni = nil
        self._pWeaponR = nil
        self._pWeaponL = nil
    end
    
    if tBodyTempleteInfo ~= nil then
        self._kAniType = tBodyTempleteInfo.AniType
        self._strAniName = tBodyTempleteInfo.Model1
        -- 3D模型
        local fullAniName = self._strAniName..".c3b"
        local fullTextureName = tBodyTempleteInfo.Texture..".pvr.ccz"
        self._strBodyTexturePvrName = tBodyTempleteInfo.Texture
        self._pAni = cc.Sprite3D:create(fullAniName)
        self._pAni:setTexture(fullTextureName)
        self:addChild(self._pAni)
        -- 3D武器模型
        local pWeaponRC3bName = tWeaponTempleteInfo.Model1..".c3b"
        local pWeaponLC3bName = nil
        if tWeaponTempleteInfo.Model2 then
            pWeaponLC3bName = tWeaponTempleteInfo.Model2..".c3b"
        end

        local pWeaponTextureName = tWeaponTempleteInfo.Texture..".pvr.ccz"
        self._strWeaponTexturePvrName = tWeaponTempleteInfo.Texture
        
        if pWeaponRC3bName then
            self._pWeaponR = cc.Sprite3D:create(pWeaponRC3bName)
            self._pWeaponR:setTexture(pWeaponTextureName)
            self._pWeaponR:setScale(tWeaponTempleteInfo.ModelScale1)
            local animation = cc.Animation3D:create(pWeaponRC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()/cc.Director:getInstance():getAnimationInterval()))
            self._pWeaponR:runAction(act)
            self._pAni:getAttachNode("boneRightHandAttach"):addChild(self._pWeaponR)
        end
        if pWeaponLC3bName then
            self._pWeaponL = cc.Sprite3D:create(pWeaponLC3bName)
            self._pWeaponL:setTexture(pWeaponTextureName)
            self._pWeaponL:setScale(tWeaponTempleteInfo.ModelScale2)
            local animation = cc.Animation3D:create(pWeaponLC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()/cc.Director:getInstance():getAnimationInterval()))
            self._pWeaponL:runAction(act)
            self._pAni:getAttachNode("boneLeftHandAttach"):addChild(self._pWeaponL)
        end

    end

    -- 判断是否加载时装背
    local tFashionBackTempleteInfo = nil    
    if roleInfo.fashionOptions and roleInfo.fashionOptions[1] == true then
        for i=1,table.getn(roleInfo.equipemts) do --遍历装备集合
            local nPart =roleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                tFashionBackTempleteInfo = roleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end
    
    -- 先移除之前的对象
    if self._pBack then
        self._pAni:getAttachNode("boneBackAttach"):removeChild(self._pBack, true)
        self._pBack = nil
    end
    if tFashionBackTempleteInfo then
        local fullAniName = tFashionBackTempleteInfo.Model1..".c3b"
        local fullTextureName = tFashionBackTempleteInfo.Texture..".pvr.ccz"
        self._strBackTexturePvrName = tFashionBackTempleteInfo.Texture
        self._pBack = cc.Sprite3D:create(fullAniName)
        self._pBack:setTexture(fullTextureName)
        self._pBack:setScale(tFashionBackTempleteInfo.ModelScale1)
        local animation = cc.Animation3D:create(fullAniName)
        local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()/cc.Director:getInstance():getAnimationInterval()))
        self._pBack:runAction(act)
        self._pAni:getAttachNode("boneBackAttach"):addChild(self._pBack)
    end

    -- 判断是否加载时装光环
    local tFashionHaloTempleteInfo = nil    
    if roleInfo.fashionOptions and roleInfo.fashionOptions[3] == true then        
        for i=1,table.getn(roleInfo.equipemts) do --遍历装备集合
            local nPart = roleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionHalo then  -- 时装光环部位
                 tFashionHaloTempleteInfo = roleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end
    
    -- 先移除之前的对象
    if self._pHalo then
        self:removeChild(self._pHalo, true)
        self._pHalo = nil
    end
    if tFashionHaloTempleteInfo then
        local fullAniName = tFashionHaloTempleteInfo.Model1..".csb"
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionHaloTempleteInfo.Texture)
        --local fullTextureName = tFashionHaloTempleteInfo.Texture..".pvr.ccz"
        self._pHalo = cc.CSLoader:createNode(fullAniName)
        self:addChild(self._pHalo,-1)
        local act = cc.CSLoader:createTimeline(fullAniName)
        act:gotoFrameAndPlay(0, act:getDuration(), true) 
        self._pHalo:stopAllActions()
        self._pHalo:runAction(act)
        self._pHalo:setScale(tFashionHaloTempleteInfo.ModelScale1)
    end
    
    self._pAni:setScale(TableTempleteCareers[roleInfo.roleCareer].ScaleInGame)
    
    -- 叠色
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        if self:getMapManager()._kCurSkyType == kType.kSky.kNightSunShine or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudy or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightRainy or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudyRainy then

            self._pAni:setColor(cPeopleNight)
            if self._pWeaponR then
                self._pWeaponR:setColor(cPeopleNight)
            end
            if self._pWeaponL then
                self._pWeaponL:setColor(cPeopleNight)
            end
            if self._pBack then
                self._pBack:setColor(cPeopleNight)
            end
            if self._pHalo then
                self._pHalo:setColor(cPeopleNight)
            end
        end
    end
    
    -- 刷新站立状态
    self:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand, true)
    
    -- 刷新相机
    self:refreshCamera()
    
end

-- 根据是否实时检测的标记来判断当前自身bottom是否与有效触发器发生碰撞
function PlayerRole:checkCollisionOnTriggerWithRuntime(bRuntime)
    if self._strCharTag == "main" then
        local nAreaIndex = self:getMapManager():getMapAreaIndexByPos(cc.p(self:getPositionX(), self:getPositionY())) -- 地图分块区域索引值
        local bottom = self:getBottomRectInMap()

        local rectIndexInArea = self:getTriggersManager()._pHelper:isCollidingBottomOnTriggerRectInArea(nAreaIndex, bottom)
        if rectIndexInArea ~= 0 then  -- 说明有碰撞
            local triggerID = self:getTriggersManager()._tTriggersRects[nAreaIndex][rectIndexInArea].ID
            local trigger = self:getTriggersManager()._tTriggersByID[triggerID]
            --  触发器未被开启（即未被使用过）并且runtime吻合，并且可见的情况下才可以被激活触发
            if ((trigger._bOpened == false) and (trigger._bRuntimeCheck == bRuntime) and (trigger._bIsVisibleOnDebug == true)) then
                trigger._bOpened = true
                trigger._bWorking = true       -- 生效，开始处理
                self:getTriggersManager():refreshDebugLayer()
            end
        end 
    end
    
    return
end

-- 判断是否已经离开入场的传送门
function PlayerRole:checkLeavingFromEnterDoor()
    if self._strCharTag == "main" then
        local doors = self:getEntitysManager()._tDoors[1]
        if table.getn(doors) == 0 then
            return
        end

        local bottom = self:getBottomRectInMap()
        local bHasLeave = true
        for kDoor, vDoor in pairs(doors) do
            local rects = vDoor._tBodys
            for kRect, vRect in pairs(rects) do
                if cc.rectIntersectsRect(bottom,vRect) == true then
                    bHasLeave = false
                    break
                end
            end
            if bHasLeave == false then
                break
            end
        end

        if bHasLeave == true then
            for kDoor, vDoor in pairs(doors) do
                vDoor:disappear()
            end
            -- 清空缓存
            self:getEntitysManager()._tDoors[1] = {}
        end
    end

    return
end

-- 获取身高
function PlayerRole:getHeight()
    local height = TableTempleteCareers[self._pRoleInfo.roleCareer].Height
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
function PlayerRole:setHp(value,maxValue) 
    value = math.ceil(value)

    self._nCurHp = value
    self._nHpMax = maxValue

    if self == self:getRolesManager()._pMainPlayerRole then
        if self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kDead then
            if self._pBattleUIDelegate then
                self._pBattleUIDelegate._pMainPlayerUINode:setMaxHp(self._nHpMax)
                self._pBattleUIDelegate._pMainPlayerUINode:setCurHp(self._nCurHp, true)           
            end

        end
    end

end

-- 加血
function PlayerRole:addHp(value)
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
    -- ui更新
    if self._strCharTag == "main" then
        if self._pBattleUIDelegate then
            self._pBattleUIDelegate._pMainPlayerUINode:setCurHp(self._nCurHp)
        end
    elseif self._strCharTag == "pvp" then
        if self._pBattleUIDelegate then
            self._pBattleUIDelegate._pBossHpNode:setBossHpCur(self._nCurHp)
        end
    end
    
end

-- 掉血
-- 参数1：掉血值
-- 参数2：是否暴击
function PlayerRole:loseHp(value, isCritical)
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
    if self._pWeaponL then
        local act = cc.Sequence:create(cc.TintTo:create(0.2, 255, 0, 0),cc.TintTo:create(0.2, self._pCurBuffColor["r"], self._pCurBuffColor["g"], self._pCurBuffColor["b"]))
        act:setTag(nRoleLoseHpActAction)
        self._pWeaponL:runAction(act)
    end
    if self._pWeaponR then
        local act = cc.Sequence:create(cc.TintTo:create(0.2, 255, 0, 0),cc.TintTo:create(0.2, self._pCurBuffColor["r"], self._pCurBuffColor["g"], self._pCurBuffColor["b"]))
        act:setTag(nRoleLoseHpActAction)
        self._pWeaponR:runAction(act)
    end
    if self._pBack then
        local act = cc.Sequence:create(cc.TintTo:create(0.2, 255, 0, 0),cc.TintTo:create(0.2, self._pCurBuffColor["r"], self._pCurBuffColor["g"], self._pCurBuffColor["b"]))
        act:setTag(nRoleLoseHpActAction)
        self._pBack:runAction(act)
    end
    
    self:showNum("-", value, isCritical)
    
    -- 如果处于战斗的强制性引导状态，当血量低于10%时，将不再掉血
    if NewbieManager:getInstance()._bSkipGuide == false and NewbieManager:getInstance()._bIsForceGuideForBattle == true then
        if self._strCharTag == "main" then
            if (self._nCurHp - value)/self._nHpMax <= 0.1 then
                return
            end
        end
    end
    
    self._nCurHp = self._nCurHp - value
    if self._nCurHp <= 0 then
        self._nCurHp = 0
    end
    -- ui更新
    if self._strCharTag == "main" then
        if self._pBattleUIDelegate then
            self._pBattleUIDelegate._pMainPlayerUINode:setCurHp(self._nCurHp)
        end
    elseif self._strCharTag == "pvp" then
        if self._pBattleUIDelegate then
            self._pBattleUIDelegate._pBossHpNode:setBossHpCur(self._nCurHp)
        end
    end
    
end

-- 增长怒气
function PlayerRole:addAnger(value)
    if BattleManager:getInstance()._bIsFirstBattleOfNewbie == true then
        if NewbieManager:getInstance()._nCurID ~= "Guide_1_4" then  -- 不为1_4时，怒气不长
            return
        end
    end
    if self._tSkills[kType.kSkill.kWayIndex.kPlayerRole.kAngerAttack] then
        value = math.ceil(value)
        self._nCurAnger = self._nCurAnger + value
        if self._nCurAnger >= self._nAngerMax then
            self._nCurAnger = self._nAngerMax            
        end
        -- ui更新
        if self._strCharTag == "main" then
            if self._pBattleUIDelegate then
                self._pBattleUIDelegate._pAngerSkillUINode:setAngerCur(self._nCurAnger)
            end
        end
    end    
end

-- 清空怒气
function PlayerRole:clearAnger()
    self._nCurAnger = 0
    -- ui更新
    if self._strCharTag == "main" then
        if self._pBattleUIDelegate then
            self._pBattleUIDelegate._pAngerSkillUINode:clearAnger()
        end
    end

end


-- 显示数字
function PlayerRole:showNum(flag, textNum, isCritical)
    local fntFileName = ""
    local numMaxScale = 1.6
    if flag == "+" then
        fntFileName = "fnt_add_blood.fnt"
    else
        if self._strCharTag == "main" then
            fntFileName = "fnt_self_blood.fnt"    -- 白色
        elseif self._strCharTag == "pvp" then
            fntFileName = "fnt_lose_blood.fnt"      -- 红字
        end
        if isCritical == true then  -- 是暴击
            numMaxScale = 2.2
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
function PlayerRole:showCriticalEffect(intersection)
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
function PlayerRole:showBlockEffect(intersection)
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
function PlayerRole:showMissEffect()    
    -- 刷新zorder
    self._pMissHitEffectAni:setPosition(self:getPositionX(), self:getPositionY() + self:getHeight()*0.8)
    self._pMissHitEffectAni:setLocalZOrder(self:getLocalZOrder()+1)

    self._pMissHitEffectAni:setVisible(true)
    self._pMissHitEffectAni:stopAllActions()
    local action = cc.CSLoader:createTimeline("MissHitEffect.csb")   
    action:gotoFrameAndPlay(0, action:getDuration(), false)   
    self._pMissHitEffectAni:runAction(action)

end

-- 创建人物角色状态机
function PlayerRole:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        pStateMachine = require("WorldPlayerRoleStateMachine"):create(self)
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        pStateMachine = require("BattlePlayerRoleStateMachine"):create(self)
    end
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 创建人物角色控制机
function PlayerRole:initControllerMachine()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        self._pControllerMachineDelegate = require("ControllerMachineDelegate"):create()
        local pBuffControllerMachine = require("BattleBuffControllerMachine"):create(self)
        local pPassiveControllerMachine = require("BattlePassiveControllerMachine"):create(self)
        self._pControllerMachineDelegate:addControllerMachine(pBuffControllerMachine)
        self._pControllerMachineDelegate:addControllerMachine(pPassiveControllerMachine)
    end
    
end

-- 设置3D模型的角度
function PlayerRole:setAngle3D(angle)
    self._fAngle3D = (math.modf(angle+90))%360  -- 补一个起始差值
    local rotaion3D = self._pAni:getRotation3D()
    rotaion3D.y = self._fAngle3D
    self._pAni:setRotation3D(rotaion3D)
end

-- 获取3D模型的角度
function PlayerRole:getAngle3D()
    local fAngle3D = (math.modf(self._fAngle3D-90))%360
    return math.abs(fAngle3D)
end

-- 设置当前移动速度比例（有叠加效果）
-- 参数：0到1 表示  0%到100%
function PlayerRole:setCurSpeedPercent(percent)
    self._nCurSpeed = self._nCurSpeed * percent
end

-- 复位角色速度
function PlayerRole:resetSpeed()
    self._nCurSpeed = self._pRoleInfo.roleAttrInfo.speed
end

-- 设置当前可能受到的所有伤害的比例（有叠加效果）
-- 参数：0到1 表示  0%到100%
function PlayerRole:setCurHurtedPercent(percent)
    self._fCurHurtedRate = self._fCurHurtedRate * percent
end

-- 复位角色伤害比例
function PlayerRole:resetHurtedRate()
    self._fCurHurtedRate = 1.0
end

-- 播放出场动作
function PlayerRole:playAppearAction()
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
function PlayerRole:getAppearActionTime()
    local duration = (self._pTempleteInfo.AppearActFrameRegion[2] - self._pTempleteInfo.AppearActFrameRegion[1])/30
    local speed = self._pTempleteInfo.AppearActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放站立动作
function PlayerRole:playStandAction()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        -- 家园里的站立动作
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
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        -- 战斗里的站立动作
        if self._pTempleteInfo.ReadyFightActFrameRegion ~= nil then
            local fullAniName = self._strAniName..".c3b"
            local animation = cc.Animation3D:create(fullAniName)
            local fStartFrame = self._pTempleteInfo.ReadyFightActFrameRegion[1]
            local fEndFrame = self._pTempleteInfo.ReadyFightActFrameRegion[2]
            local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
            temp:setSpeed(self._pTempleteInfo.ReadyFightActFrameRegion[3])
            local stand = cc.RepeatForever:create(temp)
            self._pAni:stopActionByTag(nRoleActAction)
            stand:setTag(nRoleActAction)
            self._pAni:runAction(stand)
        end
    end

end

-- 获取站立动作的时间间隔（单位：秒）
function PlayerRole:getStandActionTime()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        local duration = (self._pTempleteInfo.StandActFrameRegion[2] - self._pTempleteInfo.StandActFrameRegion[1])/30
        local speed = self._pTempleteInfo.StandActFrameRegion[3]
        --local time = duration + (1.0 - speed)*duration
        local time = duration * (1/speed)
        return time
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        local duration = (self._pTempleteInfo.ReadyFightActFrameRegion[2] - self._pTempleteInfo.ReadyFightActFrameRegion[1])/30
        local speed = self._pTempleteInfo.ReadyFightActFrameRegion[3]
        --local time = duration + (1.0 - speed)*duration
        local time = duration * (1/speed)
        return time
    end
end

-- 播放奔跑动作
function PlayerRole:playRunAction()
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
function PlayerRole:getRunActionTime()
    local duration = (self._pTempleteInfo.RunActFrameRegion[2] - self._pTempleteInfo.RunActFrameRegion[1])/30
    local speed = self._pTempleteInfo.RunActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放受击动作
function PlayerRole:playBeatenAction()
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
function PlayerRole:getBeatenActionTime()
    local duration = (self._pTempleteInfo.BeatenActFrameRegion[2] - self._pTempleteInfo.BeatenActFrameRegion[1])/30
    local speed = self._pTempleteInfo.BeatenActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放倒地动作
function PlayerRole:playFallGroundAction()
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
function PlayerRole:getFallGroundActionTime()
    local duration = (self._pTempleteInfo.FallGroundActFrameRegion[2] - self._pTempleteInfo.FallGroundActFrameRegion[1])/30
    local speed = self._pTempleteInfo.FallGroundActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放起身动作
function PlayerRole:playUpGroundAction()
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
function PlayerRole:getUpGroundActionTime()
    local duration = (self._pTempleteInfo.UpGroundActFrameRegion[2] - self._pTempleteInfo.UpGroundActFrameRegion[1])/30
    local speed = self._pTempleteInfo.UpGroundActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放眩晕动作
function PlayerRole:playDizzyAction()
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
function PlayerRole:getDizzyActionTime()
    local duration = (self._pTempleteInfo.DizzyActFrameRegion[2] - self._pTempleteInfo.DizzyActFrameRegion[1])/30
    local speed = self._pTempleteInfo.DizzyActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放死亡动作
function PlayerRole:playDeadAction()
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
function PlayerRole:getDeadActionTime()
    local duration = (self._pTempleteInfo.DeadActFrameRegion[2] - self._pTempleteInfo.DeadActFrameRegion[1])/30
    local speed = self._pTempleteInfo.DeadActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放攻击动作
function PlayerRole:playAttackAction(index)
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
function PlayerRole:getAttackActionTime(index)
    local duration = (self._pTempleteInfo.AttackActFrameRegions[index][2] - self._pTempleteInfo.AttackActFrameRegions[index][1])/30
    local speed = self._pTempleteInfo.AttackActFrameRegions[index][4]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放休闲动作
function PlayerRole:playCasualAction()
    -- 休闲动作
    if self._pTempleteInfo.CasualActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._pTempleteInfo.CasualActFrameRegion[1]
        local fEndFrame = self._pTempleteInfo.CasualActFrameRegion[2]
        local casual = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        casual:setSpeed(self._pTempleteInfo.CasualActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        casual:setTag(nRoleActAction)
        self._pAni:runAction(casual)        
    end
    
end

-- 获取休闲动作的时间间隔（单位：秒）
function PlayerRole:getCasualActionTime()
    local duration = (self._pTempleteInfo.CasualActFrameRegion[2] - self._pTempleteInfo.CasualActFrameRegion[1])/30
    local speed = self._pTempleteInfo.CasualActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 是否为异常状态（如死亡、眩晕、冻结、出场、应值等）
function PlayerRole:isUnusualState()
    local state = self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState
    if state._kTypeID ~= kType.kState.kBattlePlayerRole.kDead and
       state._kTypeID ~= kType.kState.kBattlePlayerRole.kBeaten and
       state._kTypeID ~= kType.kState.kBattlePlayerRole.kAppear and 
       state._kTypeID ~= kType.kState.kBattlePlayerRole.kFrozen and 
       state._kTypeID ~= kType.kState.kBattlePlayerRole.kDizzy and 
       self._nCurHp > 0 then
        return false
    end
    return true
end

-- 获取战斗中的属性值
function PlayerRole:getAttriValueByType(type)
    local value = 0
    local offset = self._fAttriValueOffsets[type]
    
    if type == kAttribute.kHp then  -- 生命值
        value = self._pRoleInfo.roleAttrInfo.hp
    elseif type == kAttribute.kAttack then  -- 攻击力
        value = self._pRoleInfo.roleAttrInfo.attack
    elseif type == kAttribute.kDefend then  -- 防御
        value = self._pRoleInfo.roleAttrInfo.defend
    elseif type == kAttribute.kCritChance then  -- 暴击几率
        value = self._pRoleInfo.roleAttrInfo.critRate
    elseif type == kAttribute.kCritDmage then -- 暴击伤害
        value = self._pRoleInfo.roleAttrInfo.critDmage
    elseif type == kAttribute.kResilience then -- 韧性
        value = self._pRoleInfo.roleAttrInfo.resilience
    elseif type == kAttribute.kResistance then -- 抗性
        value = self._pRoleInfo.roleAttrInfo.resistance
    elseif type == kAttribute.kBlock then -- 格挡
        value = self._pRoleInfo.roleAttrInfo.block
    elseif type == kAttribute.kPenetration then -- 穿透
        value = self._pRoleInfo.roleAttrInfo.penetration
    elseif type == kAttribute.kDodgeChance then -- 闪避
        value = self._pRoleInfo.roleAttrInfo.dodgeRate
    elseif type == kAttribute.kAbilityPower then -- 属性强化
        value = self._pRoleInfo.roleAttrInfo.attrEnhanced
    elseif type == kAttribute.kFireAttack then -- 火属性攻击
        value = self._pRoleInfo.roleAttrInfo.fireAttack
    elseif type == kAttribute.kColdAttack then -- 冰属性攻击
        value = self._pRoleInfo.roleAttrInfo.coldAttack
    elseif type == kAttribute.kLightningAttack then -- 雷属性攻击
        value = self._pRoleInfo.roleAttrInfo.lightningAttack
    elseif type == kAttribute.kLifePerSecond then -- 再生
        value = self._pRoleInfo.roleAttrInfo.lifePerSecond
    elseif type == kAttribute.kLifeSteal then -- 吸血比率
        value = self._pRoleInfo.roleAttrInfo.lifeSteal
    elseif type == kAttribute.kSpeed then -- 行走速度
        value = self._pRoleInfo.roleAttrInfo.speed
    elseif type == kAttribute.kFuryRegeneration then -- 怒气积攒速率
        value = self._pRoleInfo.roleAttrInfo.furyRegeneration
    end
    
    return value + offset
end

-- 设置战斗中的属性值的偏移变化值
function PlayerRole:addAttriValueOffset(type,value)
    self._fAttriValueOffsets[type] = self._fAttriValueOffsets[type] + value
end

-- 获取战斗中当前的防御等级
function PlayerRole:getCurDefenseLevel()
    return self._pCurDefLevel + self._nDefenseLevelOffset
end

-- 设置战斗中的需要添加的防御等级值变化偏移值
function PlayerRole:addDefenseLevelOffset(value)
    self._nDefenseLevelOffset = self._nDefenseLevelOffset + value
    if self._nDefenseLevelOffset <= 0 then
        self._nDefenseLevelOffset = 0
    end
end

-- 刷新头顶字
function PlayerRole:refreshName()
    self._pName:setString("Lv."..self._pRoleInfo.level.." "..self._pRoleInfo.roleName)
    if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle and self._strCharTag == "main" then
        cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pMainPlayerUINode:setLevelAndName(self._pRoleInfo.level, self._pRoleInfo.roleName)
    end
end

-- 激发passive时根据passiveTypeID添加相应passive
function PlayerRole:addPassiveByTypeID(typeID)
    if typeID > kType.kController.kPassive.kNone then
        -- 产生相应passive
        if self._tPassiveSkillInfos[typeID] ~= nil then   -- 需要使用的被动技能在人物自身的被动技能信息集合中恰好存在，则可以激活
            local className = ""
            if typeID == kType.kController.kPassive.kBattleDoWhenHpBelowPassive then
                className = "BattleDoWhenHpBelowPassiveController"
            elseif typeID == kType.kController.kPassive.kBattleDoWhenPetDeadPassive then
                className = "BattleDoWhenPetDeadPassiveController"
            elseif typeID == kType.kController.kPassive.kBattleAddHpWhenDoPassive then
                className = "BattleAddHpWhenDoPassiveController"
            elseif typeID == kType.kController.kPassive.kBattleDoWhenAngerIsReadyPassive then
                className = "BattleDoWhenAngerIsReadyPassiveController"
            elseif typeID == kType.kController.kPassive.kBattleDoWhenAnyEnemyDeadPassive then
                className = "BattleDoWhenAnyEnemyDeadPassiveController"
            elseif typeID == kType.kController.kPassive.kBattleDoWhenGetDebuffPassive  then
                className = "BattleDoWhenGetDebuffPassiveController"
            elseif typeID == kType.kController.kPassive.kBattleDoWhenBeSafePassive  then
                className = "BattleDoWhenBeSafePassiveController"
            end
            local passive = require(className):create(self, self._tPassiveSkillInfos[typeID])
            self:getPassiveControllerMachine():addController(passive)
            return passive
        end
    end
    return nil
end

-- 技能影响到的受击接口
function PlayerRole:beHurtedBySkill(skill, intersection)
    if self:getTalksManager():isCurTalksFinished() == false then        -- 正在显示剧情对话，则无视伤害
        return
    end
    -- 战斗结果已经得出，则不再有任何影响
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    
    if skill._pSkillInfo.AttackMode == kType.kAttackMode.kDamage then  -- 伤害

        if self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID == kType.kState.kBattlePlayerRole.kDead or
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
                elseif skill:getMaster()._kRoleType == kType.kRole.kPlayer or skill:getMaster()._kRoleType == kType.kRole.kOtherPlayer then  -- 攻击方为玩家，则需要分为普通攻击和技能攻击的积蓄值分别计算
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
        
        -- 被攻击者增加怒气
        local angerValue = 0
        angerValue = TableConstants.BeatenAngerSpeed.Value * self:getAttriValueByType(kAttribute.kFuryRegeneration)
        self:addAnger(angerValue)
        
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
        
        -- 未被攻击持续时间清0（适用于被动技能【未被攻击x秒钟时passive】）
        self:getPassiveControllerMachine()._fCurSafeTimeCount = 0
        
        if skill:getMaster() == self:getRolesManager()._pMainPlayerRole then
            self:getBattleManager():getBattleUILayer():showHitAni() -- 显示连击
        end
        
        -- 技能的主人大类型是角色，则需要考虑buff反击（反噬）
        if skill._pMaster._kGameObjType == kType.kGameObj.kRole then
            -- 收集目前的反击buff（反击-冰）
            local buffs = self:getBuffControllerMachine():collectBuffsByType(kType.kController.kBuff.kBattleFightBackIceBuff)
            for kBuff,vBuff in pairs(buffs) do
                skill._pMaster:beHurtedByBuff(vBuff)   -- 反击-冰  伤害
            end
            -- 收集目前的反击buff（反击-雷）
            local buffs = self:getBuffControllerMachine():collectBuffsByType(kType.kController.kBuff.kBattleFightBackThunderBuff)
            for kBuff,vBuff in pairs(buffs) do
                skill._pMaster:beHurtedByBuff(vBuff)   -- 反击-雷  伤害
            end
        end

        if self._nCurHp == 0  then
            self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kDead, true, {true, skill})
            -- 如果技能释放者是玩家角色或者宠物，则激活其【每杀死一个敌方单位】被动技能
            if skill:getMaster()._kRoleType == kType.kRole.kPlayer or skill:getMaster()._kRoleType == kType.kRole.kOtherPlayer then
                skill:getMaster():addPassiveByTypeID(kType.kController.kPassive.kBattleDoWhenAnyEnemyDeadPassive)
            end
            return
        end
        
        -- 考虑是否产生buff
        if skill:getMaster()._kGameObjType == kType.kGameObj.kRole then
            local buffID = skill._pSkillInfo.BuffIDs[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
            self:addBuffByID(buffID)
        end
    
        -- 如果当前不为冻结状态，则考虑应值的情况 
        if self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kFrozen then
            -- 未被攻击的累积时间需要清零
            self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._fNoHurtTimeCounter = 0
            if skill._pSkillInfo.PowerValue then
                self._nCurComboInterupt = self._nCurComboInterupt - skill._pSkillInfo.PowerValue[skill._nCurFrameRegionIndex][skill._nCurFrameEventIndex]
                -- 如果连击保户值已经为0，则强制倒地
                if self._nCurComboInterupt <= 0 then
                    self._nCurComboInterupt = self._pRoleInfo.ComboInterupt
                    if self:isUnusualState() == false then  -- 非异常状态时，可以切入应值
                        self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kBeaten, false, {skill, 5})
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
                --print("角色被打的等级差值："..nAttackAndDefDiff)
                if nAttackAndDefDiff > 0 then  -- 差值>0，切入应值状态
                    if self:isUnusualState() == false then  -- 非异常状态时，可以切入应值
                        self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kBeaten, false, {attackerSkill, nAttackAndDefDiff})
                    end
                    return
                end
            end
            
        end

    elseif skill._pSkillInfo.AttackMode == kType.kAttackMode.kRevert then  -- 恢复
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
function PlayerRole:beHurtedByBuff(buff)
    if self:getTalksManager():isCurTalksFinished() == false then        -- 正在显示剧情对话，则无视伤害
        return
    end
    -- 战斗结果已经得出，则不再有任何影响
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    
    if self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID == kType.kState.kBattlePlayerRole.kDead or
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
        
        -- 被攻击者被伤害型buff所伤，增加怒气
        local angerValue = 0
        angerValue = TableConstants.BuffAngerSpeed.Value * self:getAttriValueByType(kAttribute.kFuryRegeneration)
        self:addAnger(angerValue)
        
        if self._nCurHp == 0  then
            self:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kDead, true, {false})
            return
        end
    end

    if addHpValue ~= 0 then
        self:addHp(addHpValue)
    end

end

--设置材质特效信息
function PlayerRole:setMaterialInfo()
    for k, v in pairs(self._pRoleInfo.equipemts) do
        local pEquInfo = GetCompleteItemInfo(v,self._pRoleInfo.roleCareer)
        local nPart = pEquInfo.dataInfo.Part -- 部位
        local ptempleteInfo  = pEquInfo.templeteInfo
        if nPart == kEqpLocation.kBody then -- 身
            setSprite3dMaterial(self._pAni,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kWeapon then  -- 武器
            setSprite3dMaterial(self._pWeaponR,ptempleteInfo.Material)
            setSprite3dMaterial(self._pWeaponL,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kFashionBody then --时装身可能会影响人物模型
            setSprite3dMaterial(self._pAni,ptempleteInfo.Material)
        elseif nPart == kEqpLocation._pBack then  --时装背（翅膀）
            setSprite3dMaterial(self._pBack,ptempleteInfo.Material)

        elseif nPart == kEqpLocation.kFashionHalo then  --时装光环

        end
    end
end

return PlayerRole
