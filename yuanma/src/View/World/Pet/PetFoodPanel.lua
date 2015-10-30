--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetFoodPanel.lua
-- author:    liyuhang
-- created:   2015/09/25
-- descrip:   战灵喂食面板 
--===================================================
local PetFoodPanel = class("PetFoodPanel",function()
    return cc.Layer:create()
end)

--构造函数
function PetFoodPanel:ctor()
    self._strName = "PetFoodPanel"
    self._pDataInfo = nil
    self._pParams = nil
end

--创建函数
function PetFoodPanel:create(info)
    local layer = PetFoodPanel.new()
    layer:dispose(info)
    return layer
end

-- 处理函数
function PetFoodPanel:dispose(info)
    -- 右侧列表的回调函数
    self._pDataInfo = info
    
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    -- 加载图片资源
    ResPlistManager:getInstance():addSpriteFrames("FoodPanel.plist")
    -- 加载UI组件
    local params = require("FoodPanelParams"):create()
    self._pCCS = params._pCCS
    self._pParams = params
   
    self._pBg = params._pRightBg
    self:addChild(self._pCCS)
   
    self:updateData()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetFoodPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function PetFoodPanel:updateData()
    if self._pDataInfo == nil then
		return
	end
	
    local step = self._pDataInfo.step ~= 0 and self._pDataInfo.step or 1
	
    self._pParams._pNameText:setString(self._pDataInfo.templete.PetName)
    self._pParams._pPetTypeText:setString(petTypeColorDef[self._pDataInfo.data.PetFunction].name)
    self._pParams._pPzText:setString(self._pDataInfo.step.."阶")
    self._pParams._pLvText:setString("Lv"..self._pDataInfo.level)
    self._pParams._pPowerFnts:setString("Lv"..self._pDataInfo.level)
    self._pParams._pshxtextNum:setString(math.ceil(self._pDataInfo.data.Hp  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.HpGrowth[step]))
    self._pParams._pfangyutextNum:setString(math.ceil(self._pDataInfo.data.Defend  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DefendGrowth[step]))
    self._pParams._pGjltextNum:setString(math.ceil(self._pDataInfo.data.Attack + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.AttackGrowth[step]))
    local nowExp = PetsManager:getPetExpById(self._pDataInfo.id)
    local maxExp = TablePetsLevel[self._pDataInfo.level].PetsExp
    self._pParams._pExpBar:setPercent(nowExp/maxExp*100)
    self._pParams._pExpTextNum:setString(nowExp.."/"..maxExp)
    
    for i=1,3 do
        self._pParams["_pWsButton"..i]:addTouchEventListener(function(sender, eventType)
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
        self._pParams["_pWsButton"..i]:setTag(200003 - 1 + i)
        
        if self._pDataInfo.step == 0 then
            self._pParams["_pWsButton"..i]:setVisible(false)
        else
            self._pParams["_pWsButton"..i]:setVisible(true)
        end

        local info = BagCommonManager:getInstance():getItemRealInfo(200003 - 1 + i,kItemType.kFeed)

        self._pParams["_pIcon"..i]:loadTexture(
            info.templeteInfo.Icon..".png",
            ccui.TextureResType.plistType)
        --self.params["_picontext0"..i]:setString(info.value)

        -- 宠物食材图标弹tips
        local function touchEvent(sender,eventType) 
            if eventType == ccui.TouchEventType.ended then 
                DialogManager:getInstance():showDialog("BagCallOutDialog",{info,nil,nil,false})
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end
        self._pParams["_pIcon"..i]:setTouchEnabled(true)
        --self.params["_pIcon"..i]:addTouchEventListener(touchEvent)
    end
end

function PetFoodPanel:handleMsgAdvancePet(event)
    if event.step == nil then
        return
    end

    self._pDataInfo.step = event.step

    self._pDataInfo = PetsManager:getInstance():getPetInfoWithId(self._pDataInfo.id,
        self._pDataInfo.step,
        self._pDataInfo.level)

    self:updateData()
end

function PetFoodPanel:handleMsgFeedPet(event)
    local info = PetsManager:getInstance():getPetInfoWithId(event.petInfo.petId,
        event.petInfo.step,
        event.petInfo.level)
    self._pDataInfo = info
    self:updateData()
end

function PetFoodPanel:onExitPetFoodPanel()
    -- 释放宝石合成资源
    ResPlistManager:getInstance():removeSpriteFrames("FoodPanel.plist")
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return PetFoodPanel