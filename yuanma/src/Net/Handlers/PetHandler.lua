--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PetHandler.lua
-- author:    liyuhang
-- created:   2015/4/27
-- descrip:   宠物相关handler
--===================================================
local PetHandler = class("PetHandler")

-- 构造函数
function PetHandler:ctor()     
    -- 获取宠物列表列表
    NetHandlersManager:registHandler(21501, self.handleMsgGetPetsList)
    -- 请求上阵宠物
    NetHandlersManager:registHandler(21503, self.handleMsgField)
    -- 下阵宠物
    NetHandlersManager:registHandler(21505, self.handleMsgUnField)
    -- 合成宠物
    NetHandlersManager:registHandler(21507, self.handleMsgCompound)
    -- 进阶宠物
    NetHandlersManager:registHandler(21509, self.handleMsgAdvance)
    -- 喂食宠物
    NetHandlersManager:registHandler(21511, self.handleMsgFeed)
end

-- 创建函数
function PetHandler:create()
    print("PetHandler create")
    local handler = PetHandler.new()
    return handler
end

-- 获取宠物列表列表
function PetHandler:handleMsgGetPetsList(msg)
    print("PetHandler 21501")
    if msg.header.result == 0 then
        PetsManager:getInstance()._tMainPetsInfos = msg.body.petInfos
        PetsManager:getInstance():setMountPets(msg.body.fieldIds)
        
        --DialogManager:getInstance():showDialog("PetDialog",{msg.body.petInfos})
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetGetPets, msg.body)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 请求上阵宠物
function PetHandler:handleMsgField(msg)
    print("PetHandler 21503")
    if msg.header.result == 0 then 
        --if table.getn(msg.body.roleInfo) > 0 then
        local fightPowerChange = msg.body.roleInfo.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        if fightPowerChange ~= 0 then
            NoticeManager:getInstance():showFightStrengthChange(fightPowerChange)
        end

        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg.body.roleInfo
        RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        --end
    
        PetsManager:getInstance():setMountPets(msg.body.fieldIds)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetFieldPet, msg.body)
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

-- 下阵宠物
function PetHandler:handleMsgUnField(msg)
    print("PetHandler 21505")
    if msg.header.result == 0 then 
        --if table.getn(msg.body.roleInfo) > 0 then
        local fightPowerChange = msg.body.roleInfo.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        if fightPowerChange ~= 0 then
            NoticeManager:getInstance():showFightStrengthChange(fightPowerChange)
        end

        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg.body.roleInfo
        RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        --end
    
        PetsManager:getInstance():setMountPets(msg.body.fieldIds)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetUnFieldPet, msg.body)
    else
        print("返回错误码："..msg.header.result)
    end
end

-- 合成宠物
function PetHandler:handleMsgCompound(msg)
    print("PetHandler 21507")
    if msg.header.result == 0 then 
        PetsManager:getInstance()._tMainPetsInfos = msg.body.petInfos
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetCompoundPet, msg.body)
        
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

-- 进阶宠物
function PetHandler:handleMsgAdvance(msg)
    print("PetHandler 21509")
    if msg.header.result == 0 then 
        --if table.getn(msg.body.roleInfo) > 0 then
        local fightPowerChange = msg.body.roleInfo.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        if fightPowerChange ~= 0 then
            NoticeManager:getInstance():showFightStrengthChange(fightPowerChange)
        end

        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg.body.roleInfo
        RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        --end
    
        BagCommonManager:getInstance():updateItemArry(msg["body"].itemInfos)
        --print_lua_table(msg["body"].itemInfos)
        PetsManager:getInstance():AdvancePetWithId(msg["body"]["argsBody"].petId , msg.body.step)
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, {})
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetAdvancePet, msg.body)
       
    else
        print("返回错误码："..msg.header.result)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetAdvancePet, msg.body)
    end
end

-- 喂食宠物
function PetHandler:handleMsgFeed(msg)
    print("PetHandler 21511")
    if msg.header.result == 0 then 
        --if table.getn(msg.body.roleInfo) > 0 then
        local fightPowerChange = msg.body.roleInfo.fightingPower - RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        if fightPowerChange ~= 0 then
            NoticeManager:getInstance():showFightStrengthChange(fightPowerChange)
        end

        RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo = msg.body.roleInfo
        RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        --end
        
        for i=1,table.getn(PetsManager:getInstance()._tMainPetsInfos) do
            if PetsManager:getInstance()._tMainPetsInfos[i].petId == msg.body.petInfo.petId then
                PetsManager:getInstance()._tMainPetsInfos[i] = msg.body.petInfo
                
                if PetsManager:getInstance():isPetField(msg.body.petInfo.petId) == true then
                    PetsManager:getInstance():setMountPets(PetsManager:getInstance()._tMountPetsIdsInQueue)
                end
        	end
        end

        BagCommonManager:getInstance():updateItemArry(msg["body"].itemInfos)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, {})
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetFeedPet, msg.body)
        
        NewbieManager:showOutAndRemoveWithRunTime()

    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

return PetHandler