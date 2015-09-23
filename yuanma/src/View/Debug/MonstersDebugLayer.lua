--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonstersDebugLayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   怪物调试层
--===================================================
local MonstersDebugLayer = class("MonstersDebugLayer",function()
    return cc.Layer:create()
end)

-- 构造函数
function MonstersDebugLayer:ctor()
    self._pGLNode = nil
end

-- 创建函数
function MonstersDebugLayer:create()
    local layer = MonstersDebugLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function MonstersDebugLayer:dispose() 
    local tileWidth = self:getMapManager()._sTiledPixelSize.width
    local tileHeight = self:getMapManager()._sTiledPixelSize.height 
    local startP = cc.p(0,0)
    local endP = cc.p(0,0)

    local function onNodeEvent(event)
        if event == "exit" then
            self._pGLNode:removeFromParent()
            self._pGLNode = nil
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    -- 初始化
    --self._pTextMainRolePosIndex  = cc.Label:createWithTTF("", strCommonFontName, 20)
    --self._pTextMainRolePosIndex:setPosition(mmo.VisibleRect:center())
    --self:addChild(self._pTextMainRolePosIndex)
    
    -- 绘制（每次渲染）
    self._pGLNode  = gl.glNodeCreate()
    self._pGLNode:setContentSize(self:getMapManager()._sMapRectPixelSize)
    local function primitivesDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)
        gl.lineWidth(2.0)

        for kMonster, vMonster in pairs(MonstersManager:getInstance()._tCurWaveMonsters) do
            if vMonster._bActive == true then
                local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(vMonster:getPositionX(),vMonster:getPositionY()))
                local posPixels = self:getMapManager():convertIndexToPiexl(posIndex)
                local posStart = cc.p(posPixels.x - tileWidth/2, posPixels.y)
                local posEnd = cc.p(posPixels.x - tileWidth/2 + tileWidth, posPixels.y + tileHeight)  
                cc.DrawPrimitives.drawSolidRect( posStart, posEnd, cc.c4f(1, 0, 1, 0.2))
                -- bottom
                cc.DrawPrimitives.drawColor4B(0, 0, 255, 255)
                local recBottom = vMonster:getBottomRectInMap()
                local posStart = cc.p(recBottom.x, recBottom.y)
                local posEnd = cc.p(recBottom.x + recBottom.width, recBottom.y + recBottom.height)        
                cc.DrawPrimitives.drawRect(posStart, posEnd)
                -- body
                cc.DrawPrimitives.drawColor4B(0, 255, 0, 255)
                local recBody = vMonster:getBodyRectInMap()
                posStart = cc.p(recBody.x, recBody.y)
                posEnd = cc.p(recBody.x + recBody.width, recBody.y + recBody.height)   
                cc.DrawPrimitives.drawRect(posStart, posEnd)
                -- height
                cc.DrawPrimitives.drawColor4B(216, 36, 235, 255)
                local height = vMonster:getHeight()
                posStart = cc.p(vMonster:getPositionX()-2, vMonster:getPositionY())
                posEnd = cc.p(vMonster:getPositionX()+2, vMonster:getPositionY()+height)   
                cc.DrawPrimitives.drawRect(posStart, posEnd)
            end
        end

        kmGLPopMatrix()
    end

    self._pGLNode:registerScriptDrawHandler(primitivesDraw)
    self:addChild(self._pGLNode,-10)
    
    return
end

-- 循环更新
function MonstersDebugLayer:update(dt)
    --local pMainRole = self:getRolesManager()._pMainPlayerRole
    --local posIndex = self:getMapManager():convertPiexlToIndex(cc.p(pMainRole:getPositionX(), pMainRole:getPositionY()))
    --self._pTextMainRolePosIndex:setString("Row = "..(math.modf(posIndex.y)).." Col = "..(math.modf(posIndex.x)))
    --self._pTextMainRolePosIndex:setPosition(cc.p(pMainRole:getPositionX(), pMainRole:getPositionY() - self._pTextMainRolePosIndex:getContentSize().height))
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function MonstersDebugLayer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function MonstersDebugLayer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function MonstersDebugLayer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function MonstersDebugLayer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function MonstersDebugLayer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function MonstersDebugLayer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取技能管理器
function MonstersDebugLayer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function MonstersDebugLayer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end
--------------------------------------------------------------------------------------------------------------

return MonstersDebugLayer
