--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MapDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   地图调试层
--===================================================
local MapDebugLayer = class("MapDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function MapDebugLayer:ctor()

end

-- 创建函数
function MapDebugLayer:create()
    local layer = MapDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function MapDebugLayer:dispose()   
    -- 绘制（单次渲染）
    local mapSizeWidth = self:getMapManager()._sMapIndexSize.width
    local mapSizeHeight = self:getMapManager()._sMapIndexSize.height
    local tileWidth = self:getMapManager()._sTiledPixelSize.width
    local tileHeight = self:getMapManager()._sTiledPixelSize.height 
    local mapSize = self:getMapManager()._sMapRectPixelSize
    local startP = cc.p(0,0)
    local endP = cc.p(0,0)

    local draw = cc.DrawNode:create()
    self:addChild(draw)

    -- 画格子
    for row = 1, mapSizeHeight do
        startP = cc.p(0, row*tileHeight)
        endP = cc.p(mapSize.width, row*tileHeight)
        draw:drawLine(startP, endP, cc.c4f(0,1,0,0.3))
    end

    for col = 1, mapSizeWidth do
        startP = cc.p(col*tileWidth, mapSize.height)
        endP = cc.p(col*tileWidth, 0)
        draw:drawLine(startP, endP, cc.c4f(0,1,0,0.3))
    end

    -- 划分块区域
    for row = 0, nMapAreaRowNum do
        startP = cc.p(0, row*(mapSize.height / nMapAreaRowNum))
        endP = cc.p(mapSize.width, row*(mapSize.height / nMapAreaRowNum))
        draw:drawLine(startP, endP, cc.c4f(1,1,0,1))
    end

    for col = 0, nMapAreaColNum do
        startP = cc.p(col * (mapSize.width / nMapAreaColNum), 0)
        endP = cc.p(col * (mapSize.width / nMapAreaColNum), mapSize.height)
        draw:drawLine(startP, endP, cc.c4f(1,1,0,1))
    end

    return
end

-- 循环更新
function MapDebugLayer:update(dt)

end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function MapDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function MapDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function MapDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function MapDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function MapDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function MapDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取技能管理器
function MapDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function MapDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end
--------------------------------------------------------------------------------------------------------------

return MapDebugLayer
