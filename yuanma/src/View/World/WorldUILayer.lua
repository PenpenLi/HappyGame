--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  WorldUILayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   世界UI层
--===================================================
local WorldUILayer = class("WorldUILayer",function()
    return require("Layer"):create()
end)

local RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}

-- 构造函数
function WorldUILayer:ctor()
    self._strName = "WorldUILayer"        -- 层名称
    self._pTouchListener = nil            -- 触摸监听器
    self._pStick = nil                    -- 摇杆
    self._pCursor = nil                   -- 触摸手标
    self._pWorldUIPanelCCS = nil -- 主场景UI相关CCS 
    self._pLayerNode = nil
    -- 角色信息相关的控件 
    self._pPlayerNameText = nil -- 玩家等级和名字 
    self._pPlayerLVText = nil -- 玩家等级和名字 
    self._pFightCapacityText = nil -- 玩家的战斗力 
    self._pPhysicalValueText = nil -- 玩家的体力值 
    self._pPhysicalValueProgressBar = nil -- 玩家的体力值进度条 
    self._pExperienceValueText = nil -- 玩家的经验值 
    self._pExperieceProgressBarBg = nil -- 玩家经验的进度条 
    self._pExperieceProgressBar = nil -- 玩家经验的进度条 
    self._pGoldCoinValueText = nil -- 玩家的金币数量 
    self._pDiamondValueText = nil -- 玩家的钻石数量 
    self._pVipLevelText = nil -- 玩家的vip等级 
    -- cocos studio 按钮相关的控件 
    self._pPlayerIconButton = nil -- 玩家头像点击按钮 
    self._pBuyPhysicalButton = nil -- 玩家购买体力按钮 
    self._pBuyGoldCoinButton = nil -- 玩家购买金币按钮 
    self._pBuyDiamondButton = nil -- 玩家购买钻石按钮 
    self._pBottomRightCornnerButton = nil -- 右下角的功能按钮 
    self._pTopRightCornnerButton = nil -- 右上角的功能按钮 
    self._pSetButton = nil          --设置按钮
    -- cocos studio 节点相关的控件 
    self._pHeadNode = nil -- 玩家的头像节点 
    self._pBottomRightCornerNode = nil -- 右下角功能按钮节点 
    self._pTopRightCornnerNode = nil -- 右上角功能按钮节点 
    self._pExperieceProgNode = nil -- 经验条节点 
    
    self._pArrowLeft = nil
    self._pArrowUp = nil
    self._nRightBottomState = 2
    self._pRightArrowLeft = nil
    self._nRightUpState = 2
    -- cocos studio 功能按钮对应的容器 
    self._pWorldMainFuncMenu = nil

    self._pTalkFrame = nil                      -- 剧情对话背景框
    self._tTalkHeaders = {}                     -- 剧情对话头像，按照当前对话Contents数据中的角色顺序存放
    self._tTalkNames = {}                       -- 剧情对话头像的名称
    self._pTalkArrow = nil                      -- 剧情对话箭头
    self._pTalkArrowPlot = nil                  -- 剧情对话箭头底座
    self._pTalkTextArea = nil                   -- 剧情对话文字区域
    self._bTalkTouchStart = false               -- 剧情对话触摸是否开始

    self.leveldd = RolesManager:getInstance()._pMainRoleInfo.level
    --需要播放特效的功能开启集合
    self._tMainFuncOpenArray = {}
    
    self.levelNewbie = RolesManager:getInstance()._pMainRoleInfo.level
    --需要播放到二阶段新手引导集合
    self._tNewbieOpenArray = {}
    --聊天
    self._pChatPanelCCS = nil
    self._pChatOutsideBg =  nil                 -- 聊天出来的信息框
    self._pChatButton = nil                     -- 聊天button
    self._pChatNotice = nil                     -- 聊天的提示
    self._tNewMessage = {}                      -- 聊天的提示集合
    self._tOutSideIsVis = false                 -- 聊天的提示开关
    self._pChatElementText = nil

    self._pNewEquipPanel = nil                  -- 新获得装备面板
    self._pFastTaskPanel = nil                  -- 快速任务

    self._pNewFuncOpenCCs = nil                 --新功能开启
    self._nRoleLevel = 0
    
    self._pLvUpEffectAniNode = nil              --人物升级特效

    self._pStrongerBtn = nil                   -- 我要变强
    self._pActivityBtn = nil                   -- 活动入口
end

-- 创建函数
function WorldUILayer:create()
    local layer = WorldUILayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function WorldUILayer:dispose()
    
    ResPlistManager:getInstance():addSpriteFrames("MainUiPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("ChatOutside.plist")
    ResPlistManager:getInstance():addSpriteFrames("NovicegGuideFunction.plist")
    ResPlistManager:getInstance():addSpriteFrames("NewFuncOp.plist")
    ResPlistManager:getInstance():addSpriteFrames("LvUpEffect.plist")
    
    --注册感兴趣事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFisance ,handler(self, self.updateRoleInfoWidgets))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateRoleInfo ,handler(self, self.updateRoleInfoWidgets))
    NetRespManager:getInstance():addEventListener(kNetCmd.kHomeAddBuff ,handler(self, self.homeAddBuffInform))
    NetRespManager:getInstance():addEventListener(kNetCmd.kHomeRemoveBuff ,handler(self, self.homeRemoveBuffInform))
    NetRespManager:getInstance():addEventListener(kNetCmd.kChatOutSide,handler(self, self.homeChatOutSide))
    NetRespManager:getInstance():addEventListener(kNetCmd.kSetStickLocked,handler(self, self.handleStickLocked))
    NetRespManager:getInstance():addEventListener(kNetCmd.kWorldLayerTouch,handler(self, self.handleTouchable))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNewEquipShow,handler(self, self.handleNewEquipShow))
    NetRespManager:getInstance():addEventListener(kNetCmd.kDisPlayNotice ,handler(self, self.marqueeEvent)) --跑马灯公告通知
    NetRespManager:getInstance():addEventListener(kNetCmd.kNewbieOver,handler(self, self.NewbieOverEvent)) --新手结束
    NetRespManager:getInstance():addEventListener(kNetCmd.kFuncWarning,handler(self, self.handleMsgWarning)) --新手结束
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateBagItemList,handler(self, self.handleUpdateBagItemList))
    NetRespManager:getInstance():addEventListener(kNetCmd.kGainTaskAwardResp, handler(self,self.handleMsgGainTaskAwardResp))--领取任务（打开物品信息界面）
    
    -- 初始化ui
    self:initUI()
    
    -- 初始化剧情对话UI
    self:initTalksUI()
   
    -- 初始化触摸
    self:initTouches()
    
    --家园buff
    self:createHomeBuffInfo()   
    --聊天的黑名单查询
    self:initChatInfo()

    --家园的新功能开启
    self:initNewFuncOpen()
    
    --是否从失败界面的我要变强按钮的引导
    self:initFaildGruid()
    
    TasksManager:getInstance():createTaskWithTaskInfos(TasksManager:getInstance()._pTaskInfos)
    
    -- 检查是否有可升级技能
    SkillsManager:getInstance():checkSkills()
    
    -- 可合成宝石检查
    local bCanGemSyntheis = BagCommonManager:getInstance():isCanGemSynthesis()
    -- 可镶嵌装备检查
    BagCommonManager:getInstance()._tCanInlayEquips = BagCommonManager:getInstance():getCanInlayWearEquipIndexArry()
    -- 可强化装备
    BagCommonManager:getInstance()._tCanIntensifyEquips = BagCommonManager:getInstance():getCanIntensifyWearEquipIndexArry()
    if table.getn(BagCommonManager:getInstance()._tCanInlayEquips) > 0 or table.getn(BagCommonManager:getInstance()._tCanIntensifyEquips) > 0  or bCanGemSyntheis == true then
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "装备按钮" , value = true})
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "背包按钮" , value = true})
    end
    -- 检查是否可以领取首充奖励
    if ActivityManager:getInstance():isShowFirstChargeWarn() == true then 
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "首充按钮" , value = true})
    end
    

    CDManager:getInstance():insertCD({cdType.kNpcWaiting,TableConstants.NpcTalkDelay.Value})  
    self:handleMsgWarning({})
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitWorldUILayer()
        end
        if event == "enter" then
            NewbieManager:getInstance():getMainFuncLevel()
            -- 第一次登陆默认不显示 （新功能开启 二阶段引导）
            if isFirstLoginMain == true then
                NewbieManager:getInstance():setMainFuncLevel(self.leveldd)
            end
            
            -- 二阶段新手引导
            if self.levelNewbie ~= NewbieManager:getInstance()._nCurOpenLevel and NewbieManager:getInstance()._bSkipGuide == false then
                for i=1,table.getn(TableNewFunction) do
                    if TableNewFunction[i].Level > NewbieManager:getInstance()._nCurOpenLevel and
                        TableNewFunction[i].Level <= self.levelNewbie and
                        TableNewFunction[i].GuideId ~= nil then
                        table.insert(self._tNewbieOpenArray,TableNewFunction[i])
                    end
                end
            end
            
            -- 二阶段新手引导
            if NewbieManager:getInstance()._bSkipGuide == false then
                if table.getn(self._tNewbieOpenArray) > 0 then
                    self:showNewbieByRoleLevel()
                end
            end

            -- 弹活动幻灯片公告
            if isFirstLoginMain == true and NewbieManager:getInstance()._bSkipGuide == true then 
                -- 弹活动幻灯片公告
                --if RolesManager._pMainRoleInfo.level >= 10 then 
                --    DialogManager:getInstance():showDialog("SlideDialog")
                --end
                DialogManager:getInstance():showDialog("SlideDialog")
                isFirstLoginMain = false
            end

            -- 读取新手引导起始
            if NewbieManager:getInstance()._bSkipGuide == false then
                if isFirstLoginMain == true then
                    local temp = NewbieManager:getInstance():loadMainID()
                    if temp ~= nil and temp ~= "" and TableNewbie[temp].IsHomeScene == 1 then
                        -- 直接登录
                        if RolesManager._pMainRoleInfo.level < 10 then
                            if temp == "Guide_2_1" then
                                NewbieManager:getInstance():showNewbieByID("Guide_2_1")
                            elseif temp == "Guide_2_10" and TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.state == 2 then
                                NewbieManager:getInstance():showNewbieByID("Guide_3_1")
                            elseif temp == "Guide_3_14" and TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.state == 2 then
                                NewbieManager:getInstance():showNewbieByID("Guide_4_22")
                            elseif temp == "Guide_4_31" and TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.state == 2 then
                                NewbieManager:getInstance():showNewbieByID("Guide_5_1")
                            elseif temp == "Guide_5_17" and TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.state == 2 then
                                NewbieManager:getInstance():showNewbieByID("Guide_6_52")
                            elseif temp == "Guide_6_1" and TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.state == 2 then
                                NewbieManager:getInstance():showNewbieByID("Guide_6_52")
                            elseif temp == "Guide_7_1" and TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.state == 2 then
                                NewbieManager:getInstance():showNewbieByID("Guide_7_13")     
                            else
                                NewbieManager:getInstance():showNewbieByID(temp)
                            end
                        end
                    end
                    -- 弹活动幻灯片公告
                    if RolesManager._pMainRoleInfo.level >= 10  then 
                        DialogManager:getInstance():showDialog("SlideDialog")
                    end
                    isFirstLoginMain = false
                else
                    if TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId < 10007 then
                        local index = TasksManager:getInstance()._pMainTaskInfo.taskId - 10000
                        if RolesManager._pMainRoleInfo.level < 10 then
                            NewbieManager:getInstance():showNewbieByID("Guide_"..(index+1).."_1")
                        end
                    end
                end
                isFirstLoginMain = false
                
                NetRespManager:getInstance():dispatchEvent(kNetCmd.kNewEquip,{})
            end
            
            -- 主线任务提示
            
            if TasksManager:getInstance()._pMainTaskInfo == nil then
                TaskCGMessage:sendMessageQueryTasks21700()
            else
                self._pFastTaskPanel:updateMainTask()
            end
            
            -- 更新播放等级
            NewbieManager:getInstance():setMainFuncLevel(self.leveldd)
        end
        
        --NoticeManager:showNewEquip()
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function WorldUILayer:onExitWorldUILayer()
    self:onExitLayer()
    
    ResPlistManager:getInstance():removeSpriteFrames("MainUiPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("ChatOutside.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NovicegGuideFunction.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NewFuncOp.plist")
    ResPlistManager:getInstance():removeSpriteFrames("LvUpEffect.plist")

    NetRespManager:getInstance():removeEventListenersByHost(self)

end

-- 循环更新
function WorldUILayer:update(dt)
    -- 摇杆proc
    self:procStick(dt)
    if  self._pHomeBuffIconsNode then
    	 self._pHomeBuffIconsNode:update(dt)
    end
    self:updateChatNotice()
    
end

-- 显示结束时的回调
function WorldUILayer:doWhenShowOver()
    -- 刚进入家园，每次都要检测邮件是否有new
    local hasNewEmail = EmailManager:getInstance():hasNewEmail()
    self:showNewEmail(hasNewEmail)

    return
end

-- 关闭结束时的回调
function WorldUILayer:doWhenCloseOver()
    return
end

function WorldUILayer:initUI()
    -- 创建摇杆
    self._pStick = mmo.Stick:createWithFrameName("com_003.png","com_002.png")
    self._pStick:setStartPosition(cc.p(self._pStick:getFrameSize().width/2 + 20, self._pStick:getFrameSize().height/2 + 20))
    self._pStick:setLocked(OptionManager:getInstance()._bStickLock)  -- 默认为不锁定
    self:addChild(self._pStick)
    
    -- 创建手标    
    self._pCursor = cc.Sprite:createWithSpriteFrameName("ccsComRes/wanzifu.png")
    self:addChild(self._pCursor,kZorder.kMax)
    self._pCursor:setVisible(false)

    self._pLayerNode = cc.Node:create()
    self._pLayerNode:setPosition(0,0)
    self:addChild(self._pLayerNode)
    
    -- 加载组件 
    local params = require("MainUiPanelParams"):create() 
    self._pWorldUIPanelCCS = params._pCCS 
    self._pPlayerLVText = params._pLvText 
    --self._pPlayerLVText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pPlayerLVText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pPlayerNameText = params._pNameText 
    --self._pPlayerNameText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pPlayerNameText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pFightCapacityText = params._pEffectiveText 
    --self._pFightCapacityText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pFightCapacityText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pPhysicalValueText = params._pPowerText 
    --self._pPhysicalValueText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pPhysicalValueText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pPhysicalValueProgressBar = params._pBar
    self._pExperienceValueText = params._pExpText 
    --self._pExperienceValueText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pExperienceValueText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pExperieceProgressBarBg = params._pExpBarBg
    self._pExperieceProgressBar = params._pExpBar 
    self._pExperieceProgNode = params._pExpPoint

    local sScreen = mmo.VisibleRect:getVisibleSize()
    local bgScreen = self._pExperieceProgressBarBg:getContentSize()
    local scale = sScreen.width/bgScreen.width

    self._pExperieceProgNode:setScaleX(scale)
    --self._pExperieceProgressBar:setScaleX(1.0)
    --self._pExperieceProgressBar:setPositionX(100)

    self._pGoldCoinValueText = params._pMoneyText 
    --self._pGoldCoinValueText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pGoldCoinValueText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pDiamondValueText = params._pRmbText 
    --self._pDiamondValueText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pDiamondValueText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pVipLevelText = params._pBitmapFontLabel_2 
    self._pPlayerIconButton = params._pJsButton 

    self._pBuyPhysicalButton = params._pBuyButton1 
    self._pBuyPhysicalButton:setZoomScale(nButtonZoomScale)
    self._pBuyPhysicalButton:setPressedActionEnabled(true)
    -- 玩家购买体力的逻辑 
    self._pBuyPhysicalButton:addTouchEventListener(function (sender,eventType) 
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        elseif eventType == ccui.TouchEventType.ended then
            DialogManager:getInstance():showDialog("BuyStrengthDialog",{kBuyThingsType.kBuyStrength})
        end
    end)

    self._pBuyGoldCoinButton = params._pBuyButton2 
    self._pBuyGoldCoinButton:setZoomScale(nButtonZoomScale)
    self._pBuyGoldCoinButton:setPressedActionEnabled(true)
    self._pBuyDiamondButton = params._pBuyButton3 
    self._pBuyDiamondButton:setZoomScale(nButtonZoomScale)
    self._pBuyDiamondButton:setPressedActionEnabled(true)
    self._pBottomRightCornnerButton = params._pFunctionButton 
    self._pTopRightCornnerButton = params._pActivityButton 
    self._pHeadNode = params._pHeadPoint 
    self._pBottomRightCornerNode = params._pFunctionPoint 
    self._pTopRightCornnerNode = params._pActivityPoint 
    self._pExperieceProgNode = params._pExpPoint 
    self._pTopRightCornnerHorizontalScroolView = params._pActivityScrollView 
    self._pTopRightCornnerHorizontalScroolView:setTouchEnabled(false)
    self._pBottomRightCornerHorizontalScrollView = params._pFunctionScrollView1 
    self._pBottomRightCornerHorizontalScrollView:setTouchEnabled(false)
    self._pBottomRightCornerVerticalScrollView = params._pFunctionScrollView2 
    self._pBottomRightCornerVerticalScrollView:setTouchEnabled(false)

    --聊天的界面
    local pChatParams = require("ChatOutsideParams"):create() 
    self._pChatPanelCCS = pChatParams._pCCS 
    self._pChatOutsideBg = pChatParams._pBackGround
    self._pChatButton = pChatParams._pChat  --聊天button
    self._pChatNotice = pChatParams._pNotice --聊天新提示
    
    -- 我要变强按钮
    self._pStrongerBtn = ccui.Button:create("MainIcon/PowerLvUpIcon.png","MainIcon/PowerLvUpIcon.png","MainIcon/PowerLvUpIcon.png",ccui.TextureResType.plistType)
    self._pStrongerBtn:setPosition(mmo.VisibleRect:left().x + 65,mmo.VisibleRect:left().y-160)   
    self._pStrongerBtn:addTouchEventListener(function (sender,eventType) 
        if eventType == ccui.TouchEventType.ended then
            DialogManager:getInstance():showDialog("StrongerDialog")
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        end
    end) 
    self._pStrongerBtn:setScale(0.7)
    self._pStrongerBtn:setVisible(false)
    self:addChild(self._pStrongerBtn)        

    -- 战灵按钮
    self._pPetBgSprite = cc.Sprite:createWithSpriteFrameName("MainUiPanelRes/zjm26.png")
    self._pPetBgSprite:setPosition(mmo.VisibleRect:left().x + 71,mmo.VisibleRect:left().y-260-30)
    self._pPetBgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self._pPetBgSprite)

    self._pPetsBtn = ccui.Button:create("MainIcon/PetIcon01.png","MainIcon/PetIcon01.png","MainIcon/PetIcon01.png",ccui.TextureResType.plistType)
    self._pPetsBtn:setPosition(mmo.VisibleRect:left().x + 65,mmo.VisibleRect:left().y-260)   
    self._pPetsBtn:addTouchEventListener(function (sender,eventType) 
        if eventType == ccui.TouchEventType.ended then
            DialogManager:showDialog("PetDialog",{})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        end
    end) 
    self._pPetsBtn:setScale(1.0)
    if TableNewFunction[5].Level > self.leveldd then
        self._pPetsBtn:setVisible(false)
        self._pPetBgSprite:setVisible(false)
    else
        self._pPetsBtn:setVisible(true)
        self._pPetBgSprite:setVisible(true)
    end
    self:addChild(self._pPetsBtn)                                                                                                                                        

    -- 活动入口
    self._pActivityBtn = ccui.Button:create("icon_0002.png","icon_0002.png","icon_0002.png",ccui.TextureResType.plistType)
    self._pActivityBtn:setPosition(mmo.VisibleRect:left().x + 65,mmo.VisibleRect:left().y-180)   
    self._pActivityBtn:addTouchEventListener(function (sender,eventType) 
        if eventType == ccui.TouchEventType.ended then
            if #ActivityManager:getInstance()._tActivityStateInfoList <= 0 then 
                ActivityMessage:QueryActivityListReq22500()
               
                return
            end
            DialogManager:getInstance():showDialog("ActivityDialog")
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        end
    end) 

    --self._pActivityBtn:setVisible(false)
    self:addChild(self._pActivityBtn)       

    --初始化聊天信息
    self:createChatFunc()

    -- 创建按钮集合
    --self:createFuncBtns()
    self._pWorldMainFuncMenu = require("WorldMainFuncMenu"):create()
    self._pLayerNode:addChild(self._pWorldMainFuncMenu)


    -- 创建活动按钮集合
    --self:createActivityFuncDataArray()
    self._pWorldActivityFuncMenu = require("WorldActivityFuncMenu"):create()
    self._pLayerNode:addChild(self._pWorldActivityFuncMenu)

    -- 任务提示框
    self._pFastTaskPanel = require("FastTaskPanel"):create()
    self._pLayerNode:addChild(self._pFastTaskPanel)

    -- 设置角色头像节点在屏幕的左上角 
    self._pHeadNode:setPosition(mmo.VisibleRect:leftTop())
    
    -- 设置活动按钮节点在屏幕的右上角 
    self._pTopRightCornnerNode:setPosition(mmo.VisibleRect:rightTop().x , mmo.VisibleRect:rightTop().y - 70 ) 
    
    -- 设置功能按钮节点在屏幕的右下角 
    self._pBottomRightCornerNode:setPosition(mmo.VisibleRect:rightBottom().x,mmo.VisibleRect:rightBottom().y+20) 
    
    -- 设置经验条节点在屏幕的左下方 
    self._pExperieceProgNode:setPosition(mmo.VisibleRect:leftBottom().x,mmo.VisibleRect:leftBottom().y)
    self._pExperieceProgNode:setVisible(true)
    --设置聊天按钮在屏幕左方
    self._pChatPanelCCS:setPosition(mmo.VisibleRect:left())

    -- 右下角箭头
    --self._pArrowLeft = ccui.ImageView:create("MainUiPanelRes/ArrowLeft.png",ccui.TextureResType.plistType)
    --self._pArrowLeft:setPosition(cc.p(self._pBottomRightCornerNode:getPositionX()-60,self._pBottomRightCornerNode:getPositionY()+55))
    --self._pLayerNode:addChild(self._pArrowLeft)

    --self._pArrowUp = ccui.ImageView:create("MainUiPanelRes/ArrowUp.png",ccui.TextureResType.plistType)
    --self._pArrowUp:setPosition(cc.p(self._pBottomRightCornerNode:getPositionX()-48,self._pBottomRightCornerNode:getPositionY()+68))
    --self._pLayerNode:addChild(self._pArrowUp)

    -- 右上角箭头
    --self._pRightArrowLeft = ccui.ImageView:create("MainUiPanelRes/ArrowLeft.png",ccui.TextureResType.plistType)
    --self._pRightArrowLeft:setPosition(cc.p(self._pTopRightCornnerNode:getPositionX()-60,self._pTopRightCornnerNode:getPositionY()-55))
    --self._pLayerNode:addChild(self._pRightArrowLeft)
    
    self._pWarningSpriteUpArrow = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSpriteUpArrow:setPosition(90,90)
    self._pWarningSpriteUpArrow:setScale(0.2)
    self._pWarningSpriteUpArrow:setVisible(false)
    self._pWarningSpriteUpArrow:setAnchorPoint(cc.p(0.5, 0.5))
    self._pTopRightCornnerButton:addChild(self._pWarningSpriteUpArrow)

    -- 上下移动动画效果
    local actionMoveBy = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
    local actionMoveToBack = cc.ScaleTo:create(0.5,0.6,0.6)
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pWarningSpriteUpArrow:stopAllActions()
    self._pWarningSpriteUpArrow:runAction(cc.RepeatForever:create(seq1))
    
    self._pWarningSpriteDownArrow = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
    self._pWarningSpriteDownArrow:setPosition(90,90)
    self._pWarningSpriteDownArrow:setScale(0.2)
    self._pWarningSpriteDownArrow:setVisible(false)
    self._pWarningSpriteDownArrow:setAnchorPoint(cc.p(0.5, 0.5))
    self._pBottomRightCornnerButton:addChild(self._pWarningSpriteDownArrow)

    -- 上下移动动画效果
    local actionMoveBy1 = cc.ScaleTo:create(0.5,0.5,0.5) -- cc.MoveBy:create(0.3,self._moveToPoint)
    local actionMoveToBack1 = cc.ScaleTo:create(0.5,0.6,0.6)
    local seq2 = cc.Sequence:create(actionMoveBy1, actionMoveToBack1)
    self._pWarningSpriteDownArrow:stopAllActions()
    self._pWarningSpriteDownArrow:runAction(cc.RepeatForever:create(seq2))
    -- 右下角图标按钮事件
    self._pBottomRightCornnerButton:loadTextures(
        "MainUiPanelRes/OutButton.png",
        "MainUiPanelRes/OutButton.png",
        "MainUiPanelRes/OutButton.png",
        ccui.TextureResType.plistType)
    self._pBottomRightCornnerButton:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:runAction(cc.Sequence:create(
                cc.CallFunc:create(function() self._pBottomRightCornnerButton:setTouchEnabled(false) end),
                cc.DelayTime:create(0.3),
                cc.CallFunc:create(function() self._pBottomRightCornnerButton:setTouchEnabled(true) end)
            ))

            NewbieManager:showOutAndRemoveWithRunTime()
            self._pWorldMainFuncMenu:changeState()
            self:changeRightArrowState()
            local temp = self._pWorldMainFuncMenu:getState()
            if temp == 1 then
                self._pBottomRightCornnerButton:loadTextures(
                    "MainUiPanelRes/OutButton.png",
                    "MainUiPanelRes/OutButton.png",
                    "MainUiPanelRes/OutButton.png",
                    ccui.TextureResType.plistType)

                self._pBottomRightCornnerButton:runAction(cc.Sequence:create(
                    cc.RotateBy:create(0.2,45.0)
                ))
            else
                self._pBottomRightCornnerButton:loadTextures(
                    "MainUiPanelRes/OutButton.png",
                    "MainUiPanelRes/OutButton.png",
                    "MainUiPanelRes/OutButton.png",
                    ccui.TextureResType.plistType)

                self._pBottomRightCornnerButton:runAction(cc.Sequence:create(
                     cc.RotateBy:create(0.2,-45.0)
                 ))
            end 
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("MainUiButton")
        end
    end)
    -- 右上角图标按钮事件
    self._pTopRightCornnerButton:loadTextures(
        "MainUiPanelRes/zjm18.png",
        "MainUiPanelRes/zjm18.png",
        "MainUiPanelRes/zjm18.png",
        ccui.TextureResType.plistType)
    self._pTopRightCornnerButton:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            self:runAction(cc.Sequence:create(
                cc.CallFunc:create(function() self._pTopRightCornnerButton:setTouchEnabled(false) end),
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(function() self._pTopRightCornnerButton:setTouchEnabled(true) end)
            ))
        
            NewbieManager:showOutAndRemoveWithRunTime()
            local temp = self._nRightUpState
            if temp == 1 then
                --self._pHeadNode:setVisible(true)

                self._pTopRightCornnerButton:loadTextures(
                    "MainUiPanelRes/zjm18.png",
                    "MainUiPanelRes/zjm18.png",
                    "MainUiPanelRes/zjm18.png",
                    ccui.TextureResType.plistType)
            else
                --self._pHeadNode:setVisible(false)

                self._pTopRightCornnerButton:loadTextures(
                    "MainUiPanelRes/zjm19.png",
                    "MainUiPanelRes/zjm19.png",
                    "MainUiPanelRes/zjm19.png",
                    ccui.TextureResType.plistType)
            end

            self._pWorldActivityFuncMenu:changeState()
            self:changeRightUpArrowState()
            
            -- 创建按钮集合 --test 
            --self:createFuncBtns()
            --for i=1,table.getn(self._tFuncBtnMap) do
             --   self._tFuncBtnMap[i]:resetPos()
            --end
            --self:setAllUIVisible(true)
            
            --RolesManager._pMainRoleInfo.level = 80
            --self:updateRoleInfoWidgets()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("MainUiButton")
        end
    end)
    -- 左上角角色icon图标按钮事件
    self._pPlayerIconButton:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
            --self:getRolesManager():createNpcRoleOnWorldMapByFinishedTaskID(1)  -- test
            DialogManager:getInstance():showDialog("RolesInfoDialog",{RoleDialogTabType.RoleDialogTypeDetail})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("FunctionButton")
        end
    end)
    
    self._pPlayerIconButton:loadTextures(
        RoleIcons[RolesManager:getInstance()._pMainRoleInfo.roleCareer],
        RoleIcons[RolesManager:getInstance()._pMainRoleInfo.roleCareer],
        RoleIcons[RolesManager:getInstance()._pMainRoleInfo.roleCareer],
        ccui.TextureResType.plistType)

    self._pLayerNode:addChild(self._pWorldUIPanelCCS,1) 
    self._pLayerNode:addChild(self._pChatPanelCCS)

    ---------------------测试用-------------------------
    -------------------显示游戏ID------------------------
    local pRoleId = ccui.Text:create()
    pRoleId:setPosition(cc.p(0,-15))
    pRoleId:setFontName(strCommonFontName)
    pRoleId:setString("游戏ID:"..RolesManager:getInstance()._pMainRoleInfo.roleId)
    pRoleId:setFontSize(32)
    self._pFightCapacityText:addChild(pRoleId)
    --------------------------------------------------
    -- 初始化数值
    self:updateRoleInfoWidgets()
    
    self._pNewEquipPanel = require("EqiupNewPanel"):create()
    self._pNewEquipPanel:setPosition(cc.p(mmo.VisibleRect:rightBottom().x-300,mmo.VisibleRect:rightBottom().y+260))
    self:addChild(self._pNewEquipPanel,19)
    self._pNewEquipPanel:setVisible(false)


    --购买货币的按钮
    local BuyFinanceButtonCallBack = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            if nTag == kFinance.kCoin then     --金币
               DialogManager:getInstance():showDialog("CashTreeDialog")
            elseif nTag == kFinance.kDiamond then  --钻石
                ShopSystemCGMessage:queryChargeListReq20506()
            end
        
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("FunctionButton")
        end
    end


    self._pBuyGoldCoinButton:setTag(kFinance.kCoin)
    self._pBuyGoldCoinButton:addTouchEventListener(BuyFinanceButtonCallBack)
    self._pBuyDiamondButton:setTag(kFinance.kDiamond)
    self._pBuyDiamondButton:addTouchEventListener(BuyFinanceButtonCallBack)
        
end

-- 初始化触摸机制
function WorldUILayer:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        print("WorldUILayer!!!!")
        local location = touch:getLocation()
        self._pCursor:stopAllActions()
        self._pCursor:setVisible(true)
        self._pCursor:setOpacity(255)
        self._pCursor:setScale(0.1)
        self._pCursor:setRotation(0)
        self._pCursor:runAction(cc.Spawn:create(cc.FadeOut:create(0.5),cc.ScaleTo:create(0.5,1.0),cc.RotateBy:create(0.5,90)))
        self._pCursor:setPosition(location.x, location.y)

        if StoryGuideManager:getInstance()._bIsStory == true then --正在进行剧情动画
            if self._pTalkFrame:isVisible() == true and location.y <= self._pTalkFrame:getContentSize().height*2 then
                self._bTalkTouchStart = true
                return true
            end
            return false
        end

        if self._pStick:getIsWorking() == true then
            return false
        end
        if self._pTalkFrame:isVisible() == true then
            self._bTalkTouchStart = true
            return true
        end
        
        --家园界面判断是否点击到人物的身上（点击多个的时候只响应第一个）
        --当前正在剧情动画
        if StoryGuideManager:getInstance()._bIsStory == true or (StoryGuideManager:getInstance()._bIsStory == false and StoryGuideManager:getInstance()._bActionHasStop == false) then --正在进行剧情动画。所有的战斗逻辑暂停
           return false
        end
        local _tOtherPlayerRoles = RolesManager:getInstance()._tOtherPlayerRoles
        for k,v in pairs(_tOtherPlayerRoles) do
           local pRoleBox = v._pAni:getBoundingBox()
           local pLocal = self:convertTouchToNodeSpace(touch)
           if cc.rectContainsPoint(pRoleBox,pLocal) == true then --如果点击到其他玩家身上就记录下其他玩家当时的坐标
               self._pTouchOtherPlayerLoc = location
               self._pTouchOtherPlayer = v
                break
           end
        end
        if self:getRolesManager()._pMainPlayerRole and self._pStick:onTouchBegan(location) == true then
            return true
        end
        if self._pTouchOtherPlayerLoc then
           return true
        end
        return false
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        if self._pTalkFrame:isVisible() == true then
            return
        end
        if StoryGuideManager:getInstance()._bIsStory == true then --正在进行剧情动画
            return
        end
        if self._pTouchOtherPlayerLoc then
           if math.abs(self._pTouchOtherPlayerLoc.x - location.x) > 100 or math.abs(self._pTouchOtherPlayerLoc.y - location.y) > 100 then
              self._pTouchOtherPlayerLoc = nil
              self._pTouchOtherPlayer = nil
           end
        end
        self._pStick:onTouchMoved(location)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        if self._pTalkFrame:isVisible() == true and self._bTalkTouchStart == true then
            if NewbieManager:getInstance():isShowingNewbie() == true then
                if NewbieManager:getInstance()._pCurNewbieLayer:isPointInTouchArea(location) == true then
                    if location.y <= self._pTalkFrame:getContentSize().height*2 then
                        self:showCurTalks()
                    end
                end
            else
                if location.y <= self._pTalkFrame:getContentSize().height*2 then
                    self:showCurTalks()
                end
            end
            return
        end
        if StoryGuideManager:getInstance()._bIsStory == true then --正在进行剧情动画
            return
        end
        if self._pTouchOtherPlayerLoc then
           DialogManager:getInstance():showDialog("PlayRoleTipsDialog",{self._pTouchOtherPlayer._pRoleInfo})
           self._pTouchOtherPlayerLoc = nil 
           self._pTouchOtherPlayer = nil
        end     
        self._pStick:onTouchEnded(location)   

    end
    local function onTouchCancelled(touch,event)
        local location = touch:getLocation()
        if StoryGuideManager:getInstance()._bIsStory == true then --正在进行剧情动画
            return
        end
        self._pStick:onTouchEnded(location)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self._pTouchListener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    
end

function WorldUILayer:NewbieOverEvent(event)
    if table.getn(self._tNewbieOpenArray) > 0 then
        NewbieManager:getInstance():showNewbieByID(self._tNewbieOpenArray[1])
        table.remove(self._tNewbieOpenArray, 1)
    end
end

-- 进行二阶段新手
function WorldUILayer:showNewbieByRoleLevel()
    if table.getn(self._tNewbieOpenArray) > 0 and NewbieManager._bSkipGuide == false then
        --DialogManager:closeDialogByName("TaskDialog") 
        --DialogManager:closeDialogByName("DrunkeryDialog") 
        --self:openUpAndDownMenu()
    
        --NewbieManager:getInstance():showNewbieByID(self._tNewbieOpenArray[1])
        self._pFastTaskPanel:setCurGuide(self._tNewbieOpenArray[1])
        table.remove(self._tNewbieOpenArray, 1)
    end
end

-- 上下按钮进入打开状态
function WorldUILayer:openUpAndDownMenu()
            local temp = self._pWorldMainFuncMenu:getState()
            self._pWorldMainFuncMenu:changeState()
            self:changeRightArrowState()
            
            if temp == 1 then
                self._pWorldMainFuncMenu:changeState()
                self:changeRightArrowState()

                self._pBottomRightCornnerButton:runAction(cc.Sequence:create(
                    cc.RotateBy:create(0.2,45.0)
                ))
            end
    
    temp = self._nRightUpState
    if temp == 1 then
        
        self:changeRightUpArrowState()
        self._pWorldActivityFuncMenu:changeState()

        self._pTopRightCornnerButton:loadTextures(
            "MainUiPanelRes/zjm18.png",
            "MainUiPanelRes/zjm18.png",
            "MainUiPanelRes/zjm18.png",
            ccui.TextureResType.plistType)
    else
        self._pTopRightCornnerButton:loadTextures(
            "MainUiPanelRes/zjm19.png",
            "MainUiPanelRes/zjm19.png",
            "MainUiPanelRes/zjm19.png",
            ccui.TextureResType.plistType)
    end
end

-- 初始化剧情对话UI
function WorldUILayer:initTalksUI()
    -- 初始化剧情对话背景框
    self._pTalkFrame = cc.Sprite:createWithSpriteFrameName("ccsComRes/talksFrame.png")
    self._pTalkFrame:setAnchorPoint(0.5,0.015)
    self._pTalkFrame:setPosition(mmo.VisibleRect:bottom())
    self._pTalkFrame:setVisible(false)
    self:addChild(self._pTalkFrame,200)
    -- 初始化剧情对话箭头
    self._pTalkArrowPlot = cc.Sprite:createWithSpriteFrameName("ccsComRes/talksArrowPlot.png")
    self._pTalkArrowPlot:setAnchorPoint(0.5,0)
    self._pTalkArrowPlot:setVisible(false)  
    self:addChild(self._pTalkArrowPlot,200)
    self._pTalkArrow = cc.Sprite:createWithSpriteFrameName("ccsComRes/talksArrow.png")
    self._pTalkArrow:setAnchorPoint(0.5,0)
    self._pTalkArrow:setVisible(false)  
    self:addChild(self._pTalkArrow,200)
    -- 初始化剧情对话文本区域
    self._pTalkTextArea = cc.Label:createWithTTF("", strCommonFontName, 24, cc.size(mmo.VisibleRect:width()*4/6-50, 150), cc.TEXT_ALIGNMENT_LEFT)
    self._pTalkTextArea:setTextColor(cFontLightYellow)
    self._pTalkTextArea:setAnchorPoint(cc.p(0, 0))
    self._pTalkTextArea:setVisible(false) 
    self:addChild(self._pTalkTextArea,200)
    
    self._pTalkArrowPlot:setPositionZ(-1)
    self._pTalkArrow:setPositionZ(-1)
    self._pTalkFrame:setPositionZ(-1)
    self._pTalkTextArea:setPositionZ(-1)

end

-- 摇杆更新逻辑
function WorldUILayer:procStick(dt)
    -- 如果当前存在剧情框，则直接返回，暂不做结算处理
    if TalksManager:getInstance():isShowingTalks() == true then
        return
    end 
    if MapManager:getInstance()._bIsCameraMoving == true then
        return
    end
    --如果当前正在播放剧情动画，暂不做结算处理
    if StoryGuideManager:getInstance()._bIsStory == true then
       return
    end

    if self._pStick:needUpdate() == true then
        local pRole = self:getRolesManager()._pMainPlayerRole
        if pRole then
            if self._pStick:getDirection() ~= -1 then  -- 正在move摇杆
                self._pStick:setIsWorking(true)  -- 设置摇杆正在工作
                -- 当前已经为跑步状态
                if pRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole)._pCurState._kTypeID == kType.kState.kWorldPlayerRole.kRun then
                    pRole:setAngle3D(self._pStick:getAngle())
                    if self._pStick:getDirection() ~= pRole._kDirection then
                        pRole._kDirection = self._pStick:getDirection()
                    end
                else  -- 当前非跑步状态 
                    pRole._kDirection = self._pStick:getDirection()
                    pRole:setAngle3D(self._pStick:getAngle())
                    pRole:getStateMachineByTypeID(kType.kStateMachine.kWorldPlayerRole):setCurStateByTypeID(kType.kState.kWorldPlayerRole.kRun)
                end
            else  -- 摇杆结束
                self._pStick:setIsWorking(false)   -- 设置摇杆不在工作
            end
        end
    else
        self._pStick:setIsWorking(false)   -- 设置摇杆不在工作
    end
end

function WorldUILayer:changeRightUpArrowState()
	if self._nRightUpState == 1 then
        self._nRightUpState = 2
    else
        self._nRightUpState = 1
    end
end

function WorldUILayer:changeRightArrowState()
    if self._nRightBottomState == 1 then
        self._nRightBottomState = 2
    else
        self._nRightBottomState = 1
    end
end

function WorldUILayer:changeRightArrowIn()
    
end

function WorldUILayer:updateRoleInfoWidgets()
    self:initNewFuncOpen()     --更新提示信息
    
    if RolesManager._pMainRoleInfo.level ~= RolesManager:getInstance()._nRoleCurLevel then
    	self:showRoleLevelUp()
    end
    
    local roleInfo = RolesManager._pMainRoleInfo
    self._pPlayerLVText:setString("Lv"..roleInfo.level)
    self._nRoleLevel = roleInfo.level
    self._pPlayerNameText:setString(roleInfo.roleName)
    self._pVipLevelText:setString(roleInfo.vipInfo.vipLevel)
    self._pFightCapacityText:setString(roleInfo.roleAttrInfo.fightingPower)
    self._pPhysicalValueText:setString(roleInfo.strength.."/"..TableConstants.PowerNumLimit.Value)
    self._pGoldCoinValueText:setString(FinanceManager:getValueByFinanceType(kFinance.kCoin))
    self._pDiamondValueText:setString(FinanceManager:getValueByFinanceType(kFinance.kDiamond))   
    --self._pVipLevelText:setString(RolesManager:getInstance()._pMainRoleInfo.vipInfo.vipLevel)
    
    self._pPhysicalValueProgressBar:setPercent(roleInfo.strength/TableConstants.PowerNumLimit.Value * 100)
    if TableLevel[roleInfo.level].Exp ~= 0 then
        local temp = roleInfo.exp/TableLevel[roleInfo.level].Exp * 100
        local temp2 = string.format("%.2f",temp)
        self._pExperienceValueText:setString(temp2 .. "%")
        self._pExperieceProgressBar:setPercent(roleInfo.exp/TableLevel[roleInfo.level].Exp * 100)

        
    else
        self._pExperienceValueText:setString("100%")
        self._pExperieceProgressBar:setPercent(100)
    end
    
    -- 判断我要变强是否显示
    self._pStrongerBtn:setVisible(roleInfo.level >= TableNewFunction[28].Level)

    self.leveldd = RolesManager:getInstance()._pMainRoleInfo.level
    self.levelNewbie = RolesManager:getInstance()._pMainRoleInfo.level

    --初始化功能按钮开启情况
    --self._tMainFuncOpenArray = {}
    local upIsHasOpen = false
    local downIsHasOpen = false
    NewbieManager:getInstance():getMainFuncLevel()
    -- 第一次登陆默认不显示 （新功能开启 二阶段引导）
    if isFirstLoginMain == true then
        NewbieManager:getInstance():setMainFuncLevel(self.leveldd)
    end
    if self.leveldd ~= NewbieManager:getInstance()._nCurOpenLevel then
        for i=1,table.getn(TableMainUIFunc) do
            if TableMainUIFunc[i].OpenConditions > NewbieManager:getInstance()._nCurOpenLevel and
                TableMainUIFunc[i].OpenConditions <= self.leveldd then
                table.insert(self._tMainFuncOpenArray,TableMainUIFunc[i])
                downIsHasOpen = true
            end
        end
        
        for i=1,table.getn(TableMainActivityFunc) do
            if TableMainActivityFunc[i].OpenConditions > NewbieManager:getInstance()._nCurOpenLevel and
                TableMainActivityFunc[i].OpenConditions <= self.leveldd then
                table.insert(self._tMainFuncOpenArray,TableMainActivityFunc[i])
                upIsHasOpen = true
            end
        end
    end
    
    -- 二阶段新手引导
    if self.levelNewbie ~= NewbieManager:getInstance()._nCurOpenLevel then
        for i=1,table.getn(TableNewFunction) do
            if TableNewFunction[i].Level > NewbieManager:getInstance()._nCurOpenLevel and
                TableNewFunction[i].Level <= self.levelNewbie and
                TableNewFunction[i].GuideId ~= nil then
                table.insert(self._tNewbieOpenArray,TableNewFunction[i])
            end
        end
    end
    
    -- 更新播放等级
    NewbieManager:getInstance():setMainFuncLevel(self.leveldd)
    
    -- 二阶段新手引导
    
        if table.getn(self._tNewbieOpenArray) > 0 then
            --DialogManager:closeDialogByName("TaskDialog") 
            --DialogManager:closeDialogByName("DrunkeryDialog") 
        
            self:showNewbieByRoleLevel()
        end
    

    if table.getn(self._tMainFuncOpenArray) > 0 then
        self._pWorldMainFuncMenu:refreshMenus()
        self._pWorldActivityFuncMenu:refreshMenus()
    end
end

-- 移除当前对话的头像集合
function WorldUILayer:removeCurTalkHeadersAndNames()
    local tBakObjs = {}
    for k,v in pairs(self._tTalkHeaders) do
        local bNeedBreak = false
        for kBak,vBak in pairs(tBakObjs) do 
            if v == vBak then
                bNeedBreak = true
                break
            end
        end
        if bNeedBreak == false then
            table.insert(tBakObjs,v)
            v:removeFromParent(true)
        end
    end
    self._tTalkHeaders = {}
    tBakObjs = nil

    for k,v in pairs(self._tTalkNames) do
        v:removeFromParent(true)
    end
    self._tTalkNames = {}

end

-- 创建指定的对话的头像集合
function WorldUILayer:createTalkHeadersAndNames(talkID)
    local tContents = TableTalks[talkID].Contents
    for kInfo, vInfo in pairs(tContents) do
        -- 创建名字
        local name = ""
        if vInfo.roleType == kType.kRole.kPlayer then
            name = self:getRolesManager()._pMainRoleInfo.roleName
        elseif vInfo.roleType == kType.kRole.kNpc then
            name = TableTempleteNpcRoles[vInfo.roleTempleteID].Name
        elseif vInfo.roleType == kType.kRole.kMonster then
            name = TableTempleteMonster[vInfo.roleTempleteID].Name
        end
        local pName = cc.Label:createWithTTF(name, strCommonFontName, 20)
        pName:setTextColor(cFontWhite)
        pName:enableOutline(cFontOutline,2)
        pName:setVisible(false)
        pName:setPositionZ(-1)
        self:addChild(pName,200)
        table.insert(self._tTalkNames,pName)

        local pAni = nil
        -- 先查找角色头像是否已经在缓存中
        local needCreate = true
        for i = 1, kInfo - 1 do
            if tContents[i].roleType == vInfo.roleType then
                if tContents[i].roleType == kType.kRole.kPlayer then
                    needCreate = false
                    pAni = self._tTalkHeaders[i]
                    break
                elseif tContents[i].roleTempleteID == vInfo.roleTempleteID then
                    needCreate = false
                    pAni = self._tTalkHeaders[i]
                    break
                end
            end
        end
        if needCreate == true then
            if vInfo.roleType == kType.kRole.kPlayer then
                local roleInfo = self:getRolesManager()._pMainRoleInfo
                local templeteID = TableEquips[roleInfo.equipemts[kEqpLocation.kBody].id - 100000].TempleteID[roleInfo.roleCareer]
                local tBodyTempleteInfo = TableTempleteEquips[templeteID]
                local templeteID = TableEquips[roleInfo.equipemts[kEqpLocation.kWeapon].id - 100000].TempleteID[roleInfo.roleCareer]
                local tWeaponTempleteInfo = TableTempleteEquips[templeteID]

                -- 判断是否加载时装身
                if roleInfo.fashionOptions and roleInfo.fashionOptions[2] == true then -- 时装身        
                    for i=1,table.getn(roleInfo.equipemts) do --遍历装备集合
                        local nPart = GetCompleteItemInfo(roleInfo.equipemts[i]).dataInfo.Part -- 部位
                        if nPart == kEqpLocation.kFashionBody then  -- 时装身部位
                            local templeteID = TableEquips[roleInfo.equipemts[kEqpLocation.kFashionBody].id - 100000].TempleteID[roleInfo.roleCareer]
                            tBodyTempleteInfo = TableTempleteEquips[templeteID] 
                            break     
                        end
                    end
                end

                if tBodyTempleteInfo ~= nil then
                    -- 3D模型
                    local fullAniName = tBodyTempleteInfo.Model1..".c3b"
                    local fullTextureName = tBodyTempleteInfo.Texture..".pvr.ccz"
                    -- 记录并加载到纹理缓存中
                    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tBodyTempleteInfo.Texture)
                    pAni = cc.Sprite3D:create(fullAniName)
                    pAni:setTexture(fullTextureName)
                    self:addChild(pAni)
                    --设置材质信息
                    setSprite3dMaterial(pAni,tBodyTempleteInfo.Material)

                    -- 3D武器模型
                    local pWeaponRC3bName = tWeaponTempleteInfo.Model1..".c3b"
                    local pWeaponLC3bName = nil
                    if tWeaponTempleteInfo.Model2 then
                        pWeaponLC3bName = tWeaponTempleteInfo.Model2..".c3b"
                    end
                    local pWeaponTextureName = tWeaponTempleteInfo.Texture..".pvr.ccz"
                    -- 记录并加载到纹理缓存中
                    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tWeaponTempleteInfo.Texture)
                    if pWeaponRC3bName then
                        local pWeaponR = cc.Sprite3D:create(pWeaponRC3bName)
                        pWeaponR:setTexture(pWeaponTextureName)
                        pWeaponR:setScale(tWeaponTempleteInfo.ModelScale1)
                        local animation = cc.Animation3D:create(pWeaponRC3bName)
                        local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
                        pWeaponR:runAction(act)
                        pAni:getAttachNode("boneRightHandAttach"):addChild(pWeaponR)
                        --设置材质信息
                        setSprite3dMaterial(pWeaponR,tWeaponTempleteInfo.Material)


                    end
                    if pWeaponLC3bName then
                        local pWeaponL = cc.Sprite3D:create(pWeaponLC3bName)
                        pWeaponL:setTexture(pWeaponTextureName)
                        pWeaponL:setScale(tWeaponTempleteInfo.ModelScale2)
                        local animation = cc.Animation3D:create(pWeaponLC3bName)
                        local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
                        pWeaponL:runAction(act)
                        pAni:getAttachNode("boneLeftHandAttach"):addChild(pWeaponL)
                         --设置材质信息
                        setSprite3dMaterial(pWeaponL,tWeaponTempleteInfo.Material)
                    end
                end

                -- 判断是否加载时装背
                local tFashionBackTempleteInfo = nil
                if roleInfo.fashionOptions and roleInfo.fashionOptions[1] == true then
                    for i=1,table.getn(roleInfo.equipemts) do --遍历装备集合
                        local nPart = GetCompleteItemInfo(roleInfo.equipemts[i]).dataInfo.Part -- 部位
                        if nPart == kEqpLocation.kFashionBack then  -- 时装背部位
                            local templeteID = TableEquips[roleInfo.equipemts[kEqpLocation.kFashionBack].id - 100000].TempleteID[roleInfo.roleCareer]
                            tFashionBackTempleteInfo = TableTempleteEquips[templeteID] 
                            break     
                        end
                    end
                end
                if tFashionBackTempleteInfo then
                    local fullAniName = tFashionBackTempleteInfo.Model1..".c3b"
                    local fullTextureName = tFashionBackTempleteInfo.Texture..".pvr.ccz"
                    -- 记录并加载到纹理缓存中
                    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tFashionBackTempleteInfo.Texture)
                    local pBack = cc.Sprite3D:create(fullAniName)
                    pBack:setTexture(fullTextureName)
                    pBack:setScale(tFashionBackTempleteInfo.ModelScale1)
                    local animation = cc.Animation3D:create(fullAniName)
                    local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
                    pBack:runAction(act)
                    pAni:getAttachNode("boneBackAttach"):addChild(pBack)
                    --设置材质信息
                    setSprite3dMaterial(pBack,tFashionBackTempleteInfo.Material)
                end

                -- 创建待机动作
                local tTempleteInfo = TableTempleteCareers[roleInfo.roleCareer]
                local animation = cc.Animation3D:create(tBodyTempleteInfo.Model1..".c3b")
                local fStartFrame = 0     -- 起始帧
                local fEndFrame = 0       -- 结束帧
                if animation ~= nil then            
                    -- 站立动作
                    if tTempleteInfo.StandActFrameRegion ~= nil then
                        fStartFrame = tTempleteInfo.StandActFrameRegion[1]
                        fEndFrame = tTempleteInfo.StandActFrameRegion[2]
                        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
                        temp:setSpeed(tTempleteInfo.StandActFrameRegion[3])
                        local stand = cc.RepeatForever:create(temp)                        
                        pAni:runAction(stand)
                    end
                end
                pAni:setScale(tTempleteInfo.ScaleInTalks)
                pAni:setVisible(false)

            elseif vInfo.roleType == kType.kRole.kNpc then
                local tTempleteInfo = TableTempleteNpcRoles[vInfo.roleTempleteID]
                local fullAniName = tTempleteInfo.AniResName..".c3b"
                local fullTextureName = tTempleteInfo.Texture..".pvr.ccz"
                -- 记录并加载到纹理缓存中
                ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(tTempleteInfo.Texture)
                pAni = cc.Sprite3D:create(fullAniName)
                pAni:setTexture(fullTextureName)
                self:addChild(pAni)
                -- 动作
                local animation = cc.Animation3D:create(fullAniName)
                local fStartFrame = 0     -- 起始帧
                local fEndFrame = 0       -- 结束帧
                if animation ~= nil then
                    -- 站立动作
                    if tTempleteInfo.StandActFrameRegion ~= nil then
                        fStartFrame = tTempleteInfo.StandActFrameRegion[1]
                        fEndFrame = tTempleteInfo.StandActFrameRegion[2]
                        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
                        temp:setSpeed(tTempleteInfo.StandActFrameRegion[3])
                        local stand = cc.RepeatForever:create(temp)
                        pAni:runAction(stand)
                    end
                end
                pAni:setScale(tTempleteInfo.ScaleInTalks)
                pAni:setVisible(false)

            elseif vInfo.roleType == kType.kRole.kMonster then
                local infoTemplete = TableTempleteMonster[vInfo.roleTempleteID]
                local fullAniName = infoTemplete.Model..".c3b"
                local fullTextureName = infoTemplete.Texture..".pvr.ccz"
                -- 记录并加载到纹理缓存中
                ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(infoTemplete.Texture)
                pAni = cc.Sprite3D:create(fullAniName)
                pAni:setTexture(fullTextureName)
                self:addChild(pAni)
                -- 动作
                local animation = cc.Animation3D:create(fullAniName)
                local fStartFrame = 0     -- 起始帧
                local fEndFrame = 0       -- 结束帧
                if animation ~= nil then
                    if infoTemplete.StandActFrameRegion ~= nil then
                        fStartFrame = infoTemplete.StandActFrameRegion[1]
                        fEndFrame = infoTemplete.StandActFrameRegion[2]
                        local temp = cc.Animate3D:createWithFrames(animation, fStartFrame, fEndFrame)
                        temp:setSpeed(infoTemplete.StandActFrameRegion[3])
                        local stand = cc.RepeatForever:create(temp)
                        pAni:runAction(stand)
                    end
                end
                pAni:setScale(infoTemplete.ScaleInTalks)
                pAni:setVisible(false)

            end
        end
        pAni:setPositionZ(0)
        table.insert(self._tTalkHeaders, pAni)
    end
    
end

function WorldUILayer:showCurTalks()
    -- 全部显示完毕
    if self:getTalksManager()._nCurTalkStep + 1 > table.getn(self:getTalksManager()._tCurContents) then
        self._pTalkFrame:setVisible(false)
        self._pTalkArrowPlot:setVisible(false)
        self._pTalkArrow:setVisible(false)
        self._pTalkTextArea:setVisible(false)
        for k,v in pairs(self._tTalkHeaders) do 
            v:setVisible(false)
        end
        for k,v in pairs(self._tTalkNames) do 
            v:setVisible(false)
        end
        self:getTalksManager():setCurTalksFinished()
        return
    end

    self._pTalkFrame:setVisible(true)
    self._pTalkArrowPlot:setVisible(true)
    self._pTalkArrow:setVisible(true)
    self._pTalkTextArea:setVisible(true)
    for k,v in pairs(self._tTalkHeaders) do 
        v:setVisible(false)
    end
    for k,v in pairs(self._tTalkNames) do 
        v:setVisible(false)
    end

    self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setVisible(true)
    self._tTalkNames[self:getTalksManager()._nCurTalkStep + 1]:setVisible(true)
    self._pTalkTextArea:setString(self:getTalksManager()._tCurContents[self:getTalksManager()._nCurTalkStep + 1].words)
    if self:getTalksManager()._tCurContents[self:getTalksManager()._nCurTalkStep + 1].posType == 1 then -- 左
        self._pTalkFrame:setScaleX(-1*mmo.VisibleRect:width()/(self._pTalkFrame:getContentSize().width-8))
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setPosition(mmo.VisibleRect:width()/2/3,5)
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setRotation3D(cc.vec3(0,45,0))
        self._tTalkNames[self:getTalksManager()._nCurTalkStep + 1]:setPosition(mmo.VisibleRect:width()/2.20, 234)
        self._pTalkArrowPlot:stopAllActions()
        self._pTalkArrow:stopAllActions()
        self._pTalkArrowPlot:setPosition(mmo.VisibleRect:width()/2/3+100,10)
        self._pTalkArrow:setPosition(mmo.VisibleRect:width()/2/3+100,25)
        self._pTalkArrowPlot:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.FadeTo:create(0.3,125)),cc.EaseSineInOut:create(cc.FadeTo:create(0.3,255)))))
        self._pTalkArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(0.3,cc.p(0,30))),cc.EaseSineInOut:create(cc.MoveBy:create(0.3,cc.p(0,-30))))))
        self._pTalkTextArea:setPosition(cc.p(mmo.VisibleRect:width()/2*2/3,13))
    elseif self:getTalksManager()._tCurContents[self:getTalksManager()._nCurTalkStep + 1].posType == 2 then -- 右
        self._pTalkFrame:setScaleX(mmo.VisibleRect:width()/(self._pTalkFrame:getContentSize().width-8))
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setPosition(mmo.VisibleRect:width()*5/6,5)
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setRotation3D(cc.vec3(0,-45,0))
        self._tTalkNames[self:getTalksManager()._nCurTalkStep + 1]:setPosition(mmo.VisibleRect:width()/1.83, 234)
        self._pTalkArrowPlot:stopAllActions()
        self._pTalkArrow:stopAllActions()
        self._pTalkArrowPlot:setPosition(mmo.VisibleRect:width()*5/6-100,10)
        self._pTalkArrow:setPosition(mmo.VisibleRect:width()*5/6-100,25)
        self._pTalkArrowPlot:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.FadeTo:create(0.3,125)),cc.EaseSineInOut:create(cc.FadeTo:create(0.3,255)))))
        self._pTalkArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(0.3,cc.p(0,30))),cc.EaseSineInOut:create(cc.MoveBy:create(0.3,cc.p(0,-30))))))
        self._pTalkTextArea:setPosition(cc.p(50,13))
    end
    self:getTalksManager()._nCurTalkStep = self:getTalksManager()._nCurTalkStep + 1

end

function WorldUILayer:setAllUIVisible(visible)
    self._pStick:setVisible(visible)
    self._pLayerNode:setVisible(visible)
    self._pChatPanelCCS:setVisible(visible)
    self._pStrongerBtn:setVisible(visible)
    self._pActivityBtn:setVisible(visible)  
    
    self._pWorldMainFuncMenu:setVisible(visible)
    self._pWorldActivityFuncMenu:setVisible(visible)
end

--添加buff图标
function WorldUILayer:createHomeBuffInfo()
   
    self._pHomeBuffIconsNode = require("HomeBuffNode"):create()
    self._pHomeBuffIconsNode:setPosition(cc.p(50,-100))
    self._pPlayerIconButton:addChild(self._pHomeBuffIconsNode) 
end

--添加buff通知
function WorldUILayer:homeAddBuffInform(event)
    if self._pHomeBuffIconsNode then
		 self._pHomeBuffIconsNode:addBuffOneBuff(event)
	end
end

--删除buff通知
function WorldUILayer:homeRemoveBuffInform(event)
    if self._pHomeBuffIconsNode then
        self._pHomeBuffIconsNode:removeBuffByType(event[1])
    end
end

-- 邮件New通知
function WorldUILayer:showNewEmail(bShow)
    if bShow == true then   -- 显示
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "邮件按钮" , value = true})    
    elseif bShow == false then  -- 不显示 
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "邮件按钮" , value = false})
    end
end


--黑名单查询和初始化嘟嘟语音最大和最小发送时长
function WorldUILayer:initChatInfo()
    mmo.HelpFunc:setShortRecordTime(TableConstants.SpeechMin.Value)
    mmo.HelpFunc:setLongRecordTime(TableConstants.SpeechMax.Value)
    ChatManager:getInstance():initChatAutoPlayVoice()
    --请求黑名单信息
    ChatCGMessage:sendMessageQueryBlackList21304()
    --初始化聊天外面的一条提示富文本
    
    self._pChatElementText = require("ElementText"):create(nil,nil,nil,nil,nil,nil,22,cc.size(1200,1))
    self._pChatElementText:setPosition(cc.p(9,(self._pChatOutsideBg:getContentSize().height)/2))
    self._pChatElementText:setAnchorPoint(cc.p(0,0.5))
   -- self._pChatOutsideBg:addChild(self._pChatElementText)
    
        -- 初始化剪切矩形
    self._pClippingNode = cc.ClippingNode:create()
    self._pClippingNode:setInverted(false)
    self._pChatOutsideBg:addChild(self._pClippingNode)
    self._pClippingNode:addChild(self._pChatElementText)  
    
    
       
    local pStencil = cc.Sprite:createWithSpriteFrameName("ChatOutsideRes/textfield.png")
    pStencil:setAnchorPoint(cc.p(0,0))
    pStencil:setScaleX(0.9)
    self._pClippingNode:setStencil(pStencil)
end

--聊天按钮回调
function WorldUILayer:createChatFunc()

 local  onTouchButton = function (sender, eventType)
     if eventType == ccui.TouchEventType.ended then
        self._tNewMessage = {} --清空外面的提示队列
        DialogManager:getInstance():showDialog("ChatDialog")
    elseif eventType == ccui.TouchEventType.began then
        AudioManager:getInstance():playEffect("ChatButton")
    end
end
 self._pChatButton:addTouchEventListener(onTouchButton)
end

--外面的聊天按钮提示
function WorldUILayer:updateChatNotice(dt)
    local pState = ChatManager:getInstance():isHasNewMessage()
    self._pChatNotice:setVisible(pState)  
end

--聊天框的通知
function WorldUILayer:homeChatOutSide(event)
    if ChatManager:getInstance()._bChatOpenView == false then --如果聊天框没有打开才接受 
        for k,v in pairs(event) do
            if v.chatType == kChatType.kAll and v.contentType ~= kContentType.kVoice then
            table.insert( self._tNewMessage,v)
       	 end
        end
        
     if self._tOutSideIsVis == false and table.getn(self._tNewMessage) >0 then --如果聊天提示框没有打开
           self._tOutSideIsVis = true
           self:openChatOutSize()
           
        end
        
    end
end

-- 新装备获得
function WorldUILayer:handleNewEquipShow(event)
    if event.show == false then
        self._pNewEquipPanel:setVisible(false)
    else
        self._pNewEquipPanel:setVisible(true)
    end
    
end

--跑马灯通知
function WorldUILayer:marqueeEvent(event)
    NoticeManager:insertMarqueeMessage(event)
end

-- 处理(客户端自己推送的更新背包列表)
function WorldUILayer:handleUpdateBagItemList(event)
    -- 更新新获得装备
    BagCommonManager:getInstance():updateNewEquip()
    -- 观察宠物信息变化
    BagCommonManager:getInstance():checkPets()
    -- 可合成宝石检查
    local bCanGemSyntheis = BagCommonManager:getInstance():isCanGemSynthesis()
    -- 可镶嵌装备检查
    BagCommonManager:getInstance()._tCanInlayEquips = BagCommonManager:getInstance():getCanInlayWearEquipIndexArry()
    -- 可强化装备
    BagCommonManager:getInstance()._tCanIntensifyEquips = BagCommonManager:getInstance():getCanIntensifyWearEquipIndexArry()
    if table.getn(BagCommonManager:getInstance()._tCanInlayEquips) > 0 or table.getn(BagCommonManager:getInstance()._tCanIntensifyEquips) > 0 or bCanGemSyntheis == true then
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "装备按钮" , value = true})
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "背包按钮" , value = true})
    else
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "装备按钮" , value = false})
        NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "背包按钮" , value = false})
    end
end

--领取任务（打开物品信息界面）
function WorldUILayer:handleMsgGainTaskAwardResp(event)
    local pArgs = {["finances"] = event.award.finances,["items"] = event.award.items,["exp"]=event.addexp}
    DialogManager:getInstance():showDialog("GetItemsDialog",pArgs)
end


-- 设置触摸屏蔽
function WorldUILayer:handleTouchable(event)
    self:setTouchEnableInDialog(event[1])
end

-- 设置摇杆锁定
function WorldUILayer:handleStickLocked(event)
	if self._pStick ~= nil then
        self._pStick:setLocked(event.locked)  
	end
end

-- 红点提示
function WorldUILayer:handleMsgWarning(event)
    --self._pWarningSpriteDownArrow:setVisible(false)
    --self._pWarningSpriteUpArrow:setVisible(false)
    --for i=1,table.getn(self._tFuncBtnMap) do
    --    if self._tFuncBtnMap[i]:isWarning() == true then
    --		self._pWarningSpriteDownArrow:setVisible(true)
    --	end
    --end
    
    --for i=1,table.getn(self._tActivityFuncMap) do
    --    if self._tActivityFuncBtnMap[i]:isWarning() == true then
    --        self._pWarningSpriteUpArrow:setVisible(true)
    --    end
    --end
end

--打开聊天提示框
function WorldUILayer:openChatOutSize()
   self._pChatOutsideBg:setVisible(true)
   
   local pInfo = self._tNewMessage[1]   
    local pContent = ": "..StrToLua(pInfo.content)[1].."   ("..string.sub(os.date("%X",pInfo.timestamp),0,5)..")"
   self._pChatElementText:refresh(nil,nil,pInfo.name,nil,pContent)
  
    local actionCallBack = function()
        table.remove(self._tNewMessage,1)
        if table.getn(self._tNewMessage) ~= 0 then
            self:openChatOutSize()
        else
            self:CloseChatOutSize()
        end
    end
  
  
   self._pChatOutsideBg:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(actionCallBack)))
  
end
--关闭聊天提示框
function WorldUILayer:CloseChatOutSize()
     self._tOutSideIsVis = false
     self._pChatOutsideBg:setVisible(false)
     
end


--新功能开启
function WorldUILayer:initNewFuncOpen()

 if self._pNewFuncOpenCCs == nil then 
    local proams = require("NewFuncOpParams"):create() 
    self._pNewFuncOpenCCs = proams._pCCS
    self._pNewFuncOpenCCs:setPosition(cc.p(mmo.VisibleRect:right().x-80,mmo.VisibleRect:right().y+270))
    self._pLayerNode:addChild(self._pNewFuncOpenCCs)
 end
 local pLevel =  RolesManager:getInstance()._pMainRoleInfo.level
 local pDesc = nil
 for i=1,table.getn(TableNewFuncOp) do
     local v = TableNewFuncOp[i]
     if pLevel~= nil and v.OpenConditions > pLevel then 
        pDesc = v.Desc
        break
     end
 end
 if pDesc ~= nil then  --表里的字段必须有大于当前等级的时候
    local pMountNode = self._pNewFuncOpenCCs:getChildByName("NodeNewFunc")
    pMountNode:getChildByName("FuncText"):setString(pDesc)
 else
    self._pNewFuncOpenCCs:setVisible(false)
 end
end

--升级人物特效
function WorldUILayer:showRoleLevelUp()
    RolesManager:getInstance()._pMainPlayerRole:playLevelUpEffect()
    RolesManager:getInstance()._nRoleCurLevel = RolesManager._pMainRoleInfo.level

    local pContSize = cc.Director:getInstance():getWinSize()
    local pAniPostionX = pContSize.width/2
    local pAniPostionY = pContSize.height/2

    self._pLvUpEffectAniNode = cc.CSLoader:createNode("LvUpEffect.csb")
    local _pLvUpEffectAniAction = cc.CSLoader:createTimeline("LvUpEffect.csb")
    self._pLvUpEffectAniNode:setScale(1)
    self._pLvUpEffectAniNode:setPosition(cc.p(pAniPostionX,pAniPostionY))
    self:addChild(self._pLvUpEffectAniNode,0)

    _pLvUpEffectAniAction:gotoFrameAndPlay(0,_pLvUpEffectAniAction:getDuration(), false)
    self._pLvUpEffectAniNode:stopAllActions()
    self._pLvUpEffectAniNode:runAction(_pLvUpEffectAniAction)
end

--是否有失败后的我要变强引导
function WorldUILayer:initFaildGruid()
    local pGruidId = PurposeManager:getInstance():getFaildGruidId() 
    if pGruidId then
       PurposeManager:getInstance():createPurpose(pGruidId)
       PurposeManager:getInstance():startOperateByTaskId(pGruidId)
    end

end


return WorldUILayer
