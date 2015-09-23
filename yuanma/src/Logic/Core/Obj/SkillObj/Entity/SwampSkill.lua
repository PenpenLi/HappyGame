--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  SwampSkill.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/4
-- descrip:   沼泽地技能（减速）
--===================================================
local SwampSkill = class("SwampSkill",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function SwampSkill:ctor()
    self._strName = "SwampSkill"                           -- 技能名称
    self._kTypeID = kType.kSkill.kID.kSwampSkill           -- 技能对象类型
    self._pCurState = nil                                  -- 技能当前的状态机状态
    self._tUndefs = {}                                     -- 沼泽实体的undefs
    self._tUndefAreasIndex = {}                            -- 沼泽实体的undef矩形所处的地图areaIndex集合
    self._bIsSpeedingDownOnMainRole = false                -- 是否正作用于主角
end

-- 创建函数
function SwampSkill:create(master, skillInfo)   
    local skill = SwampSkill.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function SwampSkill:dispose()
    ------------------- 初始化 ------------------------ 
    -- 初始化该技能的相关参数
    self:initSwampSkillInfo()    
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSwampSkill()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function SwampSkill:onExitSwampSkill()    
    self:onExitSkillObj()
end

-- 循环更新
function SwampSkill:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function SwampSkill:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function SwampSkill:onUse(args)
    -- 立即手动切换到吟唱状态
    --print("开始！")
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then      
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end


-- 初始化该技能的相关参数
function SwampSkill:initSwampSkillInfo() 
    self._tUndefs = self:getMaster()._tUndefs
    for k,v in pairs(self._tUndefs) do
        -- 给矩形分区
        local info = {["x"] = v.x, ["y"] = v.y, ["width"] = v.width, ["height"] = v.height}

        local index1 = self:getMapManager():getMapAreaIndexByPos(cc.p(info.x, info.y))
        if index1 ~= 0 then
            local needInsert = true
            for kk,vv in pairs(self._tUndefAreasIndex) do
                if vv == index1 then
                    needInsert = false
                    break
                end
            end
            if needInsert == true then
                table.insert(self._tUndefAreasIndex,index1)
            end
        end

        local index2 = self:getMapManager():getMapAreaIndexByPos(cc.p(info.x + info.width, info.y))
        if ((index2 ~= 0) and (index1 ~= index2)) == true then
            local needInsert = true
            for kk,vv in pairs(self._tUndefAreasIndex) do
                if vv == index2 then
                    needInsert = false
                    break
                end
            end
            if needInsert == true then
                table.insert(self._tUndefAreasIndex,index2)
            end
        end

        local index3 = self:getMapManager():getMapAreaIndexByPos(cc.p(info.x, info.y + info.height))
        if ((index3 ~= 0) and (index1 ~= index3) and (index2 ~= index3)) == true then
            local needInsert = true
            for kk,vv in pairs(self._tUndefAreasIndex) do
                if vv == index3 then
                    needInsert = false
                    break
                end
            end
            if needInsert == true then
                table.insert(self._tUndefAreasIndex,index3)
            end
        end

        local index4 = self:getMapManager():getMapAreaIndexByPos(cc.p(info.x + info.width, info.y + info.height))
        if ((index4 ~= 0) and (index1 ~= index4) and (index2 ~= index4) and (index3 ~= index4)) == true then
            local needInsert = true
            for kk,vv in pairs(self._tUndefAreasIndex) do
                if vv == index4 then
                    needInsert = false
                    break
                end
            end
            if needInsert == true then
                table.insert(self._tUndefAreasIndex,index4)
            end
        end
    end    
end


-- 检测玩家角色是否与自身实体对象的undef发生碰撞
function SwampSkill:collidingOnUndefAndSpeedDown()
    if self:getRolesManager()._pMainPlayerRole == nil then
        return
    end
    
    local target = self:getRolesManager()._pMainPlayerRole
    local targetBottom = self:getRolesManager()._pMainPlayerRole:getBottomRectInMap()
    local posX, posY = target:getPosition()
    local nAreaIndex = target:getMapManager():getMapAreaIndexByPos(cc.p(posX, posY)) -- 地图分块区域索引值
    local needProc = false  -- 先判定是否需要遍历
    for k, v in pairs(self._tUndefAreasIndex) do
    	if v == nAreaIndex then
    	   needProc = true
    	   break
    	end
    end
    
    if needProc == true then
        local directions = 0
        local intersection = cc.rect(0,0,0,0)
        for k,v in pairs(self._tUndefs) do
            directions, intersection = self:getMaster():isCollidingUndefOnRect(targetBottom)
            if directions ~= 0 then
                break
            end
        end
        if directions ~= 0 then
            if self._bIsSpeedingDownOnMainRole == false then
                target:setSpeedPercent(30/100)  -- 30%
                self._bIsSpeedingDownOnMainRole = true
            end
        else
            if self._bIsSpeedingDownOnMainRole == true then
                target:setSpeedPercent(100/30)  -- 1/0.3
                self._bIsSpeedingDownOnMainRole = false
            end
        end
        
    else
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
    end

end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function SwampSkill:onEnterIdleDo(state)
    --print("SwampSkill:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function SwampSkill:onExitIdleDo()
--print("SwampSkill:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function SwampSkill:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function SwampSkill:onEnterChantDo(state)
    --print("SwampSkill:onEnterChantDo()")
    cclog("沼泽地时刻准备着！")
    
    self._pCurState = state
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    
end

-- 技能吟唱状态onExit时技能操作
function SwampSkill:onExitChantDo()
--print("SwampSkill:onExitChantDo()")
end

-- 技能吟唱状态onUpdate时技能操作
function SwampSkill:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function SwampSkill:onEnterProcessDo(state)
    --print("SwampSkill:onEnterProcessDo()")
    self._pCurState = state
    
end

-- 技能执行状态onExit时技能操作
function SwampSkill:onExitProcessDo()
    --print("SwampSkill:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function SwampSkill:onUpdateProcessDo(dt)
    --print("processing......")
    
    -- 检测玩家角色是否与自身实体对象的undef发生碰撞
    self:collidingOnUndefAndSpeedDown()

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function SwampSkill:onEnterReleaseDo(state)
    --print("SwampSkill:onEnterReleaseDo()")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    if self:getMaster() then
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleEntity):setCurStateByTypeID(kType.kState.kBattleEntity.kNormal)
    end
end

-- 技能释放状态onExit时技能操作
function SwampSkill:onExitReleaseDo()
    --print("SwampSkill:onExitReleaseDo()")
    
end

-- 技能释放状态onUpdate时技能操作
function SwampSkill:onUpdateReleaseDo(dt)
    
end

---------------------------------------------------------------------------------------------------------
return SwampSkill
