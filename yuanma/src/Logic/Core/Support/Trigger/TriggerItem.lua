--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TriggerItem.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   触发器动作项基类
--===================================================
local TriggerItem = class("TriggerItem")

-- 构造函数
function TriggerItem:ctor()
    self._pOwnerTrigger = nil                  -- 触发器动作项所归属的触发器
    self._kType = kType.kTriggerItemType.kNone -- 触发器动作项的类型
    self._nIndex = 0                           -- 用来标记在队列中是第几个动作，从1开始计数
    
end

-- 创建函数
function TriggerItem:create()
    local item = TriggerItem.new()
    return item
end

-- 作用函数
function TriggerItem:work()
-- override
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取战斗管理器
function TriggerItem:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function TriggerItem:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function TriggerItem:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function TriggerItem:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function TriggerItem:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function TriggerItem:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function TriggerItem:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function TriggerItem:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function TriggerItem:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取关卡管理器
function TriggerItem:getStagesManager() 
    if self._pStagesManager == nil then
        self._pStagesManager = StagesManager:getInstance()
    end
    return self._pStagesManager
end

-- 获取剧情对话管理器
function TriggerItem:getTalksManager() 
    if self._pTalksManager == nil then
        self._pTalksManager = TalksManager:getInstance()
    end
    return self._pTalksManager
end

-- 获取邮件管理器
function TriggerItem:getEmailManager() 
    if self._pEmailManager == nil then
        self._pEmailManager = EmailManager:getInstance()
    end
    return self._pEmailManager
end

-- 获取Buff管理器
function TriggerItem:getBuffManager() 
    if self._pBuffManager == nil then
        self._pBuffManager = BuffManager:getInstance()
    end
    return self._pBuffManager
end

-- 获取战斗AI管理器
function TriggerItem:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

-- 获取CD管理器
function TriggerItem:getCDManager() 
    if self._pCDManager == nil then
        self._pCDManager = CDManager:getInstance()
    end
    return self._pCDManager
end

-- 获取聊天管理器
function TriggerItem:getChatManager() 
    if self._pChatManager == nil then
        self._pChatManager = ChatManager:getInstance()
    end
    return self._pChatManager
end
--------------------------------------------------------------------------------------------------------------

return TriggerItem
