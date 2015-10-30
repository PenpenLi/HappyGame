--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RectsManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   矩形管理器
--===================================================
RectsManager = {}

local instance = nil

-- 单例
function RectsManager:getInstance()
    if not instance then
        instance = RectsManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function RectsManager:clearCache()
    self._pDebugLayer = nil                     -- 矩形调试层
    self._ttBottomRects = {}                    -- 底座碰撞矩形（分区域存放）(相当于二维数组)
    self._ttBodyRects = {}                      -- 身体碰撞矩形（分区域存放）(相当于二维数组)
    self._ttUndefRects = {}                     -- 非定义型碰撞矩形（分区域存放）(相当于二维数组)
    for i = 1, (nMapAreaRowNum * nMapAreaColNum) do
        table.insert(self._ttBottomRects,{})
        table.insert(self._ttBodyRects,{})
        table.insert(self._ttUndefRects,{})
    end
    self._pHelper = mmo.RectsHelper:getInst()
    self._pHelper:clearCache(nMapAreaRowNum, nMapAreaColNum) -- 清空c++中的缓存

end

-- 循环处理
function RectsManager:update(dt)
    -- 调试层
    if self._pDebugLayer ~= nil then
        self._pDebugLayer:update(dt)
    end
end

-- 根据地图的分区id获取对应区域的bottom矩形
function RectsManager:getBottomRectsByIndex(index)
    return self._ttBottomRects[index]
end

-- 根据地图的分区id获取对应区域的body矩形
function RectsManager:getBodyRectsByIndex(index)
    return self._ttBodyRects[index]
end

-- 根据地图的分区id获取对应区域的undefRect矩形
function RectsManager:geUndefRectsByIndex(index)
    return self._ttUndefRects[index]
end

-- 创建地图上的所有矩形
function RectsManager:createRectsOnMap(bDebug)
    local pTmxMap = MapManager:getInstance()._pTmxMap

    local pEntitysBottomLayer = pTmxMap:getObjectGroup("EntitysBottomLayer")
    local pEntitysBodyLayer = pTmxMap:getObjectGroup("EntitysBodyLayer")
    local pEntitysUndefLayer = pTmxMap:getObjectGroup("EntitysUndefLayer")
    local pRectsBottomLayer = pTmxMap:getObjectGroup("RectsBottomLayer")
    local pRectsBodyLayer = pTmxMap:getObjectGroup("RectsBodyLayer")
    local pRectsUndefLayer = pTmxMap:getObjectGroup("RectsUndefLayer")

    --------------------实体bottom矩形----------------------------------
    local entityBottomRects = pEntitysBottomLayer:getObjects()
    for k,v in pairs(entityBottomRects) do
        -- 给矩形分区
        local rectBottom = cc.rect(v.x, v.y, v.width, v.height)

        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x, rectBottom.y))
        if index1 ~= 0 then
            table.insert(self._ttBottomRects[index1],rectBottom)
	        self._pHelper:insertBottomRect(index1, rectBottom)
        end
        
        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x + rectBottom.width, rectBottom.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(self._ttBottomRects[index2],rectBottom)
	        self._pHelper:insertBottomRect(index2, rectBottom)
        end
        
        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x, rectBottom.y + rectBottom.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(self._ttBottomRects[index3],rectBottom)
	        self._pHelper:insertBottomRect(index3, rectBottom)
        end
        
        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x + rectBottom.width, rectBottom.y + rectBottom.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(self._ttBottomRects[index4],rectBottom)
	        self._pHelper:insertBottomRect(index4, rectBottom)
        end

        -- 检测例子特效动画
        if v["Particle"] ~= nil then
            MapManager:getInstance():createParticle(v["Particle"],v.x,v.y)
        end
        -- 检测序列帧动画
        if v["Ani"] ~= nil then
            MapManager:getInstance():createAni2D(v["Ani"],v.x,v.y)
        end
        
    end
    --------------------实体body矩形----------------------------------
    local entityBodyRects = pEntitysBodyLayer:getObjects()
    for k,v in pairs(entityBodyRects) do
        -- 给矩形分区
        local rectBody = cc.rect(v.x, v.y, v.width, v.height)

        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x, rectBody.y))
        if index1 ~= 0 then
            table.insert(self._ttBodyRects[index1],rectBody)
	        self._pHelper:insertBodyRect(index1, rectBody)
        end
        
        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x + rectBody.width, rectBody.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(self._ttBodyRects[index2],rectBody)
	        self._pHelper:insertBodyRect(index2, rectBody)
        end
        
        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x, rectBody.y + rectBody.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(self._ttBodyRects[index3],rectBody)
	        self._pHelper:insertBodyRect(index3, rectBody)
        end
        
        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x + rectBody.width, rectBody.y + rectBody.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(self._ttBodyRects[index4],rectBody)
	        self._pHelper:insertBodyRect(index4, rectBody)
        end
        
        -- 检测例子特效动画
        if v["Particle"] ~= nil then
            MapManager:getInstance():createParticle(v["Particle"],v.x,v.y)
        end
        -- 检测序列帧动画
        if v["Ani"] ~= nil then
            MapManager:getInstance():createAni2D(v["Ani"],v.x,v.y)
        end

    end
    --------------------实体undef矩形----------------------------------
    local entityUndefRects = pEntitysUndefLayer:getObjects()
    for k,v in pairs(entityUndefRects) do
        -- 给矩形分区
        local rectUndef = cc.rect(v.x, v.y, v.width, v.height)

        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x, rectUndef.y))
        if index1 ~= 0 then
            table.insert(self._ttUndefRects[index1],rectUndef)
            self._pHelper:insertUndefRect(index1, rectUndef)
        end

        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x + rectUndef.width, rectUndef.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(self._ttUndefRects[index2],rectUndef)
            self._pHelper:insertUndefRect(index2, rectUndef)
        end

        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x, rectUndef.y + rectUndef.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(self._ttUndefRects[index3],rectUndef)
            self._pHelper:insertUndefRect(index3, rectUndef)
        end

        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x + rectUndef.width, rectUndef.y + rectUndef.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(self._ttUndefRects[index4],rectUndef)
            self._pHelper:insertUndefRect(index4, rectUndef)
        end

        -- 检测例子特效动画
        if v["Particle"] ~= nil then
            MapManager:getInstance():createParticle(v["Particle"],v.x,v.y)
        end
        -- 检测序列帧动画
        if v["Ani"] ~= nil then
            MapManager:getInstance():createAni2D(v["Ani"],v.x,v.y)
        end

    end
    --------------------Rects bottom矩形----------------------------------
    local rectsBottomRects = pRectsBottomLayer:getObjects()
    for k,v in pairs(rectsBottomRects) do
        -- 给矩形分区
        local rectBottom = cc.rect(v.x, v.y, v.width, v.height)

        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x, rectBottom.y))
        if index1 ~= 0 then
            table.insert(self._ttBottomRects[index1],rectBottom)
	        self._pHelper:insertBottomRect(index1, rectBottom)
        end
        
        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x + rectBottom.width, rectBottom.y))

        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(self._ttBottomRects[index2],rectBottom)
	        self._pHelper:insertBottomRect(index2, rectBottom)
        end
        
        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x, rectBottom.y + rectBottom.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(self._ttBottomRects[index3],rectBottom)
	        self._pHelper:insertBottomRect(index3, rectBottom)
        end
        
        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBottom.x + rectBottom.width, rectBottom.y + rectBottom.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(self._ttBottomRects[index4],rectBottom)
	        self._pHelper:insertBottomRect(index4, rectBottom)
        end

        -- 检测例子特效动画
        if v["Particle"] ~= nil then
            MapManager:getInstance():createParticle(v["Particle"],v.x,v.y)
        end
        -- 检测序列帧动画
        if v["Ani"] ~= nil then
            MapManager:getInstance():createAni2D(v["Ani"],v.x,v.y)
        end

    end
    --------------------Rects body矩形----------------------------------
    local rectsBodyRects = pRectsBodyLayer:getObjects()
    for k,v in pairs(rectsBodyRects) do
        -- 给矩形分区
        local rectBody = cc.rect(v.x, v.y, v.width, v.height)

        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x, rectBody.y))
        if index1 ~= 0 then
            table.insert(self._ttBodyRects[index1],rectBody)
	        self._pHelper:insertBodyRect(index1, rectBody)
        end
        
        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x + rectBody.width, rectBody.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(self._ttBodyRects[index2],rectBody)
	        self._pHelper:insertBodyRect(index2, rectBody)
        end
        
        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x, rectBody.y + rectBody.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(self._ttBodyRects[index3],rectBody)
	        self._pHelper:insertBodyRect(index3, rectBody)
        end
        
        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectBody.x + rectBody.width, rectBody.y + rectBody.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(self._ttBodyRects[index4],rectBody)
	        self._pHelper:insertBodyRect(index4, rectBody)
        end

        -- 检测例子特效动画
        if v["Particle"] ~= nil then
            MapManager:getInstance():createParticle(v["Particle"],v.x,v.y)
        end
        -- 检测序列帧动画
        if v["Ani"] ~= nil then
            MapManager:getInstance():createAni2D(v["Ani"],v.x,v.y)
        end

    end
    
    --------------------UndefRects 矩形--------------------------------
    local rectsUndefRects = pRectsUndefLayer:getObjects()
    for k,v in pairs(rectsUndefRects) do
        -- 给矩形分区
        local rectUndef = cc.rect(v.x, v.y, v.width, v.height)

        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x, rectUndef.y))
        if index1 ~= 0 then
            table.insert(self._ttUndefRects[index1],rectUndef)
	        self._pHelper:insertUndefRect(index1, rectUndef)
        end
        
        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x + rectUndef.width, rectUndef.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(self._ttUndefRects[index2],rectUndef)
	        self._pHelper:insertUndefRect(index2, rectUndef)
        end
        
        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x, rectUndef.y + rectUndef.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(self._ttUndefRects[index3],rectUndef)
	        self._pHelper:insertUndefRect(index3, rectUndef)
        end
        
        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(rectUndef.x + rectUndef.width, rectUndef.y + rectUndef.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(self._ttUndefRects[index4],rectUndef)
	        self._pHelper:insertUndefRect(index4, rectUndef)
        end

        -- 检测例子特效动画
        if v["Particle"] ~= nil then
            MapManager:getInstance():createParticle(v["Particle"],v.x,v.y)
        end
        -- 检测序列帧动画
        if v["Ani"] ~= nil then
            MapManager:getInstance():createAni2D(v["Ani"],v.x,v.y)
        end
    end    
    
    if bDebug == true then
        self._pDebugLayer = require("RectsDebugLayer"):create()
        MapManager:getInstance()._pTmxMap:addChild(self._pDebugLayer, kZorder.kRectDebugLayer)
    end
end

-- 判断指定地图上的pos是否与bottomRects发生了碰撞
function RectsManager:isPointInBottomRects(pos)
    local areaIndex = MapManager:getInstance():getMapAreaIndexByPos(pos)
    if areaIndex <= 0 or 
       areaIndex > nMapAreaRowNum * nMapAreaColNum or 
       pos.x <= 0 or 
       pos.x >= MapManager:getInstance()._sMapRectPixelSize.width or
       pos.y <= 0 or 
       pos.y >= MapManager:getInstance()._sMapRectPixelSize.height then
        return true
    else
        for k, v in pairs(self._ttBottomRects[areaIndex]) do
            if cc.rectContainsPoint(v,pos) then
                return true
            end
        end
    end
    return false
end

-- 判断指定地图上的矩形是否与bottomRects发生了碰撞
function RectsManager:isRectIntersectBottomRects(rect)

    local rectPoints = {}
    table.insert(rectPoints,cc.p(rect.x, rect.y + rect.height))
    table.insert(rectPoints,cc.p(rect.x, rect.y))
    table.insert(rectPoints,cc.p(rect.x + rect.width, rect.y + rect.height))
    table.insert(rectPoints,cc.p(rect.x + rect.width, rect.y))
    
    -- 任何一个点不在有效范围内都会直接返回true
    for kPos,vPos in pairs(rectPoints) do
        if vPos.x <= 0 or vPos.x >= MapManager:getInstance()._sMapRectPixelSize.width or
           vPos.y <= 0 or vPos.y >= MapManager:getInstance()._sMapRectPixelSize.height then
            return true
        end
    end
    
    local areaIndexs = {}
    
    for kPos,vPos in pairs(rectPoints) do
        local areaIndex = MapManager:getInstance():getMapAreaIndexByPos(vPos)
        local bExist = false
        for k,v in pairs(areaIndexs) do
            if v == areaIndex then
                bExist = true
                break
            end
        end
        if bExist == false then
            table.insert(areaIndexs,areaIndex)
        end
    end
    
    for kArea, vArea in pairs(areaIndexs) do 
        for kRect, vRect in pairs(self._ttBottomRects[vArea]) do
            if cc.rectIntersectsRect(vRect,rect) == true then
                return true
            end
        end
    end
    
    return false
end

-- 插入指定信息的矩形到集合中
-- 参数1：矩形集合
-- 参数2：矩形集合的类别,1：Bottom   2：Body   3：Undef
function RectsManager:insertRectsByRects(rects, type)
    -- 匹配选型    
    local totalRects = nil
    if type == 1 then
        totalRects = self._ttBottomRects
    elseif type == 2 then
        totalRects = self._ttBodyRects
    elseif type == 3 then
        totalRects = self._ttUndefRects
    end

    for kRect, vRect in pairs(rects) do 
        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x, vRect.y))
        if index1 ~= 0 then
            table.insert(totalRects[index1],vRect)
            if type == 1 then
                self._pHelper:insertBottomRect(index1, vRect)
            elseif type == 2 then
                self._pHelper:insertBodyRect(index1, vRect)
            elseif type == 3 then
                self._pHelper:insertUndefRect(index1, vRect)
            end
        end

        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x + vRect.width, vRect.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            table.insert(totalRects[index2],vRect)
            if type == 1 then
                self._pHelper:insertBottomRect(index2, vRect)
            elseif type == 2 then
                self._pHelper:insertBodyRect(index2, vRect)
            elseif type == 3 then
                self._pHelper:insertUndefRect(index2, vRect)
            end
        end

        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x, vRect.y + vRect.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            table.insert(totalRects[index3],vRect)
            if type == 1 then
                self._pHelper:insertBottomRect(index3, vRect)
            elseif type == 2 then
                self._pHelper:insertBodyRect(index3, vRect)
            elseif type == 3 then
                self._pHelper:insertUndefRect(index3, vRect)
            end
        end

        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x + vRect.width, vRect.y + vRect.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            table.insert(totalRects[index4],vRect)
            if type == 1 then
                self._pHelper:insertBottomRect(index4, vRect)
            elseif type == 2 then
                self._pHelper:insertBodyRect(index4, vRect)
            elseif type == 3 then
                self._pHelper:insertUndefRect(index4, vRect)
            end
        end

    end

    if self._pDebugLayer then
        self._pDebugLayer:show()
    end
end

-- 移除指定信息的矩形集合
-- 参数1：矩形集合
-- 参数2：矩形集合的类别,1：Bottom   2：Body   3：Undef
function RectsManager:removeRectsByRects(rects, type)
    -- 匹配选型    
    local totalRects = nil
    if type == 1 then
        totalRects = self._ttBottomRects
    elseif type == 2 then
        totalRects = self._ttBodyRects
    elseif type == 3 then
        totalRects = self._ttUndefRects
    end
    
    for kRect, vRect in pairs(rects) do 
        local index1 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x, vRect.y))
        if index1 ~= 0 then
            for k, v in pairs(totalRects[index1]) do 
                if v.x == vRect.x and v.y == vRect.y and v.width == vRect.width and v.height == vRect.height then
                    table.remove(totalRects[index1],k)
                    self._pHelper:removeRect(index1, type, k)
                    break
                end
            end
        end

        local index2 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x + vRect.width, vRect.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            for k, v in pairs(totalRects[index2]) do 
                if v.x == vRect.x and v.y == vRect.y and v.width == vRect.width and v.height == vRect.height then
                    table.remove(totalRects[index2],k)
                    self._pHelper:removeRect(index2, type, k)
                    break
                end
            end
        end

        local index3 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x, vRect.y + vRect.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            for k, v in pairs(totalRects[index3]) do 
                if v.x == vRect.x and v.y == vRect.y and v.width == vRect.width and v.height == vRect.height then
                    table.remove(totalRects[index3],k)
                    self._pHelper:removeRect(index3, type, k)
                    break
                end
            end
        end

        local index4 = MapManager:getInstance():getMapAreaIndexByPos(cc.p(vRect.x + vRect.width, vRect.y + vRect.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            for k, v in pairs(totalRects[index4]) do 
                if v.x == vRect.x and v.y == vRect.y and v.width == vRect.width and v.height == vRect.height then
                    table.remove(totalRects[index4],k)
                    self._pHelper:removeRect(index4, type, k)
                    break
                end
            end
        end
        
    end
    
    if self._pDebugLayer then
        self._pDebugLayer:show()
    end
end

