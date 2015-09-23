--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PoisonPoolSkill.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/2/5
-- descrip:   毒池塘技能（中毒）
--===================================================
local PoisonPoolSkill = class("PoisonPoolSkill",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function PoisonPoolSkill:ctor()
    self._strName = "PoisonPoolSkill"                           -- 技能名称
    self._kTypeID = kType.kSkill.kID.kPoisonPoolSkill           -- 技能对象类型
    self._pCurState = nil                                       -- 技能当前的状态机状态
    self._tUndefs = {}                                          -- 毒池塘实体的undefs
    self._tUndefAreasIndex = {}                                 -- 毒池塘实体的undef矩形所处的地图areaIndex集合
end

-- 创建函数
function PoisonPoolSkill:create(master, skillInfo)   
    local skill = PoisonPoolSkill.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function PoisonPoolSkill:dispose()
    ------------------- 初始化 ------------------------ 
    -- 初始化该技能的相关参数
    self:initPoisonPoolSkillInfo()    
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPoisonPoolSkill()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function PoisonPoolSkill:onExitPoisonPoolSkill()    
    self:onExitSkillObj()
end

-- 循环更新
function PoisonPoolSkill:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function PoisonPoolSkill:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end

-- 技能使用接口
function PoisonPoolSkill:onUse(args) 
    -- 立即手动切换到吟唱状态
    --print("开始！")
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then      
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end


-- 初始化该技能的相关参数
function PoisonPoolSkill:initPoisonPoolSkillInfo() 
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
function PoisonPoolSkill:collidingOnUndefAndBePoisoned()    
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
    
    -- 中毒：要结合buff系统来开发，这里暂时注释掉
    --[[

    ]]
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease) -- 暂时

end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function PoisonPoolSkill:onEnterIdleDo(state)
    --print("PoisonPoolSkill:onEnterIdleDo()")
    self._pCurState = state
    self:setVisible(false)

end

-- 技能待机状态onExit时技能操作
function PoisonPoolSkill:onExitIdleDo()
--print("PoisonPoolSkill:onExitIdleDo()")
end

-- 技能待机状态onUpdate时技能操作
function PoisonPoolSkill:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function PoisonPoolSkill:onEnterChantDo(state)
    --print("PoisonPoolSkill:onEnterChantDo()")
    cclog("毒池塘时刻准备着！")
    self._pCurState = state
    
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)
    
end

-- 技能吟唱状态onExit时技能操作
function PoisonPoolSkill:onExitChantDo()
--print("PoisonPoolSkill:onExitChantDo()")
    
end

-- 技能吟唱状态onUpdate时技能操作
function PoisonPoolSkill:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function PoisonPoolSkill:onEnterProcessDo(state)
    --print("PoisonPoolSkill:onEnterProcessDo()")
    self._pCurState = state
    
end

-- 技能执行状态onExit时技能操作
function PoisonPoolSkill:onExitProcessDo()
--print("PoisonPoolSkill:onExitProcessDo()")

end

-- 技能执行状态onUpdate时技能操作
function PoisonPoolSkill:onUpdateProcessDo(dt)
    --print("processing......")
    
    -- 检测玩家角色是否与自身实体对象的undef发生碰撞
    self:collidingOnUndefAndBePoisoned()

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function PoisonPoolSkill:onEnterReleaseDo(state)
    --print("PoisonPoolSkill:onEnterReleaseDo()")
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    if self:getMaster() then
        self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleEntity):setCurStateByTypeID(kType.kState.kBattleEntity.kNormal)
    end
end

-- 技能释放状态onExit时技能操作
function PoisonPoolSkill:onExitReleaseDo()
--print("PoisonPoolSkill:onExitReleaseDo()")

end

-- 技能释放状态onUpdate时技能操作
function PoisonPoolSkill:onUpdateReleaseDo(dt)
    
end

---------------------------------------------------------------------------------------------------------
return PoisonPoolSkill
