--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleMonsterAppearState.lua
-- author:    liyuhang
-- created:   2015/1/7
-- descrip:   战斗中怪物角色出场状态
--===================================================
local BattleMonsterAppearState = class("BattleMonsterAppearState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleMonsterAppearState:ctor()
    self._strName = "BattleMonsterAppearState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleMonster.kAppear  -- 状态类型ID
end

-- 创建函数
function BattleMonsterAppearState:create()
    local state = BattleMonsterAppearState.new()
    return state
end

-- 进入函数
function BattleMonsterAppearState:onEnter(args)
    --print(self._strName.." is onEnter!")
    if self:getMaster() then
        -- mmo.DebugHelper:showJavaLog("--STATE--MONSTER"..self:getMaster()._pRoleInfo.ID.."--:Appear")

        -- 终止依托节点的action
        self:getMaster()._pAppearActionNode:stopAllActions()

        -- 现身
        self:getMaster():setVisible(true)
        self:getMaster()._pAni:setVisible(false)
        -- 出场特效
        self:getMaster():playAppearEffect()
        -- 判断是否为BOSS，如果是，则出现血条
        if self:getMaster()._nMonsterType == kType.kMonster.kBOSS or self:getMaster()._nMonsterType == kType.kMonster.kThiefBOSS then
            cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pBossHpBG:setVisible(true)
            if NewbieManager:getInstance()._bSkipGuide == false then
                if TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId == 10001 then  -- 第1次进入战斗引导
                    NewbieManager:getInstance():showNewbieByID("Guide_1_4")
                end
            end
            
        end
        
        -- 刷新动作
        self:getMaster():playAppearAction()
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 添加动作回调
        local appearOver = function()
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleMonster.kStand)
        end
        local duration = self:getMaster():getAppearActionTime()
        self:getMaster()._pAppearActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(appearOver)))
    end
    
    return
end

-- 退出函数
function BattleMonsterAppearState:onExit()
    --print(self._strName.." is onExit!")
    -- 终止依托节点的action
    self:getMaster()._pAppearActionNode:stopAllActions()

    return
end

-- 更新逻辑
function BattleMonsterAppearState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattleMonsterAppearState
