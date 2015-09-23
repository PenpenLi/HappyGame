--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BattleManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/1/7
-- descrip:   战斗管理器
--===================================================
BattleManager = {}

local instance = nil

-- 单例
function BattleManager:getInstance()
    if not instance then
        instance = BattleManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function BattleManager:clearCache()    
    self._fTimeMax = -1                                                 -- 最大时间
    self._fTimeCounter = -1                                             -- 时间计数器
    self._bHasShownBattleEndTalk = false                                -- 是否已经显示完毕结束剧情对话
    self._bIsBossDead = false                                           -- 是否boss已经死亡
    self._bTimeCounting = false                                         -- 时间是否正在计数
    self._pBattleUILayer = nil                                          -- 战斗UI层
    self._bIsAutoBattle = false                                         -- 是否自动战斗
    self._tBattleArgs = nil                                             -- 战斗对接参数（所有）
    self._kBattleResult = kType.kBattleResult.kBattling                 -- 战斗是否结束
    self._bIsTransforingFromEndBattle = false                           -- 是否正处于由战斗结束开始的场景切换
    self._tCopyResultCheckFuncs = {
        [kType.kCopy.kGold] = self.checkResultForGoldCopy,
        [kType.kCopy.kStuff] = self.checkResultForStuffCopy,
        [kType.kCopy.kMaze] = self.checkResultForMazeCopy,
        [kType.kCopy.kChallenge] = self.checkResultForChallengeCopy,
        [kType.kCopy.kTower] = self.checkResultForTowerCopy,
        [kType.kCopy.kMapBoss] = self.checkResultForMapBossCopy,
        [kType.kCopy.kMidNight] = self.checkResultForMidNightCopy,
        [kType.kCopy.kPVP] = self.checkResultForPVPCopy,
        [kType.kCopy.kHuaShan] = self.checkResultForHuaShanCopy,
        [kType.kCopy.kStory] = self.checkResultForStoryCopy
    }
    
    ------------------------------------ 爬塔副本专用 -----------------------------------------------------------
    self._tTowerCopyStepResultInfos = {}                                -- 爬塔副本分步结算信息（客户端本地缓存）格式：{{},{},{},{},.......}
    
    self._bMidNight = nil            --午夜惊魂是否开启
    self._bMidNightBeFail = nil      --午夜惊魂是否已经失败
    
    self._pMonsterDeadGread = 0
    -------------------------------  按战斗时间评星  -------------------------------------------
    self._nTimeBattleRemainSec = 0
    self._nTimeBattleLevel = 5
    -- 注销网络回调
    NetRespManager:getInstance():removeEventListenersByHost(self)
    
end

-- 循环处理
function BattleManager:update(dt)
    --如果当前正在显示新手，则立即返回
    if NewbieManager:getInstance():isShowingNewbie() == true then
        return
    end
    -- 战斗结果已经得出，则不再做任何战斗逻辑表现
    if BattleManager:getInstance()._kBattleResult ~= kType.kBattleResult.kBattling then
        return
    end
    
    self:updateTime(dt)
    self:updateResult(dt)

    if self:getBattleUILayer()._pTimeCountDownNode then 
        self:updateBatttleLevelTime(dt)
    end
end

-- 获取战斗层
function BattleManager:getBattleUILayer()
    if self._pBattleUILayer == nil then
        self._pBattleUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
    end
    return self._pBattleUILayer
end

-- 切换到自动战斗
function BattleManager:toAutoBattle()
    self._bIsAutoBattle = true
    self:getBattleUILayer()._pAutoBattleButton:setVisible(true)
    self:getBattleUILayer()._pUnAutoBattleButton:setVisible(false)
    --RolesManager:getInstance()._pMainPlayerRole._refGenAttackButton:add()
end

-- 切换到手动战斗
function BattleManager:toUnAutoBattle()
    self._bIsAutoBattle = false
    self:getBattleUILayer()._pUnAutoBattleButton:setVisible(true)
    self:getBattleUILayer()._pAutoBattleButton:setVisible(false)
    --RolesManager:getInstance()._pMainPlayerRole._refGenAttackButton:sub()
end

-- 开始计时
function BattleManager:startTime()
    if self._fTimeCounter == -1 and self._fTimeMax ~= -1 and self._bTimeCounting == false then
        self._fTimeCounter = self._fTimeMax
        self._bTimeCounting = true
    end
end

-- 暂停计时
function BattleManager:pauseTime()
    if self._bTimeCounting == true then
        self._bTimeCounting = false
    end
end

-- 恢复计时
function BattleManager:resumeTime()
    if self._bTimeCounting == false then
        self._bTimeCounting = true
    end
end

-- 时间处理
function BattleManager:updateTime(dt)
    if self._bTimeCounting == true then
        self._fTimeCounter = self._fTimeCounter - dt
        if self._fTimeCounter <= 0 then
            self._fTimeCounter = 0
            self:getBattleUILayer()._pTimeNode:setString("00:00")
        else
            local minute = mmo.HelpFunc:gGetMinuteStr(self._fTimeCounter)
            local second = mmo.HelpFunc:gGetSecondStr(self._fTimeCounter)
            local format = minute..":"..second
            self:getBattleUILayer()._pTimeNode:setString(format)
            if self:getBattleUILayer()._pTimeCountDownNode then 
                self:updateBatttleLevelTime(dt)
            end
        end
    end
end

-- 更新根据战斗时常评星
function BattleManager:updateBatttleLevelTime(dt)
    if self._bTimeCounting == false then
        return
    end
    local maxBattleLevelSec = self:getBattleUILayer()._pTimeCountDownNode:getMaxSecByLevel(self._nTimeBattleLevel)
    --maxBattleLevelSec = self._nTimeBattleLevel == 5 and maxBattleLevelSec - TableConstants.StarDelay.Value or maxBattleLevelSec 
    self._nTimeBattleRemainSec = maxBattleLevelSec - (StagesManager:getInstance():getCurStageDataInfo().Timeing - self._fTimeCounter) 

    if self._nTimeBattleRemainSec <= 0 then 
        if self._nTimeBattleLevel ~= 1 then 
            self._nTimeBattleLevel = self._nTimeBattleLevel - 1 
            -- 设置战斗评星的图标
            self:getBattleUILayer()._pTimeCountDownNode:updateImgByBattleLevel(self._nTimeBattleLevel)
            -- 获取当前评级最多消耗时间 
            local fontColor = self._nTimeBattleLevel == 1 and cRed or cWhite
            self:getBattleUILayer()._pTimeCountDownNode._pTimeText:setColor(fontColor)
        else
            self:getBattleUILayer()._pTimeCountDownNode:timeCountDown(0)
            return
        end
    end
    self:getBattleUILayer()._pTimeCountDownNode:timeCountDown(self._nTimeBattleRemainSec)
end

-- 监控游戏结果
function BattleManager:updateResult(dt)
    if self._kBattleResult ~= kType.kBattleResult.kBattling then        -- 如果已经有了战斗结果，则直接返回
        return
    end
    
    -- 如果当前存在复活弹框，则直接返回，暂不做结算处理
    if DialogManager:getInstance():getDialogByName("ReviveDialog") then
        return
    end
    
    -- 如果当前存在剧情框，则直接返回，暂不做结算处理
    if TalksManager:getInstance():isShowingTalks() == true then
        return
    end
    
    -- 如果当前正在boss死亡的慢镜头特写中，则直接返回，暂不做结算处理
    if MapManager:getInstance()._bBossDeadFilming == true then
        return
    end
    
    -- 通用结算逻辑判定
    local isFinalMap = MapManager:getInstance():isFinalMapInBattle()
    if isFinalMap == true then  -- 当前为最后一张地图
        if StagesManager:getInstance()._nCurCopyType ~= kType.kCopy.kPVP -- 当前副本类型不为PVP
            and StagesManager:getInstance()._nCurCopyType ~= kType.kCopy.kHuaShan then  -- 当前副本类型不为华山论剑
            if MonstersManager:getInstance()._bIsBossDead == true or self._bIsBossDead == true then    -- 存在boss, 如果boss死亡，则立即结算
                -- 检查战斗结束时是否需要播放剧情对话(仅限在剧情副本生效)
                if self._bHasShownBattleEndTalk == false and StagesManager:getInstance()._nCurCopyType == kType.kCopy.kStory then
                    if StagesManager:getInstance():getCurStageDataInfo().BattleEndTalkID ~= -1 then
                        TalksManager:getInstance():setCurTalks(StagesManager:getInstance():getCurStageDataInfo().BattleEndTalkID)
                        self._bHasShownBattleEndTalk = true        -- 标记已经显示了结束剧情对话
                        self._bIsBossDead = true                   -- 标记boss已经死亡
                        return
                    end
                end
                -- 战斗胜利
                self:requestForResult()
            else    -- 没有boss，如果所有怪全部被剿灭，则立即结算
                local pMonstersManager = MonstersManager:getInstance()
                if table.getn(pMonstersManager._tCurWaveMonsters) == 0 and pMonstersManager._nCurMonsterAreaIndex ~= 0 then
                    if pMonstersManager._tMonsters[pMonstersManager._nCurMonsterAreaIndex][pMonstersManager._nCurMonsterWaveIndex + 1] == nil then  -- 当前野怪区域已经没有下一波了
                        -- 在已经没有下一波的情况下，判断是否当前战斗地图中所有野怪已经全部被干掉了
                        if table.getn(pMonstersManager._tMonsters) == pMonstersManager._nCurMonsterAreaIndex then
                            -- 检查战斗结束时是否需要播放剧情对话(仅限在剧情副本生效)
                            if self._bHasShownBattleEndTalk == false and StagesManager:getInstance()._nCurCopyType == kType.kCopy.kStory then
                                if StagesManager:getInstance():getCurStageDataInfo().BattleEndTalkID ~= -1 then
                                    TalksManager:getInstance():setCurTalks(StagesManager:getInstance():getCurStageDataInfo().BattleEndTalkID)
                                    self._bHasShownBattleEndTalk = true    -- 标记已经显示了结束剧情对话
                                    return
                                end
                            end
                            -- 战斗胜利
                            self:requestForResult()
                        end
                    end
                end
            end
        end      
    end
    
    -- 利用数组下标直接进入对应副本类型的判定逻辑
    self._tCopyResultCheckFuncs[StagesManager:getInstance()._nCurCopyType](dt)

end

-- 结算请求函数（协议数据组装）
function BattleManager:requestForResult()    
    -- 只要是和服务器进行交互结算，结果均为胜利
    self._kBattleResult = kType.kBattleResult.kWin
    self:pauseTime()            -- 时间暂停
    
    -- 处理战场逻辑（战斗结束状态）
    RolesManager:getInstance():disposeWhenBattleResult()
    PetsManager:getInstance():disposeWhenBattleResult()
    MonstersManager:getInstance():disposeWhenBattleResult()    
    
    local toServer = function()
        local winData = {}
        local monstersData = MonstersManager:getInstance()._tMonsterDeadNum
        for k, v in pairs(monstersData) do
            local temp = {}
            temp.id = k
            temp.count = v
            table.insert(winData, temp)
        end
        if StagesManager:getInstance()._nBattleId == 0 or  --如果发送的战斗id是0或者战斗结果是取消状态就不发送战斗结算
           self._kBattleResult == kType.kBattleResult.kCancel then 
           return
        end
        DialogManager:getInstance():closeDialogByName("AlertDialog")
        local nConstTime = math.ceil(self._fTimeMax - self._fTimeCounter)
        print("****************************************** nConstTime:".. nConstTime)
        MessageGameInstance:sendMessageUploadBattleResult21004(StagesManager:getInstance()._nBattleId,{useTime = nConstTime, monsters = winData})
    end
    -- 延时2秒后开始结算
    cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(toServer)))
end


-- 金钱副本
function BattleManager:checkResultForGoldCopy(dt)
    local self = BattleManager:getInstance()

    -- 判定结算时机    
    if self._kBattleResult == kType.kBattleResult.kBattling then
        if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showFailureResult()
        elseif self._fTimeCounter == 0 then                    -- 时间到
            self:requestForResult()
        end
    end

end

-- 材料副本
function BattleManager:checkResultForStuffCopy(dt)
    local self = BattleManager:getInstance()
     -- 判定结算时机    
    if self._kBattleResult == kType.kBattleResult.kBattling then
        if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showFailureResult()
        elseif self._fTimeCounter == 0 then                    -- 时间到
            self:requestForResult()
        end
    end
end

-- 迷宫副本
function BattleManager:checkResultForMazeCopy(dt)
    local self = BattleManager:getInstance()
    -- 判定结算时机    
    if self._kBattleResult == kType.kBattleResult.kBattling then
       if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showFailureResult()
        elseif self._fTimeCounter == 0 then                    -- 时间到
           self:showFailureResult()
        end
    end
end

--弹出失败Dialog
function BattleManager:showFailureResult()
    DialogManager:getInstance():closeDialogByName("ChatDialog")
    self._kBattleResult = kType.kBattleResult.kLose
    self:pauseTime()            -- 时间暂停
    
    -- 处理战场逻辑（战斗结束状态）
    RolesManager:getInstance():disposeWhenBattleResult()
    PetsManager:getInstance():disposeWhenBattleResult()
    MonstersManager:getInstance():disposeWhenBattleResult() 
    
    DialogManager:getInstance():showDialog("BattleEndFailureDialog")
end


-- 挑战副本
function BattleManager:checkResultForChallengeCopy(dt)
    local self = BattleManager:getInstance()
    -- 判定结算时机    
    if self._kBattleResult == kType.kBattleResult.kBattling then
        if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showFailureResult()
        elseif self._fTimeCounter == 0 then                    -- 时间到
            self:showFailureResult()
        end
    end
end

-- 爬塔副本
function BattleManager:checkResultForTowerCopy(dt)
    local self = BattleManager:getInstance()
    -- 判定结算时机    
    if self._kBattleResult == kType.kBattleResult.kBattling then
         if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showTowerAccounts()
        elseif self._fTimeCounter == 0 then                    -- 时间到
            self:showTowerAccounts()
        end
    end   
end

-- 地图boss副本
function BattleManager:checkResultForMapBossCopy(dt)
    local self = BattleManager:getInstance()
    -- 判定结算时机    
    if self._kBattleResult == kType.kBattleResult.kBattling then
        if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showFailureResult()
        elseif self._fTimeCounter == 0 then                    -- 时间到
            self:showFailureResult()
        end
    end
end

-- 午夜惊魂副本
function BattleManager:checkResultForMidNightCopy(dt)
    local self = BattleManager:getInstance()
    -- 判定结算时机  
    if self._kBattleResult == kType.kBattleResult.kBattling then
        if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showFailureResult()
        elseif self._fTimeCounter == 0 then                    -- 时间到
            self:showFailureResult()
        end
    end
    
end

-- 排行榜副本
function BattleManager:checkResultForPVPCopy(dt)
    local self = BattleManager:getInstance()
    
    if RolesManager:getInstance()._pPvpPlayerRole and RolesManager:getInstance()._pPvpPlayerRole._nCurHp <= 0  then    -- 存在pvp对手, 如果pvp对手死亡，或者玩家死亡，则立即结算
        self._kBattleResult = kType.kBattleResult.kWin
        local toServer = function()
            ArenaCGMessage:fightResultReq21604(true)
            -- 引导
            if NewbieManager:getInstance()._bSkipGuide == false then
                if NewbieManager:getInstance()._pLastID == "Guide_6_15" then
                    NewbieManager:getInstance():showNewbieByID("Guide_6_16")
                end
            end
        end
        -- 延时2秒后开始结算
        cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(toServer)))
    elseif (RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0) or self._fTimeCounter == 0 then
        self._kBattleResult = kType.kBattleResult.kLose
        ArenaCGMessage:fightResultReq21604(false)
    end
    
end

-- 华山论剑副本
function BattleManager:checkResultForHuaShanCopy(dt)
    local self = BattleManager:getInstance()
 
    if RolesManager:getInstance()._pPvpPlayerRole and RolesManager:getInstance()._pPvpPlayerRole._nCurHp <= 0  then    -- 存在pvp对手, 如果pvp对手死亡，或者玩家死亡，则立即结算
        self._kBattleResult = kType.kBattleResult.kWin
        local toServer = function()
            HuaShanCGMessage:fightHSResultReq21906(true)
        end
        -- 延时2秒后开始结算
        cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(toServer)))
    elseif (RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0) or self._fTimeCounter == 0 then
        self._kBattleResult = kType.kBattleResult.kLose
        self:showFailureResult()
    end   

end

-- 剧情副本
function BattleManager:checkResultForStoryCopy(dt)
    local self = BattleManager:getInstance()
    -- 判定结算时机    
    if self._kBattleResult == kType.kBattleResult.kBattling then
        if RolesManager:getInstance()._pMainPlayerRole._nCurHp <= 0 then     -- 血值为0
            self:showFailureResult()
        elseif self._fTimeCounter == 0 then                    -- 时间到
            self:showFailureResult()
        end
    end
end

--爬塔副本的结算（特殊处理）
function BattleManager:showTowerAccounts()
    self:getBattleUILayer():setTowerCdTextVisible(false)     --如果有倒计时text就设置为不可见
    if table.getn(self._tTowerCopyStepResultInfos) == 0 then --没有打通一关，弹出失败界面
         self:showFailureResult()
    else
        self._kBattleResult = kType.kBattleResult.kLose
        self:pauseTime()            -- 时间暂停

        -- 处理战场逻辑（战斗结束状态）
        RolesManager:getInstance():disposeWhenBattleResult()
        PetsManager:getInstance():disposeWhenBattleResult()
        MonstersManager:getInstance():disposeWhenBattleResult() 
        
        DialogManager:getInstance():showDialog("BattleTowerAccountsDialog",self._tTowerCopyStepResultInfos)
    end
  
end


--战斗结算
function BattleManager:uploadBattleResult(args)
    DialogManager:getInstance():closeDialogByName("AlertDialog")
    print("DialogManager:getInstance():showDialog")

    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kTower then --如果是爬塔副本需要特殊处理
        table.insert(self._tTowerCopyStepResultInfos,args["body"])
        local nBattleId = StagesManager:getInstance()._nCurStageID
        local nIdentity = StagesManager:getInstance()._nIdentity
        local bHasNextCopy = self:selectTowerCopyInfoByCurBattleId(nBattleId)
        if bHasNextCopy then --如果是空则表示没有下一关了。要弹出结算
            --发送请求下个副本的协议
            local actionOverCallBack = function()
                --如果当前战斗状态为战斗失败或者战斗取消，就不发一下层数据了
                if self._kBattleResult == kType.kBattleResult.kLose
                    or self._kBattleResult == kType.kBattleResult.kCancel then
                    return
                end
                DialogManager:getInstance():closeDialogByName("AlertDialog")
                MessageGameInstance:sendMessageEntryBattle21002(nBattleId+1,nIdentity)
            end
            self:getBattleUILayer():playTowerAfterCdAction(actionOverCallBack)
        else
            self:showTowerAccounts()
        end
        return
    end
    DialogManager:getInstance():showDialog("BattleEndAccountsDialog",{args["body"].extPickCount,RolesManager:getInstance()._pMainRoleInfo.level})
    print("DialogManager:getInstance():showDialog")
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kUploadBattleResult, args["body"])
    
    -- 如果是1_4，必须手动将mainid置成下一步，避免下次进入游戏，直接判断为1_1部而进入进入第一场战斗
    if NewbieManager:getInstance()._pLastID == "Guide_1_4" then
        NewbieManager:getInstance():setMainId("Guide_2_1")
    end
    
    -- 引导
    local showGuid = function()
        if NewbieManager:getInstance()._bSkipGuide == false then
            if NewbieManager:getInstance()._pLastID == "Guide_1_4" then
                NewbieManager:getInstance():showNewbieByID("Guide_1_5")
            elseif NewbieManager:getInstance()._pLastID == "Guide_5_20" then
                NewbieManager:getInstance():showNewbieByID("Guide_5_21")
            end
        end
    end                
    cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(showGuid)))  -- 延时后再提示翻牌引导，给弹框预留一部分时间

    if table.getn(args["body"].roleAttrInfo) > 0 then
        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = args["body"].roleAttrInfo
    end

    RolesManager:getInstance()._pMainRoleInfo.exp = args["body"].currExp
    RolesManager:getInstance()._pMainRoleInfo.level = args["body"].currLevel
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateRoleInfo, {})
end

--根据当前的爬塔副本id查询下一章的副本信息
function BattleManager:selectTowerCopyInfoByCurBattleId(nBattleId)
    local TabCopys = StagesManager:getInstance():getCopyDataInfo(kType.kCopy.kTower)
    local TabCopysMap = StagesManager:getInstance():getCopyMapInfo(kType.kCopy.kTower)
    local pPrecondition = TabCopys[nBattleId-500].Postposition
    if pPrecondition ~= nil then --表示最后 一关需要手动写数据
        return true
    end
    return false

end

--爬塔副本战斗对接(从战斗内部进入，结算不弹出，直接切入下一个副本)
function BattleManager:entryTowerBattleCopy()

    local nCurStageID = StagesManager:getInstance()._nCurStageID+1
    local TabCopys = StagesManager:getInstance():getCopyDataInfo(kType.kCopy.kTower)
    local TabCopysMap = StagesManager:getInstance():getCopyMapInfo(kType.kCopy.kTower)
    local SelectedCopysDataInfo = TabCopys[nCurStageID-500]
    local pSelectedCopysFirstMapInfo =TabCopysMap[SelectedCopysDataInfo.MapID]

    --战斗数据组装
    -- 【战斗数据对接】
    local args = {}
    args._strNextMapName = pSelectedCopysFirstMapInfo.MapsName
    args._strNextMapPvrName = pSelectedCopysFirstMapInfo.MapsPvrName
    args._nNextMapDoorIDofEntity = pSelectedCopysFirstMapInfo.Doors[1][1]
    --require("TestMainRoleInfo")    --roleInfo
    args._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo 
    args._nMainPlayerRoleCurHp = RolesManager:getInstance()._pMainPlayerRole._nCurHp        -- 从副本进入时，这里为无效值
    args._nMainPlayerRoleCurAnger = RolesManager:getInstance()._pMainPlayerRole._nCurAnger   -- 从副本进入时，这里为无效值
    if PetsManager:getInstance()._pMainPetRole then
        args._nMainPetRoleCurHp = PetsManager:getInstance()._pMainPetRole._nCurHp               -- 从副本进入时，这里为无效值
    end
    args._nCurCopyType =SelectedCopysDataInfo.CopysType
    args._nCurStageID = SelectedCopysDataInfo.ID
    args._nCurStageMapID = SelectedCopysDataInfo.MapID
    args._nBattleId = SelectedCopysDataInfo.ID
    args._fTimeMax =  SelectedCopysDataInfo.Timeing
    args._bIsAutoBattle = self._bIsAutoBattle
    args._tMonsterDeadNum = {}
    args._nIdentity = StagesManager:getInstance()._nIdentity
    args._tTowerCopyStepResultInfos = self._tTowerCopyStepResultInfos
    args._pPvpRoleInfo = nil
    args._tPvpRoleMountAngerSkills = {}
    args._tPvpRoleMountActvSkills = {}
    args._tPvpPasvSkills = {}
    args._tPvpPetRoleInfosInQueue = {}

    --切换战斗场景
    LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
end

--退出战斗按钮的回调函数
function BattleManager:exitBattle()
    self._kBattleResult = kType.kBattleResult.kCancel
    if StagesManager:getInstance()._nCurCopyType == kType.kCopy.kTower then --如果是爬塔副本需要特殊处理
        self:showTowerAccounts()
    elseif StagesManager:getInstance()._nCurCopyType == kType.kCopy.kPVP then
        ArenaCGMessage:fightResultReq21604(false)
    elseif StagesManager:getInstance()._nCurCopyType == kType.kCopy.kHuaShan then
        self:showFailureResult()
	else
        LayerManager:getInstance():gotoRunningSenceLayer(WORLD_SENCE_LAYER)
    end
end

--设置死亡的怪物的积分(增量)
function BattleManager:setUpNumGread(nGread)
    self._pMonsterDeadGread =  self._pMonsterDeadGread + nGread
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kResultByGradeResp)
end

        
