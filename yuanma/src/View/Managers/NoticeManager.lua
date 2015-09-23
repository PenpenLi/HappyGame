--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  NoticeManager.lua
-- author:    liyuhang
-- created:   2015/1/23
-- descrip:   系统或全局弹出提示控制管理器
--===================================================
NoticeManager = {}

local instance = nil

-- 单例
function NoticeManager:getInstance()
    if not instance then
        instance = NoticeManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function NoticeManager:clearCache()
	self._noticeLayer = nil
	self._pNewEquipPanel = nil
	self.pMarqueePanel = nil
	self._pMarqueePanel = nil       --跑马灯panel
    self._tMarqueeInfo = {}         --跑马灯数据
    self._pNpDialuguPanel = nil     --显示npc对话
end

-- 设置noticelayer
function NoticeManager:setNoticeLayer(layer)
	self._noticeLayer = layer
	self:initMarquee()
end

-- 系统提示字   调用在 funcs.lua
function NoticeManager:showSystemMessage(msg)
    local winSize = cc.Director:getInstance():getWinSize()

    local systemLbl = ccui.Text:create()
    systemLbl:setFontName(strCommonFontName)

    local function doRemoveFromParentAndCleanup(sender,table)
        systemLbl:removeFromParent(table[1])
    end

    local action = cc.Sequence:create(
        cc.MoveBy:create(1, cc.p(0,30)),
        cc.CallFunc:create(doRemoveFromParentAndCleanup,{true}))

    systemLbl:setString(msg)
    systemLbl:setFontSize(40)
    systemLbl:setColor(cRed)
    systemLbl:setPosition(cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()*3/4))
    self._noticeLayer:addChild(systemLbl, kZorder.kSystemMessageLayer)

    systemLbl:runAction(action)
end 

-- 显示战斗力提升
--播放+战斗力的动画
function NoticeManager:showFightStrengthChange(fightChangeNum,nFightPower)
if not fightChangeNum then
	fightChangeNum = 0
end
if not nFightPower then
   nFightPower = RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
end
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(mmo.VisibleRect:width()/2-30,mmo.VisibleRect:height()/5-20)

    local pSpriteFightPow = cc.Sprite:createWithSpriteFrameName("ccsComRes/Effective.png")
    pSpriteFightPow:setPosition(pAniPostion)
    self._noticeLayer:addChild(pSpriteFightPow)

    local pStringMark =  fightChangeNum>0 and "+" or "" 
    local pStrengthNum = cc.Label:createWithBMFont("fnt_add_blood.fnt","")
    pStrengthNum:setAnchorPoint(cc.p(0,0.5))
    pStrengthNum:setPosition(cc.p(pAniPostion.x+130,pAniPostion.y+57))
    pStrengthNum:setString(pStringMark..fightChangeNum)
    self._noticeLayer:addChild(pStrengthNum)
    
    local pTotalNum = cc.Label:createWithBMFont("fnt_lose_blood1.fnt","")
    pTotalNum:setAnchorPoint(cc.p(0,0.5))
    pTotalNum:setPosition(cc.p(pAniPostion.x+100,pAniPostion.y+7))
    pTotalNum:setString(nFightPower)
    self._noticeLayer:addChild(pTotalNum)
    
    local aniPlayOver = function(frame)
        frame:removeFromParent(true)
        frame = nil
    end
    
    local mainFight = nFightPower
    local aniProcess = {fightChangeNum/10 , 2*fightChangeNum/10,3*fightChangeNum/10,4*fightChangeNum/10,5*fightChangeNum/10,
        6*fightChangeNum/10 , 7*fightChangeNum/10,8*fightChangeNum/10,9*fightChangeNum/10,fightChangeNum}

    local sprAction = cc.Sequence:create(
        --cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveBy:create(0.8,cc.p(0,100))),
        cc.DelayTime:create(0.8),
        cc.DelayTime:create(0.2),
        --cc.Spawn:create(cc.FadeOut:create(0.1),cc.MoveBy:create(0.1,cc.p(0,100))),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(aniPlayOver))
    local numAction = cc.Sequence:create(
        cc.Spawn:create(cc.FadeIn:create(0.3),cc.MoveBy:create(0.8,cc.p(0,30))),
        --cc.DelayTime:create(0.8),
        cc.DelayTime:create(0.2),
        --cc.Spawn:create(cc.FadeOut:create(0.1),cc.MoveBy:create(0.1,cc.p(0,100))),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(aniPlayOver))
    local totalAction = cc.Sequence:create(
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[1])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[2])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[3])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[4])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[5])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[6])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[7])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[8])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[9])) end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function() pTotalNum:setString(mainFight + math.ceil( aniProcess[10])) end),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(aniPlayOver))

    pStrengthNum:runAction(numAction)
    pSpriteFightPow:runAction(sprAction)
    pTotalNum:runAction(totalAction)
end

-- 新开启功能提示动画
function NoticeManager:showNewFuncAni(x,y)
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/5)
    
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
        _pIntensifyEffect:setPosition(cc.p(x,y))
        batch = cc.ParticleBatchNode:createWithTexture(_pIntensifyEffect:getTexture())
        batch:addChild(_pIntensifyEffect)
        self._noticeLayer:addChild(batch,10)
    else
        _pIntensifyEffect:resetSystem()
    end

    self._noticeLayer:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(actionOverCallBack))) 
end

function NoticeManager:showNewEquip(args)
    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(mmo.VisibleRect:rightBottom().x-100,mmo.VisibleRect:rightBottom().y+20)
    
    if self._pNewEquipPanel == nil then
    	self._pNewEquipPanel = require("EqiupNewPanel"):create()
        self._pNewEquipPanel:setPosition(pAniPostion)
        self._noticeLayer:addChild(self._pNewEquipPanel,kZorder.kSystemMessageLayer)
    end
    
    self._pNewEquipPanel:setVisible(true)
end

-- 新开启功能中心动画
function NoticeManager:showNewFuncIconAni(args)
    if args == nil then
    	return
    end

    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostion = cc.p(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2)
        
    local pGuideAniNode = cc.CSLoader:createNode("NovicegGuideFunction.csb")
    local pGuideAniAniAction = cc.CSLoader:createTimeline("NovicegGuideFunction.csb")
    pGuideAniNode:setScale(1)
    pGuideAniNode:setPosition(pAniPostion)
    self._noticeLayer:addChild( pGuideAniNode)
        
    local icon = cc.Sprite:createWithSpriteFrameName("MainIcon/" .. args.Icon .. ".png")
    icon:setPosition(pAniPostion)
        
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then 
            pGuideAniNode:removeFromParent(true)
        end
    end
    
    local actionOverCallBack = function() 
        icon:removeFromParent(true)
        icon = nil
    end
    
    pGuideAniAniAction:setFrameEventCallFunc(onFrameEvent)
    pGuideAniAniAction:gotoFrameAndPlay(0,pGuideAniAniAction:getDuration(), false)
    pGuideAniNode:stopAllActions()
    pGuideAniNode:runAction(pGuideAniAniAction)
    
    local numAction = cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.DelayTime:create(1.1),
        cc.CallFunc:create(actionOverCallBack))
    self._noticeLayer:addChild(icon)
    
    icon:runAction(numAction)
end

function NoticeManager:update(dt)
  if self._pMarqueePanel and table.getn( self._tMarqueeInfo) >0 then 
    self._pMarqueePanel:update(dt)
  end

end

--初始化跑马灯
function NoticeManager:initMarquee()
    self._pMarqueePanel = require("MarqueePanel"):create()
    self._noticeLayer:addChild(self._pMarqueePanel)
end


--跑马灯
function NoticeManager:getMarqueeMessage()
  return self._tMarqueeInfo
end

function NoticeManager:insertMarqueeMessage(pInfo)
    table.insert( self._tMarqueeInfo,pInfo)
end
