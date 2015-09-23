--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MidNightCopysDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/12
-- descrip:   午夜惊魂界面
--===================================================
local MidNightCopysDialog = class("MidNightCopysDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function MidNightCopysDialog:ctor()
    self._strName = "MidNightCopysDialog"           -- 层名称
    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pTextTitle = nil                          --问题的title
    self._pTextDesc = nil                           --问题的内容
    self._pLoadingBar = nil                         --下面的进度条
    self._pLoadingHead = nil                        --蜡烛的头
    self._pGhostNode01 = nil                        --黑无常3D模型挂载点
    self._pGhostNode02 = nil                        --白无常3D模型挂载点
    self._pListView = nil                           --下面的滑动框

    self._pCurTime = 0                              --bar当前的时间
    self._pTotalTime = 0                            --bar总时间
    self._bIsRunBar = false                         --进度条倒计时是否开启
    self._fButtonCallBack = nil                     --默认选状态的回调函数

    self._pSelectMidNightState = nil                --设置选中状态 1.免死符 2,进入答题 3直接进入战斗

    self._tQuestionInfo = {}                        --当前的5道题库
    self._pCurQuestionNum = 0                       --当前答题的数目
    self._pErrorQuestionNum = 0                     --打错的题数目
    self._pSelectedCopysDataInfo = nil
    self._pSelectedCopysFirstMapInfo = nil

end

-- 创建函数
function MidNightCopysDialog:create()
    local dialog = MidNightCopysDialog.new()
    dialog:dispose()
    return dialog
end

-- 处理函数
function MidNightCopysDialog:dispose()
    NetRespManager:getInstance():addEventListener(kNetCmd.kEntryBattle ,handler(self, self.entryBattleCopy))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUseUnDeadResp ,handler(self, self.updateDateResp))
    NetRespManager:getInstance():addEventListener(kNetCmd.kAnswerRightResp ,handler(self, self.updateDateResp))
    --断线从链接更新
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected ,handler(self, self.respNetReconnected))    
    ResPlistManager:getInstance():addSpriteFrames("NightmareUI.plist")
    ResPlistManager:getInstance():addSpriteFrames("NightmareCandle.plist")
    ResPlistManager:getInstance():addSpriteFrames("NightEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("NightRightEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("NightWrongEffect.plist")
    
    
    -- 强制设置所有角色positionZ到最小值
    MonstersManager:getInstance():setForceMinPositionZ(true, -10000)
    RolesManager:getInstance():setForceMinPositionZ(true, -10000)
    PetsManager:getInstance():setForceMinPositionZ(true, -10000)
    SkillsManager:getInstance():setForceMinPositionZ(true, -10000)
    
    MonstersManager:getInstance():deleteCurWaveMonsters()  -- 删除当前波的所有怪
    
    local params = require("NightmareParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pTextTitle =  params._pTitle              --问题的title
    self._pTextDesc =  params._pQuestion            --问题的内容
    self._pLoadingBar = params._pLoadingBar         --下面的进度条
    self._pGhostNode01 =params._pGhostNode01        --黑无 常3D模型挂载点
    self._pGhostNode02 =params._pGhostNode02        --白无常3D模型挂载点
    self._pListView = params._pListView             --下面的滑动框
    self._fButtonCallBack = { self.enterUnDeadState,self.enterAnswerState,self.enterMidNightBattleCopy}
    self._pListView:setBounceEnabled(false)
    -- 初始化dialog的基础组件
    self:disposeCSB()
    --初始化午夜惊魂说明信息
    self:initUiDecInfo()
    --初始化下面的listView信息
    self:initUiListViewInfo()
    --初始化战斗和答题数据
    self:initEnterMidNightCopysDate()
    --初始化界面的3d黑白无常模型
    self:init3DModelView()
    
    AudioManager:getInstance():playMusic("GhostRoar") -- 背景音乐
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
            self:onExitMidNightCopysDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end

function MidNightCopysDialog:updateDateResp(event)
    --关闭当前打开的Dialog
    BattleManager:getInstance()._bIsTransforingFromEndBattle = true
    self:getParent():closeDialogByNameWithNoAni("MidNightCopysDialog")
    LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
end

--断线重连的更新
function MidNightCopysDialog:respNetReconnected(event)
    if self._pErrorQuestionNum >= 3 then --错误的题超过3道了。就需要进入副本了
        self:enterMidNightBattleCopy()
    end  
    if (self._pCurQuestionNum-self._pErrorQuestionNum) >= 3  then --标示已经答对了3到题了。标示胜利了。
        BattleManager:getInstance()._bIsTransforingFromEndBattle = true
        self:getParent():closeDialogByNameWithNoAni("MidNightCopysDialog")
        LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
    end
end

--初始化午夜惊魂开始的说明信息
function MidNightCopysDialog:initUiDecInfo()

    local pTextTitle = "规则说明"
    local pTextDec = "这个是午夜惊魂副本。。。。"
    self._pTextTitle:setString(pTextTitle)              --问题的title
    self._pTextDesc:setString(pTextDec)           --问题的内容
    self._pLoadingBar:setPercent(100)
    self._pLoadingHead = cc.CSLoader:createNode("NightmareCandle.csb")
    self._pLoadingHead:setAnchorPoint(0,0.5)
    self._pLoadingHead:setPosition(self._pLoadingBar:getContentSize().width-10,self._pLoadingBar:getContentSize().height/2)
    self._pLoadingBar:addChild(self._pLoadingHead)
    
    self._pTotalTime = TableConstants.MidNightTimeLimit.Value
    self._bIsRunBar = true

end

--初始化下面的listView信息
function MidNightCopysDialog:initUiListViewInfo()
    local pTextDec = {"甲：使用“免死符”逃过阎王的邀请", "乙：进入答题环节","丙：直接挑战阎王"}

    local onTouchButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            self._bIsRunBar = false  --只要点击了下面的按钮 倒计时停止
            self._fButtonCallBack[nTag](self)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pListView:removeAllChildren()
    for i=1,table.getn(pTextDec) do
        local pItem = nil
        if i == 1 then
            local nNum = BagCommonManager:getInstance():getItemNumById(TableConstants.UnDeadID.Value)
            pItem = self:createListViewItem(pTextDec[i],true,nNum)
        else
            pItem = self:createListViewItem(pTextDec[i])
        end
        pItem:addTouchEventListener(onTouchButton)
        pItem:setTag(i)
        self._pListView:pushBackCustomItem(pItem)
    end

end


--初始化午夜惊魂的3d模型
function MidNightCopysDialog:init3DModelView()
    local pRoleLeftInfo =  TableTempleteMonster[19]
    local pRoleRightInfo = TableTempleteMonster[43]

    --黑无常
    local pRoleLeft = cc.Sprite3D:create(pRoleLeftInfo.Model..".c3b")
    pRoleLeft:setPosition(cc.p(0,-pRoleLeft:getBoundingBox().height/2))
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pRoleLeftInfo.Model)
    pRoleLeft:setTexture(pRoleLeftInfo.Texture..".pvr.ccz")
    self._pGhostNode01:addChild(pRoleLeft)
    
    local pRoleAnimation1 = cc.Animation3D:create(pRoleLeftInfo.Model..".c3b")
    local pRunActAnimate1 = cc.Animate3D:createWithFrames(pRoleAnimation1, pRoleLeftInfo.StandActFrameRegion[1],pRoleLeftInfo.StandActFrameRegion[2])
    pRoleLeft:runAction(cc.RepeatForever:create(pRunActAnimate1))
    
    
    --白无常
    local pRoleRight = cc.Sprite3D:create(pRoleRightInfo.Model..".c3b")
    pRoleRight:setPosition(cc.p(0,-pRoleLeft:getBoundingBox().height/2))
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pRoleRightInfo.Model)
    pRoleRight:setTexture(pRoleRightInfo.Texture..".pvr.ccz")         
    self._pGhostNode02:addChild(pRoleRight)
    
    local pRoleAnimation2 = cc.Animation3D:create(pRoleLeftInfo.Model..".c3b")
    local pRunActAnimate2 = cc.Animate3D:createWithFrames(pRoleAnimation2, pRoleRightInfo.StandActFrameRegion[1],pRoleRightInfo.StandActFrameRegion[2])
    pRoleRight:runAction(cc.RepeatForever:create(pRunActAnimate2))


end
--随机午夜惊魂要进入的副本信息
function MidNightCopysDialog:initEnterMidNightCopysDate()

    --答题的详细信息
    local pSize = table.getn(TableQuestions)
    for i=1,5 do
        local nRandom = getRandomNumBetween(1,pSize)
        table.insert(self._tQuestionInfo,TableQuestions[nRandom])
    end

      --进入午夜惊魂副本的信息
      local pCopyId = self:getMidNightBattleId()
      release_print("副本id为"..pCopyId)
      self._pSelectedCopysDataInfo = TableMidNightCopys[pCopyId-700]
      self._pSelectedCopysFirstMapInfo =  TableMidNightCopysMaps[self._pSelectedCopysDataInfo.MapID]
end

--根据人物等级随机出午夜惊魂要打的副本Id
function MidNightCopysDialog:getMidNightBattleId()

    local nRoleLevel = RolesManager:getInstance()._pMainRoleInfo.level
    local pMidnightCopysIDInfo = nil
    for i=1,table.getn(TableMidNightChapter) do
        if nRoleLevel <= TableMidNightChapter[i].Level then
            pMidnightCopysIDInfo =  TableMidNightChapter[i].CopysID
            break
        end

    end

    local pRundomNum = 0
    for i=1,table.getn(pMidnightCopysIDInfo) do
        pRundomNum = pRundomNum +pMidnightCopysIDInfo[i][2]
    end
    local pRundom = getRandomNumBetween(1,pRundomNum)
    local pAccount = 0
    for i=1,table.getn(pMidnightCopysIDInfo) do
        pAccount = pAccount + pMidnightCopysIDInfo[i][2]
        if pRundom <= pAccount then
            return pMidnightCopysIDInfo[i][1]
        end
    end
    return 0

end

--创建午夜惊魂的listViewitem上的button
function MidNightCopysDialog:createButtonItem(pText)
    local pIconBtn = ccui.Button:create("NightmareUIRes/jlxt6.png","NightmareUIRes/tytck1.png",nil,ccui.TextureResType.plistType)
    pIconBtn:setCapInsets(cc.rect(0,0,0,0))
    pIconBtn:setContentSize(cc.size(414, 76))
    pIconBtn:setScale9Enabled(true)
    if pText ~= nil then
        pIconBtn:setTitleText(pText)
        pIconBtn:setTitleFontSize(15)
        pIconBtn:setTitleColor(cc.c3b(0,0,0))
        pIconBtn:setTitleFontName(strCommonFontName)
    end
    return pIconBtn
end

--创建午夜惊魂listView上面的字体
function MidNightCopysDialog:createLableItem(pText)
    local pTextDec = ccui.Text:create(pText, strCommonFontName, 18)
    pTextDec:setTextColor(cc.c4b(255, 255, 255, 255))
    pTextDec:setAnchorPoint(0,0.5)
    return pTextDec
end


--创建午夜惊魂免死符button(常规的字体，是否是免战item，免战的次数)
function MidNightCopysDialog:createListViewItem(pText,bIsUnDead,pUnDeadNum)
    local pItem = self:createButtonItem()
    local pPosY =pItem:getContentSize().height/2
    --前面的常规字体
    local pText = self:createLableItem(pText)
    pText:setPosition(cc.p(30,pPosY))
    pItem:addChild(pText)

    if bIsUnDead == true then
        --免战的图片
        local pUnDeadImage = ccui.ImageView:create("NightmareUIRes/icon_998.png",ccui.TextureResType.plistType)
        pUnDeadImage:setPosition(cc.p(360,pPosY))
        pUnDeadImage:setScale(0.6)
        pItem:addChild(pUnDeadImage)

        --最后的免战数目
        local pUnDeadNumText = self:createLableItem(pUnDeadNum)
        pUnDeadNumText:setPosition(cc.p(360,pPosY/2))
        pItem:addChild(pUnDeadNumText)
    end

    return pItem
end

--答题进入下一题
function MidNightCopysDialog:nextQuestion()
    local pQuesSize = table.getn(self._tQuestionInfo)

    if self._pErrorQuestionNum >= 3 then --错误的题超过3道了。就需要进入副本了
        self:setRoleEnterByIsRight(false)
        return
    end
    if (self._pCurQuestionNum-self._pErrorQuestionNum) >= 3  then --标示已经答对了3到题了。标示胜利了。
        self:setRoleEnterByIsRight(true)
        return
    end

    self._pCurQuestionNum = self._pCurQuestionNum +1                           --如果没有答对或者打错3道，答题数目+1
    local pQuesInfo = self._tQuestionInfo[self._pCurQuestionNum]

    self._pTextTitle:setString("第"..self._pCurQuestionNum.."题")               --问题的title
    self._pTextDesc:setString(pQuesInfo.Question)                             --问题的内容

    self._pListView:removeAllChildren()


    local onTouchButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            self._bIsRunBar = false
            self:setUiTouchEnable(true)--设置屏幕不可点击
            if nTag == pQuesInfo.CorrectOption then
                --答对了
                --播放答对了的特效
                self:playRightAction()

            else
                --打错了
                self._pErrorQuestionNum = self._pErrorQuestionNum + 1
                self:playErrorAction()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    for k,v in pairs(pQuesInfo.Option) do
        local pItem = self:createListViewItem(v)
        pItem:addTouchEventListener(onTouchButton)
        pItem:setTag(k)
        self._pListView:pushBackCustomItem(pItem)
    end

    self._pCurTime =0                                --bar当前的时间
    self._pTotalTime = TableConstants.QuestionsTimeLimit.Value  --bar总时间
    self._bIsRunBar = true                           --进度条倒计时是否开启

end

--播放回答正确的的动画
function MidNightCopysDialog:playRightAction()

    local pTimeCdNode = nil
    local function onFrameEvent(frame,tTable)
        if nil == frame then
            return
        end

        local str = frame:getEvent()
        if str == "playOver" then
            pTimeCdNode:removeFromParent(true) 
            self:setUiTouchEnable(false)
            self:nextQuestion()
        end

    end

    local pSize = mmo.VisibleRect:getVisibleSize()
    pTimeCdNode = cc.CSLoader:createNode("NightRightEffect.csb")
    pTimeCdNode:setPosition(pSize.width/2,pSize.height/2)
    self:addChild(pTimeCdNode)
    local pTimeCdAct = cc.CSLoader:createTimeline("NightRightEffect.csb")
    pTimeCdAct:setFrameEventCallFunc(onFrameEvent)
    pTimeCdAct:gotoFrameAndPlay(0,pTimeCdAct:getDuration(), false)
    pTimeCdNode:runAction(pTimeCdAct)
    
end

--播放回答错误的动画
function MidNightCopysDialog:playErrorAction()

    local pTimeCdNode = nil
    local function onFrameEvent(frame,tTable)
        if nil == frame then
            return
        end

        local str = frame:getEvent()
        if str == "playOver" then
            pTimeCdNode:removeFromParent(true) 
            self:setUiTouchEnable(false)
            self:nextQuestion()
        end

    end

    local pSize = mmo.VisibleRect:getVisibleSize()
    pTimeCdNode = cc.CSLoader:createNode("NightWrongEffect.csb")
    pTimeCdNode:setPosition(pSize.width/2,pSize.height/2)
    self:addChild(pTimeCdNode)
    local pTimeCdAct = cc.CSLoader:createTimeline("NightWrongEffect.csb")
    pTimeCdAct:setFrameEventCallFunc(onFrameEvent)
    pTimeCdAct:gotoFrameAndPlay(0,pTimeCdAct:getDuration(), false)
    pTimeCdNode:runAction(pTimeCdAct)
end

--根据bool值来弹出用户是要返回主城还是进入副本
function MidNightCopysDialog:setRoleEnterByIsRight(bBool)
    local pSize = mmo.VisibleRect:getVisibleSize()
    self:setUiTouchEnable(true)
    local pTexture = ""
    if bBool == true then --答题胜利
        pTexture = "NightmareUIRes/good.png"
    else
        pTexture = "NightmareUIRes/bad.png"
    end

    local pShowImage = ccui.ImageView:create(pTexture,ccui.TextureResType.plistType)
    pShowImage:setPosition(cc.p(pSize.width/2,pSize.height/2))
    pShowImage:setScale(0)
    self:addChild(pShowImage)

    local showOver = function()

        self:setUiTouchEnable(false)
        if bBool == true then --答题胜利
            NightSystemCGMessage:sendMessageAnswerRight21802()
        else
            self:enterMidNightBattleCopy()
        end


    end

    local action = cc.Sequence:create( cc.EaseSineInOut:create(cc.ScaleTo:create(1,1,1)),cc.DelayTime:create(3),cc.CallFunc:create(showOver))
    pShowImage:runAction(action)

end


--倒计时的acticon
function MidNightCopysDialog:playTimeCdAction(func)

    local function onFrameEvent(frame,tTable)
        if nil == frame then
            return
        end

        local str = frame:getEvent()
        if str == "playOver" then
            self:setUiTouchEnable(false)
            func()
        end

    end
    self:setUiTouchEnable(true)
    local pSize = mmo.VisibleRect:getVisibleSize()
    local pTimeCdNode = cc.CSLoader:createNode("NightEffect.csb")
    pTimeCdNode:setPosition(pSize.width/2,pSize.height/2)
    self:addChild(pTimeCdNode)
    local pTimeCdAct = cc.CSLoader:createTimeline("NightEffect.csb")
    pTimeCdAct:setFrameEventCallFunc(onFrameEvent)
    pTimeCdAct:gotoFrameAndPlay(0,pTimeCdAct:getDuration(), false)
    pTimeCdNode:runAction(pTimeCdAct)

end



--使用免死符
function MidNightCopysDialog:enterUnDeadState()
    local nNum = BagCommonManager:getInstance():getItemNumById(TableConstants.UnDeadID.Value)
    if nNum <=0 then 
        NoticeManager:getInstance():showSystemMessage("免死符不足，暂时无法逃过此劫")
        self._bIsRunBar = true
        return 
    end
    
    print("1")
    self._pSelectMidNightState = 1
    NightSystemCGMessage:sendMessageUseUnDead21800()
end

--进入答题环节
function MidNightCopysDialog:enterAnswerState()
    print("2")
    self._pSelectMidNightState = 2
    local startAnswerState = function()
        self:nextQuestion()
    end
    self:playTimeCdAction(startAnswerState) --播放倒计时动画
end

--直接进入副本
function MidNightCopysDialog:enterMidNightBattleCopy()
    print("3")
    self._pSelectMidNightState = 3
    if self._pSelectedCopysDataInfo == nil or self._pSelectedCopysFirstMapInfo == nil then
        return
    end

    MessageGameInstance:sendMessageEntryBattle21002(self._pSelectedCopysDataInfo.ID,0)
end

--进入战斗
function MidNightCopysDialog:entryBattleCopy()
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

        --切换战斗场景
        BattleManager:getInstance()._bIsTransforingFromEndBattle = true
        self:getParent():closeDialogByNameWithNoAni("MidNightCopysDialog")
        LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
    end
end


-- 退出函数
function MidNightCopysDialog:onExitMidNightCopysDialog()
    self:onExitDialog()
     
    MonstersManager:getInstance():setForceMinPositionZ(false)
    RolesManager:getInstance():setForceMinPositionZ(false)
    PetsManager:getInstance():setForceMinPositionZ(false)
    SkillsManager:getInstance():setForceMinPositionZ(false)
    
    ResPlistManager:getInstance():removeSpriteFrames("NightmareUI.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NightmareCandle.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NightEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NightRightEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NightWrongEffect.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)

end

-- 循环更新
function MidNightCopysDialog:update(dt)
    if self._bIsRunBar then
        self._pCurTime = self._pCurTime + dt
        local pPercent = 1-self._pCurTime/self._pTotalTime
        self._pLoadingBar:setPercent(pPercent*100)
        self._pLoadingHead:setPosition(self._pLoadingBar:getContentSize().width*pPercent-10,self._pLoadingBar:getContentSize().height/2)
        if self._pCurTime >= self._pTotalTime then --时间到
            print("时间到")
            self._bIsRunBar = false
            if self._pSelectMidNightState == nil then --当前没有选中，时间到后默认进入答题界面
                self:enterAnswerState()
            else
                self._pErrorQuestionNum = self._pErrorQuestionNum + 1
                self:playErrorAction()
            end



        end
    end
    return
end

--设置点基层是否可以点击

function MidNightCopysDialog:setUiTouchEnable(bBool)
    self:setTouchEnableInDialog(bBool)
end

-- 显示结束时的回调
function MidNightCopysDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function MidNightCopysDialog:doWhenCloseOver()
    return
end

return MidNightCopysDialog
