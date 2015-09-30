--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Role.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   角色基类
--===================================================
local Role = class("Role",function()
    return require("GameObj"):create()
end)

-- 构造函数
function Role:ctor()
    self._nID = 0                               -- 角色ID（服务器）
    self._strName = "Role"                      -- 角色名字
    self._kGameObjType = kType.kGameObj.kRole   -- 游戏对象类型
    self._kRoleType = kType.kRole.kNone         -- 角色对象类型
    self._kDirection = kDirection.kDown         -- 角色方向    
    self._pShadow = nil                         -- 角色阴影
    self._bForceMinPositionZ = false            -- 是否需要强制positionZ
    self._nForceMinPositionZValue = 0           -- 当已经强制了positionZ时候，给其设置的固定值
    self._strBodyTexturePvrName = ""            -- 角色身纹理名称
    self._tWaveEffectsInfo = {}                 -- [1] 身的信息  [2]武器的信息  [3]背的信息    （每一项的格式为：{t模型集合, t特效UV位置集合, 特效类型}）          
    self._pCurBuffColor = cc.c3b(255,255,255)   -- 由buff导致的模型颜色值
    self._nDefenseLevelOffset = 0               -- 角色防御等级变化值
    self._fAttriValueOffsets = {}               -- 角色属性变化值{....., [kAttribute.kDefend] = -20, ......, [kAttribute.kColdAttack] = 36.5, ......, [kAttribute.kLifeSteal] = 0, .......}
    for i = 1, kAttribute.kTotalNum do          -- 初始化角色属性变化值， 默认均为0
        self._fAttriValueOffsets[i] = 0
    end
    self._fSunderArmorLoseHpRate = 0            -- 角色破甲时掉Hp（仅被技能攻击时）时额外附加的最大HP伤害的百分比
    self._bMustBlock = false                    -- 是否必须格挡
    ---------------------------------- 火 冰 雷 属性积蓄值相关参数 ----------------------------------
    self._nCurFireSaving = 0                    -- 当前火属性积蓄值
    self._nCurIceSaving = 0                     -- 当前冰属性积蓄值
    self._nCurThunderSaving = 0                 -- 当前雷属性积蓄值
    self._nFireSavingMax = 0                    -- 火属性积蓄上限
    self._nIceSavingMax = 0                     -- 冰属性积蓄上限
    self._nThunderSavingMax = 0                 -- 雷属性积蓄上限
    self._nFireSavingRecover = 0                -- 火属性恢复速度(值/s)
    self._nIceSavingRecover = 0                 -- 冰属性恢复速度(值/s)
    self._nThunderSavingRecover = 0             -- 雷属性恢复速度(值/s)
    self._fSavingPatience = 1.0                 -- 属性积蓄的耐性
    ---------------------------------------------------------------------------------------------
    self._pAppearActionNode = nil               -- 【动作依托的节点】出场的动作节点
    self._pBebeatedActionNode = nil             -- 【动作依托的节点】应值的动作节点
    self._pBebeatedActDelayActionNode = nil     -- 【动作依托的节点】应值时整体动作的滞后动作节点
    self._pKartunActionNode = nil               -- 【动作依托的节点】卡顿的动作节点
    
end

-- 创建函数
function Role:create()
    local role = Role.new()
    role:dispose()
    return role
end

-- 处理函数
function Role:dispose()
    -- 角色阴影
    self._pShadow = cc.Sprite:createWithSpriteFrameName("ShadowRes/shadow.png")
    self:addChild(self._pShadow, -2)
    -- 动作依托的节点
    self._pAppearActionNode = cc.Node:create()
    self._pBebeatedActionNode = cc.Node:create()
    self._pBebeatedActDelayActionNode = cc.Node:create()
    self._pKartunActionNode = cc.Node:create()
    self:addChild(self._pAppearActionNode)
    self:addChild(self._pBebeatedActionNode)
    self:addChild(self._pBebeatedActDelayActionNode)
    self:addChild(self._pKartunActionNode)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRole()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function Role:onExitRole()
    -- 执行父类退出方法
    self:onExitGameObj()
end

-- 循环更新
function Role:updateRole(dt)
    self:updateGameObj(dt)
    self:procWaveEffect(dt)
    
end

function Role:procWaveEffect(dt)
    for kItem, vItem in pairs(self._tWaveEffectsInfo) do
        if vItem[1] then
            for kAni, vAni in pairs(vItem[1]) do
                local glprogramstate = vAni:getGLProgramState()
                vItem[2][kAni].x = vItem[2][kAni].x + 0.01
                if vItem[2][kAni].x > 1.0 then
                    vItem[2][kAni].x = vItem[2][kAni].x - 1.0
                end
                vItem[2][kAni].y = vItem[2][kAni].y + 0.01
                if vItem[2][kAni].y > 1.0 then
                    vItem[2][kAni].y = vItem[2][kAni].y - 1.0
                end
                glprogramstate:setUniformVec2("v_animLight",vItem[2][kAni])
            end
        end
    end
    
end

-- 根据探测位置检测当在探测位置时，自身bottom矩形是否和地图中的任何bottom矩形发生了碰撞，返回的是碰撞的方向集合
-- 参数bAtSelfDirection表示在发生碰撞时，碰撞方向的集合中，是否忽略自身方向
function Role:detecCollisionBottomOnBottomsByDetecPos(posDetec, bAtSelfDirection)
    local posXBak, posYBak = self:getPosition()
    self:setPosition(posDetec)
    local nAreaIndex = self:getMapManager():getMapAreaIndexByPos(cc.p(self:getPositionX(), self:getPositionY())) -- 地图分块区域索引值
    local collisionDirections = self:getRectsManager()._pHelper:isCollidingBottomOnBottomsInArea(nAreaIndex, self:getBottomRectInMap(), bAtSelfDirection, self._kDirection)   
    self:setPosition(cc.p(posXBak, posYBak))
    return collisionDirections
end

-- 根据探测位置检测当在探测位置时，自身bottom矩形是否和地图中的任何body矩形发生了碰撞，返回的是碰撞的方向集合
-- 参数bAtSelfDirection表示在发生碰撞时，碰撞方向的集合中，是否忽略自身方向
function Role:detecCollisionBottomOnBodysByDetecPos(posDetec, bAtSelfDirection)
    local posXBak, posYBak = self:getPosition()
    self:setPosition(posDetec)
    local nAreaIndex = self:getMapManager():getMapAreaIndexByPos(cc.p(self:getPositionX(), self:getPositionY())) -- 地图分块区域索引值
    local collisionDirections = self:getRectsManager()._pHelper:isCollidingBottomOnBodysInArea(nAreaIndex, self:getBottomRectInMap(), bAtSelfDirection, self._kDirection)
    self:setPosition(cc.p(posXBak, posYBak))
    return collisionDirections
end

-- 当前位置矫正(完毕：返回true，未完成：返回false)
function Role:adjustPos()
    local posRole = cc.p(self:getPositionX(), self:getPositionY())
    local posCurIndex = self:getMapManager():convertPiexlToIndex(posRole)
    local posStandard = self:getMapManager():convertIndexToPiexl(posCurIndex)
    -- 0.5秒内纠正完毕
    self:runAction(cc.MoveBy:create(0.5, cc.p(posStandard.x - posRole.x, posStandard.y - posRole.y)))
    --self:setPosition(posStandard)
end

-- 停止角色当前动作
function Role:stopRoleActAction()
    self._pAni:stopActionByTag(nRoleActAction)    
end

-- 检测遮挡
function Role:checkCover()
    local directions = self:detecCollisionBottomOnBodysByDetecPos(cc.p(self:getPositionX(), self:getPositionY()), false)
    if directions ~= 0 then -- 发生碰撞
        self:setOpacity()
    else  -- 没有碰撞
        self:setNoOpacity()
    end
    return
end

-- 获取遮挡时的半透度
function Role:getCoverOpacity()
    return 130
end

-- 设置半透
function Role:setOpacity()
    if self._pAni:getOpacity() ~= self:getCoverOpacity() then
    
        self:hideWaveEffect(kType.kBodyParts.kBack)
        self:hideWaveEffect(kType.kBodyParts.kBody)
        self:hideWaveEffect(kType.kBodyParts.kWeapon)
        
        self._pAni:setOpacity(self:getCoverOpacity())
        if self._pShadow then
            self._pShadow:setOpacity(self:getCoverOpacity())
        end
        if self._pHalo then
            self._pHalo:setOpacity(self:getCoverOpacity())
        end
        if self._pBack then
            self._pBack:setOpacity(self:getCoverOpacity())
        end
        if self._pWeaponR then
            self._pWeaponR:setOpacity(self:getCoverOpacity())
        end
        if self._pWeaponL then
            self._pWeaponL:setOpacity(self:getCoverOpacity())
        end
        
    end
end

-- 设置非半透
function Role:setNoOpacity()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        local needOpacity = self._pRefGhostOpacity:needOpacity()
        if needOpacity == true then
            return
        end
    end
    
    if self._pAni:getOpacity() ~= 255 then
    
        self:showWaveEffect(kType.kBodyParts.kBack)
        self:showWaveEffect(kType.kBodyParts.kBody)
        self:showWaveEffect(kType.kBodyParts.kWeapon)
        
        self._pAni:setOpacity(255)
        if self._pShadow then
            self._pShadow:setOpacity(255)
        end
        if self._pHalo then
            self._pHalo:setOpacity(255)
        end
        if self._pBack then
            self._pBack:setOpacity(255)
        end
        if self._pWeaponR then
            self._pWeaponR:setOpacity(255)
        end
        if self._pWeaponL then
            self._pWeaponL:setOpacity(255)
        end        
    end
end

-- 添加波纹特效
-- 参数1：位置类型，如身、背、武器
-- 参数2：特效类型
function Role:addWaveEffect(posType, type)
    local tAniPvrNames = {}
    local tAnis = {}
    local strEffectPvrName = "" 
    local color = cc.vec4(1,1,1,1)
    
    if posType == kType.kBodyParts.kBody then
        table.insert(tAniPvrNames,self._strBodyTexturePvrName)
        table.insert(tAnis,self._pAni)
    elseif posType == kType.kBodyParts.kWeapon then
        if self._pWeaponL then
            table.insert(tAniPvrNames,self._strWeaponTexturePvrName)
            table.insert(tAnis,self._pWeaponL)
        end
        if self._pWeaponR then
            table.insert(tAniPvrNames,self._strWeaponTexturePvrName)
            table.insert(tAnis,self._pWeaponR)
        end
    elseif posType == kType.kBodyParts.kBack then
        table.insert(tAniPvrNames,self._strBackTexturePvrName)
        table.insert(tAnis,self._pBack)
    end
    
    if type == 1 then
        strEffectPvrName = "caustics"
        color = cc.vec4(1,1,1,1)
    elseif type == 2 then
        strEffectPvrName = "caustics"
        color = cc.vec4(1,0,0,1)
    elseif type == 3 then
        strEffectPvrName = "caustics"
        color = cc.vec4(0,0,1,1)
    end
    
    for k, v in pairs(tAnis) do 
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(strEffectPvrName)
        mmo.HelpFunc:addWaveEffectByShader(tAnis[k], tAniPvrNames[k]..".pvr.ccz", strEffectPvrName..".pvr.ccz", color)
    end
    
    self._tWaveEffectsInfo[posType] = {}
    self._tWaveEffectsInfo[posType][1] = tAnis -- 正在显示波纹shader特效的3d模型集合   
    self._tWaveEffectsInfo[posType][2] = {}     -- UV坐标集合
    self._tWaveEffectsInfo[posType][3] = nil     -- 特效的type集合
    for k, v in pairs(self._tWaveEffectsInfo[posType][1]) do
        table.insert(self._tWaveEffectsInfo[posType][2],cc.p(0,0)) -- 波纹shader特效在模型上的UV坐标集合 
        self._tWaveEffectsInfo[posType][3] = type  -- 波纹shader特效在模型上的特效type
    end
    
end

-- 移除波纹特效
-- 参数：位置类型，如身、背、武器
function Role:removeWaveEffect(posType)
    local item = self._tWaveEffectsInfo[posType]
    if item[1] then
        for kAni, vAni in pairs(item[1]) do 
            mmo.HelpFunc:removeWaveEffectByShader(vAni) 
        end
    end
    self._tWaveEffectsInfo[posType] = nil
end

-- 显示波纹特效
-- 参数：位置类型，如身、背、武器
function Role:showWaveEffect(posType)
    if self._tWaveEffectsInfo[posType] then
        for kAni,vAni in pairs(self._tWaveEffectsInfo[posType][1]) do
            mmo.HelpFunc:showWaveEffectByShader(vAni)
        end
    end
end

-- 隐藏波纹特效
-- 参数：位置类型，如身、背、武器
function Role:hideWaveEffect(posType)
    if self._tWaveEffectsInfo[posType] then
        for kAni,vAni in pairs(self._tWaveEffectsInfo[posType][1]) do
            mmo.HelpFunc:hideWaveEffectByShader(vAni)
        end
    end
end

-- 根据buffID添加相应buff
function Role:addBuffByID(buffID)
    if self._nCurHp <= 0 then
        return nil
    end
    if buffID ~= -1 then
        -- 产生相应buff
        local className = ""
        if TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleFireBuff then
            className = "BattleFireBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleColdBuff then
            className = "BattleColdBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleThunderBuff then
            className = "BattleThunderBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleDizzyBuff then
            className = "BattleDizzyBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattlePoisonBuff then
            className = "BattlePoisonBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleAddHpBuff then
            className = "BattleAddHpBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleGodBuff then
            className = "BattleGodBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleGhostBuff then
            className = "BattleGhostBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleAttriUpBuff then
            className = "BattleAttriUpBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleAttriDownBuff then
            className = "BattleAttriDownBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleSpeedDownBuff then
            className = "BattleSpeedDownBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleHpLimitUpBuff then
            className = "BattleHpLimitUpBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleClearAndImmuneBuff then
            className = "BattleClearAndImmuneBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleRigidBodyBuff then
            className = "BattleRigidBodyBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleFightBackFireBuff then
            className = "BattleFightBackFireBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleFightBackIceBuff then
            className = "BattleFightBackIceBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleFightBackThunderBuff then
            className = "BattleFightBackThunderBuffController"
        elseif TableBuff[buffID].TypeID == kType.kController.kBuff.kBattleSunderArmorBuff then
            className = "BattleSunderArmorBuffController"
        end
        
        -- 检查buff的免疫类型集合
        if self._pRoleInfo.ImmuneBuffTypes and self._pRoleInfo.ImmuneBuffTypes ~= "none" then
            for k,v in pairs(self._pRoleInfo.ImmuneBuffTypes) do 
                if TableBuff[buffID].TypeID == v then
                    return
                end
            end
        end

        -- 产生buff
        local buff = require(className):create(self, TableBuff[buffID])
        self:getBuffControllerMachine():addController(buff)
        return buff
    end
    return nil
end

-- 获取buff的controllermachine（所有角色都会有buff）
function Role:getBuffControllerMachine()
    return self:getControllerMachineByTypeID(kType.kControllerMachine.kBattleBuff)
end

-- 获取passive的controllermachine（只有玩家和宠物会有passive）
function Role:getPassiveControllerMachine()
    return self:getControllerMachineByTypeID(kType.kControllerMachine.kBattlePassive)
end

-- 显示升级特效  add by liyuhang
function Role:playLevelUpEffect()
    if self.pLevelUpEffectAni == nil then
        self.pLevelUpEffectAni = cc.CSLoader:createNode("LevelupEffect.csb")
        self.pLevelUpEffectAni:setPosition(cc.p(0,60))
        self:addChild(self.pLevelUpEffectAni,-2)
    end
    self:refreshCamera()

    local pLevelUpEffectAction = cc.CSLoader:createTimeline("LevelupEffect.csb")
    pLevelUpEffectAction:gotoFrameAndPlay(0, pLevelUpEffectAction:getDuration(), false)   
    self.pLevelUpEffectAni:runAction(pLevelUpEffectAction)
    
    if self.pLevelUpEffectFAni == nil then
        self.pLevelUpEffectFAni = cc.CSLoader:createNode("LevelupEffectF.csb")
        self.pLevelUpEffectFAni:setPosition(cc.p(0,60))
        self:addChild(self.pLevelUpEffectFAni)
    end
    self:refreshCamera()

    local pLevelUpEffectFAction = cc.CSLoader:createTimeline("LevelupEffectF.csb")
    pLevelUpEffectFAction:gotoFrameAndPlay(0, pLevelUpEffectFAction:getDuration(), false)   
    self.pLevelUpEffectFAni:runAction(pLevelUpEffectFAction)
end

-- 角色卡顿
function Role:roleKartun(time)
    if time ~= 0 then
        -- 开始卡顿
        self._pKartunActionNode:getActionManager():pauseTarget(self)
        self._pKartunActionNode:getActionManager():pauseTarget(self._pAni)
        self._pKartunActionNode:getActionManager():pauseTarget(self._pAppearActionNode)
        self._pKartunActionNode:getActionManager():pauseTarget(self._pBebeatedActionNode)
        self._pKartunActionNode:getActionManager():pauseTarget(self._pBebeatedActDelayActionNode)
        for k,v in pairs(self._tSkills) do 
           self._pKartunActionNode:getActionManager():pauseTarget(v)
           self._pKartunActionNode:getActionManager():pauseTarget(v._pAni)
           self._pKartunActionNode:getActionManager():pauseTarget(v._pChantOverActionNode)
           self._pKartunActionNode:getActionManager():pauseTarget(v._pSkillActOverActionNode)
        end
        local kartunOver = function()
            -- 恢复卡顿
            self._pKartunActionNode:getActionManager():resumeTarget(self)
            self._pKartunActionNode:getActionManager():resumeTarget(self._pAni)
            self._pKartunActionNode:getActionManager():resumeTarget(self._pAppearActionNode)
            self._pKartunActionNode:getActionManager():resumeTarget(self._pBebeatedActionNode)
            self._pKartunActionNode:getActionManager():resumeTarget(self._pBebeatedActDelayActionNode)
            for k,v in pairs(self._tSkills) do 
               self._pKartunActionNode:getActionManager():resumeTarget(v)
               self._pKartunActionNode:getActionManager():resumeTarget(v._pAni)
               self._pKartunActionNode:getActionManager():resumeTarget(v._pChantOverActionNode)
               self._pKartunActionNode:getActionManager():resumeTarget(v._pSkillActOverActionNode)
            end
        end
        self._pKartunActionNode:stopAllActions()
        self._pKartunActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(kartunOver)))
    end

end


return Role
