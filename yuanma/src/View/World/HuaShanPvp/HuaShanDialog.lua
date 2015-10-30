--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  HuanShanDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/05/12
-- descrip:   华山论剑
--===================================================

local HuaShanDialog = class("HuaShanDialog",function() 
	return require("Dialog"):create()
end)

function HuaShanDialog:ctor()
	self._strName = "HuaShanDialog"
	self._pCCS = nil 
	self._pBg = nil 
	self._pCloseButton = nil 
	-- pvper 列表节点
	self._PpvperListNode = nil 
	-- pvper 信息展示
	self._pPlayer = nil 
	self._pPvperModelNode = nil
	self._pVipLevelText = nil
	self._pVipLevelBtn = nil 
	self._pPvperNameText = nil 
	self._pPvperLeveText = nil 
	self._pDetailBtn = nil 
	self._pFightPowerFnt = nil 
    self._pDefeatedText = nil 
	-- 奖励物品集合（） 
	self._tRewardItems = {}
	--- 鼓舞 ---------
	self._pInspireLevelFnt = nil 
	self._pInspireProgressBar = nil 
	self._pInspireInfoText = nil
	-- 鼓舞交互节点（鼓舞满级隐藏）
	self._pInspireOperateNode = nil 
	self._pCoinInsireBtn = nil 
	self._pDiamondInsireBtn = nil 
	self._pCoinInsireNumText = nil 
	self._pDiamondInsireNumText = nil 
    self._pInsire_LvMax = nil 
	-- 挑战按钮
	self._pFightBtn = nil 
	-- 玩家的货币信息
	self._pCoinNumText = nil 
	self._pDiamondNumText = nil 
	-- 帮助按钮
	self._pHelpBtn = nil 
	self._tAllActions = {}
	-- 角色头像
	RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
	-- 当前鼓舞的等级
	self._nCurInspireLevel = 0
    -- 挑战对手列表
    self._tPvpers = nil
    -- 玩家当前的排名
    self._nCurRankIndex = 10
end

function HuaShanDialog:create(args)
	local dialog = HuaShanDialog.new()
	dialog:dispose(args)
	return dialog
end

function HuaShanDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("PvpHuashanDialog.plist")
    -- 挑战请求回调
    NetRespManager:getInstance():addEventListener(kNetCmd.kFightHSFightResp,handler(self,self.handleMsgFightHSResp21905))
    -- 鼓舞回调
    NetRespManager:getInstance():addEventListener(kNetCmd.kAddHSBuffResp,handler(self,self.handleMsgAddBuffResp21909))

    self._nCurInspireLevel = args.nBuffLevel
    self._tPvpers = args.enemys

	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitHuaShanDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	
    self:initUI()

    -- 避免模型穿透
    RolesManager:getInstance():setForceMinPositionZ(true,-10000)
    PetsManager:getInstance():setForceMinPositionZ(true,-10000)
end

function HuaShanDialog:initUI()
	local params = require("PvpHuashanDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	
	self._PpvperListNode = params._pSelectNode

	self._pPlayer = params._pPlayer 
	self._pPvperModelNode = params._pvperModelNode
	self._pPvperNameText = params._pname
	self._pVipLevelBtn = params._pvipbutton
	self._pVipLevelText = params._pvipnumber
	self._pPvperLeveText = params._plevelnumber
	self._pFightPowerFnt = params._pzhandoulinumber
	self._pDetailBtn = params._pDetailsButton
    self._pDefeatedText = params._pdefeated

	self._tRewardItems[1] = params._pItem1
	self._tRewardItems[2] = params._pItem2
	self._tRewardItems[3] = params._pItem3

	self._pInspireLevelFnt = params._pInspireLv
	self._pInspireProgressBar = params._pLoadingBar
	self._pInspireInfoText = params._pInspireText
	self._pInspireOperateNode = params._pInspireNode
    self._pInsire_LvMax = params._pText_LvMax
	self._pCoinInsireBtn = params._pInspireButton1
	self._pDiamondInsireBtn = params._pInspireButton2
	self._pCoinInsireNumText = params._pInspireMoneyNum1
	self._pDiamondInsireNumText = params._pInspireMoneyNum2

	self._pHelpBtn = params._pF1
	self._pFightBtn = params._pFightButton
	self._pCoinNumText = params._pMoneyNum1
	self._pDiamondNumText = params._pMoneyNum2

	self:disposeCSB()

	local pTouchPostion = nil
    local bIsMove = false
    local pTouchRec = self._pPlayer:getBoundingBox()
    self.pTouchBeginP = nil
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        self.pTouchBeginP = location
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(pTouchRec,pLocal) == true then
            pTouchPostion = pLocal
        end
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return true
    end
    local function onTouchMoved(touch,event)
        local location2 = touch:getLocation()
        if (math.abs(self.pTouchBeginP.x - location2.x) + math.abs(self.pTouchBeginP.y - location2.y) <= 2 ) then
        	return 
        end
        local location = self._pBg:convertTouchToNodeSpace(touch)
        if self._pRolePlayer and pTouchPostion then
            bIsMove = true
            local pRotation = self._pRolePlayer:getRotation3D()
            local dist = location.x - pTouchPostion.x
            pRotation.y = pRotation.y+dist/5
            self._pRolePlayer:setRotation3D(pRotation)
            pTouchPostion = location
        end
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local actionOverCallBack = function()  --动画播放完毕的回调 播放默认待机动作
            local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, self._tTempletetInfo.ReadyFightActFrameRegion[1],self._tTempletetInfo.ReadyFightActFrameRegion[2])
            pStandAnimate:setSpeed(self._tTempletetInfo.ReadyFightActFrameRegion[3])
            self._pRolePlayer:runAction(cc.RepeatForever:create(pStandAnimate))
        end

        if pTouchPostion and bIsMove == false and (cc.rectContainsPoint(pTouchRec,pTouchPostion) == true) then -- 如果点击有位移了播放动画
            if self._pRolePlayer then
                self._pRolePlayer:stopAllActions()
                local len = table.getn(self._tAllActions)
                local nRundom = mmo.HelpFunc:gGetRandNumberBetween(1,len)
                local tAction = self._tAllActions[nRundom]
                local pAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,tAction[1],tAction[2])
                pAnimate:setSpeed(tAction[4])
                self._pRolePlayer:runAction(cc.Sequence:create(pAnimate,cc.CallFunc:create(actionOverCallBack)))
            end
        end
        pTouchPostion = nil
        bIsMove = false
    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

	self:setPvperListDataSource(self._tPvpers)   
    self:setInspirePanelInfo()
end

-- 更新pvperList (只有10个)
function HuaShanDialog:setPvperListDataSource(tPvpers)
    -- 最高ko 排名
    local minKoIndex = 11
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			self:initPverInfo(sender:getTag() - 1000,tPvpers[sender:getTag() - 1000])
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	for i,pvperRender in ipairs(self._PpvperListNode:getChildren()) do
		pvperRender:getChildByName("Head"):loadTexture(RoleIcons[tPvpers[i].roleCareer],ccui.TextureResType.plistType)
        pvperRender:getChildByName("Head"):setScale(0.5)
		pvperRender:getChildByName("Name"):setString(tPvpers[i].roleName)
        -- 以战胜标志默认不显示
        pvperRender:getChildByName("defeated"):setVisible(false)
		pvperRender:setTag(i + 1000)
		pvperRender:addTouchEventListener(touchEvent)
        if tPvpers[i].isKo == true then
           -- 设置最高排名 
           minKoIndex =  i < minKoIndex and i or minKoIndex
           -- 按钮置灰
           pvperRender:loadTextures(
            "PvpHuashanRes/dsdjm5.png",
            "PvpHuashanRes/dsdjm5.png",
            "PvpHuashanRes/dsdjm5.png",
            ccui.TextureResType.plistType)
            -- 头像置灰
            darkNode(pvperRender:getChildByName("Head"):getVirtualRenderer():getSprite())
            -- 头像背景置灰
            darkNode(pvperRender:getChildByName("HeadBg"):getVirtualRenderer():getSprite())
            pvperRender:getChildByName("defeated"):setVisible(true)
        end
	end 
    self._nCurRankIndex = minKoIndex == 1 and 1 or minKoIndex - 1
    -- 设置默认选中项
    self:initPverInfo(self._nCurRankIndex,tPvpers[self._nCurRankIndex])
end

-- 设置角色列表的选中状态
function HuaShanDialog:setPvpRenderSelectedState(index)
    for i,pvperRender in ipairs(self._PpvperListNode:getChildren()) do
        if i == index then
            pvperRender:loadTextureNormal("PvpHuashanRes/dsdjm3.png",ccui.TextureResType.plistType)
        elseif self._tPvpers[i].isKo == true then
            pvperRender:loadTextureNormal("PvpHuashanRes/dsdjm5.png",ccui.TextureResType.plistType)
        else
            pvperRender:loadTextureNormal("PvpHuashanRes/dsdjm4.png",ccui.TextureResType.plistType)
        end
    end
end

-- 设置鼓舞信息
function HuaShanDialog:setInspirePanelInfo()
	self._pCoinNumText:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kCoin))
	self._pDiamondNumText:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kDiamond))

	self._pInspireLevelFnt:setString(self._nCurInspireLevel)
    self._pInspireInfoText:setString("当前提升 "..TableInspire[self._nCurInspireLevel + 1].InspireBuff*100 .. "% 攻击力和生命值")
	-- 最大鼓舞等级
	local nMaxInspireLevel = TableInspire[#TableInspire].Lv
	self._pInspireProgressBar:setPercent( self._nCurInspireLevel / nMaxInspireLevel * 100)
    if nMaxInspireLevel > self._nCurInspireLevel then
        -- 显示鼓舞到下一等级消耗的货币情况
        self._pCoinInsireNumText:setString(TableInspire[self._nCurInspireLevel + 1].GoldInspire)
        local goldColor = TableInspire[self._nCurInspireLevel + 1].GoldInspire > FinanceManager:getInstance()._tCurrency[kFinance.kCoin] 
                                    and cRed or cWhite
        self._pCoinInsireNumText:setColor(goldColor)
        self._pDiamondInsireNumText:setString(TableInspire[self._nCurInspireLevel + 1].DiamondInspire)
        local diamondColor = TableInspire[self._nCurInspireLevel + 1].DiamondInspire > FinanceManager:getInstance()._tCurrency[kFinance.kDiamond] 
                                    and cRed or cWhite
        self._pDiamondInsireNumText:setColor(diamondColor)
    end

	self._pInspireOperateNode:setVisible(nMaxInspireLevel > self._nCurInspireLevel)
    self._pInsire_LvMax:setVisible(nMaxInspireLevel == self._nCurInspireLevel)

	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender:getName() == "coinInspire" then
				-- 金币鼓舞  
                HuaShanCGMessage:addBuffReq21908(false)  
			elseif sender:getName() == "diamondInspire" then
				-- 钻石鼓舞
                HuaShanCGMessage:addBuffReq21908(true)
			end	
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
		end 
	end
	self._pCoinInsireBtn:addTouchEventListener(touchEvent)
    self._pCoinInsireBtn:setName("coinInspire")
	self._pDiamondInsireBtn:addTouchEventListener(touchEvent)
    self._pDiamondInsireBtn:setName("diamondInspire")
end

-- 显示pvper 的展示信息
function HuaShanDialog:initPverInfo(rankIdx,huaShanRoleInfo)
    self:setPvpRenderSelectedState(rankIdx)
	self._pPvperLeveText:setString(huaShanRoleInfo.roleLevel)
	self._pPvperNameText:setString(huaShanRoleInfo.roleName)
	self._pFightPowerFnt:setString(huaShanRoleInfo.fightingPower)
    self._pDefeatedText:setVisible(huaShanRoleInfo.isKo == true)

    -- 人物动画帧时间
    self._tTempletetInfo = TableTempleteCareers[huaShanRoleInfo.roleCareer]
    -- self._tTempletetInfo = TableTempleteCareers[1]
    self._tAllActions = {} 
    local pActionSize = table.getn(self._tTempletetInfo.AttackActFrameRegions)
    for i = pActionSize - 3,pActionSize do
        table.insert(self._tAllActions,self._tTempletetInfo.AttackActFrameRegions[i])
    end
    self:createRoleModel(huaShanRoleInfo.equipemts,huaShanRoleInfo.fashionOptions,huaShanRoleInfo.roleCareer)   --创建3d模型

    -- 挑战按钮回调
    local function touchEvent(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
    		-- 挑战按钮
    		if sender:getName() == "fight" then
    			-- 挑战对手
                if huaShanRoleInfo.isKo == false then
                    if rankIdx < self._nCurRankIndex then
                        NoticeManager:getInstance():showSystemMessage("先打败第"..self._nCurRankIndex.."再来吧")
                    else
                        HuaShanCGMessage:fightReq21904(rankIdx)
                    end
                else
                    NoticeManager:getInstance():showSystemMessage("您已经战胜"..huaShanRoleInfo.roleName.."轻点打")
                end
    		elseif sender:getName() == "detail" then
    			-- 查看Pvper 详细信息
                HuaShanCGMessage:fightReq21902(rankIdx)
            elseif sender:getName() == "help" then
                DialogManager:getInstance():showDialog("HelpDialog",kHelpSysType.kHuaShanPvp)  
    		end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
    	end
    end
    self._pFightBtn:addTouchEventListener(touchEvent)
    self._pFightBtn:setName("fight")
    self._pDetailBtn:addTouchEventListener(touchEvent)
    self._pDetailBtn:setName("detail")
    self._pDetailBtn:setZoomScale(nButtonZoomScale)
    self._pDetailBtn:setPressedActionEnabled(true)
    --self._pDetailBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pDetailBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pHelpBtn:addTouchEventListener(touchEvent)
    self._pHelpBtn:setName("help")
    self:updateRewardItems(huaShanRoleInfo.award)
end

-- 更新奖励物品
function HuaShanDialog:updateRewardItems(awardInfo)
	local itemAmount = 0
	local coinAmount = 0
	if not awardInfo  then
		return
    end
	itemAmount = #awardInfo.items
	coinAmount = #awardInfo.finances
	for i,itemRender in ipairs(self._tRewardItems) do
		if i <= itemAmount then
			local pItemInfo = GetCompleteItemInfo(awardInfo.items[i])
			itemRender:getChildByName("ItmeIcon".. i):loadTexture(pItemInfo.templeteInfo.Icon ..".png",ccui.TextureResType.plistType)
			itemRender:getChildByName("ItemNum".. i):setString(pItemInfo.value)
            if pItemInfo.dataInfo.Quality ~= nil and pItemInfo.dataInfo.Quality ~= 0 then 
                local iconBg = itemRender:getChildByName("ItmeIconBg".. i)
                local quality = pItemInfo.dataInfo.Quality
                iconBg:loadTexture("ccsComRes/qual_" ..quality.."_normal.png",ccui.TextureResType.plistType)
            else
                itemRender:getChildByName("ItmeIconBg".. i):setVisible(false)
            end
		else
			local tFinanceInfo = FinanceManager:getIconByFinanceType(awardInfo.finances[i - itemAmount].finance)
	        itemRender:getChildByName("ItmeIcon".. i):loadTexture(tFinanceInfo.filename,tFinanceInfo.textureType)
	        itemRender:getChildByName("ItemNum".. i):setString(awardInfo.finances[i - itemAmount].amount)
            itemRender:getChildByName("ItmeIconBg".. i):setVisible(false)
		end
	end
end

--创建模型信息
function HuaShanDialog:createRoleModel(equipemts,fashionOptions,roleCareer)
    local pRoleModelAni = nil
    local pRoleTexTure = nil
    local pWeaPonAni1 = nil
    local pWeaPonAni2 = nil
    local pWeaPonTexTure = nil
    local pFashionBackAni = nil
    local pFashionBackTure = nil
    local pFashionHaloAni = nil
    local pFashionHaloTure = nil
    local pModelScale = {}
    

    --根据装备初始化人物和model模型
    for i = 1,table.getn(equipemts) do
        local pEquInfo = GetCompleteItemInfo(equipemts[i],roleCareer)
        local nPart = pEquInfo.dataInfo.Part -- 部位
        local ptempleteInfo = pEquInfo.templeteInfo
        if nPart == kEqpLocation.kBody then -- 身
            pRoleModelAni = ptempleteInfo.Model1  --角色的人物模型
            pRoleTexTure = ptempleteInfo.Texture
        elseif nPart == kEqpLocation.kWeapon then  -- 武器
            pWeaPonAni1 = ptempleteInfo.Model1
            pWeaPonAni2 = ptempleteInfo.Model2
            pWeaPonTexTure = ptempleteInfo.Texture
            pModelScale[nPart] = {ptempleteInfo.ModelScale1,ptempleteInfo.ModelScale2}
        elseif nPart == kEqpLocation.kFashionBody then --时装身可能会影响人物模型
            if fashionOptions[2] == true then      --如果以时装的模型为主
                pRoleModelAni = ptempleteInfo.Model1
                pRoleTexTure = ptempleteInfo.Texture
        	end
        elseif nPart == kEqpLocation.kFashionBack then  --时装背（翅膀）
            if fashionOptions[1] == true then
                pFashionBackAni = ptempleteInfo.Model1
                pFashionBackTure = ptempleteInfo.Texture
                pModelScale[nPart] = ptempleteInfo.ModelScale1
        	end
        elseif nPart == kEqpLocation.kFashionHalo then  --时装光环
            if fashionOptions[3] == true then
                pFashionHaloAni = ptempleteInfo.Model1
                pFashionHaloTure = ptempleteInfo.Texture
                pModelScale[nPart] = ptempleteInfo.ModelScale1
        	end
        end
    end

    local nScale = self._tTempletetInfo.ScaleInShow --放大缩小比例
    self:updateRoleBodyModel(pRoleModelAni,pRoleTexTure,nScale) --更换人物模型
    self:updateRoleWepanModel(pWeaPonAni1,pWeaPonAni2,pWeaPonTexTure) --更换武器模型
    self:updateRoleFashionBackModel(pFashionBackAni,pFashionBackTure) --更换翅膀模型
    self:updateRoleFashionHaloModel(pFashionHaloAni,pFashionHaloTure,nScale) --更换光环
    --设置材质信息
    self:setMaterialInfo(equipemts)

    self._pRolePlayer:stopAllActions()
    if self._pRoleAnimation then
        --self._pRoleAnimation:release();
        self._pRoleAnimation = nil 
    end
    self._pRoleAnimation = cc.Animation3D:create(pRoleModelAni..".c3b")

    local actionOverCallBack = function ()
        local pRunActAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, self._tTempletetInfo.ReadyFightActFrameRegion[1],self._tTempletetInfo.ReadyFightActFrameRegion[2])
        pRunActAnimate:setSpeed(self._tTempletetInfo.ReadyFightActFrameRegion[3])
        self._pRolePlayer:runAction(cc.RepeatForever:create(pRunActAnimate))
    end
    self:setModelScaleByInfo(pModelScale)
    local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,self._tTempletetInfo.ShowActFrameRegion[1],self._tTempletetInfo.ShowActFrameRegion[2])
    pStandAnimate:setSpeed(self._tTempletetInfo.ShowActFrameRegion[3])
    self._pRolePlayer:runAction(cc.Sequence:create(pStandAnimate,cc.CallFunc:create(actionOverCallBack)))
    --end
end

--更换模型 人物身和时装身
function HuaShanDialog:updateRoleBodyModel(pAni,pTexture,nScale)
    if self._pRolePlayer then   -- 如果不是第一次加载需要从新清除一下工程文件
        self._pRolePlayer:stopAllActions()
        self._pRolePlayer:removeFromParent(true)
        self._pRolePlayer = nil
    end
    self._pRolePlayer = cc.Sprite3D:create(pAni..".c3b")
    self._pRolePlayer:setScale(nScale)
    self._pRolePlayer:setPosition(cc.p(self._pPlayer:getContentSize().width/2,self._pPlayer:getContentSize().height/2-self._pRolePlayer:getBoundingBox().height/3-40))
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
    self._pRolePlayer:setTexture(pTexture..".pvr.ccz")
    self._pPvperModelNode:addChild(self._pRolePlayer,2000)
end

--更换武器
function HuaShanDialog:updateRoleWepanModel(pAni1,pAni2,pTexture)
  self._pWeapon1 = nil
  self._pWeapon2 = nil
    --武器1
    if pAni1 then
        local pFashionRighWeapon =self._pRolePlayer:getAttachNode("boneRightHandAttach")
        if pFashionRighWeapon then
            self._pWeapon1 = cc.Sprite3D:create(pAni1..".c3b")
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
            self._pWeapon1:setTexture(pTexture..".pvr.ccz")
            pFashionRighWeapon:addChild( self._pWeapon1)
            local animation = cc.Animation3D:create(pAni1..".c3b")
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self._pWeapon1:runAction(act)
            
        end
    end
    if pAni2 then --如果 有第二个模型
        local pFashionLeftWeapon =self._pRolePlayer:getAttachNode("boneLeftHandAttach")
        if pFashionLeftWeapon then
            self._pWeapon2 = cc.Sprite3D:create(pAni2..".c3b")
            ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
            self._pWeapon2:setTexture(pTexture..".pvr.ccz")
            pFashionLeftWeapon:addChild(self._pWeapon2)
            local animation = cc.Animation3D:create(pAni2..".c3b")
            local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
            self._pWeapon2:runAction(act)
            
        end
    end  
end

--更换翅膀
function HuaShanDialog:updateRoleFashionBackModel(pAni,pTexture)
    local pFashionBack = self._pRolePlayer:getAttachNode("boneBackAttach")
    if pAni then
        self._pFashionBack = cc.Sprite3D:create(pAni..".c3b")
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
        self._pFashionBack:setTexture(pTexture..".pvr.ccz")
        local animation = cc.Animation3D:create(pAni..".c3b")
        local act = cc.RepeatForever:create(cc.Animate3D:createWithFrames(animation, 0, animation:getDuration()*30))
        self._pFashionBack:runAction(act)
        pFashionBack:addChild(self._pFashionBack)
    end
end

--更换光环
function HuaShanDialog:updateRoleFashionHaloModel(pAni,pTexture,nScale)
    if pAni then
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
        if not self._pFashionHalo then 
            self._pFashionHalo = cc.CSLoader:createNode(pAni..".csb")
            self._pFashionHalo:setScale(nScale)
            self._pPlayer:addChild(self._pFashionHalo,-1)
            local act = cc.CSLoader:createTimeline(pAni..".csb")
            act:gotoFrameAndPlay(0, act:getDuration(), true)
            self._pFashionHalo:stopAllActions()
            self._pFashionHalo:runAction(act)
        end
        self._pFashionHalo:setPosition(cc.p(self._pPlayer:getContentSize().width/2,self._pPlayer:getContentSize().height/2-self._pRolePlayer:getBoundingBox().height/3-40))
    end
end

-- 避免模型遮挡问题
function HuaShanDialog:setRoleModelVisible(isVisible)
    if isVisible then 
        self._pPvperModelNode:setPositionZ(2000)
    else
        self._pPvperModelNode:setPositionZ(-2000)
    end
end

--进入华山论剑战斗
function HuaShanDialog:entryBattleCopy(pvperFightInfo)
    -- 随机获得挑战本的地图信息
    local nRandomNum = getRandomNumBetween(1,#TableHuaShanCopysMaps)
    self._pSelectedCopysDataInfo = TableHuaShanCopysMaps[nRandomNum]

    if self._pSelectedCopysDataInfo ~= nil and  pvperFightInfo ~= nil then
        --战斗数据组装
        -- 【战斗数据对接】
        local args = {}
        args._strNextMapName = self._pSelectedCopysDataInfo.MapsName
        args._strNextMapPvrName = self._pSelectedCopysDataInfo.MapsPvrName
        args._nNextMapDoorIDofEntity = self._pSelectedCopysDataInfo.Doors[1][1]
        --require("TestMainRoleInfo")    --roleInfo  
        args._pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo
        -- 生命和攻击力受到鼓舞加成
        args._pMainRoleInfo.roleAttrInfo.hp = math.ceil(args._pMainRoleInfo.roleAttrInfo.hp * (1 + TableInspire[self._nCurInspireLevel + 1].InspireBuff))
        args._pMainRoleInfo.roleAttrInfo.attack = math.ceil(args._pMainRoleInfo.roleAttrInfo.attack * (1 + TableInspire[self._nCurInspireLevel + 1].InspireBuff))
        args._nMainPlayerRoleCurHp = nil      -- 从副本进入时，这里为无效值
        args._nMainPlayerRoleCurAnger = nil   -- 从副本进入时，这里为无效值
        args._nMainPetRoleCurHp = nil         -- 从副本进入时，这里为无效值
        args._tOtherPlayerRolesCurHp = {}      -- 从副本进入时，这里为无效值
        args._tOtherPlayerRolesCurAnger = {}   -- 从副本进入时，这里为无效值
        args._tOtherPetRolesCurHp = {}         -- 从副本进入时，这里为无效值
        args._nCurCopyType = kCopy.kHuaShan
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
        pvpRoleInfo.level = pvperFightInfo.level
        pvpRoleInfo.equipemts = pvperFightInfo.equipemts
        pvpRoleInfo.roleName = pvperFightInfo.roleName
        pvpRoleInfo.roleCareer = pvperFightInfo.roleCareer
        pvpRoleInfo.roleId = pvperFightInfo.roleId
        pvpRoleInfo.fashionOptions = pvperFightInfo.fashionOptions
        pvpRoleInfo.roleAttrInfo = pvperFightInfo.roleAttrInfo
        args._pPvpRoleInfo = pvpRoleInfo
        RolesManager:getInstance()._pPvpRoleInfo = pvpRoleInfo
        -- 设置挑战对手的技能信息
        args._tPvpRoleMountAngerSkills = self:getPvpMountAngerSkills(pvperFightInfo)
        args._tPvpRoleMountActvSkills = pvperFightInfo.mountSkills 
        args._tPvpPasvSkills = pvperFightInfo.pasvSkills
        -- 设置挑战对手的宠物信息
        args._tPvpPetRoleInfosInQueue = {}
        for i,v in ipairs(pvperFightInfo.pets) do
            args._tPvpPetRoleInfosInQueue[i] = v.petInfo
        end
        args._tPvpPetCooperates = {}
        args._tOtherPlayerRolesInfosOnBattleMap = {}
        args._tOtherPlayerRolesMountAngerSkillsInfos = {}
        args._tOtherPlayerRolesMountActvSkillsInfos = {}
        args._tOtherPlayerRolesPasvSkillsInfos = {}
        args._tOtherPetCooperates = {}
        args._bIsFirstBattleOfNewbie = false
    
        --关闭当前打开的Dialog
        self:getGameScene():closeDialogByNameWithNoAni("HuaShanDialog")
        --切换战斗场景
        LayerManager:getInstance():gotoRunningSenceLayer(BATTLE_SENCE_LAYER,args)
    end
end

-- 获得pvp装载的怒气技能
function HuaShanDialog:getPvpMountAngerSkills(pvperFightInfo)
    local tAngerSkills = {} 
    for i,mountSkill in ipairs(pvperFightInfo.mountSkills) do
        local skillInfo = SkillsManager:getInstance():getPvpRoleSkillDataByID(mountSkill.id,mountSkill.level)
        if skillInfo.SkillType == 5 then
            table.insert(tAngerSkills,mountSkill)
            -- 删除装备的怒气技能
            table.remove(pvperFightInfo.mountSkills,i)
        end
    end
    return tAngerSkills
end

-- 请求挑战回复
function HuaShanDialog:handleMsgFightHSResp21905(event)
    if event.roleFightInfo ~= nil then
        self:entryBattleCopy(event.roleFightInfo)
    end
end

-- 鼓舞回调
function HuaShanDialog:handleMsgAddBuffResp21909(event)
    if  self._nCurInspireLevel == event.buffLevel then
        NoticeManager:getInstance():showSystemMessage("鼓舞失败，鼓舞等级不变")
    else
        self._nCurInspireLevel = event.buffLevel
        NoticeManager:getInstance():showSystemMessage("鼓舞成功，鼓舞等级提升至"..self._nCurInspireLevel.."级")
    end  
    self:setInspirePanelInfo()
end

--设置身上3d模型的大小
function HuaShanDialog:setModelScaleByInfo(pScale)
   
    if self._pFashionBack then
        self._pFashionBack:setScale(pScale[kEqpLocation.kFashionBack])
    end
    
    if self._pFashionHalo then
        self._pFashionHalo:setScale(pScale[kEqpLocation.kFashionHalo])
    end
    if self._pWeapon1 then
        self._pWeapon1:setScale(pScale[kEqpLocation.kWeapon][1])
    end
    if self._pWeapon2 then
        self._pWeapon2:setScale(pScale[kEqpLocation.kWeapon][2])
    end
    
end

--设置材质信息
function HuaShanDialog:setMaterialInfo(tEquipemts)
    for k, v in pairs(tEquipemts) do
        local pEquInfo = v
        local nPart = pEquInfo.dataInfo.Part -- 部位
        local ptempleteInfo  = pEquInfo.templeteInfo
        if nPart == kEqpLocation.kBody then -- 身
            setSprite3dMaterial(self._pRolePlayer,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kWeapon then  -- 武器
            setSprite3dMaterial(self._pWeapon1,ptempleteInfo.Material)
            setSprite3dMaterial(self._pWeapon2,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kFashionBody then --时装身可能会影响人物模型
            setSprite3dMaterial(self._pRolePlayer,ptempleteInfo.Material)
        elseif nPart == kEqpLocation.kFashionBack then  --时装背（翅膀）
            setSprite3dMaterial(self._pFashionBack,ptempleteInfo.Material)

        elseif nPart == kEqpLocation.kFashionHalo then  --时装光环

        end
    end

end


--  退出回调
function HuaShanDialog:onExitHuaShanDialog()
    
    ResPlistManager:getInstance():removeSpriteFrames("PvpHuashanDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)

    RolesManager:getInstance():setForceMinPositionZ(false)
    PetsManager:getInstance():setForceMinPositionZ(false)
end

return HuaShanDialog