--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OtherPlayerRole.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/25
-- descrip:   其他玩家角色
--===================================================
local OtherPlayerRole = class("OtherPlayerRole",function()
    return require("Role"):create()
end)

-- 构造函数
function OtherPlayerRole:ctor()
    ------------ 人物参数相关 ---------------------------------------
    self._strName = "OtherPlayerRole"                   -- 玩家角色名字
    self._kRoleType = kType.kRole.kOtherPlayer          -- 角色对象类型
    self._pRoleInfo = nil                               -- 角色信息
    self._pTempleteInfo = nil                           -- 模板信息
    self._fAngle3D = 0                                  -- 角色模型的角度
    self._pWeaponR = nil                                -- 右手武器
    self._pWeaponL = nil                                -- 左手武器
    self._pHalo = nil                                   -- 时装光环
    self._pBack = nil                                   -- 时装背装
    self._strBackTexturePvrName = ""                    -- 时装-背纹理名称
    self._strWeaponTexturePvrName = ""                  -- 武器纹理名称
    self._pName = ""                                    -- 头顶名签
    ----------- 人物属性相关 ----------------------------------------
    self._nLevel = 0                                    -- 角色等级
    self._nCurSpeed = 0                                 -- 角色移动速度
    
end

-- 创建函数
function OtherPlayerRole:create(pRoleInfo)
    local role = OtherPlayerRole.new()
    role:dispose(pRoleInfo)
    return role
end

-- 处理函数
function OtherPlayerRole:dispose(pRoleInfo)    
    ------------------- 初始化 ----------------------
    -- 设置角色信息
    self:initInfo(pRoleInfo)
    
    -- 初始化动画
    self:initAni()
    
    -- 初始化人物身上默认bottom和body矩形信息
    self:initRects()
    
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitOtherPlayerRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function OtherPlayerRole:onExitOtherPlayerRole()    
    -- 执行父类退出方法
    self:onExitRole()
    
end

-- 循环更新
function OtherPlayerRole:updatePlayerRole(dt)
    self:updateRole(dt)
    self:refreshZorder()  

end

-- 初始化信息
function OtherPlayerRole:initInfo(pRoleInfo)
    self._pRoleInfo = pRoleInfo
    self._nLevel = self._pRoleInfo.level
    self._pTempleteInfo = TableTempleteCareers[self._pRoleInfo.roleCareer]
    self._nCurSpeed = self:getAttriValueByType(kAttribute.kSpeed)

end

-- 初始化动画
function OtherPlayerRole:initAni()
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
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tBodyTempleteInfo.Texture)
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
            local nPart =self._pRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                tFashionBackTempleteInfo = self._pRoleInfo.equipemts[i].templeteInfo
                break     
            end
        end
    end
    if tFashionBackTempleteInfo then
        local fullAniName = tFashionBackTempleteInfo.Model1..".c3b"
        local fullTextureName = tFashionBackTempleteInfo.Texture..".pvr.ccz"
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionBackTempleteInfo.Texture)
        self._strBackTexturePvrName = tFashionBackTempleteInfo.Texture
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

-- 初始化人物身上默认bottom和body矩形信息
function OtherPlayerRole:initRects()
    local tTempleteInfo = TableTempleteCareers[self._pRoleInfo.roleCareer]
    local rectBottom = tTempleteInfo.BottomRect
    local rectBody = tTempleteInfo.BodyRect
    self._recBottomOnObj = cc.rect(rectBottom[1], rectBottom[2], rectBottom[3], rectBottom[4])
    self._recBodyOnObj = cc.rect(rectBody[1], rectBody[2], rectBody[3], rectBody[4])
end

-- 刷新zorder和3d模型的positionZ
function OtherPlayerRole:refreshZorder()
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
function OtherPlayerRole:getHeight()
    local height = TableTempleteCareers[self._pRoleInfo.roleCareer].Height
    return height
end

-- 创建人物角色状态机
function OtherPlayerRole:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        pStateMachine = require("WorldOtherPlayerRoleStateMachine"):create(self)
    end
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 设置3D模型的角度
function OtherPlayerRole:setAngle3D(angle)
    self._fAngle3D = (math.modf(angle+90))%360  -- 补一个起始差值
    local rotaion3D = self._pAni:getRotation3D()
    rotaion3D.y = self._fAngle3D
    self._pAni:setRotation3D(rotaion3D)
end

-- 获取3D模型的角度
function OtherPlayerRole:getAngle3D()
    local fAngle3D = (math.modf(self._fAngle3D-90))%360
    return math.abs(fAngle3D)
end

-- 播放站立动作
function OtherPlayerRole:playStandAction()
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
function OtherPlayerRole:getStandActionTime()
    local duration = (self._pTempleteInfo.StandActFrameRegion[2] - self._pTempleteInfo.StandActFrameRegion[1])/30
    local speed = self._pTempleteInfo.StandActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放奔跑动作
function OtherPlayerRole:playRunAction()
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
function OtherPlayerRole:getRunActionTime()
    local duration = (self._pTempleteInfo.RunActFrameRegion[2] - self._pTempleteInfo.RunActFrameRegion[1])/30
    local speed = self._pTempleteInfo.RunActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放休闲动作
function OtherPlayerRole:playCasualAction()
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
function OtherPlayerRole:getCasualActionTime()
    local duration = (self._pTempleteInfo.CasualActFrameRegion[2] - self._pTempleteInfo.CasualActFrameRegion[1])/30
    local speed = self._pTempleteInfo.CasualActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 获取战斗中的属性值
function OtherPlayerRole:getAttriValueByType(type)
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

--设置材质特效信息
function OtherPlayerRole:setMaterialInfo()
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
               setSprite3dMaterial(self._pFashionBack,ptempleteInfo.Material)

        elseif nPart == kEqpLocation.kFashionHalo then  --时装光环
        
        end
    end
end


-- 刷新头顶字
function OtherPlayerRole:refreshName()
    self._pName:setString("Lv."..self._pRoleInfo.level.." "..self._pRoleInfo.roleName)
end

return OtherPlayerRole
