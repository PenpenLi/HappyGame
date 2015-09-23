--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RollHammerEntity.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/5
-- descrip:   旋转锤实体（可被摧毁可攻击）
--===================================================
local RollHammerEntity = class("RollHammerEntity",function(entityInfo, tBottoms, tBodys, tUndefs)
    return require("CanbeDestroyedEntity"):create(entityInfo, tBottoms, tBodys, tUndefs)
end)

-- 构造函数
function RollHammerEntity:ctor()
    self._strName = "RollHammerEntity"                     -- 实体名字
    self._kEntityType = kType.kEntity.kRollHammer          -- 实体对象类型
    self._pSkill = nil                                     -- 技能对象
    self._fNormalInterval = 3.0                              -- 实体normal状态下的间隔周期
end

-- 创建函数
function RollHammerEntity:create(entityInfo, tBottoms, tBodys, tUndefs)
    local entity = RollHammerEntity.new(entityInfo, tBottoms, tBodys, tUndefs)
    entity:dispose()
    return entity
end

-- 处理函数
function RollHammerEntity:dispose()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRollHammerEntity()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function RollHammerEntity:onExitRollHammerEntity()
    
    -- 执行父类退出方法
    self:onExitCanbeDestroyedEntity()
end

-- 循环更新
function RollHammerEntity:updateEntity(dt)
    self:updateGameObj(dt)
    if self._nCurHp == 0 then
        self._pSkill:setVisible(false)
    end
end

return RollHammerEntity
