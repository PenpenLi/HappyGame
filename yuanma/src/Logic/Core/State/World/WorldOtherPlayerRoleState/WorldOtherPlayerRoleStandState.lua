--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldOtherPlayerRoleStandState.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/8/25
-- descrip:   世界中其他玩家角色站立状态
--===================================================
local WorldOtherPlayerRoleStandState = class("WorldOtherPlayerRoleStandState",function()
    return require("State"):create()
end)

-- 构造函数
function WorldOtherPlayerRoleStandState:ctor()
    self._strName = "WorldOtherPlayerRoleStandState"           -- 状态名称
    self._kTypeID = kType.kState.kWorldOtherPlayerRole.kStand  -- 状态类型ID
    self._fDelayTime = 0                                       -- 待机等待时间
    self._fTimeCount = 0                                       -- 时间计数器
    ------------ 时间计数 ---------------------------------------------
    self._fStandTime = 0
    self._fCasualTime = 0

end

-- 创建函数
function WorldOtherPlayerRoleStandState:create()
    local state = WorldOtherPlayerRoleStandState.new()
    return state
end

-- 进入函数
function WorldOtherPlayerRoleStandState:onEnter(args)
   -- print(self._strName.."角色站立")    
    
    if self:getMaster() then
        self._fStandTime = 0
        self._fCasualTime = 0
        self._fStandTime = self:getMaster()._pTempleteInfo.CasualActInterval
        self:getMaster():playStandAction()

        self._fDelayTime = 0
        self._fTimeCount = 0
        -- 检测遮挡
        self:getMaster():checkCover()
        -- 随机站立等待时间
        self._fDelayTime = getRandomNumBetween(1,20)
        
    end
    return
end

-- 退出函数
function WorldOtherPlayerRoleStandState:onExit()
    --print(self._strName.." is onExit!")
    self._fDelayTime = 0
    self._fTimeCount = 0
    self._fStandTime = 0
    self._fCasualTime = 0

    return
end

-- 更新逻辑
function WorldOtherPlayerRoleStandState:update(dt)
    self._fTimeCount = self._fTimeCount + dt
    if self._fTimeCount >= self._fDelayTime then
        -- 切换到跑步状态
        local posIndex = self:getMaster():getPositionIndex()
        local targetPosIndex = MapManager:getInstance()._tOthersPlots[getRandomNumBetween(1,table.getn(MapManager:getInstance()._tOthersPlots))]
        while posIndex.x == targetPosIndex.x and posIndex.y == targetPosIndex.y do
            targetPosIndex = MapManager:getInstance()._tOthersPlots[getRandomNumBetween(1,table.getn(MapManager:getInstance()._tOthersPlots))]
        end
        local path = mmo.AStarHelper:getInst():ComputeAStar(posIndex, targetPosIndex)
        self._pOwnerMachine:setCurStateByTypeID(kType.kState.kWorldOtherPlayerRole.kRun,false,{moveDirections = path})
        return
    end

    -- 时间计数
    if self._fCasualTime == 0 then
        self._fStandTime = self._fStandTime - dt
        if self._fStandTime <= 0 then
            self._fStandTime = 0
            self._fCasualTime = self:getMaster():getCasualActionTime()
            self:getMaster():playCasualAction()
        end
    else
        self._fCasualTime = self._fCasualTime - dt
        if self._fCasualTime <= 0 then
            self._fCasualTime = 0
            self._fStandTime = self:getMaster()._pTempleteInfo.CasualActInterval
            self:getMaster():playStandAction()
        end
    end

    return
end

return WorldOtherPlayerRoleStandState
