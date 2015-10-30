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
    table.insert(self._tPvrNameCollector, "CoverLoginBg")
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
    
    -- 技能图标资源  按职业区分  
    local nCareer = RolesManager:getInstance()._pMainRoleInfo.roleCareer
    local temp = {"warrior_skill_icon","mage_skill_icon","thug_skill_icon"}
    table.insert(self._tPvrNameCollector, temp[nCareer])
    
end

----------------------------------- 战斗相关纹理资源名称收集器 ------------------------------------------
function ResPlistManager:collectPvrNameForBattle()

    -- 战斗通用动画纹理
    table.insert(self._tPvrNameCollector, "battle_common_anis")

    -- 战斗技能按钮相关纹理
    table.insert(self._tPvrNameCollector, "battle_main_skill_ui")
    
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
    
    -- 好友出场特效
    if FriendManager:getInstance()._nMountFriendSkill then
        table.insert(self._tPvrNameCollector, "FriendStart")
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
