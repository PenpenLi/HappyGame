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
    self._pMainPlayerUINode = nil               -- 主角UI
    self._pMainPetUINode = nil                  -- 主角宠物UI
    self._tOtherPlayerUINodes = {}              -- 其他玩家UI集合
    self._pBossHpNode = nil                     -- boss的UI
    self._pAngerSkillUINode = nil               -- 怒气技能节点
    self._pFuncUINode = nil                     -- 功能按钮节点（退出按钮+自动按钮）
    self._pStarUINode = nil                     -- 战斗评星
    self._pTimeUINode = nil                     -- 时间节点
    self._pHitNode = nil                        -- 连击特效结点
    self._pHitText = nil                        -- 连击数字Label
    self._pHitWords = nil                       -- 连击文字pic
    self._nHitNum = 0                           -- 连击数字
    self._pStick = nil                          -- 摇杆
    self._bStickDisabled = false                -- 摇杆是否失效
    self._pCursor = nil                         -- 触摸手标
    self._bIsShowingAngerEffect = false         -- 标记当前是否正在显示怒气UI特效
    
    self._pTestButton = nil                     -- 测试按钮
    self._pAutoBattleButton = nil               -- 自动战斗按钮（表示状态）
    self._pUnAutoBattleButton = nil             -- 手动战斗按钮（表示状态）
    self._pExitBattleButton = nil               -- 退出战斗按钮
    self._pGenAttackButton = nil                -- 普通攻击按钮
    self._pGenAttackButtonTable = nil           -- 普通按钮的连花边
    self._tSkillAttackButtons = {}              -- 技能按钮集合（左面是技能1，以此类推）
    self._pFriendSkillAttackButton = nil        -- 好友技能按钮
    self._pResonanceSkillAttackButton = nil     -- 共鸣技能按钮
    self._fTouchingCounter = -1                 -- 用于判定是否正在长按攻击按钮的计时器（-1时表示没有长按，且不计时，0时开始自动计时）
    self._bIsTouchingGenAttackButton = false    -- 是否正在长按攻击按钮
    
    self._pTalkFrame = nil                      -- 剧情对话背景框
    self._tTalkHeaders = {}                     -- 剧情对话头像，按照当前对话Contents数据中的角色顺序存放
    self._tTalkNames = {}                       -- 剧情对话头像的名称
    self._pTalkArrow = nil                      -- 剧情对话箭头
    self._pTalkArrowPlot = nil                  -- 剧情对话箭头底座
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
    self._bIsScoreByTime = false                -- 是否根据时间评分
    self._pGoldDropNode = nil                   -- 金钱副本中的已获得金币相关UI

    self._pBossAppearUIEffectAni = nil          -- BOSS出场时的UI警示特效

    self._bIsShowingCaptionContentAfterDoomsday = false   -- 是否正在显示末日后的对话内容

    
end

-- 创建函数
function BattleUILayer:create()
    local layer = BattleUILayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function BattleUILayer:dispose()
    ResPlistManager:getInstance():addSpriteFrames("SpeekingEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("ChatOutside.plist")
    NetRespManager:getInstance():addEventListener(kNetCmd.kChatOutSide,handler(self, self.homeChatOutSide))
    NetRespManager:getInstance():addEventListener(kNetCmd.kChatTeamVoice,handler(self, self.BattleChatTeamVoice))
    NetRespManager:getInstance():addEventListener(kNetCmd.kSetStickLocked,handler(self, self.handleStickLocked))
    NetRespManager:getInstance():addEventListener(kNetCmd.kDisPlayNotice ,handler(self, self.marqueeEvent)) --跑马灯公告通知
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateRoleInfo ,handler(self, self.updateRoleInfo)) --更新人物信息

    -- 初始化UI
    self:initUI()

    -- 初始化特效
    self:initEffects()
    
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
    --self:initResultByGrade()

    -- 初始化根据战斗时长评分xi
    self:initTimeCountDownResultNode()
    
    -- 初始化金钱副本中金币UI
    self:initGoldDropNode()

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnterBattleUILayer()
        elseif event == "exit" then
            self:onExitBattleUILayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 进入函数
function BattleUILayer:onEnterBattleUILayer()
    -- PVP和华山副本的时候需要有  VS特效
    self:initVSEffect()
    -- 判定自动还是非自动模式
    if self:getBattleManager()._bIsAutoBattle == true then
        self:getBattleManager():toAutoBattle()
    else
        self:getBattleManager():toUnAutoBattle()
    end
    -- 存在多人时，切换到自动战斗模式
    if table.getn(RolesManager:getInstance()._tOtherPlayerRoles) ~= 0 then
        self:getBattleManager():toAutoBattle()
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
            self._pTimeUINode:setVisible(false)
            self._pStarUINode:setVisible(false)
            self._pChatPanelCCS:setVisible(false)
            if self._pFriendSkillAttackButton then
               self._pFriendSkillAttackButton._pSkillBg:setVisible(false)
            end
            if self._pResonanceSkillAttackButton then
               self._pResonanceSkillAttackButton._pSkillBg:setVisible(false)
            end
        else
            NewbieManager:getInstance()._bIsForceGuideForBattle = false
        end
    end

end

-- 退出函数
function BattleUILayer:onExitBattleUILayer()
    self:onExitLayer()
    ResPlistManager:getInstance():removeSpriteFrames("ChatOutside.plist")
    ResPlistManager:getInstance():removeSpriteFrames("SpeekingEffect.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 处理控件逻辑
function BattleUILayer:disposeWidgets()
    ----------------------------------------- 自动战斗按钮 -----------------------------------------
    local function onAutoBattleButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == self._pAutoBattleButton then    -- 点击自动按钮
                print("当前为手动战斗状态！")
                self:getBattleManager():toUnAutoBattle()
            elseif sender == self._pUnAutoBattleButton then   -- 点击手动按钮
                print("当前为自动战斗状态！")
                self:getBattleManager():toAutoBattle()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pAutoBattleButton:addTouchEventListener(onAutoBattleButton)
    self._pUnAutoBattleButton:addTouchEventListener(onAutoBattleButton)
    
    ------------------------------------------ 退出战斗按钮 ------------------------------------------
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
    
    ----------------------------------------- 怒气技能按钮 -----------------------------------------------
    local function onAngerButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("onAngerButton")
            if self:getRolesManager()._pMainPlayerRole._nCurAnger >= self:getRolesManager()._pMainPlayerRole._nAngerMax then
                self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kAngerAttack, true)
            end
        end
    end
    self._pAngerSkillUINode._pAngerButton:addTouchEventListener(onAngerButton)
    
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

    -------------------------------------------------- 技能攻击按钮 ----------------------------------------
    local function skillAttack(skillType)
        if self:getRolesManager()._pMainPlayerRole then
            if self:getRolesManager()._pMainPlayerRole:isUnusualState() == false then
                if self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kSkillAttack and 
                   self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole)._pCurState._kTypeID ~= kType.kState.kBattlePlayerRole.kAngerAttack and 
                   self:getRolesManager()._pMainPlayerRole._tSkills[skillType]:getStateMachineByTypeID(kType.kStateMachine.kBattleSkill)._pCurState._kTypeID == kType.kState.kBattleSkill.kIdle then
                    self._tSkillAttackButtons[skillType-1]:resetCD()
                    self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kSkillAttack, true, skillType)
                    
                    if NewbieManager:getInstance()._bSkipGuide == false and NewbieManager:getInstance()._nCurID == "Guide_1_3" then
                        self._bStickDisabled = false        -- 恢复摇杆禁用
                        NewbieManager:getInstance():showOutAndRemoveWithRunTime()
                        -- 所有技能按钮出现
                        for k, v in pairs(self._tSkillAttackButtons) do
                           v:setVisible(true)
                        end
                    end
                                        
                end
            end
        end
    end
    for k,v in pairs(self._tSkillAttackButtons) do
        if v._bIsOpen == true then
            v:setCallfunc(skillAttack)
        end
    end

    ------------------------------------------------- 好友技能按钮 -----------------------------------------
    local function friendSkillCallBack(skillType)
        if skillType == "firendSkill" then
            if self:getSkillsManager()._pFriendSkill and self:getRolesManager()._pFriendRole:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole)._pCurState._kTypeID == kType.kState.kBattleFriendRole.kSuspend then
                self._pFriendSkillAttackButton:resetCD()
                self:getRolesManager()._pFriendRole:getStateMachineByTypeID(kType.kStateMachine.kBattleFriendRole):setCurStateByTypeID(kType.kState.kBattleFriendRole.kAppear)
            end
        end
    end
    if self._pFriendSkillAttackButton and self._pFriendSkillAttackButton._bIsOpen == true then
        self._pFriendSkillAttackButton:setCallfunc(friendSkillCallBack)
    end

    ------------------------------------------------- 宠物共鸣技能按钮 ---------------------------------------
    local function resonanceSkillCallBack(skillType)
        if skillType == "resonanceSkill" then
           self._pResonanceSkillAttackButton:resetCD()
           AIManager:getInstance():usePetCooperateSkillByCampType(kType.kCampType.kMain)  -- 使用宠物共鸣
        end
    end
    if self._pResonanceSkillAttackButton and self._pResonanceSkillAttackButton._bIsOpen == true then
        self._pResonanceSkillAttackButton:setCallfunc(resonanceSkillCallBack)
    end

    ------------------------------------------------- 测试按钮 --------------------------------------------
    local function onTestButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            --self._pStarUINode:addStar()
            --RolesManager:getInstance()._pMainPlayerRole:addAnger(5)
            --MonstersManager:getInstance()._pBoss:addBuffByID(7)
            --MonstersManager:getInstance()._pBoss:addBuffByID(8)
            --MonstersManager:getInstance()._pBoss:addBuffByID(9)
            --MonstersManager:getInstance()._pBoss:addBuffByID(4)
            --[[
            for k,v in pairs(RolesManager:getInstance()._tOtherPlayerRoles) do
                --v:addBuffByID(4)
                v:loseHp(999999)
                v:getStateMachineByTypeID(kType.kStateMachine.kBattleOtherPlayerRole):setCurStateByTypeID(kType.kState.kBattleOtherPlayerRole.kDead, true, {false})
            end
            ]]
            --self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kAngerAttack, true)
            MonstersManager:getInstance():debugCurWaveMonstersAllDead()

            --StoryGuideManager:getInstance():createStoryGuideById(1)

            --[[
            if RolesManager:getInstance()._pMainPlayerRole then
                RolesManager:getInstance()._pMainPlayerRole:addBuffByID(7)
                RolesManager:getInstance()._pMainPlayerRole:addBuffByID(8)
                RolesManager:getInstance()._pMainPlayerRole:addBuffByID(9)
                RolesManager:getInstance()._pMainPlayerRole:addBuffByID(4)
                RolesManager:getInstance()._pMainPlayerRole._nCurHp = 0
                RolesManager:getInstance()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kDead, true, {})
            end
            ]]
            --[[
            if RolesManager:getInstance()._pPvpPlayerRole then
                AIManager:getInstance():usePetCooperateSkillByCampType(kType.kCampType.kPvp)
            end
            ]]
            --[[
            for k,v in pairs(RolesManager:getInstance()._tOtherPlayerRoles) do
                AIManager:getInstance():usePetCooperateSkillByCampType(kType.kCampType.kOther,v)
            end
            ]]
            --MonstersManager:getInstance()._pBoss:playSkillEarlyWarningEffect(kType.kSkillEarlyWarning.kType4,{pos=cc.p(MonstersManager:getInstance()._pBoss:getPositionX(), MonstersManager:getInstance()._pBoss:getPositionY())})
            --BattleManager:getInstance():pauseTime()
            --PetsManager:getInstance()._pMainPetRole:setHp(700,2000)
            --MonstersManager:getInstance()._pBoss:setHp(0,MonstersManager:getInstance()._pBoss._nHpMax)
            --MonstersManager:getInstance()._pBoss:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster):setCurStateByTypeID(kType.kState.kBattleMonster.kDead, true, {})
            --self:getBattleManager():startTime()
            --self:getRolesManager()._pMainPlayerRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePlayerRole):setCurStateByTypeID(kType.kState.kBattlePlayerRole.kBeaten, true, {self:getRolesManager()._pMainPlayerRole._tSkills[2], 5})
            --self:getRolesManager()._pMainPlayerRole:beHurtedBySkill(self:getRolesManager()._pMainPlayerRole._tSkills[2],cc.rect(0,0,0,0))
            --self:getMapManager()._pSplashSky:stopAllActions()
            --self:getMapManager()._pSplashSky:runAction(cc.Sequence:create(cc.FadeIn:create(0),cc.FadeOut:create(0.2)))
            --if self:getPetsManager()._pPvpPetRole then
               -- self:getPetsManager()._pMainPetRole:addBuffByID(4)
                --self:getPetsManager()._pPvpPetRole:loseHp(999999999)
                --self:getPetsManager()._pPvpPetRole:getStateMachineByTypeID(kType.kStateMachine.kBattlePetRole):setCurStateByTypeID(kType.kState.kBattlePetRole.kDead, true, {false})
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
    
    return
end

-- 循环更新
function BattleUILayer:update(dt)
    if self._bIsShowingCaptionContentAfterDoomsday == true then
        if TalksManager:getInstance():isCurTalksFinished() == true then  -- 末日对话如果显示结束，则切回家园即可
            self:setVisible(false)
            RolesManager:getInstance()._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfoBakOfNewbie  -- 新手第一场战斗结束，恢复真实的角色信息
            LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
        end
    end
    if BattleManager:getInstance()._bIsTransforingFromEndBattle == true then
        return
    end
    -- 摇杆proc
    self:procStick(dt)
    -- 长按普通攻击按钮逻辑遍历proc
    self:procTouchingGenAttackButton(dt)
    -- 角色UI的更新逻辑proc
    if self._pMainPlayerUINode then
        self._pMainPlayerUINode:update(dt)
    end
    if self._pMainPetUINode then
        self._pMainPetUINode:update(dt)
    end
    if self._pBossHpNode then
        self._pBossHpNode:update(dt)
    end
    for k, v in pairs(self._tOtherPlayerUINodes) do
        v:update(dt)
    end
    -- 聊天通知更新proc
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
    -- 初始化主角UI
    local RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
    local headIconName = RoleIcons[RolesManager:getInstance()._pMainPlayerRole._pRoleInfo.roleCareer]
    local level = RolesManager:getInstance()._pMainPlayerRole._pRoleInfo.level
    local name = RolesManager:getInstance()._pMainPlayerRole._pRoleInfo.roleName
    local hp = RolesManager:getInstance()._pMainPlayerRole._nHpMax
    self._pMainPlayerUINode = require("FightRoleUINode"):create(1,headIconName,level,name,hp)
    self._pMainPlayerUINode:setPosition(cc.p(70,698))
    self:addChild(self._pMainPlayerUINode)

    -- 其他玩家头像和血条
    for k,v in pairs(RolesManager:getInstance()._tOtherPlayerRoles) do
        local RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
        local headIconName = RoleIcons[v._pRoleInfo.roleCareer]
        local level = v._pRoleInfo.level
        local name = v._pRoleInfo.roleName
        local hp = v._nHpMax
        local otherPlayerUINode = require("FightRoleUINode"):create(3,headIconName,level,name,hp)
        otherPlayerUINode:setPosition(cc.p(47,583-(k-1)*96))
        v:setBattleUILayerDelegate(otherPlayerUINode)
        self:addChild(otherPlayerUINode)
        table.insert(self._tOtherPlayerUINodes, otherPlayerUINode)
    end
    if table.getn(self._tOtherPlayerUINodes) == 0 then
        -- 初始化主角的宠物头像和血条
        if PetsManager:getInstance()._pMainPetRole then
            local headIconName = PetsManager:getInstance()._pMainPetRole._pTempleteInfo.PetIcon..".png"
            local hp = PetsManager:getInstance()._pMainPetRole._nHpMax
            self._pMainPetUINode = require("FightRoleUINode"):create(2,headIconName,nil,nil,hp)
            self._pMainPetUINode:setPosition(cc.p(47,583))
            self:addChild(self._pMainPetUINode)
            -- 关联主角宠物信息到ui
            PetsManager:getInstance()._pMainPetRole:setBattleUILayerDelegate(self)
        end
    end

    -- 创建摇杆
    self._pStick = mmo.Stick:createWithFrameName("com_003.png","com_002.png")
    self._pStick:setStartPosition(cc.p(self._pStick:getFrameSize().width/2 + 20, self._pStick:getFrameSize().height/2 + 20))
    self._pStick:setLocked(OptionManager:getInstance()._bStickLock)  -- 默认为不锁定
    self:addChild(self._pStick)
    
    -- 创建手标    
    self._pCursor = cc.Sprite:createWithSpriteFrameName("ccsComRes/wanzifu.png")
    self:addChild(self._pCursor,kZorder.kMax)
    self._pCursor:setVisible(false)

    -- 功能按钮节点
    self._pFuncUINode = cc.Node:create()
    self._pFuncUINode:setPosition(mmo.VisibleRect:width() - 70,mmo.VisibleRect:height() - 130)
    self:addChild(self._pFuncUINode)

    -- 退出游戏按钮
    self._pExitBattleButton = ccui.Button:create("buttons/zdjm24.png","buttons/zdjm24.png","buttons/zdjm24.png",ccui.TextureResType.plistType)
    self._pExitBattleButton:setTitleFontSize(25)
    self._pExitBattleButton:setPosition(0,0)
    self._pExitBattleButton:setTitleText("退出战斗")
    self._pExitBattleButton:setTitleFontName(strCommonFontName)
    self._pExitBattleButton:getTitleRenderer():setTextColor(cFontBrown)
    self._pExitBattleButton:setZoomScale(nButtonZoomScale)  
    self._pExitBattleButton:setPressedActionEnabled(true)
    self._pFuncUINode:addChild(self._pExitBattleButton)
    
    -- 自动战斗按钮
    self._pAutoBattleButton = ccui.Button:create("buttons/zdjm24.png","buttons/zdjm24.png","buttons/zdjm24.png",ccui.TextureResType.plistType)
    self._pAutoBattleButton:setTitleFontSize(25)
    self._pAutoBattleButton:setPosition(0, -100)
    self._pAutoBattleButton:setTitleText("自动战斗")
    self._pAutoBattleButton:setTitleFontName(strCommonFontName)
    self._pAutoBattleButton:getTitleRenderer():setTextColor(cFontBrown)
    self._pAutoBattleButton:setZoomScale(nButtonZoomScale)  
    self._pAutoBattleButton:setPressedActionEnabled(true)
    self._pFuncUINode:addChild(self._pAutoBattleButton)
    ------------------------------------------------
    self._pUnAutoBattleButton = ccui.Button:create("buttons/zdjm24.png","buttons/zdjm24.png","buttons/zdjm24.png",ccui.TextureResType.plistType)
    self._pUnAutoBattleButton:setTitleFontSize(25)
    self._pUnAutoBattleButton:setPosition(0,-100)
    self._pUnAutoBattleButton:setTitleText("手动战斗")
    self._pUnAutoBattleButton:setTitleFontName(strCommonFontName)
    self._pUnAutoBattleButton:getTitleRenderer():setTextColor(cFontBrown)
    self._pUnAutoBattleButton:setZoomScale(nButtonZoomScale)  
    self._pUnAutoBattleButton:setPressedActionEnabled(true)
    self._pFuncUINode:addChild(self._pUnAutoBattleButton)

    -- 战斗评星
    self._pStarUINode = require("StarUINode"):create()
    self._pStarUINode:setPosition(cc.p(mmo.VisibleRect:width() - 160, mmo.VisibleRect:height() - 20))
    self:addChild(self._pStarUINode)

    -- 战斗时间
    self._pTimeUINode = ccui.Text:create()
    self._pTimeUINode:setFontName(strCommonFontName)
    self._pTimeUINode:setFontSize(26)
    self._pTimeUINode:setTextColor(cFontWhite)
    self._pTimeUINode:enableOutline(cFontOutline,2)
    self._pTimeUINode:setPosition(cc.p(mmo.VisibleRect:width() - 95, mmo.VisibleRect:height() - 50))
    self:addChild(self._pTimeUINode)

    -- 普通攻击按钮
    self._pGenAttackButton = ccui.Button:create("SkillUIRes/zjm39.png","SkillUIRes/zjm39.png","SkillUIRes/zjm39_2.png",ccui.TextureResType.plistType)
    self._pGenAttackButton:setPosition(mmo.VisibleRect:width() - self._pGenAttackButton:getContentSize().width*0.5, self._pGenAttackButton:getContentSize().height/2)
    self._pGenAttackButton:setZoomScale(nButtonZoomScale)
    self._pGenAttackButton:setPressedActionEnabled(true)
    self:addChild(self._pGenAttackButton)
    self._pGenAttackButtonTable = cc.Sprite:createWithSpriteFrameName("SkillUIRes/zdjm29.png")
    self._pGenAttackButtonTable:setAnchorPoint(cc.p(1,0))
    self._pGenAttackButtonTable:setPosition(cc.p(mmo.VisibleRect:width()+12,-8))
    self:addChild(self._pGenAttackButtonTable)

    -- 怒气技能底座
    self._pAngerSkillUINode = require("AngerSkillUINode"):create()
    self._pAngerSkillUINode:setPosition(cc.p(mmo.VisibleRect:width()/2,62))
    self:addChild(self._pAngerSkillUINode)

    -- 关联主角信息到ui
    RolesManager:getInstance()._pMainPlayerRole:setBattleUILayerDelegate(self)

    -- 技能按钮
    local skillPosition = {
        {-255 , 11},
        {-222 , 146},
        {-90 , 185},
        {-90 , 305},
    }
    local sScreen = mmo.VisibleRect:getVisibleSize()
    for i=1,table.getn(SkillsManager:getInstance()._tMainRoleMountActvSkills) do
        local skillInfo = SkillsManager:getInstance():getMainRoleSkillDataByID(SkillsManager:getInstance()._tMainRoleMountActvSkills[i].id,SkillsManager:getInstance()._tMainRoleMountActvSkills[i].level)
        local pSkillAttackButton = require("BattleSkillButtonWidget"):create(1)
        pSkillAttackButton:setPosition(sScreen.width + skillPosition[i][1],skillPosition[i][2])
        self:addChild(pSkillAttackButton)
        pSkillAttackButton:setTag(i+1)
        pSkillAttackButton:setSkillInfo(skillInfo)
        pSkillAttackButton._bIsOpen = true
        table.insert(self._tSkillAttackButtons, pSkillAttackButton)
    end
    for i=table.getn(SkillsManager:getInstance()._tMainRoleMountActvSkills)+1,4 do
        local pSkillAttackButton = require("BattleSkillButtonWidget"):create(1)
        pSkillAttackButton:setPosition(sScreen.width + skillPosition[i][1],skillPosition[i][2])
        self:addChild(pSkillAttackButton)
        pSkillAttackButton:setTag(i)
        pSkillAttackButton:setNoOpenState()
        pSkillAttackButton._bIsOpen = false
        table.insert(self._tSkillAttackButtons, pSkillAttackButton)
    end
    
    -- 好友技能按钮
    self._pFriendSkillAttackButton = require("BattleSkillButtonWidget"):create(2)
    self:addChild(self._pFriendSkillAttackButton)
    self._pFriendSkillAttackButton:setTag("firendSkill")
    self._pFriendSkillAttackButton:setPosition(cc.p(mmo.VisibleRect:width()/2-56,31))
    self._pFriendSkillAttackButton._bIsOpen = false
    if FriendManager:getInstance():getFriendSkillId() ~= -1 then
        self._pFriendSkillAttackButton._bIsOpen = true
        self._pFriendSkillAttackButton:setSkillInfo(TableFriendSkills[FriendManager:getInstance():getFriendSkillId()])
    end

    if self:getBattleManager()._bIsAutoBattle == true then
        self._pAutoBattleButton:setVisible(true)
        self._pUnAutoBattleButton:setVisible(false)
    else
        self._pAutoBattleButton:setVisible(false)
        self._pUnAutoBattleButton:setVisible(true)
    end

    -- 共鸣技能
    self._pResonanceSkillAttackButton = require("BattleSkillButtonWidget"):create(3)
    self._pResonanceSkillAttackButton:setPosition(cc.p(mmo.VisibleRect:width()/2-174,31))
    self:addChild(self._pResonanceSkillAttackButton)
    self._pResonanceSkillAttackButton:setTag("resonanceSkill")
    self._pResonanceSkillAttackButton._bIsOpen = false
    if table.getn(RolesManager:getInstance()._tMainPetCooperates) ~= 0 then
        self._pResonanceSkillAttackButton._bIsOpen = true   -- 宠物共鸣队列长度不为0，则认为存在宠物共鸣
        self._pResonanceSkillAttackButton:setSkillInfo(RolesManager:getInstance()._tMainPetCooperates[1].CD)
    end

    -- 新手的第一场战斗
    if BattleManager:getInstance()._bIsFirstBattleOfNewbie == true then
        -- 普通攻击按钮隐藏
        self._pGenAttackButton:setVisible(false)
        self._pGenAttackButtonTable:setVisible(false)
        -- 技能按钮隐藏
        for k, v in pairs(self._tSkillAttackButtons) do
            v:setVisible(false)
        end
    end

    -- 测试按钮
    self._pTestButton = ccui.Button:create("buttons/zdjm24.png","buttons/zdjm24.png","buttons/zdjm24.png",ccui.TextureResType.plistType)
    self._pTestButton:setTitleFontSize(25)
    self._pTestButton:setPosition(100,mmo.VisibleRect:height()/3+190)
    self._pTestButton:setTitleText("测试按钮")
    self._pTestButton:setTitleFontName(strCommonFontName)
    self._pTestButton:getTitleRenderer():setTextColor(cFontBrown)
    self._pTestButton:setZoomScale(nButtonZoomScale)  
    self._pTestButton:setPressedActionEnabled(true)
    self:addChild(self._pTestButton)
    --self._pTestButton:setVisible(false)

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

-- 初始化特效
function BattleUILayer:initEffects()
    -- BOSS出场时的UI警示特效
    self._pBossAppearUIEffectAni = cc.CSLoader:createNode("BossStartEffect.csb")
    self:addChild(self._pBossAppearUIEffectAni)
    self._pBossAppearUIEffectAni:setVisible(false)

end

-- 初始化血条
function BattleUILayer:initBars()
    local pBoss = nil
    local nBossNumHp = 1
    if self:getMonstersManager()._pBoss then
        pBoss = self:getMonstersManager()._pBoss
    elseif self:getRolesManager()._pPvpPlayerRole then
        pBoss = self:getRolesManager()._pPvpPlayerRole
    end
    if pBoss then
        --设置当前boss的血条值
        if pBoss._pRoleInfo.HpBarNumber then
            nBossNumHp = pBoss._pRoleInfo.HpBarNumber
        end
        self._pBossHpNode = require("BossHpNode"):create(nBossNumHp)
        self._pBossHpNode:setPosition(mmo.VisibleRect:width()/2, mmo.VisibleRect:height() - 19)
        self:addChild( self._pBossHpNode)
        -- 关联BOSS或者PVP对手信息到ui
        self._pBossHpNode:setVisible(false)
        pBoss:setBattleUILayerDelegate(self)
    end
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
        if StoryGuideManager:getInstance()._bIsStory == true then --正在进行剧情动画
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
        if StoryGuideManager:getInstance()._bIsStory == true then --正在进行剧情动画
            return
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
    
    return
end

-- 摇杆更新逻辑
function BattleUILayer:procStick(dt)
    -- 如果当前存在剧情框，则直接返回，暂不做结算处理
    if TalksManager:getInstance():isShowingTalks() == true then
        return
    end
    --如果当前正在播放剧情动画，暂不做结算处理
    if StoryGuideManager:getInstance()._bIsStory == true then
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

-- 判断是否是长按普通攻击按钮进行连击操作
function BattleUILayer:procTouchingGenAttackButton(dt)
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
end

-- 播放Boss出场时的UI警示特效
function BattleUILayer:showBossAppearUIEffect()
    self._pBossAppearUIEffectAni:setPosition(mmo.VisibleRect:center())
    self._pBossAppearUIEffectAni:stopAllActions()
    self._pBossAppearUIEffectAni:setVisible(false)
    local action = cc.CSLoader:createTimeline("BossStartEffect.csb")
    action:gotoFrameAndPlay(0, action:getDuration(), false)
    self._pBossAppearUIEffectAni:runAction(action)
    self._pBossAppearUIEffectAni:runAction(cc.Sequence:create(cc.Show:create(),cc.DelayTime:create(action:getDuration()*cc.Director:getInstance():getAnimationInterval()),cc.Hide:create()))
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
    self._bIsShowingAngerEffect = true
end

-- 停止怒气特效
function BattleUILayer:stopAngerEffect()
    self._bIsShowingAngerEffect = false
end

-- 移除当前对话的头像集合
function BattleUILayer:removeCurTalkHeadersAndNames()
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
function BattleUILayer:createTalkHeadersAndNames(talkID)
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

-- 显示对话信息
function BattleUILayer:showCurTalks()
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

function BattleUILayer:setAllUIVisible(visible)
    self._pStick:setVisible(visible)

    --如果boss没有死，且boss的状态不是挂起状态就可以设置boss的血条
    if MonstersManager:getInstance()._pBoss and MonstersManager:getInstance()._pBoss:getStateMachineByTypeID(kType.kStateMachine.kBattleMonster)._pCurState._kTypeID ~= kType.kState.kBattleMonster.kSuspend then
      if self._pBossHpNode then
         self._pBossHpNode:setVisible(visible)
      end
    end

    self._pMainPlayerUINode:setVisible(visible)

    if self._pMainPetUINode then
       self._pMainPetUINode:setVisible(visible)
    end

    for k,v in pairs(self._tOtherPlayerUINodes) do
        v:setVisible(visible)
    end

    self._pFuncUINode:setVisible(visible)
    
    --连击动画
    if visible == false then
       self:hideHitAni() 
    end

    -- 设置评分
    if self._pTimeCountDownNode then 
       self._pTimeCountDownNode:setVisible(visible)
    end

     -- 设置评分
    if self._pGoldDropNode then 
       self._pGoldDropNode:setVisible(visible)
    end

    self._pAngerSkillUINode:setVisible(visible)
    
    -- 新手的第一场战斗(且剧情动画没有开启)
    if BattleManager:getInstance()._bIsFirstBattleOfNewbie == true and StoryGuideManager:getInstance()._bIsStory == false then
        -- 好友技能
        if self._pFriendSkillAttackButton then
           self._pFriendSkillAttackButton:setVisible(visible)
        end
        -- 共鸣技能
        if self._pResonanceSkillAttackButton then
           self._pResonanceSkillAttackButton:setVisible(visible)
        end
        return
    end

    -- 普通攻击按钮
    self._pGenAttackButton:setVisible(visible)
    self._pGenAttackButtonTable:setVisible(visible)

    -- 技能按钮
    for k,v in pairs(self._tSkillAttackButtons) do
        v:setVisible(visible)
    end

    self._pStarUINode:setVisible(visible)
    self._pTimeUINode:setVisible(visible)

    --聊天按钮
    if self._pChatPanelCCS then 
       self._pChatPanelCCS:setVisible(visible)
    end

    -- 好友技能
    if self._pFriendSkillAttackButton then
       self._pFriendSkillAttackButton:setVisible(visible)
    end
    
    -- 共鸣技能
    if self._pResonanceSkillAttackButton then
       self._pResonanceSkillAttackButton:setVisible(visible)
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
    	--return 
    end

    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self._tNewMessage = {} --清空外面的提示队列
            DialogManager:getInstance():showDialog("ChatDialog")
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ChatButton")
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
        self._pChatPanelCCS:setPosition(cc.p(0,mmo.VisibleRect:height()*0.453))
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
    --self._pLevLabel:setString("Lv"..self:getRolesManager()._pMainPlayerRole._pRoleInfo.level)
end

--按照打怪的的个数来评星
function BattleUILayer:initResultByGrade()
    --如果是金钱副本 材料副本 按照评分来评星
    if  StagesManager:getInstance()._nCurCopyType == kType.kCopy.kGold 
     or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kStuff then
        self._pResultByGradeNode = require("ResultByGrade"):create({kResultType.kGreadResult,1})
        self._pResultByGradeNode:setPosition(mmo.VisibleRect:width()/2 + 120, -25)
		self._pTimeUINode:addChild(self._pResultByGradeNode)
	end	
end

-- 按照战斗的时长来评星
-- 以时间为结算的副本包括：挑战副本 剧情副本 迷宫副本 地图boss
function BattleUILayer:initTimeCountDownResultNode()
    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kChallenge
        or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kStory
        --or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kMaze
        or StagesManager:getInstance()._nCurCopyType == kType.kCopy.kMapBoss then 
            self._pStarUINode:setStar(5)
            -- 获取评星为5 时间
            local nRemainSec = StagesManager:getInstance():getCurStageDataInfo()["FiveStarGrade"]
            self._pTimeUINode:setString(nRemainSec)
            self._bIsScoreByTime = true
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

-- 新手第一场战斗结束后的字幕
function BattleUILayer:showCaptionContentAfterDoomsdayWithDelay(delay)
    local pBlackBackground = cc.LayerColor:create(cc.c4b(0,0,0,0))
    self:addChild(pBlackBackground,180)
    local blackOver = function()
        TalksManager:getInstance():setCurTalks(80)
        MapManager:getInstance()._pTmxMap:setVisible(false)
        pBlackBackground:setVisible(false)
        -- 开始显示末日对白
        self._bIsShowingCaptionContentAfterDoomsday = true
    end
    pBlackBackground:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.FadeTo:create(3.0,255), cc.CallFunc:create(blackOver)))

    -- 主角ui隐藏
    self._pMainPlayerUINode:setVisible(false)
    -- 动画瞬间，需要强制隐藏相应UI
    self._pStarUINode:setVisible(false)
    self._pTimeUINode:setVisible(false)
    -- 好友技能
    if self._pFriendSkillAttackButton then
       self._pFriendSkillAttackButton:setVisible(false)
    end
    -- 共鸣技能
    if self._pResonanceSkillAttackButton then
       self._pResonanceSkillAttackButton:setVisible(false)
    end
    self._pAngerSkillUINode:setVisible(false)
    self._pBossHpNode:setVisible(false)

end

return BattleUILayer
