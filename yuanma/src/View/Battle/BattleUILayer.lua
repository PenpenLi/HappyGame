--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleUILayer.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/4
-- descrip:   战斗UI层
--===================================================
local BattleUILayer = class("BattleUILayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function BattleUILayer:ctor()
    self._strName = "BattleUILayer"             -- 层名称
    self._pTouchListener = nil                  -- 触摸监听器
    self._pHeader = nil                         -- 玩家角色头像
    self._pLevLabel = nil                       -- 玩家角色等级
    self._pNameLabel = nil                      -- 玩家角色名称
    self._pHitNode = nil                        -- 连击特效结点
    self._pHitText = nil                        -- 连击数字Label
    self._pHitWords = nil                       -- 连击文字pic
    self._nHitNum = 0                           -- 连击数字
    self._pStick = nil                          -- 摇杆
    self._bStickDisabled = false                -- 摇杆是否失效
    self._pCursor = nil                         -- 触摸手标
    self._pPanelCCS = nil                       -- CCS根节点
    self._pUILeftUp = nil                       -- 左上角UI节点
    self._pFuncBtnNode = nil                    -- 功能按钮节点（自动战斗+退出战斗）
    self._pAttackBtnNode = nil                  -- 攻击按钮节点（普通攻击+技能攻击）
    self._pTimeNode = nil                       -- 时间节点
    self._pPlayerHpBG = nil                     -- 玩家血条节点
    self._pPlayerHpBar = nil                    -- 玩家血条
    self._pPlayerHpCache = nil                  -- 玩家血条缓冲
    self._pPlayerHpText = nil                   -- 玩家血条文字x%
    self._pPlayerAngerBar = nil                 -- 玩家怒气条
    self._pPlayerAngerEffectAni = {}            -- 玩家怒气UI特效Ani(3个)
    self._bIsShowingAngerEffect = false         -- 标记当前是否正在显示怒气UI特效
    self._pPlayerBuffIconsNode = nil            -- 玩家的Buff图标队列
    
    self._pPetNode = nil                        -- 宠物UI总结点
    self._pPetHeaderFrame = nil                 -- 宠物角色头像底框
    self._pPetHeaderIcon = nil                  -- 宠物角色头像图标
    self._pPetHpBG = nil                        -- 宠物血条背景
    self._pPetHpBar = nil                       -- 宠物血条
    self._pPetHpCache = nil                     -- 宠物血条缓冲
    
    self._pBossHpBG = nil                       -- Boss血条节点
    self._pBossHpBar = nil                      -- Boss血条
    self._pBossHpCache = nil                    -- Boss血条缓冲
    self._pBossNameText = nil                   -- Boss名称
    self._pBossBuffIconsNode = nil              -- Boss的Buff图标队列
    self._pTestButton = nil                     -- 测试按钮
    self._pAutoBattleButton = nil               -- 自动战斗按钮（表示状态）
    self._pUnAutoBattleButton = nil             -- 手动战斗按钮（表示状态）
    self._pExitBattleButton = nil               -- 退出战斗按钮
    self._pHeaderAngerButton = nil              -- 头像怒气大招按钮
    self._pGenAttackButton = nil                -- 普通攻击按钮
    self._pSkillAttackButtons = {}              -- 技能按钮集合（左面是技能1，以此类推）
    self._pFriendSkillAttackButton = nil        -- 好友技能按钮
    self._fTouchingCounter = -1                 -- 用于判定是否正在长按攻击按钮的计时器（-1时表示没有长按，且不计时，0时开始自动计时）
    self._bIsTouchingGenAttackButton = false    -- 是否正在长按攻击按钮

    self._nPlayerHpMax = 0                      -- 玩家血量最大值
    self._nPlayerHpCur = 0                      -- 玩家血量当前值
    self._nPlayerAngerMax = 0                   -- 玩家怒气最大值
    self._nPlayerAngerCur = 0                   -- 玩家怒气当前值
    self._nPetHpMax = 0                         -- 玩家宠物血量最大值
    self._nPetHpCur = 0                         -- 玩家宠物血量当前值
    self._nBossHpMax = 0                        -- boss血量最大值
    self._nBossHpCur = 0                        -- boss血量当前值
    
    self._pTalkFrame = nil                      -- 剧情对话背景框
    self._tTalkHeaders = {}                     -- 剧情对话头像，按照当前对话Contents数据中的角色顺序存放
    self._pTalkArrow = nil                      -- 剧情对话箭头
    self._pTalkTextArea = nil                   -- 剧情对话文字区域
    self._bTalkTouchStart = false               -- 剧情对话触摸是否开始
    
    self._pTowerCdText = nil                    -- 爬塔副本的结算后的时间倒计时
    self._pTowerCdBg = nil                      -- 爬塔副本的结算后的背景框

    self._pChatPanelCCS = nil                   -- 聊天的ccs
    self._pChatOutsideBg = nil                  -- 聊天的背景
    self._pChatButton = nil                     -- 聊天button
    self._pChatNotice = nil                     -- 聊天新提示
    self._tNewMessage = {}                      -- 聊天的提示集合
    self._tOutSideIsVis = false                 -- 聊天的提示开关
    self._pChatElementText = nil                -- 聊天的富文本
    
    self._bHasVisChatBtn = true                 -- 是否有聊天按钮
    
    self._bTeamVoiceHasPlay = false             -- 团队语音是否播放
    self._tTeamVoiceMessage = {}                -- 团队语音集合
    self._pButtonCdTime = 0
    self._nButtonCd = 3
    self._nVoiceCdTime = 0                      -- 语音倒计时

    self._pResultByGradeNode = nil              -- 材料副本或金钱副本评分
    self._pTimeCountDownNode = nil              -- 根据战斗时长评分节点
    self._pGoldDropNode = nil                   -- 金钱副本中的已获得金币相关UI
    
end

-- 创建函数
function BattleUILayer:create()
    local layer = BattleUILayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleUILayer:dispose()
    
    ResPlistManager:getInstance():addSpriteFrames("FightUI.plist")
    ResPlistManager:getInstance():addSpriteFrames("SpeekingEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("ChatOutside.plist")
    NetRespManager:getInstance():addEventListener(kNetCmd.kChatOutSide,handler(self, self.homeChatOutSide))
    NetRespManager:getInstance():addEventListener(kNetCmd.kChatTeamVoice,handler(self, self.BattleChatTeamVoice))
    NetRespManager:getInstance():addEventListener(kNetCmd.kSetStickLocked,handler(self, self.handleStickLocked))
    NetRespManager:getInstance():addEventListener(kNetCmd.kDisPlayNotice ,handler(self, self.marqueeEvent)) --跑马灯公告通知
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateRoleInfo ,handler(self, self.updateRoleInfo)) --更新人物信息

    
    -- 初始化UI
    self:initUI()
    
    -- 初始化进度条
    self:initBars()

    -- 初始化连击动画
    self:initHitAni()

    -- 初始化剧情对话UI
    self:initTalksUI()
    
    -- 处理控件
    self:disposeWidgets()   
    
    -- 初始化触摸
    self:initTouches() 
    
    --初始化爬塔副本的右侧说明 仅爬塔副本用
    self:initTowerCopyExplain()
   
    --初始化聊天信息
    self:createChatFunc()
    
    --初始化金钱副本或材料副本的评星
    self:initResultByGrade()

    -- 初始化根据战斗时长评分xi
    self:initTimeCountDownResultNode()
    
    -- 初始化金钱副本中金币UI
    self:initGoldDropNode()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBattleUILayer()
        end
        if event == "enter" then
            -- PVP和华山副本的时候需要有  VS特效
            self:initVSEffect()
 
            if self:getBattleManager()._bIsAutoBattle == true then
                self:getBattleManager():toAutoBattle()
            else
                self:getBattleManager():toUnAutoBattle()
            end
        	
            -- 读取新手引导起始
            if NewbieManager:getInstance()._bSkipGuide == false then
                if TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId == 10001 then  -- 第一次进入战斗引导
                    NewbieManager:getInstance():showNewbieByID("Guide_1_1")
                elseif TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId == 10006 then  -- 第6次进入战斗引导
                    NewbieManager:getInstance():showNewbieByID("Guide_6_15")
                end
                if TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId <= 10006 then
                    -- 战斗中，只要是新手引导，则立即隐藏退出按钮和自动战斗按钮
                    NewbieManager:getInstance()._bIsForceGuideForBattle = true      -- 强制性战斗引导
                    self._pAutoBattleButton:setVisible(false)
                    self._pUnAutoBattleButton:setVisible(false)
                    self._pExitBattleButton:setVisible(false)
                    BattleManager:getInstance():pauseTime()
                    self._pTimeNode:setVisible(false)
                else
                    NewbieManager:getInstance()._bIsForceGuideForBattle = false
                end
            end

        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function BattleUILayer:onExitBattleUILayer()
    self:onExitLayer()
    
    ResPlistManager:getInstance():removeSpriteFrames("FightUI.plist")
    ResPlistManager:getInstance():removeSpriteFrames("ChatOutside.plist")
    ResPlistManager:getInstance():removeSpriteFrames("SpeekingEffect.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
    
end

-- 循环更新
function BattleUILayer:update(dt)
    if BattleManager:getInstance()._bIsTransforingFromEndBattle == true then
        return
    end
    -- 摇杆proc
    self:procStick(dt)
    -- 判断是否是长按普通攻击按钮进行连击操作
    self._bIsTouchingGenAttackButton = false
    if self._fTouchingCounter ~= -1 then
        self._fTouchingCounter = self._fTouchingCounter + dt
        if self._fTouchingCounter >= 0.1 then
            self._fTouchingCounter = 0.1
            self._bIsTouchingGenAttackButton = true
            if self:getRolesManager()._pMainPlayerRole then
                if self:getRolesManager()._pMainPlayerRole:isUnusualState() == false and 
                   self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kGenAttack then
                    self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kGenAttack, true)
                end
            end
            
        end
    end
    
    if self._pPlayerBuffIconsNode then
    	self._pPlayerBuffIconsNode:update(dt)
    end
    if self._pBossBuffIconsNode then
        self._pBossBuffIconsNode:update(dt)
    end
    self:updateChatNotice(dt)
end

-- 显示结束时的回调
function BattleUILayer:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BattleUILayer:doWhenCloseOver()
    return
end

-- 初始化UI
function BattleUILayer:initUI()   
    -- 创建摇杆
    self._pStick = mmo.Stick:createWithFrameName("com_003.png","com_002.png")
    self._pStick:setStartPosition(cc.p(self._pStick:getFrameSize().width/2 + 20, self._pStick:getFrameSize().height/2 + 44))
    self._pStick:setLocked(OptionManager:getInstance()._bStickLock)  -- 默认为不锁定
    self:addChild(self._pStick)
    
    -- 创建手标    
    self._pCursor = cc.Sprite:createWithSpriteFrameName("ccsComRes/wanzifu.png")
    self:addChild(self._pCursor,kZorder.kMax)
    self._pCursor:setVisible(false)
    
    -- 加载组件
    local params = require("FightUIParams"):create()
    self._pPanelCCS = params._pCCS
    self._pUILeftUp = params._pNodePCHPrage
    self._pFuncBtnNode = params._pNodeFunc
    self._pAttackBtnNode = params._pNodeAttack
    self._pTimeNode = params._ptime
    
    self._pTestButton = params._pTestButton
    self._pAutoBattleButton = params._pautomaticfight
    self._pUnAutoBattleButton = params._pautomaticfight2
    self._pExitBattleButton = params._pout
    self._pHeaderAngerButton = params._piconandskill5
    self._pGenAttackButton = params._pnormalattack
    self._pSkillAttackButtons = {}
    
    ---------------------------- skill btn 
    local function skillAttack(skillType)
        if self:getRolesManager()._pMainPlayerRole then
            if self:getRolesManager()._pMainPlayerRole:isUnusualState() == false then
                if self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kSkillAttack and 
                   self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kAngerAttack and 
                   self:getRolesManager()._pMainPlayerRole._tSkills[skillType]:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
                    self._pSkillAttackButtons[skillType-1]:resetCD()
                    self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kSkillAttack, true, skillType)
                    
                    if NewbieManager:getInstance()._bSkipGuide == false and NewbieManager:getInstance()._nCurID == "Guide_1_3" then
                        self._bStickDisabled = false        -- 恢复摇杆禁用
                        NewbieManager:getInstance():showOutAndRemoveWithRunTime()
                    end
                                        
                end
            end
        end

    end

    local skillPosition = {
        {-308 , 15},
        {-309 , 136},
        {-215 , 214},
        {-93 , 223},
    }

    local sScreen = mmo.VisibleRect:getVisibleSize()

    for i=1,table.getn(SkillsManager:getInstance()._tMainRoleMountActvSkills) do
        local skillInfo = SkillsManager:getInstance():getMainRoleSkillDataByID(SkillsManager:getInstance()._tMainRoleMountActvSkills[i].id,SkillsManager:getInstance()._tMainRoleMountActvSkills[i].level)
        
        local pSkillAttackButton = require("BattleSkillButtonWidget"):create()
        pSkillAttackButton:setPosition(sScreen.width + skillPosition[i][1],skillPosition[i][2])
        self:addChild(pSkillAttackButton)
        pSkillAttackButton:setTag(i+1)
        pSkillAttackButton:setCallfunc(skillAttack)
        pSkillAttackButton:setSkillInfo(skillInfo)

        table.insert(self._pSkillAttackButtons, pSkillAttackButton)
    end
    
    for i=table.getn(SkillsManager:getInstance()._tMainRoleMountActvSkills)+1,4 do
        local pSkillAttackButton = require("BattleSkillButtonWidget"):create()
        pSkillAttackButton:setPosition(sScreen.width + skillPosition[i][1],skillPosition[i][2])
        self:addChild(pSkillAttackButton)
        pSkillAttackButton:setTag(i)
        pSkillAttackButton:setNoOpenState()
        
        table.insert(self._pSkillAttackButtons, pSkillAttackButton)
    end
    -------------------------------------
    -- 好友技能按钮
    if FriendManager:getInstance():getFriendSkillId() ~= -1 then
        local function friendSkillCallBack(skillType)
            if skillType == "firendSkill" then
                if self:getSkillsManager()._pFriendSkill and self:getRolesManager()._pFriendRole:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole)._pCurState._kTypeID == kType.kState.kBattleFriendRole.kSuspend then
                    self._pFriendSkillAttackButton:resetCD()
                    self:getRolesManager()._pFriendRole:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kAppear)
                end
            end
        end
        self._pFriendSkillAttackButton = require("BattleSkillButtonWidget"):create()
        self._pFriendSkillAttackButton:setPosition(13,mmo.VisibleRect:height() - 330)
        self:addChild(self._pFriendSkillAttackButton)
        self._pFriendSkillAttackButton:setTag("firendSkill")
        self._pFriendSkillAttackButton:setCallfunc(friendSkillCallBack)
        self._pFriendSkillAttackButton:setSkillInfo(TableFriendSkills[FriendManager:getInstance():getFriendSkillId()])
    end

    
    if self:getBattleManager()._bIsAutoBattle == true then
        self._pAutoBattleButton:setVisible(true)
        self._pUnAutoBattleButton:setVisible(false)
    else
        self._pAutoBattleButton:setVisible(false)
        self._pUnAutoBattleButton:setVisible(true)
    end
    self._pUILeftUp:setPosition(0,mmo.VisibleRect:height()-10)
    self._pFuncBtnNode:setPosition(mmo.VisibleRect:width(),mmo.VisibleRect:height()-120)
    self._pAttackBtnNode:setPosition(mmo.VisibleRect:width()-20,30)
    self._pTimeNode:setPosition(mmo.VisibleRect:width()/2 + 100,mmo.VisibleRect:height()-20)

    self:addChild(self._pPanelCCS,1)
    
end

function BattleUILayer:initVSEffect()
    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kPVP or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kHuaShan then
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr("PvpPkEffect")
        self._pVSEffectAni = cc.CSLoader:createNode("PvpPkEffect.csb")
        self._pVSEffectAni:setScale(2)
        self._pVSEffectAni:setPosition(mmo.VisibleRect:width()/2,mmo.VisibleRect:height()/2)
        self:addChild(self._pVSEffectAni)
        local playVSEffect = function()
            local function onFrameEvent(frame)
                if nil == frame then
                    return
                end
                local str = frame:getEvent()
                if str == "start" then
                elseif str == "end" then
                    self._pVSEffectAni:stopAllActions()
                    self._pVSEffectAni:removeFromParent(true)
                end
            end
            local vsAction = cc.CSLoader:createTimeline("PvpPkEffect.csb")
            vsAction:gotoFrameAndPlay(0, vsAction:getDuration(), false)  
            vsAction:setFrameEventCallFunc(onFrameEvent)
            self._pVSEffectAni:runAction(vsAction)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(playVSEffect)))
    end
end

-- 设置玩家血量最大值
function BattleUILayer:setPlayerHpMax(hpMax)
    self._nPlayerHpMax = hpMax
end

-- 设置玩家血量当前值
function BattleUILayer:setPlayerHpCur(hpCur,bSkipAni)
    self._nPlayerHpCur = hpCur
    self._pPlayerHpText:setString(self._nPlayerHpCur.."/"..self._nPlayerHpMax)
    self._pPlayerHpBar:setPercentage(self._nPlayerHpCur/self._nPlayerHpMax*100.0)
    if bSkipAni then
        self._pPlayerHpCache:setPercentage(self._nPlayerHpCur/self._nPlayerHpMax*100.0)
    else
        self._pPlayerHpCache:stopAllActions()
        self._pPlayerHpCache:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, self._nPlayerHpCur/self._nPlayerHpMax*100.0)))
    end
    
end

-- 设置玩家怒气最大值
function BattleUILayer:setPlayerAngerMax(maxValue)
    self._nPlayerAngerMax = maxValue
end

-- 设置玩家怒气当前值
function BattleUILayer:setPlayerAngerCur(angerCur)
    self._nPlayerAngerCur = angerCur
    self._pPlayerAngerBar:setPercentage(self._nPlayerAngerCur/self._nPlayerAngerMax*100.0)
    if self._nPlayerAngerCur >= self._nPlayerAngerMax then
        if self._bIsShowingAngerEffect == false then
            self:playAngerEffect()
        end 
    else
        if self._bIsShowingAngerEffect == true then
            self:stopAngerEffect()
        end 
    end
end

-- 设置玩家宠物血量最大值
function BattleUILayer:setPetHpMax(hpMax)
    self._nPetHpMax = hpMax
end

-- 设置玩家宠物血量当前值
function BattleUILayer:setPetHpCur(hpCur,bSkipAni)
    self._nPetHpCur = hpCur
    self._pPetHpBar:setPercentage(self._nPetHpCur/self._nPetHpMax*100.0)
    if bSkipAni then
        self._pPetHpCache:setPercentage(self._nPetHpCur/self._nPetHpMax*100.0)
    else
        self._pPetHpCache:stopAllActions()
        self._pPetHpCache:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, self._nPetHpCur/self._nPetHpMax*100.0)))
    end

end

-- 设置boss血量最大值
function BattleUILayer:setBossName(name)
    self._pBossNameText:setString(name)
end

-- 设置boss血量最大值
function BattleUILayer:setBossHpMax(bossHpMax)
    self._nBossHpMax = bossHpMax
end

-- 设置boss血量当前值
function BattleUILayer:setBossHpCur(bossHpCur)
    self._nBossHpCur = bossHpCur
    self._pBossHpBar:setPercentage(self._nBossHpCur/self._nBossHpMax*100.0)
    self._pBossHpCache:stopAllActions()
    self._pBossHpCache:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, self._nBossHpCur/self._nBossHpMax*100.0)))
end

-- 初始化血条
function BattleUILayer:initBars()
    -- 初始化主角血条
    local pBG = cc.Sprite:createWithSpriteFrameName("FightUIRes/mainRoleframe.png")
    local pBar = cc.Sprite:createWithSpriteFrameName("BloodBarAniRes/BigBloodBar.png")
    local pBarCache = cc.Sprite:createWithSpriteFrameName("BloodBarAniRes/BigBloodBarCache.png")

    self._pPlayerHpBar = cc.ProgressTimer:create(pBar)
    self._pPlayerHpBar:setAnchorPoint(0,0)
    self._pPlayerHpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pPlayerHpBar:setMidpoint(cc.p(0,0))
    self._pPlayerHpBar:setBarChangeRate(cc.p(1,0))
    self._pPlayerHpBar:setPercentage(100)
    self._pPlayerHpBar:setPosition(cc.p(126,77))

    self._pPlayerHpCache = cc.ProgressTimer:create(pBarCache)
    self._pPlayerHpCache:setAnchorPoint(0,0)
    self._pPlayerHpCache:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pPlayerHpCache:setMidpoint(cc.p(0,0))
    self._pPlayerHpCache:setBarChangeRate(cc.p(1,0))
    self._pPlayerHpCache:setPercentage(100)
    self._pPlayerHpCache:setPosition(cc.p(126,77))

    -- 血条文字
    self._pPlayerHpText = cc.Label:createWithTTF("100%", strCommonFontName, 18)
    --self._pPlayerHpText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1))
    self._pPlayerHpText:setPosition(cc.p(self._pPlayerHpBar:getPositionX() + self._pPlayerHpBar:getContentSize().width/2, self._pPlayerHpBar:getPositionY() + self._pPlayerHpBar:getContentSize().height/2-2))
    self._pPlayerHpText:setColor(cWhite)

    self._pPlayerHpBG = pBG
    self._pPlayerHpBG:addChild(self._pPlayerHpCache)
    self._pPlayerHpBG:addChild(self._pPlayerHpBar)
    self._pPlayerHpBG:addChild(self._pPlayerHpText)
    self._pPlayerHpBG:setAnchorPoint(0,0)
    local x, y = self._pUILeftUp:getPosition()
    self._pPlayerHpBG:setPosition(x + 1,y-130)
    self:addChild(self._pPlayerHpBG)

    -- 头像
    local RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
    self._pHeader = cc.Sprite:createWithSpriteFrameName(RoleIcons[self:getRolesManager()._pMainPlayerRole._pRoleInfo.roleCareer])
    self._pHeader:setAnchorPoint(cc.p(0.5,0))
    self._pHeader:setPosition(cc.p(self._pHeaderAngerButton:getContentSize().width/2-15,31))
    self._pHeaderAngerButton:addChild(self._pHeader,2)
    
    -- 等级标签
    self._pLevLabel = cc.Label:createWithTTF("Lv"..self:getRolesManager()._pMainPlayerRole._pRoleInfo.level, strCommonFontName, 20)
    self._pLevLabel:setAnchorPoint(cc.p(0,0))
    --self._pLevLabel:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._pLevLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._pLevLabel:setPosition(cc.p(134,100))
    self._pLevLabel:setColor(cGreen)
    self._pPlayerHpBG:addChild(self._pLevLabel,10)
    
    -- 名字标签
    self._pNameLabel = cc.Label:createWithTTF(self:getRolesManager()._pMainPlayerRole._pRoleInfo.roleName, strCommonFontName, 20)
    self._pNameLabel:setAnchorPoint(cc.p(0,0))
    --self._pNameLabel:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._pNameLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self._pNameLabel:setPosition(cc.p(self._pLevLabel:getPositionX() + self._pLevLabel:getContentSize().width + 6, self._pLevLabel:getPositionY()))
    self._pNameLabel:setColor(cWhite)
    self._pPlayerHpBG:addChild(self._pNameLabel,10)
    
    -- 初始化主角怒气条
    local pAngerBar = cc.Sprite:createWithSpriteFrameName("FightUIRes/Anger.png")
    self._pPlayerAngerBar = cc.ProgressTimer:create(pAngerBar)
    self._pPlayerAngerBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self._pPlayerAngerBar:setMidpoint(cc.p(0.5,0.5))
    self._pPlayerAngerBar:setBarChangeRate(cc.p(0,1))
    self._pPlayerAngerBar:setScaleX(-1)
    self._pPlayerAngerBar:setPercentage(100)
    self._pPlayerAngerBar:setPosition(cc.p(self._pPlayerAngerBar:getContentSize().width/2,self._pPlayerAngerBar:getContentSize().height/2+4))
    self._pPlayerHpBG:addChild(self._pPlayerAngerBar)
    
    -- 怒气UI特效
    local effect1 = cc.CSLoader:createNode("AngerUIEffect1.csb")
    effect1:setVisible(false)
    self._pHeaderAngerButton:addChild(effect1,3)
    table.insert(self._pPlayerAngerEffectAni, effect1)
    
    local effect2 = cc.CSLoader:createNode("AngerUIEffect2.csb")
    effect2:setVisible(false)
    self._pHeaderAngerButton:addChild(effect2,1)
    table.insert(self._pPlayerAngerEffectAni, effect2)
    
    local effect3 = cc.CSLoader:createNode("AngerUIEffect3.csb")
    effect3:setVisible(false)
    self._pHeaderAngerButton:addChild(effect3,4)
    table.insert(self._pPlayerAngerEffectAni, effect3)
    
    effect1:setPosition(cc.p(self._pHeaderAngerButton:getContentSize().width/2, self._pHeaderAngerButton:getContentSize().height/2))
    effect2:setPosition(cc.p(self._pHeaderAngerButton:getContentSize().width/2, self._pHeaderAngerButton:getContentSize().height/2))
    effect3:setPosition(cc.p(self._pHeaderAngerButton:getContentSize().width/2, self._pHeaderAngerButton:getContentSize().height/2))

    -- 初始化Boss血条
    local pBossBG = cc.Sprite:createWithSpriteFrameName("FightUIRes/bossframe.png")
    local pBossBar = cc.Sprite:createWithSpriteFrameName("BloodBarAniRes/bossHP.png")
    local pBossBarCache = cc.Sprite:createWithSpriteFrameName("BloodBarAniRes/bossHPCache.png")
    
    self._pBossHpBar = cc.ProgressTimer:create(pBossBar)
    self._pBossHpBar:setAnchorPoint(0,0)
    self._pBossHpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pBossHpBar:setMidpoint(cc.p(1,0))
    self._pBossHpBar:setBarChangeRate(cc.p(1,0))
    self._pBossHpBar:setPercentage(100)
    self._pBossHpBar:setPosition(cc.p((pBossBG:getContentSize().width - self._pBossHpBar:getContentSize().width)/2,43))
    
    self._pBossHpCache = cc.ProgressTimer:create(pBossBarCache)
    self._pBossHpCache:setAnchorPoint(0,0)
    self._pBossHpCache:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pBossHpCache:setMidpoint(cc.p(1,0))
    self._pBossHpCache:setBarChangeRate(cc.p(1,0))
    self._pBossHpCache:setPercentage(100)
    self._pBossHpCache:setPosition(cc.p((pBossBG:getContentSize().width - self._pBossHpCache:getContentSize().width)/2,43))

    -- Boss名称
    self._pBossNameText = cc.Label:createWithTTF("", strCommonFontName, 18)
    --self._pBossNameText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1))
    self._pBossNameText:setPosition(cc.p(self._pBossHpBar:getPositionX() + self._pBossHpBar:getContentSize().width/2, self._pBossHpBar:getPositionY() + self._pBossHpBar:getContentSize().height/2-2))
    self._pBossNameText:setColor(cWhite)
    
    self._pBossHpBG = pBossBG
    pBossBG:addChild(self._pBossHpCache)
    pBossBG:addChild(self._pBossHpBar)
    pBossBG:addChild(self._pBossNameText)
    pBossBG:setAnchorPoint(1,0)
    pBossBG:setPosition(mmo.VisibleRect:width() - 8, mmo.VisibleRect:height() - pBossBG:getContentSize().height)
    self:addChild(pBossBG)

    -- 初始化主角的宠物头像和血条
    if PetsManager:getInstance()._pMainPetRole then
        self._pPetHeaderFrame = cc.Sprite:createWithSpriteFrameName("FightUIRes/HeadBtnNormal.png")
        self._pPetHeaderFrame:setScale(0.8)
        self._pPetHeaderIcon = cc.Sprite:createWithSpriteFrameName(PetsManager:getInstance()._pMainPetRole._pTempleteInfo.PetIcon..".png")
        self._pPetHeaderIcon:setScale(0.8)

        local pBarCache = cc.Sprite:createWithSpriteFrameName("FightUIRes/PetBloodBarCache.png")
        self._pPetHpCache = cc.ProgressTimer:create(pBarCache)
        self._pPetHpCache:setAnchorPoint(0,0)
        self._pPetHpCache:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self._pPetHpCache:setMidpoint(cc.p(0,0))
        self._pPetHpCache:setBarChangeRate(cc.p(1,0))
        self._pPetHpCache:setPercentage(100)
        self._pPetHpCache:setPosition(cc.p(20,3))

        local pBar = cc.Sprite:createWithSpriteFrameName("FightUIRes/PetBloodBar.png")
        self._pPetHpBar = cc.ProgressTimer:create(pBar)
        self._pPetHpBar:setAnchorPoint(0,0)
        self._pPetHpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self._pPetHpBar:setMidpoint(cc.p(0,0))
        self._pPetHpBar:setBarChangeRate(cc.p(1,0))
        self._pPetHpBar:setPercentage(100)
        self._pPetHpBar:setPosition(cc.p(20,3))

        self._pPetHpBG = cc.Sprite:createWithSpriteFrameName("FightUIRes/PetBloodBg.png")
        self._pPetHpBG:setPosition(cc.p(self._pPetHeaderFrame:getBoundingBox().width/2 + pBar:getBoundingBox().width/2 - 24, 10))
        self._pPetHpBG:addChild(self._pPetHpCache)
        self._pPetHpBG:addChild(self._pPetHpBar)

        self._pPetNode = cc.Node:create()
        self._pPetNode:addChild(self._pPetHpBG)
        self._pPetNode:addChild(self._pPetHeaderFrame)
        self._pPetNode:addChild(self._pPetHeaderIcon)
        self._pPetNode:setPosition(cc.p(44,mmo.VisibleRect:height() - 184))

        self:addChild(self._pPetNode)
        
        self._pTestButton:setPosition(cc.p(self._pTestButton:getPositionX() - 12, self._pTestButton:getPositionY() - 40))
        
    end
    
    -- 关联主角信息到ui
    self:getRolesManager()._pMainPlayerRole:setBattleUILayerDelegate(self)
    
    -- 关联主角宠物信息到ui
    if self:getPetsManager()._pMainPetRole then
        self:getPetsManager()._pMainPetRole:setBattleUILayerDelegate(self)
    end
    
    -- 关联BOSS或者PVP对手信息到ui
    self._pBossHpBG:setVisible(false)
    if self:getMonstersManager()._pBoss then
        self:getMonstersManager()._pBoss:setBattleUILayerDelegate(self)
    elseif self:getRolesManager()._pPvpPlayerRole then
        self:getRolesManager()._pPvpPlayerRole:setBattleUILayerDelegate(self)
    end
    
    self._pPlayerBuffIconsNode = require("BuffNode"):create()
    self._pPlayerBuffIconsNode:setPosition(cc.p(134,42))
    self._pPlayerHpBG:addChild(self._pPlayerBuffIconsNode)

    self._pBossBuffIconsNode =require("BuffNode"):create()
    self._pBossBuffIconsNode:setPosition(cc.p(0,3))
    pBossBG:addChild(self._pBossBuffIconsNode)
    
end 

-- 初始化连击动画
function BattleUILayer:initHitAni()    
    
    self._pHitNode = cc.Node:create()
    self._pHitNode:setVisible(false)
    self:addChild(self._pHitNode,10)

    self._pHitWords = cc.Sprite:createWithSpriteFrameName("hit/hitWords.png")
    self._pHitWords:setPosition(0,0)
    self._pHitNode:addChild(self._pHitWords)

    local fntFileName = "fnt_combo.fnt"
    self._pHitText = cc.LabelBMFont:create("", fntFileName)
    self._pHitText:setPosition(-110,20)
    self._pHitNode:addChild(self._pHitText)
    
    self._pHitNode:setPosition(mmo.VisibleRect:width() + 200, mmo.VisibleRect:height()/2)

end

-- 初始化剧情对话UI
function BattleUILayer:initTalksUI()    
    -- 初始化剧情对话背景框
    self._pTalkFrame = cc.Sprite:createWithSpriteFrameName("ccsComRes/talksFrame.png")
    self._pTalkFrame:setScaleX(1024/self._pTalkFrame:getContentSize().width)
    self._pTalkFrame:setAnchorPoint(0.5,0.01)
    self._pTalkFrame:setPosition(mmo.VisibleRect:bottom())
    self._pTalkFrame:setVisible(false)    
    self:addChild(self._pTalkFrame,20)
    -- 初始化剧情对话箭头
    self._pTalkArrow = cc.Sprite:createWithSpriteFrameName("ccsComRes/talksArrow.png")
    self._pTalkArrow:setAnchorPoint(0.5,0)
    self._pTalkArrow:setPosition(self._pTalkFrame:getPositionX()+512-100,0)
    self._pTalkArrow:setVisible(false)  
    self:addChild(self._pTalkArrow,20)
    self._pTalkArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.EaseSineInOut:create(cc.MoveBy:create(0.3,cc.p(0,30))),cc.EaseSineInOut:create(cc.MoveBy:create(0.3,cc.p(0,-30))))))
    -- 初始化剧情对话文本区域
    self._pTalkTextArea = cc.Label:createWithTTF("", strCommonFontName, 24, cc.size(600, 150), cc.TEXT_ALIGNMENT_LEFT)
    self._pTalkTextArea:setPosition(cc.p((mmo.VisibleRect:width()-600)/2, (self._pTalkFrame:getContentSize().height - 150)/2))
    self._pTalkTextArea:setAnchorPoint(cc.p(0, 0))
    self._pTalkTextArea:setVisible(false) 
    --self._pTalkTextArea:enableShadow(cc.c4b(0, 0, 0, 255))
    self:addChild(self._pTalkTextArea,20)
    
    self._pTalkArrow:setPositionZ(4100)
    self._pTalkFrame:setPositionZ(4100)
    self._pTalkTextArea:setPositionZ(4100)
    
end

-- 处理控件逻辑
function BattleUILayer:disposeWidgets()    
    local function onAutoBattleButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            if tag == 100 then  -- 点击自动按钮
                print("当前为手动战斗状态！")
                self:getBattleManager():toUnAutoBattle()
            elseif tag == 101 then  -- 点击手动按钮
                print("当前为自动战斗状态！")
                self:getBattleManager():toAutoBattle()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pAutoBattleButton:setTag(100)
    self._pUnAutoBattleButton:setTag(101)
    self._pAutoBattleButton:addTouchEventListener(onAutoBattleButton)
    self._pUnAutoBattleButton:addTouchEventListener(onAutoBattleButton)
    
    local function onExitBattleButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("onExitBattleButton")
            local forceExit = function()
                BattleManager:getInstance():exitBattle()
            end
            showConfirmDialog("确定退出战斗？" , forceExit)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pExitBattleButton:addTouchEventListener(onExitBattleButton)
    
    -- 怒气技能
    local function onHeaderAngerButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("onHeaderAngerButton")
            if self:getRolesManager()._pMainPlayerRole._nCurAnger >= self:getRolesManager()._pMainPlayerRole._nAngerMax then
                self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kAngerAttack, true)
            end
        end
    end
    self._pHeaderAngerButton:addTouchEventListener(onHeaderAngerButton)
    
    ------------------------------------------------- 普通攻击按钮 -----------------------------------------
    local function onGenAttackButton(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self._fTouchingCounter = 0          -- 等待开始计时
        elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
            self._fTouchingCounter = -1         -- 置回-1，停止计时
            if self:getRolesManager()._pMainPlayerRole then
                if self:getRolesManager()._pMainPlayerRole:isUnusualState() == false then
                    self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kGenAttack, true)
                end
            end
        end
    end
    self._pGenAttackButton:addTouchEventListener(onGenAttackButton)
    ------------------------------------------------------------------------------------------------------------
    
    local function onTestButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            MonstersManager:getInstance():debugCurWaveMonstersAllDead()
            if RolesManager:getInstance()._pMainPlayerRole then
                RolesManager:getInstance()._pMainPlayerRole:resetSpeed()
                RolesManager:getInstance()._pMainPlayerRole:setCurSpeedPercent(2)
            end
            if RolesManager:getInstance()._pPvpPlayerRole then
                RolesManager:getInstance()._pPvpPlayerRole._nCurHp = 0
                RolesManager:getInstance()._pPvpPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kDead, true, {})
            end
            
            --BattleManager:getInstance():pauseTime()
            --PetsManager:getInstance()._pMainPetRole:setHp(700,2000)

            --MonstersManager:getInstance()._pBoss:setHp(0,MonstersManager:getInstance()._pBoss._nHpMax)
            --MonstersManager:getInstance()._pBoss:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDead, true, {})

            --self:getBattleManager():startTime()
            
            --self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kBeaten, true, {self:getRolesManager()._pMainPlayerRole._tSkills[2], 5})
            
            --self:getRolesManager()._pMainPlayerRole:beHurtedBySkill(self:getRolesManager()._pMainPlayerRole._tSkills[2],cc.rect(0,0,0,0))

            --self:getMapManager()._pSplashSky:stopAllActions()
            --self:getMapManager()._pSplashSky:runAction(cc.Sequence:create(cc.FadeIn:create(0),cc.FadeOut:create(0.2)))
            
            --if self:getPetsManager()._pMainPetRole then
               -- self:getPetsManager()._pMainPetRole:addBuffByID(4)
                --self:getPetsManager()._pMainPetRole:loseHp(55550)
                --self:getPetsManager()._pMainPetRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kDead, true)
            --end
            
            --self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleHpLimitUpBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[12]))  -- 加入<增加血量上限>状态到控制机
            
            --local posX, posY = RolesManager:getInstance()._pMainPlayerRole:getPosition()
            --self:getMapManager():moveMapCameraByPos(1, 0.5, cc.p(posX,posY), 0.5, 0.4,nil,false)
            
            --self:getRolesManager()._pMainPlayerRole:clearAnger()
            
            --self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleClearAndImmuneBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[13]))  -- 加入异常免疫状态到控制机
            --self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleFireBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[1]))  -- 加入灼烧状态到控制机
            --self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleColdBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[2]))  -- 加入寒冷状态到控制机
            --self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleThunderBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[3]))  -- 加入雷击状态到控制机
            --self:getRolesManager()._pMainPlayerRole:addBuffByID(4)  -- 加入破甲状态到控制机
            
            --aaa = aaa + 1
            --local result = aaa%16
            --[[
            if result == 0 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleFireBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[1]))  -- 加入灼烧状态到控制机
            elseif result == 1 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleColdBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[2]))  -- 加入寒冷状态到控制机
            elseif result == 2 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleThunderBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[3]))  -- 加入雷击状态到控制机
            elseif result == 3 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleDizzyBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[4]))  -- 加入眩晕状态到控制机
            elseif result == 4 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattlePoisonBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[5]))  -- 加入中毒状态到控制机
            elseif result == 5 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleAddHpBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[6]))  -- 加入持续加血状态到控制机
            elseif result == 6 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleGodBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[7]))  -- 加入无敌状态到控制机
            elseif result == 7 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleGhostBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[8]))  -- 加入虚影状态到控制机
            elseif result == 8 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleAttriUpBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[9]))  -- 加入属性增益状态到控制机
            elseif result == 9 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleAttriDownBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[10]))  -- 加入属性增益状态到控制机
            elseif result == 10 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleSpeedDownBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[11]))  -- 加入减速状态到控制机
            elseif result == 11 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleHpLimitUpBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[12]))  -- 加入<增加血量上限>状态到控制机
            elseif result == 12 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleRigidBodyBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[14]))  -- 加入钢体状态到控制机
            elseif result == 13 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleFightBackFireBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[15]))  -- 加入反击-火状态到控制机                
            elseif result == 14 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleFightBackIceBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[16]))  -- 加入反击-冰状态到控制机
            elseif result == 15 then
                self:getRolesManager()._pMainPlayerRole:getBuffControllerMachine():addController(require("BattleFightBackThunderBuffController"):create(self:getRolesManager()._pMainPlayerRole, TableBuff[17]))  -- 加入反击-雷状态到控制机            
            end
            ]]
        end
    end
    self._pTestButton:addTouchEventListener(onTestButton)
    --self._pTestButton:setVisible(false)
    
    return
end

-- 初始化触摸
function BattleUILayer:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        self._pCursor:stopAllActions()
        self._pCursor:setVisible(true)
        self._pCursor:setOpacity(255)
        self._pCursor:setScale(0.1)
        self._pCursor:setRotation(0)
        self._pCursor:runAction(cc.Spawn:create(cc.FadeOut:create(0.5),cc.ScaleTo:create(0.5,1.0),cc.RotateBy:create(0.5,90)))
        self._pCursor:setPosition(location.x, location.y)
        if self._pStick:getIsWorking() == true then
            return false
        end
        if self._pTalkFrame:isVisible() == true then
            self._bTalkTouchStart = true
            return true
        end
        if self:getRolesManager()._pMainPlayerRole and self._pStick:onTouchBegan(location) == true then
            return true
        end
        return false
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        if self._pTalkFrame:isVisible() == true then
            return
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
        self._pStick:onTouchEnded(location)
    end
    local function onTouchCancelled(touch,event)
        local location = touch:getLocation()
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
    
    return
end

-- 摇杆更新逻辑
function BattleUILayer:procStick(dt)
    -- 如果当前存在剧情框，则直接返回，暂不做结算处理
    if TalksManager:getInstance():isShowingTalks() == true then
        return
    end
    if MapManager:getInstance()._bIsCameraMoving == true then
        return
    end
    if self._pStick:needUpdate() == true then
        local pRole = self:getRolesManager()._pMainPlayerRole
        if pRole then            
            if self._bStickDisabled == true then
                return
            end
            if self._pStick:getDirection() ~= -1 then  -- 正在move摇杆
                self._pStick:setIsWorking(true)  -- 设置摇杆正在工作
                -- 当前已经为跑步状态
                if pRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID == kType.kState.kBattlePlayerRole.kRun then
                    pRole:setAngle3D(self._pStick:getAngle())
                    if self._pStick:getDirection() ~= pRole._kDirection then
                        pRole._kDirection = self._pStick:getDirection()
                    end
                else  -- 当前非跑步状态 
                    -- 只有当主角出于站立状态时，才会切换到跑步状态，否则只会产生转向作用
                    if pRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID == kType.kState.kBattlePlayerRole.kStand then
                        if pRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._fWaitCounter >= fRoleStandWaitDelay then
                            pRole._kDirection = self._pStick:getDirection()
                            pRole:setAngle3D(self._pStick:getAngle())
                            pRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kRun)
                            if NewbieManager:getInstance()._bSkipGuide == false then
                                if NewbieManager:getInstance()._nCurID == "Guide_1_1" then
                                    NewbieManager:getInstance():showOutAndRemoveWithRunTime()
                                    self._bStickDisabled = false  -- 恢复摇杆
                                end
                            end
                        end
                        
                    end

                end
            else  -- 摇杆结束
                self._pStick:setIsWorking(false)   -- 设置摇杆不在工作
            end
        end
    else
        self._pStick:setIsWorking(false)   -- 设置摇杆不在工作
    end
end

-- 显示连击动画
function BattleUILayer:showHitAni()
    
    -- 连击计数中断所需的时间
    local time = TableConstants.ComboBreakTime.Value

    local showOver = function()
        self._nHitNum = 0
    end

    self._nHitNum = self._nHitNum + 1
    self._pHitText:setString(tostring(self._nHitNum))
    if self._pHitNode:isVisible() == false then
        self._pHitNode:setScaleY(0)
    end
    self._pHitNode:stopAllActions()
    self._pHitNode:setPosition(mmo.VisibleRect:width() - 100, mmo.VisibleRect:height()/2) 
    self._pHitNode:runAction(
        cc.Sequence:create(cc.Show:create(), 
                           cc.EaseSineIn:create(cc.ScaleTo:create(0.1,1.5,1.5)), 
                           cc.EaseSineIn:create(cc.ScaleTo:create(0.1,1,1)),
                           cc.DelayTime:create(time),
                           cc.EaseSineIn:create(cc.ScaleTo:create(0.1, 1.0,0)), 
                           cc.Hide:create(),
                           cc.CallFunc:create(showOver) )
                             )
end

-- 取消连击动画
function BattleUILayer:hideHitAni()
    self._nHitNum = 0
    self._pHitText:setString("")
    self._pHitNode:stopAllActions()
    self._pHitNode:setVisible(false)
end

-- 播放怒气特效
function BattleUILayer:playAngerEffect()
    self:stopAngerEffect()
    
    local act1 = cc.CSLoader:createTimeline("AngerUIEffect1.csb")
    act1:gotoFrameAndPlay(0,act1:getDuration(),false)
    self._pPlayerAngerEffectAni[1]:runAction(act1)
    local time = (act1:getEndFrame() - act1:getStartFrame())*cc.Director:getInstance():getAnimationInterval()
    local timeSpeed = act1:getTimeSpeed()
    time = time * (1/timeSpeed)
    self._pPlayerAngerEffectAni[1]:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(time),cc.Hide:create()))
    
    local act2 = cc.CSLoader:createTimeline("AngerUIEffect2.csb")
    act2:gotoFrameAndPlay(0,act2:getDuration(),true)
    self._pPlayerAngerEffectAni[2]:runAction(cc.Show:create())
    self._pPlayerAngerEffectAni[2]:runAction(act2)
    
    local act3 = cc.CSLoader:createTimeline("AngerUIEffect3.csb")
    act3:gotoFrameAndPlay(0,act3:getDuration(),true)
    self._pPlayerAngerEffectAni[3]:runAction(cc.Show:create())
    self._pPlayerAngerEffectAni[3]:runAction(act3)

    self._bIsShowingAngerEffect = true
end

-- 停止怒气特效
function BattleUILayer:stopAngerEffect()
    for k, v in pairs(self._pPlayerAngerEffectAni) do 
        v:stopAllActions()
        v:setVisible(false)
    end
    self._bIsShowingAngerEffect = false
end

-- 移除当前对话的头像集合
function BattleUILayer:removeCurTalkHeaders()
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
end

-- 创建指定的对话的头像集合
function BattleUILayer:createTalkHeaders(talkID)
    local tContents = TableTalks[talkID].Contents
    for kInfo, vInfo in pairs(tContents) do
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
                    end
                    if pWeaponLC3bName then
                        local pWeaponL = cc.Sprite3D:create(pWeaponLC3bName)
                        pWeaponL:setTexture(pWeaponTextureName)
                        pWeaponL:setScale(tWeaponTempleteInfo.ModelScale2)
                        local animation = cc.Animation3D:create(pWeaponLC3bName)
                        local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
                        pWeaponL:runAction(act)
                        pAni:getAttachNode("boneLeftHandAttach"):addChild(pWeaponL)
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
        pAni:setPositionZ(4000)
        table.insert(self._tTalkHeaders, pAni)
    end

end

-- 显示对话信息
function BattleUILayer:showCurTalks()
    -- 全部显示完毕
    if self:getTalksManager()._nCurTalkStep + 1 > table.getn(self:getTalksManager()._tCurContents) then
        self._pTalkFrame:setVisible(false)
        self._pTalkArrow:setVisible(false)
        self._pTalkTextArea:setVisible(false)
        for k,v in pairs(self._tTalkHeaders) do 
            v:setVisible(false)
        end
        self:getTalksManager():setCurTalksFinished()
        return
    end

    self._pTalkFrame:setVisible(true)
    self._pTalkArrow:setVisible(true)
    self._pTalkTextArea:setVisible(true)
    for k,v in pairs(self._tTalkHeaders) do 
        v:setVisible(false)
    end
    self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setVisible(true)
    if self:getTalksManager()._tCurContents[self:getTalksManager()._nCurTalkStep + 1].posType == 1 then -- 左
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setPosition(self._pTalkFrame:getPositionX()-512 + 130,0)
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setRotation3D(cc.vec3(0,45,0))
    elseif self:getTalksManager()._tCurContents[self:getTalksManager()._nCurTalkStep + 1].posType == 2 then -- 右
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setPosition(self._pTalkFrame:getPositionX()+512 - 130,0)
        self._tTalkHeaders[self:getTalksManager()._nCurTalkStep + 1]:setRotation3D(cc.vec3(0,-45,0))
    end

    self._pTalkTextArea:setString(self:getTalksManager()._tCurContents[self:getTalksManager()._nCurTalkStep + 1].words)
    self:getTalksManager()._nCurTalkStep = self:getTalksManager()._nCurTalkStep + 1

end

function BattleUILayer:setAllUIVisible(visible)
    self._pStick:setVisible(visible)
    self._pPanelCCS:setVisible(visible)
    self._pPlayerHpBG:setVisible(visible)
    self._pPlayerAngerBar:setVisible(visible)
    self._pPlayerBuffIconsNode:setVisible(visible)
    self._pBossBuffIconsNode:setVisible(visible)
    if self._pChatPanelCCS then 
       self._pChatPanelCCS:setVisible(visible)
    end
    
    
    if self._pPetNode then
        self._pPetNode:setVisible(visible)
    end
    
    if self:getMonstersManager()._pBoss and self:getMonstersManager()._pBoss:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID ~= kType.kState.kBattleMonster.kSuspend then
        self._pBossHpBG:setVisible(visible)
    elseif self:getRolesManager()._pPvpPlayerRole then 
        self._pBossHpBG:setVisible(visible)
    end
    
    for k,v in pairs(self._pSkillAttackButtons) do
        v:setVisible(visible)
    end
end

--初始化爬塔副本的右侧说明 仅爬塔副本用
function BattleUILayer:initTowerCopyExplain()
   if  StagesManager:getInstance()._nCurCopyType == kType.kCopy.kTower then
        local tTowerCopysInfo =  StagesManager:getInstance():getCurStageDataInfo()
        local pScrollViewInfo = getBoxInfo(tTowerCopysInfo.MustDropItem)
        local tTowerChapterInfo = TableTowerChapter[tTowerCopysInfo.Chapter].TheCopys
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr("TowerBattlePanel")
        local params = require("TowerBattlePanelParams"):create()   
        local pTowerCopysExplainPanel =  params._pCCS               --爬塔副本的palel
        local pBackGround = params._pBackGround                     --背景框
        local pTowerFntTitle = params._pChapterFnt                  --当前的层数 title
        local pTowerCurChapter = params._pText_3                    --x/x 当前的层数
        local pTowerMaxChapter = params._pText_4                    --x/x 总层数
        local pTowerGetScrollView = params._pGetItemsScrollView     --可以获得的ScrollView
        pTowerFntTitle:setString(tTowerCopysInfo.SortNumber)
        pTowerCurChapter:setString(tTowerCopysInfo.SortNumber)
        pTowerMaxChapter:setString("/"..table.getn(tTowerChapterInfo))
        
        --设置ScrollView数据
        pTowerGetScrollView:removeAllChildren(true)
        local sScreen = mmo.VisibleRect:getVisibleSize()
        local sBgSize= pBackGround:getContentSize()

        local nUpAndDownDis = 5                             --装备上下与框的间隔
        local nLeftAndReightDis = 4                         --装备左右与框的间隔
        local nSize = 50                                   --每个cell的宽度和高度
        local nStartx = 0
        local nNum =table.getn(pScrollViewInfo)
        local nViewWidth  = pTowerGetScrollView:getContentSize().width
        local nViewHeight  = pTowerGetScrollView:getContentSize().height
        local pScrInnerWidth = (nViewWidth >(nLeftAndReightDis+nSize)*nNum) and nViewWidth or (nLeftAndReightDis+nSize)*nNum
        pTowerGetScrollView:setInnerContainerSize(cc.size(pScrInnerWidth,nViewHeight))
        for i=1,nNum do
            local pDateInfo = pScrollViewInfo[i]
            local pCell =  require("BattleItemCell"):create()
            pCell:setScale(0.5)
            local nX = (i-1)*(nSize+nLeftAndReightDis)+nStartx
            local nY = (nViewHeight-nSize)/2
            pCell:setPosition(nX,nY)

            if pDateInfo.finance then --是货币
                pCell:setFinanceInfo(pScrollViewInfo[i])
            else
                pCell:setItemInfo(pScrollViewInfo[i])
            end
            pCell:setTouchEnabled(false)
            pTowerGetScrollView:addChild(pCell)
        end 
        
        pTowerCopysExplainPanel:setPosition(cc.p(sScreen.width-sBgSize.width/2,sScreen.height/2))
        self:addChild(pTowerCopysExplainPanel)
   end	
end

--爬塔副本创建倒计时数字
function BattleUILayer:playTowerAfterCdAction(func)

    local nX = mmo.VisibleRect:getVisibleSize().width/2
    local nY = mmo.VisibleRect:getVisibleSize().height/2
    local nCdNum = TableConstants.AfterTowerCD.Value

    --cd的背景
    local pTowerCdBg = cc.Sprite:createWithSpriteFrameName("ccsComRes/pmd.png")
    pTowerCdBg:setPosition(cc.p(nX-200,nY+220))
    pTowerCdBg:setOpacity(0)
    self:addChild(pTowerCdBg,3)
    self._pTowerCdBg = pTowerCdBg

    local pBgWidth = pTowerCdBg:getContentSize().width
    local pBgHeight = pTowerCdBg:getContentSize().height

    --进入下一层的图片
    local pNextImage = cc.Sprite:createWithSpriteFrameName("TowerBattlePanel/TowerNextText.png")
    pNextImage:setPosition(cc.p(pBgWidth/2-pNextImage:getContentSize().width/2,pBgHeight/2))
    pNextImage:setOpacity(0)
    pTowerCdBg:addChild(pNextImage)

    self._pTowerCdText = cc.Label:createWithBMFont("fnt_002.fnt",nCdNum)
    self._pTowerCdText:setAnchorPoint(cc.p(0.5, 0.5))
    self._pTowerCdText:setPosition(cc.p(pBgWidth/2+30,pBgHeight/2+120))
    self._pTowerCdText:setOpacity(0)
    pTowerCdBg:addChild(self._pTowerCdText)

    local addActiconCallBack = function()
        if nCdNum == 1 then
            func()
        end
        self._pTowerCdText:setString(nCdNum)
        nCdNum = nCdNum -1
    end
    local seq = cc.Sequence:create(cc.DelayTime:create(0.6)
        ,cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(0.10,cc.p(pBgWidth/2+30,pBgHeight/2)),6),cc.FadeIn:create(0.10))
        ,cc.CallFunc:create(addActiconCallBack)
        ,cc.EaseIn:create(cc.ScaleTo:create(0.2,1.9),6),cc.ScaleTo:create(0.05,1),cc.DelayTime:create(0.1)
        ,cc.Spawn:create(cc.MoveTo:create(0.1,cc.p(pBgWidth/2+30,pBgHeight/2+120)),cc.FadeOut:create(0.1)))
    local action = cc.Repeat:create(seq, nCdNum)


    
    local bgActionOverCallBack = function()
        pNextImage:setOpacity(255)
    end
    pTowerCdBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(0.10,cc.p(nX,nY+220)),6),cc.FadeIn:create(0.10)),cc.CallFunc:create(bgActionOverCallBack)))
    self._pTowerCdText:runAction(action)
    --播放倒计时，隐藏退出战斗按钮
    self._pExitBattleButton:setVisible(false)
end

--爬塔副本设置cd的text是否显示
function BattleUILayer:setTowerCdTextVisible(bBool)
    if self._pTowerCdText ~= nil and bBool == false then
        self._pTowerCdText:stopAllActions()
         self._pTowerCdBg:setVisible(false)
    end
end


--聊天按钮回调
function BattleUILayer:createChatFunc()
    if TasksManager:getInstance()._pMainTaskInfo ~= nil and TasksManager:getInstance()._pMainTaskInfo.taskId < 10007 then
    	return 
    end

    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self._tNewMessage = {} --清空外面的提示队列
            DialogManager:getInstance():showDialog("ChatDialog")
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    --聊天按钮是否开启
    self._bHasVisChatBtn = true
    if self._bHasVisChatBtn then
        --聊天的界面
        local pChatParams = require("ChatOutsideParams"):create() 
        self._pChatPanelCCS = pChatParams._pCCS 
        self._pChatOutsideBg = pChatParams._pBackGround
        self._pChatButton = pChatParams._pChat  --聊天button
        self._pChatNotice = pChatParams._pNotice --聊天新提示
        --设置聊天按钮在屏幕左方
        self._pChatPanelCCS:setPosition(cc.p(mmo.VisibleRect:width()/2-300,60))
        self:addChild(self._pChatPanelCCS)
        self._pChatButton:addTouchEventListener(onTouchButton)
    
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
    
    --语音按钮是否开启 只是在组队界面用
    if not self._bHasVisChatBtn then 
        --语音button
        self._pVoiceBtn = ccui.Button:create("ChatOutsideRes/ltjm14.png","ChatOutsideRes/ltjm13.png",nil,ccui.TextureResType.plistType)
        self._pVoiceBtn:setTouchEnabled(true)
        self._pVoiceBtn:setPosition(mmo.VisibleRect:width()/2,120)
        self:addChild(self._pVoiceBtn)
        --语音的初始化跟设置
        self:setVoiceBtnInfo()
    end
    
      
end



---------------------------------组队语音相关功能----------------------------
--语音的初始化跟设置
function BattleUILayer:setVoiceBtnInfo()

	--录音的动画
    self._pVoiceAniNode = cc.CSLoader:createNode("SpeekingEffect.csb")
    self._pVoiceAniNode:setPosition(mmo.VisibleRect:center())
    self._pVoiceAniNode:setVisible(false)
    self:addChild( self._pVoiceAniNode)
    --倒计时
    self._pdaojishi = self._pVoiceAniNode:getChildByName("Time")
    self._pdaojishi:setString(0)
    
    

    local pBeginPosY = nil
    local onTouchVoiceButton = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then      -- 按下录音
           AudioManager:getInstance():playEffect("ButtonClick")
            if self._pButtonCdTime > 0 then
                NoticeManager:getInstance():showSystemMessage("点击太频繁，稍后重试")
                return
            end
            local bBool,nTime = ChatManager:getInstance():isCanSendMessage(kChatType.kTeam)
            if bBool then 
                pBeginPosY = sender:getTouchBeganPosition().y
                self._bVoiceBtnDown = true
                self:playVoiceAni() --播放动画
                mmo.HelpFunc:pressRecordVoice()

            else --正在cd
                NoticeManager:getInstance():showSystemMessage("还需要"..nTime.."秒才能在组队发言")
            end
  
      elseif eventType == ccui.TouchEventType.moved then
            local pPosY = sender:getTouchMovePosition().y
            if pPosY and pBeginPosY and pPosY - pBeginPosY > 150 and self._bVoiceBtnDown then
                self._bVoiceBtnDown = false --移动超过距离，取消语音
                self:stopVoiceAni() --停止动画
                mmo.HelpFunc:cancelSendVoice()
                NoticeManager:getInstance():showSystemMessage("取消成功")
             end
         
        elseif eventType == ccui.TouchEventType.ended then     -- 抬起发送
        
            if self._bVoiceBtnDown == true then --如果还没有发送
                self._bVoiceBtnDown = false
                self:stopVoiceAni() --停止动画
               
                if  self._nVoiceCdTime <= TableConstants.SpeechMin.Value then 
                    NoticeManager:getInstance():showSystemMessage("语音过短，发送失败！")
                    mmo.HelpFunc:cancelSendVoice()
                else
                    mmo.HelpFunc:releaseSendVoice()
                end
                if self._pButtonCdTime == 0 then
                    self._pButtonCdTime = self._nButtonCd
                end
            end
        
        elseif eventType == ccui.TouchEventType.canceled then  --取消
            if self._bVoiceBtnDown == true then --如果还没有发送
                self._bVoiceBtnDown = false
                self:stopVoiceAni() --停止动画
                mmo.HelpFunc:releaseSendVoice()
            end
        end
    end
    
    self._pVoiceBtn:addTouchEventListener(onTouchVoiceButton)        

end

--播放录音动画
function BattleUILayer:playVoiceAni()
    self._pVoiceAniNode:setVisible(true)
    self._pdaojishi:setString(0)
    local pVoiceiAction = cc.CSLoader:createTimeline("SpeekingEffect.csb")
    pVoiceiAction:gotoFrameAndPlay(0,pVoiceiAction:getDuration(), true)
    self._pVoiceAniNode:stopAllActions()
    self._pVoiceAniNode:runAction(pVoiceiAction)

    local nMaxTime = TableConstants.SpeechMax.Value
    local timeCallBack = function(time,id)
        self._pdaojishi:setString(nMaxTime -time) 
        self._nVoiceCdTime = nMaxTime -time
        if time == 0 then
            self:stopVoiceAni() --停止动画
            
        end
    end

    CDManager:getInstance():insertCD({cdType.kChatVoiceTime,nMaxTime,timeCallBack})

end

--停止播放动画
function BattleUILayer:stopVoiceAni()
    self._pVoiceAniNode:setVisible(false)
    self._pVoiceAniNode:stopAllActions()
    CDManager:getInstance():deleteOneCdByKey(cdType.kChatVoiceTime)
end

-- 循环更新
function BattleUILayer:updateChatVoice(dt)
    -- 放到循环中进行监控，把得到的语音id和时长发给服务器
    local id = mmo.DataHelper:getLastVoiceId()
    if id ~= "" then
       print("hahaha:"..id)
    end

    local duration = mmo.DataHelper:getLastVoiceDuration()
    if duration ~= 0 then
        print("bababa:"..duration)
        self:sendMessage(kContentType.kVoice,id,duration)
    end  
    
    local isOver = mmo.DataHelper:getPlayVoiceOver()
    if isOver == true and self._bHasVisChatBtn == false then --如果有播放完毕
        self:playTeamVoice()
    end
    if self._pButtonCdTime > 0 then
        self._pButtonCdTime =  self._pButtonCdTime - dt
        if self._pButtonCdTime <= 0 then
            self._pButtonCdTime = 0
        end
    end
    
    return
end

--发送聊天信息(聊天类型，聊天内容，语音聊天长度)
function BattleUILayer:sendMessage(nContentType,pText,nLength)

    -- 对方id
    local pdesRoleId =0
    local bUesHorn = false
    --聊天频道
    local pChatType = kChatType.kTeam
    --内容类型
    local pContentType = nContentType
    local pText = "{'"..pText.."','"..nLength.."'}"
    local args = {pdesRoleId,bUesHorn,pChatType,pContentType,pText}
    ChatCGMessage:sendMessageChat21302(args)

end

--语音组队的提示
function BattleUILayer:BattleChatTeamVoice(event)
    --如果聊天按钮没有 且打开了组队自动播放
    if self._bHasVisChatBtn == false then -- and ChatManager:getInstance()._tAutoPlayVoice[3] == true then
        local pMyRoleId = RolesManager:getInstance()._pMainRoleInfo.roleId
         for k,v in pairs(event) do
            --聊天数据是团队聊天，类型是语音，而且不是自己，播放语音
            if v.chatType == kChatType.kTeam and v.contentType == kContentType.kVoice then -- and pMyRoleId ~= v.roleId  then
                table.insert(self._tTeamVoiceMessage,v)
            end   
         end
    end
    if self._bTeamVoiceHasPlay == false and table.getn(self._tTeamVoiceMessage) >0 then --如果聊天提示框没有打开
        self._bTeamVoiceHasPlay = true
        self:playTeamVoice()
    end

end


--播放团队语音
function BattleUILayer:playTeamVoice()

    if table.getn(self._tTeamVoiceMessage) ~= 0 then 
        local pPlayId =  StrToLua(self._tTeamVoiceMessage[1].content)[1]
         table.insert(ChatManager:getInstance()._tAutoPlayTeamId,pPlayId)    
         mmo.HelpFunc:playVoice(pPlayId)
        table.remove(self._tTeamVoiceMessage,1)
    else
        local pPlaySize = table.getn(ChatManager:getInstance()._tAutoPlayTeamId)
        local pTeamUnReadSize = ChatManager:getInstance():getUnReadNumByType(kChatType.kTeam)
        if  pPlaySize == pTeamUnReadSize  then --如果播放的跟已读的一样那么说明组队语音全部播放完毕，不显示有未读消息
        	ChatManager:getInstance()._tNewMessage[kChatType.kTeam] = false
        end
        self._bTeamVoiceHasPlay = false
    end

end
-------------------------------------------------------------

-- 设置摇杆锁定
function BattleUILayer:handleStickLocked(event)
    if self._pStick ~= nil then
        self._pStick:setLocked(event.locked)  
    end
end


------------------------聊天按钮相关功能---------------------------

--外面的聊天按钮提示
function BattleUILayer:updateChatNotice(dt)
    local pState = ChatManager:getInstance():isHasNewMessage()
    if self._pChatNotice then 
       self._pChatNotice:setVisible(pState) 
    end
    if not self._bHasVisChatBtn then --如果有聊天按钮，语音播放按钮隐藏不做语音监控
       self:updateChatVoice(dt)
    end
end

--聊天框的通知
function BattleUILayer:homeChatOutSide(event)
    if self._bHasVisChatBtn then   --是否有聊天按钮
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
end

--打开聊天提示框
function BattleUILayer:openChatOutSize()
   self._pChatOutsideBg:setVisible(true)
   
   local pInfo = self._tNewMessage[1]
   local pContent = ": "..StrToLua(pInfo.content)[1].."   ("..os.date("%X",pInfo.timestamp)..")"
   self._pChatElementText:refresh(nil,nil,pInfo.name,nil,pContent)
  
    local actionCallBack = function()
        table.remove(self._tNewMessage,1)
        if table.getn(self._tNewMessage) ~= 0 then
            self:openChatOutSize()
        else
            self:CloseChatOutSize()
        end
    end

   self._pChatOutsideBg:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(actionCallBack)))
  
end
--关闭聊天提示框
function BattleUILayer:CloseChatOutSize()
     self._tOutSideIsVis = false
     self._pChatOutsideBg:setVisible(false)
     
end

--跑马灯通知
function BattleUILayer:marqueeEvent(event)
    NoticeManager:insertMarqueeMessage(event)
end
--更新人物信息
function BattleUILayer:updateRoleInfo()
    self._pLevLabel:setString("Lv"..self:getRolesManager()._pMainPlayerRole._pRoleInfo.level)
end


--按照打怪的的个数来评星
function BattleUILayer:initResultByGrade()
    --如果是金钱副本 材料副本 按照评分来评星
    if  StagesManager:getInstance()._nCurCopyType == kType.kCopy.kGold 
     or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kStuff then
        self._pResultByGradeNode = require("ResultByGrade"):create({kResultType.kGreadResult,1})
        self._pResultByGradeNode:setPosition(mmo.VisibleRect:width()/2 + 120, -25)
		self._pTimeNode:addChild(self._pResultByGradeNode)
	end
	
end

-- 按照战斗的时长来评星
-- 以时间为结算的副本包括：挑战副本 剧情副本 迷宫副本 地图boss
function BattleUILayer:initTimeCountDownResultNode()
    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kChallenge
        or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kStory
        or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kMaze
        or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kMapBoss then 
        self._pTimeCountDownNode = require("TimeCountDownBattleLevelLayer"):create()
        self._pTimeCountDownNode:setPosition(mmo.VisibleRect:width()/2 + 120, -25)
        self._pTimeNode:addChild(self._pTimeCountDownNode) 
    end
    
end

-- 金钱副本中已获得金币数量相关UI
function BattleUILayer:initGoldDropNode()
    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kGold then
        self._pGoldDropNode = require("GoldDropNode"):create()
        self._pGoldDropNode:setScale(0.5)
        self._pGoldDropNode:setPosition(mmo.VisibleRect:width()/2-70, mmo.VisibleRect:height()-40)
        self:addChild(self._pGoldDropNode)
    end

end

return BattleUILayer
