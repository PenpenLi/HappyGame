--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MonsterSkill60.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/9/25
-- descrip:   怪物技能攻击60    蚩尤   防御
--===================================================
local MonsterSkill60 = class("MonsterSkill60",function(master, skillInfo)
    return require("SkillObj"):create(master, skillInfo)
end)

-- 构造函数
function MonsterSkill60:ctor()
    self._strName = "MonsterSkill60"                            -- 技能名称
    self._kTypeID = kType.kSkill.kID.kMonsterSkill60            -- 技能对象类型
    self._pCurState = nil                                       -- 技能当前的状态机状态
    self._nRoleAttackActionIndex = 7                            -- 角色攻击动作index
    
end

-- 创建函数
function MonsterSkill60:create(master,skillInfo)
    local skill = MonsterSkill60.new(master, skillInfo)
    skill:dispose()
    return skill
end

-- 处理函数
function MonsterSkill60:dispose()
    ------------------- 初始化 ------------------------  
    -- 创建状态机
    self:initStateMachine()
    
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitMonsterSkill60()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 退出函数
function MonsterSkill60:onExitMonsterSkill60()    
    self:onExitSkillObj()
end

-- 循环更新
function MonsterSkill60:update(dt)
    self:updateSkillObj(dt)
end

-- 创建状态机
function MonsterSkill60:initStateMachine()
    self._pStateMachineDelegate = require("StateMachineDelegate"):create()
    local pStateMachine = require("BattleSkillStateMachine"):create(self)
    self._pStateMachineDelegate:addStateMachine(pStateMachine)
end


-- 技能使用接口
function MonsterSkill60:onUse() 
    -- 立即手动切换到吟唱状态
    if self._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
        self._fCDCounter = 0   -- CD时间清空     
        self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kChant)
    end
end

-- 初始化动作帧事件回调
function MonsterSkill60:initActionsFrameEvents(index, action)

end

-- 帧事件的处理
function MonsterSkill60:procActionsFrameEvents()
    self._strFrameEventName = ""
end

-------------------------------------------------------------------------------------------------
-- 技能待机状态onEnter时技能操作
function MonsterSkill60:onEnterIdleDo(state)
    self._pCurState = state
    self._fIntervalCount = 0
    self:getMaster()._bMustBlock = false
    
end

-- 技能待机状态onExit时技能操作
function MonsterSkill60:onExitIdleDo()

end

-- 技能待机状态onUpdate时技能操作
function MonsterSkill60:onUpdateIdleDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能吟唱状态onEnter时技能操作
function MonsterSkill60:onEnterChantDo(state)
    self._pCurState = state
    
    -- 播放攻击时的人物动作
    self:getMaster():playAttackAction(self._nRoleAttackActionIndex)

    -- 人物动作结束
    local roleActOver = function()
        -- 人物动作结束后，可以开始释放下一个技能
        if self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID == kType.kState.kBattleMonster.kSkillAttack then
            self:getMaster():getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._bToNextSkill = true
            self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kRelease)
        end
        
    end
    local duration = self:getMaster():getAttackActionTime(self._nRoleAttackActionIndex)
    self._pSkillActOverActionNode:stopAllActions()
    self._pSkillActOverActionNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(roleActOver)))

    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kProcess)

end

-- 技能吟唱状态onExit时技能操作
function MonsterSkill60:onExitChantDo()

end

-- 技能吟唱状态onUpdate时技能操作
function MonsterSkill60:onUpdateChantDo(dt)

end
-------------------------------------------------------------------------------------------------
-- 技能执行状态onEnter时技能操作
function MonsterSkill60:onEnterProcessDo(state)
    self._pCurState = state
    self:getMaster()._bMustBlock = true  -- 必须格挡

end

-- 技能执行状态onExit时技能操作
function MonsterSkill60:onExitProcessDo()

end

-- 技能执行状态onUpdate时技能操作
function MonsterSkill60:onUpdateProcessDo(dt)

end
-----------------------------------------------------------------------------------------------------
-- 技能释放状态onEnter时技能操作
function MonsterSkill60:onEnterReleaseDo(state)
    self._pCurState = state
    self._pCurState._pOwnerMachine:setCurStateByTypeID(kType.kState.kBattleSkill.kIdle)
    
end

-- 技能释放状态onExit时技能操作
function MonsterSkill60:onExitReleaseDo()

end

-- 技能释放状态onUpdate时技能操作
function MonsterSkill60:onUpdateReleaseDo(dt)

end
---------------------------------------------------------------------------------------------------------
return MonsterSkill60
