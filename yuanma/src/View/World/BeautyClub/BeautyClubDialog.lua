--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BeautyClubDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/02/03
-- descrip:   群芳阁系统
--===================================================
local BeautyClubDialog = class("BeautyClubDialog",function() 
	return require("Dialog"):create()
end)

-- 构造函数
function BeautyClubDialog:ctor()
	-- 层名字
	self._strName = "BeautyClubDialog"
	-- 美人头像列表容器
	self._pBeautyIconList = nil 
	-- 美人头像itemCell 
	self._pBeautyIconItemCell = nil 
	-- 美人组合列表容器
	self._pBeautyGroupList = nil 
	-- 美人组合itemCell  
	self._pBeautyGroupItemCell = nil 
	-- 玩家的货币图标
	self._pCoinIcon = nil 
	-- 玩家的货币数量
	self._pCoinNumText = nil
	-- 美人大图
	self._pBeautyPicLayer = nil 
	self._pBeautyPicNode = nil 
	-- 美人大图的亲密特效
	self._pKissParicle = nil
	-- 美人组解锁特效
	self._pBeautyGroupUnLockAni = nil 
	self._pBeautyGroupUnLockNode = nil 
	-- 美人组成
	self._tBeautyGroupListArry = {}
	-- 美人互动时间间隔
	self._nTimeDiff = 0
	-- 美人互动剩余次数
	self._nKissRemainNum = 0
	-- 是否需要刷新美人组数据
	self._isNeedUpdateBeautyList = false
	-- 当前大图显示的美人信息
	self._pCurBagPicBeautyInfo = nil 
	-- 美人管理器
	self._pBeautyManager = BeautyManager:getInstance()
	------------------------------------------------------
	-- 美人头像容器
	self._pBeautyIconListController = nil 
	-- 默认选中美人头像的索引
	self._curBeautyIconSelectedIndex = 1
	-- 美人组容器
	self._pBeautyGroupListController = nil 

end

-- 创建函数
function BeautyClubDialog:create(args)
	local dialog = BeautyClubDialog.new()
	dialog:dispose(args)
	return dialog
end

-- 处理函数
function BeautyClubDialog:dispose(args)
	self:setNeedCache(true)
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "群芳阁按钮" , value = false})
	
	-- 美人互动
	NetRespManager:getInstance():addEventListener(kNetCmd.kKissBeauty, handler(self,self.handleMsgKissBeauty20803))
	-- 美人激活
    NetRespManager:getInstance():addEventListener(kNetCmd.kBeautyAwake, handler(self,self.handleMsgBeautyAwake20805))
	-- 加载 群芳阁资源合图
    ResPlistManager:getInstance():addSpriteFrames("BeautyClub.plist")
    -- 美人头像列表合图
    ResPlistManager:getInstance():addSpriteFrames("BeautyListInfo.plist")
    -- 美人组合图
    ResPlistManager:getInstance():addSpriteFrames("BeautyArmyList.plist") 
    -- 美人大图   
    ResPlistManager:getInstance():addSpriteFrames("BelleBigPicture.plist")
	-- 加载 群芳阁美人大图合图
	ResPlistManager:getInstance():addSpriteFrames("beauties_bg.plist")
    ResPlistManager:getInstance():addSpriteFrames("beauties_bg1.plist")
    -- 加载美人亲密升级纹理
    ResPlistManager:getInstance():addSpriteFrames("LoveUpEffect.plist")
	--初始化界面UI 
	self:initUI()
	-- 结点事件 
	local function onNodeEvent(event)
        if event == "exit" then
			self:onExitBeautyClubDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	-- 初始化触摸相关
	self:initTouches()
	-- 初始化数据 
	self._nTimeDiff = args[1]
	self._nKissRemainNum = args[2]

	self:checkBeautyGroupUnLockAni()

end

-- 初始化界面UI 
function BeautyClubDialog:initUI()
	-- 加载 cocosStudio
	local params = require("BeautyClubParams"):create()
	self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton 
	-- 美人头像相关
	self._pBeautyIconList = params._pLeftScrollView
	self._pBeautyPicNode = params._pBelleBigNode
	-- 美人组相关
	self._pBeautyGroupList = params._pRightLeftScrollView
	-- 货币相关
	self._pCoinIcon = params._pcurrencyicon
    self._pCoinNumText = params._pMoneyNumText

	self:disposeCSB()
	-- 设置美人头像列表
	self:setBeautyListDataSource(self._pBeautyManager._tBeautyModelList)
	-- 设置美人组列表
	self:setBeautyGroupListDataSource(self._pBeautyManager._tBeautyGroupModelList)
	-- 初始化玩家的金币信息
	self:showCoinsInfo(kFinance.kCoin)
	-- 设置美人的的大图
	self:initBeautyPic()

end

-- 设置美人头像数据源
function BeautyClubDialog:setBeautyListDataSource(tBeautyModels)
	if type(tBeautyModels) ~= "table" then
		return
	end
	self._pBeautyIconListController = require("ListController"):create(self,
	   self._pBeautyIconList,listLayoutType.LayoutType_vertiacl,310,130)
	self._pBeautyIconListController:setVertiaclDis(10)	
	-- 获取集合的个数
	self._pBeautyIconListController._pNumOfCellDelegateFunc = function () 
		return #tBeautyModels
	end
	self._pBeautyIconListController._pDataSourceDelegateFunc = function (delegate,controller,index)
		local cell = controller:dequeueReusableCell()
		if not cell then 
			cell = require("BeautyIconItemRender"):create(tBeautyModels[index])
			cell:setIndex(index)
			cell:setCallbackFunc(function (index) 
				-- 清除上次选中的状态
				if self._curBeautyIconSelectedIndex > 0 then 
					local cell = self._pBeautyIconListController:cellWithIndex(self._curBeautyIconSelectedIndex)
					if cell then 
						cell:changeSelectEvent(false)
					end
				end
				self._curBeautyIconSelectedIndex = index
				-- 显示美人大图
				self:showBeautyPic(tBeautyModels[index])
			end)
		else 
			cell:setDataSource(tBeautyModels[index])
		end 
		return cell
	end
	-- 设置美人头像数据源
	self._pBeautyIconListController:setDataSource(tBeautyModels)
	-- 默认选中第一项
    local cell = self._pBeautyIconListController:cellWithIndex(self._curBeautyIconSelectedIndex)
    if cell then 
    	cell:changeSelectEvent(true)
    end
end

-- 设置美人组数据源
function BeautyClubDialog:setBeautyGroupListDataSource(tBeautyGroupModels)
	if type(tBeautyGroupModels) ~= "table" then
		return 
	end
	self._pBeautyGroupListController = require("ListController"):create(self,
	   self._pBeautyGroupList,listLayoutType.LayoutType_vertiacl,640,303)
	self._pBeautyGroupListController:setVertiaclDis(10)	

	self._pBeautyGroupListController._pNumOfCellDelegateFunc = function () 
		return #tBeautyGroupModels
	end

	self._pBeautyGroupListController._pDataSourceDelegateFunc = function (delegate,controller,index)
		local cell = controller:dequeueReusableCell()
		if not cell then 
			cell = require("BeautyGroupItemRender"):create()
			cell:setIndex(index)
			cell:setDataSource(tBeautyGroupModels[index])
		else
			cell:setDataSource(tBeautyGroupModels[index])
		end 
		return cell
	end
	-- 设置美人组数据源
	self._pBeautyGroupListController:setDataSource(tBeautyGroupModels)
end

-- 加载美人大图
function BeautyClubDialog:initBeautyPic()
	-- 美人大图
	self._pBeautyPicLayer = require("BelleBigPictureParams"):create()
   -- 美人大图的收起按钮
   local function onHidePicBtnClick(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
		   self._pBeautyPicLayer._pCCS:setVisible(false)
		   self._pBeautyGroupList:setVisible(true)
		elseif eventType == ccui.TouchEventType.began then
      	   AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	-- 美人大图的收起按钮
	local pHideBtn = self._pBeautyPicLayer._pCloseButton
	pHideBtn:addTouchEventListener(onHidePicBtnClick)
	pHideBtn:setZoomScale(nButtonZoomScale)
	pHideBtn:setPressedActionEnabled(true)
	-- 风景图屏蔽 向下传递事件
	local function onClickBeautyImg(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			return true
		end
	end
	self._pBeautyPicLayer._pBelleImage:setTouchEnabled(true)
	self._pBeautyPicLayer._pBelleImage:addTouchEventListener(onClickBeautyImg)
	-- 美人大图的亲密按钮
	local function onKissBeautyBtnClick(sender,eventType)
		if eventType == ccui.TouchEventType.began then
      	    AudioManager:getInstance():playEffect("ButtonClick")
			if self._nTimeDiff > 0 then 
				return true
			end
		end
		if eventType == ccui.TouchEventType.ended then
			if self._nTimeDiff > 0 then 
				NoticeManager:getInstance():showSystemMessage("cd中请稍后再来。")
				return 
			end
			if self._nKissRemainNum > 0 then
				if self._pCurBagPicBeautyInfo.haveSeen == false then
					NoticeManager:getInstance():showSystemMessage("你还没有"..self._pCurBagPicBeautyInfo.templeteInfo.Name.."。")
				else
					BeautyClubSystemCGMessage:kissBeutyReq20802(sender:getTag() - 10000)
				end
			else
				NoticeManager:getInstance():showSystemMessage("今天的亲密次数已用尽，请您明天再来")
			end
		end
	end
	-- 美人大图的亲密按钮
	local pKissBtn = self._pBeautyPicLayer._pQinButton
	pKissBtn:addTouchEventListener(onKissBeautyBtnClick)
	pKissBtn:setZoomScale(nButtonZoomScale)
	pKissBtn:setPressedActionEnabled(true)
	self._pBeautyPicNode:addChild(self._pBeautyPicLayer._pCCS)
	-- 默认不显示
	self._pBeautyPicLayer._pCCS:setVisible(false)

	-- 亲密的提示红点
	local warningSprite = cc.Sprite:createWithSpriteFrameName("MainIcon/mail03.png")
	warningSprite:setPosition(155,60)
    warningSprite:setScale(0.5)
    warningSprite:setVisible(false)
    warningSprite:setName("warningSprite") 
    warningSprite:setAnchorPoint(cc.p(0.5, 0.5))
    pKissBtn:addChild(warningSprite)

	self._pKissParicle = cc.ParticleSystemQuad:create("ParticleHeartEffect.plist")
    local parent = cc.ParticleBatchNode:createWithTexture(self._pKissParicle:getTexture())
    self._pKissParicle:setPositionType(cc.POSITION_TYPE_GROUPED)
    self._pKissParicle:stopSystem()
    parent:setScale(2)
    parent:addChild(self._pKissParicle)
    local s = self._pBeautyPicLayer._pBellePicture01:getContentSize()
    parent:setPosition(s.width/2, s.height/2)
    -- 美人大图
    self._pBeautyPicLayer._pBellePicture01:addChild(parent)

    -- 美人大图亲密度的进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName("BelleBigPictureRes/jqfb025.png")
    local pLoadingBar = cc.ProgressTimer:create(pSprite)
    pLoadingBar:setPosition(self._pBeautyPicLayer._pQinMiBar:getPosition())
    pLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pLoadingBar:setMidpoint(cc.p(0, 0))
    pLoadingBar:setBarChangeRate(cc.p(1, 0))
    pLoadingBar:setPercentage(0)
    self._pBeautyPicLayer._pQinMinBarBg:addChild(pLoadingBar)
    self._pBeautyPicLayer._pQinMiBar:removeFromParent()
    self._pBeautyPicLayer._pQinMiBar = nil 
    self._pBeautyPicLayer._pQinMiBar = pLoadingBar

    -- 美人亲密升级动画
   	self._pLoveUpGradeAni = cc.CSLoader:createNode("LoveUpEffect.csb")
    self._pLoveUpGradeAni:setPosition(s.width/2,s.height/2)
    self._pBeautyPicLayer._pBellePicture01:addChild(self._pLoveUpGradeAni)
    self._pLoveUpGradeAni:setVisible(false)

end

-- 显示美人大图
function BeautyClubDialog:showBeautyPic(beautyModel)
	self._pBeautyGroupList:setVisible(false)
	self._pBeautyPicLayer._pQinButton:setTag(10000 + beautyModel.dataInfo.ID)
   	-- 美人的大图
   	self._pBeautyPicLayer._pBellePicture01:loadTexture(beautyModel.templeteInfo.BeautyImage..".png",ccui.TextureResType.plistType)
   	-- 当前等级要求的经验值
   	local prevExp = beautyModel.level > 0 and beautyModel.dataInfo.RequiredLevel[beautyModel.level] or 0
   	-- 升级需要的经验
   	local needExp = beautyModel.dataInfo.RequiredLevel[beautyModel.level + 1] - prevExp
	-- 美人的亲密等级
    self._pBeautyPicLayer._pQinMiBar:setPercentage((beautyModel.expValue - prevExp)/needExp * 100)
	-- 亲密等级
	self._pBeautyPicLayer._pQmLvText:setString("lv" ..beautyModel.level)
	-- 亲密进度条文字
	self._pBeautyPicLayer._pQinMinNumText:setString((beautyModel.expValue - prevExp)/needExp * 100 .."%")
	self._pBeautyPicLayer._pQinMinNumText:setPositionZ(100)
	-- 美人互动的剩余次数
	self._pBeautyPicLayer._pRemainNumText:setString("互动剩余次数："..self._nKissRemainNum)
	-- 美人的名字
	--self._pBeautyPicLayer:getChildByName("kissname"):setString(beautyModel.templeteInfo.Name
    self._pBeautyPicLayer._pCCS:setVisible(true)
    -- 如果美人没有遇见则图片置灰
    if beautyModel.haveSeen == false then 
    	darkNode(self._pBeautyPicLayer._pBellePicture01:getVirtualRenderer():getSprite())
    else
        unDarkNode(self._pBeautyPicLayer._pBellePicture01:getVirtualRenderer():getSprite())
    end
    
    -- 当前美人大图显示的美人信息
    self._pCurBagPicBeautyInfo = beautyModel
   	self:checkShowQinMiWarn()
end

function BeautyClubDialog:checkShowQinMiWarn()
	-- 是否显示可亲密提示
    local warningSprite = self._pBeautyPicLayer._pQinButton:getChildByName("warningSprite")
    local bNeedShowSprite = true
    if self._nTimeDiff > 0 then 
		bNeedShowSprite = false
	end
	if self._nKissRemainNum > 0 then
		if self._pCurBagPicBeautyInfo == nil then 
			bNeedShowSprite = false
		end
		if self._pCurBagPicBeautyInfo ~= nil and self._pCurBagPicBeautyInfo.haveSeen == false then
			bNeedShowSprite = false
		end
	else
		bNeedShowSprite = false
	end
	warningSprite:setVisible(bNeedShowSprite)
end

-- 亲密特效
function BeautyClubDialog:showKissBeautyAni()
	self._pKissParicle:resetSystem()
end

-- 美人亲密升级特效
function BeautyClubDialog:showLoveUpgradeAni()
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "end" then
            self._pLoveUpGradeAni:setVisible(false)    
        end
    end
    self._pLoveUpGradeAni:setVisible(true)
    local pLoveUpGradeAction = cc.CSLoader:createTimeline("LoveUpEffect.csb")
    pLoveUpGradeAction:setFrameEventCallFunc(onFrameEvent)
    pLoveUpGradeAction:gotoFrameAndPlay(0,33,false)
    self._pLoveUpGradeAni:stopAllActions()
    self._pLoveUpGradeAni:runAction(pLoveUpGradeAction)
end

-- 美人组解锁特效
function BeautyClubDialog:showBeautyGroupUnLockAni(itemCell)
	local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playAni" then
            local boomParicle = cc.ParticleSystemQuad:create("ParticleBeautyUnblockEffect02.plist")
		    local parent = cc.ParticleBatchNode:createWithTexture(boomParicle:getTexture())
		    boomParicle:setPositionType(cc.POSITION_TYPE_GROUPED)
		    parent:addChild(boomParicle)
		    self._pBeautyGroupUnLockNode:addChild(parent)
		    local function playOver()
		    	self:checkBeautyGroupUnLockAni()
		    end
		    parent:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(playOver)))
        end
    end
	if not self._pBeautyGroupUnLockNode then 
		self._pBeautyGroupUnLockNode = cc.CSLoader:createNode("BeautyGroupUnLock.csb")
		local s = cc.size(626,250)
		--self._pBeautyGroupUnLockNode:setPosition(cc.p(s.width/2,s.height/2))
		self._pBeautyGroupUnLockNode:setPosition(cc.p(itemCell:getPositionX(),itemCell:getPositionY()))
		self._pBeautyGroupUnLockAni = cc.CSLoader:createTimeline("BeautyGroupUnLock.csb")
        self._pBeautyGroupList:addChild(self._pBeautyGroupUnLockNode)
        self._pBeautyGroupUnLockNode:stopAllActions()
        self._pBeautyGroupUnLockAni:setFrameEventCallFunc(onFrameEvent)
        self._pBeautyGroupUnLockAni:gotoFrameAndPlay(0,85,false)
        self._pBeautyGroupUnLockNode:runAction(self._pBeautyGroupUnLockAni)
    else
    	local s = cc.size(626,250)
    	self._pBeautyGroupUnLockNode:setPosition(cc.p(itemCell:getPositionX(),itemCell:getPositionY()))
    	self._pBeautyGroupUnLockAni:gotoFrameAndPlay(0,85,false)
	end
	
end

function BeautyClubDialog:checkBeautyGroupUnLockAni()
	-- 判断是否播放美人组解锁特效
	local roleLevel = RolesManager:getInstance()._pMainRoleInfo.level
	self._pBeautyManager:getBeautyGroupUnlockId()
	local groupNum = #self._pBeautyManager._tBeautyGroupModelList
	for index,beautyGroupModel in ipairs(self._pBeautyManager._tBeautyGroupModelList) do
		local isReachLevel = roleLevel >= beautyGroupModel.dataInfo.RequiredLevel
		if beautyGroupModel.id > self._pBeautyManager._nCurUnLockGroupId then 
			if isReachLevel then 
				self._pBeautyManager:setBeautyGroupUnLockId(beautyGroupModel.id)
				local itemCell = self._pBeautyGroupListController:cellWithIndex(index)
				local percent = (index - 1) / (groupNum - 1) *  100
				self._pBeautyGroupList:jumpToPercentVertical(percent)
				self:showBeautyGroupUnLockAni(itemCell)
				break		
			end
		end
	end
end

-- 美人组全部激活特效
function BeautyClubDialog:showBeautyGroupActiveAni(itemCell)
	local activeAni = cc.CSLoader:createNode("ParticlesBiankuangjihuo.csb")
	local s = itemCell._pBg:getContentSize()
	activeAni:setPosition(cc.p(s.width/2,s.height/2))
	itemCell._pBg:addChild(activeAni)
	local activeAction = cc.CSLoader:createTimeline("ParticlesBiankuangjihuo.csb")	
	activeAni:stopAllActions()
	activeAction:gotoFrameAndPlay(0,80,false)
	activeAni:runAction(activeAction)

	local function showOver()
		activeAni:removeFromParent(true)
	end
    activeAni:runAction(cc.Sequence:create(cc.DelayTime:create(80*cc.Director:getInstance():getAnimationInterval()),cc.CallFunc:create(showOver)))
end

-- 循环更新
function BeautyClubDialog:update(dt)
    if not self._nTimeDiff then
        return 
    end
	if self._nTimeDiff > 0 then 
		self._nTimeDiff =  self._nTimeDiff - dt
        local format = gTimeToStr(self._nTimeDiff)
        self._pBeautyPicLayer._pQinButton:setTitleText("剩余"..format)
        if self._nTimeDiff <= 0 then 
        	self._pBeautyPicLayer._pQinButton:setTitleText("亲密一下")
        	self:checkShowQinMiWarn()
        end
	end
end

-- 美人互动的网络回调函数
function BeautyClubDialog:handleMsgKissBeauty20803(args)
	-- 亲密特效
	self:showKissBeautyAni()
	-- 互动剩余时间
	self._nTimeDiff = args.timeDiff
	-- 互动剩余次数
    self._nKissRemainNum = args.remainNum
    self._isNeedUpdateBeautyList = args.levelUpgrade
    if self._isNeedUpdateBeautyList  then 
    	-- 表示亲密已经升级 
    	local previousLevel = args.previousLevel
    	local upgradeNum = args.beautyModel.level - previousLevel 
    	local tPerent = {}
    	for i = 1,upgradeNum do
    		tPerent[i] = {100,previousLevel + i - 1}
    	end
    	self:setKissBarPercent(tPerent)

    	self._pBeautyGroupListController:setDataSource(self._pBeautyManager._tBeautyGroupModelList)
    end
    -- 更新美人头像数据
	self._pBeautyIconListController:setDataSource(self._pBeautyManager._tBeautyModelList)
	self:showBeautyPic(args.beautyModel)
end

-- 激活美人的网络回调函数
function BeautyClubDialog:handleMsgBeautyAwake20805(args)
	--local itemCell = self._tSelectedGropItems[args.groupId][args.index]
	local itemCell = self._pBeautyGroupListController:cellWithIndex(args.groupId)
	if itemCell ~= nil then
		itemCell:setDataSource(self._pBeautyManager._tBeautyGroupModelList[args.groupId])
		-- 设置美人头像列表
		self._pBeautyIconListController:setDataSource(self._pBeautyManager._tBeautyModelList)
	end
	-- 如果没人组全部激活
   	if itemCell._bEffective == true then
        self:showBeautyGroupActiveAni(itemCell)
   	end
    -- 初始化玩家的金币信息
    self:showCoinsInfo(kFinance.kCoin)
    -- 更新美人组信息
    self._pBeautyGroupListController:setDataSource(self._pBeautyManager._tBeautyGroupModelList)
end

-- 设置玩家的金币信息
function BeautyClubDialog:showCoinsInfo(financeType)
	local tFinanceInfo = FinanceManager:getInstance():getIconByFinanceType(financeType)
	--self._pCoinIcon:loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
	self._pCoinNumText:setString(FinanceManager:getValueByFinanceType(financeType))
end

-- 退出函数
function BeautyClubDialog:onExitBeautyClubDialog()
    self:onExitDialog()
	-- 释放网络监听事件
	NetRespManager:getInstance():removeEventListenersByHost(self)
	-- 释放掉群芳阁 合图资源
    ResPlistManager:getInstance():removeSpriteFrames("BeautyClub.plist")
	-- 释放 群芳阁美人大图合图
	ResPlistManager:getInstance():removeSpriteFrames("beauties_bg.plist")
    ResPlistManager:getInstance():removeSpriteFrames("beauties_bg1.plist")
    ResPlistManager:getInstance():removeSpriteFrames("LoveUpEffect.plist")
end


-- 初始化触摸相关
function BeautyClubDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
     
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()  
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

function BeautyClubDialog:updateCacheWithData(args)
	self:showCoinsInfo(kFinance.kCoin)
	self._pBeautyGroupList:jumpToTop()
	self:checkBeautyGroupUnLockAni()
	-- 更新美人头像的数据
	self._pBeautyIconListController:setDataSource(self._pBeautyManager._tBeautyModelList)
	-- 更新美人组的数据
	self._pBeautyGroupListController:setDataSource(self._pBeautyManager._tBeautyGroupModelList)

	-- 默认选中第一项
    local cell = self._pBeautyIconListController:cellWithIndex(self._curBeautyIconSelectedIndex)
    if cell then 
    	cell:changeSelectEvent(true)
    end
end

-- 亲密进度条
--  {{100,1},{100,2}}
function BeautyClubDialog:setKissBarPercent(nPercent)
    local nSize = table.getn(nPercent)
    for i=1,nSize do

        local callBack = function()
            self._pBeautyPicLayer._pQmLvText:setString("Lv"..nPercent[i][2])
            if i < nSize then
                self._pBeautyPicLayer._pQinMiBar:setPercentage(0)
            else
            	local beautyModel = self._pCurBagPicBeautyInfo
            	-- 当前等级要求的经验值
			   	local prevExp = beautyModel.level > 0 and beautyModel.dataInfo.RequiredLevel[beautyModel.level] or 0
			   	-- 升级需要的经验
			   	local needExp = beautyModel.dataInfo.RequiredLevel[beautyModel.level + 1] - prevExp
				-- 美人的亲密等级
			    self._pBeautyPicLayer._pQinMiBar:setPercentage((beautyModel.expValue - prevExp)/needExp * 100)
				-- 亲密等级
				self._pBeautyPicLayer._pQmLvText:setString("lv" ..beautyModel.level)
				-- 亲密进度条文字
				self._pBeautyPicLayer._pQinMinNumText:setString((beautyModel.expValue - prevExp)/needExp * 100 .."%")
            end
            self:showLoveUpgradeAni()
        end
        self._pBeautyPicLayer._pQinMiBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.5*i), cc.ProgressTo:create(0.2, nPercent[i][1]),cc.CallFunc:create(callBack)))
    end
end

return BeautyClubDialog