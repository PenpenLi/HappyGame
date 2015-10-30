--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleSkillButtonWidget.lua
-- author:    liyuhang
-- created:   2015/1/27
-- descrip:   battle ui 技能按钮
--===================================================
local BattleSkillButtonWidget = class("BattleSkillButtonWidget",function()
    return cc.Layer:create()
end)

local STATE_NORMAL = 1
local STATE_CD = 2
local STATE_NOOPEN = 3

-- 构造函数
function BattleSkillButtonWidget:ctor()
    self._strName = "BattleSkillButtonWidget"       -- 层名称

    self._nType = 1                                 -- 按钮类型  1：技能按钮   2：好友技能按钮  3:宠物共鸣技能
    self._recBg = cc.rect(0,0,0,0)                  -- 背景框所在矩形
    self._pSkillInfo = nil                          -- 技能info
    self._pSkillBg = nil                            -- 技能按钮 背景框
    self._pSkillBtn = nil                           -- 技能按钮 名字
    self._pCdBar = nil                              -- cd条
    self._pCDNum = nil                              -- CD时间倒计时显示控件
    
    self._sIcon = nil                               -- 技能icon 名字
    self._fClickBtnCallfunc = nil                   -- 点击技能回调
    self._bCanClick = true                          -- 技能是否可点击
    self._nSkillCdState = STATE_NORMAL              -- 技能使用状态

    self._nCdTime = 0                               -- 技能cd时间
    self._nCdProcessTime = 0                        -- 技能cd剩余时间
    self._nTag = 1
    self._pUseEffect = nil
    self._bIsOpen = true                            -- 按钮是否是开启状态

end

-- 创建函数
function BattleSkillButtonWidget:create(type)
    local layer = BattleSkillButtonWidget.new()
    layer:dispose(type)
    return layer
end

-- 处理函数
function BattleSkillButtonWidget:dispose(type)
    self._nType = type  -- 技能按钮类型
    --加载ui
    if self._nType == 1 then  -- 技能按钮
        self._pSkillBtn = nil
        self._pSkillBtn = ccui.Button:create(
            "SkillUIRes/zdjm27.png",
            "SkillUIRes/zdjm27.png",
            "SkillUIRes/zdjm27.png",
            ccui.TextureResType.plistType)
        self._pSkillBtn:setTouchEnabled(true)
        self._pSkillBtn:setPosition(-12,-13)
        self._pSkillBtn:setAnchorPoint(cc.p(0, 0))
        self:addChild(self._pSkillBtn)
        self._pSkillBtn:setVisible(true)
        
        self._pSkillNoBg = ccui.ImageView:create("SkillUIRes/zdjm26.png",ccui.TextureResType.plistType)
        self._pSkillNoBg:setPosition(self._pSkillBtn:getContentSize().width/2-14,self._pSkillBtn:getContentSize().height/2-10)
        self._pSkillNoBg:setScale(1.0)
        --self._pSkillNoBg:setVisible(false)
        self:addChild(self._pSkillNoBg)

        self._pSkillBg = ccui.ImageView:create("SkillUIRes/zdjm27.png",ccui.TextureResType.plistType)
        self._pSkillBg:setPosition(self._pSkillBtn:getContentSize().width/2-14,self._pSkillBtn:getContentSize().height/2-10)
        self._pSkillBg:setScale(0.92)
        self._pSkillBg:setVisible(false)
        self:addChild(self._pSkillBg)

        self._pSkillBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if self._bCanClick == true then
                    if self._fClickBtnCallfunc then
                        self._fClickBtnCallfunc(self._nTag)  
                    end
                end
            end
        end)
        
        local pBarCd = cc.Sprite:createWithSpriteFrameName("SkillUIRes/CdPics.png")    
        self._pCdBar = cc.ProgressTimer:create(pBarCd)
        self._pCdBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        self._pCdBar:setMidpoint(cc.p(0.5,0.5))
        self._pCdBar:setPosition(self._pSkillBtn:getContentSize().width/2-13,self._pSkillBtn:getContentSize().height/2-11)
        self._pCdBar:setBarChangeRate(cc.p(1,0))
        self._pCdBar:setPercentage(self._nCdProcessTime / (self._nCdTime * (1.0/cc.Director:getInstance():getAnimationInterval()) ) * 100)
        self:addChild(self._pCdBar)
        --[[
        self._pOpenLevellbl = ccui.Text:create()
        self._pOpenLevellbl:setFontName(strCommonFontName)
        self._pOpenLevellbl:setString("冷去中")
        self._pOpenLevellbl:setPosition(36,33)
        self._pOpenLevellbl:setFontSize(18)
        self._pOpenLevellbl:setColor(cRed)
        self._pOpenLevellbl:setVisible(false)
        self:addChild(self._pOpenLevellbl)
        ]]
        self._pCDNum = cc.Label:createWithTTF("", strCommonFontName, 48)
        self._pCDNum:setTextColor(cFontWhite)
        self._pCDNum:enableOutline(cFontOutline,2)
        self._pCDNum:setPosition(self._pSkillBtn:getContentSize().width/2-13,self._pSkillBtn:getContentSize().height/2-11)
        self:addChild(self._pCDNum)
    else    -- 好友技能按钮或宠物共鸣技能按钮
        self._pSkillBtn = nil
        self._pSkillBtn = ccui.Button:create(
            "SkillUIRes/zdjm30.png",
            "SkillUIRes/zdjm30.png",
            "SkillUIRes/zdjm30.png",
            ccui.TextureResType.plistType)
        self._pSkillBtn:setTouchEnabled(true)
        self._pSkillBtn:setPosition(-12,-13)
        self._pSkillBtn:setAnchorPoint(cc.p(0, 0))
        self:addChild(self._pSkillBtn)
        self._pSkillBtn:setVisible(true)

        self._pSkillNoBg = ccui.ImageView:create("SkillUIRes/zdjm26.png",ccui.TextureResType.plistType)
        self._pSkillNoBg:setPosition(self._pSkillBtn:getContentSize().width/2-12,self._pSkillBtn:getContentSize().height/2-13)
        self._pSkillNoBg:setScale(1.0)
        --self._pSkillNoBg:setVisible(false)
        self:addChild(self._pSkillNoBg)

        self._pSkillBg = ccui.ImageView:create("SkillUIRes/zdjm30.png",ccui.TextureResType.plistType)
        self._pSkillBg:setPosition(self._pSkillBtn:getContentSize().width/2-12,self._pSkillBtn:getContentSize().height/2-13)
        self._pSkillBg:setVisible(false)
        self:addChild(self._pSkillBg)

        self._pSkillBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if self._bCanClick == true then
                    if self._fClickBtnCallfunc then
                        self._fClickBtnCallfunc(self._nTag)  
                    end
                end
            end
        end)
        
        local pBarCd = cc.Sprite:createWithSpriteFrameName("SkillUIRes/zdjm32cd.png")    
        self._pCdBar = cc.ProgressTimer:create(pBarCd)
        self._pCdBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        self._pCdBar:setMidpoint(cc.p(0.5,0.5))
        self._pCdBar:setPosition(self._pSkillBtn:getContentSize().width/2-12,self._pSkillBtn:getContentSize().height/2-13)
        self._pCdBar:setBarChangeRate(cc.p(1,0))
        self._pCdBar:setPercentage(self._nCdProcessTime / (self._nCdTime * (1.0/cc.Director:getInstance():getAnimationInterval()) ) * 100)
        self:addChild(self._pCdBar)

        --[[
        self._pOpenLevellbl = ccui.Text:create()
        self._pOpenLevellbl:setFontName(strCommonFontName)
        self._pOpenLevellbl:setString("冷去中")
        self._pOpenLevellbl:setPosition(36,33)
        self._pOpenLevellbl:setFontSize(18)
        self._pOpenLevellbl:setColor(cRed)
        self._pOpenLevellbl:setVisible(false)
        self:addChild(self._pOpenLevellbl)
        ]]
        self._pCDNum = cc.Label:createWithTTF("", strCommonFontName, 48)
        self._pCDNum:setTextColor(cFontWhite)
        self._pCDNum:enableOutline(cFontOutline,2)
        self._pCDNum:setPosition(self._pSkillBtn:getContentSize().width/2-12,self._pSkillBtn:getContentSize().height/2-13)
        self:addChild(self._pCDNum)
    end
    
    --self.batch = nil
    --self._pUseEffect = cc.ParticleSystemQuad:create("SkillCDEffect.plist")
    --self._pUseEffect:setPosition(cc.p(self._pCdBar:getContentSize().width/2-14 , self._pCdBar:getContentSize().height/2-15))
    --self.batch = cc.ParticleBatchNode:createWithTexture(self._pUseEffect:getTexture())
    --self.batch:addChild(self._pUseEffect)
    --self:addChild(self.batch,10)
    
    --[[
    self.batch = cc.CSLoader:createNode("SkillCDEffect.csb")
    local _pResolveAniAction = cc.CSLoader:createTimeline("SkillCDEffect.csb")
    self.batch:setScale(1)
    self.batch:setPosition(cc.p(self._pCdBar:getContentSize().width/2-14 , self._pCdBar:getContentSize().height/2-15))
    self:addChild( self.batch)

    _pResolveAniAction:gotoFrameAndPlay(0,_pResolveAniAction:getDuration(), true)
    self.batch:stopAllActions()
    self.batch:runAction(_pResolveAniAction)
    ]]

    --设置技能当前状态
    self:setSkillButtonState(STATE_NORMAL)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBattleSkillButtonWidget()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return
end

-- 退出函数
function BattleSkillButtonWidget:onExitBattleSkillButtonWidget()

end

-- 设置按钮为未开启状态
function BattleSkillButtonWidget:setNoOpenState()
    self:setSkillButtonState(STATE_NOOPEN)
end

-- 设置技能按钮状态
function BattleSkillButtonWidget:setSkillButtonState( state )
    local function actionOver()
        self:setSkillButtonState(STATE_NORMAL)
        self._pCdBar:setPercentage(100)
        --self:showCDAni()
    end

    local stateChangeAction = {
        [STATE_NORMAL] = function()
            self._bCanClick = true
            self._pCdBar:setVisible(false)
           -- self.batch:setVisible(true)
        end ,
        [STATE_CD] = function()
            self._bCanClick = false
            self._pCdBar:setVisible(true)
            --self.batch:setVisible(false)
            -- CD文字提示
            self:disposeCDNum()
            self._pCdBar:stopAllActions()
            self._pCdBar:setPercentage(100)
            self._pCdBar:runAction(cc.Sequence:create(
                cc.ProgressTo:create(self._nCdTime, 0) ,
                cc.CallFunc:create(actionOver,{true}))
                )
        end ,
        [STATE_NOOPEN] = function()
            self._bCanClick = false
            self._pCdBar:setVisible(false)
            self._pSkillBg:setVisible(false)
            --self._pSkillNoBg:setVisible(true)
            --self._pOpenLevellbl:setVisible(false)
            --self.batch:setVisible(false)
            
            --local offsetActive = TableConstants.ActiveSkillNumber.Value + 1
            --local level = SkillsManager:getMainRoleSkillDataByID(offsetActive*(RolesManager:getInstance()._pMainRoleInfo.roleCareer-1) + 2 + 3*(self._nTag-1),1).RequiredLevel
            --self._pOpenLevellbl:setString(level .. "级开启")
        end
    }

    self._nSkillCdState = state
    stateChangeAction[self._nSkillCdState]()
end

-- cd完成特效
function BattleSkillButtonWidget:showCDAni()
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(self._pCdBar:getContentSize().width/2-14 , self._pCdBar:getContentSize().height/2-15) 

    local batch = nil
    local _pIntensifyEffect = nil
    local actionOverCallBack = function()
        _pIntensifyEffect = nil
        batch:removeFromParent(true)
        batch = nil
    end
    ----------------
    if not _pIntensifyEffect then
        _pIntensifyEffect = cc.ParticleSystemQuad:create("Particlefire04.plist")
        _pIntensifyEffect:setPosition(pAniPostion)
        batch = cc.ParticleBatchNode:createWithTexture(_pIntensifyEffect:getTexture())
        batch:addChild(_pIntensifyEffect)
        self:addChild(batch,10)
    else
        _pIntensifyEffect:resetSystem()
    end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(actionOverCallBack))) 
end

-- 循环更新
function BattleSkillButtonWidget:update(dt)
    if self._nSkillCdState == STATE_CD then
        local result1,result2 = math.modf(self._nCdProcessTime/(1.0/cc.Director:getInstance():getAnimationInterval()))
        self._pCdBar:setPercentage(self._nCdProcessTime / (self._nCdTime * (1.0/cc.Director:getInstance():getAnimationInterval())) * 100)
        self._nCdProcessTime = self._nCdProcessTime - 1
        if self._nCdProcessTime < 0 then
            self:setSkillButtonState(STATE_NORMAL)
            --self:showCDAni()
        end
    end
end

-- 设置回调函数
function BattleSkillButtonWidget:setCallfunc(func)
	self._fClickBtnCallfunc = func
end

-- 设置是否可点击
function BattleSkillButtonWidget:setTouchEnabled(canTouch)
    self._pSkillBtn:setTouchEnabled(canTouch)
end

-- 设置技能按钮
function BattleSkillButtonWidget:setSkillBtn(btn)
    self._pSkillBtn = btn
end

function BattleSkillButtonWidget:setBright( value )
    self._pSkillBtn:setBright(value)
end

-- 设置skillInfo
function BattleSkillButtonWidget:setSkillInfo(skillInfo) 
    self._pSkillBg:setVisible(true)
    if self._nType == 1 then  -- 技能按钮
        self._pSkillInfo = skillInfo
        self._nCdTime = self._pSkillInfo["CD"]
        local templeteId = self._pSkillInfo["TempleteID"]
        self._sIcon = TableTempleteSkills[templeteId].SkillIcon
        local sIconPress = TableTempleteSkills[templeteId].SkillIconPress
        self._pSkillBg:loadTexture(self._sIcon ..".png", ccui.TextureResType.plistType)
    elseif self._nType == 2 then  -- 好友技能按钮
        self._pSkillInfo = skillInfo
        self._nCdTime = self._pSkillInfo["CD"]
        local templeteId = self._pSkillInfo["TempleteID"]
        self._sIcon = TableTempleteSkills[templeteId].SkillIcon
        local sIconPress = TableTempleteSkills[templeteId].SkillIconPress
        self._pSkillBg:loadTexture("SkillUIRes/zdjm32.png", ccui.TextureResType.plistType)
    elseif self._nType == 3 then  -- 宠物共鸣技能按钮
        self._nCdTime = skillInfo
        self._pSkillBg:loadTexture("SkillUIRes/zdjm31.png", ccui.TextureResType.plistType)
    end
    --self._pCdBar:setPosition(cc.p((self._pSkillBg:getContentSize().width - self._pCdBar:getContentSize().width)/2 + self._pCdBar:getContentSize().width, (self._pSkillBg:getContentSize().height - self._pCdBar:getContentSize().height)/2))
end

function BattleSkillButtonWidget:setTag(tag)
    print("setTag is register " .. tag)
     self._nTag = tag
end 

function BattleSkillButtonWidget:resetCD()
    self._nCdProcessTime = self._nCdTime * (1.0/cc.Director:getInstance():getAnimationInterval())
    self:setSkillButtonState(STATE_CD)  
end

function BattleSkillButtonWidget:disposeCDNum()
    ---------------------------------CD文字提示-------------------------------------------------
    local cd = math.ceil(self._nCdTime)
    local intCD, floatCD = math.modf(self._nCdTime)
    if floatCD == nil then floatCD = 0 end
    local floatCDOver = function()
        local check = function()
            self._pCDNum:setOpacity(0)
            self._pCDNum:setScale(2.0)
            self._pCDNum:runAction(cc.Spawn:create(cc.EaseIn:create(cc.ScaleTo:create(0.25,1.0,1.0),5),cc.EaseIn:create(cc.FadeIn:create(0.25),5)))
            self._pCDNum:setString(tostring(cd))
            cd = cd - 1
        end
        check()
        self._pCDNum:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(check)),intCD-1),cc.DelayTime:create(1.0),cc.Hide:create()))
    end
    self._pCDNum:setOpacity(0)
    self._pCDNum:setScale(2.0)
    self._pCDNum:runAction(cc.Spawn:create(cc.EaseIn:create(cc.ScaleTo:create(0.25,1.0,1.0),5),cc.EaseIn:create(cc.FadeIn:create(0.25),5)))
    self._pCDNum:setString(tostring(cd))
    self._pCDNum:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(floatCD),cc.CallFunc:create(floatCDOver)))
    ----------------------------------------------------------------------------------------------
end

return BattleSkillButtonWidget
