--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RolesDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   角色调试层
--===================================================
local RolesDebugLayer = class("RolesDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function RolesDebugLayer:ctor()
    self._pTextMainRolePosIndex = nil           -- 主角位置索引值label
    self._pTextPvpRolePosIndex = nil            -- Pvp对手位置索引值label
end

-- 创建函数
function RolesDebugLayer:create()
    local layer = RolesDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function RolesDebugLayer:dispose() 
    local tileWidth = self:getMapManager()._sTiledPixelSize.width
    local tileHeight = self:getMapManager()._sTiledPixelSize.height 
    local startP = cc.p(0,0)
    local endP = cc.p(0,0)
    
    -- 初始化文字标签
    self._pTextMainRolePosIndex  = cc.Label:createWithTTF("", strCommonFontName, 20)
    self._pTextMainRolePosIndex:setPosition(mmo.VisibleRect:center())
    self:addChild(self._pTextMainRolePosIndex)
    self._pTextPvpRolePosIndex  = cc.Label:createWithTTF("", strCommonFontName, 20)
    self._pTextPvpRolePosIndex:setPosition(mmo.VisibleRect:center())
    self:addChild(self._pTextPvpRolePosIndex)
    
      
    -- 绘制（每次渲染）
    local glNode  = gl.glNodeCreate()
    glNode:setContentSize(self:getMapManager()._sMapRectPixelSize)
    local function primitivesDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)
        gl.lineWidth(2.0)
        
        local pMainRole = self:getRolesManager()._pMainPlayerRole
        if pMainRole then
            local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pMainRole:getPositionX(),pMainRole:getPositionY()))
            local posPixels = self:getMapManager():convertIndexToPiexl(posIndex)
            local posStart = cc.p(posPixels.x - tileWidth/2, posPixels.y)
            local posEnd = cc.p(posPixels.x - tileWidth/2 + tileWidth, posPixels.y + tileHeight)  
            cc.DrawPrimitives.drawSolidRect( posStart, posEnd, cc.c4f(1, 0, 1, 0.2))

            -- bottom
            cc.DrawPrimitives.drawColor4B(0, 0, 255, 255)
            local recBottom = pMainRole:getBottomRectInMap()
            local posStart = cc.p(recBottom.x, recBottom.y)
            local posEnd = cc.p(recBottom.x + recBottom.width, recBottom.y + recBottom.height)        
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- body
            cc.DrawPrimitives.drawColor4B(0, 255, 0, 255)
            local recBody = pMainRole:getBodyRectInMap()
            posStart = cc.p(recBody.x, recBody.y)
            posEnd = cc.p(recBody.x + recBody.width, recBody.y + recBody.height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- height
            cc.DrawPrimitives.drawColor4B(216, 36, 235, 255)
            local height = pMainRole:getHeight()
            posStart = cc.p(pMainRole:getPositionX()-2, pMainRole:getPositionY())
            posEnd = cc.p(pMainRole:getPositionX()+2, pMainRole:getPositionY()+height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            
        end
        
        local pPvpRole = self:getRolesManager()._pPvpPlayerRole
        if pPvpRole then
            local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pPvpRole:getPositionX(),pPvpRole:getPositionY()))
            local posPixels = self:getMapManager():convertIndexToPiexl(posIndex)
            local posStart = cc.p(posPixels.x - tileWidth/2, posPixels.y)
            local posEnd = cc.p(posPixels.x - tileWidth/2 + tileWidth, posPixels.y + tileHeight)  
            cc.DrawPrimitives.drawSolidRect( posStart, posEnd, cc.c4f(1, 0, 1, 0.2))

            -- bottom
            cc.DrawPrimitives.drawColor4B(0, 0, 255, 255)
            local recBottom = pPvpRole:getBottomRectInMap()
            local posStart = cc.p(recBottom.x, recBottom.y)
            local posEnd = cc.p(recBottom.x + recBottom.width, recBottom.y + recBottom.height)        
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- body
            cc.DrawPrimitives.drawColor4B(0, 255, 0, 255)
            local recBody = pPvpRole:getBodyRectInMap()
            posStart = cc.p(recBody.x, recBody.y)
            posEnd = cc.p(recBody.x + recBody.width, recBody.y + recBody.height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- height
            cc.DrawPrimitives.drawColor4B(216, 36, 235, 255)
            local height = pPvpRole:getHeight()
            posStart = cc.p(pPvpRole:getPositionX()-2, pPvpRole:getPositionY())
            posEnd = cc.p(pPvpRole:getPositionX()+2, pPvpRole:getPositionY()+height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
        end
        
        local npc = self:getRolesManager()._tNpcRoles[1]
        if npc then
            -- bottom
            cc.DrawPrimitives.drawColor4B(0, 0, 255, 255)
            local recBottom = npc:getBottomRectInMap()
            local posStart = cc.p(recBottom.x, recBottom.y)
            local posEnd = cc.p(recBottom.x + recBottom.width, recBottom.y + recBottom.height)        
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- body
            cc.DrawPrimitives.drawColor4B(0, 255, 0, 255)
            local recBody = npc:getBodyRectInMap()
            posStart = cc.p(recBody.x, recBody.y)
            posEnd = cc.p(recBody.x + recBody.width, recBody.y + recBody.height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- height
            cc.DrawPrimitives.drawColor4B(216, 36, 235, 255)
            local height = npc:getHeight()
            posStart = cc.p(npc:getPositionX()-2, npc:getPositionY())
            posEnd = cc.p(npc:getPositionX()+2, npc:getPositionY()+height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
        end

        kmGLPopMatrix()
    end

    glNode:registerScriptDrawHandler(primitivesDraw)
    self:addChild(glNode,-10)
    
    return
end

-- 循环更新
function RolesDebugLayer:update(dt)
    local pMainRole = self:getRolesManager()._pMainPlayerRole
    if pMainRole then
        local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pMainRole:getPositionX(), pMainRole:getPositionY()))
        self._pTextMainRolePosIndex:setVisible(true)
        self._pTextMainRolePosIndex:setString("Row = "..(math.modf(posIndex.y)).." Col = "..(math.modf(posIndex.x)))
        self._pTextMainRolePosIndex:setPosition(cc.p(pMainRole:getPositionX(), pMainRole:getPositionY() - self._pTextMainRolePosIndex:getContentSize().height))
    else
        self._pTextMainRolePosIndex:setVisible(false)
    end
    
    local pPvpRole = self:getRolesManager()._pPvpPlayerRole
    if pPvpRole then
        local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pPvpRole:getPositionX(), pPvpRole:getPositionY()))
        self._pTextPvpRolePosIndex:setVisible(true)
        self._pTextPvpRolePosIndex:setString("Row = "..(math.modf(posIndex.y)).." Col = "..(math.modf(posIndex.x)))
        self._pTextPvpRolePosIndex:setPosition(cc.p(pPvpRole:getPositionX(), pPvpRole:getPositionY() - self._pTextPvpRolePosIndex:getContentSize().height))
    else
        self._pTextPvpRolePosIndex:setVisible(false)
    end
    
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function RolesDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function RolesDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function RolesDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function RolesDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function RolesDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function RolesDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取技能管理器
function RolesDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function RolesDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end
--------------------------------------------------------------------------------------------------------------

return RolesDebugLayer
