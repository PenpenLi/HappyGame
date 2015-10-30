--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleFriendRoleAppearState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/12
-- descrip:   战斗中好友角色出场状态
--===================================================
local BattleFriendRoleAppearState = class("BattleFriendRoleAppearState",function()
    return require("State"):create()
end)

-- 构造函数
function BattleFriendRoleAppearState:ctor()
    self._strName = "BattleFriendRoleAppearState"           -- 状态名称
    self._kTypeID = kType.kState.kBattleFriendRole.kAppear  -- 状态类型ID
    
end

-- 创建函数
function BattleFriendRoleAppearState:create()
    local state = BattleFriendRoleAppearState.new()
    return state
end

-- 进入函数
function BattleFriendRoleAppearState:onEnter(args)
    -- mmo.DebugHelper:showJavaLog("mmo:BattleFriendRoleAppearState")
    -------------------------- 显示角色 --------------------------------------------------------------------
    if self:getMaster() then
    ------------------------- 先做位置随机 ----------------------------------------------------------------
        AIManager:getInstance():objBlinkToRandomPosAccordingToTargetObj(self:getMaster(), self:getRolesManager()._pMainPlayerRole,3,7)
        
        -- 终止依托节点的action
        self:getMaster()._pAppearActionNode:stopAllActions()

        self:getMaster():setAngle3D(270)
        self:getMaster()._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(270)
        self:getMaster():setVisible(true)
        self:getMaster()._pAni:setVisible(false)
        self:getMaster()._pShadow:setVisible(false)
    
        -------------------------- 出场特效 -------------------------------------------------------------
        self:getMaster():showAppearEffect()
        local appear = function()
            -- 刷新动作
            self:getMaster():playAppearAction()
            -- 检测遮挡
            self:getMaster():checkCover()
        end
        -- 添加动作回调
        local appearOver = function()
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleFriendRole.kSkillAttack)
        end
        local duration = self:getMaster():getAppearActionTime()
        self:getMaster()._pAppearActionNode:runAction(cc.Sequence:create(cc.CallFunc:create(appear),cc.DelayTime:create(duration), cc.CallFunc:create(appearOver)))

    end
    
    return
end

-- 退出函数
function BattleFriendRoleAppearState:onExit()    
    -- 终止依托节点的action
    self:getMaster()._pAppearActionNode:stopAllActions()

    return
end

-- 更新逻辑
function BattleFriendRoleAppearState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
    end
    return
end

return BattleFriendRoleAppearState
