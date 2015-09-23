--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SkillsDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/8
-- descrip:   技能调试层
--===================================================
local SkillsDebugLayer = class("SkillsDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function SkillsDebugLayer:ctor()

end

-- 创建函数
function SkillsDebugLayer:create()
    local layer = SkillsDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function SkillsDebugLayer:dispose()   
    -- 绘制（单次渲染）
    local draw = cc.DrawNode:create()
    self:addChild(draw)    
    
    -- 绘制（每次渲染）
    local glNode  = gl.glNodeCreate()
    glNode:setContentSize(self:getMapManager()._sMapRectPixelSize)
    local function primitivesDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)
        gl.lineWidth(2.0)

        -- 主角技能集合
        local skills = self:getSkillsManager()._tMainRoleSkills
        for k, v in pairs(skills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                for mk,mv in pairs(v._tCurAttackRects) do
                    local rect = mv
                    cc.DrawPrimitives.drawSolidRect( cc.p(rect.x, rect.y), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1, 0, 0, 0.35))                
                end
            end 
        end
        
        -- 主角宠物技能集合
        local skills = self:getSkillsManager()._tCurMainPetRoleSkills
        for k, v in pairs(skills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                for mk,mv in pairs(v._tCurAttackRects) do
                    local rect = mv
                    cc.DrawPrimitives.drawSolidRect( cc.p(rect.x, rect.y), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1, 0, 0, 0.35))                
                end
            end 
        end
        
        -- PVP技能集合
        local skills = self:getSkillsManager()._tPvpRoleSkills
        for k, v in pairs(skills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                for mk,mv in pairs(v._tCurAttackRects) do
                    local rect = mv
                    cc.DrawPrimitives.drawSolidRect( cc.p(rect.x, rect.y), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1, 0, 0, 0.35))                
                end
            end 
        end
        
        -- PVP宠物技能集合
        local skills = self:getSkillsManager()._tCurPvpPetRoleSkills
        for k, v in pairs(skills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                for mk,mv in pairs(v._tCurAttackRects) do
                    local rect = mv
                    cc.DrawPrimitives.drawSolidRect( cc.p(rect.x, rect.y), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1, 0, 0, 0.35))                
                end
            end 
        end
        
        -- 野怪技能集合        
        local nCurMonsterAreaIndex = self:getMonstersManager()._nCurMonsterAreaIndex
        local nCurMonsterWaveIndex = self:getMonstersManager()._nCurMonsterWaveIndex
        if nCurMonsterAreaIndex ~= 0 and nCurMonsterWaveIndex~= 0 then
            local skills = self:getSkillsManager()._tMonstersSkills[nCurMonsterAreaIndex][nCurMonsterWaveIndex]
            for k, v in pairs(skills) do
                if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                    for mk,mv in pairs(v._tCurAttackRects) do
                        local rect = mv
                        cc.DrawPrimitives.drawSolidRect( cc.p(rect.x, rect.y), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1, 0, 0, 0.35))                
                    end
                end 
            end
        end

        -- 实体技能集合
        local skills = self:getSkillsManager()._tEntitysSkills
        for k, v in pairs(skills) do
            if v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID ~= kType.kState.kBattleSkill.kIdle then
                for mk,mv in pairs(v._tCurAttackRects) do
                    local rect = mv
                    cc.DrawPrimitives.drawSolidRect( cc.p(rect.x, rect.y), cc.p(rect.x+rect.width, rect.y+rect.height), cc.c4f(1, 0, 0, 0.35))                
                end
            end 
        end

        kmGLPopMatrix()
    end

    glNode:registerScriptDrawHandler(primitivesDraw)
    self:addChild(glNode,-10)

    return
end

-- 循环更新
function SkillsDebugLayer:update(dt)

end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function SkillsDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function SkillsDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function SkillsDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function SkillsDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function SkillsDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function SkillsDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取技能管理器
function SkillsDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function SkillsDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end
--------------------------------------------------------------------------------------------------------------

return SkillsDebugLayer
