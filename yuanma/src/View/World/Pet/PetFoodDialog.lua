--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetFoodDialog.lua
-- author:    liyuhang
-- created:   2015/4/22
-- descrip:   宠物喂食系统面板
--===================================================
local PetFoodDialog = class("PetFoodDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function PetFoodDialog:ctor()
    -- 层名字
    self._strName = "PetFoodDialog" 
    -- 触摸监听器
    self._pTouchListener = nil 
    --  商城相关的PCCS
    self._pCCS = nil  
    -- 商城背景
    self._pBg = nil
    -- 关闭按钮
    self._pCloseButton = nil   
    
    self.params = nil     

    self._pDataInfo = nil
    self.step = 0
    
    self._bGot = false
    
    self._tAllActions = {}    --宠物动作
    self._tPercent = {}
    self._nLastRoleLevel = 0
    
    self._pExpLoadingBar = nil
    self._pExpText = nil
end

-- 创建函数
function PetFoodDialog:create(args)
    local layer = PetFoodDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数
function PetFoodDialog:dispose(args)
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kMountSkill, handler(self,self.handleMsgMountSkill))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFisance, handler(self,self.handleMsgUpdateFisance))
    -- 加载商城的 合图资源
    ResPlistManager:getInstance():addSpriteFrames("PetFood.plist")
    
    self._pDataInfo = args[1]
    self._bGot = args[2]
    self.step = self._pDataInfo.step
    self._nLastRoleLevel = self._pDataInfo.level
    
    if self.step == 0 then
    	self.step = 1
    end
    -- 初始化界面相关
    self:initUI()

    -- 初始化触摸相关
    self:initTouches()

    ------------------节点事件------------------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitSkillDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 初始化界面UI 控件
function PetFoodDialog:initUI()
    -- 加载组件
    local params = require("PetFoodParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    self:disposeCSB()
    
    self.params._pLoadingBar:setVisible(false)
    self.params._pExpText:setVisible(false)
    
    local pSprite = cc.Sprite:createWithSpriteFrameName("PetFoodRes/jlxt8.png")
    self._pExpLoadingBar = cc.ProgressTimer:create(pSprite)
    self._pExpLoadingBar:setPosition(cc.p(280,45))
    self._pExpLoadingBar:setScaleX(2.52)
    self._pExpLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pExpLoadingBar:setMidpoint(cc.p(0, 0))
    self._pExpLoadingBar:setBarChangeRate(cc.p(1, 0))
    self._pExpLoadingBar:setPercentage(0)
    self.params._p3DBg:addChild(self._pExpLoadingBar,0)
    
    self._pExpText = cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pExpText:setLineHeight(20)
    self._pExpText:setAdditionalKerning(-2)
    self._pExpText:setTextColor(cc.c4b(255, 255, 255, 255))
    self._pExpText:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self._pExpText:setPositionX(280)
    self._pExpText:setPositionY(45)
    self._pExpText:setWidth(85)
    --self._pExpText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pNameLbllbl:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pExpText:setAnchorPoint(0.5,0.5)
    self._pExpText:setString("")
    self.params._p3DBg:addChild(self._pExpText)
    
    local nowExp = PetsManager:getPetExpById(self._pDataInfo.id)
    local maxExp = TablePetsLevel[self._pDataInfo.level].PetsExp
    self._pExpLoadingBar:setPercentage(nowExp/maxExp*100)
 
    self:updateData()
    
    local pActionSize = table.getn(self._pDataInfo.templete.AttackActFrameRegions)
    for i=pActionSize-3,pActionSize do
        table.insert(self._tAllActions,self._pDataInfo.templete.AttackActFrameRegions[i])
    end
end

function PetFoodDialog:updateData()
    self.params._pFoodButton01:setTag(200003)
    self.params._pFoodButton02:setTag(200004)
    self.params._pFoodButton03:setTag(200005)
    
    if self._bGot == false then
        self.params._pFoodBg:setVisible(false)
    else
        self.params._pFoodBg:setVisible(true)
        local nowExp = PetsManager:getPetExpById(self._pDataInfo.id)
        local maxExp = TablePetsLevel[self._pDataInfo.level].PetsExp
        --self.params._pLoadingBar:runAction(cc.Sequence:create(cc.DelayTime:create(2), cc.ProgressTo:create(20, nowExp/maxExp*100)))
        if maxExp == 0 then
            self._pExpText:setString("满级")
            self.params._pFoodButton01:setVisible(false)
            self.params._pFoodButton02:setVisible(false)
            self.params._pFoodButton03:setVisible(false)
            self._pExpLoadingBar:setPercentage(100)
        else 
            self._pExpText:setString(nowExp.."/"..maxExp)
            self.params._pFoodButton01:setVisible(true)
            self.params._pFoodButton02:setVisible(true)
            self.params._pFoodButton03:setVisible(true)
        end
        
        --人物的等级
        local tParcent = {}
        local nLevel = self._pDataInfo.level
        local nLastLevel = self._nLastRoleLevel
        for i=1,(nLevel-nLastLevel) do
            table.insert(tParcent,{100,nLastLevel+(i-1)})
        end
        local nPercent = (nowExp/maxExp)*100
        table.insert(tParcent,{nPercent,nLevel})
        self._tPercent = tParcent
        
        local nSize = table.getn(self._tPercent)
        for i=1,nSize do 
            local callBack = function()
                if i<nSize then
                    self._pExpLoadingBar:setPercentage(0)
                elseif i == nSize then
                    
                end
            end   
            self._pExpLoadingBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*i), cc.ProgressTo:create(0.2, self._tPercent[i][1]),cc.CallFunc:create(callBack)))
        end
        
        self._tPercent = {}
        self._nLastRoleLevel = self._pDataInfo.level
    end
    
    for i=1,3 do
        self.params["_pFoodButton0"..i]:addTouchEventListener(function(sender, eventType)
            if self._pDataInfo ~= nil then
                if eventType == ccui.TouchEventType.ended then
                    local info = BagCommonManager:getInstance():getItemRealInfo(sender:getTag(),kItemType.kFeed)
                    if info.value <= 0 then
                    	NoticeManager:showSystemMessage("宠物食材不足")
                    	return
                    end
                    PetCGMessage:sendMessageFeed21510(self._pDataInfo.id,sender:getTag())
                elseif eventType == ccui.TouchEventType.began then
                    AudioManager:getInstance():playEffect("ButtonClick")
                end
            end
        end)
        
        local info = BagCommonManager:getInstance():getItemRealInfo(200003 - 1 + i,kItemType.kFeed)

        self.params["_pIcon0"..i]:loadTexture(
            info.templeteInfo.Icon..".png",
            ccui.TextureResType.plistType)
        self.params["_picontext0"..i]:setString(info.value)

        -- 宠物食材图标弹tips
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

    local levelIndex  = math.modf(self._pDataInfo.level/10) 
    local skillArry = self._pDataInfo.data.SkillIDs[levelIndex+1]
    for i=1,4 do
        if TablePets[self._pDataInfo.id].SkillRequiredLv[i] <= self.step  then
            self.params["_pPetSkill0"..i]:setString(TableTempleteSkills[TablePetsSkills[skillArry[i]].TempleteID].SkillName )
        else
            self.params["_pPetSkill0"..i]:setTextColor(cc.c4b(128, 128, 128, 128))
            self.params["_pPetSkill0"..i]:setString(TableTempleteSkills[TablePetsSkills[skillArry[i]].TempleteID].SkillName
                .." (" .. TablePets[self._pDataInfo.id].SkillRequiredLv[i] .."阶开启)" )
        end
    end
    
    for i=1,4 do
        local type = self._pDataInfo.data["SpecialType"..i]
        local value = self._pDataInfo.data["SpecialValue"..i]
        
        local temp1,temp2 =  math.modf(TablePetsLevel[self._pDataInfo.level].PetSpecialGrowth * value[self.step]/1) 
        local temp = temp2 > 0 and temp1 + 1 or temp1
        
        if TablePets[self._pDataInfo.id].SpecialRequiredLv[i] <= self.step  then
            self.params["_pRoleAttribute0"..i.."02"]:setString(temp)
        else
            self.params["_pRoleAttribute0"..i.."02"]:setTextColor(cc.c4b(128, 128, 128, 128))
            self.params["_pRoleAttribute0"..i.."01"]:setTextColor(cc.c4b(128, 128, 128, 128))
            self.params["_pRoleAttribute0"..i.."02"]:setString(temp.." (" .. TablePets[self._pDataInfo.id].SpecialRequiredLv[i] .."阶开启)" )
        end
    
        self.params["_pRoleAttribute0"..i.."01"]:setString(kAttributeNameTypeTitle[type])
    end
    
    self.params["_pAttack02"]:setString(math.ceil( self._pDataInfo.data.Attack + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.AttackGrowth[self.step]))
    self.params["_pPenetration02"]:setString(math.ceil(self._pDataInfo.data.Penetration + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.PenetrationGrowth[self.step]))
    self.params["_pCriticalChance02"]:setString(math.ceil(self._pDataInfo.data.CriticalChance + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.CriticalChanceGrowth[self.step]))
    self.params["_pCriticalDmage02"]:setString(math.ceil(self._pDataInfo.data.CriticalDmage + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.CriticalDmageGrowth[self.step]))
    self.params["_pAbilityPower02"]:setString(math.ceil(self._pDataInfo.data.AbilityPower + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.AbilityPowerGrowth[self.step]))
    self.params["_pFire02"]:setString(math.ceil(self._pDataInfo.data.FireAttack + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.FireAttackGrowth[self.step]))
    self.params["_pCold02"]:setString(math.ceil(self._pDataInfo.data.ColdAttack  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ColdAttackGrowth[self.step]))
    self.params["_pLightning02"]:setString(math.ceil(self._pDataInfo.data.LightningAttack  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LightningAttackGrowth[self.step]))
    self.params["_pHp02"]:setString(math.ceil(self._pDataInfo.data.Hp  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.HpGrowth[self.step]))
    self.params["_pDefend02"]:setString(math.ceil(self._pDataInfo.data.Defend  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DefendGrowth[self.step]))
    self.params["_pResilience02"]:setString(math.ceil(self._pDataInfo.data.Resilience  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ResilienceGrowth[self.step]))
    self.params["_pBlock02"]:setString(math.ceil(self._pDataInfo.data.Block  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.BlockGrowth[self.step]))
    self.params["_pDodgeChance02"]:setString(math.ceil(self._pDataInfo.data.DodgeChance  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DodgeChanceGrowth[self.step]))
    self.params["_pResistance02"]:setString(math.ceil(self._pDataInfo.data.Resistance  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ResistanceGrowth[self.step]))
    self.params["_pLifeperSecond02"]:setString(math.ceil(self._pDataInfo.data.LifeperSecond  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LifeperSecondGrowth[self.step]))
    self.params["_pLifeSteal02"]:setString(math.ceil(self._pDataInfo.data.LifeSteal  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LifeStealGrowth[self.step]))
    
    self.params["_pName"]:setString(self._pDataInfo.templete.PetName)
    local step = self._pDataInfo.step == 0 and 1 or self._pDataInfo.step
    self.params["_pName"]:setColor(kQualityFontColor3b[step])
    self.params["_pIcon"]:loadTexture(
        self._pDataInfo.templete.PetIcon ..".png"
        ,ccui.TextureResType.plistType)

    self.params["_pLv02"]:setString(self._pDataInfo.level)
    
    local step = self._pDataInfo.step == 0 and 1 or self._pDataInfo.step
    self.params["_pIconP"]:loadTexture("ccsComRes/qual_" ..step.."_normal.png",ccui.TextureResType.plistType)   
    
    self.params["_pQuality"]:setString(self._pDataInfo.step .. "阶")
    self.params["_pType"]:setString(petTypeColorDef[self._pDataInfo.data.PetFunction].name)
    self.params["_pType"]:setColor(petTypeColorDef[self._pDataInfo.data.PetFunction].color)
    
    self:updatePetRole()
end

function PetFoodDialog:updatePetRole()
    if self._pPetRole then   -- 如果不是第一次加载需要从新清除一下工程文件
        self._pPetRole:stopAllActions()
        self._pPetRole:removeFromParent(true)
        self._pPetRole = nil
    end

    self._pPetRole = cc.Sprite3D:create(self._pDataInfo.templete.Model..".c3b")
    self._pPetRole:setScale(self._pDataInfo.templete.ScaleInShow)
    self._pPetRole:setPosition(cc.p(self.params["_p3DBg"]:getContentSize().width/2,100))
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(self._pDataInfo.templete.Texture)
    self._pPetRole:setTexture(self._pDataInfo.templete.Texture..".pvr.ccz")
    self.params["_p3DBg"]:addChild(self._pPetRole,3)
    
    self._pPetRole:stopAllActions()
    self._pRoleAnimation = cc.Animation3D:create(self._pDataInfo.templete.Model..".c3b")
    local actionOverCallBack = function ()
        local pRunActAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, self._pDataInfo.templete.StandActFrameRegion[1],self._pDataInfo.templete.StandActFrameRegion[2])
        pRunActAnimate:setSpeed(self._pDataInfo.templete.StandActFrameRegion[3])
        self._pPetRole:runAction(cc.RepeatForever:create(pRunActAnimate))
    end

    local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,self._pDataInfo.templete.ShowActFrameRegion[1],self._pDataInfo.templete.ShowActFrameRegion[2])
    pStandAnimate:setSpeed(self._pDataInfo.templete.ShowActFrameRegion[3])
    self._pPetRole:runAction(cc.Sequence:create(pStandAnimate,cc.CallFunc:create(actionOverCallBack)))
   
    self._pPetRole:setPositionZ(5000)
end


-- 初始化触摸相关
function PetFoodDialog:initTouches()
    local pTouchPostion = nil
    local bIsMove = false
    local pTouchRec = self.params["_p3DBg"]:getBoundingBox()
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
            --self:close()
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
        if self._pPetRole and pTouchPostion then
            bIsMove = true
            local pRotation = self._pPetRole:getRotation3D()
            local dist = location.x - pTouchPostion.x
            pRotation.y = pRotation.y+dist/5
            self._pPetRole:setRotation3D(pRotation)
            pTouchPostion = location
        end

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end a ".."x="..location.x.."  y="..location.y)

        local actionOverCallBack = function()  --动画播放完毕的回调 播放默认待机动作
            local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation, self._pDataInfo.templete.StandActFrameRegion[1],self._pDataInfo.templete.StandActFrameRegion[2])
            pStandAnimate:setSpeed(self._pDataInfo.templete.StandActFrameRegion[3])
            self._pPetRole:runAction(cc.RepeatForever:create(pStandAnimate))
        end

        if pTouchPostion and bIsMove == false and (cc.rectContainsPoint(pTouchRec,pTouchPostion) == true) then -- 如果点击有位移了播放动画
            if self._pPetRole then
                self._pPetRole:stopAllActions()
                local len = table.getn(self._tAllActions)
                local  nRundom = mmo.HelpFunc:gGetRandNumberBetween(1,len)
                local  tAction = self._tAllActions[nRundom]
                local  pAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation,tAction[1],tAction[2])
                pAnimate:setSpeed(tAction[4])
                self._pPetRole:runAction(cc.Sequence:create(pAnimate,cc.CallFunc:create(actionOverCallBack)))
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
end

-- 退出函数
function PetFoodDialog:onExitSkillDialog()
    self:onExitDialog()
    
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("PetFood.plist")
end

function PetFoodDialog:handleMsgFeedPet(event)
    local info = PetsManager:getInstance():getPetInfoWithId(event.petInfo.petId,
        event.petInfo.step,
        event.petInfo.level)
    self._pDataInfo = info
    self:updateData()
end

return PetFoodDialog