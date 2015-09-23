--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StateMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   状态机基类
--===================================================
local StateMachine = class("StateMachine")

-- 构造函数
function StateMachine:ctor()
    self._strName = "StateMachine"              -- 状态机名称
    self._kTypeID = kType.kStateMachine.kNone   -- 状态类机型ID
    self._pMaster = nil                         -- 当前状态机的持有者（主人）
    self._pCurState = nil                       -- 当前状态  
    self._tStates = {}                          -- 状态机中所有状态的集合
end

-- 创建函数
function StateMachine:create(master)
    local machine = StateMachine.new()
    machine:onEnter(master)
    return machine
end

-- 进入函数
function StateMachine:onEnter(master)
    --print(self._strName.." is onEnter!")
    self._pMaster = master
    return
end

-- 退出函数
function StateMachine:onExit()
   -- print(self._strName.." is onExit!")
    if self._pCurState ~= nil then
       self._pCurState:onExit()
    end
    return
end

-- 更新逻辑
function StateMachine:update(dt)
    if self._pCurState ~= nil then
        self._pCurState:update(dt)
    end
    return
end

-- 添加状态到状态机
function StateMachine:addState(pState)
    for k,v in pairs(self._tStates) do
        if v._kTypeID == pState._kTypeID then
           -- print(pState._strName .. " has already exists!")
            return
        end
    end
    --print(pState._strName .. " add success!")
    pState._pOwnerMachine = self
    table.insert(self._tStates,pState)
    return
end

-- 设置当前状态机的状态，force表示是否强制切换状态
function StateMachine:setCurStateByTypeID(id, force, args)
    for k,v in pairs(self._tStates) do
        if v._kTypeID == id then  -- 找到了要切换到的state
            if self._pCurState ~= nil then
                if (force ~= true) and (self._pCurState._kTypeID == id) then
                    return
                end
                self._pCurState:onExit()
            end
            self._pCurState = v
            self._pCurState:onEnter(args)
            return
        end
    end
    
    print("Don't find the state which you want to set as current state!")
    self._pCurState = nil
    return
end

-- 获取当前状态机的持有者
function StateMachine:getMaster()
    return self._pMaster
end

-- 设置当前状态机的持有者
function StateMachine:setMaster(master)
    self._pMaster = master
end

return StateMachine
