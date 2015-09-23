--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CameraTriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   触发器相机动作项
--===================================================
local CameraTriggerItem = class("CameraTriggerItem",function()
    return require("TriggerItem"):create()
end)

-- 构造函数
function CameraTriggerItem:ctor()
    self._kType = kType.kTriggerItemType.kCamera -- 触发器动作项的类型
    self._posTarget = cc.p(0,0)                  -- 目标位置信息
    self._fMoveDuration = 0                      -- 移动屏幕的持续时间
    self._fScale = 1.0                           -- 缩放比例
    self._fScaleDuration = 0                     -- 缩放的持续时间
    self._bResumeFollowAfterAction = false       -- 是否在动作结束后恢复屏幕自动跟随功能
    self._nOrder = 0                             -- 播放顺序：1.先移动再缩放   2.先缩放再移动    3.只移动    4.只缩放
    self._posScaleCenter = nil                   -- 可选，在镜头先scale的时候，此项有效，先scale时的中心点
end

-- 创建函数
function CameraTriggerItem:create(index, pos, moveTime, scale, scaleTime, resumFollowAfterAction, order, posScaleCenter)
    local item = CameraTriggerItem.new()
    item._nIndex = index
    item._posTarget = pos
    item._fMoveDuration = moveTime
    item._fScale = scale
    item._fScaleDuration = scaleTime
    item._bResumeFollowAfterAction = resumFollowAfterAction
    item._nOrder = order
    item._posScaleCenter = posScaleCenter
    return item
end

-- 作用函数
function CameraTriggerItem:work()
    if self._pOwnerTrigger._nCurStep == self._nIndex and  -- 列表中上一个动作运行结束以后才可以进入到当前动作的执行
        self:getMapManager()._pTmxMap:getActionByTag(nTriggerItemTag) == nil then

        -----------------------------------------------------------------------------------------------------------------
        local actionOverCallBack = function()
            self._pOwnerTrigger:addCurStep()
        end
        self:getMapManager():moveMapCameraByPos(self._nOrder, self._fMoveDuration, self._posTarget, self._fScaleDuration, self._fScale, self._posScaleCenter, self._bResumeFollowAfterAction, actionOverCallBack)
        -----------------------------------------------------------------------------------------------------------------------

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

return CameraTriggerItem
