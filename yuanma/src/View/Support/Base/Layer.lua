--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Layer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   层基类
--===================================================
local Layer = class("Layer",function()
    return cc.Layer:create()
end)

-- 构造函数
function Layer:ctor()
    self._strName = "Layer"               -- 层名称
    self._pTouchListener = nil          -- 触摸监听器
    
    self._pIgnoreTouchLayer = require("NoTouchLayer"):create()   -- 加载触摸屏蔽层
    self:addChild(self._pIgnoreTouchLayer,kZorder.kSystemMessageLayer)
end

-- 创建函数
function Layer:create()
    local layer = Layer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function Layer:dispose()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function Layer:onExitLayer()
    print(self._strName.." onExit!")
end

-- 循环更新
function Layer:update(dt)

end

-- 显示（带动画）
function Layer:showWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:setVisible(true)
    self:stopAllActions()

    local pPreposMask = cc.Layer:create()
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)

    local showOver = function()
        self:doWhenShowOver()
        if self._pTouchListener ~= nil then
            self._pTouchListener:setEnabled(true)
        end
        pPreposMask:removeFromParent(true)
    end
    pPreposMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(showOver)))
    return
end


-- 关闭（带动画）
function Layer:closeWithAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end

    self:stopAllActions()
    
    local closeOver = function()
        self:doWhenCloseOver()
        self:removeFromParent(true)
    end
    local pPreposMask = cc.Layer:create()
    self:addChild(pPreposMask,kZorder.kPreposMaskLayer)
    pPreposMask:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(closeOver)))

    return
end

-- 关闭（不带动画）
function Layer:closeWithNoAni()
    if self._pTouchListener ~= nil then
        self._pTouchListener:setEnabled(false)
    end
    self:stopAllActions()
    self:doWhenCloseOver()
    self:removeFromParent(true)
    return
end

-- 关闭函数
function Layer:close()
    self:getGameScene():closeLayer(self)
end

function Layer:setTouchEnableInDialog( beTouchEnable )
    self._pIgnoreTouchLayer._pTouchListener:setEnabled(beTouchEnable)
end

-- 获取游戏场景对象
function Layer:getGameScene()
    return cc.Director:getInstance():getRunningScene()
end

-- 显示结束时的回调
function Layer:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function Layer:doWhenCloseOver()
    return
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取关卡管理器
function Layer:getStagesManager() 
    if self._pStagesManager == nil then
        self._pStagesManager = StagesManager:getInstance()
    end
    return self._pStagesManager
end

-- 获取战斗管理器
function Layer:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function Layer:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function Layer:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function Layer:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function Layer:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function Layer:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function Layer:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function Layer:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function Layer:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取剧情对话管理器
function Layer:getTalksManager() 
    if self._pTalksManager == nil then
        self._pTalksManager = TalksManager:getInstance()
    end
    return self._pTalksManager
end

-- 获取任务管理器
function Layer:getTasksManager() 
    if self._pTasksManager == nil then
        self._pTasksManager = TasksManager:getInstance()
    end
    return self._pTasksManager
end

-- 获取邮件管理器
function Layer:getEmailManager() 
    if self._pEmailManager == nil then
        self._pEmailManager = EmailManager:getInstance()
    end
    return self._pEmailManager
end

-- 获取Buff管理器
function Layer:getBuffManager() 
    if self._pBuffManager == nil then
        self._pBuffManager = BuffManager:getInstance()
    end
    return self._pBuffManager
end

-- 获取战斗AI管理器
function Layer:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

-- 获取CD管理器
function Layer:getCDManager() 
    if self._pCDManager == nil then
        self._pCDManager = CDManager:getInstance()
    end
    return self._pCDManager
end

-- 获取聊天管理器
function Layer:getChatManager() 
    if self._pChatManager == nil then
        self._pChatManager = ChatManager:getInstance()
    end
    return self._pChatManager
end

-- 获取目标管理器
function Layer:getPurposeManager() 
    if self._pPurposeManager == nil then
        self._pPurposeManager = PurposeManager:getInstance()
    end
    return self._pPurposeManager
end

-- 获取消息管理器
function Layer:getNoticeManager() 
    if self._pNoticeManager == nil then
        self._pNoticeManager = NoticeManager:getInstance()
    end
    return self._pNoticeManager
end

-- 获取剧情的管理器
function Layer:getStoryGuideManager() 
    if self._pStoryGuideManager == nil then
        self._pStoryGuideManager = StoryGuideManager:getInstance()
    end
    return self._pStoryGuideManager
end
--------------------------------------------------------------------------------------------------------------

return Layer
