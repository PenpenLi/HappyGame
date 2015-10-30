--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PvperDetialDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/05/12
-- descrip:   华山论剑Pvper详情
--===================================================

local PvperDetialDialog = class("PvperDetialDialog",function()
	return require("Dialog"):create()
end)

function PvperDetialDialog:ctor()
	self._strName = "PvperDetailDialog"
	self._pCCS = nil 
	self._pBg = nil 
	self._pCloseButton = nil 
	-- pvper 基本信息
	self._pPlayer = nil 
	self._pVipLevelText = nil
	self._pVipLevelBtn = nil 
	self._pPvperNameText = nil 
	self._pPvperLeveText = nil 
	self._pAddBuddyBtn = nil 
	self._pFightPowerFnt = nil 
	self._pTabBtn = nil 
	self._pTabText = nil 
	self._pContainerNode = nil
	-- 战斗配置面板
	self._pFightDeploySubPanel = nil 
	self._pSkillContainerBg = nil
	self._tPetRenders = {}
	-- 角色详情面板
	self._pDetialSubPanel = nil
	-- 角色头像
	RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
	-- 宠物类型
	petTypeColorDef = {
		     {name = "攻击型" , color = cRed},
             {name = "防守型" , color = cBlue},
             {name = "支援型" , color = cGreen},
             {name = "控制型" , color = cPurple},
		}
	-- pvperInfo 
	self._tPvperFightInfo = nil 
	self._tEquALlPostion = {}
	self._tAllActions = {}
	self._pArrayTableSprite = {}
    -- 华山论剑代理
    self._pHuaShanDelegate = nil 
    -- 角色信息代理
    self._pRolesInfoDialogDelegate = nil 
end

function PvperDetialDialog:create(args)
	local dialog = PvperDetialDialog.new()
	dialog:dispose(args)
	return dialog
end

function PvperDetialDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("PlayerRolesCheckDialog.plist")
    -- 加载刺客技能图标
    ResPlistManager:getInstance():addSpriteFrames("thug_skill_icon.plist")
    -- 加载战士技能图标
    ResPlistManager:getInstance():addSpriteFrames("warrior_skill_icon.plist")
    -- 加载法师技能图标
    ResPlistManager:getInstance():addSpriteFrames("mage_skill_icon.plist")
    self._tPvperFightInfo = args
   
	local function onNodeEvent(event)
		if event == "exit" then
			self:onExitPvperDetailDialog()
		end
	end
	self:registerScriptHandler(onNodeEvent)
	
    self:initUI()

    -- 隐藏 华山论剑界面的模型
    self._pHuaShanDelegate = DialogManager:getInstance():getDialogByName("HuaShanDialog")
    if self._pHuaShanDelegate ~= nil then 
        self._pHuaShanDelegate:setRoleModelVisible(false)
    end
    -- 隐藏 角色信息界面的模型
    self._pRolesInfoDialogDelegate = DialogManager:getInstance():getDialogByName("RolesInfoDialog")
    if self._pRolesInfoDialogDelegate ~= nil then 
        self._pRolesInfoDialogDelegate:setRoleModelVisible(false)
    end

    RolesManager:getInstance():setForceMinPositionZ(true,-10000)
    PetsManager:getInstance():setForceMinPositionZ(true,-10000)
end	

function PvperDetialDialog:initUI()
	local params = require("PlayerRolesCheckDialogParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pPlayer = params._pPlayer
	self._pPvperNameText = params._pName
    self._pVipLevelBtn = params._pVip_button
    self._pVipLevelText = params._pVip_number
	self._pPvperLeveText = params._pLevel_number
    self._pFightPowerBg = params._pZhandouliBg
    --self._pFightPowerBg:setPositionZ(6000)
	self._pFightPowerFnt = params._pZhandouli_number
	self._pTabBtn = params._pExchange
	self._pTabText = params._pExchange_text
    self._pTabText:setString("详细\n属性")
	self._pAddBuddyBtn = params._pAddFriends
	-- subPanel 挂载节点
	self._pContainerNode = params._pNodeRight
	-- 战斗配置子面板
    self._pFightDeploySubPanel = params._pEqiupRight
    --角色详细信息
    self._pDetialSubPanel = require("PlayerDetailInfoPanel"):create({nil,true})
    self._pDetialSubPanel:setPosition(self._pFightDeploySubPanel:getPosition())
    self._pDetialSubPanel:setVisible(false)
    self._pContainerNode:addChild(self._pDetialSubPanel)
	-- 配置上阵技能	
	self._pSkillContainerBg = params._pSkillBg
	-- 宠物信息
	self._tPetRenders[1] = params._pPetBg1
	self._tPetRenders[2] = params._pPetBg2
	self._tPetRenders[3] = params._pPetBg3

	self:disposeCSB()

	local sContSize = self._pPlayer:getContentSize()
    
    local pPosX,pPosY = self._pPlayer:getPosition()
    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 0                         --装备左右与框的间隔
    local nSize = 101                                   --一个装备框的大小
    local nFashionDis = 13                              --下面时装和人物的距离
    -- 左上4，左上3，左上2，左上1
    table.insert(self._tEquALlPostion,cc.p(-nSize-nLeftAndReightDis,nSize*3+3*nUpAndDownDis))
    table.insert(self._tEquALlPostion,cc.p(-nSize-nLeftAndReightDis,nSize*2+2*nUpAndDownDis))
    table.insert(self._tEquALlPostion,cc.p(-nSize-nLeftAndReightDis,nSize*1+1*nUpAndDownDis))
    table.insert(self._tEquALlPostion,cc.p(-nSize-nLeftAndReightDis,0))
    --右上4，右上3，右上2，右上1
    table.insert(self._tEquALlPostion,cc.p(sContSize.width+nLeftAndReightDis,nSize*3+3*nUpAndDownDis))
    table.insert(self._tEquALlPostion,cc.p(sContSize.width+nLeftAndReightDis,nSize*2+2*nUpAndDownDis))
    table.insert(self._tEquALlPostion,cc.p(sContSize.width+nLeftAndReightDis,nSize*1+1*nUpAndDownDis))
    table.insert(self._tEquALlPostion,cc.p(sContSize.width+nLeftAndReightDis,0))
    --下左1 2 3
    table.insert(self._tEquALlPostion,cc.p(sContSize.width/2-3*nSize/2-20,-nFashionDis-nSize))
    table.insert(self._tEquALlPostion,cc.p(sContSize.width/2-nSize/2,-nFashionDis-nSize))
    table.insert(self._tEquALlPostion,cc.p(sContSize.width/2+nSize/2+20,-nFashionDis-nSize))

	local function touchEvent (sender,eventType) 
		if eventType == ccui.TouchEventType.ended then
			if sender:getName() == "addBuddy" then
				-- 添加好友请求
                local roleId = self._tPvperFightInfo.roleId
                if FriendManager:getInstance():checkIsFriendWithRoleId(roleId) ~= -1 then
                    NoticeManager:getInstance():showSystemMessage("你们已经是好友。")
                else
                    FriendCGMessage:sendMessageApplyFriend22010(roleId)
                end
			elseif sender:getName() == "tabBtn" then
				-- 切换右侧子面板
                for i, subPanel in ipairs(self._pContainerNode:getChildren()) do
                    subPanel:setVisible(subPanel:isVisible() == false)
                    if self._pFightDeploySubPanel:isVisible() == true then
                        self._pTabText:setString("详细\n属性")
                    else
                        self._pTabText:setString("战斗\n配置")
                    end
                end
			end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
		end
	end
	self._pAddBuddyBtn:setName("addBuddy")
    self._pAddBuddyBtn:setZoomScale(nButtonZoomScale)
    self._pAddBuddyBtn:setPressedActionEnabled(true)
    --self._pAddBuddyBtn:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pAddBuddyBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
	self._pAddBuddyBtn:addTouchEventListener(touchEvent)
	self._pTabBtn:setName("tabBtn")
    self._pTabBtn:setZoomScale(nButtonZoomScale)
    self._pTabBtn:setPressedActionEnabled(true)
    --self._pTabText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pTabText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
	self._pTabBtn:addTouchEventListener(touchEvent)

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

        print("touch begin 11".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return true
    end
    local function onTouchMoved(touch,event)
        local location2 = touch:getLocation()
        if (math.abs(self.pTouchBeginP.x - location2.x)+math.abs(self.pTouchBeginP.y - location2.y) <= 2 )then
        	return 
        end
       local location = self._pBg:convertTouchToNodeSpace(touch)

        print("touch move ".."x="..location.x.."  y="..location.y)
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
        print("touch end a ".."x="..location.x.."  y="..location.y)

        local actionOverCallBack = function()  --动画播放完毕的回调 播放默认待机动作
            local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, self._tTempletetInfo.ReadyFightActFrameRegion[1],self._tTempletetInfo.ReadyFightActFrameRegion[2])
            pStandAnimate:setSpeed(self._tTempletetInfo.ReadyFightActFrameRegion[3])
            self._pRolePlayer:runAction(cc.RepeatForever:create(pStandAnimate))
        end

        if pTouchPostion and bIsMove == false and (cc.rectContainsPoint(pTouchRec,pTouchPostion) == true) then -- 如果点击有位移了播放动画
            if self._pRolePlayer then
                self._pRolePlayer:stopAllActions()
                local len = table.getn(self._tAllActions)
                local  nRundom = mmo.HelpFunc:gGetRandNumberBetween(1,len)
                local  tAction = self._tAllActions[nRundom]
                local  pAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,tAction[1],tAction[2])
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
    -- 设置Pvper 的自身属性
    self:initPvperInfo()
    -- 设置Pvper 的技能属性
    self:initSkillRenders(self._tPvperFightInfo.mountSkills)
    -- 设置Pvper 的宠物属性
    self:initPetRenders(self._tPvperFightInfo.pets)
    
end

function PvperDetialDialog:initPvperInfo()
	self._pPvperNameText:setString(self._tPvperFightInfo.roleName)
    self._pVipLevelText:setString(self._tPvperFightInfo.vipLevel)
	self._pPvperLeveText:setString("Lv"..self._tPvperFightInfo.level)
	self._pFightPowerFnt:setString(self._tPvperFightInfo.roleAttrInfo.fightingPower)
	-- 人物动画帧时间
    self._tTempletetInfo = TableTempleteCareers[self._tPvperFightInfo.roleCareer]
    self._tAllActions = {}
    local pActionSize = table.getn(self._tTempletetInfo.AttackActFrameRegions)
    for i = pActionSize - 3,pActionSize do
        table.insert(self._tAllActions,self._tTempletetInfo.AttackActFrameRegions[i])
    end
    self:createRoleModel(self._tPvperFightInfo.equipemts,self._tPvperFightInfo.fashionOptions,self._tPvperFightInfo.roleCareer)   --创建3d模型

    self:initRoleEquInfo()
    -- 设置角色的详细属性  
    self._pDetialSubPanel:setDataSource(self._tPvperFightInfo.roleAttrInfo)

    -- 如果已经是好友则隐藏添加好友按钮
     local roleId = self._tPvperFightInfo.roleId
     self._pAddBuddyBtn:setVisible( FriendManager:getInstance():checkIsFriendWithRoleId(roleId) == -1)
end

--初始化角色的装备信息
function PvperDetialDialog:initRoleEquInfo()
    --创建11个背景框
    for i = 1,table.getn(self._tEquALlPostion) do
        local cell = require("BagItemCell"):create()
        cell:setPosition(self._tEquALlPostion[i])
        cell:openSelectedState()
        cell:setCalloutSrcType(kCalloutSrcType.KCalloutSrcTypeUnKnow)
        self._pPlayer:addChild(cell,5000)
        if i ~= 8 then --武宠不添加到表里面
            table.insert(self._pArrayTableSprite,cell)
          else
          cell:setVisible(false)
        end
    end

    --设置默认装备信息
    for k,v in pairs(self._pArrayTableSprite) do
        v:setTouchEnabled(false)
        v:setEquipDefIconByPart(k) 
    end

    
    --给装备设置数据
    for i = 1,table.getn(self._tPvperFightInfo.equipemts) do
        local pPart = self._tPvperFightInfo.equipemts[i].dataInfo.Part -- 部位
        self._pArrayTableSprite[pPart]:setItemInfo(GetCompleteItemInfo(self._tPvperFightInfo.equipemts[i],self._tPvperFightInfo.roleCareer))
        self._pArrayTableSprite[pPart]:setTouchEnabled(true)
    end
end

--创建模型信息
function PvperDetialDialog:createRoleModel(equipemts,fashionOptions,roleCareer)
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
                pModelScale[nPart] = ptempleteInfo.ModelScale1
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
    self:setMaterialInfo(equipemts) --设置材质信息
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
    
  --  self._pRolePlayer:setPositionZ(2000)
end

--更换模型 人物身和时装身
function PvperDetialDialog:updateRoleBodyModel(pAni,pTexture,nScale)
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
    self._pPlayer:addChild(self._pRolePlayer,2000)
end

--更换武器
function PvperDetialDialog:updateRoleWepanModel(pAni1,pAni2,pTexture)
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
function PvperDetialDialog:updateRoleFashionBackModel(pAni,pTexture)
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
function PvperDetialDialog:updateRoleFashionHaloModel(pAni,pTexture,nScale)
    if pAni then
        ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(pTexture)
        self._pFashionHalo = cc.CSLoader:createNode(pAni..".csb")
        self._pFashionHalo:setScale(nScale)
        self._pFashionHalo:setPosition(cc.p(self._pPlayer:getContentSize().width/2,self._pPlayer:getContentSize().height/2-self._pRolePlayer:getBoundingBox().height/3-40))
        self._pPlayer:addChild(self._pFashionHalo,-1)
        local act = cc.CSLoader:createTimeline(pAni..".csb")
        act:gotoFrameAndPlay(0, act:getDuration(), true)
        self._pFashionHalo:stopAllActions()
        self._pFashionHalo:runAction(act)
    end
end

-- 设置角色的技能信息
-- {id,level}
function PvperDetialDialog:initSkillRenders(mountSkills)
	local skillInfoArry = {}
	-- 点击技能图标
	local function onTouchSkillIcon (sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local skillData =  skillInfoArry[sender:getTag() - 3000]
			if skillData ~= nil then
				DialogManager:getInstance():showDialog("SkillDetailDialog",{skillData,true})
			else
				print("skillData******************* is nil error")
			end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
		end
	end

	for i,skillRender in ipairs(self._pSkillContainerBg:getChildren()) do
		if i > #mountSkills then
			--skillRender:setVisible(false)
		else
			--skillRender:setVisible(true)
            local skillInfo = SkillsManager:getInstance():getCareerSkillInfo(self._tPvperFightInfo.roleCareer,mountSkills[i].id,mountSkills[i].level)
			skillInfoArry[i] = skillInfo
			-- 技能名称
			skillRender:getChildByName("SkillName"):setString(skillInfo.SkillName)
			-- 技能图标
			skillRender:getChildByName("SkillIcon"):loadTexture(skillInfo.skillIcon..".png",ccui.TextureResType.plistType)
			-- 技能等级
            skillRender:getChildByName("SkillLv"):setString("lv".. skillInfo.Level)
            skillRender:addTouchEventListener(onTouchSkillIcon)
            skillRender:setTag(i + 3000)
		end
	end
	
end

-- 设置角色的宠物信息
function PvperDetialDialog:initPetRenders(pets)
	--图标按钮
	local infoArry = {}
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
        	local info = infoArry[sender:getTag() - 2000]
            DialogManager:showDialog("PetFoodDialog",{info,false})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
	for i,render in ipairs(self._tPetRenders) do
		local iconBg = render:getChildByName("IconBg")
		if i <= #pets then
			iconBg:setVisible(true)
            render:getChildByName("TextNoPet"):setVisible(false)
            local info = PetsManager:getInstance():getPetInfoWithId(pets[i].petInfo.petId,pets[i].petInfo.step,pets[i].petInfo.level)
			infoArry[i] = info
			-- 设置宠物的品质边框
            local step = info.step == 0 and 1 or info.step
            iconBg:loadTexture("ccsComRes/qual_" ..step.."_normal.png",ccui.TextureResType.plistType)   
			-- 头像
			iconBg:getChildByName("Icon"):loadTextures(
                info.templete.PetIcon ..".png",
                info.templete.PetIcon ..".png",
                info.templete.PetIcon ..".png",
		        ccui.TextureResType.plistType)
			iconBg:getChildByName("Icon"):addTouchEventListener(onTouchBg)
            iconBg:getChildByName("Icon"):setTag(2000 + i)
			-- 等级
			iconBg:getChildByName("Lv"):setString(info.level)
			-- 阶
			iconBg:getChildByName("Quality"):setString(info.step .. "阶")
			-- 宠物类型
            iconBg:getChildByName("Type"):setString(petTypeColorDef[info.data.PetFunction].name)
            iconBg:getChildByName("Type"):setColor(petTypeColorDef[info.data.PetFunction].color)
			-- 宠物名字
			iconBg:getChildByName("Name"):setString(info.templete.PetName)
            iconBg:getChildByName("Name"):setColor(kQualityFontColor3b[step])
			-- 基本属性(向上取整)
    		iconBg:getChildByName("Defend"):setString(math.ceil(info.data.Defend + info.level * info.data.DefendGrowth[info.step]))
    		iconBg:getChildByName("Hp"):setString(math.ceil(info.data.Hp + info.level * info.data.HpGrowth[info.step]))
    		iconBg:getChildByName("Attack"):setString(math.ceil(info.data.Attack + info.level * info.data.AttackGrowth[info.step]))
		else
			iconBg:setVisible(false)
            render:getChildByName("TextNoPet"):setVisible(true)
		end

	end
end

function PvperDetialDialog:onExitPvperDetailDialog ()
    -- 重置其它界面的模型信息
    if self._pHuaShanDelegate ~= nil then 
        self._pHuaShanDelegate:setRoleModelVisible(true)
    end

    if self._pRolesInfoDialogDelegate ~= nil then 
        self._pRolesInfoDialogDelegate:setRoleModelVisible(true)
    end
    
    ResPlistManager:getInstance():removeSpriteFrames("PlayerRolesCheckDialog.plist")  
    ResPlistManager:getInstance():removeSpriteFrames("thug_skill_icon.plist")
    ResPlistManager:getInstance():removeSpriteFrames("warrior_skill_icon.plist")
    ResPlistManager:getInstance():removeSpriteFrames("mage_skill_icon.plist")

    --RolesManager:getInstance():setForceMinPositionZ(false)
    --PetsManager:getInstance():setForceMinPositionZ(false)
    
end

--设置身上3d模型的大小
function PvperDetialDialog:setModelScaleByInfo(pScale)

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
function PvperDetialDialog:setMaterialInfo(tEquipments)
    for k, v in pairs(tEquipments) do
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


return PvperDetialDialog