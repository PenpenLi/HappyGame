--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleEndFailureDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/23
-- descrip:   战斗失败的界面
--===================================================
local BattleEndFailureDialog = class("BattleEndFailureDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BattleEndFailureDialog:ctor()
    self._strName = "BattleEndFailureDialog"        -- 层名称
    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pNodesure = nil                           --确定按钮的挂载node
    self._bRePlay = false                           --是否重玩
    self._pRePlayBtn = nil                          --重玩按钮
    self._pNodeRePlay = nil                         --重来一次的挂载node
    self._pNodeStrengthen = nil                     --我要变强的挂载node
end

-- 创建函数
function BattleEndFailureDialog:create()
    local dialog = BattleEndFailureDialog.new()
    dialog:dispose()
    return dialog
end

-- 处理函数
function BattleEndFailureDialog:dispose()
    NetRespManager:getInstance():addEventListener(kNetCmd.kEntryBattle, handler(self, self.rePlayNetBack))
    
    ResPlistManager:getInstance():addSpriteFrames("FightEndFailure.plist")
    ResPlistManager:getInstance():addSpriteFrames("FightEndSureButton.plist")
    ResPlistManager:getInstance():addSpriteFrames("FightEndAgainButton.plist")
    self:initUi()
    self:initBtn()
    self:initStrongBtn()
   
    AudioManager:getInstance():playMusic("BattleLose") -- 背景音乐
     
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
        end
        return false   --可以向下传递事件
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

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBattleEndFailureDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end


function BattleEndFailureDialog:initUi()
    local params = require("FightEndFailureParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGorund
    self._pCloseButton = params._pCloseButton
    self._pNodesure = params._pNodesure               --确定按钮的挂载node
    self._pNodeRePlay = params._pNodeagain
    self._pNodeStrengthen = params._pNodeStrengthen 
    -- 初始化dialog的基础组件
    self:disposeCSB()
    
    local pFightEndFailureAction = cc.CSLoader:createTimeline("FightEndFailure.csb")
    pFightEndFailureAction:gotoFrameAndPlay(0,pFightEndFailureAction:getDuration(), false)
    self._pCCS:runAction(pFightEndFailureAction)

end



function BattleEndFailureDialog:initBtn()

    --确定按钮的csb
    local pConfirm = cc.CSLoader:createNode("FightEndSureButton.csb")
    self._pNodesure:addChild(pConfirm)
    pConfirm:setVisible(false)

    --确定按钮
    self._pConfirmBtn = pConfirm:getChildByName("surebutton")
    -- 关闭按钮的事件
    local touchEvent = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            BattleManager:getInstance()._bIsTransforingFromEndBattle = true
            self:getParent():closeDialogByNameWithNoAni("BattleEndFailureDialog")
            LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pConfirmBtn:addTouchEventListener(touchEvent)

    local confirmCallBack = function()
        local pConfirmAction = cc.CSLoader:createTimeline("FightEndSureButton.csb")
        pConfirmAction:gotoFrameAndPlay(0,pConfirmAction:getDuration(), false)
        pConfirm:setVisible(true)
        pConfirm:runAction(pConfirmAction)  
    end
    self._pCCS:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(confirmCallBack)))


    -- 重玩按钮的csb
    local pRePlay = cc.CSLoader:createNode("FightEndAgainButton.csb")
    self._pNodeRePlay:addChild(pRePlay)
    pRePlay:setVisible(false)

    --重玩按钮
    self._pRePlayBtn = pRePlay:getChildByName("againbutton")
    -- 重玩按钮的事件
    local replayEvent = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:rePlay()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pRePlayBtn:addTouchEventListener(replayEvent)

    local replayCallBack = function()
        local pReplayAction = cc.CSLoader:createTimeline("FightEndAgainButton.csb")
        pReplayAction:gotoFrameAndPlay(0,pReplayAction:getDuration(), false)
        pRePlay:setVisible(true)
        pRePlay:runAction(pReplayAction)
    end
    self._pCCS:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(replayCallBack)))

    -- 非指定类型的副本 没有重玩按钮
    local pCurCopyType =  StagesManager:getInstance()._nCurCopyType
    if pCurCopyType ~= kType.kCopy.kStory and pCurCopyType ~= kType.kCopy.kGold and 
        pCurCopyType ~= kType.kCopy.kStuff and pCurCopyType ~= kType.kCopy.kChallenge and
        pCurCopyType ~= kType.kCopy.kMaze then
        self._pNodeRePlay:setVisible(false)
    end


end

--初始化我要变强的列表
function BattleEndFailureDialog:initStrongBtn()

    local pCurLevel =  RolesManager:getInstance()._pMainRoleInfo.level
    local pIndex =table.getn(TableFailGuide)
    for i=1,table.getn(TableFailGuide) do
        if pCurLevel < TableFailGuide[i].Level then
            pIndex = i-1
        end
    end
    


    local jumpToStrongEvent = function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local pTag = sender:getTag()
            local nGuideId = TableNewFunction[pTag].GuideID1
            --记录点击的指引id
            PurposeManager:getInstance()._pFaildGruidId = nGuideId  
            BattleManager:getInstance()._bIsTransforingFromEndBattle = true
            self:getParent():closeDialogByNameWithNoAni("BattleEndFailureDialog")
            LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    local tFaildGuideInfo = TableFailGuide[pIndex]
    for k,v in pairs(tFaildGuideInfo.FunctionID)do
        local pBtnInfo = TableNewFunction[v]
        PurposeManager:createPurpose(pBtnInfo.GuideID1)
        local pBtn =  self:createStrongBtn(pBtnInfo.FailIcon,pBtnInfo.FailIconPress)
        pBtn:setTag(v)
        pBtn:setPosition(tFaildGuideInfo.Position[k][1],tFaildGuideInfo.Position[k][2])
        pBtn:addTouchEventListener(jumpToStrongEvent)
        self._pNodeStrengthen:addChild(pBtn)
    end
end

--创建一个btn
function BattleEndFailureDialog:createStrongBtn(pNomalTexture,pPressTexture)
    local pBtn =  nil
    local pNomal = "FightEndFailureRes/"..pNomalTexture..".png"
    local pPress = "FightEndFailureRes/"..pPressTexture..".png"
    pBtn = ccui.Button:create(pNomal,pPress,pPress,ccui.TextureResType.plistType)
    pBtn:setTouchEnabled(true)
    return pBtn
end


-- 退出函数
function BattleEndFailureDialog:onExitBattleEndFailureDialog()
    self:onExitDialog()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FightEndFailure.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FightEndSureButton.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FightEndAgainButton.plist")
end

-- 循环更新
function BattleEndFailureDialog:update(dt)
    return
end

-- 显示结束时的回调
function BattleEndFailureDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BattleEndFailureDialog:doWhenCloseOver()
    return
end

-- 重玩本次副本
function BattleEndFailureDialog:rePlay()
    if self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kStory or self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kGold or
       self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kStuff or self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kChallenge or
       self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kMaze then
        MessageGameInstance:sendMessageEntryBattle21002(self:getBattleManager()._tBattleArgs._nBattleId,0)
    end
end

-- 重玩本次副本的回调
function BattleEndFailureDialog:rePlayNetBack()
    -- 切换战斗
    self._bRePlay = true
    BattleManager:getInstance()._bIsTransforingFromEndBattle = true
    self:getParent():closeDialogByNameWithNoAni("BattleEndFailureDialog")
    LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER, BattleManager:getInstance()._tBattleArgs)

end

function BattleEndFailureDialog:closeWithAni()
    self:stopAllActions()
    if self._pTouchListener then
        self._pTouchListener:setEnabled(false)
        self._pTouchListener:setSwallowTouches(false)
    end
    self:setTouchEnableInDialog(true)
    self:doWhenCloseOver()
    self:removeAllChildren(true)
    self:removeFromParent(true)

end


return BattleEndFailureDialog
