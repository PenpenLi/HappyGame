--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OperateSearchPath.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/7
-- descrip:   寻路引导至NPC操作（用于任务中的操作队列）
--===================================================
local OperateSearchPath = class("OperateSearchPath", function()
	return require("Operate"):create()
end)

-- 构造函数
function OperateSearchPath:ctor()
    self._strName = "OperateSearchPath"      -- 操作名称
    self._pTargetPosIndex = cc.p(-1,-1)      -- 寻路的目标位置
    
end

-- 创建函数
function OperateSearchPath:create(args)
    local op = OperateSearchPath.new()
    op:dispose(args)
    return op
end

-- 初始化处理
function OperateSearchPath:dispose(args)
    -- 解析目标位置 
    local npc = self:getRolesManager()._tNpcRoles[args.npcID]
    
    if npc == nil then
    	return
    end
    
    self._pTargetPosIndex = self:getMapManager():convertPiexlToIndex(cc.p(npc:getPositionX(), npc:getPositionY()))
    self._pTargetPosIndex.y = self._pTargetPosIndex.y + 1
    
end

-- 开始
function OperateSearchPath:onEnter()
    self:onBaseEnter()
    
    -- 开始寻路计算，并切换到奔跑状态
    local startPosIndex = self:getRolesManager()._pMainPlayerRole:getPositionIndex()
    local path = mmo.AStarHelper:getInst():ComputeAStar(startPosIndex, self._pTargetPosIndex)
    self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun, true, {moveDirections = path})    
    
    return
end

-- 结束
function OperateSearchPath:onExit()
    self:onBaseExit()
    
    return
end

-- 循环更新
function OperateSearchPath:onUpdate(dt)
    self:onBaseUpdate(dt)
    
    -- 监控摇杆的状态，一旦发生摇杆，则立即中断当前行为
    local bIsStickWorking = cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")._pStick:getIsWorking()
    if bIsStickWorking == true then     -- 摇杆正在进行中
        self._bException = true     -- 动了摇杆，则设置为异常中断，立即取消当前任务中的操作队列，人物立即切换回站立状态
        self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand, true)
        return
    end
    
    -- 回到站立状态时，表示当前寻路操作已经结束
    if self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole)._pCurState._kTypeID == kType.kState.kWorldPlayerRole.kStand then
        self._bIsOver = true    -- 已经结束
    end
    
    return
end

-- 复位
function OperateSearchPath:reset()
    self:baseReset()
    
    --self._bException = true     -- 动了摇杆，则设置为异常中断，立即取消当前任务中的操作队列，人物立即切换回站立状态
    self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand, true)
    return
end

-- 检测结束标记
function OperateSearchPath:checkOver(dt)
    if self._bIsOver == true then
        self:onExit()
    end
    return
end

return OperateSearchPath
