--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NewbieManager.lua
-- author:    taoye
-- created:   2015/6/19
-- descrip:   新手引导管理器
--===================================================
NewbieManager = {}

local instance = nil

-- 单例
function NewbieManager:getInstance()
    if not instance then
        instance = NewbieManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function NewbieManager:clearCache()
    self._nCurID = ""                       -- 当前的新手步骤id
    self._pCurInfo = nil                    -- 当前新手步骤info
    self._pCurNewbieLayer = nil             -- 当前新手layer
    self._pLastID = ""                      -- 上一次的新手步骤id
    self._bIsForceGuideForBattle = false    -- 是否为强制性战斗引导
    self._nCurOpenLevel = 1                 -- 目前 已经开启到的等级
    
    self._bSkipGuide = true                 -- 是否跳过剧情动画和所有引导   false为不跳过

end

-- 获取目前已经播放的开放功能等级
function NewbieManager:getMainFuncLevel()
    local temp = cc.UserDefault:getInstance():getIntegerForKey("MainFuncLevel_"..RolesManager:getInstance()._pMainRoleInfo.roleId)
    
    if temp ~= 0 then
        self._nCurOpenLevel = temp
    end
end

-- 设置目前开放功能的等级
function NewbieManager:setMainFuncLevel(level)
    self._nCurOpenLevel = level
    
    cc.UserDefault:getInstance():setIntegerForKey("MainFuncLevel_"..RolesManager:getInstance()._pMainRoleInfo.roleId, self._nCurOpenLevel)
    cc.UserDefault:getInstance():flush()
end

-- 读取是否播放过剧情动画
function NewbieManager:getBePlayStoryAniOrNot()
    if RolesManager:getInstance()._pMainRoleInfo then
        local id = cc.UserDefault:getInstance():getStringForKey("NewbieStory_"..RolesManager:getInstance()._pMainRoleInfo.roleId)
        if id ~= "true" then
            return false
        else
            return true
        end
    end
end

-- 设置永远跳过引导
function NewbieManager:setSkipStory()
    if RolesManager:getInstance()._pMainRoleInfo then
        cc.UserDefault:getInstance():setStringForKey("NewbieSkipStory_"..RolesManager:getInstance()._pMainRoleInfo.roleId, "true")
        cc.UserDefault:getInstance():flush()
        self._bSkipGuide = true
    end
end

-- 获取是否永远跳过引导
function NewbieManager:getSkipStory()
    if self._bSkipGuide == true then
    	return
    end

    if RolesManager:getInstance()._pMainRoleInfo then
        local id = cc.UserDefault:getInstance():getStringForKey("NewbieSkipStory_"..RolesManager:getInstance()._pMainRoleInfo.roleId)
        if id == nil or id == "" then
            self._bSkipGuide = false
        else
            self._bSkipGuide = true
        end
    end
end

-- 设置已经播放过剧情动画
function NewbieManager:setPlayStoryAniOver()
    if RolesManager:getInstance()._pMainRoleInfo then
        cc.UserDefault:getInstance():setStringForKey("NewbieStory_"..RolesManager:getInstance()._pMainRoleInfo.roleId, "true")
        cc.UserDefault:getInstance():setStringForKey("NewbieMainID_"..RolesManager:getInstance()._pMainRoleInfo.roleId, "Guide_1_1")
        cc.UserDefault:getInstance():flush()
    end
end

-- 读取记录过的MainID(每次角色登陆成功后会调用上一次)
function NewbieManager:loadMainID()
    if RolesManager:getInstance()._pMainRoleInfo then
        local id = cc.UserDefault:getInstance():getStringForKey("NewbieMainID_"..RolesManager:getInstance()._pMainRoleInfo.roleId)
        --self:showNewbieByID(id)
        return id
    end
    
    return nil
end

-- 强制关闭引导
function NewbieManager:closeNewbie()
    if self._pCurNewbieLayer then
        self._pCurNewbieLayer:removeFromParent(true)
        self._pCurNewbieLayer = nil
    end
end

-- 判定当前是否正在显示引导相关界面
function NewbieManager:isShowingNewbie()
    if self._pCurNewbieLayer then
        return true
    end
    return false
end

-- 显示指定的引导界面
function NewbieManager:showNewbieByID(id)
    if self._pCurNewbieLayer then
        self._pCurNewbieLayer:removeFromParent(true)
        self._pCurNewbieLayer = nil
    end

    if id and id ~= "" then

        self._nCurID = id
        self._pCurInfo = TableNewbie[self._nCurID]
        
        self._pCurNewbieLayer = require("NewbieLayer"):create(
            self._pCurInfo.IsRunTime, 
            self._pCurInfo.Adaptation,
            cc.p(self._pCurInfo.TouchPosX, self._pCurInfo.TouchPosY),
            self._pCurInfo.ArrowDirection,
            cc.p(self._pCurInfo.TextPosX,self._pCurInfo.TextPosY),
            cc.size(self._pCurInfo.TextSizeWidth,self._pCurInfo.TextSizeHeight),
            self._pCurInfo.TextContent)

        if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
            cc.Director:getInstance():getRunningScene():addChild(self._pCurNewbieLayer,kZorder.kNewbieLayer)
        elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
            cc.Director:getInstance():getRunningScene():addChild(self._pCurNewbieLayer,kZorder.kNewbieLayer)
        end
        
        
        cclog("新手引导:"..self._nCurID)
        
        -- 记录每一步的记录
        if self._pCurInfo then
            MessageCommonUtil:sendMessageSaveNewerPro21308(self._pCurInfo.MainID)
            cc.UserDefault:getInstance():setStringForKey("NewbieMainID_"..RolesManager:getInstance()._pMainRoleInfo.roleId, self._pCurInfo.MainID)
            cc.UserDefault:getInstance():flush()
        end

    end
    
end

function NewbieManager:setMainId(mainId)
    MessageCommonUtil:sendMessageSaveNewerPro21308(mainId)
    cc.UserDefault:getInstance():setStringForKey("NewbieMainID_"..RolesManager:getInstance()._pMainRoleInfo.roleId, mainId)
    cc.UserDefault:getInstance():flush()
end

-- 显示关联的下一个引导界面
function NewbieManager:showNextNewbie()    
    if self._pCurNewbieLayer then
        self._pCurNewbieLayer:removeFromParent(true)
        self._pCurNewbieLayer = nil
    end
    
    local lastID = self._nCurID
    local isForceGuideForBattle = self._bIsForceGuideForBattle
    
    if self._pCurInfo.NextID and self._pCurInfo.NextID ~= "" then        -- 存在后置id
        self._nCurID = self._pCurInfo.NextID
        self._pCurInfo = TableNewbie[self._nCurID]
        
        self._pCurNewbieLayer = require("NewbieLayer"):create(
            self._pCurInfo.IsRunTime, 
            self._pCurInfo.Adaptation,
            cc.p(self._pCurInfo.TouchPosX, self._pCurInfo.TouchPosY),
            self._pCurInfo.ArrowDirection,
            cc.p(self._pCurInfo.TextPosX,self._pCurInfo.TextPosY),
            cc.size(self._pCurInfo.TextSizeWidth,self._pCurInfo.TextSizeHeight),
            self._pCurInfo.TextContent)
        
        if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
            cc.Director:getInstance():getRunningScene():addChild(self._pCurNewbieLayer,kZorder.kNewbieLayer)
        elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
            cc.Director:getInstance():getRunningScene():addChild(self._pCurNewbieLayer,kZorder.kNewbieLayer)
        end
        
        cclog("新手引导:"..self._nCurID)
        
        -- 记录每一步的记录
        if self._pCurInfo then
            MessageCommonUtil:sendMessageSaveNewerPro21308(self._pCurInfo.MainID)
            cc.UserDefault:getInstance():setStringForKey("NewbieMainID_"..RolesManager:getInstance()._pMainRoleInfo.roleId, self._pCurInfo.MainID)
            cc.UserDefault:getInstance():flush()
        end

    else
        cclog("新手引导结束！最近一次id为："..self._nCurID)
        self:clearCache()
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNewbieOver,{})
        --cc.UserDefault:getInstance():setStringForKey("NewbieMainID_"..RolesManager:getInstance()._pMainRoleInfo.roleId, "")
        --cc.UserDefault:getInstance():flush()
    end
    
    -- 记录上一步的id
    self._pLastID = lastID
    -- 是否为强制性战斗引导
    self._bIsForceGuideForBattle = isForceGuideForBattle

end

-- 显示结束(非即时操作时使用，在网络回调的确认位置添加即可)
function NewbieManager:showOutAndRemoveWithRunTime(guideIds)
    if guideIds == nil or table.getn(guideIds) == 0 then
        if self._pCurNewbieLayer then
            self._pCurNewbieLayer:showOutAndRemove()
        end
    else
        for i=1,table.getn(guideIds) do
            if guideIds[i] == self._nCurID then
                if self._pCurNewbieLayer then
                    self._pCurNewbieLayer:showOutAndRemove()
                end
                return
        	end
        end
    end
end

