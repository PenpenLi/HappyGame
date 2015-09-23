--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Operate.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/5/7
-- descrip:   操作基类（用于任务中的操作队列）
--===================================================
local Operate = class("Operate")

-- 构造函数
function Operate:ctor()
    self._strName = "Operate"      -- 操作名称
    self._bIsOver = false          -- 操作是否已经结束（需要的时候设置为true，表示当前操作结束）
    self._bException = false       -- 是否发生异常中断（一旦发生异常中断，则立即取消当前任务中的操作队列）
    
end

-- 创建函数
function Operate:create()
    local op = Operate.new()
    return op
end

-- 开始
function Operate:onBaseEnter()
    
    return
end

-- 结束
function Operate:onBaseExit()
    
    return
end

-- 循环更新
function Operate:onBaseUpdate(dt)

    return
end

-- 复位
function Operate:baseReset()
    self._bIsOver = false
    self._bException = false
    return
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取关卡管理器
function Operate:getStagesManager() 
    if self._pStagesManager == nil then
        self._pStagesManager = StagesManager:getInstance()
    end
    return self._pStagesManager
end

-- 获取战斗管理器
function Operate:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function Operate:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function Operate:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function Operate:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function Operate:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function Operate:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function Operate:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function Operate:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function Operate:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取剧情对话管理器
function Operate:getTalksManager() 
    if self._pTalksManager == nil then
        self._pTalksManager = TalksManager:getInstance()
    end
    return self._pTalksManager
end

-- 获取任务管理器
function Operate:getTasksManager() 
    if self._pTasksManager == nil then
        self._pTasksManager = TasksManager:getInstance()
    end
    return self._pTasksManager
end

-- 获取邮件管理器
function Operate:getEmailManager() 
    if self._pEmailManager == nil then
        self._pEmailManager = EmailManager:getInstance()
    end
    return self._pEmailManager
end

-- 获取Buff管理器
function Operate:getBuffManager() 
    if self._pBuffManager == nil then
        self._pBuffManager = BuffManager:getInstance()
    end
    return self._pBuffManager
end

-- 获取战斗AI管理器
function Operate:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

-- 获取CD管理器
function Operate:getCDManager() 
    if self._pCDManager == nil then
        self._pCDManager = CDManager:getInstance()
    end
    return self._pCDManager
end

-- 获取聊天管理器
function Operate:getChatManager() 
    if self._pChatManager == nil then
        self._pChatManager = ChatManager:getInstance()
    end
    return self._pChatManager
end
--------------------------------------------------------------------------------------------------------------

return Operate
