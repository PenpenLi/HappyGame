--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetDialog.lua
-- author:    liyuhang
-- created:   2015/4/22
-- descrip:   宠物系统面板
--===================================================
petTypeColorDef = {
     {name = "攻击型" , color = cRed},
     {name = "防守型" , color = cBlue},
     {name = "支援型" , color = cGreen},
     {name = "控制型" , color = cPurple},
}

local PetDialog = class("PetDialog",function()
    return require("Dialog"):create()
end)

local PetTabTypes = {
    PetTeam = 1,
    PetJigsaw = 2,
}

-- 构造函数
function PetDialog:ctor()
    -- 层名字
    self._strName = "PetDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil        

    self._pTabBtn = {}
    self._nTabType = PetTabTypes.PetTeam
    
    self._tPets = {{petId = 1 , level = 1 , step = 2 , exp = 1},
        {petId = 2 , level = 1 , step = 3 , exp = 1},
        {petId = 3 , level = 5 , step = 1 , exp = 1},
        {petId = 4 , level = 44 , step = 4 , exp = 1},
    }
   
    self.params = nil
    
    self._pBlackLayer = nil
    self._pPetRole = nil
    
    self._pItems = {}
end

-- 创建函数
function PetDialog:create(args)
    local layer = PetDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数 
function PetDialog:dispose(args)
    PetCGMessage:sendMessageGetPetsList21500()

    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetGetPets, handler(self,self.handleMsgGetPets))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetFieldPet, handler(self,self.handleMsgFieldPet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetUnFieldPet, handler(self,self.handleMsgUnFieldPet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetCompoundPet, handler(self,self.handleMsgCompoundPet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("Pet.plist")
    ResPlistManager:getInstance():addSpriteFrames("OnePet.plist")
    ResPlistManager:getInstance():addSpriteFrames("NoPet.plist")
    ResPlistManager:getInstance():addSpriteFrames("JigsawPet.plist")
    ResPlistManager:getInstance():addSpriteFrames("NovicegGuideFunction.plist")
    ResPlistManager:getInstance():addSpriteFrames("PetCompound.plist")
    
    self._tPets = args[1]
    
    -- 初始化界面相关
    self:initUI()
    
    self._pBlackLayer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    self._pBlackLayer:setVisible(false)
    self:addChild(self._pBlackLayer)

    -- 初始化触摸相关
    self:initTouches()
    
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "宠物按钮" , value = false})

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function PetDialog:initUI()
    -- 加载组件
    local params = require("PetParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    --self._pBg:setVisible(false)
    
    self.params._pScrollView:setInnerContainerSize(self.params._pScrollView:getContentSize())
    self.params._pScrollView:setTouchEnabled(true)
    self.params._pScrollView:setBounceEnabled(true)
    self.params._pScrollView:setClippingEnabled(true)
    
    self._pTabBtn[1] = params._pTeamButton
    self._pTabBtn[2] = params._pJigsawButton
    
    self._pTabBtn[1]:setTag(1)
    self._pTabBtn[2]:setTag(2)
    self:tabSelectAction(1)
    
    local function tabButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            self:tabSelectAction(tag)
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    
    self.params["_pShopButton"]:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    
    self._pTabBtn[1]:addTouchEventListener(tabButton)
    self._pTabBtn[2]:addTouchEventListener(tabButton)
    
    for i=1,3 do
        self.params["_ppetbutton0"..i]:setTag(i)
        
        self.params["_ppetbutton0"..i]:addTouchEventListener(function(sender, eventType) 
            if eventType == ccui.TouchEventType.ended then
                if PetsManager:getInstance()._tMountPetsIdsInQueue[sender:getTag()] ~= 0 then
                    PetCGMessage:sendMessageunField21504(PetsManager:getInstance()._tMountPetsIdsInQueue[sender:getTag()])
                end
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end)
    end
    
    self:disposeCSB()
    
    self:updateTeamDatas()
end

function PetDialog:tabSelectAction(type)
    self._pTabBtn[1]:loadTextures(
        type == 1 and "PetRes/cwjm2.png" or "PetRes/cwjm1.png",
        "PetRes/cwjm2.png",
        "PetRes/cwjm1.png",
        ccui.TextureResType.plistType)

    self._pTabBtn[2]:loadTextures(
        type == 2 and "PetRes/cwjm4.png" or "PetRes/cwjm3.png",
        "PetRes/cwjm4.png",
        "PetRes/cwjm3.png",
        ccui.TextureResType.plistType)
        
    if self._nTabType == type then
    	return
    end

    self._nTabType = type
	local action = {
	   [PetTabTypes.PetTeam] = function()
            self:updateTeamDatas()
	   end,
	   [PetTabTypes.PetJigsaw] = function()
            self:updateJigsawDatas()
       end,
	}
	
	action[type]()
end

function PetDialog:updateJigsawDatas()
    self.params._pScrollView:removeAllChildren()
    self._pItems = {}
    
    self.params._pScrollView:jumpToTop()

    local bigCount,rowCount = 0
    bigCount = table.getn(TablePets)
    local result1,result2 = math.modf(bigCount/2)
    if result2 > 0 then
        rowCount = result1 + 1
    else
        rowCount = result1
    end

    local nUpAndDownDis = 4                             --装备上下与框的间隔
    local nLeftAndReightDis = 0                         --装备左右与框的间隔
    local nSize = 90
    local nViewWidth  = self.params._pScrollView:getContentSize().width
    local nViewHeight = self.params._pScrollView:getContentSize().height
    local scrollViewHeight =((nUpAndDownDis+220)*(rowCount) > nViewHeight) and (nUpAndDownDis+220)*(rowCount)   or nViewHeight
    self.params._pScrollView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))
    --self.params._pScrollView:setBackGroundColorType(1)

    for i = 1,bigCount do
        -- 按照宠物索引 取宠物数据
        local info = nil
        info = PetsManager:getInstance():getPetChipDataWithId(i)
    
        local cell = self._pItems[i]
        if not self._pItems[i] then
            cell = require("PetJigsaw"):create()
        end

        local t1,t2 = math.modf((i-1)/2)
        t2 = t2*2
        cell:setPosition(173 + t2*(345+nLeftAndReightDis), 75 + scrollViewHeight-(220+nUpAndDownDis)*t1-230 +45 )
        cell:setAnchorPoint(cc.p(0,0))
        self.params._pScrollView:addChild(cell)
        self._pItems[i] = cell

        --local info = nil
        -- 按照背包索引 取物品数据
        --info = BagCommonManager:getInstance():getItemInfoByIndex(i,self._tType)

        cell:setInfo(info)
    end
    
    for i=1,3 do
        self.params["_ppetbutton0"..i]:setVisible(false)
        self.params["_pIcon0"..i]:setVisible(true)
        self.params["_pIcon0"..i]:loadTexture(
            "ccsComRes/BagItem.png",
            ccui.TextureResType.plistType)
        self.params["_picontext0"..i]:setVisible(false)
        self.params["_pIconP0"..i]:setVisible(false)
        self.params["_pIcon0"..i]:setTouchEnabled(false)
    end

    for i=1,3 do
        
        local info = BagCommonManager:getInstance():getItemRealInfo(200036 - 1 + i,kItemType.kFeed)

        self.params["_pIcon0"..i]:loadTexture(
            info.templeteInfo.Icon..".png",
            ccui.TextureResType.plistType)
        self.params["_pIcon0"..i]:setVisible(true)
        self.params["_picontext0"..i]:setVisible(true)
        self.params["_picontext0"..i]:setString(info.value)

        -- 图标弹tips
        local function touchEvent(sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                DialogManager:getInstance():showDialog("BagCallOutDialog",{info,nil,nil,false})
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end

        self.params["_pIcon0"..i]:setTouchEnabled(true)
        self.params["_pIcon0"..i]:addTouchEventListener(touchEvent)
    end
end

function PetDialog:updateTeamDatas()
    self.params._pScrollView:removeAllChildren()
    self._pItems = {}
    
    self.params._pScrollView:jumpToTop()
    
    local bigCount,rowCount = 0
    bigCount = table.getn(TablePets) --table.getn(PetsManager:getInstance()._tMainPetsInfos)
    local result1,result2 = math.modf(bigCount/2)
    if result2 > 0 then
        rowCount = result1 + 1
    else
        rowCount = result1
    end

    local nUpAndDownDis = 4                             --装备上下与框的间隔
    local nLeftAndReightDis = 0                         --装备左右与框的间隔
    local nSize = 90
    local nViewWidth  = self.params._pScrollView:getContentSize().width
    local nViewHeight = self.params._pScrollView:getContentSize().height
    local scrollViewHeight =((nUpAndDownDis+220)*(rowCount) > nViewHeight) and (nUpAndDownDis+220)*(rowCount)   or nViewHeight
    self.params._pScrollView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))
    --self.params._pScrollView:setBackGroundColorType(1)

    for i = 1,table.getn(PetsManager:getInstance()._tMainPetsInfos) do
        -- 按照宠物索引 取宠物数据
        local info = nil
        info = PetsManager:getInstance():getPetInfoWithId(PetsManager:getInstance()._tMainPetsInfos[i].petId,
            PetsManager:getInstance()._tMainPetsInfos[i].step,
            PetsManager:getInstance()._tMainPetsInfos[i].level)
            
        if info ~= nil then
            local cell = self._pItems[i]
            if not self._pItems[i] then
                cell = require("PetItemCell"):create(info)
            end

            local t1,t2 = math.modf((i-1)/2)
            t2 = t2*2
            cell:setPosition(173 + t2*(345+nLeftAndReightDis), 75 + scrollViewHeight-(220+nUpAndDownDis)*t1-230 +45 )
            cell:setAnchorPoint(cc.p(0,0))
            self.params._pScrollView:addChild(cell)
            self._pItems[i] = cell
        end
    end
    
    for  i = table.getn(PetsManager:getInstance()._tMainPetsInfos) + 1 , table.getn(TablePets) do
        local cell = require("NoPetCell"):create()
        
        local t1,t2 = math.modf((i-1)/2)
        t2 = t2*2
        cell:setPosition(173 + t2*(345+nLeftAndReightDis), 75 + scrollViewHeight-(220+nUpAndDownDis)*t1-230 +45 )
        cell:setAnchorPoint(cc.p(0,0))
        self.params._pScrollView:addChild(cell)
    end
    
    local RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
    for i=1,3 do
        self.params["_ppetbutton0"..i]:setVisible(false)
        self.params["_pIcon0"..i]:setVisible(true)
        self.params["_pIcon0"..i]:loadTexture(
            "ccsComRes/BagItem.png",
            ccui.TextureResType.plistType)
        self.params["_picontext0"..i]:setVisible(false)
        self.params["_pIconP0"..i]:setVisible(false)
        self.params["_pIcon0"..i]:setTouchEnabled(false)
    end
    
    for i=1,table.getn(PetsManager:getInstance()._tMountPetsIdsInQueue) do
        if PetsManager:getInstance()._tMountPetsIdsInQueue[i] ~= 0 then
            local info = PetsManager:getInstance():getPetChipDataWithId(PetsManager:getInstance()._tMountPetsIdsInQueue[i])

            self.params["_ppetbutton0"..i]:loadTextures(
                info.templete.PetIcon..".png",
                info.templete.PetIcon..".png",
                info.templete.PetIcon..".png",
                ccui.TextureResType.plistType)
            self.params["_ppetbutton0"..i]:setVisible(true)
            
            self.params["_pIconP0"..i]:setVisible(true)
            
            self.params["_pIconP0"..i]:loadTexture(
                "ccsComRes/qual_" ..info.step.."_normal.png",
                ccui.TextureResType.plistType)
        end
    end
end


-- 初始化触摸相关
function PetDialog:initTouches()
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
end

-- 退出函数
function PetDialog:onExitPetDialog()
    self:onExitDialog()
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("Pet.plist")
    ResPlistManager:getInstance():removeSpriteFrames("OnePet.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NoPet.plist")
    ResPlistManager:getInstance():removeSpriteFrames("JigsawPet.plist")
    ResPlistManager:getInstance():removeSpriteFrames("PetCompound.plist")
    ResPlistManager:getInstance():removeSpriteFrames("NovicegGuideFunction.plist")
end

function PetDialog:handleMsgGetPets(event)
   
end

-- 处理上阵
function PetDialog:handleMsgFieldPet(event)
    self:updateTeamDatas()
end 

-- 处理下阵
function PetDialog:handleMsgUnFieldPet(event)
    self:updateTeamDatas()
end

-- 处理合成
function PetDialog:handleMsgCompoundPet(event)
    --self:updateJigsawDatas()
    
    local info = nil
    local petId = nil
    for i=1,table.getn(TablePets) do
        if TablePets[i].PieceID == event.argsBody.chipId then
            petId = TablePets[i].ID
            break
    	end
    end
    
    for i=1,table.getn(PetsManager:getInstance()._tMainPetsInfos) do
        if PetsManager:getInstance()._tMainPetsInfos[i].petId == petId then
            info = PetsManager:getInstance():getPetInfoWithId(PetsManager:getInstance()._tMainPetsInfos[i].petId,
                PetsManager:getInstance()._tMainPetsInfos[i].step,
                PetsManager:getInstance()._tMainPetsInfos[i].level)
        end
    end
    
    if info ~= nil then
        self:showNewPet(info)
    end
end

-- 处理进阶
function PetDialog:handleMsgAdvancePet(event)
    self:updateJigsawDatas()
end 

-- 处理喂食
function PetDialog:handleMsgFeedPet(event)
    local action = {
        [PetTabTypes.PetTeam] = function()
            self:updateTeamDatas()
        end,
        [PetTabTypes.PetJigsaw] = function()
            self:updateJigsawDatas()
        end,
    }
    action[self._nTabType]()
end

function PetDialog:showNewPet(dataInfo)
    if self._pPetRole then   -- 如果不是第一次加载需要从新清除一下工程文件
        self._pPetRole:stopAllActions()
        self._pPetRole:removeFromParent(true)
        self._pPetRole = nil
    end
    self:setTouchEnableInDialog(true)
    --self._pBlackLayer:setVisible(true)
    
    local _pResolveAniNode = cc.CSLoader:createNode("PetCompound.csb")
    local _pResolveAniAction = cc.CSLoader:createTimeline("PetCompound.csb")
    _pResolveAniNode:setPosition(self._pBg:getContentSize().width/2,self._pBg:getContentSize().height/2)
    _pResolveAniNode:setScale(2)
    self._pBg:addChild( _pResolveAniNode)

    self._pPetRole = cc.Sprite3D:create(dataInfo.templete.Model..".c3b")
    local pAniPostion = cc.p(self._pBg:getContentSize().width/2,self._pBg:getContentSize().height/2 - dataInfo.templete.Height/2*1.5 - 100)
    self._pPetRole:setScale(dataInfo.templete.ScaleInShow*1.5)
    self._pPetRole:setPosition(pAniPostion)
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(dataInfo.templete.Texture)
    self._pPetRole:setTexture(dataInfo.templete.Texture..".pvr.ccz")
    self._pBg:addChild(self._pPetRole,10)

    self._pPetRole:stopAllActions()
    self._pRoleAnimation = cc.Animation3D:create(dataInfo.templete.Model..".c3b")
    local actionOverCallBack = function ()
        local pRunActAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, dataInfo.templete.StandActFrameRegion[1],dataInfo.templete.StandActFrameRegion[2])
        pRunActAnimate:setSpeed(dataInfo.templete.StandActFrameRegion[3])
        self._pPetRole:runAction(cc.RepeatForever:create(pRunActAnimate))
    end
    
    local showOverCallback = function ()
        self._pPetRole:setVisible(false)
        self:setTouchEnableInDialog(false)
        self._pBlackLayer:setVisible(false)
        _pResolveAniNode:removeFromParent(true)
    end

    local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,dataInfo.templete.ShowActFrameRegion[1],dataInfo.templete.ShowActFrameRegion[2])
    pStandAnimate:setSpeed(dataInfo.templete.ShowActFrameRegion[3])
    self._pPetRole:runAction(cc.Sequence:create(pStandAnimate,cc.CallFunc:create(actionOverCallBack),cc.DelayTime:create(1.5),cc.CallFunc:create(showOverCallback)))
    
    _pResolveAniAction:gotoFrameAndPlay(0,_pResolveAniAction:getDuration(), true)
    _pResolveAniNode:stopAllActions()
    _pResolveAniNode:runAction(_pResolveAniAction)

    self._pPetRole:setPositionZ(5000)
end

return PetDialog