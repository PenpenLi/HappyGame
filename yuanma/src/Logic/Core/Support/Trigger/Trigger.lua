--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Trigger.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   触发器对象
--===================================================
local Trigger = class("Trigger")

-- 构造函数
function Trigger:ctor()
    self._strName = "Trigger"                   -- 触发器名称
    self._bOpened = false                       -- 是否已经被激活打开
    self._bWorking = false                      -- 是否正在处理中
    self._bIsVisibleOnDebug = true              -- 在debug信息上是否可见,默认均为可见

    -- 参数相关
    self._nID = 0                               -- trigger的ID号
    self._tRects = {}                           -- 触发器所归属的所有矩形对象
    self._bRuntimeCheck = true                  -- 是否实时检测（默认都是实时检测，即角色行进时进行检测，个别除外，如：传送门，只在角色停下来的时候才检测）
    self._nCurStep = 1                          -- 从1开始计数()
    self._tTriggerItems = {}                     -- 动作项队列
end

-- 创建函数
function Trigger:create()
    local item = Trigger.new()
    return item
end

-- 循环更新
function Trigger:update(dt)
    if self._bWorking == true then
        if self._nCurStep <= table.getn(self._tTriggerItems) then
            self._tTriggerItems[self._nCurStep]:work()  -- 相应触发器生效处理
        else -- 动作列表已经全部执行结束，可以退出触发器了
            self._bWorking = false
            if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kWorld then
                cc.Director:getInstance():getRunningScene():getLayerByName("WorldLayer")._pTouchListener:setEnabled(true)
                cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pTouchListener:setEnabled(true)
            elseif LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle then
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleLayer")._pTouchListener:setEnabled(true)
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pTouchListener:setEnabled(true)
            end
           
        end
    end
    return
end

-- 当前动作执行列表步数加1
function Trigger:addCurStep()
    self._nCurStep = self._nCurStep + 1
end

-- 退出函数
function Trigger:onExitTrigger()
    for k,v in pairs(self._tTriggerItems) do
        v = nil
    end
end

return Trigger
