--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoadBlockEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/2
-- descrip:   屏障实体
--===================================================
local RoadBlockEntity = class("RoadBlockEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("Entity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function RoadBlockEntity:ctor()
    self._strName = "RoadBlockEntity"                -- 实体名字
    self._kEntityType = kType.kEntity.kRoadBlock     -- 实体对象类型
end

-- 创建函数
function RoadBlockEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = RoadBlockEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function RoadBlockEntity:dispose()
    ------------------- 初始化 ----------------------
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRoadBlockEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function RoadBlockEntity:onExitRoadBlockEntity()
    
    -- 执行父类退出方法
    self:onExitEntity()
end

-- 循环更新
function RoadBlockEntity:updateEntity(dt)
    self:updateGameObj(dt)

end

-- 设置是否生效
function RoadBlockEntity:setRoadBlockEntitysActive(bActive)
    if bActive == true then
        self._bActive = true
        self:getRectsManager():insertRectsByRects(self._tBottoms, 1)
        self:getRectsManager():insertRectsByRects(self._tBodys, 2)
        self:getRectsManager():insertRectsByRects(self._tUndefs, 3)
        self:stopAllActions()
        self:setScale(0.1)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(getRandomNumBetween(1,100)/80), cc.Show:create(), cc.EaseSineOut:create(cc.ScaleTo:create(1.0, 1.0,1.0))))
    else
        local disAppearOver = function()
            self._bActive = false
        end
        self:stopAllActions()
        self:runAction(cc.Sequence:create(cc.EaseSineOut:create(cc.ScaleTo:create(0.5, 0.1,0.1)), cc.Hide:create(), cc.CallFunc:create(disAppearOver)))
    end
end

return RoadBlockEntity
