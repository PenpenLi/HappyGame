--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  PlayerDetailInfoPanel.lua
-- author:    liyuhang
-- created:   2014/12/16
-- descrip:   角色详细属性控件
--===================================================

local PlayerDetailInfoPanel = class("PlayerDetailInfoPanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function PlayerDetailInfoPanel:ctor()
    self._strName = "PlayerDetailInfoPanel"        -- 层名称
   
    self._pHpLbl = nil           --生命
    self._pDefendLbl = nil       --防御
    self._pResilienceLbl = nil   --韧性
    self._pBlockLbl = nil
    self._pDodgeRateLbl = nil
    self._pResistanceLbl = nil
    self._pLifePerSecondLbl = nil
    self._pLifeStealLbl = nil   

    self._pAttackLbl = nil       --攻击力
    self._pPenetrationLbl = nil
    self._pCritDmageLbl = nil
    self._pCritRateLbl = nil
    self._pAttrEnhancedLbl = nil
    self._pFireAttackLbl = nil
    self._pLightningAttackLbl = nil
    self._pColdAttackLbl = nil

    -- pvper属性
    self._pPvperAttrInfo = nil 
    self._isPvper = false
end 

-- 创建函数
function PlayerDetailInfoPanel:create(args)
    local layer = PlayerDetailInfoPanel.new()
    layer:dispose(args)
    return layer
end

-- 处理函数
function PlayerDetailInfoPanel:dispose(args)
    self._pPvperAttrInfo = args[1]
    self._isPvper = args[2]
    if self._isPvper == false then
        -- 注册网络回调事件
        NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateRoleInfo ,handler(self, self.updateRoleInfo))
    end

    -- 加载资源
    ResPlistManager:getInstance():addSpriteFrames("PlayerInfPanel.plist")
    -- 加载dialog组件
    local params = require("PlayerInfPanelParams"):create()
    self._pCCS = params._pCCS

    self._pHpLbl = params._pNum1           --生命
    self._pDefendLbl = params._pNum2       --防御
    self._pResilienceLbl = params._pNum3   --韧性
    self._pBlockLbl = params._pNum4
    self._pDodgeRateLbl = params._pNum5
    self._pResistanceLbl = params._pNum6
    self._pLifePerSecondLbl = params._pNum7
    self._pLifeStealLbl = params._pNum8   

    self._pAttackLbl = params._pNum9       --攻击力
    self._pPenetrationLbl = params._pNum10
    self._pCritRateLbl = params._pNum11
    self._pCritDmageLbl = params._pNum12
    self._pAttrEnhancedLbl = params._pNum13
    self._pFireAttackLbl = params._pNum14
    self._pColdAttackLbl = params._pNum15
    self._pLightningAttackLbl = params._pNum16
    self._pDefText = params._pDefText 
    self._pAtaText  = params._pAtaText 
    self:addChild(self._pCCS)
    
    --self._pDefText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pDefText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    --self._pAtaText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pAtaText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

    self:updateRoleInfo()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitPlayerDetailInfoPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function PlayerDetailInfoPanel:updateRoleInfo()

    if self._isPvper == true and self._pPvperAttrInfo == nil then
        return
    end
	local roleInfo = nil 
    if not self._pPvperAttrInfo then
       roleInfo = RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo
    else
        roleInfo = self._pPvperAttrInfo
    end

    --self._pHpLbl:setString(roleInfo.hp)
    self._pHpLbl:setString(roleInfo.hp)
    self._pDefendLbl:setString(roleInfo.defend)
    self._pResilienceLbl:setString(roleInfo.resilience)
    self._pBlockLbl:setString(roleInfo.block)
    self._pDodgeRateLbl:setString(roleInfo.dodgeRate)
    self._pResistanceLbl:setString(roleInfo.resistance)
    self._pLifePerSecondLbl:setString(roleInfo.lifePerSecond)
    self._pLifeStealLbl:setString(roleInfo.lifeSteal)

    self._pAttackLbl:setString(roleInfo.attack)
    self._pPenetrationLbl:setString(roleInfo.penetration)
    self._pCritDmageLbl:setString(roleInfo.critDmage)
    self._pCritRateLbl:setString(roleInfo.critRate)
    self._pAttrEnhancedLbl:setString(roleInfo.attrEnhanced)
    self._pFireAttackLbl:setString(roleInfo.fireAttack)
    self._pLightningAttackLbl:setString(roleInfo.lightningAttack)
    self._pColdAttackLbl:setString(roleInfo.coldAttack)
end

-- 退出函数
function PlayerDetailInfoPanel:onExitPlayerDetailInfoPanel()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    -- release合图资源  
    ResPlistManager:getInstance():removeSpriteFrames("PlayerInfPanel.plist")
end

-- 循环更新
function PlayerDetailInfoPanel:update(dt)
    return
end

-- 显示结束时的回调
function PlayerDetailInfoPanel:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function PlayerDetailInfoPanel:doWhenCloseOver()
    return
end

-- 设置pvper 属性信息
function PlayerDetailInfoPanel:setDataSource(attrInfo)
    self._pPvperAttrInfo = attrInfo
    self:updateRoleInfo()
end

return PlayerDetailInfoPanel
