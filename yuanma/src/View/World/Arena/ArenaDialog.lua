--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ArenaDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/04/23
-- descrip:   竞技场
--===================================================

local ArenaDialog = class("ArenaDialog",function() 
	return require("Dialog"):create()
end)

function ArenaDialog:ctor()
	self._strName = "ArenaDialog"
	self._pCloseButton = nil 
	self._pCCS = nil 
	self._pBg = nil 

	self._pPlayerNameText = nil
	self._pCurRankFntText = nil 
	self._pCurHonorNumText = nil 
	self._pWinNumText = nil 
	self._pRemainFightNumFntText = nil 
	self._pArenaGiftBtn = nil 
	self._pBoxCount = nil 
	self._pArenaGiftTimeDownText = nil
	self._pShowRankBtn = nil
	self._pHonorShopBtn = nil 
	
	self._pContainerNode = nil 

	self._pArenaPanel = nil 
	self._pArenaScrollView = nil 
	-- 免费刷新
	self._pRefreshTitleText = nil 
	self._pRefreshNumText = nil 
	self._pRefreshBtn = nil 	
	-- 钻石刷新
	self._pRmbIcon = nil 
	self._pRmbNum = nil 

	self._pArenaRankPanel = nil 
	self._pArenaRankScrollView = nil 
	-- 可领奖倒计时
	self._nTimeDiff = 0
	-- 当天剩余可领奖次数
	self._nBoxCount = 0
	-- 剩余免费刷新次数
	self._nRemainRefreshNum = 0
	-- 花钱刷新次数
	self._nDiamondRefreshNum = 0
	-- 角色剩余的挑战次数
	self._nRemainBattleNum = 0
	-- 角色头像
	RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
	-- 子面板
	self._tSubPanel = {}

	-- dataInfo 
	-- 挑战对手的数据信息
	self._pPvPRoleInfo = {}
	-- 按下时的放大尺寸
	self._fBigScale = 1.04
	-- 每次点击emailItem项时的位移
    self._fMoveDis = 0                        
end

function ArenaDialog:create(args)
	local dialog = ArenaDialog.new()
	dialog:dispose(args)
	return dialog
end

function ArenaDialog:dispose(args)
	ResPlistManager:getInstance():addSpriteFrames("PvpDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("PvpRender.plist")	
    ResPlistManager:getInstance():addSpriteFrames("RankingListRender.plist")
    ResPlistManager:getInstance():addSpriteFrames("RankingListPanel.plist")
	-- 挑战回复
	NetRespManager:getInstance():addEventListener(kNetCmd.kFightResp,handler(self,self.handleMsgFight21603))
	-- 查询排行榜回复
	NetRespManager:getInstance():addEventListener(kNetCmd.kQueryArenaRankResp,handler(self,self.handleMsgQueryArenaRank21607))
	-- 刷新对手列表
	NetRespManager:getInstance():addEventListener(kNetCmd.kRefreshEnemyResp,handler(self,self.handleMsgRefreshEnemy21609))
	-- 获取竞技场礼包
	NetRespManager:getInstance():addEventListener(kNetCmd.kDrawArenaBoxResp,handler(self,self.handleMsgDrawArenaBox21611))	
	 -- 注册购买商品的回调函数
    NetRespManager:getInstance():addEventListener(kNetCmd.kBuyGoods, handler(self,self.handleMsgBuyGoods20505))
    -- 新手中
    NetRespManager:getInstance():addEventListener(kNetCmd.kWorldLayerTouch,handler(self, self.handleTouchable))
    -- 购买战斗次数的网络回复
    NetRespManager:getInstance():addEventListener(kNetCmd.kBuyBattleResp ,handler(self, self.buyBattleNumResp21317))
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitArenaDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)

	 -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    self:initUI()
    -- 设置玩家的竞技场信息
    self:initPlayerInfo(args.pageInfo)
    -- 设置挑战对手列表
    self:setEnemyList(args.roleList)
    -- 更新刷新提示
	self:setRefreshTimeInfo()
end 

function ArenaDialog:initUI()
	local params = require("PvpDialogParams"):create()
	
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	-- 玩家信息相关节点	
	self._pPlayerNameText = params._pPlayerNameText
	self._pCurRankFntText = params._pRankingFont
	self._pCurHonorNumText = params._pHonorTextNum
	self._pWinNumText = params._pWinTextNum
	self._pRemainFightNumFntText = params._pLeaveFnt
	self._pArenaGiftBtn = params._pGiftsPic
	self._pArenaGiftBtn:setZoomScale(nButtonZoomScale)  
    self._pArenaGiftBtn:setPressedActionEnabled(true)
	self._pBoxCount = params._pText1
	self._pArenaGiftTimeDownText = params._pTimeNum
	self._pShowRankBtn = params._pRankingButton
	self._pShowRankBtn:setZoomScale(nButtonZoomScale)  
    self._pShowRankBtn:setPressedActionEnabled(true)
	self._pHonorShopBtn = params._pHonorShopButton
	self._pHonorShopBtn:setZoomScale(nButtonZoomScale)  
    self._pHonorShopBtn:setPressedActionEnabled(true)
	-- 右侧内容节点                                                                                                                            
	self._pContainerNode = params._pRightNode
	-- 竞技场相关信息
	self._pArenaPanel = params._pRightFrameImage
	self._pArenaScrollView = params._pScrollView
	self._pRefreshTitleText = params._pRefurbishText
	self._pRefreshBtn = params._pRefurbishButton
    self._pRefreshNumText = params._pTextTimeNum
	self._pRmbIcon = params._pRmbIcon
	-- 设置钻石的图标
	local financeInfo = FinanceManager:getInstance():getIconByFinanceType(kFinance.kDiamond)
	self._pRmbIcon:loadTexture(financeInfo.filename,financeInfo.textureType)
	self._pRmbNum = params._pRMBNum
	self:disposeCSB()
	table.insert(self._tSubPanel,self._pArenaPanel)
	-- 竞技场排行榜
	local arenaRankParams = require("RankingListPanelParams"):create()
	self._pRankPCCS = arenaRankParams._pCCS
	self._pArenaRankPanel = arenaRankParams._pBackGround
	self._pArenaRankScrollView = arenaRankParams._pScrollView 
	
	self._pContainerNode:addChild(self._pRankPCCS)
	-- 排行榜面板默认不可见
	self._pArenaRankPanel:setVisible(false)
	table.insert(self._tSubPanel,self._pArenaRankPanel)
	
	self:disposeTouchEvent()

end

-- 设置
function ArenaDialog:handleTouchable(event)
    if NewbieManager._pCurNewbieLayer ~= nil then
        self._pArenaScrollView:setTouchEnabled(false)
    else
        self._pArenaScrollView:setTouchEnabled(true)
    end
end

-- 处理界面的点击事件
function ArenaDialog:disposeTouchEvent()
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender:getTag() == 10002 then
				self:tagSelectedChanged()
			elseif sender:getTag() == 10001 then
				if self._nRemainRefreshNum > 0 then
					ArenaCGMessage:refreshEnemyReq21608()
				else
					local needDamondNum = TableConstants.RefreshPVPPrice.Value 
						+ (self._nDiamondRefreshNum - 1) * TableConstants.RefreshPVPPriceGrowth.Value
					local msg = string.format("确定消耗%d个玉璧进行刷新",needDamondNum)
            		showConfirmDialog(msg,function () ArenaCGMessage:refreshEnemyReq21608() end)
				end
			elseif sender:getTag() == 10003 then
                DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kHonorShop})
			elseif sender:getTag() == 10000 then
				if self._nBoxCount <= 0 then
					NoticeManager:getInstance():showSystemMessage("您还没有获得竞技场礼包")
					return
				elseif self._nTimeDiff > 0 then
					NoticeManager:getInstance():showSystemMessage("领取时间未到，请等待")
					return 
				end
                ArenaCGMessage:drawArenaBoxReq21610()	 
			end
		elseif eventType == ccui.TouchEventType.began then
       		AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	-- 竞技场礼包
	self._pArenaGiftBtn:setTag(10000)
	self._pArenaGiftBtn:addTouchEventListener(touchEvent)
	-- 刷新挑战对手
	self._pRefreshBtn:setTag(10001)
	self._pRefreshBtn:setVisible(false)
	self._pRefreshBtn:addTouchEventListener(touchEvent)
    --self._pRefreshBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pRefreshBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
	-- 打开排行榜(竞技场切换)
	self._pShowRankBtn:setTag(10002)
	self._pShowRankBtn:addTouchEventListener(touchEvent)
    --self._pShowRankBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pShowRankBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
	-- 荣誉商城
	self._pHonorShopBtn:setTag(10003)
	self._pHonorShopBtn:addTouchEventListener(touchEvent)
    --self._pHonorShopBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pHonorShopBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

end

-- 设置玩家的信息
function ArenaDialog:initPlayerInfo(args)
    self._pPlayerNameText:setString(RolesManager._pMainRoleInfo.roleName)
	self._pCurRankFntText:setString(args.rank)
	self._pCurHonorNumText:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kHR))
	self._pWinNumText:setString(args.winStreak)
	self._pRemainFightNumFntText:setString(args.remainCount)
	self._nRemainBattleNum = args.remainCount
	self._nRemainRefreshNum = args.remainRefresh
	self._nDiamondRefreshNum = args.diamondRefresh
	
	self._nTimeDiff = args.remainTime
    self._nBoxCount = args.boxCount
    self._pBoxCount:setString(self._nBoxCount)
end

-- 设置挑战对手列表
function ArenaDialog:setEnemyList(tEnemy)
	if type(tEnemy) ~= "table" then
		print("挑战列表不能为空")
		--return
	end
	table.sort(tEnemy,function(a,b)
        return a.rank < b.rank -- 从小到大排序
    end
    )
	-- 发起挑战
	local function challengeEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			AudioManager:getInstance():playEffect("ButtonClick")
			self._fMoveDis = 0
			sender:setScale(self._fBigScale)
		elseif eventType == ccui.TouchEventType.moved then
			self._fMoveDis = self._fMoveDis + 1
			if self._fMoveDis >= 5 then 
				sender:setScale(1)
			end
		elseif eventType == ccui.TouchEventType.ended then
			if sender:getScale() > 1 then
				-- 向服务器发送挑战协议
				if self._nRemainBattleNum <= 0 then 
					DialogManager:getInstance():showDialog("BuyStrengthDialog",{2,kCopy.kPVP, 0})
					return
				end
				ArenaCGMessage:fightReq21602(tEnemy[sender:getTag() - 5000].roleId)
			end
			sender:setScale(1)
			self._fMoveDis = 0
		end
	end

    self._pArenaScrollView:removeAllChildren()
   
    local nInnerHeight = self._pArenaScrollView:getContentSize().height
	local nInnerWidth = self._pArenaScrollView:getInnerContainerSize().width
    local nRenderHeight = 160
	nInnerHeight = math.max(nInnerHeight,#tEnemy * nRenderHeight)
    self._pArenaScrollView:setInnerContainerSize(cc.size(nInnerWidth,nInnerHeight))
	for index,enemyInfo in ipairs(tEnemy) do
		local pEnemyRender = require("PvpRenderParams"):create()
		pEnemyRender._pRakingBg:setSwallowTouches(false)
		-- 头像
        pEnemyRender._pHeadIcon:loadTexture(RoleIcons[enemyInfo.roleCareer],ccui.TextureResType.plistType)
        -- pEnemyRender._pHeadIcon:setScale(0.5)
		-- 等级
        pEnemyRender._pOverPLvText:setString("Lv".. enemyInfo.level)
		-- nickName
        pEnemyRender._pOverPaiHangName:setString(enemyInfo.name)
		-- 排行
        pEnemyRender._pOverPaiHangNum:setString(enemyInfo.rank)
		-- 战斗力
		pEnemyRender._pOverPowerFnt:setString(enemyInfo.fightingPower)
		-- 奖励物品相关
		local rewardArry = self:getRewardItemByRank(enemyInfo.rank)
		local innerWidth = 0
		local innerHeight = pEnemyRender._pGiftScrollView:getContentSize().height
		for i,v in ipairs(rewardArry) do
            local financeInfo = FinanceManager:getInstance():getIconByFinanceType(v[1])
			if i == 1  then				
				pEnemyRender._pGiftIcon1:loadTexture(financeInfo.filename,financeInfo.textureType)
				pEnemyRender._pGift1Num:setString(v[2])
			else
				local itemNode = pEnemyRender._pItemNode:clone()
				local pGifIcon = itemNode:getChildByName("GiftIcon1")
				pGifIcon:loadTexture(financeInfo.filename,financeInfo.textureType)
				itemNode:getChildByName("Gift1Num"):setString(v[2])
                itemNode:setPositionX(pGifIcon:getContentSize().width * (i - 1) * pGifIcon:getScaleX() + 20)
				innerWidth = pGifIcon:getContentSize().width * pGifIcon:getScaleX() + innerWidth
				pEnemyRender._pGiftScrollView:addChild(itemNode)
			end
		end
		if innerWidth > pEnemyRender._pGiftScrollView:getInnerContainerSize().width then
		 	pEnemyRender._pGiftScrollView:setInnerContainerSize(cc.size(innerWidth,innerHeight))
		 	pEnemyRender._pGiftScrollView:setBounceEnabled(true)
            pEnemyRender._pGiftScrollView:setTouchEnabled(true)
		else
			pEnemyRender._pGiftScrollView:setBounceEnabled(false)
			pEnemyRender._pGiftScrollView:setTouchEnabled(false)
		end
		-- 挑战按钮
        pEnemyRender._pPvpButton:setTag(5000 + index)
        pEnemyRender._pPvpButton:setSwallowTouches(false)
		pEnemyRender._pPvpButton:addTouchEventListener(challengeEvent)
		-- pEnemyRender 锚点（0.5，1）
        pEnemyRender._pCCS:setPosition(cc.p(nInnerWidth / 2,nInnerHeight - nRenderHeight * (index - 1)))     
		self._pArenaScrollView:addChild(pEnemyRender._pCCS)
	end
    
end

-- 设置排行榜数据列表getPreferredSize 

function ArenaDialog:setRankList(tPlayer) 
    self._pArenaRankScrollView:removeAllChildren() 
   	local nRenderHeight = 100
    local nInnerHeight = self._pArenaRankScrollView:getContentSize().height
	local nInnerWidth = self._pArenaRankScrollView:getInnerContainerSize().width
    nInnerHeight = math.max(nInnerHeight,#tPlayer * nRenderHeight)
   	self._pArenaRankScrollView:setInnerContainerSize(cc.size(nInnerWidth,nInnerHeight))
    for i,roleArenaInfo in ipairs(tPlayer) do
        local roleArenaInfo = tPlayer[i]
		local pRender = require("RankingListRenderParams"):create()
		-- 背景图隔行显示
		-- pRender._pListBg:setVisible(idx % 2 > 0)
		-- 排行
		pRender._pText1:setString(roleArenaInfo.rank)
		-- 昵称
		pRender._pText2:setString(roleArenaInfo.name)
		-- 等级
		pRender._pText3:setString(roleArenaInfo.level)
		-- 职业
		pRender._pText4:setString(kRoleCareerTitle[roleArenaInfo.roleCareer])
		pRender._pText4:setColor(kRoleCareerFontColor[roleArenaInfo.roleCareer])
		-- 战斗力
		pRender._pText5:setString(roleArenaInfo.fightingPower)
        -- 九宫格图片获得实际尺寸的方法
		pRender._pCCS:setPosition(cc.p(nInnerWidth / 2, nInnerHeight - nRenderHeight * ( i - 1)))
		self._pArenaRankScrollView:addChild(pRender._pCCS)
		-- 前3名特殊处理
		if roleArenaInfo.rank < 4 then
			pRender._pText1:setVisible(false)
            local rankSpr = cc.Sprite:createWithSpriteFrameName("RankingListRender/pvpjm".. roleArenaInfo.rank + 1 ..".png")
			rankSpr:setPosition(pRender._pText1:getPosition()) 
            rankSpr:setPositionY(pRender._pText1:getPositionY() + 2)      
			pRender._pCCS:addChild(rankSpr)
		end
	end
       
end

-- 定时器（循环更新）
function ArenaDialog:update(dt)
	self:updateGetGiftTime(dt)
end

-- 更新玩家的领奖倒计时
function ArenaDialog:updateGetGiftTime(dt)
    if not self._nTimeDiff then
        return 
    end
	if self._nTimeDiff > 0 then 
        local format = gTimeToStr(self._nTimeDiff)
        self._pArenaGiftTimeDownText:setString(format)
        self._nTimeDiff = self._nTimeDiff - dt
    else
    	if self._nBoxCount > 0 then 
            self._pArenaGiftTimeDownText:setString("可领取")
        else
        	self._pArenaGiftTimeDownText:setString("没有礼包")
        end
	end
end


function ArenaDialog:tagSelectedChanged()
	 for k,subPanel in pairs(self._tSubPanel) do
	 	subPanel:setVisible(subPanel:isVisible()== false)
	 end
	 if self._pArenaPanel:isVisible() == true then
	 	self._pShowRankBtn:setTitleText("排行榜")        
	 else
	 	self._pShowRankBtn:setTitleText("竞技场")
        ArenaCGMessage:queryArenaRankReq21606(0,50)
	 end	
end

-- 挑战对手请求回复
function ArenaDialog:handleMsgFight21603(event)
	self._pPvPRoleInfo = event.roleInfo
	self:entryBattleCopy()
end

-- 查询竞技场旁行榜
function ArenaDialog:handleMsgQueryArenaRank21607(event)
	if event.roleList ~= nil then 
		self:setRankList(event.roleList)
	end
end

-- 刷新对手列表
function ArenaDialog:handleMsgRefreshEnemy21609(event)
	-- 更新刷新次数
	self._nRemainRefreshNum = self._nRemainRefreshNum - 1
	if self._nRemainRefreshNum <= 0 then
		self._nDiamondRefreshNum = self._nDiamondRefreshNum + 1
    end
    self:setRefreshTimeInfo()
    self:setEnemyList(event.roleList)
end

-- 竞技场领奖
function ArenaDialog:handleMsgDrawArenaBox21611(event)
	self._nBoxCount = event.boxCount
	self._nTimeDiff = event.remainTime
    self._pBoxCount:setString(self._nBoxCount)
end

-- 设置刷新信息
function ArenaDialog:setRefreshTimeInfo()
	-- 设置控件的可见性
	--self._pRmbNum:setVisible(self._nRemainRefreshNum <= 0)
	--self._pRmbIcon:setVisible(self._nRemainRefreshNum <= 0)
	--self._pRefreshTitleText:setVisible(self._nRemainRefreshNum > 0)
	--self._pRefreshNumText:setVisible(self._nRemainRefreshNum > 0)
	
	if self._nRemainRefreshNum > 0 then
		self._pRefreshNumText:setString(self._nRemainRefreshNum)
	else
		local needDamondNum = TableConstants.RefreshPVPPrice.Value 
		+ (self._nDiamondRefreshNum - 1) * TableConstants.RefreshPVPPriceGrowth.Value
        self._pRmbNum:setString(needDamondNum)
	end
end

--进入战斗
function ArenaDialog:entryBattleCopy()
	-- 随机获得挑战本的地图信息
	local nRandomNum = getRandomNumBetween(1,#TablePVPCopysMaps)
	self._pSelectedCopysDataInfo = TablePVPCopysMaps[nRandomNum]

    if self._pSelectedCopysDataInfo ~= nil and  self._pPvPRoleInfo ~= nil then
        --战斗数据组装
        -- 【战斗数据对接】
        local args = {}
        args._strNextMapName = self._pSelectedCopysDataInfo.MapsName
        args._strNextMapPvrName = self._pSelectedCopysDataInfo.MapsPvrName
        args._nNextMapDoorIDofEntity = self._pSelectedCopysDataInfo.Doors[1][1]
        --require("TestMainRoleInfo")    --roleInfo  
        args._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo
        args._nMainPlayerRoleCurHp = nil      -- 从副本进入时，这里为无效值
        args._nMainPlayerRoleCurAnger = nil   -- 从副本进入时，这里为无效值
        args._nMainPetRoleCurHp = nil         -- 从副本进入时，这里为无效值
        args._nCurCopyType = kCopy.kPVP
        args._nCurStageID = self._pSelectedCopysDataInfo.ID
        args._nCurStageMapID = self._pSelectedCopysDataInfo.MapID
        args._nBattleId = 0
        args._fTimeMax = TableConstants.PVPTime.Value
        args._bIsAutoBattle = false
        args._tMonsterDeadNum = {}
        args._nIdentity = 0
        args._tTowerCopyStepResultInfos = {}
        -- 拼接挑战对手的信息
        local pvpRoleInfo = {}
        pvpRoleInfo.level = self._pPvPRoleInfo.level
        pvpRoleInfo.equipemts = self._pPvPRoleInfo.equipemts
        pvpRoleInfo.roleName = self._pPvPRoleInfo.roleName
        pvpRoleInfo.roleCareer = self._pPvPRoleInfo.roleCareer
        pvpRoleInfo.roleId = self._pPvPRoleInfo.roleId
        pvpRoleInfo.fashionOptions = self._pPvPRoleInfo.fashionOptions
        pvpRoleInfo.roleAttrInfo = self._pPvPRoleInfo.roleAttrInfo
        args._pPvpRoleInfo = pvpRoleInfo
        RolesManager:getInstance()._pPvpRoleInfo = pvpRoleInfo
        -- 设置挑战对手的技能信息
        args._tPvpRoleMountAngerSkills = self:getPvpMountAngerSkills()
        args._tPvpRoleMountActvSkills = self._pPvPRoleInfo.mountSkills 
        args._tPvpPasvSkills = self._pPvPRoleInfo.pasvSkills
        -- 设置挑战对手的宠物信息
        args._tPvpPetRoleInfosInQueue = {}
        for i,v in ipairs(self._pPvPRoleInfo.pets) do
        	args._tPvpPetRoleInfosInQueue[i] = v.petInfo
        end
       
        --关闭当前打开的Dialog
        self:getGameScene():closeDialogByNameWithNoAni("ArenaDialog")
        --切换战斗场景
        LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
    end
end

-- 获得pvp装载的怒气技能
function ArenaDialog:getPvpMountAngerSkills()
	local tAngerSkills = {} 
	for i,mountSkill in ipairs(self._pPvPRoleInfo.mountSkills) do
		local skillInfo = SkillsManager:getInstance():getPvpRoleSkillDataByID(mountSkill.id,mountSkill.level)
		if skillInfo.SkillType == 5 then
			table.insert(tAngerSkills,mountSkill)
			-- 删除装备的怒气技能
			table.remove(self._pPvPRoleInfo.mountSkills,i)
		end
	end
	return tAngerSkills
end

-- 根据排名获得奖励的货币信息（类型，数量）
function ArenaDialog:getRewardItemByRank(rankIndex)
	local itemIdx = 0 
	local recentlyNum = 0
	for i,v in ipairs(TableArena) do
		if v.Ranking > rankIndex then
			break
		end
		if i == 1 then
			recentlyNum =  rankIndex - v.Ranking 
			itemIdx = 1
		else
			if rankIndex - v.Ranking < recentlyNum then
				recentlyNum = rankIndex - v.Ranking
				itemIdx = i
			end
		end
	end
	return TableArena[itemIdx].WinReward
end

function ArenaDialog:handleMsgBuyGoods20505(event)
	-- 刷新玩家的荣誉值
	self._pCurHonorNumText:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kHR))
end

-- 购买挑战次数的网络回调
function ArenaDialog:buyBattleNumResp21317(event)
	if event.copyType == kCopy.kPVP then 
		self._nRemainBattleNum = self._nRemainBattleNum + 1
		self._pRemainFightNumFntText:setString(self._nRemainBattleNum)
 	end
end

function ArenaDialog:onExitArenaDialog()
	self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("PvpDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("PvpRender.plist")   
    ResPlistManager:getInstance():removeSpriteFrames("RankingListRender.plist")
    ResPlistManager:getInstance():removeSpriteFrames("RankingListPanel.plist")
	NetRespManager:getInstance():removeEventListenersByHost(self)
end

return ArenaDialog