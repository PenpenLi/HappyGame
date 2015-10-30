--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Entity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   实体
--===================================================
local Entity = class("Entity",function()
    return require("GameObj"):create()
end)

-- 构造函数
function Entity:ctor()
    self._nID = 0                               -- 实体ID（地编中设置）
    self._kGameObjType = kType.kGameObj.kEntity -- 游戏对象类型
    self._tBottoms = {}                         -- 实体bottom矩形集合
    self._tBodys = {}                           -- 实体body矩形集合
    self._tUndefs = {}                          -- 实体undef矩形集合 
    self._tTempleteInfo = nil                   -- 实体模板表数据
    self._pEntityInfo = nil                     -- 实体属性表数据
    self._nCurHp = 0                            -- 实体当前Hp
    
    self._pKartunActionNode = nil               -- 【动作依托的节点】卡顿的动作节点
    
end

-- 创建函数
function Entity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = Entity.new()
    entity:dispose(entityInfo, tBottoms, tBodys, tUndefs)
    return entity
end

-- 处理函数
function Entity:dispose(entityInfo, tBottoms, tBodys, tUndefs)
    ------------------- 初始化 ----------------------
    -- 设置实体信息
    self:initInfo(entityInfo)
    
    -- 初始化动画
    self:initAni()
    
    -- 初始化动作
    self:initAniAction()
    
    -- 初始化实体默认bottom和body和undef矩形信息
    self:initRects(tBottoms, tBodys, tUndefs)
    
    -- 创建实体状态机
    self:initStateMachine()
    
    -- 根据EntityInfo设置当前是否生效
    self:initVisibleActive()
    
    -- 动作依托的节点
    self._pKartunActionNode = cc.Node:create()
    self:addChild(self._pKartunActionNode)
   
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function Entity:onExitEntity()
    -- 执行父类退出方法
    self:onExitGameObj()
end

-- 循环更新
function Entity:updateEntity(dt)
    self:updateGameObj(dt)

end

-- 初始化动画
function Entity:initInfo(entityInfo)
    self._pEntityInfo = entityInfo
    self._tTempleteInfo = TableTempleteEntitys[entityInfo.TempleteID]
    self._strName = self._tTempleteInfo.Name
    self._nCurHp = entityInfo.CanBeHurtedTimes

end

-- 初始化动画
function Entity:initAni()
    self._kAniType = self._tTempleteInfo.AniType
    self._strAniName = self._tTempleteInfo.AniResName
    
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(self._tTempleteInfo.PvrName)
    self._pAni = cc.CSLoader:createNode(self._strAniName..".csb")
    self:addChild(self._pAni)
end

-- 初始化动作
function Entity:initAniAction()

end

-- 根据EntityInfo设置当前是否生效可见
function Entity:initVisibleActive()
    -- 设置是否可见，同时也会影响到矩形是否生效
    if self._pEntityInfo.Visible == 1 then
        self:setVisible(true)
    else    -- 将自身的矩形信息从矩形管理器中移除
        self:setVisible(false)
        -- 如果实体不可见，则当前实体的矩形集合需要从rectsManager中移除
        self:getRectsManager():removeRectsByRects(self._tBottoms, 1)
        self:getRectsManager():removeRectsByRects(self._tBodys, 2)
        self:getRectsManager():removeRectsByRects(self._tUndefs, 3)
        
    end
end

-- 播放正常动作
function Entity:playNormalAction()
    if self._pAni:getNumberOfRunningActions() == 0 then
        local normal = cc.CSLoader:createTimeline(self._strAniName..".csb")
        self._pAni:stopAllActions()
        normal:setTag(nEntityActAction)
        normal:gotoFrameAndPlay(self._tTempleteInfo.NormalActFrameRegion[1], self._tTempleteInfo.NormalActFrameRegion[2], true)  
        normal:setTimeSpeed(self._tTempleteInfo.NormalActFrameRegion[3])
        self._pAni:runAction(normal)
    end
    
end

-- 播放被摧毁的动作
function Entity:playDestroyedAction()
    local destroy = cc.CSLoader:createTimeline(self._strAniName..".csb")
    self._pAni:stopAllActions()
    destroy:setTag(nEntityActAction)
    destroy:gotoFrameAndPlay(self._tTempleteInfo.DestroyedActFrameRegion[1], self._tTempleteInfo.DestroyedActFrameRegion[2], false)  
    destroy:setTimeSpeed(self._tTempleteInfo.DestroyedActFrameRegion[3])
    self._pAni:runAction(destroy)
end

-- 初始化实体默认bottom和body和undef矩形信息
function Entity:initRects(tBottoms, tBodys, tUndefs)
    -- 初始化默认bottom和body和undef矩形信息
    self._tBottoms = tBottoms
    self._tBodys = tBodys
    self._tUndefs = tUndefs
    
end

-- 创建实体状态机
function Entity:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = nil
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        pStateMachine = require("WorldEntityStateMachine"):create(self)
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        pStateMachine = require("BattleEntityStateMachine"):create(self)
    end
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 获取对象的底座bottom在地图中的绝对（位置）碰撞矩形
function Entity:getBottomRectInMap()
    local posX, posY = self:getPosition()
    local rec = cc.rect(0,0,0,0)
    
    local bigRect = self._tBottoms[1]
    for k,v in pairs(self._tBottoms) do
    	if bigRect.x >= v.x then
    	    bigRect.x = v.x
    	end
        if bigRect.x + bigRect.width <= v.x + v.width then
            bigRect.width = v.x + v.width - bigRect.x
        end
        if bigRect.y >= v.y then
            bigRect.y = v.y
        end
        if bigRect.y + bigRect.height <= v.y + v.height then
            bigRect.height = v.y + v.height - bigRect.y
        end
    end
    
    if bigRect ~= nil then
       rec = cc.rect(bigRect.x, bigRect.y, bigRect.width, bigRect.height)
    end
    return rec
end

-- 获取对象的主干body在地图中的绝对（位置）碰撞矩形
function Entity:getBodyRectInMap()
    local posX, posY = self:getPosition()
    local rec = cc.rect(0,0,0,0)
    
    local bigRect = self._tBodys[1]
    for k,v in pairs(self._tBodys) do
        if bigRect.x >= v.x then
            bigRect.x = v.x
        end
        if bigRect.x + bigRect.width <= v.x + v.width then
            bigRect.width = v.x + v.width - bigRect.x
        end
        if bigRect.y >= v.y then
            bigRect.y = v.y
        end
        if bigRect.y + bigRect.height <= v.y + v.height then
            bigRect.height = v.y + v.height - bigRect.y
        end
    end
    
    if bigRect ~= nil then
        rec = cc.rect(bigRect.x, bigRect.y, bigRect.width, bigRect.height)
    end
    return rec
end

-- 获取对象的undef在地图中的绝对（位置）碰撞矩形
function Entity:getUndefRectInMap()
    local posX, posY = self:getPosition()
    local rec = cc.rect(0,0,0,0)

    local bigRect = self._tUndefs[1]
    for k,v in pairs(self._tUndefs) do
        if bigRect.x >= v.x then
            bigRect.x = v.x
        end
        if bigRect.x + bigRect.width <= v.x + v.width then
            bigRect.width = v.x + v.width - bigRect.x
        end
        if bigRect.y >= v.y then
            bigRect.y = v.y
        end
        if bigRect.y + bigRect.height <= v.y + v.height then
            bigRect.height = v.y + v.height - bigRect.y
        end
    end

    if bigRect ~= nil then
        rec = cc.rect(bigRect.x, bigRect.y, bigRect.width, bigRect.height)
    end
    return rec
end

-- 判定是否发生本身Body与指定矩形上的碰撞（返回碰撞的方向集合 和 碰撞产生的矩形区域）
function Entity:isCollidingBodyOnRect(recObjBody)
    local directions = 0
    local inersection = cc.rect(0,0,0,0)
    for kBody,vBody in pairs(self._tBodys) do 
        directions = mmo.HelpFunc:getCollidingDirections(vBody, recObjBody)
        inersection = cc.rectIntersection(vBody, recObjBody)
        if directions ~= 0 then
            break
        end
    end
    return  directions, inersection
end

-- 判定是否发生本身Bottom与指定矩形上的碰撞（返回碰撞的方向集合 和 碰撞产生的矩形区域）
function Entity:isCollidingBottomOnRect(recObjBody)
    local directions = 0
    local inersection = cc.rect(0,0,0,0)
    for kBottom,vBottom in pairs(self._tBottoms) do 
        directions = mmo.HelpFunc:getCollidingDirections(vBottom, recObjBody)
        inersection = cc.rectIntersection(vBottom, recObjBody)
        if directions ~= 0 then
            break
        end
    end
    return  directions, inersection
end

-- 判定是否发生本身Undef与指定矩形上的碰撞（返回碰撞的方向集合 和 碰撞产生的矩形区域）
function Entity:isCollidingUndefOnRect(recObjBody)
    local directions = 0
    local inersection = cc.rect(0,0,0,0)
    for kUndef,vUndef in pairs(self._tUndefs) do 
        directions = mmo.HelpFunc:getCollidingDirections(vUndef, recObjBody)
        inersection = cc.rectIntersection(vUndef, recObjBody)
        if directions ~= 0 then
            break
        end
    end
    return  directions, inersection
end

-- 获取遮挡时的半透度
function Entity:getCoverOpacity()
    return 130
end

-- 设置半透
function Entity:setOpacity()
    if self._pAni:getOpacity() ~= self:getCoverOpacity() then
        self._pAni:setOpacity(self:getCoverOpacity())
    end
end

-- 实体卡顿
function Entity:roleKartun(time)
    if time ~= 0 then
        -- 开始卡顿
        self._pKartunActionNode:getActionManager():pauseTarget(self._pAni)
        local kartunOver = function()
            -- 恢复卡顿
            self._pKartunActionNode:getActionManager():resumeTarget(self._pAni)
        end 
        self._pKartunActionNode:stopAllActions()
        self._pKartunActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(kartunOver)))
    end

end

return Entity
