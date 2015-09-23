--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldFuncBtn.lua
-- author:    wuquandong 
-- e-mail:    365667276@qq.com
-- created:   2015/1/27
-- descrip:   主UI 功能图标
--===================================================
local WorldFuncBtn = class("WorldFuncBtn",function()
	return cc.Layer:create()
end)

local STATE_ABLE = 1
local STATE_DISABLE = 2

-- 构造函数
function WorldFuncBtn:ctor()
	self._strName = "WorldFuncBtn" 
    self._pTouchListener = nil
	-- 展示相关、
	self._pIconSprite = nil      -- 图标
    self._pIconSpritePress = nil -- 按下图标
	self._pNameLbl = nil
	--  数据相关
	self._nFuncInfo = nil -- func info 

	self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

	self._fCallback = nil
	
	self._pDisablePoint = nil
	self._pAblePoint = nil
	self._bDisableShowOrNot = false
	self._bKeyPress = false
	self._bTouchAble = true

	self._kState = STATE_DISABLE
	
    self._moveToPoint = cc.p(0,13)
	
	self._sKeyName = ""
end

-- 创建函数
function WorldFuncBtn:create(info)
	local button = WorldFuncBtn.new()
    button:dispose(info)
	return button
end

function WorldFuncBtn:dispose(info)
	self._nFuncInfo = info
    self._sKeyName = info.Desc
    
    NetRespManager:getInstance():addEventListener(kNetCmd.kFuncWarning, handler(self, self.handleMsgWarning))
	
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			self:callbackFunc(sender,eventType)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	
	self._pIconSprite = cc.Sprite:createWithSpriteFrameName("MainIcon/" .. self._nFuncInfo.Icon .. ".png")
    self._pIconSprite:setPosition(0,0)
    self._pIconSprite:setAnchorPoint(cc.p(0, 0))
    self:addChild(self._pIconSprite)
    
    self._pIconSpritePress = cc.Sprite:createWithSpriteFrameName("MainIcon/" .. self._nFuncInfo.Icon .. ".png")
    self._pIconSpritePress:setPosition(-5,-5)
    self._pIconSpritePress:setScale(1.1)
    self._pIconSpritePress:setVisible(false)
    self._pIconSpritePress:setAnchorPoint(cc.p(0, 0))
    self:addChild(self._pIconSpritePress)
    
    self._pWarningSprite = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSprite:setPosition(65,65)
    self._pWarningSprite:setScale(0.2)
    self._pWarningSprite:setVisible(false)
    self._pWarningSprite:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self._pWarningSprite)
    
    -- 上下移动动画效果
    local actionMoveBy = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
    local actionMoveToBack = cc.ScaleTo:create(0.5,0.6,0.6)
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pWarningSprite:stopAllActions()
    self._pWarningSprite:runAction(cc.RepeatForever:create(seq1))
    
    self:setKeyPress(false)
    
    self._pNameLbl = cc.Label:create()
    self._pIconSprite:setAnchorPoint(cc.p(0, 0))
    self._pNameLbl:setString(self._nFuncInfo.Desc)
    self._pNameLbl:setPosition(35,20)
    
    --self._pIconSprite:addChild(self._pNameLbl)
    
    self._bDisableShowOrNot = (self._nFuncInfo.InsideOrOut == 1) and true or false
    if self._bDisableShowOrNot == true then
        self:setVisible(false)
    end

    local x,y = self._pIconSprite:getPosition()
    local size = self._pIconSprite:getContentSize()
    self._recBg = cc.rect(x,y,size.width,size.height)
	
	-- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()    
        local point = self:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,point) == true and self._bTouchAble == true then--self._fCallback()
            self:setKeyPress(true)
            return true   --可以向下传递事件
        end
        return false   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        local point = self:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,point) ~= true then
            self:setKeyPress(false)
        end
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local point = self:convertTouchToNodeSpace(touch)
        
        if cc.rectContainsPoint(self._recBg,point) == true and self._bKeyPress == true and (self._kState == STATE_ABLE or self._bDisableShowOrNot == false) then
            local canCallback = true
            if BagCommonManager:getInstance():getInitDataOrNot() == false then
                BagCommonCGMessage:sendMessageGetBagList20100()
                canCallback = false
            end
            
            if SkillsManager:getInstance()._bGetInitData == false then
                SkillCGMessage:sendMessageQuerySkillList21400()
                canCallback = false
            end
            
            if TasksManager:getInstance()._bStoryDataInit == false then
                MessageGameInstance:sendMessageQueryStoryBattleList21008(0)
                canCallback = false
            end
            
            if TasksManager:getInstance()._bGetInitData == false then
            	TaskCGMessage:sendMessageQueryTasks21700()
                canCallback = false
            end
            
            if FriendManager:getInstance()._bGetInitData == false  then
                FriendCGMessage:sendMessageRecommendList22008()
                FriendCGMessage:sendMessageQueryFriendSkill()

                FriendCGMessage:sendMessageQueryApplyFriendList22002()
                FriendCGMessage:sendMessageQueryGiftList22004()
                FriendCGMessage:sendMessageQueryFriendList22000()
                canCallback = false
            end
            
            if canCallback == true then
                -- DialogManager:getInstance():closeAllDialogs()
                --RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kStand)
                TasksManager:stopAllOperate()
                self._fCallback()
                NewbieManager:getInstance():showOutAndRemoveWithRunTime()
            end
        end
        self:setKeyPress(false)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWorldFuncBtn()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

-- 新开启功能提示动画
function WorldFuncBtn:showNewFuncAni()
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(self._pIconSprite:getContentSize().width/2 , self._pIconSprite:getContentSize().height/2) 

    local batch = nil
    local _pIntensifyEffect = nil
    local actionOverCallBack = function()
        _pIntensifyEffect = nil
        batch:removeFromParent(true)
        batch = nil
    end
    ----------------
    if not _pIntensifyEffect then
        _pIntensifyEffect = cc.ParticleSystemQuad:create("ParticlesShiyonglaba.plist")
        _pIntensifyEffect:setPosition(pAniPostion)
        batch = cc.ParticleBatchNode:createWithTexture(_pIntensifyEffect:getTexture())
        batch:addChild(_pIntensifyEffect)
        self:addChild(batch,10)
    else
        _pIntensifyEffect:resetSystem()
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(actionOverCallBack))) 
end

function WorldFuncBtn:setPoints(ablePoint, disablePoint)
    self._pAblePoint = ablePoint
    self._pDisablePoint = disablePoint
    
    if self._kState == STATE_ABLE then
        self:setVisible(true)
        self:setPosition(ablePoint.x,ablePoint.y)
    else
        self:setPosition(disablePoint.x,disablePoint.y)
    end
end

function WorldFuncBtn:setCallback( func )
	self._fCallback = func
end

function WorldFuncBtn:setStateAble( )
	self._kState = STATE_ABLE
end

function WorldFuncBtn:setStateDisable( )
	self._kState = STATE_DISABLE
end

function WorldFuncBtn:setTouchAble(visible)
	self._bTouchAble = visible
end

function WorldFuncBtn:getState( )
	return self._kState
end

function WorldFuncBtn:setKeyPress(arg)
    if arg == true then
        self._bKeyPress = true
        self._pIconSpritePress:setVisible(true)
        self._pIconSprite:setVisible(false)
    else
        self._bKeyPress = false
        self._pIconSpritePress:setVisible(false)
        self._pIconSprite:setVisible(true)
	end
end

function WorldFuncBtn:resetPos()
    if self._kState == STATE_ABLE then
        self:setVisible(true)
        self:setPosition(self._pAblePoint.x,self._pAblePoint.y)
        
    else
        self:setPosition(self._pDisablePoint.x,self._pDisablePoint.y)
        if self._bDisableShowOrNot == true then
            self:setVisible(false)
        end
	end
end

function WorldFuncBtn:changeState(  )
	if self._kState == STATE_ABLE then
	
		self._kState = STATE_DISABLE
        --self._pTouchListener:setEnabled(false)
        --self._pNameLbl:setVisible(false)
        
		self:runAction(cc.Sequence:create(
        	cc.MoveTo:create(0.1,self._pDisablePoint),
        	cc.CallFunc:create(function()
                if self._bDisableShowOrNot == true then
                    self:setVisible(false)
        	    end
                
                --self._pNameLbl:setVisible(true)
            end
        )
    	))
	else
	
		self._kState = STATE_ABLE
        --self._pNameLbl:setVisible(false)
        self:setVisible(true)
        
		self:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.1,self._pAblePoint),
        	cc.CallFunc:create(function()
                --self._pTouchListener:setEnabled(true)
                --self._pNameLbl:setVisible(true)
                --self._pNameLbl:setPosition(35,20)
            end
        )
    	))
	end
end

-- 退出函数
function WorldFuncBtn:onExitWorldFuncBtn()
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

function WorldFuncBtn:handleMsgWarning(event)
    if event.Desc == self._sKeyName then
        self._pWarningSprite:setVisible(event.value)
	end
end

function WorldFuncBtn:isWarning()
    return self._pWarningSprite:isVisible() 
end

return WorldFuncBtn
