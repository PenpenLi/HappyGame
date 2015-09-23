--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TriggersDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   触发器调试层
--===================================================
local TriggersDebugLayer = class("TriggersDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function TriggersDebugLayer:ctor()
    self._pDraw = nil 
    
end

-- 创建函数
function TriggersDebugLayer:create()
    local layer = TriggersDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function TriggersDebugLayer:dispose()   
    self:show()
end

-- 处理函数
function TriggersDebugLayer:show()     

    self:removeAllChildren(true)
    
    self._pDraw = cc.DrawNode:create()
    self:addChild(self._pDraw)
     
    -- 绘制（单次渲染）
    local startP = cc.p(0,0)
    local endP = cc.p(0,0)

    for k,v in pairs(self:getTriggersManager()._tTriggers) do
        if v._bOpened == false and v._bIsVisibleOnDebug == true then
            for kRect, vRect in pairs(v._tRects) do
                startP = cc.p(vRect.x+2, vRect.y+2)
                endP = cc.p(startP.x + vRect.width-4, startP.y + vRect.height-4)
                self._pDraw:drawSolidRect(startP, endP, cc.c4f(0,0,0,0.6)) 
                
                local pLable = cc.Label:createWithTTF(v._strName, strCommonFontName, 18, cc.size(vRect.width, vRect.height), cc.TEXT_ALIGNMENT_LEFT)
                pLable:setAnchorPoint(cc.p(0, 0))
                pLable:setPosition(cc.p(vRect.x, vRect.y))
                --pLable:enableShadow(cc.c4b(0, 0, 0, 255))
                self._pDraw:addChild(pLable)
            end
        end
    end
    
    MapManager:getInstance()._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
    
    return
end

-- 循环更新
function TriggersDebugLayer:update(dt)

end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function TriggersDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function TriggersDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function TriggersDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function TriggersDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function TriggersDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function TriggersDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取技能管理器
function TriggersDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function TriggersDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end
--------------------------------------------------------------------------------------------------------------

return TriggersDebugLayer
