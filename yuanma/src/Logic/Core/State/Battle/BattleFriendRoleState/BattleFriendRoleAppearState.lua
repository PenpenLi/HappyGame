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
    ------------------------- 先做位置随机 ----------------------------------------------------------------
    local posIndex = self:getRolesManager()._pMainPlayerRole:getPositionIndex()
    local stepOffsetX = getRandomNumBetween(3,7)     -- 3到7步
    local stepOffsetY = getRandomNumBetween(3,7)     -- 3到7步
    local factorX = getRandomNumBetween(1,2)        -- 随机正负
    local factorY = getRandomNumBetween(1,2)        -- 随机正负
    if factorX == 2 then factorX = -1 end
    if factorY == 2 then factorY = -1 end
    local tiledType = self:getMapManager():getTiledAttriAt(cc.p(posIndex.x + stepOffsetX*factorX, posIndex.y + stepOffsetY*factorY))        
    while tiledType == kType.kTiledAttri.kBarrier or 
        posIndex.x + stepOffsetX*factorX >= self:getMapManager()._sMapIndexSize.width or
        posIndex.x + stepOffsetX*factorX <= 0 or
        posIndex.y + stepOffsetY*factorY >= self:getMapManager()._sMapIndexSize.height or
        posIndex.y + stepOffsetY*factorY <= 0 do
        stepOffsetX = getRandomNumBetween(3,7)     -- 3到7步
        stepOffsetY = getRandomNumBetween(3,7)     -- 3到7步
        factorX = getRandomNumBetween(1,2)        -- 随机正负
        factorY = getRandomNumBetween(1,2)        -- 随机正负
        if factorX == 2 then factorX = -1 end
        if factorY == 2 then factorY = -1 end
        tiledType = self:getMapManager():getTiledAttriAt(cc.p(posIndex.x + stepOffsetX*factorX, posIndex.y + stepOffsetY*factorY))

    end
    -------------------------- 显示角色 --------------------------------------------------------------------
    if self:getMaster() then
        -- 终止依托节点的action
        self:getMaster()._pAppearActionNode:stopAllActions()

        self:getMaster():setPositionByIndex(cc.p(posIndex.x + stepOffsetX*factorX, posIndex.y + stepOffsetY*factorY))
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
