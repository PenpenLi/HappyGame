--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SpikeRockEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/5
-- descrip:   地刺实体（可被摧毁）
--===================================================
local SpikeRockEntity = class("SpikeRockEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("CanbeDestroyedEntity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function SpikeRockEntity:ctor()
    self._strName = "SpikeRockEntity"                     -- 实体名字
    self._kEntityType = kType.kEntity.kSpikeRock          -- 实体对象类型
    self._pSkill = nil                                    -- 技能对象
    self._fNormalInterval = 3.0                           -- 实体normal状态下的间隔周期
    
end

-- 创建函数
function SpikeRockEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = SpikeRockEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function SpikeRockEntity:dispose()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSpikeRockEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function SpikeRockEntity:onExitSpikeRockEntity()
    
    
    -- 执行父类退出方法
    self:onExitCanbeDestroyedEntity()
end

-- 循环更新
function SpikeRockEntity:updateEntity(dt)
    self:updateGameObj(dt)

end

return SpikeRockEntity
