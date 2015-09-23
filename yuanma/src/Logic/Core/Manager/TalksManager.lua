--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TalksManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/6
-- descrip:   剧情对话管理器
--===================================================
TalksManager = {}

local instance = nil

-- 单例
function TalksManager:getInstance()
    if not instance then
        instance = TalksManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function TalksManager:clearCache()    
    self._nCurTalksID = 0       -- 当前对话内容信息在对话表中的ID
    self._tCurContents = {}     -- 当前对话内容信息集合
    self._nCurTalkStep = 0      -- 当前对话内容信息中的步数
    
end

-- 循环处理
function TalksManager:update(dt)
    if self:isCurTalksFinished() == false then
        -- 强制设置所有角色positionZ到最小值
        MonstersManager:getInstance():setForceMinPositionZ(true,-10000)
        RolesManager:getInstance():setForceMinPositionZ(true,-10000)
        PetsManager:getInstance():setForceMinPositionZ(true,-10000)
    end  
end

-- 激活对话（入口）（由触发器调用）
function TalksManager:setCurTalks(talkID)
    self._nCurTalksID = talkID
    self._tCurContents = TableTalks[self._nCurTalksID].Contents
    self._nCurTalkStep = 0
    
    -- 强制设置所有角色positionZ到最小值
    MonstersManager:getInstance():setForceMinPositionZ(true,-10000)
    RolesManager:getInstance():setForceMinPositionZ(true,-10000)
    PetsManager:getInstance():setForceMinPositionZ(true,-10000)
    
    local pUILayer = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")   
        pUILayer:setAllUIVisible(false)
        -- 摇杆禁用
        pUILayer._pStick:setIsWorking(false)
        pUILayer._pStick:hide()
        -- 角色恢复到默认站立状态
        RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand)
        
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        BattleManager:getInstance():pauseTime() -- 战斗时间暂停
        pUILayer:setAllUIVisible(false)
        -- 摇杆禁用
        pUILayer._pStick:setIsWorking(false)
        pUILayer._pStick:hide()
        -- 角色恢复到默认站立状态
        if RolesManager:getInstance()._pMainPlayerRole:isUnusualState() == true then     -- 非正常状态
            RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
        end
        
    end
    pUILayer:removeCurTalkHeaders()
    pUILayer:createTalkHeaders(talkID)
    
    pUILayer:showCurTalks()

end

-- 设置对话结束（由UI层调用）
function TalksManager:setCurTalksFinished()
    self._nCurTalksID = 0
    self._tCurContents = {}
    self._nCurTalkStep = 0
    
    -- 恢复设置所有角色positionZ到最小值
    MonstersManager:getInstance():setForceMinPositionZ(false)
    RolesManager:getInstance():setForceMinPositionZ(false)
    PetsManager:getInstance():setForceMinPositionZ(false)
    
    local pUILayer = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")   
        pUILayer:setAllUIVisible(true)     
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
        pUILayer:setAllUIVisible(true)
        if pUILayer._pTimeNode:isVisible() == true then
            BattleManager:getInstance():resumeTime()    -- 战斗时间继续
        end
    end
    pUILayer:removeCurTalkHeaders()

end

-- 当前对话是否已经显示结束
function TalksManager:isCurTalksFinished()    
    if self._nCurTalksID == 0 then
        return true
    end
    return false
end

-- 当前对话是否正在显示
function TalksManager:isShowingTalks()
    local pUILayer = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")        
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        pUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
    end
    return pUILayer._pTalkFrame:isVisible()
end

