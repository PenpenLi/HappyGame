--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattlePassiveController.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/3/25
-- descrip:   所有战斗被动技能控制
--===================================================
local BattlePassiveController = class("BattlePassiveController",function()
    return require("Controller"):create()
end)

-- 构造函数
function BattlePassiveController:ctor()
    self._strName = "BattlePassiveController"           -- Passive对象名称
    self._kTypeID = kType.kController.kNone             -- 控制类机型ID
    self._pMaster = nil                                 -- 当前Passive的持有者（Role）
    self._pPassiveInfo = nil                            -- Passive表数据
    
end

-- 创建函数
function BattlePassiveController:create(master, passiveInfo)
    local controller = BattlePassiveController.new()
    controller:dispose(master, passiveInfo)
    return controller
end

-- 处理函数
function BattlePassiveController:dispose(master, passiveInfo)    
    -- 设置buff通用信息 
    self._pMaster = master
    self._pPassiveInfo = passiveInfo

    return
end

-- 进入函数
function BattlePassiveController:onEnter()

    return
end

-- 退出函数
function BattlePassiveController:onExit()

    return
end

-- 循环更新
function BattlePassiveController:updateBattlePassive(dt)

end

-- 获取技能的主人
function BattlePassiveController:getMaster() 
    return self._pMaster
end

-- 设置当前状态机的持有者
function BattlePassiveController:setMaster(master)
    self._pMaster = master
end

-- 手动取消buff
function BattlePassiveController:cancel() 
    if self._bEnable == true then
        self._bEnable = false
    end
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function BattlePassiveController:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function BattlePassiveController:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function BattlePassiveController:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function BattlePassiveController:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function BattlePassiveController:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function BattlePassiveController:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function BattlePassiveController:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function BattlePassiveController:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function BattlePassiveController:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取战斗AI管理器
function BattlePassiveController:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

--------------------------------------------------------------------------------------------------------------

return BattlePassiveController
