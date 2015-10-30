--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OptionDialog.lua
-- author:    liyuhang
-- created:   2015/7/14
-- descrip:   设置面板
--===================================================

local OptionDialog = class("OptionDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function OptionDialog:ctor()
    -- 层名字
    self._strName = "OptionDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil    
    
    self._nType =  kOptionType.NoneOption 

    self.params = nil
    
    self._pCheckBoxBg = nil
end

-- 创建函数
function OptionDialog:create(args)
    local layer = OptionDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function OptionDialog:dispose(args)

    NetRespManager:getInstance():addEventListener(kNetCmd.kOtherPlayerInfos, handler(self, self.otherPlayersNetBack))
    
    -- 加载合图资源
    ResPlistManager:getInstance():addSpriteFrames("SetSystemDialog.plist")

    if args[1] ~= nil then
        self._nType = args[1]
    end
    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitOptionDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function OptionDialog:initUI()
    -- 加载组件
    local params = require("SetSystemDialogParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    if self._nType == kOptionType.LoginOption then
        --退出游戏按钮
        self.params._pExitGameButton:setEnabled(false)
        darkNode(self.params._pExitGameButton:getVirtualRenderer():getSprite())
        --返回游戏按钮
        self.params._pGoGameButton:setEnabled(false)
        darkNode(self.params._pGoGameButton:getVirtualRenderer():getSprite())
    end
    
    if isIOSMobilePlatform() == true then
        self.params._pShakeButton:setVisible(false)
        self.params._pShakeText:setVisible(false)
    end
    
    -----------------------------------------------
    self.params._pMusicButton:loadTextures(
        OptionManager:getInstance()._bOpenMusic == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bOpenMusic == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bOpenMusic == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        ccui.TextureResType.plistType)
        
    self.params._pSoundEffectButton:loadTextures(
        OptionManager:getInstance()._bOpenSoundEffect == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bOpenSoundEffect == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bOpenSoundEffect == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        ccui.TextureResType.plistType)
        
    self.params._pNameButton:loadTextures(
        OptionManager:getInstance()._bPlayersNameShowOrNot == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bPlayersNameShowOrNot == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bPlayersNameShowOrNot == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        ccui.TextureResType.plistType)
        
    self.params._pRockerButton:loadTextures(
        OptionManager:getInstance()._bStickLock == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bStickLock == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bStickLock == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        ccui.TextureResType.plistType)
        
    self.params._pShakeButton:loadTextures(
        OptionManager:getInstance()._bShake == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bShake == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        OptionManager:getInstance()._bShake == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
        ccui.TextureResType.plistType)
    
    self:updatePlayerShowLevel()
    -----------------------------------------------
    -- 音乐按钮
    self.params._pMusicButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._bOpenMusic == true then
            	OptionManager:setOptionMusic(false)
            else
                OptionManager:setOptionMusic(true)
                AudioManager:getInstance():replayMusic()
            end
            
            self.params._pMusicButton:loadTextures(
                OptionManager:getInstance()._bOpenMusic == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bOpenMusic == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bOpenMusic == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                ccui.TextureResType.plistType)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    -- 音效按钮
    self.params._pSoundEffectButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._bOpenSoundEffect == true then
                OptionManager:setOptionSoundEffect(false)
            else
                OptionManager:setOptionSoundEffect(true)
            end
            
            self.params._pSoundEffectButton:loadTextures(
                OptionManager:getInstance()._bOpenSoundEffect == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bOpenSoundEffect == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bOpenSoundEffect == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                ccui.TextureResType.plistType)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    -- 昵称显示按钮
    self.params._pNameButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._bPlayersNameShowOrNot == true then
                OptionManager:setOptionPlayersNameShow(false)
            else
                OptionManager:setOptionPlayersNameShow(true)
            end
            
            self.params._pNameButton:loadTextures(
                OptionManager:getInstance()._bPlayersNameShowOrNot == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bPlayersNameShowOrNot == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bPlayersNameShowOrNot == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                ccui.TextureResType.plistType)
            
            -- 刷新当前在线玩家昵称显示
            self:updateRolesNameShow()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            
        end
    end)
    -- 锁定摇杆
    self.params._pRockerButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._bStickLock == true then
                OptionManager:setOptionStickLock(false)
            else
                OptionManager:setOptionStickLock(true)
            end
            
            self.params._pRockerButton:loadTextures(
                OptionManager:getInstance()._bStickLock == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bStickLock == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bStickLock == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                ccui.TextureResType.plistType)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    -- 手机震动
    self.params._pShakeButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._bShake == true then
                OptionManager:setOptionShake(false)
            else
                OptionManager:setOptionShake(true)
            end
            
            self.params._pShakeButton:loadTextures(
                OptionManager:getInstance()._bShake == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bShake == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                OptionManager:getInstance()._bShake == true and "SetSystemDialogRes/szjm1.png" or "SetSystemDialogRes/szjm2.png",
                ccui.TextureResType.plistType)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self.params._pLowButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._nPlayersRoleShowLevel ~= 3 then
            	OptionManager:setOptionShowLevel(3)
                self:updatePlayerShowLevel()
                self:requestOtherPlayersInfos()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    self.params._pMidButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._nPlayersRoleShowLevel ~= 2 then
                OptionManager:setOptionShowLevel(2)
                self:updatePlayerShowLevel()
                self:requestOtherPlayersInfos()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    self.params._pHeighButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if OptionManager:getInstance()._nPlayersRoleShowLevel ~= 1 then
                OptionManager:setOptionShowLevel(1)
                self:updatePlayerShowLevel()
                self:requestOtherPlayersInfos()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    -- 退出游戏
    self.params._pExitGameButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            disconnect()
            cc.Director:getInstance():getRunningScene()._bSkipHeartBeat = true
            LoginManager:getInstance()._tCurSessionId = nil
            self:getGameScene():closeDialogByNameWithNoAni("OptionDialog")
            LayerManager:getInstance():gotoRunningSenceLayer(LOGIN_SENCE_LAYER)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
           
        end
    end)
    
    -- 返回游戏
    self.params._pGoGameButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            self:close()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    -- 论坛入口
    self.params._pGmButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            local id = mmo.HelpFunc:getPlatform()
            if id < 0 then
            	return
            end
        
            cc.Application:getInstance():openURL(strForceDownloadApkHyperlink[id])
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    self:disposeCSB()
end

function OptionDialog:updatePlayerShowLevel()
     if self._pCheckBoxBg ~= nil then
     	self._pCheckBoxBg:removeFromParent()
     	self._pCheckBoxBg = nil
     end   
        
    self._pCheckBoxBg = cc.Sprite:createWithSpriteFrameName("SetSystemDialogRes/jsjm_014.png")
    
    if OptionManager:getInstance()._nPlayersRoleShowLevel == 3 then
        self.params._pLowButton:addChild(self._pCheckBoxBg)
        self._pCheckBoxBg:setPosition(self.params._pLowButton:getContentSize().width/2,self.params._pLowButton:getContentSize().height/2)
    elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 2 then
        self.params._pMidButton:addChild(self._pCheckBoxBg)
        self._pCheckBoxBg:setPosition(self.params._pMidButton:getContentSize().width/2,self.params._pMidButton:getContentSize().height/2)
    elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 1 then
        self.params._pHeighButton:addChild(self._pCheckBoxBg)
        self._pCheckBoxBg:setPosition(self.params._pHeighButton:getContentSize().width/2,self.params._pHeighButton:getContentSize().height/2)
    end
    
end

-- 请求在线玩家数据
function OptionDialog:requestOtherPlayersInfos()
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        -- 移除所有其他玩家和其他玩家的宠物
        RolesManager:getInstance():removeAllOtherPlayerRolesOnWorldMap()
        PetsManager:getInstance():removeAllOtherPetRolesOnWorldMap()

        -- 请求在线玩家
        local args = nil
        if OptionManager:getInstance()._nPlayersRoleShowLevel == 3 then
            args = {count=TableConstants.SameScreenMin.Value}
        elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 2 then
            args = {count=TableConstants.SameScreenMid.Value}
        elseif OptionManager:getInstance()._nPlayersRoleShowLevel == 1 then
            args = {count=TableConstants.SameScreenMax.Value}
        end
        OtherPlayersCGMessage:sendMessageOtherPlayers(args)
    end
end

-- 其他玩家数据返回（网络回调）
function OptionDialog:otherPlayersNetBack(event)
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        -- 创建其他玩家
        self:getRolesManager():createOtherPlayerRoleOnMap()
        -- 创建其他玩家的宠物
        self:getPetsManager():createOtherPetRolesOnMap()
        -- 刷新相机
        MapManager:getInstance()._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
    end
end

-- 刷新当前在线玩家名称显示
function OptionDialog:updateRolesNameShow()
    local visible = OptionManager:getInstance()._bPlayersNameShowOrNot
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then
        self:getRolesManager()._pMainPlayerRole._pName:setVisible(visible)
        if self:getPetsManager()._pMainPetRole then
            self:getPetsManager()._pMainPetRole._pName:setVisible(visible)
        end
        for k,v in pairs(self:getRolesManager()._tOtherPlayerRoles) do 
            v._pName:setVisible(visible)
        end
        for k,v in pairs(self:getPetsManager()._tOtherPetRoles) do 
            v._pName:setVisible(visible)
        end
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        self:getRolesManager()._pMainPlayerRole._pName:setVisible(visible)
        if self:getPetsManager()._pMainPetRole then
            self:getPetsManager()._pMainPetRole._pName:setVisible(visible)
        end
        if self:getRolesManager()._pPvpPlayerRole then
            self:getRolesManager()._pPvpPlayerRole._pName:setVisible(visible)
        end
        if self:getPetsManager()._pPvpPetRole then
            self:getPetsManager()._pPvpPetRole._pName:setVisible(visible)
        end
        for k,v in pairs(self:getRolesManager()._tOtherPlayerRoles) do 
            v._pName:setVisible(visible)
        end
        for k,v in pairs(self:getPetsManager()._tOtherPetRoles) do 
            v._pName:setVisible(visible)
        end
    end

end

-- 初始化触摸相关
function OptionDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

-- 退出函数
function OptionDialog:onExitOptionDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("SetSystemDialog.plist")
end

return OptionDialog