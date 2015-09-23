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

    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形
    self._pSkillInfo = nil          -- 技能info
    self._pSkillBg = nil            -- 技能按钮 背景框
    self._pSkillBtn = nil           -- 技能按钮 名字
    self._pCDlbl = nil              -- cd显示label
    self._pCdBar = nil              -- cd条
    
    self._sIcon = nil               -- 技能icon 名字
    self._fClickBtnCallfunc = nil                -- 点击技能回调
    self._bCanClick = true                       -- 技能是否可点击
    self._nSkillCdState = STATE_NORMAL           -- 技能使用状态

    self._nCdTime = 0                            -- 技能cd时间
    self._nCdProcessTime = 0                     -- 技能cd剩余时间
    self._nTag = 1
    self._pUseEffect = nil
end

-- 创建函数
function BattleSkillButtonWidget:create()
    local layer = BattleSkillButtonWidget.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleSkillButtonWidget:dispose()
    --加载ui
    self._pSkillBtn = nil
    self._pSkillBtn = ccui.Button:create(
        "FightUIRes/skillicon01.png",
        "FightUIRes/skillicon02.png",
        "FightUIRes/skillicon01.png",
        ccui.TextureResType.plistType)
    self._pSkillBtn:setTouchEnabled(true)
    self._pSkillBtn:setPosition(-12,-13)
    self._pSkillBtn:setAnchorPoint(cc.p(0, 0))
    self:addChild(self._pSkillBtn)
    self._pSkillBtn:setVisible(true)
    
    self._pSkillBg = ccui.ImageView:create("FightUIRes/skillicon01.png",ccui.TextureResType.plistType)
    self._pSkillBg:setPosition(-0,-0)
    self._pSkillBg:setScale(0.85)
    self._pSkillBg:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pSkillBg)

    self._pSkillBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._bCanClick == true then
                self._fClickBtnCallfunc(self._nTag)            
            end
        end
    end)
    
    local pBarCd = cc.Sprite:createWithSpriteFrameName("FightUIRes/CdPics.png")

    --self._pCdBar = cc.ProgressTimer:create(pBarCd)
    --self._pCdBar:setAnchorPoint(0,0)
    --self._pCdBar:setPosition(-7,-7)
    --self._pCdBar:setScaleY(0.85)
    --self._pCdBar:setScaleX(0.85)
    --self._pCdBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    --self._pCdBar:setMidpoint(cc.p(0.0,0.0))
    --self._pCdBar:setBarChangeRate(cc.p(0,1))
    --self._pCdBar:setPercentage(self._nCdProcessTime / (self._nCdTime * (1.0/cc.Director:getInstance():getAnimationInterval()) ) * 100)
    --self:addChild(self._pCdBar)
    
    self._pCdBar = cc.ProgressTimer:create(pBarCd)
    self._pCdBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self._pCdBar:setMidpoint(cc.p(0.5,0.5))
    self._pCdBar:setPosition(-7,-7)
    self._pCdBar:setAnchorPoint(0,0)
    self._pCdBar:setScaleY(0.85)
    self._pCdBar:setScaleX(0.85)
    self._pCdBar:setBarChangeRate(cc.p(1,0))
    self._pCdBar:setPercentage(self._nCdProcessTime / (self._nCdTime * (1.0/cc.Director:getInstance():getAnimationInterval()) ) * 100)
    self:addChild(self._pCdBar)

    self._pCDlbl = ccui.Text:create()
    self._pCDlbl:setFontName(strCommonFontName)
    self._pCDlbl:setString("冷去中")
    self._pCDlbl:setPosition(30,10)
    self._pCDlbl:setColor(cRed)
    self:addChild(self._pCDlbl)
    
    
    self._pSkillNoBg = ccui.ImageView:create("FightUIRes/zdjm37.png",ccui.TextureResType.plistType)
    self._pSkillNoBg:setPosition(2,-0)
    self._pSkillNoBg:setScale(1.0)
    self._pSkillNoBg:setAnchorPoint(cc.p(0,0))
    self._pSkillNoBg:setVisible(false)
    self:addChild(self._pSkillNoBg)

    self._pOpenLevellbl = ccui.Text:create()
    self._pOpenLevellbl:setFontName(strCommonFontName)
    self._pOpenLevellbl:setString("冷去中")
    self._pOpenLevellbl:setPosition(36,33)
    self._pOpenLevellbl:setFontSize(20)
    self._pOpenLevellbl:setColor(cRed)
    self._pOpenLevellbl:setVisible(false)
    self:addChild(self._pOpenLevellbl)
    
    --self.batch = nil
    --self._pUseEffect = cc.ParticleSystemQuad:create("SkillCDEffect.plist")
    --self._pUseEffect:setPosition(cc.p(self._pCdBar:getContentSize().width/2-14 , self._pCdBar:getContentSize().height/2-15))
    --self.batch = cc.ParticleBatchNode:createWithTexture(self._pUseEffect:getTexture())
    --self.batch:addChild(self._pUseEffect)
    --self:addChild(self.batch,10)
    
    self.batch = cc.CSLoader:createNode("SkillCDEffect.csb")
    local _pResolveAniAction = cc.CSLoader:createTimeline("SkillCDEffect.csb")
    self.batch:setScale(1)
    self.batch:setPosition(cc.p(self._pCdBar:getContentSize().width/2-14 , self._pCdBar:getContentSize().height/2-15))
    self:addChild( self.batch)

    _pResolveAniAction:gotoFrameAndPlay(0,_pResolveAniAction:getDuration(), true)
    self.batch:stopAllActions()
    self.batch:runAction(_pResolveAniAction)

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
            self._pCDlbl:setVisible(false)
            self._pCdBar:setVisible(false)
            self.batch:setVisible(true)
        end ,
        [STATE_CD] = function()
            self._bCanClick = false
            self._pCDlbl:setVisible(true)
            self._pCdBar:setVisible(true)
            self.batch:setVisible(false)
            
            self._pCdBar:stopAllActions()
            self._pCdBar:setPercentage(100)
            self._pCdBar:runAction(cc.Sequence:create(
                cc.ProgressTo:create(self._nCdTime, 0) ,
                cc.CallFunc:create(actionOver,{true}))
                )
        end ,
        [STATE_NOOPEN] = function()
            self._bCanClick = false
            self._pCDlbl:setVisible(false)
            self._pCdBar:setVisible(false)
            self._pSkillBg:setVisible(false)
            self._pSkillNoBg:setVisible(true)
            self._pOpenLevellbl:setVisible(true)
            self.batch:setVisible(false)
            
            local offsetActive = TableConstants.ActiveSkillNumber.Value + 1
            local level = SkillsManager:getMainRoleSkillDataByID(offsetActive*(RolesManager:getInstance()._pMainRoleInfo.roleCareer-1) + 2 + 3*(self._nTag-1),1).RequiredLevel
            self._pOpenLevellbl:setString(level .. "级开启")
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
        self._pCDlbl:setString("冷去中 "..result1)
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
    self._pSkillInfo = skillInfo

    self._nCdTime = self._pSkillInfo["CD"]
    local templeteId = self._pSkillInfo["TempleteID"]
    self._sIcon = TableTempleteSkills[templeteId].SkillIcon
    local sIconPress = TableTempleteSkills[templeteId].SkillIconPress

    self._pSkillBg:loadTexture(
    self._sIcon ..".png",
    ccui.TextureResType.plistType)
    
    --self._pCdBar:setPosition(cc.p((self._pSkillBg:getContentSize().width - self._pCdBar:getContentSize().width)/2 + self._pCdBar:getContentSize().width, (self._pSkillBg:getContentSize().height - self._pCdBar:getContentSize().height)/2))
 end

-- 
function BattleSkillButtonWidget:setTag(tag)
    print("setTag is register " .. tag)
     self._nTag = tag
end 

function BattleSkillButtonWidget:resetCD()
    self._nCdProcessTime = self._nCdTime * (1.0/cc.Director:getInstance():getAnimationInterval())
    self:setSkillButtonState(STATE_CD)  
end

return BattleSkillButtonWidget
