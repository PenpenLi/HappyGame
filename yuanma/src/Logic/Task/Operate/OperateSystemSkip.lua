--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OperateSystemSkip.lua
-- author:    liyuhang
-- created:   2015/5/11
-- descrip:   显示系统跳转界面操作（用于任务中的操作队列）
--===================================================
local OperateSystemSkip = class("OperateSystemSkip", function()
    return require("Operate"):create()
end)

-- 构造函数
function OperateSystemSkip:ctor()
    self._strName = "OperateSystemSkip"       -- 操作名称
    self._kSystemSkip = kEventType.kNone      -- 事件类型
    self._pParams = nil                       -- 要跳转到的战斗关卡参数信息

end

-- 创建函数
function OperateSystemSkip:create(args)
    local op = OperateSystemSkip.new()
    op:dispose(args)
    return op
end

-- 初始化处理
function OperateSystemSkip:dispose(args)
    self._kSystemSkip = args.sysType
    self._pParams = args.params
end

-- 开始
function OperateSystemSkip:onEnter()
    self:onBaseEnter()

    if self._kSystemSkip == kEventType.kCopy then  --// 打副本
    
    elseif self._kSystemSkip == kEventType.kArena then  --// 竞技场挑战
        ArenaCGMessage:queryArenaInfoReq21600()
    elseif self._kSystemSkip == kEventType.kResolve then  -- 分解
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeResolve,nil})
    elseif self._kSystemSkip == kEventType.kSynthesis then -- 合成
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeGemCompound,nil})
    elseif self._kSystemSkip == kEventType.kInlay then  -- 镶嵌
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabGemTypeGemInlay,nil})
    elseif self._kSystemSkip == kEventType.kForging then -- 锻造
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeEquFoundry,nil})
    elseif self._kSystemSkip == kEventType.kUpFairyPill then -- 升级境界丹
        FairyLandCGMessage:sendMessageSelectFairyInfo20600()
    elseif self._kSystemSkip == kEventType.kUpFairyDish then   -- 升级境界盘
        FairyLandCGMessage:sendMessageSelectFairyInfo20600()
    elseif self._kSystemSkip == kEventType.kRefineBlade then  -- 炼化剑魂
        BladeSoulCGMessage:sendMessageSelectBladeSoulInfo20700()
    elseif self._kSystemSkip == kEventType.kDevourBlade then  --// 吞噬剑魂
        BladeSoulCGMessage:sendMessageSelectBladeSoulInfo20700()
        
        TasksManager:getInstance():setAutoBladesoulType(2)
    elseif self._kSystemSkip == kEventType.kAwakeBeauty then  --// 唤醒美人
        BeautyClubSystemCGMessage:queryBeautyInfoReq20800() 
    elseif self._kSystemSkip == kEventType.kUpBeauty then  --// 升级美人
        BeautyClubSystemCGMessage:queryBeautyInfoReq20800() 
    elseif self._kSystemSkip == kEventType.kKissBeauty then  --// 亲密美人
        BeautyClubSystemCGMessage:queryBeautyInfoReq20800() 
    elseif self._kSystemSkip == kEventType.kUpSkill then  --// 技能升级
        DialogManager:getInstance():showDialog("SkillDialog",{})
    elseif self._kSystemSkip == kEventType.kFeedPet then  --// 给宠物喂食(宠物升级)
        DialogManager:showDialog("PetDialog",{})
    elseif self._kSystemSkip == kEventType.kCompoundPet then  --// 合成宠物
        DialogManager:showDialog("PetDialog",{})
    elseif self._kSystemSkip == kEventType.kUpPet then  --// 升级宠物
        DialogManager:showDialog("PetDialog",{})
    elseif self._kSystemSkip == kEventType.kAdvancePet then  --// 给宠物升阶
        DialogManager:showDialog("PetDialog",{})
    elseif self._kSystemSkip == kEventType.kCharge then  --// 充值
    
    elseif self._kSystemSkip == kEventType.kCostDiamond then  --// 消耗钻石
        DialogManager:getInstance():showDialog("ShopDialog",{kShopType.kDiamondShop})
    elseif self._kSystemSkip == kEventType.kUpRoleLevel then  --// 升级
        DialogManager:getInstance():showDialog("StoryCopyDialog")
    elseif self._kSystemSkip == kEventType.kUseItem then  --// 使用道具
        DialogManager:getInstance():showDialog("RolesInfoDialog",{RoleDialogTabType.RoleDialogTypeBag})
    elseif self._kSystemSkip == kEventType.kCostStrength then  --// 消耗体力
        DialogManager:getInstance():showDialog("StoryCopyDialog")
    elseif self._kSystemSkip == kEventType.kInviteFriend then  --// 申请好友
        DialogManager:showDialog("FriendsDialog",{})
    elseif self._kSystemSkip == kEventType.kFriendCount then  --// 好友数量
        DialogManager:showDialog("FriendsDialog",{})
    elseif self._kSystemSkip == kEventType.kFightPower then  --// 战斗力
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeIntensify,nil})
    elseif self._kSystemSkip == kEventType.kIntensify then  --// 强化
        DialogManager:getInstance():showDialog("EquipmentDialog",{EquipmentTabType.EquipmentTabTypeIntensify,nil})
        
    elseif self._kSystemSkip == kEventType.kFriendShip then  --// 好友亲密度
        DialogManager:showDialog("FriendsDialog",{})
        
    elseif self._kSystemSkip == kEventType.kFriendGift then  --// 好友礼包
        DialogManager:showDialog("FriendsDialog",{})
        
    elseif self._kSystemSkip == kEventType.kEntryFamily then  --// 加入家族
        if  FamilyManager:getInstance()._bOwnFamily == true then --有家族
            DialogManager:getInstance():showDialog("FamilyDialog")
        else
            DialogManager:getInstance():showDialog("FamilyRegisterDialog")  
            FamilyCGMessage:queryFamilyListReq22300(0,8)
        end
        
    elseif self._kSystemSkip == kEventType.kFamilyDonate then  --// 家族捐献
        if  FamilyManager:getInstance()._bOwnFamily == true then --有家族
            DialogManager:getInstance():showDialog("FamilyDialog")
        else
            DialogManager:getInstance():showDialog("FamilyRegisterDialog")  
            FamilyCGMessage:queryFamilyListReq22300(0,8)
        end
        
    elseif self._kSystemSkip == kEventType.kFinishTypeTask then  --// 完成某类型任务N个
        DialogManager:getInstance():showDialog("TaskDialog",{false})
        
    elseif self._kSystemSkip == kEventType.kSaleWine then  --// 出售酒品
        DrunkeryCGMessage:openDrunkeryDialog22100()
        
    elseif self._kSystemSkip == kEventType.kBuyWine then  --// 购买酒品
        DrunkeryCGMessage:openDrunkeryDialog22100()
    end

    if self._pParams == nil then
        self._bIsOver = true    -- 结束
    end

    return
end

-- 结束
function OperateSystemSkip:onExit()
    self:onBaseExit()

    return
end

-- 循环更新
function OperateSystemSkip:onUpdate(dt)
    self:onBaseUpdate(dt)

    

    return
end

-- 复位
function OperateSystemSkip:reset()
    self:baseReset()

    return
end

-- 检测结束标记
function OperateSystemSkip:checkOver(dt)
    if self._bIsOver == true then
        self:onExit()
    end
    return
end

return OperateSystemSkip
