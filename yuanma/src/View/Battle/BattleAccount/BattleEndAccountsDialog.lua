--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleEndAccountsDialog.lua
-- author:    liyuhang
-- created:   2015/1/19
-- descrip:   战斗结算
--===================================================
local BattleEndAccountsDialog = class("BattleEndAccountsDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BattleEndAccountsDialog:ctor()
    self._strName = "BattleEndAccountsDialog"       -- 层名称

    self._pCCS = nil
    self._pBg = nil
    self._nPickCardNum = 1            -- 本次结算抽卡的次数
    self._nVipPickCardNum = 1         -- 本次结算vip抽卡的次数

    self._pExpProgressBar = nil       -- 经验条
    self._pExpProgressBarNode = nil
    self._pItems = nil                -- 本次获得物品数组
    self._pItemsScrollView = nil      -- 获得得物品得scrollview
    self._tScrollViewItem ={}         -- 获得的物品item
    self._pCardsData = {}             -- 本次战斗抽卡所有数据的项


    self._NormalActFrameRegion = {{0,50},{60,115},{130,185},{200,255},{270,340}}   -- 战斗评级帧动画播放区间
    self._pParamsAction = nil         --大背景的动画
    self._tRoleNode = {}              --挂在所有角色背景图片的node
    self._prole03arm = nil            --职业3的手
    self._prolelevel = nil            --人物的等级
    self._pRoleNode = nil             --人物挂载node
    self._pRoleBg = nil               --角色的csb

    self._tFinceNode = {}             --挂在金钱的node 手动设置某个货币的存在
    self._tFinceImageIcon = {}        --金钱的图片
    self._tFinceText = {}             --金钱的数值

    self._pStartLevelNode = nil       --星星动画的挂载node
    self._pStartLevel = nil           --星星的csb

    self._pConfirmNode = nil          --确定按钮动画的挂载node
    self._pConfirm = nil              --确定按钮的csb
    self._pConfirmBtn = nil           --确定按钮
    
    self._pRePlay = nil               --重玩按钮的csb
    self._pRePlayBtn = nil            --重玩按钮
    
    self._pUpLevelEffect = nil        --人物升级的帧动画

    self._pCardCCS = nil              --翻盘的ui
    self._pCardCCSAct = nil           --翻盘的动画
    self._tCardFront = {}             --正面的牌
    self._tCardBg = {}                --反面的牌
    self._tCardNode = {}              --正面牌的挂在node
    self._tHasClickIndex = {}         --点击过的牌下表
    self._tCardItem = {}              --翻牌出来的item
    self._pLeavePickCardNumLbl = nil  --说明可以翻牌的次数lable
    self._tPercent = {}               --播放经验进度条的数组
    self._nLastRoleLevel= nil         --人物的上一次的等级
    self._bMidNight = nil             --午夜惊魂是否开启
    self._bRePlay = false             -- 是否重玩
    self._nLastClickTag = nil
end

-- 创建函数
function BattleEndAccountsDialog:create(args)
    local layer = BattleEndAccountsDialog.new()
    layer:dispose(args)
    return layer
end

function BattleEndAccountsDialog:handleMsgReconnect(event)
    if event.reconnected == nil then
        MessageGameInstance:sendMessagePickCardState21016()
    else
        self._bMidNight = false
    end 
end

-- 抽卡结束后，接受网络数据，更新获取的物品列表
function BattleEndAccountsDialog:updateCard(event)

    self._nPickCardNum = self._nPickCardNum - 1
    
    for i=1,table.getn(self._tCardBg) do
        self._tCardBg[i]:setTouchEnabled(true)
    end
    
    --先把翻牌的数组下表记录
    table.insert(self._tHasClickIndex,event.index)
    self._tCardItem[event.index]:setVisible(true)
    local pCardFront = self._tCardFront[event.index]
    local nX,nY = pCardFront:getPosition()
    pCardFront:setOpacity(255)
    pCardFront:setPosition(nX,nY+30)
    self._tCardBg[event.index]:setPosition(nX,nY+30)
    -- 如果当前抽中的是物品
    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101
    local nViewHeight = self._pItemsScrollView:getContentSize().height

    if table.getn(event.item) ~= 0 then
        -- 添加到已获得物品列表
        local pItemInfo = GetCompleteItemInfo(event.item[1])
        table.insert( self._pItems,pItemInfo)
        local nAllNum = table.getn(self._pItems)
        local nItemCell = require("BattleItemCell"):create()
        nItemCell:setItemInfo(pItemInfo)
        nItemCell:setTouchEnabled(false)
        nItemCell:setPosition((nSize+nLeftAndReightDis)*(nAllNum-1),0)
        self._pItemsScrollView:addChild(nItemCell)
        self._pItemsScrollView:setInnerContainerSize(cc.size((nSize+nLeftAndReightDis)*nAllNum,nViewHeight))
        table.insert( self._tScrollViewItem ,nItemCell)

        --设置翻牌出来的item信息
        self._tCardItem[event.index]:setItemInfo(pItemInfo)

        --删除翻开的牌的数据，在数据表中
        for i=1,table.getn(self._pCardsData.Items) do
            local nDate = self._pCardsData.Items[i]
            if nDate[1] == pItemInfo.id and nDate[4] == pItemInfo.baseType then --表示是一样的物品
                table.remove(self._pCardsData.Items,i) --如果发现就删除数据。剩下的都是没有选的卡牌数据
                break
            end
        end

    end

    -- 如果当前抽中的是货币
    if table.getn(event.finance) ~= 0 then
        local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(event.finance[1].finance)
        tFinanceInfo.amount = event.finance[1].amount
        tFinanceInfo.finance = event.finance[1].finance
        table.insert( self._pItems,tFinanceInfo)
        local nAllNum = table.getn(self._pItems)
        local nItemCell = require("BattleItemCell"):create()
        nItemCell:setFinanceInfo(tFinanceInfo)
        nItemCell:setPosition((nSize+nLeftAndReightDis)*(nAllNum-1),0)
        self._pItemsScrollView:addChild(nItemCell)
        self._pItemsScrollView:setInnerContainerSize(cc.size((nSize+nLeftAndReightDis)*nAllNum,nViewHeight))

        --设置翻牌出来的item信息
        self._tCardItem[event.index]:setFinanceInfo(tFinanceInfo)

        --删除翻开的牌的数据，在数据表中
        for i=1,table.getn(self._pCardsData.Moneys) do
            local nDate = self._pCardsData.Moneys[i]
            if nDate[1] == tFinanceInfo.finance and nDate[2] == tFinanceInfo.amount then --表示是一样的资源
                table.remove( self._pCardsData.Moneys,i)--如果发现就删除数据。剩下的都是没有选的卡牌数据
                break
            end
        end
    end

    print("剩余的翻牌次数     "..self._nPickCardNum)
    if self._nPickCardNum == 0 then --牌翻完了
        for i=1,table.getn(self._tCardItem) do
            --先查找一下是否翻开过牌
            local bHasBreak = true
            for j=1,table.getn(self._tHasClickIndex) do
                if self._tHasClickIndex[j] == i then --标示点击已经翻开的牌
                    bHasBreak = false
                end
            end
            self._tCardItem[i]:setVisible(true)
            if bHasBreak then      --判断剩余的里面有没有金钱
                local nMonesyNum = table.getn(self._pCardsData.Moneys) --翻卡的金钱数据
                bHasBreak = true   --剩余的里面没有金钱，遍历物品
                for m=1,nMonesyNum do
                    local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(self._pCardsData.Moneys[m][1])
                    tFinanceInfo.amount = self._pCardsData.Moneys[m][2]
                    self._tCardFront[i]:setOpacity(255)
                    self._tCardItem[i]:setFinanceInfo(tFinanceInfo)
                    table.remove(self._pCardsData.Moneys,m)
                    table.insert(self._tHasClickIndex,i)
                    bHasBreak = false
                    break
                end

            end

            if bHasBreak then  --判断剩余的里面有没有物品
                local nItemNum = table.getn(self._pCardsData.Items) --翻卡的物品数据
                for kdate,vdate in pairs(self._pCardsData.Items) do
                    local pItemInfo = {id = vdate[1], baseType = vdate[4], value = vdate[2]}
                    pItemInfo = GetCompleteItemInfo(pItemInfo)
                    self._tCardItem[i]:setItemInfo(pItemInfo)
                    self._tCardFront[i]:setOpacity(255)
                    table.remove(self._pCardsData.Items,kdate)
                    table.insert(self._tHasClickIndex,i)
                    bHasBreak = false
                    break
                end
            end
        end
        local runCardHideCallBack = function()
            self._pCardCCS:setVisible(false)
            --播放按钮动画
            local function buttonCallBack(frame)
                if nil == frame then
                    return
                end
                local str = frame:getEvent()
                if str == "end" then   --如果第一个开始显示出来
                    self._pConfirmBtn:setVisible(true)
                    self._pRePlayBtn:setVisible(true)
                    for k,v in pairs(self._tScrollViewItem) do
                        v:setTouchEnabled(true)
                    end
                    -- 新手期间隐藏掉重玩按钮
                    if TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId <= 10006 then
                        self._pRePlayBtn:setVisible(false)
                    end
                end
            end

            local pConfirmAction = cc.CSLoader:createTimeline("FightEndSureButton.csb")
            pConfirmAction:gotoFrameAndPlay(0,pConfirmAction:getDuration(), false)
            pConfirmAction:setFrameEventCallFunc(buttonCallBack)
            self._pConfirm:setVisible(true)
            self._pConfirm:runAction(pConfirmAction)
            
            local pRePlayAction = cc.CSLoader:createTimeline("FightEndAgainButton.csb")
            pRePlayAction:gotoFrameAndPlay(0,pRePlayAction:getDuration(), false)
            pRePlayAction:setFrameEventCallFunc(buttonCallBack)
            self._pRePlay:setVisible(true)
            self._pRePlay:runAction(pRePlayAction)

        end
        self._pCardCCS:runAction( cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(runCardHideCallBack)))
    end
    
    -- 引导
    if NewbieManager:getInstance()._bSkipGuide == false then
        if NewbieManager:getInstance()._nCurID == "Guide_1_5" or NewbieManager:getInstance()._nCurID == "Guide_5_21" or NewbieManager:getInstance()._nCurID == "Guide_6_16" then
            NewbieManager:getInstance():showOutAndRemoveWithRunTime()
        end
    end
    
end

--断线重连后，查询抽卡数据
function BattleEndAccountsDialog:updatePickCardState(event)
    local pCardNum = event.remainCount
    local pCardInfo = event.cardInfo
    if self._nLastClickTag then
       pCardInfo.index = self._nLastClickTag
    end
    
    if self._nPickCardNum == pCardNum then --如果当前次数跟剩余次数一样。说明数据没问题
        for i=1,table.getn(self._tCardBg) do
            self._tCardBg[i]:setTouchEnabled(true)
        end
       return
       
     else --数据不正确
     
       if pCardNum == 0 then  --如果剩余次数为0，表示已经翻牌结束了
           self._nPickCardNum = 0
           self._pCardCCS:setVisible(false)
           self._pConfirm:setVisible(true)
           self._pConfirmBtn:setVisible(true)
           self._pRePlay:setVisible(true)
           self._pRePlayBtn:setVisible(true)
           
            -- 新手期间隐藏掉重玩按钮
            if TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId <= 10006 then
                self._pRePlayBtn:setVisible(false)
            end
            
           return 
       end
     
       self._nPickCardNum = pCardNum + 1
       self:updateCard(pCardInfo)
    end
end

-- 处理函数
function BattleEndAccountsDialog:dispose(args)

    --注册
    NetRespManager:getInstance():addEventListener(kNetCmd.kUploadBattleResult ,handler(self, self.uploadBattleResult))
    NetRespManager:getInstance():addEventListener(kNetCmd.kPickCard ,handler(self, self.updateCard))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected ,handler(self, self.handleMsgReconnect))
    NetRespManager:getInstance():addEventListener(kNetCmd.kPickCardState ,handler(self, self.updatePickCardState)) --断线重连后，查询翻卡数据
    NetRespManager:getInstance():addEventListener(kNetCmd.kEntryBattle, handler(self, self.rePlayNetBack))      -- 重玩回调注册
    
    --加载
    ResPlistManager:getInstance():addSpriteFrames("FightEndCard.plist")
    ResPlistManager:getInstance():addSpriteFrames("FightEndRole.plist")
    ResPlistManager:getInstance():addSpriteFrames("FightEndSureButton.plist")
    ResPlistManager:getInstance():addSpriteFrames("FightEndUI.plist")
    ResPlistManager:getInstance():addSpriteFrames("LevelStar.plist")
    ResPlistManager:getInstance():addSpriteFrames("LvUpEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("FightEndAgainButton.plist")
    
    self._nVipPickCardNum = args[1]
    self._nPickCardNum = args[1] + 1
    self._nLastRoleLevel = args[2]
    -- 初始化UI
    self:initUI()
    self:initCards()
    
    AudioManager:getInstance():playMusic("BattleWin") -- 背景音乐
    DialogManager:getInstance():closeDialogByName("ChatDialog")

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBattleEndAccounts()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function BattleEndAccountsDialog:onExitBattleEndAccounts()
    self:onExitDialog()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    -- 释放掉login合图资源   
    ResPlistManager:getInstance():removeSpriteFrames("FightEndCard.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FightEndRole.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FightEndSureButton.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FightEndUI.plist")
    ResPlistManager:getInstance():removeSpriteFrames("LevelStar.plist")
    ResPlistManager:getInstance():removeSpriteFrames("LvUpEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FightEndAgainButton.plist")
   

end

function BattleEndAccountsDialog:uploadBattleResult(event)

    -- 战斗结算数据 更新
     self._bMidNight = event.midNight     --午夜惊魂是否开启
    BattleManager:getInstance()._bMidNight = self._bMidNight
    -- 战斗评级
    local nCurBattleLevel = event.curStar
    self:playNormalAction(nCurBattleLevel)
    print("event.curStar = "..event.curStar)
    for i=1,table.getn(event.finances) do
        self._tFinceNode[i]:setVisible(true)
        local tFinanceInfo = FinanceManager:getIconByFinanceType(event.finances[i].finance)
        self._tFinceImageIcon[i]:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
        self._tFinceText[i]:setString(event.finances[i].amount)
    end

    if event.addExp ~= 0 then --有增加的经验
        local nIndex = table.getn(event.finances)+1
        self._tFinceNode[nIndex]:setVisible(true)
        self._tFinceImageIcon[nIndex]:loadTexture("ccsComRes/icon_000.png",ccui.TextureResType.plistType)
        self._tFinceText[nIndex]:setString(event.addExp)
    end

    --人物的等级
    local tParcent = {}
    local nLevel = event.currLevel
    local nLastLevel = self._nLastRoleLevel
    for i=1,(nLevel-nLastLevel) do
        table.insert(tParcent,{100,nLastLevel+(i-1)})
    end
    local nPercent = (event.currExp/TableLevel[nLevel].Exp)*100
    table.insert(tParcent,{nPercent,nLevel})
    self._tPercent = tParcent
    --self._pExpProgressBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, nPercent)))

    self._pItems = event.items

    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101
    local nViewHeight = self._pItemsScrollView:getContentSize().height
    local nViewWidth  = self._pItemsScrollView:getContentSize().width

    --获取的物品列表
    self._pItemsScrollView:setInnerContainerSize(cc.size((nSize+nLeftAndReightDis)*table.getn(self._pItems),nViewHeight))
    for i=1,table.getn(self._pItems) do
        local pItemInfo = GetCompleteItemInfo(self._pItems[i])
        local nItemCell = require("BattleItemCell"):create()
        nItemCell:setItemInfo(pItemInfo)
        nItemCell:setTouchEnabled(false)
        nItemCell:setPosition((nSize+nLeftAndReightDis)*(i-1),0)
        self._pItemsScrollView:addChild(nItemCell)
        table.insert( self._tScrollViewItem ,nItemCell)
    end

    --更新额外奖励卡牌组 数据
    self._pCardsData = TablePoker[event.cardId]

    --收到网络回复，播放加载动画
    self._pCCS:setVisible(true)
      --界面背景的动画
    local paramsAction = cc.CSLoader:createTimeline("FightEndUI.csb")
    paramsAction:gotoFrameAndPlay(0,paramsAction:getDuration(),false)
    self._pCCS:runAction(paramsAction)

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()   --放完评星动画后的回调 播放洗牌的动画
        if str == "end" then
            if RolesManager:getInstance()._pMainRoleInfo.roleCareer == kCareer.kThug then --刺客
                self._prole03arm:setVisible(true)
            end
        end
    end

    --角色加载的动画
    local pRoleAction = cc.CSLoader:createTimeline("FightEndRole.csb")
    pRoleAction:gotoFrameAndPlay(0,pRoleAction:getDuration(),false)       --角色的csb
    pRoleAction:setFrameEventCallFunc(onFrameEvent)
    self._pRoleBg:runAction(pRoleAction)                                  --角色的动画

end

-- 循环更新
function BattleEndAccountsDialog:update(dt)

end

-- 显示结束时的回调
function BattleEndAccountsDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BattleEndAccountsDialog:doWhenCloseOver()
    return
end

-- 初始化UI
function BattleEndAccountsDialog:initUI()
    -- 加载组件
    local params = require("FightEndUIParams"):create()
    self._pCCS = params._pCCS
    self._pCCS:setVisible(false)
    self._pBg = params._pBg
    self._tRoleNode = {params._pNoderole01,params._pNoderole02,params._pNoderole03}    --挂在人物背景图片的node 1:战士 2:法师 3:刺客
    self._tFinceNode = {params._pnodegold01,params._pnodegold02,params._pnodegold03}   --挂在金钱的node 手动设置某个货币的存在
    self._tFinceImageIcon = {params._picon01,params._picon02,params._picon03}          --金钱的图片
    self._tFinceText = {params._ptext01,params._ptext02,params._ptext03}               --金钱的数值
    self._pStartLevelNode = params._pNodelevelstar                                     --星星动画的node
    self._pConfirmNode = params._pNodesure                                             --确定按钮动画的node
    self._prole03arm = params._prole03arm                                              --职业3的手
    self._prolelevel =  params._prolelevel                                             --人物的等级
    self._pExpProgressBarNode = params._pnodeexp                                       --经验条的挂载点
    --self._pExpProgressBar = params._pExpProgressBa                                    --经验条的挂载点
    self:addChild(self._pCCS)

    local sScreen = mmo.VisibleRect:getVisibleSize()
    self._pCCS:setPosition(sScreen.width/2, sScreen.height/2)


    self._pItemsScrollView = params._pscrollview
    self._pItemsScrollView:setInnerContainerSize(self._pItemsScrollView:getContentSize())


   self._pExpProgressBar = self:createRoleExpBar()

   self._pExpProgressBarNode:addChild(self._pExpProgressBar) 
   local roleInfo = RolesManager:getInstance()._pMainRoleInfo

    --设置角色的等级
    self._prolelevel:setString("Lv"..roleInfo.level)

    --设置经验条
    local nMaxExp =TableLevel[roleInfo.level].Exp
    local nCurExp =roleInfo.exp
    local nPercent = (nCurExp/nMaxExp)*100
    self._pExpProgressBar:setPercentage(nPercent)
    -- 战斗评级动画
    local plevlelStart = cc.CSLoader:createNode("LevelStar.csb")
    self._pStartLevelNode:addChild(plevlelStart)
    self._pStartLevel = plevlelStart
    self._pStartLevel:setVisible(false)

    --确定按钮的csb
    local pConfirm = cc.CSLoader:createNode("FightEndSureButton.csb")
    self._pConfirmNode:addChild(pConfirm)
    self._pConfirm = pConfirm
    pConfirm:setVisible(false)
    
    --升级动画
    local pUpLevelEf = cc.CSLoader:createNode("LvUpEffect.csb")
    pUpLevelEf:setPosition(sScreen.width/2, sScreen.height/2)
    self:addChild(pUpLevelEf)
    pUpLevelEf:setVisible(false)
    self._pUpLevelEffect = pUpLevelEf
    
    --确定按钮
    self._pConfirmBtn = pConfirm:getChildByName("surebutton")
    self._pConfirmBtn:setVisible(false)
    -- 关闭按钮的事件
    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._bMidNight == true then -- 开启了午夜惊魂
                self:getParent():closeDialogByNameWithNoAni("BattleEndAccountsDialog")
                DialogManager:getInstance():showDialog("MidNightCopysDialog")
            elseif self._bRePlay == false then
                BattleManager:getInstance()._bIsTransforingFromEndBattle = true
                self:getParent():closeDialogByNameWithNoAni("BattleEndAccountsDialog")
                LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
            end
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pConfirmBtn:addTouchEventListener(touchEvent)
    
    -- 重玩按钮
    self._pRePlay = cc.CSLoader:createNode("FightEndAgainButton.csb")
    params._pNodeagain:addChild(self._pRePlay)
    self._pRePlay:setVisible(false)
    
    self._pRePlayBtn = self._pRePlay:getChildByName("againbutton")
    self._pRePlayBtn:setVisible(false)
    
    -- 重玩按钮的事件
    local function rePlayBtnEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._bMidNight == true then     -- 如果开启了午夜惊魂，无论点击再来一次或是确认按钮，都要强制进入午夜惊魂副本
                showSystemMessage("午夜惊魂副本已被激活，无法重来一次了亲，进入答题环节......")
                DialogManager:getInstance():showDialog("MidNightCopysDialog")
                self:getParent():closeDialogByNameWithNoAni("BattleEndAccountsDialog")
                
            else
                self:rePlay()
            end
         elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pRePlayBtn:addTouchEventListener(rePlayBtnEvent)
    
    -- 非指定类型的副本 没有重玩按钮
    local pCurCopyType =  StagesManager:getInstance()._nCurCopyType
   
    if pCurCopyType ~= kType.kCopy.kStory and pCurCopyType ~= kType.kCopy.kGold and 
       pCurCopyType ~= kType.kCopy.kStuff and pCurCopyType ~= kType.kCopy.kChallenge and
       pCurCopyType ~= kType.kCopy.kMaze then
          params._pNodeagain:setVisible(false)
    end

    --角色的职业
    local roleCareer = RolesManager:getInstance()._pMainRoleInfo.roleCareer
    --角色的挂载node
    self._pRoleNode = self._tRoleNode[roleCareer]

    --背景角色的csb
    local pRoleImage = cc.CSLoader:createNode("FightEndRole.csb")
    self._pRoleNode:addChild(pRoleImage)
    self._pRoleBg = pRoleImage

    local pRoleNode = nil
    if roleCareer == kCareer.kWarrior then --战士
        pRoleNode= pRoleImage:getChildByName("role01")
    elseif roleCareer == kCareer.kMage then --法师
        pRoleNode = pRoleImage:getChildByName("role02")
    elseif roleCareer == kCareer.kThug then --刺客
        pRoleNode = pRoleImage:getChildByName("role03")
    end
    pRoleNode:setVisible(true)

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        return true   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

function BattleEndAccountsDialog:initCards()

    local sScreen = mmo.VisibleRect:getVisibleSize()
    local params = require("FightEndCardParams"):create()
    params._pCCS:setPosition(sScreen.width/2,sScreen.height/2)
    self:addChild(params._pCCS)
    self._pCardCCS = params._pCCS
    params._pCCS:setVisible(false)
    self._tCardBg = {params._pcardA01,params._pcardA02,params._pcardA03,params._pcardA04}       --背面的牌
    self._tCardFront = {params._pcardB01,params._pcardB02,params._pcardB03,params._pcardB04}  --正面的牌
    self._tCardNode = {params._pNodeitem01,params._pNodeitem02,params._pNodeitem03,params._pNodeitem04} --正面牌的挂在node
    
    --剩余翻牌次数
    self._pLeavePickCardNumLbl = cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pLeavePickCardNumLbl:setLineHeight(20)
    self._pLeavePickCardNumLbl:setAdditionalKerning(-2)
    self._pLeavePickCardNumLbl:setTextColor(cc.c4b(255, 255, 255, 255))
    self._pLeavePickCardNumLbl:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self._pLeavePickCardNumLbl:setPositionX(0)
    self._pLeavePickCardNumLbl:setPositionY(-300)
    --self._pLeavePickCardNumLbl:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    params._pCCS:addChild(self._pLeavePickCardNumLbl)

    for i=1,table.getn(self._tCardNode) do
        local nItemCell = require("BattleItemCell"):create()
        nItemCell:setVisible(false)
        self._tCardNode[i]:addChild(nItemCell)
        table.insert(self._tCardItem,nItemCell)

    end

    local onTouchCardBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            if self._nPickCardNum == 0 then --翻牌结束
                return
            end
            for i=1,table.getn( self._tHasClickIndex) do
                if self._tHasClickIndex[i]==nTag then
                    return
                end
            end
            for i=1,table.getn(self._tCardBg) do
               self._tCardBg[i]:setTouchEnabled(false)
            end
            self._nLastClickTag = nTag --记录上一次的点击的下表(断线重连用)
            MessageGameInstance:sendMessagePickCard21006(nTag)

          elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    for i=1,table.getn(self._tCardBg) do
        self._tCardBg[i]:setTag(i)
        self._tCardBg[i]:setTouchEnabled(false)
        self._tCardBg[i]:addTouchEventListener(onTouchCardBg)
    end


end

function BattleEndAccountsDialog:initCardsDate()

    self._pCardCCS:setVisible(true)
    self._pLeavePickCardNumLbl:setVisible(false)
    --vip额外的抽卡次数
    if self._nVipPickCardNum > 0 then
     self._pLeavePickCardNumLbl:setString("请翻牌领取追加奖励 剩余次数： " .. 1 .. " + vip".. self._nVipPickCardNum .. "次")
    else
     self._pLeavePickCardNumLbl:setString("请翻牌领取追加奖励 剩余次数： " .. self._nPickCardNum)
    end



    if self._pCardsData.Moneys == nil then
        self._pCardsData.Moneys ={}
    end
    local nMonesyNum = table.getn(self._pCardsData.Moneys) --翻卡的金钱数据
    for i=1,nMonesyNum do
        local nItemCell = self._tCardItem[i]
        local pMoneysInfo = self._pCardsData.Moneys[i]
        local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(pMoneysInfo[1])
        tFinanceInfo.amount = pMoneysInfo[2]
        nItemCell:setFinanceInfo(tFinanceInfo)
    end
    if self._pCardsData.Items == nil then
        self._pCardsData.Items ={}
    end

    local nItemIndex = nMonesyNum    --物品挂载点的开始index
    if self._pCardsData._pCardsData == nil then
        self._pCardsData._pCardsData ={}
    end
    local nItemNum = table.getn(self._pCardsData.Items) --翻卡的物品数据
    for i=1,nItemNum do
        local nItemCell = self._tCardItem[i+nItemIndex]
        local pdate =  self._pCardsData.Items[i]
        local pItemInfo = {id = pdate[1], baseType = pdate[4], value = pdate[2]}
        pItemInfo = GetCompleteItemInfo(pItemInfo)
        nItemCell:setItemInfo(pItemInfo)
        nItemCell:setTouchEnabled(false)
    end


    --播放洗牌的动画
    local function playShuffleCell(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "open1" then   --如果第一个开始显示出来
            self._tCardItem[1]:setVisible(true)
        elseif str == "open2" then
            self._tCardItem[2]:setVisible(true)
        elseif str == "open3" then
            self._tCardItem[3]:setVisible(true)
        elseif str == "open4" then
            self._tCardItem[4]:setVisible(true)
        elseif str == "close" then     --item全部隐藏
            for i=1,table.getn(self._tCardItem) do
                self._tCardItem[i]:setVisible(false)
            end
        elseif str == "end" then      --背景图片可以点击
            for i=1,table.getn(self._tCardBg) do
                self._tCardBg[i]:setTouchEnabled(true)
            end
        end

    end

    local paramsAction = cc.CSLoader:createTimeline("FightEndCard.csb")
    paramsAction:setFrameEventCallFunc(playShuffleCell)
    paramsAction:gotoFrameAndPlay(0,paramsAction:getDuration(),false)
    self._pCardCCS:runAction(paramsAction) --播放动画
end



-- 播放战斗评级动作
function BattleEndAccountsDialog:playNormalAction(nStarNum)

    local runStartAction = function()
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end
            local str = frame:getEvent()   --放完评星动画后的回调 播放洗牌的动画
            print(str)
            if str ==  "starover"..nStarNum then
             self:setRoleExpBarPercent(self._tPercent) 
             if table.getn(self._tPercent) >1 then 
                local pUpLevelAct = cc.CSLoader:createTimeline("LvUpEffect.csb")
                pUpLevelAct:gotoFrameAndPlay(0,pUpLevelAct:getDuration(), false)
                self._pUpLevelEffect:setVisible(true)
                self._pUpLevelEffect:runAction(pUpLevelAct)
             end       
            end
        end
        local pLevelStarAct = cc.CSLoader:createTimeline("LevelStar.csb")
        pLevelStarAct:gotoFrameAndPlay(self._NormalActFrameRegion[nStarNum][1], self._NormalActFrameRegion[nStarNum][2], false)
        pLevelStarAct:setFrameEventCallFunc(onFrameEvent)
        self._pStartLevel:setVisible(true)
        self._pStartLevel:runAction(pLevelStarAct)
        
    end

    self:runAction( cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(runStartAction)))
end

--创建一个进度条
function BattleEndAccountsDialog:createRoleExpBar()
    -- 进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName("FightEndUIRes/exp.png")
    local pLoadingBar = cc.ProgressTimer:create(pSprite)
    pLoadingBar:setPosition(cc.p(0,0))
    pLoadingBar:setScaleX(2.78)
    pLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pLoadingBar:setMidpoint(cc.p(0, 0))
    pLoadingBar:setBarChangeRate(cc.p(1, 0))
    pLoadingBar:setPercentage(0)
    return pLoadingBar
end

function BattleEndAccountsDialog:setRoleExpBarPercent(nPercent)
    local nSize = table.getn(nPercent)
    for i=1,nSize do 
    
        local callBack = function()
            self._prolelevel:setString("Lv"..nPercent[i][2])
            if i<nSize then
                self._pExpProgressBar:setPercentage(0)
             elseif i == nSize then
               if self._nPickCardNum > 0 then
                self:initCardsDate()
               end
             end
        end   
        self._pExpProgressBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*i), cc.ProgressTo:create(0.2, nPercent[i][1]),cc.CallFunc:create(callBack)))
      end 
end

-- 重玩本次副本
function BattleEndAccountsDialog:rePlay()
    if self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kStory or self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kGold or
        self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kStuff or self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kChallenge or
        self:getBattleManager()._tBattleArgs._nCurCopyType == kType.kCopy.kMaze then
        MessageGameInstance:sendMessageEntryBattle21002(self:getBattleManager()._tBattleArgs._nBattleId,0)
    end
end

-- 重玩本次副本的回调
function BattleEndAccountsDialog:rePlayNetBack()
    -- 切换战斗
    self._bRePlay = true
    BattleManager:getInstance()._bIsTransforingFromEndBattle = true
    self:getParent():closeDialogByNameWithNoAni("BattleEndAccountsDialog")
    LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,BattleManager:getInstance()._tBattleArgs)
end

function BattleEndAccountsDialog:closeWithAni()
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


return BattleEndAccountsDialog
