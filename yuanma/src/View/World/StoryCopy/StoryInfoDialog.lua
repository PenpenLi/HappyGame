--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryInfoDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/15
-- descrip:   关卡副本的详细信息
--===================================================
local StoryInfoDialog = class("StoryInfoDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function StoryInfoDialog:ctor()
    self._strName = "StoryInfoDialog"                               -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pStoryName = nil                                          --关卡的名字
    self._pStorydifficulty = nil                                    --关卡的难度
    self._pNeedLevel = nil                                          --关卡的需要的等级
    self._pSuggestBtPower =nil                                      --关卡的推荐战斗力
    self._pPhysicalValueProgressBar = nil                           --当前体力的进度条
    self._pPhysicalValueProgressText = nil                          --当前体力/剩余体力
    self._pResidueCount = nil                                       --关卡的剩余次数
    self._pExpendPhysicalValueProgress= nil                         --关卡需要消耗的体力
    self._pEnterBattleButton = nil                                  --进入副本的button
    self._pScrollview = nil                                         --关卡可以得到的奖励ScrollView
    self._pLevelstarImage = nil                                     --关卡的星级图片

    self._pStoryInfo = {}                                           --服务器传过来的数据（消耗次数跟星级）
    self._pStoryCopys = {}                                          --本地数据
    self._pScrollViewDate = nil
    self._pCopyHasOpen = false                                      --关卡是否开启
    self._pFriendHelpInfo = nil

    self._pSelectedCopysDataInfo = nil
    self._pSelectedCopysFirstMapInfo = nil 
    self._pHasTextBattle = false                                    --是否是测试战斗。不正常进来。不能进行结算
    self._pChooseButton = nil
    self._pIconPic = nil
    ----------------------------------------------------------------------------
    self._nRemainBattleNum = 0                                      -- 关卡的剩余挑战次数
end

-- 创建函数
function StoryInfoDialog:create(args)
    local dialog = StoryInfoDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function StoryInfoDialog:dispose(args)
    -- 进入战斗的网络回复
    NetRespManager:getInstance():addEventListener(kNetCmd.kEntryBattle ,handler(self, self.entryBattleCopy))
    -- 购买战斗次数的网络回复
    NetRespManager:getInstance():addEventListener(kNetCmd.kBuyBattleResp ,handler(self, self.buyBattleNumResp21317))
    self._pStoryCopys = args[1]   --本地数据
    if table.getn(args) >= 2 then --服务器传过来的数据（消耗次数跟星级）
       self._pCopyHasOpen = true
       self._pStoryInfo = args[2]    
       
        if args[2].text then  --是否是测试战斗。不正常进来。不能进行结算
           self._pHasTextBattle = args[2].text
       end
    end
    ResPlistManager:getInstance():addSpriteFrames("StoryCopysTips.plist")
    local params = require("StoryCopysTipsParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pStoryName = params._pstorycopysname02                    --关卡的名字
    self._pStorydifficulty = params._pstorycopysdifficulty02        --关卡的难度
    self._pNeedLevel = params._pneedlevel02                         --关卡的需要的等级
    self._pSuggestBtPower = params._pbattlepower02                  --关卡的推荐战斗力
    self._pPhysicalValueProgressBar = params._pPloadingbar          --当前体力的进度条
    self._pPhysicalValueProgressText = params._ppowertext           --当前体力/剩余体力
    self._pResidueCount = params._pcurcount02                       --关卡的剩余次数
    self._pExpendPhysicalValueProgress= params._pusepower02         --关卡需要消耗的体力
    self._pEnterBattleButton = params._pSureButton                  --进入副本的button
    self._pScrollview = params._pscrollview                         --关卡可以得到的奖励ScrollView
    self._pLevelstarImage =  params._plevelstar                     --关卡的星级图片
    self._pChooseButton = params._pChooseButton                     --选择助战好友
    self._pIconPic = params._pIconPic                               --选择助战好友头像
    self._pIconPic:setVisible(false)
    -- 初始化dialog的基础组件
    self:disposeCSB()
    self:initUI()
    --加载ScrollView数据
    self:loadScrollViewDate()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return true   --可以向下传递事件
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
            self:onExitStoryInfoDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function StoryInfoDialog:setFriendHelpInfo(info)
    self._pFriendHelpInfo = info
    if self._pFriendHelpInfo == nil then
        self._pIconPic:setVisible(false)
        return
    end
    self._pIconPic:setVisible(true)
    self._pIconPic:loadTexture(
        kRoleIcons[self._pFriendHelpInfo.roleCareer],
        ccui.TextureResType.plistType)
end

--初始化界面
function StoryInfoDialog:initUI()
    local tStoryType = {"普通","精英","boss","精英boss"}
    local pColor = {cWhite,cBlue,cOrange,cYellow}
    self._pStoryName:setString(self._pStoryCopys.Name)                               --关卡名字
    self._pStorydifficulty:setString(tStoryType[self._pStoryCopys.StoryType])        -- 副本类型
    self._pStorydifficulty:setColor(pColor[self._pStoryCopys.StoryType])
    self._pNeedLevel:setString(self._pStoryCopys.RequiredLevel)                      --副本所需等级
    self._pSuggestBtPower:setString(self._pStoryCopys.RecommendedBP)                 --关卡的推荐战斗力
    
    self._pExpendPhysicalValueProgress:setString(self._pStoryCopys.PowerNum)         --关卡需要消耗的体力
    local pRoleCurLv = RolesManager:getInstance()._pMainRoleInfo.level
    if self._pStoryCopys.RequiredLevel > pRoleCurLv then
       self._pNeedLevel:setColor(cRed)
    end

    --角色体力
    local nCurValue = RolesManager:getInstance()._pMainRoleInfo.strength
    local nMaxValue = TableConstants.PowerNumLimit.Value
    self._pPhysicalValueProgressBar:setPercent((nCurValue/nMaxValue)* 100)
    self._pPhysicalValueProgressText:setString(nCurValue.."/"..nMaxValue)
    if nCurValue < self._pStoryCopys.PowerNum then 
       self._pExpendPhysicalValueProgress:setColor(cRed)
    end
    --self._pPhysicalValueProgressText:enableOutline(cc.c4b(0, 0, 0, 255), 2)

    local nStartNum = 0
    local nCurrentCount = 0             --关卡当前次数
    local nExtCount = 0                 --额外增加的次数
    local nAllCount = self._pStoryCopys.Times


    if self._pCopyHasOpen then --标示关卡已经开启   
        nCurrentCount = self._pStoryInfo.currentCount         --关卡当前次数
        nExtCount = self._pStoryInfo.extCount                 --额外增加的次数
        nStartNum = self._pStoryInfo.bestStar
     else --关卡未开启
        nCurrentCount = nAllCount
    end
    self._nRemainBattleNum = nCurrentCount+nExtCount
    self._pResidueCount:setString(self._nRemainBattleNum.."/"..(nExtCount+nAllCount))   --关卡的剩余次数


    --关卡的星级图片
    local pStartImage = {"StoryCopysTipsRes/star01.png","StoryCopysTipsRes/star02.png","StoryCopysTipsRes/star03.png","StoryCopysTipsRes/star04.png","StoryCopysTipsRes/star05.png"}
    if nStartNum == 0 then --关卡不开启
        self._pLevelstarImage:setVisible(false)
    else
        self._pLevelstarImage:setVisible(true)
        self._pLevelstarImage:loadTexture(pStartImage[nStartNum],ccui.TextureResType.plistType)
    end
     
    --进入副本的回调
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           self._pSelectedCopysDataInfo =  self._pStoryCopys
           self._pSelectedCopysFirstMapInfo = TableStoryCopysMaps[self._pSelectedCopysDataInfo.MapID]
           if self._pHasTextBattle then
              self:entryBattleCopy()
           else  
                if self._nRemainBattleNum < 1 then 
                    DialogManager:getInstance():showDialog("BuyStrengthDialog",{2,kCopy.kStory,self._pStoryCopys.ID})
                    return
                end
                MessageGameInstance:sendMessageEntryBattle21002(self._pStoryCopys.ID,0,self._pFriendHelpInfo~=nil and self._pFriendHelpInfo.roleId or 0) 
           end    
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pEnterBattleButton:addTouchEventListener(onTouchButton)
    --self._pEnterBattleButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pEnterBattleButton:setZoomScale(nButtonZoomScale)
    self._pEnterBattleButton:setPressedActionEnabled(true)
    if self._pCopyHasOpen == false then --标示关卡已经开启   
      darkNode(self._pEnterBattleButton:getVirtualRenderer():getSprite())
      self._pEnterBattleButton:setTouchEnabled(false)
    end
    
    self._pChooseButton:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           DialogManager:showDialog("SelectFriendDialog",{self})
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
end

function StoryInfoDialog:getScrollViewDate()
local pScrollViewDate  = {}
    local nDate =  self._pStoryCopys.MayDropItems

    for i=1,table.getn(nDate) do
        local pInfo = {id=nDate[i][1],baseType = nDate[i][2],value = 0}
        
        table.insert(pScrollViewDate,GetCompleteItemInfo(pInfo))
    end
    return pScrollViewDate
end

--进入战斗
function StoryInfoDialog:entryBattleCopy()
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
        args._nIdentity = 0
        args._tTowerCopyStepResultInfos = {}
        args._pPvpRoleInfo = nil
        args._tPvpRoleMountAngerSkills = {}
        args._tPvpRoleMountActvSkills = {}
        args._tPvpPasvSkills = {}
        args._tPvpPetRoleInfosInQueue = {}
        
        --关闭当前打开的Dialog
        self:getGameScene():closeDialogByNameWithNoAni("StoryCopyDialog")
        self:getGameScene():closeDialogByNameWithNoAni("StoryInfoDialog")
        
        --切换战斗场景
        LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
    end
end

-- 购买战斗次数的网络回调
function StoryInfoDialog:buyBattleNumResp21317(event)
    if self._pStoryCopys.ID == event.copyId and event.copyType == kCopy.kStory then 
        local nAllCount = self._pStoryCopys.Times
        self._pStoryInfo.currentCount  = self._pStoryInfo.currentCount + 1
        if self._pCopyHasOpen then --标示关卡已经开启   
            nCurrentCount = self._pStoryInfo.currentCount         --关卡当前次数
            nExtCount = self._pStoryInfo.extCount                 --额外增加的次数
            nStartNum = self._pStoryInfo.bestStar
        else --关卡未开启
            nCurrentCount = nAllCount
        end
        self._nRemainBattleNum = nCurrentCount+nExtCount 
        self._pResidueCount:setString(self._nRemainBattleNum.."/"..(nExtCount+nAllCount))   --关卡的剩余次数
    end 
end

--初始化ScrollView界面数据
function StoryInfoDialog:loadScrollViewDate()
    self._pScrollViewDate =  self:getScrollViewDate()

    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101                                   --每个cell的宽度和高度
    local nStartx = 0
    local nNum = #self._pScrollViewDate
    local nViewWidth  = self._pScrollview:getContentSize().width
    local nViewHeight  = self._pScrollview:getContentSize().height
    local pScrInnerWidth = (nViewWidth >(nLeftAndReightDis+nSize)*nNum) and nViewWidth or (nLeftAndReightDis+nSize)*nNum
    self._pScrollview:setInnerContainerSize(cc.size(pScrInnerWidth,nViewHeight))
    if pScrInnerWidth == nViewWidth then
        self._pScrollview:setBounceEnabled(false)
        nStartx = (nViewWidth-(nLeftAndReightDis+nSize)*(nNum-1))/2-nSize/2
    end

    for i=1,nNum do
        local pCell =  require("BagItemCell"):create()
        local nX = (i-1)*(nSize+nLeftAndReightDis)+nStartx
        local nY = (nViewHeight-nSize)/2
        pCell:setPosition(nX,nY)
        pCell:setItemInfo(self._pScrollViewDate[i])
        pCell:setTouchEnabled(false)
        pCell:setNameLabelVisible(false)
        self._pScrollview:addChild(pCell)

        local pName = cc.Label:createWithTTF("", strCommonFontName, 18)
        pName:setLineHeight(20)
        pName:setAdditionalKerning(-2)
        pName:setTextColor(cc.c4b(255, 255, 255, 255))
        pName:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        pName:setPosition(cc.p(nX+nSize/2,nY+nSize))
        --pName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        --pName:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        pName:setString(self._pScrollViewDate[i].templeteInfo.Name)
        local pQuality = self._pScrollViewDate[i].dataInfo.Quality
        if pQuality and pQuality >0 then
            pName:setColor(kQualityFontColor3b[pQuality])
        end
        self._pScrollview:addChild(pName)
    end
end

-- 退出函数
function StoryInfoDialog:onExitStoryInfoDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("StoryCopysTips.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function StoryInfoDialog:update(dt)
    return
end

-- 显示结束时的回调
function StoryInfoDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function StoryInfoDialog:doWhenCloseOver()
    return
end

return StoryInfoDialog
