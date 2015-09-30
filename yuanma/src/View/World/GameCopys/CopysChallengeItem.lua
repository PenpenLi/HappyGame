--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CopysChallengeItem.lua
-- author:    wuquandong
-- created:   2015/04/15
-- descrip:   挑战副本itemcell
--===================================================
local CopysChallengeItem = class("CopysChallengeItem",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function CopysChallengeItem:ctor()
    -- 层名称
    self._strName = "CopysChallengeItem"        
    -- 副本数据信息
    self._pDataInfo = nil  
    -- 副本中第一张地图信息             
    self._pFirstMapInfo = nil          
    -- 副本总次数
    self._nTotalCount = 0
    -- 副本当前剩余次数
    self._nCurCount = 0

    -- 地图背景
    self._pBg = nil
    -- 背景
    self._pBgFrame = nil
    
    self._pCopyBg = nil
    -- 进入副本按钮
    self._pEntryBtn = nil
    self._pEntryBtnText = nil
    
    self._pText1Pos = nil
    self._pTextNode1 = nil
    -- 关卡消耗物品
    self._pDownBg2 = nil
    --关卡消耗物品图标
    self._pItemCost = nil
    --关卡消耗物品数量   当前拥有数量/本次所需数量
    self._pItemCostNum = nil
    -- 副本进入次数
    self._pCurCountTextNum = nil
    -- 消耗体力
    self._pCastCountTextNum = nil
    -- 副本的名字
    self._pInstanceNmaeText = nil
    -- 推荐战斗力
    self._pSuggestCombatText = nil
    -- 可视区域
    self._recBg = nil
    -- 关卡奖励物品图标
    self._tGoodsItemIconArry = {}
    --锁住的图片
    self._pLockImg = nil 
    -- 解锁需要的等级
    self._pNeedLevelText = nil 
    -- 旋转挂载的节点
    self._pNodeLock = nil 
    -- 关卡信息节点
    self._pStageInofNode = nil
    -- 是否未解锁
    self._beLocked = false
    -- 前置关卡Id
    self._tUnPrevStages = {}
    
    self._pItem1Bg = nil
    self._pItem2Bg = nil
    self._pItem3Bg = nil
    self._pReward = nil

    self._fClickCallback = nil
    self._fUpdateCallback = nil
    self._nIndex = 0
    
    self._pCopysLock = nil
    self._pCopysunLock = nil
end

-- 创建函数
function CopysChallengeItem:create(dataInfo, mapInfo)
    local dialog = CopysChallengeItem.new()
    dialog:dispose(dataInfo, mapInfo)
    return dialog
end

function CopysChallengeItem:setBtnVisible(args)
    --self._pEntryBtn:setVisible(args)
end

-- 处理函数
function CopysChallengeItem:dispose(dataInfo, mapInfo)
    --注册（请求游戏副本列表）
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryBattleList, handler(self, self.updateQueryBattleList))
    -- 购买战斗次数的网络回复
    NetRespManager:getInstance():addEventListener(kNetCmd.kBuyBattleResp ,handler(self, self.buyBattleNumResp21317))

    ResPlistManager:getInstance():addSpriteFrames("ChallengeCopys.plist")
    ResPlistManager:getInstance():addSpriteFrames("CopysBgLock.plist")
    ResPlistManager:getInstance():addSpriteFrames("EnterIntoEffect.plist")
    self._pDataInfo = dataInfo
    self._pFirstMapInfo = mapInfo
   
    self:initUI()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,pLocal) == false then
            --self._pEntryBtn:setVisible(false)
        end
       
        return false
    end
    local function onTouchMoved(touch,event)
        local location = self._pBg:convertTouchToNodeSpace(touch)

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
       
    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitInstanceItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function CopysChallengeItem:setSelfPos(x, y)
	self._recBg.x = x
    self._recBg.y = y    
end

function CopysChallengeItem:setSelfScaleNormal()
    self:setScale(1.0)
    
    self:setPosition(self._recBg.x,self._recBg.y)
end

function CopysChallengeItem:setSelfScaleSmall()
    self:setScale(0.9)

    self:setPosition(self._recBg.x+20,self._recBg.y+20)
end

function CopysChallengeItem:setCounts(totalCount , curCount)
	self._nTotalCount = totalCount
    self._nCurCount = curCount

    if self._pCurCountTextNum ~= nil then
        self._pCurCountTextNum:setString(self._nCurCount.."/"..self._nTotalCount)
    end
    
    if curCount == 0 then
        self._pCurCountTextNum:setColor(cRed)
    else
        self._pCurCountTextNum:setColor(cGreen)
    end
end

function CopysChallengeItem:initUI()
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if RolesManager:getInstance()._pMainRoleInfo.level < self._pDataInfo.RequiredLevel then --等级不足
                NoticeManager:getInstance():showSystemMessage("需玩家等级达到"..self._pDataInfo.RequiredLevel.."级!")
                return
            end
            if #self._tUnPrevStages > 0 then
                NoticeManager:getInstance():showSystemMessage("需要通关".. self:getBattleNameById(self._tUnPrevStages[1]))
                return
            end
            if self._nCurCount <= 0 then 
                DialogManager:getInstance():showDialog("BuyStrengthDialog",{2,self._pDataInfo.CopysType,self._pDataInfo.ID})
                return
            end
            
            if self._pDataInfo.Items then --如果进入的副本需要道具
                local pItemsId = self._pDataInfo.Items
                local pNeedNum = self._pDataInfo.ItemNum
                local pOwnNum = BagCommonManager:getInstance():getItemNumById(pItemsId)
                if pOwnNum < pNeedNum then --道具不足
                    NoticeManager:getInstance():showSystemMessage("材料不足！")
                	return 
                end
                
           
            end
            
            if self._fClickCallback ~= nil then
                self._fClickCallback(self._pDataInfo, self._pFirstMapInfo)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    --图标按钮
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:setSelfScaleNormal()
            self._pEntryBtn:setVisible(true)
        elseif eventType == ccui.TouchEventType.moved then
            self:setSelfScaleNormal()
            if self._fUpdateCallback ~= nil then
                self._fUpdateCallback()
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self:setSelfScaleSmall()
            if self._fUpdateCallback ~= nil then
                self._fUpdateCallback()
            end
        end
    end
    -- 加载csb 组件
    local params = require("ChallengeCopysParams"):create()
    self._pCCS = params._pCCS
    self._pBgFrame = params._pBackGround
    self._pCopyBg = params._pcopyBg
    self._pStageInofNode = params._pDownBg
    self._pBg = params._pcopyBg
    self._pBg:loadTexture("MoneyCopysDialogRes/".. self._pDataInfo.MapIcon..".png",ccui.TextureResType.plistType)
    self._pBg:setTouchEnabled(true)
    self._pBg:setSwallowTouches(false)
    self._pBg:addTouchEventListener(onTouchBg)

    local size = self._pBg:getContentSize()
    self._pBgFrame:setContentSize(size.width + 34 , size.height + 34)

    local x,y = self:getPosition()
    local size = self._pBgFrame:getContentSize()
    self._recBg = cc.rect(x,y,size.width,size.height)

    self._pEntryBtn = params._pSureButton
    self._pEntryBtn:setTouchEnabled(true)
    self._pEntryBtn:setZoomScale(nButtonZoomScale)
    self._pEntryBtn:setPressedActionEnabled(true)
    self._pEntryBtn:addTouchEventListener(onTouchButton)
    --self._pEntryBtn:setVisible(false)
    self._pBgFrame:reorderChild(self._pEntryBtn , 4)
    --self._pEntryBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pEntryBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
      
    self._pCastCountTextNum = params._pusepower02
    --self._pCastCountTextNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._pCastCountTextNum:setString(self._pDataInfo.PowerNum)
    --self._pCastCountTextNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    self._pCurCountTextNum = params._pcurcount02
    self._pCurCountTextNum:setString("0/0")
    --self._pCurCountTextNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pCurCountTextNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

    self._pInstanceNmaeText = params._pcopysname
    self._pInstanceNmaeText:setString(self._pDataInfo.Name)
    --self._pInstanceNmaeText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pInstanceNmaeText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

    -- 奖励物品
    self._tGoodsItemIconArry = {
        [1] = {params._pItem1Bg,params._pItem1},
        [2] = {params._pItem2Bg,params._pItem2},
        [3] = {params._pItem3Bg,params._pItem3},
    }
    
    self._pItem1Bg = params._pItem1Bg
    self._pItem2Bg = params._pItem2Bg
    self._pItem3Bg = params._pItem3Bg
    self._pReward = params._pReward 

    self._pLockImg = params._plock
    self._pNeedLevelText = params._plockText
    
    self._pSuggestCombatText = params._pbattlepower02
    self._pSuggestCombatText:setString(self._pDataInfo.RecommendedBP)
    self._pNodeLock = params._pNodeLock
    
    self._pTextNode1 = params._pTextNode1
    self._pText1Pos = self._pTextNode1:getPositionY()
    self._pTextNode1:setPositionY(self._pText1Pos - 50)
    
    self._pDownBg2 = params._pTextNode2
    self._pDownBg2:setVisible(false)
    self._pItemCost = params._pItem
    self._pItemCostNum = params._pCost
    if self._pDataInfo.Items ~= nil and self._pDataInfo.ItemNum ~= nil then
        self:setNeedItemInfo(self._pDataInfo.Items)
    end
    
    

    local sNode = self._pBgFrame:getContentSize()

    self._pCCS:setPosition(sNode.width/2, sNode.height/2)
    self:addChild(self._pCCS)
end

-- 设置可能掉落的物品图标
function CopysChallengeItem:setDropOutItems()
    if type(self._pDataInfo.MayDropItems) ~= "table" then
        return
    end
    local dropItemNum = #self._pDataInfo.MayDropItems
    for i,v in ipairs(self._tGoodsItemIconArry) do
        if i <= dropItemNum then
            v[1]:setVisible(true)
            v[2]:setVisible(true)
            if self._pDataInfo.MayDropItems[i][1] > 100 then 
                local pItemInfo = {id = self._pDataInfo.MayDropItems[i][1], baseType = self._pDataInfo.MayDropItems[i][2],}
                local itemIcon = GetCompleteItemInfo(pItemInfo).templeteInfo.Icon.. ".png"
                v[2]:setSpriteFrame(itemIcon)
            else
                local tFinanceInfo = FinanceManager:getIconByFinanceType(self._pDataInfo.MayDropItems[i][1])
                v[2]:setSpriteFrame(tFinanceInfo.filename)
            end
        else
            v[1]:setVisible(false)
            v[2]:setVisible(false)
        end
    end
end

-- 退出函数
function CopysChallengeItem:onExitInstanceItem()
    NetRespManager:getInstance():removeEventListenersByHost(self) 
    ResPlistManager:getInstance():removeSpriteFrames("ChallengeCopys.plist")
    ResPlistManager:getInstance():removeSpriteFrames("CopysBgLock.plist")
    ResPlistManager:getInstance():removeSpriteFrames("EnterIntoEffect.plist")
end

function CopysChallengeItem:setClickCallback(func)
	self._fClickCallback = func
end

function CopysChallengeItem:setUpdateCallback(func)
    self._fUpdateCallback = func
end

function CopysChallengeItem:updateQueryBattleList(event)
    local battleList = event.battleExts
    
    local isLocked = true

    if self._pDataInfo.Precondition ~= nil then
        self._tUnPrevStages = joinWithTables(self._tUnPrevStages,self._pDataInfo.Precondition)
    end

    for i=1,table.getn(battleList) do
        -- 判断当前关卡是否解锁
        if battleList[i].battleId == self._pDataInfo.ID then
            self:setCounts(battleList[i].extCount + self._pDataInfo.Times, battleList[i].currentCount)
            if self._pDataInfo.Items ~= nil and self._pDataInfo.ItemNum ~= nil then
                self:setNeedItemInfo(self._pDataInfo.Items)
            end
            self:setDropOutItems()
            isLocked = false
    	end
        -- 有前置关卡
        if self._pDataInfo.Precondition ~= nil then
          for j, battleId in ipairs(self._tUnPrevStages) do
               if battleList[i].battleId == battleId and battleList[i].bestStar > 0 then
                    table.remove(self._tUnPrevStages,j)
               end
          end
        end
    end
   
    if RolesManager:getInstance()._pMainRoleInfo.level >= self._pDataInfo.RequiredLevel and #self._tUnPrevStages < 1 then
        isLocked = false
    end
    
    if isLocked == true then
        if RolesManager:getInstance()._pMainRoleInfo.level < self._pDataInfo.RequiredLevel then --等级不足
            self._pNeedLevelText:setString("达到".. self._pDataInfo.RequiredLevel.."级")
        elseif RolesManager:getInstance()._pMainRoleInfo.level >= self._pDataInfo.RequiredLevel and #self._tUnPrevStages > 0 then
            self._pNeedLevelText:setString("通关".. self:getBattleNameById(self._tUnPrevStages[1]))
        end
        self._beLocked = true
        -- 未解锁特效
        self._pCopysLock = cc.CSLoader:createNode("CopysBgLock.csb")
        --self._pCopysLock:setPosition(self._pNodeLock:getPosition())
        self._pNodeLock:addChild(self._pCopysLock)
       local pCopysLockAct = cc.CSLoader:createTimeline("CopysBgLock.csb")
        pCopysLockAct:gotoFrameAndPlay(0,pCopysLockAct:getDuration(),true)
        pCopysLockAct:setTimeSpeed(0.3)
        self._pCopysLock:runAction(pCopysLockAct)
        darkNode(self._pBg:getVirtualRenderer():getSprite())
        
    else
        self._pCopysunLock = cc.CSLoader:createNode("EnterIntoEffect.csb")
        self._pCopysunLock:setPosition(cc.p(self._pCopyBg:getContentSize().width/2 , self._pCopyBg:getContentSize().height/2 + 60))
        self._pCopyBg:addChild(self._pCopysunLock,0)
       local pCopysunLockAct = cc.CSLoader:createTimeline("EnterIntoEffect.csb")
        pCopysunLockAct:gotoFrameAndPlay(0,pCopysunLockAct:getDuration(),true)
        pCopysunLockAct:setTimeSpeed(0.3)
        self._pCopysunLock:runAction(pCopysunLockAct)
    end
    self._pTextNode1:setVisible(isLocked == false)
    if self._pDataInfo.Items ~= nil and self._pDataInfo.ItemNum ~= nil then
        self._pDownBg2:setVisible(isLocked == false)
    end
    self._pBg:setTouchEnabled(isLocked == false)
    self._pItem1Bg:setVisible(isLocked == false)
    self._pItem2Bg:setVisible(isLocked == false)
    self._pItem3Bg:setVisible(isLocked == false)
    self._pReward:setVisible(isLocked == false)
    self._pEntryBtn:setVisible(isLocked == false)
    self._pLockImg:setVisible(isLocked)
end 

-- 通过挑战关卡id 找关卡名字
function CopysChallengeItem:getBattleNameById(nBattleId)
    return TableChallengeCopys[nBattleId - 400].Name
end

-- 设置关卡消耗
function CopysChallengeItem:setNeedItemInfo(info)
    if info == nil then
    	return
    end
    
    local pItemInfo = {id = info, baseType = 4}
    pItemInfo = GetCompleteItemInfo(pItemInfo)
    local itemIcon = pItemInfo.templeteInfo.Icon.. ".png"
    
    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            DialogManager:getInstance():showDialog("BagCallOutDialog",{pItemInfo,nil,nil,false})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    self._pItemCost:setTouchEnabled(true)
    self._pItemCost:addTouchEventListener(touchEvent)
    self._pItemCost:setSwallowTouches(true)

    self._pDownBg2:setVisible(true)
    self._pTextNode1:setPositionY(self._pText1Pos)
   
    self._pItemCost:loadTexture(itemIcon,ccui.TextureResType.plistType)
    local strMsg = string.format("%d/%d",BagCommonManager:getInstance():getItemNumById(info),self._pDataInfo.ItemNum)
    self._pItemCostNum:setString(strMsg)
end

function CopysChallengeItem:buyBattleNumResp21317(event)
    if self._pDataInfo.ID == event.copyId and event.copyType == self._pDataInfo.CopysType then 
        self._pCurCountTextNum:setString(self._nCurCount + 1 .."/"..self._nTotalCount)
        self._pCurCountTextNum:setColor(cGreen)
        self._nCurCount = self._nCurCount + 1
    end
end

return CopysChallengeItem
