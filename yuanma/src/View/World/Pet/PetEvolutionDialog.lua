--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetEvolutionDialog.lua
-- author:    liyuhang
-- created:   2015/4/22
-- descrip:   宠物升阶系统面板
--===================================================
local PetEvolutionDialog = class("PetEvolutionDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function PetEvolutionDialog:ctor()
    -- 层名字
    self._strName = "PetEvolutionDialog" 
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
    
    self._bCanAdvance = true
end

-- 创建函数
function PetEvolutionDialog:create(args)
    local layer = PetEvolutionDialog.new()
    layer:dispose(args)
    return layer
end

-- 处理函数
function PetEvolutionDialog:dispose(args)
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetReconnected, handler(self,self.handleMsgNetReconnected))
    --NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFisance, handler(self,self.handleMsgUpdateFisance))
    -- 加载商城的 合图资源
    self._pDataInfo = args[1]
    
    ResPlistManager:getInstance():addSpriteFrames("PetEvolution.plist")

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
function PetEvolutionDialog:initUI()
    -- 加载组件
    local params = require("PetEvolutionParams"):create()
    self.params = params   
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton

    self:disposeCSB()
    
    params._pScrollView:setClippingEnabled(true)
    
    if self._pDataInfo.step ~= 5 then
        self._bCanAdvance = true        
    end
    
    params._pSureButton:addTouchEventListener(function(sender, eventType) 
        if eventType == ccui.TouchEventType.ended then
            if self._bCanAdvance == true then
                local chipCount = BagCommonManager:getInstance():getItemNumById(self._pDataInfo.data.PieceID)
        
                if chipCount < self._pDataInfo.data.PieceNum then
                	NoticeManager:showSystemMessage("战灵碎片不足")
                	return
                end
            
                PetCGMessage:sendMessageAdvance21508(self._pDataInfo.id)
                self._bCanAdvance = false
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self:updateData()
end

function PetEvolutionDialog:updateData()
    if self._pDataInfo.step < 5 then
        local MaterialRequiredinfo = self._pDataInfo.data["MaterialRequired"..self._pDataInfo.step]

        for i=1,3 do
            local info = BagCommonManager:getInstance():getItemRealInfo(200036 - 1 + i,kItemType.kFeed)

            self.params["_pIcon0"..i]:loadTexture(
                info.templeteInfo.Icon..".png",
                ccui.TextureResType.plistType)

            if info.value < MaterialRequiredinfo[i+1][2] then
                self.params["_picontext0"..i]:setTextColor(cc.c4b(255, 0, 0, 255))
            else
                self.params["_picontext0"..i]:setTextColor(cc.c4b(255, 255, 255, 255))
            end    

            self.params["_picontext0"..i]:setString(info.value.. "/"..MaterialRequiredinfo[i+1][2])

            -- 宠物进阶材料弹tips
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
    else
        for i=1,3 do
            self.params["_pIcon0"..i]:setVisible(false)
            self.params["_picontext0"..i]:setVisible(false)
        end
    end 
    
    local chipCount = BagCommonManager:getInstance():getItemNumById(self._pDataInfo.data.PieceID)
    --宠物碎片进度条
    --self._pLoadingBar = self._pIcon01:getChildByName("LoadingBar")
    --碎片进度条上的数字“10/10”
    self.params["_pTextLoad"]:setString(chipCount .. "/" .. self._pDataInfo.data.PieceNum)
    self.params["_pLoadingBar"]:setPercent(chipCount/self._pDataInfo.data.PieceNum * 100)
    
    --宠物icon
    self.params["_pIcon"]:loadTexture(
        self._pDataInfo.templete.PetIcon..".png",
            ccui.TextureResType.plistType)
    --宠物名称
    self.params["_pName"]:setString(self._pDataInfo.templete.PetName)
  
    --宠物等级具体数字
    self.params["_pLv02"]:setString(self._pDataInfo.level)
    --宠物类型
    self.params["_pType"]:setString(self._pDataInfo.level)
    --宠物当前品质
    self.params["_pQuality"]:setString(self._pDataInfo.step.."阶")

    local levelIndex  = math.modf(self._pDataInfo.level/10) 
    local skillArry = self._pDataInfo.data.SkillIDs[levelIndex+1]
    for i=1,4 do
        if TablePets[self._pDataInfo.id].SkillRequiredLv[i] <= self._pDataInfo.step  then
            self.params["_pPetSkill0"..i]:setTextColor(cc.c4b(255, 255, 255, 255))
        else
            self.params["_pPetSkill0"..i]:setTextColor(cc.c4b(128, 128, 128, 128))
        end
        self.params["_pPetSkill0"..i]:setString(TableTempleteSkills[TablePetsSkills[skillArry[i]].TempleteID].SkillName)
    end

    for i=1,4 do
        if TablePets[self._pDataInfo.id].SpecialRequiredLv[i] <= self._pDataInfo.step  then
            self.params["_pRoleAttribute0"..i.."02"]:setTextColor(cc.c4b(255, 255, 255, 255))
            self.params["_pRoleAttribute0"..i.."01"]:setTextColor(cc.c4b(255, 255, 255, 255))
            self.params["_pScrollView"]:getChildByName("RoleAttribute0"..i.."03"):setTextColor(cc.c4b(255, 255, 255, 255))
        else
            self.params["_pRoleAttribute0"..i.."02"]:setTextColor(cc.c4b(128, 128, 128, 255))
            self.params["_pRoleAttribute0"..i.."01"]:setTextColor(cc.c4b(128, 128, 128, 255))
            self.params["_pScrollView"]:getChildByName("RoleAttribute0"..i.."03"):setTextColor(cc.c4b(128, 128, 128, 255))
        end
    
        local type = self._pDataInfo.data["SpecialType"..i]
        local value = self._pDataInfo.data["SpecialValue"..i]
        local temp21,temp22 =  math.modf(TablePetsLevel[self._pDataInfo.level].PetSpecialGrowth * value[self._pDataInfo.step]/1) 
        local temp2 = temp22 > 0 and temp21 + 1 or temp21
        
        local temp31,temp32 =  math.modf((TablePetsLevel[self._pDataInfo.level].PetSpecialGrowth * value[self._pDataInfo.step+1] 
            - TablePetsLevel[self._pDataInfo.level].PetSpecialGrowth * value[self._pDataInfo.step])/1) 
        local temp3 = temp32 > 0 and temp31 + 1 or temp31
        
        self.params["_pRoleAttribute0"..i.."02"]:setString(temp2)
        self.params["_pRoleAttribute0"..i.."01"]:setString(kAttributeNameTypeTitle[type])
        self.params["_pScrollView"]:getChildByName("RoleAttribute0"..i.."03"):setString("+" .. temp3 )
    end
    
    self.params["_pAttack02"]:setString(math.ceil(self._pDataInfo.data.Attack + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.AttackGrowth[self._pDataInfo.step]))
    self.params["_pPenetration02"]:setString(math.ceil(self._pDataInfo.data.Penetration + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.PenetrationGrowth[self._pDataInfo.step]))
    self.params["_pCriticalChance02"]:setString(math.ceil(self._pDataInfo.data.CriticalChance + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.CriticalChanceGrowth[self._pDataInfo.step]))
    self.params["_pCriticalDmage02"]:setString(math.ceil(self._pDataInfo.data.CriticalDmage + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.CriticalDmageGrowth[self._pDataInfo.step]))
    self.params["_pAbilityPower02"]:setString(math.ceil(self._pDataInfo.data.AbilityPower + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.AbilityPowerGrowth[self._pDataInfo.step]))
    self.params["_pFire02"]:setString(math.ceil(self._pDataInfo.data.FireAttack + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.FireAttackGrowth[self._pDataInfo.step]))
    self.params["_pCold02"]:setString(math.ceil(self._pDataInfo.data.ColdAttack  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ColdAttackGrowth[self._pDataInfo.step]))
    self.params["_pLightning02"]:setString(math.ceil(self._pDataInfo.data.LightningAttack  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LightningAttackGrowth[self._pDataInfo.step]))
    self.params["_pHp02"]:setString(math.ceil(self._pDataInfo.data.Hp  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.HpGrowth[self._pDataInfo.step]))
    self.params["_pDefend02"]:setString(math.ceil(self._pDataInfo.data.Defend  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DefendGrowth[self._pDataInfo.step]))
    self.params["_pResilience02"]:setString(math.ceil(self._pDataInfo.data.Resilience  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ResilienceGrowth[self._pDataInfo.step]))
    self.params["_pBlock02"]:setString(math.ceil(self._pDataInfo.data.Block  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.BlockGrowth[self._pDataInfo.step]))
    self.params["_pDodgeChance02"]:setString(math.ceil(self._pDataInfo.data.DodgeChance  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DodgeChanceGrowth[self._pDataInfo.step]))
    self.params["_pResistance02"]:setString(math.ceil(self._pDataInfo.data.Resistance  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ResistanceGrowth[self._pDataInfo.step]))
    self.params["_pLifeperSecond02"]:setString(math.ceil(self._pDataInfo.data.LifeperSecond  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LifeperSecondGrowth[self._pDataInfo.step]))
    self.params["_pLifeSteal02"]:setString(math.ceil(self._pDataInfo.data.LifeSteal  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LifeStealGrowth[self._pDataInfo.step]))
    
    self.params["_pAttack03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth * (self._pDataInfo.data.AttackGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.AttackGrowth[self._pDataInfo.step])))
    self.params["_pPenetration03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth  *(self._pDataInfo.data.PenetrationGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.PenetrationGrowth[self._pDataInfo.step])))
    self.params["_pCriticalChance03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth  *(self._pDataInfo.data.CriticalChanceGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.CriticalChanceGrowth[self._pDataInfo.step])) )
    self.params["_pCriticalDmage03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth  *(self._pDataInfo.data.CriticalDmageGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.CriticalDmageGrowth[self._pDataInfo.step]) ))
    self.params["_pAbilityPower03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth  *(self._pDataInfo.data.AbilityPowerGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.AbilityPowerGrowth[self._pDataInfo.step]) ))
    self.params["_pFire03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth  *(self._pDataInfo.data.FireAttackGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.FireAttackGrowth[self._pDataInfo.step]) ))
    self.params["_pCold03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.ColdAttackGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.ColdAttackGrowth[self._pDataInfo.step]) ))
    self.params["_pLightning03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.LightningAttackGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.LightningAttackGrowth[self._pDataInfo.step]) ))
    self.params["_pHp03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.HpGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.HpGrowth[self._pDataInfo.step]) ))
    self.params["_pDefend03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.DefendGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.DefendGrowth[self._pDataInfo.step]) ))
    self.params["_pResilience03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.ResilienceGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.ResilienceGrowth[self._pDataInfo.step]) ))
    self.params["_pBlock03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.BlockGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.BlockGrowth[self._pDataInfo.step]) ))
    self.params["_pDodgeChance03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.DodgeChanceGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.DodgeChanceGrowth[self._pDataInfo.step]) ))
    self.params["_pResistance03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.ResistanceGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.ResistanceGrowth[self._pDataInfo.step]) ))
    self.params["_pLifeperSecond03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.LifeperSecondGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.LifeperSecondGrowth[self._pDataInfo.step]) ))
    self.params["_pLifeSteal03"]:setString("+" .. math.ceil(TablePetsLevel[self._pDataInfo.level].PetGrowth *(self._pDataInfo.data.LifeStealGrowth[self._pDataInfo.step+1]-self._pDataInfo.data.LifeStealGrowth[self._pDataInfo.step]) ))
    
    self:updatePetRole()
end

function PetEvolutionDialog:updatePetRole()
    if self._pPetRole then   -- 如果不是第一次加载需要从新清除一下工程文件
        self._pPetRole:stopAllActions()
        self._pPetRole:removeFromParent(true)
        self._pPetRole = nil
    end

    self._pPetRole = cc.Sprite3D:create(self._pDataInfo.templete.Model..".c3b")
    self._pPetRole:setScale(self._pDataInfo.templete.ScaleInShow)
    self._pPetRole:setPosition(cc.p(self.params["_p3DBg"]:getContentSize().width/2-270,30))
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(self._pDataInfo.templete.Texture)
    self._pPetRole:setTexture(self._pDataInfo.templete.Texture..".pvr.ccz")
    self.params["_p3DBg"]:addChild(self._pPetRole,3)
    
    self.params["_plevelBefore"]:loadTexture(
        "PetEvolutionRes/level"..(self._pDataInfo.step)..".png",
        ccui.TextureResType.plistType)
    self.params["_plevelAfter"]:loadTexture(
        "PetEvolutionRes/level"..(self._pDataInfo.step+1)..".png",
        ccui.TextureResType.plistType)

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
    
    local nextInfo = PetsManager:getInstance():getPetInfoWithId(self._pDataInfo.id,
        self._pDataInfo.step+1,
        self._pDataInfo.level)
    
    if self._pPetRole1 then   -- 如果不是第一次加载需要从新清除一下工程文件
        self._pPetRole1:stopAllActions()
        self._pPetRole1:removeFromParent(true)
        self._pPetRole1 = nil
    end

    self._pPetRole1 = cc.Sprite3D:create(nextInfo.templete.Model..".c3b")
    self._pPetRole1:setScale(nextInfo.templete.ScaleInShow)
    self._pPetRole1:setPosition(cc.p(self.params["_p3DBg"]:getContentSize().width/2+270,30))
    ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(nextInfo.templete.Texture)
    self._pPetRole1:setTexture(nextInfo.templete.Texture..".pvr.ccz")
    self.params["_p3DBg"]:addChild(self._pPetRole1,3)

    self._pPetRole1:stopAllActions()
    self._pRoleAnimation1 = cc.Animation3D:create(nextInfo.templete.Model..".c3b")
    local actionOverCallBack = function ()
        local pRunActAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation1, nextInfo.templete.StandActFrameRegion[1],nextInfo.templete.StandActFrameRegion[2])
        pRunActAnimate:setSpeed(nextInfo.templete.StandActFrameRegion[3])
        self._pPetRole1:runAction(cc.RepeatForever:create(pRunActAnimate))
    end

    local pStandAnimate = cc.Animate3D:createWithFrames(self._pRoleAnimation1,nextInfo.templete.ShowActFrameRegion[1],nextInfo.templete.ShowActFrameRegion[2])
    pStandAnimate:setSpeed(nextInfo.templete.ShowActFrameRegion[3])
    self._pPetRole1:runAction(cc.Sequence:create(pStandAnimate,cc.CallFunc:create(actionOverCallBack)))
    
    -- 强制设置所有角色positionZ到最小值
    self._pPetRole:setPositionZ(5000)
    self._pPetRole1:setPositionZ(5000)
end

-- 初始化触摸相关
function PetEvolutionDialog:initTouches()
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
function PetEvolutionDialog:onExitSkillDialog()
    self:onExitDialog()
    
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("PetEvolution.plist")
end

function PetEvolutionDialog:handleMsgAdvancePet(event)
    if event.step == nil then
        self._bCanAdvance = true  
        return
    end

    self._pDataInfo.step = event.step
    
    self._pDataInfo = PetsManager:getInstance():getPetInfoWithId(self._pDataInfo.id,
        self._pDataInfo.step,
        self._pDataInfo.level)
    if self._pDataInfo.step == 5 then
        self:close()    
    else
        self._bCanAdvance = true  
    end
    
    self:updateData()
end

function PetEvolutionDialog:handleMsgNetReconnected(event)
    self._bCanAdvance = true  
end

return PetEvolutionDialog