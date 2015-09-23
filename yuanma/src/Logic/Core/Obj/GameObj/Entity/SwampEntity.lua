--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SwampEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/3
-- descrip:   沼泽实体
--===================================================
local SwampEntity = class("SwampEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("Entity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function SwampEntity:ctor()
    self._strName = "SwampEntity"                -- 实体名字
    self._kEntityType = kType.kEntity.kSwamp     -- 实体对象类型
    self._pSkill = nil                           -- 技能对象
    self._fNormalInterval = 0                    -- 实体normal状态下的间隔周期
end

-- 创建函数
function SwampEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = SwampEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function SwampEntity:dispose()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSwampEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function SwampEntity:onExitSwampEntity()


    
    -- 执行父类退出方法
    self:onExitEntity()
end

-- 循环更新
function SwampEntity:updateEntity(dt)
    self:updateGameObj(dt)

end

return SwampEntity
