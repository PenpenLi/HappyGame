--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DoorEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/2
-- descrip:   传送门实体
--===================================================
local DoorEntity = class("DoorEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("Entity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function DoorEntity:ctor()
    self._strName = "DoorEntity"                -- 实体名字
    self._kEntityType = kType.kEntity.kDoor     -- 实体对象类型
    self._pTrigger = nil                        -- 传送门触发器
end

-- 创建函数
function DoorEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = DoorEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function DoorEntity:dispose()
   
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitDoorEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function DoorEntity:onExitDoorEntity()
    
    -- 执行父类退出方法
    self:onExitEntity()
end

-- 循环更新
function DoorEntity:updateEntity(dt)
    self:updateGameObj(dt)

end

-- 传送门出现
function DoorEntity:appear()
    if self._bActive == false or self._pAni:getActionByTag(nDoorActAction) or self._pTrigger._bIsVisibleOnDebug == true then
        return
    end
    self:setVisible(true)
    local appearOver = function()
        if self._pTrigger then
            self._pTrigger._bIsVisibleOnDebug = true
            self:getTriggersManager():refreshDebugLayer()  -- 刷新调试层
        end
    end
    self._pAni:setOpacity(0)
    local action = cc.Sequence:create(cc.EaseSineInOut:create(cc.FadeTo:create(1.0,255)),cc.CallFunc:create(appearOver))
    action:setTag(nDoorActAction)
    self._pAni:runAction(action)
    
    self:getRectsManager():insertRectsByRects(self._tBottoms, 1)
    self:getRectsManager():insertRectsByRects(self._tBodys, 2)
    self:getRectsManager():insertRectsByRects(self._tUndefs, 3)
    
end

-- 传送门消失
function DoorEntity:disappear()    
    if self._bActive == false or self._pAni:getActionByTag(nDoorActAction) then 
	   return
    end
    local disappearOver = function()
        if self._pTrigger then
            self._pTrigger._bIsVisibleOnDebug = false
            self:getTriggersManager():refreshDebugLayer()  -- 刷新调试层
        end
        self._bActive = false
    end
    local action = cc.Sequence:create(cc.EaseSineInOut:create(cc.FadeTo:create(1.0,0)),cc.CallFunc:create(disappearOver))
    action:setTag(nDoorActAction)
    self._pAni:runAction(action)
end

return DoorEntity
