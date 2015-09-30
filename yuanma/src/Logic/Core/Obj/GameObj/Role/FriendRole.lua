--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendRole.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/11
-- descrip:   好友角色
--===================================================
local FriendRole = class("FriendRole",function()
    return require("Role"):create()
end)

-- 构造函数
function FriendRole:ctor()
    ------------ 人物参数相关 ---------------------------------------
    self._strName = "FriendRole"                    -- 角色名字
    self._kRoleType = kType.kRole.kFriend           -- 角色对象类型
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
    ----------- 人物属性相关 ----------------------------------------
    self._nLevel = 0                                -- 角色等级
    self._pSkill = nil                              -- 角色技能
    self._nFireAttackValue = 0                      -- 角色火属性攻击值
    self._nIceAttackValue = 0                       -- 角色冰属性攻击值
    self._nThunderAttackValue = 0                   -- 角色雷属性攻击值
    self._nAbilityPowerValue = 0                    -- 角色属性强化值
    ----------- 人物特效相关 -------------------------------------------
    self._pFriendAppearEffectAni = nil              -- 人物出场特效Ani
    self._pCriticalHitEffectAni = nil               -- 角色暴击特效动画
    self._pBlockHitEffectAni = nil                  -- 角色格挡特效动画
    self._pMissHitEffectAni = nil                   -- 角色闪避特效动画                
    ----------- ref引用计数 --------------------------------------------
    self._pRefGhostOpacity = nil                    -- 角色虚影半透的引用计数，其他正常（可以应值等等）
    
end

-- 创建函数
function FriendRole:create(pRoleInfo)
    local role = FriendRole.new()
    role:dispose(pRoleInfo)
    return role
end

-- 处理函数
function FriendRole:dispose(pRoleInfo)    
    ------------------- 初始化 ----------------------
    -- 设置角色信息
    self:initInfo(pRoleInfo)
    
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
            self:onExitFriendRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function FriendRole:onExitFriendRole()
    -- 执行父类退出方法
    self:onExitRole()
    
end

-- 循环更新
function FriendRole:updateFriendRole(dt)
    self:updateRole(dt)
    self:refreshZorder()

end

-- 初始化信息
function FriendRole:initInfo(pRoleInfo)
    self._pRoleInfo = pRoleInfo
    
    -- 数据表中的参数项与从服务器获得的数据进行合并
    local dataFromTable = TablePlayerRoles[self._pRoleInfo.roleCareer]
    self._pRoleInfo.FireMax = dataFromTable.FireMax
    self._pRoleInfo.ColdMax = dataFromTable.ColdMax
    self._pRoleInfo.LigtningMax = dataFromTable.LigtningMax
    self._pRoleInfo.FireRecover = dataFromTable.FireRecover
    self._pRoleInfo.ColdRecover = dataFromTable.ColdRecover
    self._pRoleInfo.LightningRecover = dataFromTable.LightningRecover
    
    self._nLevel = self._pRoleInfo.level
    self._pTempleteInfo = TableTempleteCareers[self._pRoleInfo.roleCareer]
    self._nFireAttackValue = self:getAttriValueByType(kAttribute.kFireAttack)
    self._nIceAttackValue = self:getAttriValueByType(kAttribute.kColdAttack)
    self._nThunderAttackValue = self:getAttriValueByType(kAttribute.kLightningAttack)
    self._nAbilityPowerValue = self:getAttriValueByType(kAttribute.kAbilityPower)
    
end

-- 初始化动画
function FriendRole:initAni()
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
        print("FriendRole's equipment's body is null!!!")
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
    
end

-- 初始化特效
function FriendRole:initEffects()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then        
        self._pFriendAppearEffectAni = cc.CSLoader:createNode("FriendStart.csb")
        self._pFriendAppearEffectAni:setPosition(cc.p(0,self:getHeight()/2))
        self._pFriendAppearEffectAni:setVisible(false)
        self:addChild(self._pFriendAppearEffectAni)
        
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
        
    end

end

-- 移除特效动画
function FriendRole:removeAllEffects()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then  
        self._pFriendAppearEffectAni:removeFromParent(true)
        self._pCriticalHitEffectAni:removeFromParent(true)
        self._pBlockHitEffectAni:removeFromParent(true)
        self._pMissHitEffectAni:removeFromParent(true)
    end
end

-- 初始化引用计数
function FriendRole:initRefs()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then  
        -- 角色虚影半透的引用计数 
        self._pRefGhostOpacity = require("RoleGhostRef"):create(self)   
    end
end

-- 播放受击特效
function FriendRole:playHurtedEffect(type, intersection, isCritical, isBlock)

end

-- 初始化人物身上默认bottom和body矩形信息
function FriendRole:initRects()
    local tTempleteInfo = TableTempleteCareers[self._pRoleInfo.roleCareer]
    local rectBottom = tTempleteInfo.BottomRect
    local rectBody = tTempleteInfo.BodyRect
    self._recBottomOnObj = cc.rect(rectBottom[1], rectBottom[2], rectBottom[3], rectBottom[4])
    self._recBodyOnObj = cc.rect(rectBody[1], rectBody[2], rectBody[3], rectBody[4])
end

-- 刷新zorder和3d模型的positionZ
function FriendRole:refreshZorder()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        if self._bForceMinPositionZ == true then   -- 强制positionZ
            self:setPositionZ(self._nForceMinPositionZValue)
        else                                    -- 非强制positionZ
            self:setPositionZ(self:getPositionIndex().y*(self:getMapManager()._f3DZ))
        end
        self:setLocalZOrder(kZorder.kMinRole + self:getMapManager()._sMapRectPixelSize.height - self:getPositionY())
    end
end


-- 获取身高
function FriendRole:getHeight()
    local height = TableTempleteCareers[self._pRoleInfo.roleCareer].Height
    return height
end

-- 加血
function FriendRole:addHp(value)
    
end

-- 掉血
-- 参数1：掉血值
-- 参数2：是否暴击
function FriendRole:loseHp(value, isCritical)

end

-- 显示暴击特效
function FriendRole:showCriticalEffect(intersection)
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
function FriendRole:showBlockEffect(intersection)
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
function FriendRole:showMissEffect()    
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
function FriendRole:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        pStateMachine = require("BattleFriendRoleStateMachine"):create(self)
    end
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 创建人物角色控制机
function FriendRole:initControllerMachine()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then

    end
    
end

-- 设置3D模型的角度
function FriendRole:setAngle3D(angle)
    self._fAngle3D = (math.modf(angle+90))%360  -- 补一个起始差值
    local rotaion3D = self._pAni:getRotation3D()
    rotaion3D.y = self._fAngle3D
    self._pAni:setRotation3D(rotaion3D)
end

-- 获取3D模型的角度
function FriendRole:getAngle3D()
    local fAngle3D = (math.modf(self._fAngle3D-90))%360
    return math.abs(fAngle3D)
end

-- 播放出场动作
function FriendRole:playAppearAction()
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
function FriendRole:getAppearActionTime()
    local duration = (self._pTempleteInfo.AppearActFrameRegion[2] - self._pTempleteInfo.AppearActFrameRegion[1])/30
    local speed = self._pTempleteInfo.AppearActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放站立动作
function FriendRole:playStandAction()
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
function FriendRole:getStandActionTime()
    local duration = (self._pTempleteInfo.StandActFrameRegion[2] - self._pTempleteInfo.StandActFrameRegion[1])/30
    local speed = self._pTempleteInfo.StandActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放奔跑动作
function FriendRole:playRunAction()
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
function FriendRole:getRunActionTime()
    local duration = (self._pTempleteInfo.RunActFrameRegion[2] - self._pTempleteInfo.RunActFrameRegion[1])/30
    local speed = self._pTempleteInfo.RunActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放受击动作
function FriendRole:playBeatenAction()
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
function FriendRole:getBeatenActionTime()
    local duration = (self._pTempleteInfo.BeatenActFrameRegion[2] - self._pTempleteInfo.BeatenActFrameRegion[1])/30
    local speed = self._pTempleteInfo.BeatenActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放倒地动作
function FriendRole:playFallGroundAction()
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
function FriendRole:getFallGroundActionTime()
    local duration = (self._pTempleteInfo.FallGroundActFrameRegion[2] - self._pTempleteInfo.FallGroundActFrameRegion[1])/30
    local speed = self._pTempleteInfo.FallGroundActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放起身动作
function FriendRole:playUpGroundAction()
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
function FriendRole:getUpGroundActionTime()
    local duration = (self._pTempleteInfo.UpGroundActFrameRegion[2] - self._pTempleteInfo.UpGroundActFrameRegion[1])/30
    local speed = self._pTempleteInfo.UpGroundActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放眩晕动作
function FriendRole:playDizzyAction()
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
function FriendRole:getDizzyActionTime()
    local duration = (self._pTempleteInfo.DizzyActFrameRegion[2] - self._pTempleteInfo.DizzyActFrameRegion[1])/30
    local speed = self._pTempleteInfo.DizzyActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放死亡动作
function FriendRole:playDeadAction()
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
function FriendRole:getDeadActionTime()
    local duration = (self._pTempleteInfo.DeadActFrameRegion[2] - self._pTempleteInfo.DeadActFrameRegion[1])/30
    local speed = self._pTempleteInfo.DeadActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 播放攻击动作
function FriendRole:playAttackAction(index)
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
function FriendRole:getAttackActionTime(index)
    local duration = (self._pTempleteInfo.AttackActFrameRegions[index][2] - self._pTempleteInfo.AttackActFrameRegions[index][1])/30
    local speed = self._pTempleteInfo.AttackActFrameRegions[index][4]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

-- 是否为异常状态（如死亡、眩晕、冻结、出场、应值等）
function FriendRole:isUnusualState()
    local state = self:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole)._pCurState
    if state._kTypeID ~= kType.kState.kBattleFriendRole.kDead and
       state._kTypeID ~= kType.kState.kBattleFriendRole.kBeaten and
       state._kTypeID ~= kType.kState.kBattleFriendRole.kAppear and 
       state._kTypeID ~= kType.kState.kBattleFriendRole.kFrozen and 
       state._kTypeID ~= kType.kState.kBattleFriendRole.kDizzy then
        return false
    end
    return true
end

-- 获取战斗中的属性值
function FriendRole:getAttriValueByType(type)
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
function FriendRole:addAttriValueOffset(type,value)
    self._fAttriValueOffsets[type] = self._fAttriValueOffsets[type] + value
end

-- 获取战斗中当前的防御等级
function FriendRole:getCurDefenseLevel()
    return self._pCurDefLevel + self._nDefenseLevelOffset
end

-- 技能影响到的受击接口
function FriendRole:beHurtedBySkill(skill, intersection)

end

-- buff影响到的受击接口
function FriendRole:beHurtedByBuff(buff)

end

-- 显示出现特效
function FriendRole:showAppearEffect()
    local action = cc.CSLoader:createTimeline("FriendStart.csb")
    action:gotoFrameAndPlay(0, action:getDuration(), false)
    self._pFriendAppearEffectAni:stopAllActions()
    self._pFriendAppearEffectAni:setVisible(true)
    self._pFriendAppearEffectAni:runAction(action)
    local show = function()
        self._pAni:setVisible(true)
        self._pShadow:setVisible(true)
    end
    self._pFriendAppearEffectAni:runAction(cc.Sequence:create(cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()*0.6), cc.CallFunc:create(show), cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()*0.4), cc.Hide:create()))
    
end

-- 显示出现特效
function FriendRole:showDisAppearEffect()
    local action = cc.CSLoader:createTimeline("FriendStart.csb")
    action:gotoFrameAndPlay(0, action:getDuration(), false)
    self._pFriendAppearEffectAni:stopAllActions()
    self._pFriendAppearEffectAni:setVisible(true)
    self._pFriendAppearEffectAni:runAction(action)
    local show = function()
        self._pAni:setVisible(false)
        self._pShadow:setVisible(false)
    end
    self._pFriendAppearEffectAni:runAction(cc.Sequence:create(cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()*0.6), cc.CallFunc:create(show), cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()*0.4), cc.Hide:create()))
    return action:getDuration()*cc.Director:getInstance():getAnimationInterval()
end

-- 使用技能大招
function FriendRole:useSkill()
    -------------------------- 使用技能前的特效 -------------------------------------------------------------
    self:showAppearEffect()
end

-- 刷新头顶字
function FriendRole:refreshName()
    self._pName:setString("Lv."..self._pRoleInfo.level.." "..self._pRoleInfo.roleName)
end

return FriendRole
