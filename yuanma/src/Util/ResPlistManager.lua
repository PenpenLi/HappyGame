--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ResPlistManager.lua
-- author:    liyuhang
-- created:   2014/12/7
-- descrip:   资源管理器
--===================================================
ResPlistManager = {}

local instance = nil

-- 单例
function ResPlistManager:getInstance()
    if not instance then
        instance = ResPlistManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function ResPlistManager:clearCache()    
    self._tResTable = {}
    self._tPvrNameCollector = {}                    -- 需加载的纹理名称收集器
    self._bAsyncStart = false                       -- 异步资源加载是否开始
end

-- add 资源（先添加spriteFrames，后自动添加textures）
function ResPlistManager:addSpriteFrames(plistPathName)
    if self._tResTable[plistPathName] == nil then
        cc.SpriteFrameCache:getInstance():addSpriteFrames(plistPathName)
        local texturePathName = string.sub(plistPathName,0,string.len(plistPathName)-6)
        cc.Director:getInstance():getTextureCache():addImage(texturePathName ..".pvr.ccz")
        self._tResTable[plistPathName] = {plistName = plistPathName , ref = 1}
    else
        self._tResTable[plistPathName].ref = self._tResTable[plistPathName].ref + 1
    end
end

-- release 资源（先移除spriteFrames，后自动移除textures）
function ResPlistManager:removeSpriteFrames(plistPathName)
    if self._tResTable[plistPathName] == nil then
        print("try to release plist " .. plistPathName .." but this is not added")
        return
    else
        self._tResTable[plistPathName].ref = self._tResTable[plistPathName].ref - 1
        if self._tResTable[plistPathName].ref <= 0 then
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plistPathName)
            local texturePathName = string.sub(plistPathName,0,string.len(plistPathName)-6)
            cc.Director:getInstance():getTextureCache():removeTextureForKey(texturePathName ..".pvr.ccz")
            self._tResTable[plistPathName] = nil
        end
    end
    
end

-- release 资源（先移除spriteFrames，后自动移除textures）
function ResPlistManager:removeSpriteFramesInLoading()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    self._tResTable = {}
    self:addSpriteFrames("loading.plist")
    
end

------------------------------------ 添加必要的资源 ---------------------------------------------------
function ResPlistManager:addNecessarySpriteFrames()
    self:addSpriteFrames("debug.plist")
    self:addSpriteFrames("comUI.plist")
    self:addSpriteFrames("comAni.plist")
    self:addSpriteFrames("emoji.plist")
    self:addSpriteFrames("goods_icon.plist")
    self:addSpriteFrames("PromptDialog.plist")

end

--------------------------------- Login登录相关纹理资源名称收集器 --------------------------------------
function ResPlistManager:collectPvrNameForLogin()

    -- 登录账户相关资源，角色创建与角色选择相关资源    
    table.insert(self._tPvrNameCollector, "CreatRolePanel")
    table.insert(self._tPvrNameCollector, "SeverSlectPanel")
    table.insert(self._tPvrNameCollector, "StartGamePanel")
    table.insert(self._tPvrNameCollector, "RoleSlectPanel")
    table.insert(self._tPvrNameCollector, "LoginBg")
    table.insert(self._tPvrNameCollector, "ServerItem")

end

----------------------------------- 战斗相关纹理资源名称收集器 ------------------------------------------
function ResPlistManager:collectPvrNameForWorld()
    
    --预加载家园 npc的音效
    for k ,v in pairs(TableTempleteNpcRoles) do
        for kv,vv in pairs(v.Voice) do 
            AudioManager:preloadEffect(vv[1])
        end
    end
    
    
    -- 家园地图纹理
    table.insert(self._tPvrNameCollector, tDefaultMapNames[1])
    table.insert(self._tPvrNameCollector, tDefaultMapNames[2])
    
    -- 家园动画纹理
    table.insert(self._tPvrNameCollector, "world_anis")
    
    -- 家园icons
    table.insert(self._tPvrNameCollector, "main_icons")
    
    --家用buff
    table.insert(self._tPvrNameCollector, "home_buff")
    
    -- 宠物头像
    table.insert(self._tPvrNameCollector, "pet_icon")
    
    -- 场景云
    table.insert(self._tPvrNameCollector, "CloudTransfor")
    
    -- NPC的脚下法阵特效
    table.insert(self._tPvrNameCollector, "NpcEffect")
    
    -- 技能图标资源  按职业区分  
    local nCareer = RolesManager:getInstance()._pMainRoleInfo.roleCareer
    local temp = {"warrior_skill_icon","mage_skill_icon","thug_skill_icon"}
    table.insert(self._tPvrNameCollector, temp[nCareer])

    -- 主角玩家的模型贴图和武器贴图
    local pMainPlayerRoleInfo = RolesManager:getInstance()._pMainRoleInfo
    local templeteID = TableEquips[pMainPlayerRoleInfo.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[pMainPlayerRoleInfo.roleCareer]
    local strBodyPvrName = TableTempleteEquips[templeteID].Texture
    local templeteID = TableEquips[pMainPlayerRoleInfo.equipemts[kEqpLocation.kWeapon].id - 100000].TempleteID[pMainPlayerRoleInfo.roleCareer]
    local strWeaponPvrName = TableTempleteEquips[templeteID].Texture
    if self:checkPvrNameCollectorItemExist(strWeaponPvrName) == false then
        table.insert(self._tPvrNameCollector, strWeaponPvrName)
    end
    
    
    --先初始化人物信息
    for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
        GetCompleteItemInfo(pMainPlayerRoleInfo.equipemts[i],nCareer)
     end
    
    -- 加载时装身贴图
    if pMainPlayerRoleInfo.fashionOptions and pMainPlayerRoleInfo.fashionOptions[2] == true then
        for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
            local nPart = pMainPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                strBodyPvrName = pMainPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                break     
            end
        end
    end
    if self:checkPvrNameCollectorItemExist(strBodyPvrName) == false then
        table.insert(self._tPvrNameCollector, strBodyPvrName)
    end

    -- 加载时装背贴图
    if pMainPlayerRoleInfo.fashionOptions and pMainPlayerRoleInfo.fashionOptions[1] == true then
        local strBackPvrName = ""    
        for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
            local nPart =pMainPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                strBackPvrName = pMainPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                break
            end
        end
        if self:checkPvrNameCollectorItemExist(strBackPvrName) == false then
            table.insert(self._tPvrNameCollector, strBackPvrName)
        end
    end

    -- 加载时装光环合图
    if pMainPlayerRoleInfo.fashionOptions and pMainPlayerRoleInfo.fashionOptions[3] == true then
        local strHaloPvrName = ""
        for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
            local nPart = pMainPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionHalo then  -- 时装光环部位
                strHaloPvrName = pMainPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                break     
            end
        end
        if self:checkPvrNameCollectorItemExist(strHaloPvrName) == false then
            table.insert(self._tPvrNameCollector, strHaloPvrName)
        end
    end
    
    -- 宠物的模型贴图
    local tMainPetRoleInfos = PetsManager:getInstance()._tMainPetRoleInfosInQueue
    for kInfo,vInfo in pairs(tMainPetRoleInfos) do 
        local templeteInfo = TableTempletePets[TablePets[vInfo.petId].TempleteID[vInfo.step]]
        local texturePvrName = templeteInfo.Texture
        if self:checkPvrNameCollectorItemExist(texturePvrName) == false then
            table.insert(self._tPvrNameCollector, texturePvrName)
        end
    end
    
end

----------------------------------- 战斗相关纹理资源名称收集器 ------------------------------------------
function ResPlistManager:collectPvrNameForBattle()

    -- 战斗通用动画纹理
    table.insert(self._tPvrNameCollector, "battle_common_anis")
    
    -- 战斗buff图标
    table.insert(self._tPvrNameCollector, "buff_icons")
    
    -- 宠物头像
    table.insert(self._tPvrNameCollector, "pet_icon")
    
    -- 场景云
    table.insert(self._tPvrNameCollector, "CloudTransfor")
    
    -- 其他战斗必备特效动画
    table.insert(self._tPvrNameCollector, "SkillCDEffect")
    table.insert(self._tPvrNameCollector, "BlockHitEffect")
    table.insert(self._tPvrNameCollector, "CriticalHitEffect")
    table.insert(self._tPvrNameCollector, "DeadEffect")
    table.insert(self._tPvrNameCollector, "LevelupEffectF")
    table.insert(self._tPvrNameCollector, "LevelupEffect")
    table.insert(self._tPvrNameCollector, "FightBackFireBuff")
    table.insert(self._tPvrNameCollector, "FightBackIceBuff")
    table.insert(self._tPvrNameCollector, "FightBackThunderBuff")
    table.insert(self._tPvrNameCollector, "GoDirectionTip")
    table.insert(self._tPvrNameCollector, "HurtedFireEffect")
    table.insert(self._tPvrNameCollector, "HurtedIceEffect")
    table.insert(self._tPvrNameCollector, "HurtedPhysicEffect")
    table.insert(self._tPvrNameCollector, "HurtedThunderEffect")
    table.insert(self._tPvrNameCollector, "MissHitEffect")
    table.insert(self._tPvrNameCollector, "MonsterDebutEffect")
    table.insert(self._tPvrNameCollector, "BossStartEffect")
    table.insert(self._tPvrNameCollector, "MonsterDeadAttachBuffWarningEffect6")     -- 持续加血Buff警示
    table.insert(self._tPvrNameCollector, "MonsterDeadAttachBuffWarningEffect7")     -- 无敌Buff警示
    table.insert(self._tPvrNameCollector, "MonsterDeadAttachBuffWarningEffect9")     -- 属性增益Buff警示
    table.insert(self._tPvrNameCollector, "MonsterDeadAttachBuffWarningEffect11")    -- 减速Buff警示
    table.insert(self._tPvrNameCollector, "StunBuff")
    table.insert(self._tPvrNameCollector, "ThunderBuff")
    table.insert(self._tPvrNameCollector, "PenetrateBuff")
    table.insert(self._tPvrNameCollector, "EarlyWarningEffect1")
    table.insert(self._tPvrNameCollector, "EarlyWarningEffect2")
    table.insert(self._tPvrNameCollector, "EarlyWarningEffect3")
    table.insert(self._tPvrNameCollector, "EarlyWarningEffect4")
    
    -- 怒气UI特效
    table.insert(self._tPvrNameCollector, "AngerUIEffect1")
    table.insert(self._tPvrNameCollector, "AngerUIEffect2")
    table.insert(self._tPvrNameCollector, "AngerUIEffect3")
        
    -- 技能图标资源  按职业区分  
    local nCareer = RolesManager:getInstance()._pMainRoleInfo.roleCareer
    local temp = {"warrior_skill_icon","mage_skill_icon","thug_skill_icon"}
    table.insert(self._tPvrNameCollector, temp[nCareer])
    
    -- 地图纹理
    table.insert(self._tPvrNameCollector, MapManager:getInstance()._strNextMapPvrName)
    
    -- 金币掉落动画特效
    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kGold then
        table.insert(self._tPvrNameCollector, "GoldDropEffect")
    end
    
    --------------------------------------------------------- 主角 ----------------------------------------------------------------------------
    -- 主角玩家的模型贴图和武器贴
    local pMainPlayerRoleInfo = RolesManager:getInstance()._pMainRoleInfo
    local templeteID = TableEquips[pMainPlayerRoleInfo.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[pMainPlayerRoleInfo.roleCareer]
    local strBodyPvrName = TableTempleteEquips[templeteID].Texture
    local templeteID = TableEquips[pMainPlayerRoleInfo.equipemts[kEqpLocation.kWeapon].id - 100000].TempleteID[pMainPlayerRoleInfo.roleCareer]
    local strWeaponPvrName = TableTempleteEquips[templeteID].Texture
    if self:checkPvrNameCollectorItemExist(strWeaponPvrName) == false then
        table.insert(self._tPvrNameCollector, strWeaponPvrName)
    end
    
    --先初始化人物信息
    for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
        GetCompleteItemInfo(pMainPlayerRoleInfo.equipemts[i],nCareer)
    end
    
    -- 加载时装身贴图    
    if pMainPlayerRoleInfo.fashionOptions and pMainPlayerRoleInfo.fashionOptions[2] == true then
        for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
            local nPart = pMainPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                strBodyPvrName = pMainPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                break     
            end
        end
    end
    if self:checkPvrNameCollectorItemExist(strBodyPvrName) == false then
        table.insert(self._tPvrNameCollector, strBodyPvrName)
    end
    
    -- 加载时装背贴图
    if pMainPlayerRoleInfo.fashionOptions and pMainPlayerRoleInfo.fashionOptions[1] == true then
        local strBackPvrName = ""    
        for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
            local nPart = pMainPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                strBackPvrName = pMainPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                break     
            end
        end
        if self:checkPvrNameCollectorItemExist(strBackPvrName) == false then
            table.insert(self._tPvrNameCollector, strBackPvrName)
        end
    end
    
    -- 加载时装光环合图
    if pMainPlayerRoleInfo.fashionOptions and pMainPlayerRoleInfo.fashionOptions[3] == true then
        local strHaloPvrName = ""
        for i=1,table.getn(pMainPlayerRoleInfo.equipemts) do --遍历装备集合
            local nPart = pMainPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
            if nPart == kEqpLocation.kFashionHalo then  -- 时装光环部位
                strHaloPvrName = pMainPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                break     
            end
        end
        if self:checkPvrNameCollectorItemExist(strHaloPvrName) == false then
            table.insert(self._tPvrNameCollector, strHaloPvrName)
        end
    end
    
    -- 主角玩家普通攻击特效
    local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID((RolesManager:getInstance()._pMainRoleInfo.roleCareer-1)*activeSkillNum + 1,0)
    local templeteID = skillData.TempleteID
    if self:checkPvrNameCollectorItemExist(TableTempleteSkills[templeteID].DetailInfo.PvrName) == false then
        table.insert(self._tPvrNameCollector, TableTempleteSkills[templeteID].DetailInfo.PvrName)
    end
    -- 主角玩家技能攻击特效
    for k,v in pairs(SkillsManager:getInstance()._tMainRoleMountActvSkills) do
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(v.id,v.level)
        local templeteID = skillData.TempleteID
        if self:checkPvrNameCollectorItemExist(TableTempleteSkills[templeteID].DetailInfo.PvrName) == false then
            table.insert(self._tPvrNameCollector, TableTempleteSkills[templeteID].DetailInfo.PvrName)
        end
    end
    -- 主角玩家怒气技能特效
    if table.getn(SkillsManager:getInstance()._tMainRoleMountAngerSkills) ~= 0 then
        local skillData = SkillsManager:getInstance():getMainRoleSkillDataByID(SkillsManager:getInstance()._tMainRoleMountAngerSkills[1].id, SkillsManager:getInstance()._tMainRoleMountAngerSkills[1].level)
        local templeteID = skillData.TempleteID
        if self:checkPvrNameCollectorItemExist(TableTempleteSkills[templeteID].DetailInfo.PvrName) == false then
            table.insert(self._tPvrNameCollector, TableTempleteSkills[templeteID].DetailInfo.PvrName)
        end
    end
    
    --------------------------------------------------- 好友 ----------------------------------------------------------------------------
    -- 主角玩家的模型贴图和武器贴
    local pFriendRoleInfo = FriendManager:getInstance()._nMountFriendSkill
    if pFriendRoleInfo then
    
        local temp = {"warrior_skill_icon","mage_skill_icon","thug_skill_icon"}
        if self:checkPvrNameCollectorItemExist(temp[pFriendRoleInfo.roleCareer]) == false then
            table.insert(self._tPvrNameCollector, temp[pFriendRoleInfo.roleCareer])
        end
        
        table.insert(self._tPvrNameCollector, "FriendStart")
        
        local templeteID = TableEquips[pFriendRoleInfo.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[pFriendRoleInfo.roleCareer]
        local strBodyPvrName = TableTempleteEquips[templeteID].Texture
        local templeteID = TableEquips[pFriendRoleInfo.equipemts[kEqpLocation.kWeapon].id - 100000].TempleteID[pFriendRoleInfo.roleCareer]
        local strWeaponPvrName = TableTempleteEquips[templeteID].Texture
        if self:checkPvrNameCollectorItemExist(strWeaponPvrName) == false then
            table.insert(self._tPvrNameCollector, strWeaponPvrName)
        end
        
        --先初始化人物信息
        for i=1,table.getn(pFriendRoleInfo.equipemts) do --遍历装备集合
            GetCompleteItemInfo(pFriendRoleInfo.equipemts[i],pFriendRoleInfo.roleCareer)
        end

        -- 加载时装身贴图    
        if pFriendRoleInfo.fashionOptions and pFriendRoleInfo.fashionOptions[2] == true then
            for i=1,table.getn(pFriendRoleInfo.equipemts) do --遍历装备集合
                local nPart = pFriendRoleInfo.equipemts[i].dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                    strBodyPvrName = pFriendRoleInfo.equipemts[i].templeteInfo.Texture
                    break     
                end
            end
        end
        if self:checkPvrNameCollectorItemExist(strBodyPvrName) == false then
            table.insert(self._tPvrNameCollector, strBodyPvrName)
        end

        -- 加载时装背贴图
        if pFriendRoleInfo.fashionOptions and pFriendRoleInfo.fashionOptions[1] == true then
            local strBackPvrName = ""    
            for i=1,table.getn(pFriendRoleInfo.equipemts) do --遍历装备集合
                local nPart =pFriendRoleInfo.equipemts[i].dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                    strBackPvrName = pFriendRoleInfo.equipemts[i].templeteInfo.Texture
                    break
                end
            end
            if self:checkPvrNameCollectorItemExist(strBackPvrName) == false then
                table.insert(self._tPvrNameCollector, strBackPvrName)
            end
        end

        -- 加载时装光环合图
        if pFriendRoleInfo.fashionOptions and pFriendRoleInfo.fashionOptions[3] == true then
            local strHaloPvrName = ""
            for i=1,table.getn(pFriendRoleInfo.equipemts) do --遍历装备集合
                local nPart =pFriendRoleInfo.equipemts[i].dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionHalo then  -- 时装光环部位
                    strHaloPvrName = pFriendRoleInfo.equipemts[i].templeteInfo.Texture
                    break     
                end
            end
            if self:checkPvrNameCollectorItemExist(strHaloPvrName) == false then
                table.insert(self._tPvrNameCollector, strHaloPvrName)
            end
        end

        -- 好友技能特效
        if FriendManager:getInstance():getFriendSkillId() ~= -1 then
            local pSkillInfo = TableFriendSkills[FriendManager:getInstance():getFriendSkillId()]
            local pPvrName = TableTempleteSkills[pSkillInfo.TempleteID].DetailInfo.PvrName
            if self:checkPvrNameCollectorItemExist(pPvrName) == false then
                table.insert(self._tPvrNameCollector, pPvrName)
            end
        end
        
    end

    ----------------------------------------------------- 主角宠物 ------------------------------------------------------------------------
    -- 主角宠物的模型贴图
    local tMainPetRoleInfos = PetsManager:getInstance()._tMainPetRoleInfosInQueue
    for kInfo,vInfo in pairs(tMainPetRoleInfos) do 
        local templeteInfo = TableTempletePets[TablePets[vInfo.petId].TempleteID[vInfo.step]]
        local texturePvrName = templeteInfo.Texture
        if self:checkPvrNameCollectorItemExist(texturePvrName) == false then
            table.insert(self._tPvrNameCollector, texturePvrName)
        end
    end    
    
    ----------------------------------------------------- PVP主角 ----------------------------------------------------------------------------
    if RolesManager:getInstance()._pPvpRoleInfo then

        -- 主角玩家的模型贴图和武器贴
        local pPvpPlayerRoleInfo = RolesManager:getInstance()._pPvpRoleInfo
        local templeteID = TableEquips[pPvpPlayerRoleInfo.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[pPvpPlayerRoleInfo.roleCareer]
        local strBodyPvrName = TableTempleteEquips[templeteID].Texture
        local templeteID = TableEquips[pPvpPlayerRoleInfo.equipemts[kEqpLocation.kWeapon].id - 100000].TempleteID[pPvpPlayerRoleInfo.roleCareer]
        local strWeaponPvrName = TableTempleteEquips[templeteID].Texture
        if self:checkPvrNameCollectorItemExist(strWeaponPvrName) == false then
            table.insert(self._tPvrNameCollector, strWeaponPvrName)
        end
        
        --先初始化人物信息
        for i=1,table.getn(pPvpPlayerRoleInfo.equipemts) do --遍历装备集合
            GetCompleteItemInfo(pPvpPlayerRoleInfo.equipemts[i],pPvpPlayerRoleInfo.roleCareer)
        end
        
        -- 加载时装身贴图    
        if pPvpPlayerRoleInfo.fashionOptions and pPvpPlayerRoleInfo.fashionOptions[2] == true then
            for i=1,table.getn(pPvpPlayerRoleInfo.equipemts) do --遍历装备集合
                local nPart = pPvpPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                    strBodyPvrName = pPvpPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                    break     
                end
            end
        end
        if self:checkPvrNameCollectorItemExist(strBodyPvrName) == false then
            table.insert(self._tPvrNameCollector, strBodyPvrName)
        end

        -- 加载时装背贴图
        if pPvpPlayerRoleInfo.fashionOptions and pPvpPlayerRoleInfo.fashionOptions[1] == true then
            local strBackPvrName = ""    
            for i=1,table.getn(pPvpPlayerRoleInfo.equipemts) do --遍历装备集合
                local nPart = pPvpPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                    strBackPvrName = pPvpPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                    break     
                end
            end
            if self:checkPvrNameCollectorItemExist(strBackPvrName) == false then
                table.insert(self._tPvrNameCollector, strBackPvrName)
            end
        end

        -- 加载时装光环合图
        if pPvpPlayerRoleInfo.fashionOptions and pPvpPlayerRoleInfo.fashionOptions[3] == true then
            local strHaloPvrName = ""
            for i=1,table.getn(pPvpPlayerRoleInfo.equipemts) do --遍历装备集合
                local nPart = pPvpPlayerRoleInfo.equipemts[i].dataInfo.Part -- 部位
                if nPart == kEqpLocation.kFashionHalo then  -- 时装光环部位
                    strHaloPvrName = pPvpPlayerRoleInfo.equipemts[i].templeteInfo.Texture
                    break     
                end
            end
            if self:checkPvrNameCollectorItemExist(strHaloPvrName) == false then
                table.insert(self._tPvrNameCollector, strHaloPvrName)
            end
        end
        
        -- PVP主角玩家普通攻击特效
        local skillData = SkillsManager:getInstance():getPvpRoleSkillDataByID((RolesManager:getInstance()._pPvpRoleInfo.roleCareer-1)*activeSkillNum + 1,0)
        local templeteID = skillData.TempleteID
        if self:checkPvrNameCollectorItemExist(TableTempleteSkills[templeteID].DetailInfo.PvrName) == false then
            table.insert(self._tPvrNameCollector, TableTempleteSkills[templeteID].DetailInfo.PvrName)
        end
        -- PVP主角玩家技能攻击特效
        for k,v in pairs(SkillsManager:getInstance()._tPvpRoleMountActvSkills) do
            local skillData = SkillsManager:getInstance():getPvpRoleSkillDataByID(v.id,v.level)
            local templeteID = skillData.TempleteID
            if self:checkPvrNameCollectorItemExist(TableTempleteSkills[templeteID].DetailInfo.PvrName) == false then
                table.insert(self._tPvrNameCollector, TableTempleteSkills[templeteID].DetailInfo.PvrName)
            end
        end
        -- PVP主角玩家怒气技能特效
        if table.getn(SkillsManager:getInstance()._tPvpRoleMountAngerSkills) ~= 0 then
            local skillData = SkillsManager:getInstance():getPvpRoleSkillDataByID(SkillsManager:getInstance()._tPvpRoleMountAngerSkills[1].id, SkillsManager:getInstance()._tPvpRoleMountAngerSkills[1].level)
            local templeteID = skillData.TempleteID
            if self:checkPvrNameCollectorItemExist(TableTempleteSkills[templeteID].DetailInfo.PvrName) == false then
                table.insert(self._tPvrNameCollector, TableTempleteSkills[templeteID].DetailInfo.PvrName)
            end
        end
        ------------------------------------------------------- PVP宠物 ----------------------------------------------------------------------
        -- PVP宠物的模型贴图
        local tPvpPetRoleInfos = PetsManager:getInstance()._tPvpPetRoleInfosInQueue
        for kInfo,vInfo in pairs(tPvpPetRoleInfos) do 
            local templeteInfo = TableTempletePets[TablePets[vInfo.petId].TempleteID[vInfo.step]]
            local texturePvrName = templeteInfo.Texture
            if self:checkPvrNameCollectorItemExist(texturePvrName) == false then
                table.insert(self._tPvrNameCollector, texturePvrName)
            end
        end
        
    end
   
    ------------------------------------------------------------- 野怪 ----------------------------------------------------------------------
    -- 野怪的模型贴图   和   野怪普通攻击特效纹理
    local stageMapInfo = StagesManager:getInstance():getCurStageMapInfo()
    local areaIndex = 1
    while stageMapInfo["MonsterArea"..areaIndex] ~= nil do
        for kMonsterWave,vMonsterWave in pairs(stageMapInfo["MonsterArea"..areaIndex]) do
            for kMonster, vMonster in pairs(vMonsterWave) do
                -- 野怪的模型贴图
                local monsterPvrName = TableTempleteMonster[TableMonster[vMonster.monsterID].TempleteID].Texture
                if self:checkPvrNameCollectorItemExist(monsterPvrName) == false then
                    table.insert(self._tPvrNameCollector, monsterPvrName)
                end
                -- 野怪普通攻击特效纹理
                for kSkill,vSkill in pairs(TableMonster[vMonster.monsterID].SkillIDs) do
                    local templeteId = TableMonsterSkills[vSkill].TempleteID
                    if self:checkPvrNameCollectorItemExist(TableTempleteSkills[templeteId].DetailInfo.PvrName) == false then
                        table.insert(self._tPvrNameCollector, TableTempleteSkills[templeteId].DetailInfo.PvrName)
                    end
                end
            end
        end
        areaIndex = areaIndex + 1
    end
    
    ------------------------------------------------------------- 实体 -------------------------------------------------------------------------
    -- 实体的合图（实体资源+攻击特效资源）
    for k, v in pairs(stageMapInfo.EntityIDs) do 
        if self:checkPvrNameCollectorItemExist(TableTempleteEntitys[TableEntitys[v].TempleteID].PvrName) == false then
            table.insert(self._tPvrNameCollector, TableTempleteEntitys[TableEntitys[v].TempleteID].PvrName)
        end
        if TableEntitys[v].SkillID ~= 0 and TableEntitysSkills[TableEntitys[v].SkillID].TempleteID ~= nil then
            if self:checkPvrNameCollectorItemExist(TableTempleteSkills[TableEntitysSkills[TableEntitys[v].SkillID].TempleteID].DetailInfo.PvrName) == false then
                table.insert(self._tPvrNameCollector, TableTempleteSkills[TableEntitysSkills[TableEntitys[v].SkillID].TempleteID].DetailInfo.PvrName)
            end
        end
    end

end

function ResPlistManager:checkPvrNameCollectorItemExist(pvrName)
    local needInsert = true
    for k,v in pairs(self._tPvrNameCollector) do 
        if v == pvrName then
            needInsert = false
        end
    end
    return not needInsert
end
---------------------------------- 加载相关纹理资源名称收集器的资源 --------------------------------
function ResPlistManager:loadPvr()
    for k,v in pairs(self._tPvrNameCollector) do 
        self:addSpriteFrames(v..".plist")
    end
end
---------------------------------- 异步加载相关纹理资源名称收集器的图片资源 --------------------------------
function ResPlistManager:loadPicAsync(callFunc)
    for k,v in pairs(self._tPvrNameCollector) do 
        print("纹理："..v..".pvr.ccz")
        cc.Director:getInstance():getTextureCache():addImageAsync(v..".pvr.ccz", callFunc)  -- 异步加载所有纹理
    end
end
---------------------------------- 清空相关纹理资源名称收集器及卸载资源 --------------------------------
function ResPlistManager:clearPvrName()
    for k, v in pairs(self._tPvrNameCollector) do 
        self:removeSpriteFrames(v..".plist")      -- 释放合图信息和纹理资源
    end
    self._tPvrNameCollector = {}
end

--------------------------------- 添加指定纹理到纹理名称收集器并加载（用于场景运行中的资源加载） ------------------------------------------
function ResPlistManager:addPvrNameToColllectorAndLoadPvr(strPvrName)
    if self:checkPvrNameCollectorItemExist(strPvrName) == false then
        table.insert(self._tPvrNameCollector, strPvrName)
        self:addSpriteFrames(strPvrName..".plist")
    end
end
