--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PoisonPoolEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/5
-- descrip:   毒池塘实体
--===================================================
local PoisonPoolEntity = class("PoisonPoolEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("Entity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function PoisonPoolEntity:ctor()
    self._strName = "PoisonPoolEntity"                -- 实体名字
    self._kEntityType = kType.kEntity.kPoisonPool     -- 实体对象类型
    self._pSkill = nil                                -- 技能对象
    self._fNormalInterval = 0                         -- 实体normal状态下的间隔周期

end

-- 创建函数
function PoisonPoolEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = PoisonPoolEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function PoisonPoolEntity:dispose()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPoisonPoolEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function PoisonPoolEntity:onExitPoisonPoolEntity()
    
    -- 执行父类退出方法
    self:onExitEntity()
end

-- 循环更新
function PoisonPoolEntity:updateEntity(dt)
    self:updateGameObj(dt)

end

return PoisonPoolEntity
