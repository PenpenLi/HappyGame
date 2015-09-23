--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleBuffController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/12
-- descrip:   所有战斗Buff基类
--===================================================
local BattleBuffController = class("BattleBuffController",function()
    return require("Controller"):create()
end)

-- 构造函数
function BattleBuffController:ctor()
    self._strName = "BattleBuffController"              -- Buff对象名称
    self._strAniName = ""                               -- 动画资源名称
    self._kTypeID = kType.kController.kBuff.kNone       -- 控制类机型ID
    self._pMaster = nil                                 -- 当前Buff的持有者（Role）
    self._pBuffInfo = nil                               -- Buff表数据
    self._pAni = nil                                    -- 动画   
    self._pAniParent = nil                              -- 动画父节点
    self._pAniPos = nil                                 -- 动画位置
    self._pColor = nil                                  -- 当前buff的颜色
    
end

-- 创建函数
function BattleBuffController:create(master, buffInfo)
    local controller = BattleBuffController.new()
    controller:dispose(master, buffInfo)
    return controller
end

-- 处理函数
function BattleBuffController:dispose(master, buffInfo)    
    -- 设置buff通用信息 
    self._pMaster = master
    self._pBuffInfo = buffInfo
    

    return
end

-- 进入函数
function BattleBuffController:onEnter()

    return
end

-- 退出函数
function BattleBuffController:onExit()

    return
end

-- 循环更新
function BattleBuffController:updateBattleBuff(dt)
    if self._pAniPos then
        if self._pAniParent then
            self._pAniParent:setPosition(self._pAniPos())
        else
            self._pAni:setPosition(self._pAniPos())
        end
    end
end

-- 获取技能的主人
function BattleBuffController:getMaster() 
    return self._pMaster
end

-- 设置当前状态机的持有者
function BattleBuffController:setMaster(master)
    self._pMaster = master
end

-- 手动取消buff
function BattleBuffController:cancel() 

end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function BattleBuffController:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function BattleBuffController:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function BattleBuffController:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function BattleBuffController:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function BattleBuffController:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function BattleBuffController:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function BattleBuffController:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function BattleBuffController:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function BattleBuffController:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取战斗AI管理器
function BattleBuffController:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

--------------------------------------------------------------------------------------------------------------

return BattleBuffController
