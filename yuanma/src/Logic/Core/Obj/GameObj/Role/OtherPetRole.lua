--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OtherPetRole.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/25
-- descrip:   其他宠物角色
--===================================================
local OtherPetRole = class("OtherPetRole",function()
    return require("Role"):create()
end)

-- 构造函数
function OtherPetRole:ctor()
    ------------ 人物参数相关 ---------------------------------------
    self._strName = "OtherPetRole"                  -- 宠物角色名字
    self._kRoleType = kType.kRole.OtherPetRole      -- 宠物角色类型
    self._kPetType = kType.kPet.kNone               -- 宠物大类型，如：pet1,2,3
    self._pRoleInfo = nil                           -- 宠物角色信息
    self._pTempleteInfo = nil                       -- 模板信息
    self._fAngle3D = 0                              -- 宠物角色模型的角度
    self._pMaster = nil                             -- 宠物的主人
    self._pName = ""                                -- 头顶名签
    ----------- 人物属性相关 ----------------------------------------
    self._nLevel = 0                                -- 宠物角色等级
    self._kQuality = kType.kQuality.kNone           -- 宠物角色品质
    self._nCurSpeed = 0                             -- 宠物角色移动速度
    
end

-- 创建函数
function OtherPetRole:create(pRoleInfo,master)
    local role = OtherPetRole.new()
    role:dispose(pRoleInfo,master)
    return role
end

-- 处理函数
function OtherPetRole:dispose(pRoleInfo,master)    
    ------------------- 初始化 ----------------------
    -- 设置宠物角色信息
    self:initInfo(pRoleInfo,master)
    
    -- 初始化动画
    self:initAni()
    
    -- 初始化人物身上默认bottom和body矩形信息
    self:initRects()
    
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitOtherPetRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function OtherPetRole:onExitOtherPetRole()
    -- 执行父类退出方法
    self:onExitRole()
    
end

-- 循环更新
function OtherPetRole:updatePetRole(dt)
    self:updateRole(dt)
    self:refreshZorder()

end

-- 初始化信息
function OtherPetRole:initInfo(pRoleInfo, master)
    self._kQuality = pRoleInfo.step           -- 宠物品质
    self._kPetType = pRoleInfo.petId          -- 宠物类型
    self._nLevel = pRoleInfo.level            -- 宠物等级
    
    self._pRoleInfo = TablePets[pRoleInfo.petId]
    self._pRoleInfo.step = self._kQuality
    self._pRoleInfo.type = self._kPetType
    self._pRoleInfo.level = self._nLevel
    
    self._pTempleteInfo = TableTempletePets[self._pRoleInfo.TempleteID[self._kQuality]]
    self._nCurSpeed = self._pRoleInfo.Speed
    
    -- 关联宠物自己的主人
    self._pMaster = master
   
end

-- 初始化动画
function OtherPetRole:initAni()
    self._kAniType = self._pTempleteInfo.AniType
    self._strAniName = self._pTempleteInfo.Model

    local fullAniName = self._strAniName..".c3b"
    local fullTextureName = self._pTempleteInfo.Texture..".pvr.ccz"
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(self._pTempleteInfo.Texture)
    self._strBodyTexturePvrName = self._pTempleteInfo.Texture
    self._pAni = cc.Sprite3D:create(fullAniName)
    self._pAni:setTexture(fullTextureName)
    self:addChild(self._pAni)

    self._pAni:setScale(self._pTempleteInfo.ScaleInGame)
    
    -- 头顶字：XX的XX
    self._pName = cc.Label:createWithTTF(self._pMaster._pRoleInfo.roleName.."的"..self._pTempleteInfo.PetName, strCommonFontName, 15)
    self._pName:setPosition(cc.p(0,self:getHeight()+3))
    self:addChild(self._pName)
    if OptionManager:getInstance()._bPlayersNameShowOrNot == true then
        self._pName:setVisible(true)
    else
        self._pName:setVisible(false)
    end
    
    -- 叠色
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        if self:getMapManager()._kCurSkyType == kType.kSky.kNightSunShine or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudy or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightRainy or 
            self:getMapManager()._kCurSkyType == kType.kSky.kNightCloudyRainy then

            self._pAni:setColor(cPeopleNight)
        end
    end
    
end

-- 初始化人物身上默认bottom和body矩形信息
function OtherPetRole:initRects()
    local rectBottom = self._pTempleteInfo.BottomRect
    local rectBody = self._pTempleteInfo.BodyRect
    self._recBottomOnObj = cc.rect(rectBottom[1], rectBottom[2], rectBottom[3], rectBottom[4])
    self._recBodyOnObj = cc.rect(rectBody[1], rectBody[2], rectBody[3], rectBody[4])
end

-- 刷新zorder和3d模型的positionZ
function OtherPetRole:refreshZorder()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        if self._bForceMinPositionZ == true then   -- 强制positionZ
            self:setPositionZ(self._nForceMinPositionZValue)
        else                                    -- 非强制positionZ
            self:setPositionZ(self:getPositionIndex().y*(self:getMapManager()._f3DZ))
        end
        self:setLocalZOrder(kZorder.kMinRole + self:getMapManager()._sMapRectPixelSize.height - self:getPositionY())
    end
end

-- 获取身高
function OtherPetRole:getHeight()
    local height = TableTempletePets[self._pRoleInfo.TempleteID[self._kQuality]].Height
    return height
end

-- 创建人物角色状态机
function OtherPetRole:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        pStateMachine = require("WorldOtherPetRoleStateMachine"):create(self)
    end
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 设置3D模型的角度
function OtherPetRole:setAngle3D(angle)
    self._fAngle3D = (math.modf(angle+90))%360  -- 补一个起始差值
    local rotaion3D = self._pAni:getRotation3D()
    rotaion3D.y = self._fAngle3D
    self._pAni:setRotation3D(rotaion3D)
end

-- 获取3D模型的角度
function OtherPetRole:getAngle3D()
    local fAngle3D = (math.modf(self._fAngle3D-90))%360
    return math.abs(fAngle3D)
end

-- 播放站立动作
function OtherPetRole:playStandAction()
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
function OtherPetRole:getStandActionTime()
    local duration = (self._pTempleteInfo.StandActFrameRegion[2] - self._pTempleteInfo.StandActFrameRegion[1])/30
    local speed = self._pTempleteInfo.StandActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放奔跑动作
function OtherPetRole:playRunAction()
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

-- 播放休闲动作
function OtherPetRole:playCasualAction()
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
function OtherPetRole:getCasualActionTime()
    local duration = (self._pTempleteInfo.CasualActFrameRegion[2] - self._pTempleteInfo.CasualActFrameRegion[1])/30
    local speed = self._pTempleteInfo.CasualActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 获取奔跑动作的时间间隔（单位：秒）
function OtherPetRole:getRunActionTime()
    local duration = (self._pTempleteInfo.RunActFrameRegion[2] - self._pTempleteInfo.RunActFrameRegion[1])/30
    local speed = self._pTempleteInfo.RunActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 获取战斗中的属性值
function OtherPetRole:getAttriValueByType(type)
    local value = 0
    local offset = self._fAttriValueOffsets[type]

    if type == kAttribute.kHp then  -- 生命值
        value = self._pRoleInfo.Hp + self._pRoleInfo.HpGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kAttack then  -- 攻击力
        value = self._pRoleInfo.Attack + self._pRoleInfo.AttackGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kDefend then  -- 防御
        value = self._pRoleInfo.Defend + self._pRoleInfo.DefendGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kCritChance then  -- 暴击几率
        value = self._pRoleInfo.CriticalChance + self._pRoleInfo.CriticalChanceGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kCritDmage then -- 暴击伤害
        value = self._pRoleInfo.CriticalDmage + self._pRoleInfo.CriticalDmageGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kResilience then -- 韧性
        value = self._pRoleInfo.Resilience + self._pRoleInfo.ResilienceGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kResistance then -- 抗性
        value = self._pRoleInfo.Resistance + self._pRoleInfo.ResistanceGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kBlock then -- 格挡
        value = self._pRoleInfo.Block + self._pRoleInfo.BlockGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kPenetration then -- 穿透
        value = self._pRoleInfo.Penetration + self._pRoleInfo.PenetrationGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kDodgeChance then -- 闪避
        value = self._pRoleInfo.DodgeChance + self._pRoleInfo.DodgeChanceGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kAbilityPower then -- 属性强化
        value = self._pRoleInfo.AbilityPower + self._pRoleInfo.AbilityPowerGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kFireAttack then -- 火属性攻击
        value = self._pRoleInfo.FireAttack + self._pRoleInfo.FireAttackGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kColdAttack then -- 冰属性攻击
        value = self._pRoleInfo.ColdAttack + self._pRoleInfo.ColdAttackGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kLightningAttack then -- 雷属性攻击
        value = self._pRoleInfo.LightningAttack + self._pRoleInfo.LightningAttackGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kLifePerSecond then -- 再生
        value = self._pRoleInfo.LifeperSecond + self._pRoleInfo.LifeperSecondGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    elseif type == kAttribute.kLifeSteal then -- 吸血比率
        value = self._pRoleInfo.LifeSteal + self._pRoleInfo.LifeStealGrowth[self._kQuality] * TablePetsLevel[self._nLevel].PetGrowth
    end

    return value + offset
end

-- 刷新头顶字
function OtherPetRole:refreshName()
    self._pName:setString(self._pMaster._pRoleInfo.roleName.."的"..self._pTempleteInfo.PetName)
end

return OtherPetRole
