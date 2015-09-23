--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleDeadState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/16
-- descrip:   战斗中玩家角色死亡状态
--===================================================
local BattlePlayerRoleDeadState = class("BattlePlayerRoleDeadState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleDeadState:ctor()
    self._strName = "BattlePlayerRoleDeadState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kDead  -- 状态类型ID
    self._fBeatenAngle = 0                                -- 受击角度
    self._fBeatenOffset = 0                               -- 飞出距离

end

-- 创建函数
function BattlePlayerRoleDeadState:create()
    local state = BattlePlayerRoleDeadState.new()
    return state
end

-- 进入函数
function BattlePlayerRoleDeadState:onEnter(args)
    mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:Dead")
    if self:getMaster() then
        --print(self:getMaster()._strCharTag.."角色死亡状态")

        -- args[1] 是否为技能   args[2] skill对象
        if args[1] == true then  -- 由技能致死
            local pAttackerSkill = args[2]
            -- 受击的角度计算
            self._fBeatenAngle = mmo.HelpFunc:gAngleAnalyseForRotation(self:getMaster():getPositionX(), self:getMaster():getPositionY(), pAttackerSkill:getMaster():getPositionX(), pAttackerSkill:getMaster():getPositionY())
            -- 获得飞出距离
            self._fBeatenOffset = TableConstants.DeadFlyDistance.Value
            -- 刷新角色角度
            self:refreshBeatenDirection()
            -- 后退位移
            self:toBackDistanceWithTime(TableConstants.BeatedFlyTime.Value)
        end

        -- 如果是PVP对手，则需要慢镜头
        if self:getMaster()._strCharTag == "pvp" then
            local cameraOver = function()
                cc.Director:getInstance():getScheduler():setTimeScale(0.3)
            end
            -- 相机拉近，给boss一个特写
            local posX, posY = self:getMaster():getPosition()
            self:getMapManager():moveMapCameraByPos(1, 0.5, cc.p(posX,posY), 0.5, 0.7, nil, false, cameraOver)
            -- 特写标记
            self:getMapManager()._bBossDeadFilming = true
            -- 强制设置所有角色positionZ到最小值
            MonstersManager:getInstance():setForceMinPositionZ(true, -5000)
            RolesManager:getInstance():setForceMinPositionZ(true, -5000)
            PetsManager:getInstance():setForceMinPositionZ(true, -5000)
            SkillsManager:getInstance():setForceMinPositionZ(true, -5000)
        end
        
        -- 刷新动作
        self:getMaster():playDeadAction()
      
        -- 死亡动画
        self:getMaster():playDeadEffect()
    
        -- 摇杆禁用
        self:getMaster()._refStick:add()
        
        -- 普通攻击按钮禁用
        self:getMaster()._refGenAttackButton:add()
        
        -- 技能按钮禁用
        for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
            self:getMaster()._tRefSkillButtons[i]:add()
        end
        
        -- 添加动作回调
        local deadOver = function()
            -- 判断是否为PVP对手，如果是，则血条消失
            if self:getMaster()._strCharTag == "pvp" then
                cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")._pBossHpBG:setVisible(false)
                cc.Director:getInstance():getScheduler():setTimeScale(1.0)   -- 如果是PVP，死亡结束后恢复正常镜头速度
                -- 相机复原，回到正常比例
                self:getMapManager():moveMapCameraByPos(2, 0.5, cc.p(-1,-1), 0.5, 1.0, cc.p(self:getMaster():getPositionX(),self:getMaster():getPositionY()), true)
                -- 特写标记
                self:getMapManager()._bBossDeadFilming = false
                -- 恢复设置所有角色positionZ到最小值
                MonstersManager:getInstance():setForceMinPositionZ(false)
                RolesManager:getInstance():setForceMinPositionZ(false)
                PetsManager:getInstance():setForceMinPositionZ(false)
                SkillsManager:getInstance():setForceMinPositionZ(false)
            end
        end
        self:getMaster()._pAni:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(deadOver)))
        
        -- 立刻移除所有buff
        self:getMaster():getBuffControllerMachine():removeAllBuffsRightNow()
        
        -- 复位技能状态
        for k,v in pairs(self:getMaster()._tSkills) do 
            v:stopAllActionNodes()
            v:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill):setCurStateByTypeID(kType.kState.kBattleSkill.kIdle, true)
        end

        -- 死亡声
        AudioManager:getInstance():playEffect(self:getMaster()._pTempleteInfo.DeadVoice)
        
        -- 显示复活弹框（竞技场和华山论剑除外）
        if self:getMaster()._strCharTag == "main" then
            if StagesManager:getInstance()._nCurCopyType ~= kType.kCopy.kPVP and StagesManager:getInstance()._nCurCopyType ~= kType.kCopy.kHuaShan then
                DialogManager:getInstance():showDialog("ReviveDialog")
            end
        end
    end
    
    return
end

-- 退出函数
function BattlePlayerRoleDeadState:onExit()
    --print(self._strName.." is onExit!")
    if self:getMaster() then
        
        -- 摇杆解除禁用
        self:getMaster()._refStick:sub()
    
        -- 普通攻击按钮解除禁用
        self:getMaster()._refGenAttackButton:sub()
    
        -- 技能按钮解除禁用
        for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
            self:getMaster()._tRefSkillButtons[i]:sub()
        end
    end
    
    return
end

-- 更新逻辑
function BattlePlayerRoleDeadState:update(dt)     
    return
end

-- Proc受击瞬间的方向刷新
function BattlePlayerRoleDeadState:refreshBeatenDirection()
    if self:getMaster() then
        self:getMaster():setAngle3D(self._fBeatenAngle)
        self:getMaster()._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(self._fBeatenAngle)
    end
    return
end

-- 反方向后退位移
function BattlePlayerRoleDeadState:toBackDistanceWithTime(time)
    if self:getMaster() then
        local rect = self:getMaster():getBottomRectInMap() 
        local toX = rect.x
        local toY = rect.y
        local width = rect.width
        local height = rect.height
        local direction = self:getMaster()._kDirection
        local offset = 0
        local test = 37
        if direction == kDirection.kDown then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX,toY + offset, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toY = toY + (offset - test)
        elseif direction == kDirection.kUp then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX,toY - offset, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toY = toY - (offset - test)
        elseif direction == kDirection.kRight then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX - offset,toY, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX - (offset - test)
        elseif direction == kDirection.kLeft then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + offset,toY, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX + (offset - test)
        elseif direction == kDirection.kRightDown then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX - offset / 1.414, toY + offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX - (offset - test) / 1.414
            toY = toY + (offset - test) / 1.414
        elseif direction == kDirection.kRightUp then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX - offset / 1.414, toY - offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX - (offset - test) / 1.414
            toY = toY - (offset - test) / 1.414
        elseif direction == kDirection.kLeftDown then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + offset / 1.414, toY + offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX + (offset - test) / 1.414
            toY = toY + (offset - test) / 1.414
        elseif direction == kDirection.kLeftUp then
            while self:getRectsManager():isRectIntersectBottomRects(cc.rect(toX + offset / 1.414, toY - offset / 1.414, width, height)) == false do
                offset = offset + test
                if offset >= self._fBeatenOffset then
                    break
                end
            end
            if offset <= test then
                offset = test  -- 保证下面做差以后为0
            end
            toX = toX + (offset - test) / 1.414
            toY = toY - (offset - test) / 1.414
        end
        local act = cc.EaseSineOut:create(cc.MoveTo:create(time,cc.p(toX + width/2,toY)))
        self:getMaster():stopActionByTag(nRoleBackActionTag)
        act:setTag(nRoleBackActionTag)
        self:getMaster():runAction(act)
    end
    
end

return BattlePlayerRoleDeadState
