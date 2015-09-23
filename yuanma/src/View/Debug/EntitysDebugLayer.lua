--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EntitysDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   实体调试层
--===================================================
local EntitysDebugLayer = class("EntitysDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function EntitysDebugLayer:ctor()

end

-- 创建函数
function EntitysDebugLayer:create()
    local layer = EntitysDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function EntitysDebugLayer:dispose()   
    -- 绘制（单次渲染）
    local draw = cc.DrawNode:create()
    self:addChild(draw)
    
    --[[
    local entitys = self:getEntitysManager()._tEntitys
    for k,v in pairs(entitys) do 
        local x, y = v:getPosition()
        local posStart = cc.p(x - 10, y - 10)
        local posEnd = cc.p(x + 10, y + 10)
        draw:drawRect(posStart, posEnd, cc.c4f(0,0,1,1))
    end
    ]]

    
    return
end

-- 循环更新
function EntitysDebugLayer:update(dt)

end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function EntitysDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function EntitysDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function EntitysDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function EntitysDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function EntitysDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function EntitysDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取技能管理器
function EntitysDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function EntitysDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

--------------------------------------------------------------------------------------------------------------

return EntitysDebugLayer
