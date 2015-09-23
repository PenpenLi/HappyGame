--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EqiupNewPanel.lua
-- author:    liyuhang
-- created:   2015/7/20
-- descrip:   新装备获得面板
--===================================================

local EqiupNewPanel = class("EqiupNewPanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function EqiupNewPanel:ctor()
    self._strName = "EqiupNewPanel"        -- 层名称
    
    self.params = nil
    self._pCurData = nil
    
    self._bShow = false
end

-- 创建函数
function EqiupNewPanel:create()
    local layer = EqiupNewPanel.new()
    layer:dispose()
    return layer
end

-- 处理函数
function EqiupNewPanel:dispose()
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kNewEquip,handler(self, self.handleNewEquip))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateBagItemList,handler(self, self.handleUpdateBagItemList))
    -- 加载资源
    ResPlistManager:getInstance():addSpriteFrames("EquipNowDiolog.plist")
    -- 加载dialog组件
    local params = require("EquipNowDiologParams"):create()
    self.params = params
    self._pCCS = params._pCCS
    self:addChild(self._pCCS)

    --整理按钮
    self._pOKButton = params._pOKButton
    --self._pTidyBtn:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pOKButton:setZoomScale(nButtonZoomScale)
    self._pOKButton:setPressedActionEnabled(true)
    self._pOKButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if RolesManager:getInstance()._pMainRoleInfo.level < self._pCurData.dataInfo.RequiredLevel then --等级不足
                NoticeManager:getInstance():showSystemMessage("角色等级不足")
            else    
                EquipmentCGMessage:sendMessageWareEquipment20106(self._pCurData.position)
            end
        
            if table.getn(BagCommonManager:getInstance()._tNewGetEquip) > 1 then
                table.remove(BagCommonManager:getInstance()._tNewGetEquip , 1)
                self._pCurData = BagCommonManager:getInstance()._tNewGetEquip[1]
                self:setEquipData(self._pCurData)
            elseif table.getn(BagCommonManager:getInstance()._tNewGetEquip) == 1 then
                table.remove(BagCommonManager:getInstance()._tNewGetEquip , 1)
                NetRespManager:dispatchEvent(kNetCmd.kNewEquipShow,{show = false})
                self._bShow = false
                self._pCurData = nil
            else 
                NetRespManager:dispatchEvent(kNetCmd.kNewEquipShow,{show = false})
                self._bShow = false
                self._pCurData = nil
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)
    
    self.params._pCloseButton:addTouchEventListener(function(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if table.getn(BagCommonManager:getInstance()._tNewGetEquip) > 1 then
                table.remove(BagCommonManager:getInstance()._tNewGetEquip , 1)
                self._pCurData = BagCommonManager:getInstance()._tNewGetEquip[1]
                self:setEquipData(self._pCurData)
            elseif table.getn(BagCommonManager:getInstance()._tNewGetEquip) == 1 then
                table.remove(BagCommonManager:getInstance()._tNewGetEquip , 1)
                NetRespManager:dispatchEvent(kNetCmd.kNewEquipShow,{show = false})
                self._bShow = false
                self._pCurData = nil
            else 
                NetRespManager:dispatchEvent(kNetCmd.kNewEquipShow,{show = false})
                self._bShow = false
                self._pCurData = nil
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEqiupNewPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- 忽略此次，直接进入下一个
function EqiupNewPanel:refreshData()
    if table.getn(BagCommonManager:getInstance()._tNewGetEquip) > 1 then
        table.remove(BagCommonManager:getInstance()._tNewGetEquip , 1)
        self._pCurData = BagCommonManager:getInstance()._tNewGetEquip[1]
        self:setEquipData(self._pCurData)
    elseif table.getn(BagCommonManager:getInstance()._tNewGetEquip) == 1 then
        table.remove(BagCommonManager:getInstance()._tNewGetEquip , 1)
        NetRespManager:dispatchEvent(kNetCmd.kNewEquipShow,{show = false})
        self._bShow = false
        self._pCurData = nil
    else 
        NetRespManager:dispatchEvent(kNetCmd.kNewEquipShow,{show = false})
        self._bShow = false
        self._pCurData = nil
    end
end

-- 设置数据
function EqiupNewPanel:setEquipData(data)
	self.params._pEquipIcon:loadTexture( data.templeteInfo.Icon .. ".png",ccui.TextureResType.plistType)
    self.params._pPwoerText:setString(data.equipment[1].fightingPower)
    
    if data.dataInfo.Quality ~= nil and data.dataInfo.Quality ~= 0 then
        self.params._pEqiupIconPz:loadTexture("ccsComRes/qual_" ..data.dataInfo.Quality.."_normal.png",ccui.TextureResType.plistType)
        self.params._pEqiupIconPz:setVisible(true)
    end
end

-- 新装备提示处理
function EqiupNewPanel:handleNewEquip(event)
    if BagCommonManager:getInstance()._tNewGetEquip == nil then
        return
    end

    if table.getn(BagCommonManager:getInstance()._tNewGetEquip) ~= 0 then
        self._pCurData = BagCommonManager:getInstance()._tNewGetEquip[1]
        self:setEquipData(self._pCurData)
        --table.remove(BagCommonManager:getInstance()._tNewGetEquip , 1)
        NetRespManager:dispatchEvent(kNetCmd.kNewEquipShow,{show = true})
        self._bShow = true
	end
end

-- 更新背包
function EqiupNewPanel:handleUpdateBagItemList(event)
    if self._bShow == true and self._pCurData ~= nil then
		-- 根据position遍历一次找到
		local beExist = false
        for i=1,table.getn(BagCommonManager:getInstance()._pItemArry) do
            if self._pCurData.position == BagCommonManager:getInstance()._pItemArry[i].position then
                beExist = true
                if  BagCommonManager:getInstance()._pItemArry[i].baseType == self._pCurData.baseType and
                    BagCommonManager:getInstance()._pItemArry[i].id == self._pCurData.id and
                    BagCommonManager:getInstance()._pItemArry[i].value == self._pCurData.value and 
                    BagCommonManager:getInstance()._pItemArry[i].position == self._pCurData.position and 
                    self._pCurData.equipment[1].fightingPower == BagCommonManager:getInstance()._pItemArry[i].equipment[1].fightingPower then
                else
                    self:refreshData()
                    break
                end
			end
		end
		
        if beExist == false then
            self:refreshData()
		end
	end
end

-- 退出函数
function EqiupNewPanel:onExitEqiupNewPanel()
    -- release合图资源
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("EquipNowDiolog.plist")
end

return EqiupNewPanel