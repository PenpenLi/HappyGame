--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetsDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/4/24
-- descrip:   宠物角色调试层
--===================================================
local PetsDebugLayer = class("PetsDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function PetsDebugLayer:ctor()
    self._pTextMainPetRolePosIndex = nil           -- 主角宠物位置索引值label
    self._pTextPvpPetRolePosIndex = nil            -- Pvp对手宠物位置索引值label
end

-- 创建函数
function PetsDebugLayer:create()
    local layer = PetsDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function PetsDebugLayer:dispose() 
    local tileWidth = self:getMapManager()._sTiledPixelSize.width
    local tileHeight = self:getMapManager()._sTiledPixelSize.height 
    local startP = cc.p(0,0)
    local endP = cc.p(0,0)
    
    -- 初始化文字标签
    self._pTextMainPetRolePosIndex  = cc.Label:createWithTTF("", strCommonFontName, 20)
    self._pTextMainPetRolePosIndex:setPosition(mmo.VisibleRect:center())
    self:addChild(self._pTextMainPetRolePosIndex)
    self._pTextPvpPetRolePosIndex  = cc.Label:createWithTTF("", strCommonFontName, 20)
    self._pTextPvpPetRolePosIndex:setPosition(mmo.VisibleRect:center())
    self:addChild(self._pTextPvpPetRolePosIndex)
    
      
    -- 绘制（每次渲染）
    local glNode  = gl.glNodeCreate()
    glNode:setContentSize(self:getMapManager()._sMapRectPixelSize)
    local function primitivesDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)
        gl.lineWidth(2.0)
        
        local pMainPetRole = self:getPetsManager()._pMainPetRole
        if pMainPetRole then
            local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pMainPetRole:getPositionX(),pMainPetRole:getPositionY()))
            local posPixels = self:getMapManager():convertIndexToPiexl(posIndex)
            local posStart = cc.p(posPixels.x - tileWidth/2, posPixels.y)
            local posEnd = cc.p(posPixels.x - tileWidth/2 + tileWidth, posPixels.y + tileHeight)  
            cc.DrawPrimitives.drawSolidRect( posStart, posEnd, cc.c4f(1, 0, 1, 0.2))

            -- bottom
            cc.DrawPrimitives.drawColor4B(0, 0, 255, 255)
            local recBottom = pMainPetRole:getBottomRectInMap()
            local posStart = cc.p(recBottom.x, recBottom.y)
            local posEnd = cc.p(recBottom.x + recBottom.width, recBottom.y + recBottom.height)        
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- body
            cc.DrawPrimitives.drawColor4B(0, 255, 0, 255)
            local recBody = pMainPetRole:getBodyRectInMap()
            posStart = cc.p(recBody.x, recBody.y)
            posEnd = cc.p(recBody.x + recBody.width, recBody.y + recBody.height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- height
            cc.DrawPrimitives.drawColor4B(216, 36, 235, 255)
            local height = pMainPetRole:getHeight()
            posStart = cc.p(pMainPetRole:getPositionX()-2, pMainPetRole:getPositionY())
            posEnd = cc.p(pMainPetRole:getPositionX()+2, pMainPetRole:getPositionY()+height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
        end
        
        local pPvpPetRole = self:getPetsManager()._pPvpPetRole
        if pPvpPetRole then
            local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pPvpPetRole:getPositionX(),pPvpPetRole:getPositionY()))
            local posPixels = self:getMapManager():convertIndexToPiexl(posIndex)
            local posStart = cc.p(posPixels.x - tileWidth/2, posPixels.y)
            local posEnd = cc.p(posPixels.x - tileWidth/2 + tileWidth, posPixels.y + tileHeight)  
            cc.DrawPrimitives.drawSolidRect( posStart, posEnd, cc.c4f(1, 0, 1, 0.2))

            -- bottom
            cc.DrawPrimitives.drawColor4B(0, 0, 255, 255)
            local recBottom = pPvpPetRole:getBottomRectInMap()
            local posStart = cc.p(recBottom.x, recBottom.y)
            local posEnd = cc.p(recBottom.x + recBottom.width, recBottom.y + recBottom.height)        
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- body
            cc.DrawPrimitives.drawColor4B(0, 255, 0, 255)
            local recBody = pPvpPetRole:getBodyRectInMap()
            posStart = cc.p(recBody.x, recBody.y)
            posEnd = cc.p(recBody.x + recBody.width, recBody.y + recBody.height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
            -- height
            cc.DrawPrimitives.drawColor4B(216, 36, 235, 255)
            local height = pPvpPetRole:getHeight()
            posStart = cc.p(pPvpPetRole:getPositionX()-2, pPvpPetRole:getPositionY())
            posEnd = cc.p(pPvpPetRole:getPositionX()+2, pPvpPetRole:getPositionY()+height)   
            cc.DrawPrimitives.drawRect(posStart, posEnd)
        end

        kmGLPopMatrix()
    end

    glNode:registerScriptDrawHandler(primitivesDraw)
    self:addChild(glNode,-10)
    
    return
end

-- 循环更新
function PetsDebugLayer:update(dt)
    local pMainPetRole = self:getPetsManager()._pMainPetRole
    if pMainPetRole then
        local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pMainPetRole:getPositionX(), pMainPetRole:getPositionY()))
        self._pTextMainPetRolePosIndex:setVisible(true)
        self._pTextMainPetRolePosIndex:setString("Row = "..(math.modf(posIndex.y)).." Col = "..(math.modf(posIndex.x)))
        self._pTextMainPetRolePosIndex:setPosition(cc.p(pMainPetRole:getPositionX(), pMainPetRole:getPositionY() - self._pTextMainPetRolePosIndex:getContentSize().height))
    else
        self._pTextMainPetRolePosIndex:setVisible(false)
    end
    
    local pPvpPetRole = self:getPetsManager()._pPvpPetRole
    if pPvpPetRole then
        local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pPvpPetRole:getPositionX(), pPvpPetRole:getPositionY()))
        self._pTextPvpPetRolePosIndex:setVisible(true)
        self._pTextPvpPetRolePosIndex:setString("Row = "..(math.modf(posIndex.y)).." Col = "..(math.modf(posIndex.x)))
        self._pTextPvpPetRolePosIndex:setPosition(cc.p(pPvpPetRole:getPositionX(), pPvpPetRole:getPositionY() - self._pTextPvpPetRolePosIndex:getContentSize().height))
    else
        self._pTextPvpPetRolePosIndex:setVisible(false)
    end
    
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function PetsDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function PetsDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function PetsDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function PetsDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function PetsDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function PetsDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物管理器
function PetsDebugLayer:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function PetsDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function PetsDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end
--------------------------------------------------------------------------------------------------------------

return PetsDebugLayer
