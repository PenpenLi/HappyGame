--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePlayerRoleBebeatedState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/15
-- descrip:   战斗中玩家角色受击状态
--===================================================
local BattlePlayerRoleBebeatedState = class("BattlePlayerRoleBebeatedState",function()
    return require("State"):create()
end)

-- 构造函数
function BattlePlayerRoleBebeatedState:ctor()
    self._strName = "BattlePlayerRoleBebeatedState"           -- 状态名称
    self._kTypeID = kType.kState.kBattlePlayerRole.kBeaten    -- 状态类型ID

    self._kBeatenType = kType.kBeaten.kNone                   -- 受击类型
    self._fBeatenAngle = 0                                    -- 受击角度
    self._fBeatenOffset = 0                                   -- 击退距离
    self._bCheckTransformState = false                        -- 是否检测状态的转换

end

-- 创建函数
function BattlePlayerRoleBebeatedState:create()
    local state = BattlePlayerRoleBebeatedState.new()
    return state
end

-- 进入函数
-- 参数：args[1]：攻击者技能对象    args[2]：（攻击等级-防御等级）
function BattlePlayerRoleBebeatedState:onEnter(args)
    if self:getMaster() then
        mmo.DebugHelper:showJavaLog("--STATE--PLAYER--:BeBeated")
        -- 复位可能存在的所有技能的动画
        for k,v in pairs(self:getMaster()._tSkills) do 
            v:stopAllActionNodes()
            v._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
        end
        
        -- 检测遮挡
        self:getMaster():checkCover()
        
        -- 摇杆禁用
        self:getMaster()._refStick:add()
        -- 普通攻击按钮禁用
        self:getMaster()._refGenAttackButton:add()
        -- 技能按钮禁用
        for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
            self:getMaster()._tRefSkillButtons[i]:add()
        end

        if self:getMaster()._strCharTag == "main" then
            self:getBattleManager():getBattleUILayer():hideHitAni() -- 停止界面显示的连击文字和数据
        end

        -- 状态机的主人PlayerRole
        local master = self:getMaster()
        -- 攻击者的技能对象
        local pAttackerSkill = args[1]
        -- 攻击等级与防御等级的差值
        local nAttackAndDefDiff = args[2]
        -- 受击的角度
        local fBeatenAngle = mmo.HelpFunc:gAngleAnalyseForRotation(master:getPositionX(), master:getPositionY(),pAttackerSkill:getMaster():getPositionX(), pAttackerSkill:getMaster():getPositionY())
        
        -- 设置受击类型
        self._kBeatenType = TableTempleteAttackLevelDiff[nAttackAndDefDiff].CareersBeaten[2]
        -- 击退位移
        self._fBeatenOffset = TableTempleteAttackLevelDiff[nAttackAndDefDiff].CareersBeaten[1]
        -- 设置受击角度
        self._fBeatenAngle = fBeatenAngle

        local start = function()
            -- 终止依托节点的action
            self:getMaster()._pBebeatedActionNode:stopAllActions()
            self:getMaster():stopActionByTag(nRoleBackActionTag)

            -- 刷新动作，根据受击类型匹配相应处理
            if self._kBeatenType == kType.kBeaten.kNoOffset then    -- 原地受击
                self:beatenNoOffset()
            elseif self._kBeatenType == kType.kBeaten.kBack then    -- 被击退
                self:beatenBack()
            elseif self._kBeatenType == kType.kBeaten.kFall then    -- 被击倒
                self:beatenFall()
            elseif self._kBeatenType == kType.kBeaten.kBackAndFall then  -- 被击退同时被击倒
                self:beatenBackAndFall()
            end
        end
        self:getMaster()._pBebeatedActDelayActionNode:stopAllActions()
        self:getMaster()._pBebeatedActDelayActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(start)))

    end
    return
end

-- 退出函数
function BattlePlayerRoleBebeatedState:onExit()
    --print(self._strName.." is onExit!")
    -- 成员变量复位
    self._kBeatenType = kType.kBeaten.kNone
    self._fBeatenAngle = 0
    self._fBeatenOffset = 0
    self._bCheckTransformState = false

    -- 终止依托节点的action
    self:getMaster()._pBebeatedActionNode:stopAllActions()
    self:getMaster():stopActionByTag(nRoleBackActionTag)

    -- 摇杆恢复禁用
    self:getMaster()._refStick:sub()
    -- 普通攻击按钮恢复禁用
    self:getMaster()._refGenAttackButton:sub()
    -- 技能按钮恢复禁用
    for i=1,table.getn(self:getMaster()._tRefSkillButtons) do
        self:getMaster()._tRefSkillButtons[i]:sub()
    end

    return
end

-- 更新逻辑
function BattlePlayerRoleBebeatedState:update(dt)
    if self:getMaster() then
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 检测标记位，进行状态切换
        if self._bCheckTransformState == true then
            self._bCheckTransformState = false
            self._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattlePlayerRole.kStand)
        end
    end
    return
end

-- Proc受击瞬间的方向刷新
function BattlePlayerRoleBebeatedState:refreshBeatenDirection()
    if self:getMaster() then
        self:getMaster():setAngle3D(self._fBeatenAngle)
        self:getMaster()._kDirection = mmo.HelpFunc:gDirectionAnalyseByAngle(self._fBeatenAngle)
    end
    return
end

-- Proc原地受击
function BattlePlayerRoleBebeatedState:beatenNoOffset()
    if self:getMaster() then
        -- 刷新新的方向
        self:refreshBeatenDirection()
        -- 播放受击动画
        self:getMaster():playBeatenAction()
        -- 添加动作回调
        local bebeatenOver = function()
            self._bCheckTransformState = true
        end
        local duration = self:getMaster():getBeatenActionTime()
        local act = cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(bebeatenOver))
        self:getMaster()._pBebeatedActionNode:runAction(act)
    end
    return
end

-- Proc被击退
function BattlePlayerRoleBebeatedState:beatenBack()
    if self:getMaster() then
        -- 刷新新的方向
        self:refreshBeatenDirection()
        -- 播放受击动画
        self:getMaster():playBeatenAction()
        -- 添加动作回调
        local bebeatenOver = function()
            self._bCheckTransformState = true
        end
        local duration = self:getMaster():getBeatenActionTime()
        local act = cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(bebeatenOver))
        self:getMaster()._pBebeatedActionNode:runAction(act)
        -- 反方向后退
        self:toBackDistanceWithTime(TableConstants.BeatedFlyTime.Value)
    end

    return
end

-- Proc被击倒
function BattlePlayerRoleBebeatedState:beatenFall()
    if self:getMaster() then
        -- 刷新新的方向
        self:refreshBeatenDirection()
        -- 播放受击动画
        self:getMaster():playFallGroundAction() 
        -- 添加动作回调
        local fallOver = function()
            self:getMaster():playUpGroundAction()
        end
        local upOver = function()
            self._bCheckTransformState = true
        end
        local durationFallGround = self:getMaster():getFallGroundActionTime()
        local durationUpGround = self:getMaster():getUpGroundActionTime()
        local act = cc.Sequence:create(cc.DelayTime:create(durationFallGround), cc.CallFunc:create(fallOver), cc.DelayTime:create(durationUpGround), cc.CallFunc:create(upOver))  
        self:getMaster()._pBebeatedActionNode:runAction(act)
        
        -- 开始出现免受伤害计数
        self._pOwnerMachine._fIgnorHurtTimeCounter = 0
        
        -- 应值声
        AudioManager:getInstance():playEffect(self:getMaster()._pTempleteInfo.BeatenVoice)
    end
    
    return
end

-- Proc被击退同时被击倒
function BattlePlayerRoleBebeatedState:beatenBackAndFall()
    if self:getMaster() then
        -- 刷新新的方向
        self:refreshBeatenDirection()
        -- 播放受击动画
        self:getMaster():playFallGroundAction() 
        
        -- 添加动作回调
        local fallOver = function()
            self:getMaster():playUpGroundAction()
        end
        local upOver = function()
            self._bCheckTransformState = true
        end
        local durationFallGround = self:getMaster():getFallGroundActionTime()
        local durationUpGround = self:getMaster():getUpGroundActionTime()
        local act = cc.Sequence:create(cc.DelayTime:create(durationFallGround), cc.CallFunc:create(fallOver), cc.DelayTime:create(durationUpGround), cc.CallFunc:create(upOver))  
        self:getMaster()._pBebeatedActionNode:runAction(act)
        
        -- 反方向后退
        self:toBackDistanceWithTime(TableConstants.BeatedFlyTime.Value)

        -- 开始出现免受伤害计数
        self._pOwnerMachine._fIgnorHurtTimeCounter = 0
        
        -- 应值声
        AudioManager:getInstance():playEffect(self:getMaster()._pTempleteInfo.BeatenVoice)
    end
    
    return
end

-- 反方向后退位移
function BattlePlayerRoleBebeatedState:toBackDistanceWithTime(time)
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

return BattlePlayerRoleBebeatedState
