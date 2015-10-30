--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetEvolutionPanel.lua
-- author:    liyuhang
-- created:   2015/09/25
-- descrip:   战灵升阶面板 
--===================================================
local PetEvolutionPanel = class("PetEvolutionPanel",function()
    return cc.Layer:create()
end)

--构造函数
function PetEvolutionPanel:ctor()
    self._strName = "PetEvolutionPanel"
    self._pDataInfo = nil
    self._pParams = nil
    self._bCanAdvance = true
end

--创建函数
function PetEvolutionPanel:create(info)
    local layer = PetEvolutionPanel.new()
    layer:dispose(info)
    return layer
end

-- 处理函数
function PetEvolutionPanel:dispose(info)
    -- 右侧列表的回调函数
    self._pDataInfo = info
    
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    -- 加载图片资源
    ResPlistManager:getInstance():addSpriteFrames("AdvancedPetPanel.plist")
    -- 加载UI组件
    local params = require("AdvancedPetPanelParams"):create()
    self._pCCS = params._pCCS
    self._pParams = params

    self._pBg = params._pAdvancedPetBg
    self:addChild(self._pCCS)
    
    params._pJjieButton:addTouchEventListener(function(sender, eventType) 
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

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetEvolutionPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

function PetEvolutionPanel:updateData()
    if self._pDataInfo == nil then
        return
    end

    local step = self._pDataInfo.step ~= 0 and self._pDataInfo.step or 1

    self._pParams._pNameText:setString(self._pDataInfo.templete.PetName)
    self._pParams._pPetTypeText:setString(petTypeColorDef[self._pDataInfo.data.PetFunction].name)
    self._pParams._pLvText:setString("Lv"..self._pDataInfo.level)
    self._pParams._pPzText1:setString(step.."阶")
    self._pParams._pPzText2:setString((step + 1).."阶")
    
    --宠物生命值
    self._pParams._pshxtextNum:setString(math.ceil(self._pDataInfo.data.Hp  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.HpGrowth[step]))
    --升阶后生命值
    self._pParams._pshxtextNum_1:setString(math.ceil(self._pDataInfo.data.Hp  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.HpGrowth[step+1]))
    --宠物防御力值
    self._pParams._pfangyutextNum:setString(math.ceil(self._pDataInfo.data.Defend  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DefendGrowth[step]))
    --升阶后防御力
    self._pParams._pfangyutextNum1:setString(math.ceil(self._pDataInfo.data.Defend  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DefendGrowth[step+1]))
    --宠物攻击力值
    self._pParams._pGjltextNum:setString(math.ceil(self._pDataInfo.data.Attack + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.AttackGrowth[step]))
    --升阶后攻击力
    self._pParams._pGjltextNum_1:setString(math.ceil(self._pDataInfo.data.Attack + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.AttackGrowth[step+1]))

    local chipCount = BagCommonManager:getInstance():getItemNumById(self._pDataInfo.data.PieceID)
    --升阶材料1数量
    self._pParams._pIcon1Num:setString(chipCount .. "/" .. self._pDataInfo.data.PieceNum)
    --宠物升阶材料1图标
    self._pParams._pIcon1:loadTexture(
        self._pDataInfo.templete.PetIcon..".png",
        ccui.TextureResType.plistType)
    
    local MaterialRequiredinfo = self._pDataInfo.data["MaterialRequired"..step]
    for i=1,3 do
        local info = BagCommonManager:getInstance():getItemRealInfo(200036 - 1 + i,kItemType.kFeed)
        --升阶数量
        self._pParams["_pIcon".. (i+1) .."Num"]:setString(info.value.. "/"..MaterialRequiredinfo[i+1][2])
        --宠物升阶材料1图标
        self._pParams["_pIcon"..(i+1)]:loadTexture(
            info.templeteInfo.Icon..".png",
            ccui.TextureResType.plistType)
    end
    
end

function PetEvolutionPanel:handleMsgAdvancePet(event)
    if event.step == nil then
        self._bCanAdvance = true  
        return
    end

    self._pDataInfo.step = event.step

    self._pDataInfo = PetsManager:getInstance():getPetInfoWithId(self._pDataInfo.id,
        self._pDataInfo.step,
        self._pDataInfo.level)
    if self._pDataInfo.step == 5 then
        --self:close()    
    else
        self._bCanAdvance = true  
    end

    self:updateData()
end

function PetEvolutionPanel:handleMsgFeedPet(event)
    local info = PetsManager:getInstance():getPetInfoWithId(event.petInfo.petId,
        event.petInfo.step,
        event.petInfo.level)
    self._pDataInfo = info
    self:updateData()
end

function PetEvolutionPanel:onExitPetEvolutionPanel()
    -- 释放宝石合成资源
    ResPlistManager:getInstance():removeSpriteFrames("AdvancedPetPanel.plist")
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return PetEvolutionPanel