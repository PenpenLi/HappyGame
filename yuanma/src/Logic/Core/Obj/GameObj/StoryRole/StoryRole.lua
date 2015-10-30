--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryRole.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   角色基类
--===================================================
local StoryRole = class("StoryRole",function()
    return require("GameObj"):create()
end)

-- 构造函数
function StoryRole:ctor()
    self._nID = 0                                    -- 角色ID（服务器只有主角有）
    self._strName = "StoryRole"                      -- 角色名字
    self._kStoryRoleType = kType.kRole.kNone         -- 角色对象类型
    self._pInstenceId = nil                          -- 实例id(每个对象都是唯一的)


    self._pStoryRoleInfo =  nil                      -- 怪物角色表信息初始化用
    self._kDirection = kDirection.kDown              -- 角色方向    
    self._pDeadEffectAni = nil                       -- 角色死亡特效动画
    -------------玩家特殊处理的------------------------
    self._pRoleInfo = nil                            -- 玩家自己(特殊处理)

    --------------NPC怪物的----------------------------
    self._tTempleteInfo = nil                        -- 模板信息(npc怪物用)

  
 
end

-- 创建函数
function StoryRole:create(args,pRoleInfo)
    local StoryRole = StoryRole.new()
    StoryRole:dispose(args,pRoleInfo)
    return StoryRole
end

-- 处理函数{}
function StoryRole:dispose(args,pRoleInfo)

     -- 动作依托的节点
    self._pSkillActionNode = cc.Node:create()
    self:addChild(self._pSkillActionNode)

    -- 初始化动画
    self:initAni(args,pRoleInfo)
    -- 初始化特效
    self:initEffects()
    -- 创建状态机
    self:initStateMachine()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitStoryRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

function StoryRole:initAni(args,pRoleInfo)
  self._kStoryRoleType = args.RoleType
  self._pInstenceId = args.InstanceID
  if self._kStoryRoleType == kType.kRole.kPlayer then
    self._pRoleInfo = pRoleInfo
    self._tTempleteInfo = TableTempleteCareers[self._pRoleInfo.roleCareer]
    self:initRoleAni()

  elseif self._kStoryRoleType == kType.kRole.kNpc then
    self._tTempleteInfo = TableTempleteNpcRoles[args.TempleteID]
    self:initNpcAni()

  elseif self._kStoryRoleType == kType.kRole.kMonster then
     self._tTempleteInfo = TableTempleteMonster[args.TempleteID]
     self:initMonsterAni()
  end
  local pos = StoryGuideManager:getInstance():toPos(args.StartX,args.StartY,true)
  self:setPosition(pos)
  self:setPositionZ(self:getPositionIndex().y*self:getStoryGuideManager():getStoryGuideLayer()._f3DZ)
  self:setLocalZOrder(self:getStoryGuideManager():getStoryGuideLayer()._sMapRectPixelSize.height - self:getPositionY())
end

-- 初始化动画
function StoryRole:initRoleAni()

    local tBodyTempleteInfo = nil
    --先初始化人物信息
    for i=1,table.getn(self._pRoleInfo.equipemts) do --遍历装备集合
        GetCompleteItemInfo(self._pRoleInfo.equipemts[i],self._pRoleInfo.roleCareer)
    end

    --普通身
    for i=1,table.getn(self._pRoleInfo.equipemts) do --遍历装备集合
        local nPart = self._pRoleInfo.equipemts[i].dataInfo.Part -- 部位
        if nPart == kEqpLocation.kBody then  -- 时装身部位
            tBodyTempleteInfo = self._pRoleInfo.equipemts[i].templeteInfo
            break     
        end
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
        setSprite3dMaterial(self._pAni,tBodyTempleteInfo.Material)

        -- 3D武器模型
        local tWeaponTempleteInfo = nil
        for i=1,table.getn(self._pRoleInfo.equipemts) do --遍历装备集合
            local nPart = self._pRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kWeapon then    -- 武器背部位
                tWeaponTempleteInfo = self._pRoleInfo.equipemts[i].templeteInfo
               break     
            end
        end

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
            setSprite3dMaterial(self._pWeaponR,tWeaponTempleteInfo.Material)
        end
        if pWeaponLC3bName then
            self._pWeaponL = cc.Sprite3D:create(pWeaponLC3bName)
            self._pWeaponL:setTexture(pWeaponTextureName)
            self._pWeaponL:setScale(tWeaponTempleteInfo.ModelScale2)
            local animation = cc.Animation3D:create(pWeaponLC3bName)
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self._pWeaponL:runAction(act)
            self._pAni:getAttachNode("boneLeftHandAttach"):addChild(self._pWeaponL)
            setSprite3dMaterial(self._pWeaponL,tWeaponTempleteInfo.Material)
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
        setSprite3dMaterial(self._pBack,tFashionBackTempleteInfo.Material)
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

    --[[
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
    ]]
    -- 角色阴影
    self._pShadow = cc.Sprite:createWithSpriteFrameName("ShadowRes/shadow.png")
    self:addChild(self._pShadow, -2)

end

function StoryRole:initNpcAni()

 local tTempleteInfo = self._tTempleteInfo
    self._kAniType = tTempleteInfo.AniType
    self._strAniName = tTempleteInfo.AniResName

    local fullAniName = self._strAniName..".c3b"
    local fullTextureName = tTempleteInfo.Texture..".pvr.ccz"
    self._strBodyTexturePvrName = tTempleteInfo.Texture
    
    -- 记录并加载到纹理缓存中
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tTempleteInfo.Texture)
    self._pAni = cc.Sprite3D:create(fullAniName)
    self._pAni:setTexture(fullTextureName)
    self:addChild(self._pAni)
    self._pAni:setScale(tTempleteInfo.Scale)
    
    -- 脚底法阵
    if self._tTempleteInfo.MagicEffect ~= "none" and self._tTempleteInfo.MagicEffect ~= "" then
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(self._tTempleteInfo.MagicEffect)
        self._pMagicEffectAni = cc.CSLoader:createNode(self._tTempleteInfo.MagicEffect..".csb")
        local pMagicEffectAction = cc.CSLoader:createTimeline(self._tTempleteInfo.MagicEffect..".csb")
        pMagicEffectAction:gotoFrameAndPlay(0, pMagicEffectAction:getDuration(), true)
        self._pMagicEffectAni:runAction(pMagicEffectAction)
        self._pMagicEffectAni:setScale(1.0)
        --self._pMagicEffectAni:setScale(0.8/tTempleteInfo.Scale)
        self:addChild(self._pMagicEffectAni)
    end
end

-- 初始化动画
function StoryRole:initMonsterAni()  
     local tTempleteInfo = self._tTempleteInfo
    self._kAniType = tTempleteInfo.AniType
    self._strAniName = tTempleteInfo.Model

    local fullAniName = self._strAniName..".c3b"
    local fullTextureName = tTempleteInfo.Texture..".pvr.ccz"
        -- 记录并加载到纹理缓存中
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tTempleteInfo.Texture)
    self._strBodyTexturePvrName = tTempleteInfo.Texture
    self._pAni = cc.Sprite3D:create(fullAniName)
    self._pAni:setTexture(fullTextureName)
    self:addChild(self._pAni)

    self._pAni:setScale(tTempleteInfo.Scale)
    
    -- 野怪有指定转向
    if tTempleteInfo.AppointedRotation ~= -1 then
        self:setAngle3D(tTempleteInfo.AppointedRotation)
        self._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(tTempleteInfo.AppointedRotation)
    end

end

function StoryRole:initEffects()

   -- 死亡特效
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr("DeadEffect")
   self._pDeadEffectAni = cc.CSLoader:createNode("DeadEffect.csb")
   self:getMapManager()._pTmxMap:addChild(self._pDeadEffectAni)
   self._pDeadEffectAni:setVisible(false)

end

-- 播放站立动作
function StoryRole:playStandAction()
    -- 站立动作
    if self._tTempleteInfo.StandActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.StandActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.StandActFrameRegion[2]
        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        temp:setSpeed(self._tTempleteInfo.StandActFrameRegion[3])
        local stand = cc.RepeatForever:create(temp)
        self._pAni:stopActionByTag(nRoleActAction)
        stand:setTag(nRoleActAction)
        self._pAni:runAction(stand)
    end
end


-- 播放休闲动作
function StoryRole:playCasualAction()
    -- 休闲动作
    if self._tTempleteInfo.CasualActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.CasualActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.CasualActFrameRegion[2]
        local casual = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        casual:setSpeed(self._tTempleteInfo.CasualActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        casual:setTag(nRoleActAction)
        self._pAni:runAction(casual)        
    end
    
end

-- 获取休闲动作的时间间隔（单位：秒）
function StoryRole:getCasualActionTime()
    local duration = (self._tTempleteInfo.CasualActFrameRegion[2] - self._tTempleteInfo.CasualActFrameRegion[1])/30
    local speed = self._tTempleteInfo.CasualActFrameRegion[3]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end


function StoryRole:playRunAction()
      -- 奔跑动作
    if self._tTempleteInfo.RunActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.RunActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.RunActFrameRegion[2]
        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        temp:setSpeed(self._tTempleteInfo.RunActFrameRegion[3])
        local run = cc.RepeatForever:create(temp)
        self._pAni:stopActionByTag(nRoleActAction)
        run:setTag(nRoleActAction)
        self._pAni:runAction(run)
    end
end


-- 播放死亡动作
function StoryRole:playDeadAction()
    -- 死亡动作
    if self._tTempleteInfo.DeadActFrameRegion ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local fStartFrame = self._tTempleteInfo.DeadActFrameRegion[1]
        local fEndFrame = self._tTempleteInfo.DeadActFrameRegion[2]
        local dead = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
        dead:setSpeed(self._tTempleteInfo.DeadActFrameRegion[3])
        self._pAni:stopActionByTag(nRoleActAction)
        dead:setTag(nRoleActAction)
        self._pAni:runAction(dead)
    end 

end

-- 播放攻击动作
function StoryRole:playAttackAction(index)
    -- 攻击动作
    if self._tTempleteInfo.AttackActFrameRegions ~= nil then
        local fullAniName = self._strAniName..".c3b"
        local animation = cc.Animation3D:create(fullAniName)
        local region = self._tTempleteInfo.AttackActFrameRegions[index]
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

-- 显示死亡特效
function StoryRole:playDeadEffect()
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

--添加技能
function StoryRole:playSkill(pTalkInfo)
   
    local playActCallBack = function()
        print("skillName "..pTalkInfo.SkillName)
        local pSkill = cc.CSLoader:createNode(pTalkInfo.SkillName..".csb")
        local pos = StoryGuideManager:getInstance():toPos(pTalkInfo.SkillDisplaceX,pTalkInfo.SkillDisplaceY)
        pSkill:setPosition(pos)
        self:addChild(pSkill)
        pSkill:setLocalZOrder(self:getLocalZOrder()+1)
        pSkill:stopAllActions()
        local action = cc.CSLoader:createTimeline(pTalkInfo.SkillName..".csb")
        action:gotoFrameAndPlay(pTalkInfo.SkillStartFrame, pTalkInfo.SkillEndFrame, false)  
        pSkill:runAction(action)
    end 

    self._pSkillActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(pTalkInfo.SkillWaitTime),cc.CallFunc:create(playActCallBack)))
end

--角色移除
function StoryRole:removeRole()
    local runActionCalllBack = function()
        StoryGuideManager:getInstance():removeRoleByInstenceId(self._pInstenceId)
        self:removeFromParent(true)
        print("removeOK")
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
    end
    print("remove")
    self:getStateMachineByTypeID(kType.kStateMachine.kStoryGuideRole):setCurStateByTypeID(kType.kState.kStoryGuideRole.kDead, false, {func = runActionCalllBack})
end

--角色移动
function StoryRole:moveRole(pPos,nSpeed)
    local runActionCalllBack = function()
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
    end

    self:getStateMachineByTypeID(kType.kStateMachine.kStoryGuideRole):setCurStateByTypeID(kType.kState.kStoryGuideRole.kRun, false, {endPos = pPos ,speed = nSpeed,func = runActionCalllBack })
end

--释放技能
function StoryRole:playAttackSkill(pTackInfo)
    local runActionCalllBack = function()
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
    end
 self:getStateMachineByTypeID(kType.kStateMachine.kStoryGuideRole):setCurStateByTypeID(kType.kState.kStoryGuideRole.kSkillAttack, false, {tkillInfo = pTackInfo ,func = runActionCalllBack })
end

-- 创建人物角色状态机
function StoryRole:initStateMachine()
  self._pStateMachineDelegate = require("StateMachineDelegate"):create()
  local pStateMachine = nil

    pStateMachine = require("StoryGuideRoleStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)

end

-- 设置3D模型的角度
function StoryRole:setAngle3D(angle)
    self._fAngle3D = (math.modf(angle+90))%360  -- 补一个起始差值
    local rotaion3D = self._pAni:getRotation3D()
    rotaion3D.y = self._fAngle3D
    self._pAni:setRotation3D(rotaion3D)
end


-- 获取攻击动作的时间间隔（单位：秒）
function StoryRole:getAttackActionTime(index)
    local duration = (self._tTempleteInfo.AttackActFrameRegions[index][2] - self._tTempleteInfo.AttackActFrameRegions[index][1])/30
    local speed = self._tTempleteInfo.AttackActFrameRegions[index][4]
    --local time = duration + (1.0 - speed)*duration
    local time = duration * (1/speed)
    return time
end

--刷新自身的posZ
function StoryRole:refreshZorder()
  self:setPositionZ(self:getPositionIndex().y*self:getStoryGuideManager():getStoryGuideLayer()._f3DZ)
  self:setLocalZOrder(self:getStoryGuideManager():getStoryGuideLayer()._sMapRectPixelSize.height - self:getPositionY())
end

-- 退出函数
function StoryRole:onExitStoryRole()
    -- 执行父类退出方法
    self:onExitGameObj()
end

-- 循环更新
function StoryRole:updateStoryRole(dt)
    self:updateGameObj(dt)
    self:refreshZorder()  
end

return StoryRole
