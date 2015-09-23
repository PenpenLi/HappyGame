--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  DelayTriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   触发器延时动作项
--===================================================
local DelayTriggerItem = class("DelayTriggerItem",function()
    return require("TriggerItem"):create()
end)

-- 构造函数
function DelayTriggerItem:ctor()
    self._kType = kType.kTriggerItemType.kDelay  -- 触发器动作项的类型
    self._fDelayTime = 0                        -- 延时时间
end

-- 创建函数
function DelayTriggerItem:create(index, delay)
    local item = DelayTriggerItem.new()
    item._nIndex = index
    item._fDelayTime = delay
    return item
end

-- 作用函数
function DelayTriggerItem:work()
    if self._pOwnerTrigger._nCurStep == self._nIndex and  -- 列表中上一个动作运行结束以后才可以进入到当前动作的执行
        self:getMapManager()._pTmxMap:getActionByTag(nTriggerItemTag) == nil then
        -- 执行结束后的回调
        local actionOverCallBack = function()
            self._pOwnerTrigger:addCurStep()
        end
        local act = cc.Sequence:create(cc.DelayTime:create(self._fDelayTime), cc.CallFunc:create(actionOverCallBack))
        act:setTag(nTriggerItemTag)
        self:getMapManager()._pTmxMap:runAction(act)

        if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
            -- 场景触摸被禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldLayer")._pTouchListener:setEnabled(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pTouchListener:setEnabled(false) 
            -- 角色恢复到默认站立状态
            self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand)
            -- 摇杆禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pStick:setIsWorking(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pStick:hide()

        elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
            -- 场景触摸被禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleLayer")._pTouchListener:setEnabled(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pTouchListener:setEnabled(false) 
            -- 角色恢复到默认站立状态
            self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
            -- 摇杆禁用
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:setIsWorking(false)
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pStick:hide()

        end
        
    end
end

return DelayTriggerItem
