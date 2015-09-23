--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ControllerMachine.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   控制机基类
--===================================================
local ControllerMachine = class("ControllerMachine")

-- 构造函数
function ControllerMachine:ctor()
    self._strName = "ControllerMachine"              -- 控制机名称
    self._kTypeID = kType.kControllerMachine.kNone   -- 控制类机型ID
    self._pMaster = nil                              -- 控制机的持有者（主人）
    self._bEnable = true                             -- 是否可用（默认：可用）
    self._tControllers = {}                          -- 控制机中所有控制的集合(格式：键：控制typeID  值：控制)

end

-- 创建函数
function ControllerMachine:create()
    local machine = ControllerMachine.new()
    machine:onEnter()
    return machine
end

-- 进入函数
function ControllerMachine:onEnter()
    print(self._strName.." is onEnter!")
    return
end

-- 退出函数
function ControllerMachine:onExit()
    print(self._strName.." is onExit!")
    for k,v in pairs(self._tControllers) do
        if v._bEnable == true then
            v:onExit()
            v._pMaster = nil
            v._pAni = nil
            v._pAniParent = nil
        end
    end
    self._pMaster = nil
    return   
end

-- 更新逻辑
function ControllerMachine:update(dt)
    for k,v in pairs(self._tControllers) do
        if v._bEnable == false then
            self:removeControllerByIndex(k)
            break
        end
    end
    
    for k,v in pairs(self._tControllers) do
        if v._bEnable == true then
            v:update(dt)
        end
    end 
    
    return
end

-- 添加控制到控制机
function ControllerMachine:addController(pController)
    table.insert(self._tControllers, pController)
    pController._pOwnerMachine = self
    pController:onEnter()
    return
end

-- 根据_nID从控制机中移除控制
function ControllerMachine:removeControllerByID(id)
    for k,v in pairs(self._tControllers) do
        if v._nID == id then
            v:onExit()
            table.remove(self._tControllers, k)
            break
        end    
    end
    return
end

-- 根据队列中的index从控制机中移除控制
function ControllerMachine:removeControllerByIndex(idx)
    self._tControllers[idx]:onExit()
    table.remove(self._tControllers, idx)
    return
end

-- 根据typeID从控制机中获取控制
function ControllerMachine:getControllerByID(id)
    for k,v in pairs(self._tControllers) do
        if v._nID == id then
            return v
        end    
    end
    return 0
end

-- 设置控制机是否可用
function ControllerMachine:setEnable(enable)
	if(self._bEnable == enable) then return end

    self._bIsEnable = enable
    
    if self._bIsEnable == true then 
        print(self._strName.." is Enabled!")
        for k,v in pairs(self._tControllers) do 
            if v._bEnable == true then
                v:onEnter()
            end
        end
    else
        print(self._strName.." is UnEnabled!")
        for k,v in pairs(self._tControllers) do 
            if v._bEnable == true then
                v:onExit()
            end
        end
    end
end

-- 设置控制机的持有者
function ControllerMachine:setMaster(pMaster)
    self._pMaster = pMaster
end

-- 获取控制机的持有者
function ControllerMachine:getMaster()
    return self._pMaster
end

return ControllerMachine
