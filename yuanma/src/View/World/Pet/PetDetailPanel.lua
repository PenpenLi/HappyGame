--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetDetailPanel.lua
-- author:    liyuhang
-- created:   2015/09/25
-- descrip:   战灵xq面板 
--===================================================
local PetDetailPanel = class("PetDetailPanel",function()
    return cc.Layer:create()
end)

--构造函数
function PetDetailPanel:ctor()
    self._strName = "PetDetailPanel"
    self._pDataInfo = nil
    self._pParams = nil
end

--创建函数
function PetDetailPanel:create(info)
    local layer = PetDetailPanel.new()
    layer:dispose(info)
    return layer
end

-- 处理函数
function PetDetailPanel:dispose(info)
    -- 右侧列表的回调函数
    self._pDataInfo = info
    
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetFeedPet, handler(self,self.handleMsgFeedPet))
    NetRespManager:getInstance():addEventListener(kNetCmd.kNetAdvancePet, handler(self,self.handleMsgAdvancePet))
    -- 加载图片资源
    ResPlistManager:getInstance():addSpriteFrames("PetDetailed.plist")
    -- 加载UI组件
    local params = require("PetDetailedParams"):create()
    self._pCCS = params._pCCS
    self._pParams = params

    self._pBg = params._pDetailedBg
    self:addChild(self._pCCS)

    self:updateData()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPetDetailPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

function PetDetailPanel:updateData()
    if self._pDataInfo == nil then
        return
    end
    
    local step = self._pDataInfo.step ~= 0 and self._pDataInfo.step or 1
    
    --头像icon
    self._pParams._pIcon:loadTexture(
        self._pDataInfo.templete.PetIcon..".png",
        ccui.TextureResType.plistType)
    --宠物名字
    self._pParams._pPetNameText:setString(self._pDataInfo.templete.PetName)
    --宠物等级
    self._pParams._pPetLvText:setString("Lv"..self._pDataInfo.level)
    --宠物类型
    self._pParams._pPetTypeText:setString(petTypeColorDef[self._pDataInfo.data.PetFunction].name)
    --宠物品质
    self._pParams._pPetPzText:setString(self._pDataInfo.step.."阶")
    --攻击值
    self._pParams._pText2_1:setString(math.ceil(self._pDataInfo.data.Attack + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.AttackGrowth[step]))
    --生命值
    self._pParams._pText4_1:setString(math.ceil(self._pDataInfo.data.Hp  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.HpGrowth[step]))
    --防御值
    self._pParams._pText3_1:setString(math.ceil(self._pDataInfo.data.Defend  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DefendGrowth[step]))
    --暴击值
    self._pParams._pText5_1:setString(math.ceil(self._pDataInfo.data.CriticalChance + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.CriticalChanceGrowth[step]))
    --暴伤值
    self._pParams._pText6_1:setString(math.ceil(self._pDataInfo.data.CriticalDmage + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.CriticalDmageGrowth[step]))
    --抗性值
    self._pParams._pText8_1:setString(math.ceil(self._pDataInfo.data.Resilience  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ResilienceGrowth[step]))
    --韧性值
    self._pParams._pText7_1:setString(math.ceil(self._pDataInfo.data.Resilience  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ResilienceGrowth[step]))
    --格挡值
    self._pParams._pText9_1:setString(math.ceil(self._pDataInfo.data.Block  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.BlockGrowth[step]))
    --穿透值
    self._pParams._pText10_1:setString(math.ceil(self._pDataInfo.data.Penetration + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.PenetrationGrowth[step]))
    --闪避值
    self._pParams._pText11_1:setString(math.ceil(self._pDataInfo.data.DodgeChance  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.DodgeChanceGrowth[step]))
    --再生值
    self._pParams._pText16_1:setString(math.ceil(self._pDataInfo.data.LifeperSecond  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LifeperSecondGrowth[step]))
    --吸血值
    self._pParams._pText17_1:setString(math.ceil(self._pDataInfo.data.LifeSteal  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LifeStealGrowth[step]))
    --属性强化值
    self._pParams._pText12_1:setString(math.ceil(self._pDataInfo.data.AbilityPower + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.AbilityPowerGrowth[step]))
    --火属性
    self._pParams._pText13_1:setString(math.ceil(self._pDataInfo.data.FireAttack + TablePetsLevel[self._pDataInfo.level].PetGrowth  * self._pDataInfo.data.FireAttackGrowth[step]))
    --冰属性
    self._pParams._pText14_1:setString(math.ceil(self._pDataInfo.data.ColdAttack  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.ColdAttackGrowth[step]))
    --雷属性
    self._pParams._pText15_1:setString(math.ceil(self._pDataInfo.data.LightningAttack  + TablePetsLevel[self._pDataInfo.level].PetGrowth * self._pDataInfo.data.LightningAttackGrowth[step]))
    
    local levelIndex  = math.modf(self._pDataInfo.level/10) 
    local skillArry = self._pDataInfo.data.SkillIDs[levelIndex+1]
    for i=1,4 do
        if TablePets[self._pDataInfo.id].SkillRequiredLv[i] <= step  then
            self._pParams["_pText"..(22+i)]:setString(TableTempleteSkills[TablePetsSkills[skillArry[i]].TempleteID].SkillName )
        else
            self._pParams["_pText"..(22+i)]:setTextColor(cc.c4b(128, 128, 128, 128))
            self._pParams["_pText"..(22+i)]:setString(TableTempleteSkills[TablePetsSkills[skillArry[i]].TempleteID].SkillName
                .." (" .. TablePets[self._pDataInfo.id].SkillRequiredLv[i] .."阶开启)" )
        end
    end

    for i=1,4 do
        local type = self._pDataInfo.data["SpecialType"..i]
        local value = self._pDataInfo.data["SpecialValue"..i]

        local temp1,temp2 =  math.modf(TablePetsLevel[self._pDataInfo.level].PetSpecialGrowth * value[step]/1) 
        local temp = temp2 > 0 and temp1 + 1 or temp1

        if TablePets[self._pDataInfo.id].SpecialRequiredLv[i] <= step  then
            self._pParams["_pText"..(18+i)]:setString(kAttributeNameTypeTitle[type] .. " +".. temp)
        else
            self._pParams["_pText"..(18+i)]:setTextColor(cc.c4b(128, 128, 128, 128))
            self._pParams["_pText"..(18+i)]:setString(kAttributeNameTypeTitle[type] .. " +".. temp.." (" .. TablePets[self._pDataInfo.id].SpecialRequiredLv[i] .."阶开启)" )
        end
    end
end

function PetDetailPanel:handleMsgAdvancePet(event)
    if event.step == nil then
    	return
    end
    
    self._pDataInfo.step = event.step

    self._pDataInfo = PetsManager:getInstance():getPetInfoWithId(self._pDataInfo.id,
        self._pDataInfo.step,
        self._pDataInfo.level)
    
    self:updateData()
end

function PetDetailPanel:handleMsgFeedPet(event)
    local info = PetsManager:getInstance():getPetInfoWithId(event.petInfo.petId,
        event.petInfo.step,
        event.petInfo.level)
    self._pDataInfo = info
    self:updateData()
end

function PetDetailPanel:onExitPetDetailPanel()
    -- 释放宝石合成资源
    ResPlistManager:getInstance():removeSpriteFrames("PetDetailed.plist")
    -- 释放网络监听事件
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

return PetDetailPanel