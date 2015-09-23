--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  Dialog.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   对话框基类
--===================================================
local Dialog = class("Dialog",function()
    return cc.Layer:create()
end)

-- 构造函数
function Dialog:ctor()
    self._strName = "Dialog"        -- 对话框名称
    self._pCCS = nil                -- 对话框ccs结点
    self._pBg = nil                 -- 背景框（Sprite）
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形
    self._pCloseButton = nil        -- 关闭按钮
    self._pTouchListener = nil      -- 触摸监听器
    
    self._bIsNeedCache = false

    self._pIgnoreTouchLayer = require("NoTouchLayer"):create()   -- 加载触摸屏蔽层
    self:addChild(self._pIgnoreTouchLayer,kZorder.kLayer)
    
    self._bShowOver = false
end

-- 创建函数
function Dialog:create()
    local dialog = Dialog.new()
    dialog:dispose()
    return dialog
end

-- 处理函数
function Dialog:dispose()
--[[
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end ".."x="..location.x.."  y="..location.y)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
]]
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function Dialog:onExitDialog()
    print(self._strName.." onExit!")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function Dialog:update(dt)

end

-- 加载框体
function Dialog:disposeCSB()
    -- 添加结点
    local sNode = self._pCCS:getContentSize()
    local sScreen = mmo.VisibleRect:getVisibleSize()
    self._pCCS:setPosition(sScreen.width/2, sScreen.height/2)
    self:addChild(self._pCCS)
    -- 初始化背景
    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)
    -- 关闭按钮回调函数
    local function closeButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:close()
            NewbieManager:getInstance():showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    -- 给关闭按钮添加监听机制
    self._pCloseButton:addTouchEventListener(closeButtonCallBack)
    self._pCloseButton:setZoomScale(nButtonZoomScale)  
    self._pCloseButton:setPressedActionEnabled(true)
end

function Dialog:setTouchEnableInDialog( beTouchEnable )
    self._pIgnoreTouchLayer._pTouchListener:setEnabled(beTouchEnable)
end

function Dialog:setNeedCache( args )
    self._bIsNeedCache = args
end

-- 显示（带动画）
function Dialog:showWithAni()
    self:setVisible(true)
    self:stopAllActions()
    self:setScale(0)
    
    if self._pTouchListener then
        self._pTouchListener:setSwallowTouches(true)
        self._pTouchListener:setEnabled(true)
    end

    local showOver = function()
        self:doWhenShowOver()
        self._bShowOver = true
    end
    
    local action = cc.Sequence:create(
        cc.EaseSineInOut:create(cc.ScaleTo:create(0.2,1,1)),
        cc.CallFunc:create(showOver))
        --[[
    local action = cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(showOver))
        ]]
    self:runAction(action)
end

function Dialog:updateCacheWithData(args)
	
end

-- 显示隐藏dialog
function Dialog:showCacheWithAni()
    print("------------------------------------  showCacheWithAni")
    local showOver = function()
        if self._pTouchListener then
            self._pTouchListener:setSwallowTouches(true)
            self._pTouchListener:setEnabled(true)
        end
        self._bShowOver = true
    end
    
    self:setVisible(true)
    if self._pTouchListener then
        self._pTouchListener:setSwallowTouches(true)
        self._pTouchListener:setEnabled(true)
    end
    self:stopAllActions()

    self:setScale(0)
    --local action = cc.EaseSineInOut:create(cc.ScaleTo:create(0.2,1,1))

    local action = cc.Sequence:create(
        cc.EaseSineInOut:create(cc.ScaleTo:create(0.2,1,1)),
        cc.CallFunc:create(showOver))

    self:runAction(action)
    
end

-- 隐藏 （带动画）
function Dialog:hiddenWithAni()
    self:stopAllActions()
    
    if self._pTouchListener then
        self._pTouchListener:setEnabled(false)
        self._pTouchListener:setSwallowTouches(false)
    end
    self._bShowOver = false
    
    local closeOver = function()
        self:setVisible(false)
        self:getGameScene():checkMaskBg()
    end
    local action = cc.Sequence:create(
        cc.EaseSineInOut:create(cc.ScaleTo:create(0.2,0,0)),
        cc.CallFunc:create(closeOver))
    --[[
    local action = cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(closeOver))   
        ]] 
    self:runAction(action) 
end

-- 关闭（带动画）
function Dialog:closeWithAni()
    self:stopAllActions()
    if self._pTouchListener then
        self._pTouchListener:setEnabled(false)
        self._pTouchListener:setSwallowTouches(false)
    end
    
    self:setTouchEnableInDialog(true)
    
    local closeOver = function()
        self:doWhenCloseOver()
        self:removeFromParent(true)
    end
    local action = cc.Sequence:create(
        cc.EaseSineInOut:create(cc.ScaleTo:create(0.2,0,0)),
        cc.CallFunc:create(closeOver))
        --[[
    local action = cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(closeOver))    
        ]]
    self:runAction(action) 
end

-- 关闭（不带动画）
function Dialog:closeWithNoAni()
    self:stopAllActions()
    if self._pTouchListener then
        self._pTouchListener:setEnabled(false)
        self._pTouchListener:setSwallowTouches(false)
    end
    self:setTouchEnableInDialog(true)
    self:doWhenCloseOver()
    self:removeFromParent(true)

end


-- 关闭函数
function Dialog:close()
    --self:getGameScene():closeDialog(self)
    if self._bIsNeedCache == true then
        self:getGameScene():hiddenDialog(self)
    else
        self:getGameScene():closeDialog(self)
    end
end

-- 获取游戏场景
function Dialog:getGameScene()
    return self:getParent()
end

-- 显示结束时的回调
function Dialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function Dialog:doWhenCloseOver()
    return
end

--------------------------------------------获取管理器相关-------------------------------------------------
-- 获取关卡管理器
function Dialog:getStagesManager() 
    if self._pStagesManager == nil then
        self._pStagesManager = StagesManager:getInstance()
    end
    return self._pStagesManager
end

-- 获取战斗管理器
function Dialog:getBattleManager() 
    if self._pBattleManager == nil then
        self._pBattleManager = BattleManager:getInstance()
    end
    return self._pBattleManager
end

-- 获取实体管理器
function Dialog:getEntitysManager() 
    if self._pEntitysManager == nil then
        self._pEntitysManager = EntitysManager:getInstance()
    end
    return self._pEntitysManager
end

-- 获取地图管理器
function Dialog:getMapManager() 
    if self._pMapManager == nil then
        self._pMapManager = MapManager:getInstance()
    end
    return self._pMapManager
end

-- 获取野怪管理器
function Dialog:getMonstersManager() 
    if self._pMonstersManager == nil then
        self._pMonstersManager = MonstersManager:getInstance()
    end
    return self._pMonstersManager
end

-- 获取矩形管理器
function Dialog:getRectsManager() 
    if self._pRectsManager == nil then
        self._pRectsManager = RectsManager:getInstance()
    end
    return self._pRectsManager
end

-- 获取角色管理器
function Dialog:getRolesManager() 
    if self._pRolesManager == nil then
        self._pRolesManager = RolesManager:getInstance()
    end
    return self._pRolesManager
end

-- 获取宠物角色管理器
function Dialog:getPetsManager() 
    if self._pPetsManager == nil then
        self._pPetsManager = PetsManager:getInstance()
    end
    return self._pPetsManager
end

-- 获取技能管理器
function Dialog:getSkillsManager() 
    if self._pSkillsManager == nil then
        self._pSkillsManager = SkillsManager:getInstance()
    end
    return self._pSkillsManager
end

-- 获取触发器管理器
function Dialog:getTriggersManager() 
    if self._pTriggersManager == nil then
        self._pTriggersManager = TriggersManager:getInstance()
    end
    return self._pTriggersManager
end

-- 获取剧情对话管理器
function Dialog:getTalksManager() 
    if self._pTalksManager == nil then
        self._pTalksManager = TalksManager:getInstance()
    end
    return self._pTalksManager
end

-- 获取任务管理器
function Dialog:getTasksManager() 
    if self._pTasksManager == nil then
        self._pTasksManager = TasksManager:getInstance()
    end
    return self._pTasksManager
end

-- 获取邮件管理器
function Dialog:getEmailManager() 
    if self._pEmailManager == nil then
        self._pEmailManager = EmailManager:getInstance()
    end
    return self._pEmailManager
end

-- 获取Buff管理器
function Dialog:getBuffManager() 
    if self._pBuffManager == nil then
        self._pBuffManager = BuffManager:getInstance()
    end
    return self._pBuffManager
end

-- 获取战斗AI管理器
function Dialog:getAIManager() 
    if self._pAIManager == nil then
        self._pAIManager = AIManager:getInstance()
    end
    return self._pAIManager
end

-- 获取CD管理器
function Dialog:getCDManager() 
    if self._pCDManager == nil then
        self._pCDManager = CDManager:getInstance()
    end
    return self._pCDManager
end

-- 获取聊天管理器
function Dialog:getChatManager() 
    if self._pChatManager == nil then
        self._pChatManager = ChatManager:getInstance()
    end
    return self._pChatManager
end
--------------------------------------------------------------------------------------------------------------

return Dialog
