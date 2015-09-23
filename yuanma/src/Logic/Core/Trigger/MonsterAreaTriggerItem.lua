--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonsterAreaTriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/30
-- descrip:   触发器野怪区域激活动作项
--===================================================
local MonsterAreaTriggerItem = class("MonsterAreaTriggerItem",function()
    return require("TriggerItem"):create()
end)

-- 构造函数
function MonsterAreaTriggerItem:ctor()
    self._kType = kType.kTriggerItemType.kMonsterArea   -- 触发器动作项的类型
    self._nMonsterAreaIdex = 0                          -- 待触发的野怪区域id
end

-- 创建函数
function MonsterAreaTriggerItem:create(index, monsterAreaIdex)
    local item = MonsterAreaTriggerItem.new()
    item._nIndex = index
    item._nMonsterAreaIdex = monsterAreaIdex
    return item
end

-- 作用函数
function MonsterAreaTriggerItem:work()
    if self._pOwnerTrigger._nCurStep == self._nIndex and  -- 列表中上一个动作运行结束以后才可以进入到当前动作的执行
        self:getMapManager()._pTmxMap:getActionByTag(nTriggerItemTag) == nil then
        
      -- 激活当前野怪区域的屏障
      local entitys = self:getEntitysManager()._tRoadBlockEntitys[self._nMonsterAreaIdex]
      for k,v in pairs(entitys) do 
          v:setRoadBlockEntitysActive(true)      
      end
      
      -- 激活当前野怪区域的第一波野怪
      self:getMonstersManager():appearMonstersWithAreaAndWave(self._nMonsterAreaIdex, 1)
      
      self._pOwnerTrigger:addCurStep()

    end
end

return MonsterAreaTriggerItem
