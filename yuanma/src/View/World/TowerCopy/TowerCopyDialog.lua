--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TowerCopyDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/4/15
-- descrip:   爬塔副本入口
--===================================================
local TowerCopyDialog = class("TowerCopyDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function TowerCopyDialog:ctor()
    self._strName = "TowerCopyDialog"       -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pPageView = nil                   -- 界面的pageView
    self._pNextButton = nil                 -- 下一个章节按钮
    self._pLastButton = nil                 -- 上一个章节按钮
    self._pCurTowerNum = nil                -- 当前塔所在的层数

    self._nClickBattleId = nil              -- 选中具体副本的章节id
    self._nClickStoryId = nil               -- 选中的具体副本id
    self._tPageViewIndex = {}               -- pageView已经加载过的章节
    self._tStoryBattleInfo = {}             -- 副本的总信息
    self._pScrollView = nil                 -- 奖励通关的ScrollView
    self._pBattleButton = nil               -- 进入战斗的信息
    self._pResidueNum = nil                 -- 挑战剩余次数
    self._pAllNum = nil                     -- 挑战总次数
    self._pTowerTexture = nil               -- 第几层塔的图片

    self._pCurTowerId = nil                 -- 当前的爬塔id
    self._tPageViewIndex = {}               -- 当前pageView加载的塔ID

    self._tLoadTextrue = {}
    self._tTowerCopyInfo = {}               -- 爬塔副本信息
    self._nIdentity = nil                   -- 标识id


    self._pTempScrollView = nil             -- 临时的ScrollView 需要手动设置ScrollView的位移量
    self._nOffectParent = 0                 -- scrollview的偏移量
    self._tOffectPar = {}                   -- 所有副本的偏移量
    self._bHasAllLoad = true                -- 是否一次性加载过来
    self._tBossOpenId = {}

    self._pSelectedCopysDataInfo = nil
    self._pSelectedCopysFirstMapInfo = nil


end

-- 创建函数
function TowerCopyDialog:create(args)
    local dialog = TowerCopyDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function TowerCopyDialog:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kEntryBattle ,handler(self, self.entryBattleCopy))
    self._tTowerCopyInfo = args[1]
    self._nIdentity = args[2]
    self:initUI()

    local pInitDate = nil
    for k,v in pairs(self._tTowerCopyInfo) do
        self:addPagePanelByInfo(TableTowerChapter[v.towerId],v.currId)
        if k == 1 then --标示第一章
            pInitDate = v
            if self._bHasAllLoad == false then
                break
            end
        end

    end

    self:updateScrollViewGetItemInfoById(pInitDate.currId,pInitDate.copyType)
    self:setChangeBtHasVisableById(pInitDate.towerId)
    self:setUiBattleDate(pInitDate)
    self:playTowerBossAniByChaper(pInitDate.towerId)
    self:disposeCSB()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
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
            self:onExitTowerCopyDialog()
        end
    end

    self:registerScriptHandler(onNodeEvent)
    return

end


--初始化界面
function TowerCopyDialog:initUI()

    ResPlistManager:getInstance():addSpriteFrames("TowerCopysDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("TowerEffect.plist")
    local params = require("TowerCopysDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pPageView = params._pTowerPageView
    self._pNextButton = params._pNextButton
    self._pLastButton = params._pCPreviousButton
    self._pCurTowerNum = params._pSmText2Num
    self._pScrollView = params._pScrollView
    self._pBattleButton = params._pBattleButton
    self._pResidueNum = params._pChallengeNum1 --挑战剩余次数
    self._pAllNum = params._pChallengeNum2     --挑战总次数
    self._pTowerTexture =  params._pTowerName  --第几层塔的图片
    self._pPageView:setTouchEnabled(false)
    --左翻，又翻的button
    local  onTouchExchengeButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local ncurIndex = self._pPageView:getCurPageIndex()
            local nTag = sender:getTag()
            if nTag == 1 then --下一个
                local nJumpStoryId = ncurIndex+2
                if self:selectStoryHasLoadById(nJumpStoryId) == false then --如果下一章没有加载
                    self:addPagePanelByInfo(TableTowerChapter[nJumpStoryId],self._tTowerCopyInfo[nJumpStoryId].currId)
                    self:updateScrollViewGetItemInfoById(self._tTowerCopyInfo[nJumpStoryId].currId,self._tTowerCopyInfo[nJumpStoryId].copyType)
                end
                self:setScrollViewOffect(nJumpStoryId)
                self:updateScrollViewGetItemInfoById(self._tTowerCopyInfo[nJumpStoryId].currId,self._tTowerCopyInfo[nJumpStoryId].copyType)
                self:setUiBattleDate(self._tTowerCopyInfo[nJumpStoryId])
                self:setChangeBtHasVisableById(ncurIndex+2)
                self._pPageView:scrollToPage(ncurIndex+1)
                self:playTowerBossAniByChaper(nJumpStoryId)


            elseif nTag ==2 then --上一个
                local nJumpStoryId = ncurIndex
                self:setScrollViewOffect(nJumpStoryId)
                self:setChangeBtHasVisableById(ncurIndex)
                self:updateScrollViewGetItemInfoById(self._tTowerCopyInfo[nJumpStoryId].currId,self._tTowerCopyInfo[nJumpStoryId].copyType)
                self:setUiBattleDate(self._tTowerCopyInfo[nJumpStoryId])
                self._pPageView:scrollToPage(ncurIndex-1)
                self:playTowerBossAniByChaper(nJumpStoryId)
            end

        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pNextButton:addTouchEventListener(onTouchExchengeButton)
    self._pNextButton:setTag(1)
    self._pLastButton:addTouchEventListener(onTouchExchengeButton)
    self._pLastButton:setTag(2)

    --进入战斗的button
    local onTouchBattleButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self._pSelectedCopysDataInfo == nil or self._pSelectedCopysFirstMapInfo == nil then
                return
            end
            MessageGameInstance:sendMessageEntryBattle21002(self._pSelectedCopysDataInfo.ID,self._nIdentity)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pBattleButton:addTouchEventListener(onTouchBattleButton)


end

--根据爬塔的id开刷新下面的数据信息
function TowerCopyDialog:updateScrollViewGetItemInfoById(nPowerId,pStoryType)
    local tTowerCopysInfo = nil
    local pScrollViewInfo = nil
    local pBool =  false --是否是副本是否显示获得物品的数目
    if pStoryType == kType.kCopy.kTower then
        tTowerCopysInfo = TableTowerCopys[nPowerId-500]
        self._pSelectedCopysDataInfo = tTowerCopysInfo
        self._pSelectedCopysFirstMapInfo = TableTowerCopysMaps[self._pSelectedCopysDataInfo.MapID]
        pScrollViewInfo = getBoxInfo(tTowerCopysInfo.MustDropItem)
        --设置下层数
        self._pCurTowerNum:setString(tTowerCopysInfo.SortNumber)
        pBool = true

    elseif pStoryType == kType.kCopy.kMapBoss then
        tTowerCopysInfo = TableMapBossCopys[nPowerId-600]
        self._pSelectedCopysDataInfo = tTowerCopysInfo
        self._pSelectedCopysFirstMapInfo = TableMapBossCopysMaps[self._pSelectedCopysDataInfo.MapID]
        pScrollViewInfo = getBoxInfo(tTowerCopysInfo.MayDropItems)
        --设置下层数
        self._pCurTowerNum:setString("Boss")
        pBool = false
    end


    --设置ScrollView数据
    self._pScrollView:removeAllChildren(true)

    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101                                   --每个cell的宽度和高度
    local nStartx = 0
    local nScale = 0.75
    local nNum =table.getn(pScrollViewInfo)
    local nViewWidth  = self._pScrollView:getContentSize().width
    local nViewHeight  = self._pScrollView:getContentSize().height
    local pScrInnerWidth = (nViewWidth >(nLeftAndReightDis+nSize)*nNum) and nViewWidth or (nLeftAndReightDis+nSize)*nNum
    self._pScrollView:setInnerContainerSize(cc.size(pScrInnerWidth,nViewHeight))
    self._pScrollView:setBounceEnabled(false)
    for i=1,nNum do
        local pDateInfo = pScrollViewInfo[i]
        local pCell =  require("BattleItemCell"):create()
        pCell:setScale(nScale)
        local nX = (i-1)*(nSize+nLeftAndReightDis)+nStartx
        local nY = (nViewHeight-nSize*nScale)/2
        pCell:setPosition(nX*nScale,nY)

        if pDateInfo.finance then --是货币
            pCell:setFinanceInfo(pScrollViewInfo[i])
        else
            pCell:setItemInfo(pScrollViewInfo[i])
        end
        --设置数量是否显示
        pCell:setItemNumHasVisible(pBool)
        pCell:setTouchEnabled(false)
        self._pScrollView:addChild(pCell)

    end
end

--设置界面的其他信息 --第几层 ，剩余次数
function TowerCopyDialog:setUiBattleDate(pInfo)
    if pInfo == nil then
        return
    end
    local nMaxNum = TableTowerChapter[pInfo.towerId].Times+pInfo.extCount
    self._pResidueNum:setString(nMaxNum-pInfo.currCount)
    self._pAllNum:setString("/"..nMaxNum)
    self._pTowerTexture:loadTexture("TowerCopysDialog/TowerName"..pInfo.towerId..".png",ccui.TextureResType.plistType)
end


--设置左右button是否显示可以切换通过towerid
function TowerCopyDialog:setChangeBtHasVisableById(nTowerId)
    local bNextHasVis = nil
    if nTowerId ~= table.getn(self._tTowerCopyInfo)then
        bNextHasVis = true
    else
        bNextHasVis =false
    end
    self._pNextButton:setVisible(bNextHasVis)                --下一个章节按钮

    local bLastHasVis = nil
    if nTowerId == 1 then
        bLastHasVis = false
    else
        bLastHasVis =true
    end
    self._pLastButton:setVisible(bLastHasVis)                --上章节按钮
end


--通过id判断pageView是否加载了该章节
function TowerCopyDialog:selectStoryHasLoadById(nStoryId)
    for i=1,table.getn(self._tPageViewIndex) do
        if self._tPageViewIndex[i] == nStoryId then
            return true
        end
    end
    return false
end

--通过数据来初始化ScrollView pDateInfo是章节信息
function TowerCopyDialog:addPagePanelByInfo(pDateInfo,pCurCopyId)
    if pDateInfo == nil then
        return
    end
    table.insert(self._tPageViewIndex,pDateInfo.Chapter)
    local pSize = self._pPageView:getContentSize()
    local layout = ccui.Layout:create()
    layout:setContentSize(pSize)

    --初始化ScrollView
    local scrollView = ccui.ScrollView:create()
    scrollView:setContentSize(pSize)
    layout:addChild(scrollView)
    scrollView:setTouchEnabled(true)
    scrollView:setPropagateTouchEvents(false)
    --设置塔的图片
    local nIndex = 0
    local nUpAndDownDis = 0                  --装备上下与框的间隔
    local nHeight = 90
    local nStoryState = 0      --0:已经开启    1：准备攻打  2：未开启
    scrollView:setInnerContainerSize(cc.size(pSize.width,(nHeight+nUpAndDownDis)*(table.getn(pDateInfo.TheCopys)+1)))
    for i=1,table.getn(pDateInfo.TheCopys)+1 do
        local pStoreyImage = nil
        local pX = pSize.width/2
        local pY = (i-1)*(nHeight+nUpAndDownDis)+nHeight/2
        local pStoryText = "" -- 塔的层数
        if i > table.getn(pDateInfo.TheCopys) then --boss
            if pDateInfo.MapBossCopysID == pCurCopyId then --说明当前达到boss关卡了
                self:addCurCopyEffect(scrollView,cc.p(pX,pY-10),pDateInfo.Chapter)
                nStoryState = 1
                nIndex = i
        end
        pStoreyImage = self:addCopyStoreyImage(pDateInfo,nStoryState,"BOSS")

        else
            if pDateInfo.TheCopys[i] == pCurCopyId then --标示章节开启
                nStoryState = 1
                pStoreyImage = self:addCopyStoreyImage(pDateInfo,nStoryState,i)
                self:addCurCopyEffect(scrollView,cc.p(pX,pY))
                nStoryState = 2
                nIndex = i
                if i == 1 then --标示第一层
                    BagCommonManager:getInstance():resetPlayBossId(pDateInfo.Chapter)
                end
                
                
            else   --未开启状态或者已经开启装备

                pStoreyImage = self:addCopyStoreyImage(pDateInfo,nStoryState,i)
            end
        end

        pStoreyImage:setPosition(cc.p(pX,pY))
        scrollView:addChild(pStoreyImage,2)
    end

    local Parent = self:getOffectNum(nIndex,table.getn(pDateInfo.TheCopys)+1)
    table.insert(self._tOffectPar,{scrollView,Parent})
    self:setScrollViewOffect(pDateInfo.Chapter)

    self._pPageView:addPage(layout)
end

--添加特效
function TowerCopyDialog:addCurCopyEffect(pScrollView,pPos,nChapterId)
   
    if nChapterId then
       local pTowerEffectNode = cc.CSLoader:createNode("TowerBossEffect.csb")
       pTowerEffectNode:setPosition(pPos)
       pScrollView:addChild(pTowerEffectNode,5)
       pTowerEffectNode:setVisible(false)
       self._tBossOpenId[nChapterId] = pTowerEffectNode	
    end

    local pTowerEffectNode = cc.CSLoader:createNode("TowerEffect.csb")
    local pTowerEffectAction = cc.CSLoader:createTimeline("TowerEffect.csb")
    pTowerEffectAction:gotoFrameAndPlay(0,pTowerEffectAction:getDuration(), true)
    pTowerEffectNode:setPosition(pPos)
    pScrollView:addChild(pTowerEffectNode,3)
    pTowerEffectNode:runAction(pTowerEffectAction)

end

--播放第X章的boss特效
function TowerCopyDialog:playTowerBossAniByChaper(nChaperId)
    local tPlayId = BagCommonManager:getInstance()._tPlayTowerAniId
    for k,v in pairs(tPlayId) do
      if nChaperId == v  then --这个特效已经播放一次了
        return 
      end
    end


    if self._tBossOpenId[nChaperId] ~= nil then 
        self._tBossOpenId[nChaperId]:setVisible(true)
        self._tBossOpenId[nChaperId]:stopAllActions()
        local pTowerEffectAction = cc.CSLoader:createTimeline("TowerBossEffect.csb")
        pTowerEffectAction:gotoFrameAndPlay(0,pTowerEffectAction:getDuration(), false)
        self._tBossOpenId[nChaperId]:runAction(pTowerEffectAction)
        BagCommonManager:getInstance():insertPlayBossId(nChaperId)
    end
end



--根据塔的id和塔某一层的状态返回生成的塔层数图片
function TowerCopyDialog:addCopyStoreyImage(pCopyChapterInfo,nState,pText)

    local pBgSize = nil

    local pItemBg = ccui.ImageView:create()
    pItemBg:loadTexture(pCopyChapterInfo.TowerBgName..".png",ccui.TextureResType.plistType)

    pBgSize = pItemBg:getContentSize()
    --塔里面的icon
    local pItemIcon = ccui.ImageView:create()
    pItemIcon:loadTexture("TowerCopysDialog/ptjm11.png",ccui.TextureResType.plistType)
    pItemIcon:setPosition(cc.p(pBgSize.width/2,pBgSize.height/2))
    pItemBg:addChild(pItemIcon)


    --塔的层数
    local pItemNum = ccui.TextBMFont:create()
    pItemNum:setFntFile("BOSS.fnt")
    pItemNum:setAnchorPoint(1,0.5)
    pItemNum:setPosition(cc.p(pBgSize.width*0.7,pBgSize.height/2-4))
    pItemNum:setString("")
    pItemBg:addChild(pItemNum)

    --图片字   “层”
    local pItemstoreyImage = ccui.ImageView:create()
    pItemstoreyImage:loadTexture("TowerCopysDialog/ptjm9.png",ccui.TextureResType.plistType)
    pItemstoreyImage:setPosition(cc.p(pBgSize.width*0.7,pBgSize.height/2-8))
    pItemstoreyImage:setAnchorPoint(0,0.5)
    pItemBg:addChild(pItemstoreyImage)

    --未开启的图片
    local pItemNotOpenImage = ccui.ImageView:create()
    pItemNotOpenImage:setPosition(cc.p(pBgSize.width/2,pBgSize.height/2))
    pItemBg:addChild(pItemNotOpenImage)

    --塔前面的开启小箱子
    local pItemSmallIcon = ccui.ImageView:create()
    pItemSmallIcon:setPosition(cc.p(pBgSize.width*0.3,pBgSize.height/2))
    pItemBg:addChild(pItemSmallIcon)

    if nState == 2 then --未开启
        pItemNotOpenImage:loadTexture("TowerCopysDialog/ptjm10.png",ccui.TextureResType.plistType)
        pItemstoreyImage:setVisible(false)
        darkNode(pItemIcon:getVirtualRenderer():getSprite())

    elseif nState == 1 then --准备攻打的副本
        pItemSmallIcon:loadTexture("TowerCopysDialog/ptjm6.png",ccui.TextureResType.plistType)
        pItemNum:setString(pText)
    else --已经通关
        pItemSmallIcon:loadTexture("TowerCopysDialog/ptjm7.png",ccui.TextureResType.plistType)
        pItemIcon:setColor(cGrey)
        pItemNum:setString(pText)

    end


    return pItemBg
end



--进入战斗
function TowerCopyDialog:entryBattleCopy()
    if self._pSelectedCopysDataInfo ~= nil and self._pSelectedCopysFirstMapInfo ~= nil then
        --战斗数据组装
        -- 【战斗数据对接】
        local args = {}
        args._strNextMapName = self._pSelectedCopysFirstMapInfo.MapsName
        args._strNextMapPvrName = self._pSelectedCopysFirstMapInfo.MapsPvrName
        args._nNextMapDoorIDofEntity = self._pSelectedCopysFirstMapInfo.Doors[1][1]
        --require("TestMainRoleInfo")    --roleInfo
        args._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo
        args._nMainPlayerRoleCurHp = nil      -- 从副本进入时，这里为无效值
        args._nMainPlayerRoleCurAnger = nil   -- 从副本进入时，这里为无效值
        args._nMainPetRoleCurHp = nil         -- 从副本进入时，这里为无效值
        args._nCurCopyType =self._pSelectedCopysDataInfo.CopysType
        args._nCurStageID = self._pSelectedCopysDataInfo.ID
        args._nCurStageMapID = self._pSelectedCopysDataInfo.MapID
        args._nBattleId = self._pSelectedCopysDataInfo.ID
        args._fTimeMax = self._pSelectedCopysDataInfo.Timeing
        args._bIsAutoBattle = false
        args._tMonsterDeadNum = {}
        args._nIdentity = self._nIdentity
        args._tTowerCopyStepResultInfos = {}
        args._pPvpRoleInfo = nil
        args._tPvpRoleMountAngerSkills = {}
        args._tPvpRoleMountActvSkills = {}
        args._tPvpPasvSkills = {}
        args._tPvpPetRoleInfosInQueue = {}

        --关闭当前打开的Dialog
        self:getGameScene():closeDialogByNameWithNoAni("CopysPortalDialog")
        self:getGameScene():closeDialogByNameWithNoAni("TowerCopyDialog")
        --切换战斗场景
        LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
    end
end

--设置ScrollView的偏移量
function TowerCopyDialog:setScrollViewOffect(nChapter)
    local ptempInfo = self._tOffectPar[nChapter]
    if ptempInfo == nil then
        return
    end
    local pScrollView = ptempInfo[1]
    local nParance = ptempInfo[2]
    pScrollView:scrollToPercentVertical(100-nParance,0.1,false)
end

--设置ScrollView的offect 
function TowerCopyDialog:getOffectNum(nClickIndex,nAllNum)
    if nClickIndex <=5 then
	   return 0
    end
    if nClickIndex >nAllNum - 5 then
		return 100
	end
	 
    return (nClickIndex-4)/(nAllNum-5) *100
end


-- 退出函数
function TowerCopyDialog:onExitTowerCopyDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("TowerCopysDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("TowerEffect.plist")
end

-- 循环更新
function TowerCopyDialog:update(dt)
    return
end

-- 显示结束时的回调
function TowerCopyDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function TowerCopyDialog:doWhenCloseOver()
    return
end

return TowerCopyDialog
