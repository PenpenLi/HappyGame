--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleTowerAccountsDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/4/24
-- descrip:   爬塔副本结算界面
--===================================================
local BattleTowerAccountsDialog = class("BattleTowerAccountsDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BattleTowerAccountsDialog:ctor()
    self._strName = "BattleTowerAccountsDialog"        -- 层名称
    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pConfirmBtn = nil           --确定按钮
    self._pScrollView = nil
    self._tFinceNode = {}             --挂在金钱的node 手动设置某个货币的存在
    self._tFinceImageIcon = {}        --货币的图片
    self._tFinceText = {}             --金钱的数值
    self._pExpProgressBar = nil       --进度条
    self._pExpProgressBarNode = nil   --进度条挂在node
    self._prolelevel = nil            --人物等级

    self._pAccountDate = nil
    self._tAddid = {}
end

-- 创建函数
function BattleTowerAccountsDialog:create(args)
    local dialog = BattleTowerAccountsDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function BattleTowerAccountsDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("TowerFinishDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("LvUpEffect.plist")
    
    local params = require("TowerFinishDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pConfirmBtn  = params._pOkButton
    self._pScrollView = params._pScrollView
    self._pExpProgressBarNode = params._pExpBarNode -- 进度条挂载node
    self._prolelevel = params._pLvText      --人物等级
    self._tFinceNode = {params._pExpNode,params._pMoneyNode,params._pRmbNode,params._pToukonNode}        --挂在金钱的node 手动设置某个货币的存在
    self._tFinceImageIcon = {params._pExpIcon,params._pMoneyIcon,params._pRmbIcon,params._pToukonIcon}    --货币的图片
    self._tFinceText = {params._pExpTextNum,params._pMoneyTextNum,params._pRmbTextNum,params._pToukonTextNum}   --金钱的数值
    -- 初始化dialog的基础组件
    self:disposeCSB()
    self:setAccountsDate(args)
    self:initUiDate()
    self:initScrollView()
    
    AudioManager:getInstance():playMusic("BattleWin") -- 背景音乐

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
            self:onExitBattleTowerAccountsDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end
--结算数据整理
function BattleTowerAccountsDialog:setAccountsDate(args)
    self._pAccountDate = {}
    local nLastLevel = RolesManager:getInstance()._pMainRoleInfo.level
    local nLastExp = RolesManager:getInstance()._pMainRoleInfo.exp
    local nAddExp = 0
    local tFinances = {}
    local tItemlists = {}
    local tAddId = {}


    for k,v in pairs(args) do
        --经验
        nAddExp = nAddExp + v.addExp
        --金融
        for i=1,table.getn(v.finances) do
            local nType = v.finances[i].finance
            local nValue =  v.finances[i].amount
            if tFinances[nType] == nil then
                tFinances[nType] = 0
            end
            tFinances[nType] =  tFinances[nType] +nValue
        end
        --玩家当前等级和经验
        if k == table.getn(args)then  --最后一次设置经验和等级
            RolesManager:getInstance()._pMainRoleInfo.exp = v.currExp
            RolesManager:getInstance()._pMainRoleInfo.level = v.currLevel
        end

        --更新人物属性
        if table.getn(v.roleAttrInfo) > 0 then
            RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = v.roleAttrInfo
        end
        
        --更新装备
        for i=1,table.getn(v.items) do
            local pItems = v.items[i]
            local nId = pItems.id
            if tAddId[nId] == nil then  --没有加载过这个id
                tAddId[nId] = nId
                table.insert(tItemlists,GetCompleteItemInfo(pItems))
            else --加载过这个id
                if v.baseType == kItemType.kEquip then
                    table.insert(tItemlists,GetCompleteItemInfo(pItems))
            else --可以把value相加一下
                local nIndex = self:selectDateIndexByID(tItemlists,nId)
                tItemlists[nIndex].value = tItemlists[nIndex].value +pItems.value
            end
            end
        end
    end

    self._pAccountDate.LastLevel = nLastLevel
    self._pAccountDate.LastExp = nLastExp
    self._pAccountDate.AddExp = nAddExp
    self._pAccountDate.Finances = tFinances
    self._pAccountDate.Itemlists = tItemlists

end

--初始化界面数据
function BattleTowerAccountsDialog:initUiDate()

    --初始化金钱
    local pFinances =  self._pAccountDate.Finances
    local nIndex = 1
    for i=1,kFinance.kFC do 
        if pFinances[i] ~= nil then
            self._tFinceNode[nIndex]:setVisible(true)
            local tFinanceInfo = FinanceManager:getIconByFinanceType(i)
            self._tFinceImageIcon[nIndex]:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
            self._tFinceText[nIndex]:setString(pFinances[i])
            nIndex = nIndex +1
        end

    end

    --进度条
    self._pExpProgressBar = self:createRoleExpBar()
    self._pExpProgressBarNode:addChild(self._pExpProgressBar)

    --设置角色的等级
    local nLastLevel = self._pAccountDate.LastLevel
    local nLastExp = self._pAccountDate.LastExp
    local nCurLevel = RolesManager:getInstance()._pMainRoleInfo.level
    local nCurExp = RolesManager:getInstance()._pMainRoleInfo.exp


    --设置开始的经验和进度条
    local pTempMaxExp = (TableLevel[nLastLevel].Exp == 0) and nLastExp or TableLevel[nLastLevel].Exp
    local nPercent = (nLastExp/pTempMaxExp)*100
    self._pExpProgressBar:setPercentage(nPercent)
    self._prolelevel:setString("Lv"..nLastLevel)



    --进度条动画
    local tParcent = {}
    for i=1,(nCurLevel-nLastLevel) do
        table.insert(tParcent,{100,nLastLevel+(i-1)})
    end
    local pTempCurMaxExp = (TableLevel[nCurLevel].Exp == 0) and nCurExp or TableLevel[nCurLevel].Exp
    local nPercent = (nCurExp/pTempCurMaxExp)*100
    table.insert(tParcent,{nPercent,nCurLevel})
    self:setRoleExpBarPercent(tParcent)
    
    --升级特效
    if table.getn(tParcent) > 1 then
        local sScreen = mmo.VisibleRect:getVisibleSize()
        local pUpLevelEf = cc.CSLoader:createNode("LvUpEffect.csb")
        pUpLevelEf:setPosition(sScreen.width/2, sScreen.height/2)
        self:addChild(pUpLevelEf)
        local pUpLevelAct = cc.CSLoader:createTimeline("LvUpEffect.csb")
        pUpLevelAct:gotoFrameAndPlay(0,pUpLevelAct:getDuration(), false)
        pUpLevelEf:runAction(pUpLevelAct)
    end

    
    -- 设置已装备物品关闭按钮的事件
    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            --关闭当前打开的Dialog
            BattleManager:getInstance()._bIsTransforingFromEndBattle = true
            self:getParent():closeDialogByNameWithNoAni("BattleTowerAccountsDialog")
            LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pConfirmBtn:addTouchEventListener(touchEvent)

end


--初始化ScrollView
function BattleTowerAccountsDialog:initScrollView()

    local pItemDate = self._pAccountDate.Itemlists
    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101
    local nViewHeight = self._pScrollView:getContentSize().height
    local nViewWidth  = self._pScrollView:getContentSize().width

    --获取的物品列表
    self._pScrollView:setInnerContainerSize(cc.size((nSize+nLeftAndReightDis)*table.getn(pItemDate),nViewHeight))
    for i=1,table.getn(pItemDate) do
        local nItemCell = require("BattleItemCell"):create()
        nItemCell:setItemInfo(pItemDate[i])
        nItemCell:setPosition((nSize+nLeftAndReightDis)*(i-1),0)
        self._pScrollView:addChild(nItemCell)
    end

end

--判断这个物品是否add了
function BattleTowerAccountsDialog:selectDateIndexByID(tDate,nId)
    for k,v in pairs(tDate) do
        if v.id == nId then
            return k
        end
    end
end


--创建一个进度条
function BattleTowerAccountsDialog:createRoleExpBar()
    -- 进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName("TowerFinishDialog/exp.png")
    local pLoadingBar = cc.ProgressTimer:create(pSprite)
    pLoadingBar:setPosition(cc.p(0,0))
    pLoadingBar:setScaleX(1.76)
    pLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pLoadingBar:setMidpoint(cc.p(0, 0))
    pLoadingBar:setBarChangeRate(cc.p(1, 0))
    pLoadingBar:setPercentage(0)
    return pLoadingBar
end

function BattleTowerAccountsDialog:setRoleExpBarPercent(nPercent)
    local nSize = table.getn(nPercent)
    for i=1,nSize do

        local callBack = function()
            self._prolelevel:setString("Lv"..nPercent[i][2])
            if i<nSize then
                self._pExpProgressBar:setPercentage(0)
            end
        end
        self._pExpProgressBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*i), cc.ProgressTo:create(0.2, nPercent[i][1]),cc.CallFunc:create(callBack)))
    end
end


-- 退出函数
function BattleTowerAccountsDialog:onExitBattleTowerAccountsDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("TowerFinishDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("LvUpEffect.plist")
end

function BattleTowerAccountsDialog:closeWithAni()
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

-- 循环更新
function BattleTowerAccountsDialog:update(dt)
    return
end

-- 显示结束时的回调
function BattleTowerAccountsDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BattleTowerAccountsDialog:doWhenCloseOver()
    return
end

return BattleTowerAccountsDialog
