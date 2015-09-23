--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RectsDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   矩形调试层
--===================================================
local RectsDebugLayer = class("RectsDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function RectsDebugLayer:ctor()
    self._pDraw = nil 
    
end

-- 创建函数
function RectsDebugLayer:create()
    local layer = RectsDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function RectsDebugLayer:dispose()   

    self:show()
    
    return
end

-- 循环更新
function RectsDebugLayer:show()
    -- 绘制（单次渲染）
    if self._pDraw then
        self:removeChild(self._pDraw, true)
    end
    
    self._pDraw = cc.DrawNode:create()
    self:addChild(self._pDraw)
    
    for index = 1, nMapAreaColNum*nMapAreaRowNum do 
        local tBottomRects = self:getRectsManager():getBottomRectsByIndex(index)
        for k,v in pairs(tBottomRects) do      
            self._pDraw:drawRect(cc.p(v.x, v.y), cc.p(v.x + v.width,v.y + v.height), cc.c4f(0,0,1,1))    
        end
    end

    for index = 1, nMapAreaColNum*nMapAreaRowNum do 
        local tBodyRects = self:getRectsManager():getBodyRectsByIndex(index)
        for k,v in pairs(tBodyRects) do          
            self._pDraw:drawRect(cc.p(v.x, v.y), cc.p(v.x + v.width,v.y + v.height), cc.c4f(0,1,0,1)) 
        end
    end

    for index = 1, nMapAreaColNum*nMapAreaRowNum do 
        local tUndefRects = self:getRectsManager():geUndefRectsByIndex(index)
        for k,v in pairs(tUndefRects) do          
            self._pDraw:drawRect(cc.p(v.x, v.y), cc.p(v.x + v.width,v.y + v.height), cc.c4f(0,1,1,1)) 
        end
    end
    
    self:getMapManager()._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
    
end

-- 循环更新
function RectsDebugLayer:update(dt)

end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function RectsDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function RectsDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function RectsDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function RectsDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function RectsDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function RectsDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取技能管理器
function RectsDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function RectsDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end
--------------------------------------------------------------------------------------------------------------

return RectsDebugLayer
