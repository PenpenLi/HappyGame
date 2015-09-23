--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EquipmentHandler.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2014/12/16
-- descrip:  装备相关handler
--===================================================
local EquipmentHandler = class("EquipmentHandler")

-- 构造函数
function EquipmentHandler:ctor()
    -- 装备穿戴
    NetHandlersManager:registHandler(20107, self.handleWareEquipment20107)
    -- 时装是否显示
    NetHandlersManager:registHandler(20111, self.handleFashionOpt20111)
    --分解装备
    NetHandlersManager:registHandler(20113, self.handleResolveEquipment20113)
    --背包装备强化
    NetHandlersManager:registHandler(20125, self.handleIntensifyBagEquipment20125)
    --身上装备强化
    NetHandlersManager:registHandler(20127, self.handleIntensifyRoleEquipment20127)
    --修改昵称
    NetHandlersManager:registHandler(20011, self.handleRoleChangeName20011)
    --出售物品
    NetHandlersManager:registHandler(20129, self.handlekSellItem20129)
    --锻造装备
    NetHandlersManager:registHandler(20131, self.handleFoundryEquipment20131)
    -- 一键出售白绿装备
    NetHandlersManager:registHandler(20137, self.handlesellChapEquipByAuto20137)
    
    
end

-- 创建函数
function EquipmentHandler:create()
    print("EquipmentHandler create")
    local handler = EquipmentHandler.new()
    return handler
end


-- 穿戴装备
function EquipmentHandler:handleWareEquipment20107(msg)
    print("bagCommoneHandler 20107")
    if msg.header.result == 0 then
        --更新背包数据
        BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        local event = msg["body"]        
        -- warning  ： 要先更新任务装备信息，再发送更新背包事件
        --装备穿戴的存储
        local nPowerChange = event.roleInfo.roleAttrInfo.fightingPower-RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        if nPowerChange ~=0 and nPowerChange ~= nil  then
            NoticeManager:getInstance():showFightStrengthChange(nPowerChange)
        end
        --更新人物信息
        RolesManager:getInstance():setMainRole(event.roleInfo)
        
        NewbieManager:showOutAndRemoveWithRunTime()
        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kWareEquipment,event)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
    else
        print("返回错误码："..msg.header.result)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

--时装显示

function EquipmentHandler:handleFashionOpt20111(msg)
 print("bagCommoneHandler 20111")
    if msg.header.result == 0 then
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kFashionHasWare, event)
    
    else
        print("返回错误码："..msg.header.result)
    end
end

--分解装备

function EquipmentHandler:handleResolveEquipment20113( msg )
   print("bagCommoneHandler 20113")
    if msg.header.result == 0 then

    NetRespManager:getInstance():dispatchEvent(kNetCmd.kResolveEquipment, nil)
    else
        print("返回错误码："..msg.header.result)
    end
end



--强化背包装备
function EquipmentHandler:handleIntensifyBagEquipment20125( msg )
 print("bagCommoneHandler 20125")
    if msg.header.result == 0 then
     local event = msg["body"]
     NetRespManager:getInstance():dispatchEvent(kNetCmd.kIntensifyyBagEquipment, event)
    else
        print("返回错误码："..msg.header.result)
        DialogManager:getInstance():getDialogByName("EquipmentDialog"):setTouchEnableInDialog(false)
    end

end

--强化人物装备
function EquipmentHandler:handleIntensifyRoleEquipment20127( msg )
 print("bagCommoneHandler 20127")
    if msg.header.result == 0 then
        local event = msg["body"]
        --如果从RolesInfoDialog中过来的需要刷新装备和人物属性信息
        --发强化人物身上装备的信息

        NetRespManager:getInstance():dispatchEvent(kNetCmd.kIntensifyyRoleEquipment,event)
        NewbieManager:showOutAndRemoveWithRunTime()
    else
        print("返回错误码："..msg.header.result)
        DialogManager:getInstance():getDialogByName("EquipmentDialog"):setTouchEnableInDialog(false)
        NewbieManager:showOutAndRemoveWithRunTime()
    end
end

--修改昵称回复
function EquipmentHandler:handleRoleChangeName20011( msg )
    print("bagCommoneHandler 20011")
    if msg.header.result == 0 then
        local event = msg["body"]
        local pNewRoleName = event["argsBody"].name
        RolesManager:getInstance()._pMainRoleInfo.roleName = pNewRoleName
        RolesManager:getInstance():setMainRole(RolesManager:getInstance()._pMainRoleInfo)
        --如果从RolesInfoDialog中过来的需要刷新装备和人物属性信息        
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kChangeName,event)
        DialogManager:getInstance():closeDialogByName("RolesChangeNameDialog")   
        NoticeManager:getInstance():showSystemMessage("昵称修改成功")
    else
        print("返回错误码："..msg.header.result)

    end
end

--出售物品
function EquipmentHandler:handlekSellItem20129( msg )
    print("bagCommoneHandler 20129")
    if msg.header.result == 0 then
        local event = msg["body"]
       local pItemInfo = BagCommonManager:getItemInfoByPosition(event["argsBody"].index)
        if pItemInfo.baseType ==kItemType.kEquip and #pItemInfo.equipment[1].stones >0  then --如果是装备且有宝石
            NoticeManager:getInstance():showSystemMessage("装备上的宝石已卸下存入背包内")
       end
        
        --BagCommonManager:getInstance():updateItemArry(msg["body"].itemList)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
       -- DialogManager:getInstance():closeDialogByName("MutlipeUseItemDialog") 
        DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
        
        local item = BagCommonManager:getItemInfoByPosition(event["argsBody"].index)
        -- 这个判断，目的卖光某个格子后，如果爆包补位，就不再先是选中特效
        if BagCommonManager:getInstance()._beSellOutPosition ~= event["argsBody"].index then
            NetRespManager:getInstance():dispatchEvent(kNetCmd.kBagSelectedCell, {cell = item}) 
        else
            BagCommonManager:getInstance():setSellOutPosition(-1)
            DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
        end
        
      if not BagCommonManager:getInstance():getItemInfoByIndex(event.argsBody.index) then --如果此物品卖完了就关闭版子
           DialogManager:getInstance():closeDialogByName("BagCallOutDialog") 
      end
    else
        print("返回错误码："..msg.header.result)
    end
end


--锻造装备
function EquipmentHandler:handleFoundryEquipment20131( msg )
 print("bagCommoneHandler 20131")
    if msg.header.result == 0 then
        local event = msg["body"]
        --BagCommonManager:getInstance():updateItemArry(event.itemList)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kForgingEquip,event)
       -- DialogManager:getInstance():showDialog("GetItemsDialog",{GetCompleteItemInfo(event.proItemList[1])})  
    else
        print("返回错误码："..msg.header.result)
        DialogManager:getInstance():getDialogByName("EquipmentDialog")._pEqFoundryInfoView._pFoundryButton:setTouchEnabled(true)
        DialogManager:getInstance():getDialogByName("EquipmentDialog"):setTouchEnableInDialog(false)
    end
end

function EquipmentHandler:handlesellChapEquipByAuto20137(msg)
    print("EquipmentHandler 20137")
    if msg.header.result == 0 then 
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, {})
    else
        print("返回错误码："..msg.header.result)
    end
end

return EquipmentHandler