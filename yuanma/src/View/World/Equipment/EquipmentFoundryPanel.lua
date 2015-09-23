--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EquipmentFoundryPanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/10
-- descrip:   装备锻造界面
--===================================================

local EquipmentFoundryPanel = class("EquipmentFoundryPanel",function()
    return require("BasePanel"):create()
end)

-- 构造函数
function EquipmentFoundryPanel:ctor()
    self._strName = "EquipmentFoundryPanel" -- 层名称
    self._pCCS  = nil
    self._pFoundryBg  = nil                  --背景
    self._pParticleNode = nil                --中心图片挂在Node
    self._pEqiupPiecesIcon = nil             --碎片图标
    self._pPiecesLv = nil                    --碎片的等级
    self._pOwnPiecesNum = nil                --拥有碎片的数量
    self._pNeedPiecesNum = nil               --需要的碎片数量
    self._pEquipTreeIcon = nil               --图谱图标
    self._pOwnEquipTreeNum = nil             --拥有图谱数量
    self._pNeedEquipTreeNum = nil            --拥有图谱数量
    self._pEqiupMentIcon = nil               --合成的装备图标
    self._pEqiupMentLv = nil                 --合成的装备等级
    self._pDesBg = nil                       --合成装备信息的背景
    self._pEquipName = nil                   --装备名称文字
    self._pPartName = nil                    --装备部位文字
    self._pLvName = nil                      --装备等级文字
    self._pMainFightPower = nil              --装备战斗力最小值
    self._pMaxFightPower = nil               --装备战斗力最大值
    self._pMoneyNum = nil                    --锻造消耗金钱值
    self._pFoundryButton = nil               --锻造按钮
    self._pNotFoundryShowImage = nil         --没有锻造装备的显示

    self._pPiecesDate = nil                  --碎片的信息
    self._pEquipTreeDate =  nil              --图谱的信息
    self._pFoundryDate = nil                 --要锻造的装备信息
    self.touchLayerFunc = nil                --屏蔽层

end

-- 创建函数
function EquipmentFoundryPanel:create(func)
    local layer = EquipmentFoundryPanel.new()
    layer:dispose(func)
    return layer
end

-- 处理函数
function EquipmentFoundryPanel:dispose(func)
    -- 注册网络回调事件
    -- NetRespManager:getInstance():addEventListener(kNetCmd.kForgingEquip ,handler(self, self.RespBagEquipmentDate)) --强化装备tip
    ResPlistManager:getInstance():addSpriteFrames("EquipmentFoundryPanel.plist")
    local params = require("EquipmentFoundryPanelParams"):create()
    self._pCCS = params._pCCS
    self._pFoundryBg  = params._pFoundryBg                      --背景
    self._pParticleNode = params._pParticleNode                 --中心图片挂在Node
    self._pPiecesName = params._pPathName                       --碎片名字
    self._pEqiupPiecesIcon = params._pPiecesEqiupIconQuality    --碎片图标
    self._pPiecesIconQuality = params._pPiecesEqiupIcon         --碎片品质
    self._pPiecesLv = params._pPiecesLevel                      --碎片的等级
    self._pOwnPiecesNum =  params._pPiecesNum1                  --拥有碎片的数量
    self._pNeedPiecesNum =  params._pPiecesNum2                 --需要的碎片数量
    self._pEquipTreeName = params._pPicsName                    --图谱的名字
    self._pEquipTreeIcon =  params._pPicsIconQuality            --图谱图标
    self._pTreeIconQuality = params._pPicsIcon                  --图谱品质图
    self._pOwnEquipTreeNum = params._pPicsNum1                  --拥有图谱数量
    self._pNeedEquipTreeNum = params._pPicsNum2                 --拥有图谱数量
    self._pEqiupMentIcon = params._pEqiupMentIconQuality        --合成的装备图标
    self._pMentIconQuality = params._pEqiupMentIcon             --图谱品质图
    self._pEqiupMentLv = params._pEqiupMentLv                   --合成的装备等级
    self._pDesBg = params._pDesBg                               --合成装备信息的背景
    self._pEquipName = params._pEquipName                       --装备名称文字
    self._pPartName = params._pPosName                          --装备部位文字
    self._pLvName = params._pLvName                             --装备等级文字
    self._pMainFightPower = params._pFightNum1                  --装备战斗力最小值
    self._pMaxFightPower = params._pFightNum2                   --装备战斗力最大值
    self._pMoneyNum = params._pMoneyNum                         --锻造消耗金钱值
    self._pFoundryButton = params._pFoundryButton               --锻造按钮
    self._pNotFoundryShowImage = params._pWeiFangText             --没有锻造装备的显示
    self:addChild(self._pCCS)
    self._fEquCallback = func
    --[[
    --添加一个动画层
    self._pNoTouchLayer = require("NoTouchLayer"):create()
    self:addChild(self._pNoTouchLayer,kZorder.kLayer)
    ]]
    self:clearResolveUiDateInfo()      --清理数据
    self:initEquipmentFoundryUi()      --初始化数据
    
    --增加字体描边
    
    --self._pPiecesName:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._pPiecesLv:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pOwnPiecesNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pNeedPiecesNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pEquipTreeName:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._pOwnEquipTreeNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pNeedEquipTreeNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pEqiupMentLv:enableOutline(cc.c4b(0, 0, 0, 255), 2)
   --[[
    self._pEquipName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._pPartName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._pLvName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._pMainFightPower:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self._pMaxFightPower:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    ]]
    --self._pMoneyNum:enableOutline(cc.c4b(0, 0, 0, 255), 1)
   -- self._pPiecesName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pPiecesName:enableOutline(cc.c4b(0, 0, 0, 255), 2)


    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEquipmentFoundryPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--初始化数据
function EquipmentFoundryPanel:initEquipmentFoundryUi()

    local foundryButtonCallBack = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
    
            if self._pPiecesDate == nil and self._pEquipTreeDate == nil  then
               NoticeManager:getInstance():showSystemMessage("请放入材料")
               return 
            end
            if self._pPiecesDate == nil then
                NoticeManager:getInstance():showSystemMessage("请放入碎片")
                return 
            end
            if self._pEquipTreeDate == nil then
                NoticeManager:getInstance():showSystemMessage("请放入图谱")
                return 
            end
            if BagCommonManager:getInstance():isBagItemsEnough() then
                NoticeManager:getInstance():showSystemMessage("背包已满")
                return 
            end
           
            if self._pFoundryDate ~= nil then
               local nOwnCoin = FinanceManager:getInstance():getValueByFinanceType(kFinance.kCoin)
                local nNeedCoin = self._pFoundryDate.dataInfo.FoundryPrice
                if nOwnCoin < nNeedCoin then
                    NoticeManager:getInstance():showSystemMessage("金币不足")
                    return 
                end
               
            end
            self._pFoundryButton:setTouchEnabled(false)
            
            if self._pFoundryDate and self._pPiecesDate and self._pEquipTreeDate then
                EquipmentCGMessage:sendMessageFoundryEquipment20130(self._pPiecesDate.id,self._pEquipTreeDate.id)
                self.touchLayerFunc(true)
                -- DialogManager:getInstance():showDialog("GetItemsDialog",{self._pFoundryDate})
            end
            --self._pFoundryButton:setTouchEnabled(true)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end


    self._pFoundryButton:addTouchEventListener(foundryButtonCallBack)    --一键强化回调
    --self._pFoundryButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pFoundryButton:setZoomScale(nButtonZoomScale)
    self._pFoundryButton:setPressedActionEnabled(true)

end

--更新数据
function EquipmentFoundryPanel:updateEquipmentFoundryUi()
    local pOwnPiecesNum = 0       --拥有的碎片数量
    local pOwnEquTreeDate = 0     --拥有的图谱数量

    
    local onImageViewClicked = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender:getTag() == 1 then --碎片
                self._pPiecesIconQuality:setVisible(false)
                self._pPiecesDate = nil
                
           	else
                self._pTreeIconQuality:setVisible(false)
                self._pEquipTreeDate = nil
            end
            self._pFoundryDate = nil
            self:updateEquipmentFoundryUi()
            self._fEquCallback({ self._pEquipTreeDate, self._pPiecesDate})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    if self._pPiecesDate then   --碎片的信息
        pOwnPiecesNum = BagCommonManager:getInstance():getItemNumById(self._pPiecesDate.id)
        self._pPiecesIconQuality:setVisible(true)
        self._pEqiupPiecesIcon:loadTexture(self._pPiecesDate.templeteInfo.Icon ..".png",ccui.TextureResType.plistType)
         self._pEqiupPiecesIcon:setTag(1)
        self._pEqiupPiecesIcon:addTouchEventListener(onImageViewClicked)
        self._pPiecesLv:setString("Lv"..self._pPiecesDate.dataInfo.RequiredLevel)
        self._pPiecesName:setString(self._pPiecesDate.templeteInfo.Name)
        local nQuality = self._pPiecesDate.dataInfo.Quality
        if nQuality ~= 0 then
            self._pPiecesIconQuality:loadTexture("ccsComRes/qual_" ..nQuality.."_normal.png",ccui.TextureResType.plistType)
        end
        
    end

    if self._pEquipTreeDate then      --图谱的信息
        self._pTreeIconQuality:setVisible(true)
        pOwnEquTreeDate = BagCommonManager:getInstance():getItemNumById(self._pEquipTreeDate.id)
        self._pEquipTreeIcon:loadTexture(self._pEquipTreeDate.templeteInfo.Icon ..".png",ccui.TextureResType.plistType)
        self._pEquipTreeIcon:setTag(2)
        self._pEquipTreeIcon:addTouchEventListener(onImageViewClicked)
        self._pEquipTreeName:setString(self._pEquipTreeDate.templeteInfo.Name)
        local nQuality = self._pEquipTreeDate.dataInfo.Quality
        if nQuality ~= 0 then
            self._pTreeIconQuality:loadTexture("ccsComRes/qual_" ..nQuality.."_normal.png",ccui.TextureResType.plistType)

        end

    end

    if self._pFoundryDate then  --要锻造的装备信息
        self._pMentIconQuality:setVisible(true)
        self._pEqiupMentIcon:loadTexture(self._pFoundryDate.templeteInfo.Icon ..".png",ccui.TextureResType.plistType)
        self._pEqiupMentLv:setString("Lv"..self._pFoundryDate.dataInfo.RequiredLevel)
        local nEquipQuality = self._pFoundryDate.dataInfo.Quality
        self._pMentIconQuality:loadTexture("ccsComRes/qual_" ..nEquipQuality.."_normal.png",ccui.TextureResType.plistType)


        --拥有的碎片数量 需要的碎片数量
        self._pOwnPiecesNum:setString(pOwnPiecesNum)
        self._pOwnPiecesNum:setColor((pOwnPiecesNum >= self._pFoundryDate.dataInfo.EquipPieces)and cWhite or cRed)
        self._pNeedPiecesNum:setString("/"..self._pFoundryDate.dataInfo.EquipPieces)

        --拥有的图谱数量 需要的图谱数量
        self._pOwnEquipTreeNum:setString(pOwnEquTreeDate)
        self._pOwnEquipTreeNum:setColor((pOwnEquTreeDate >= self._pFoundryDate.dataInfo.EquipTree)and cWhite or cRed)
        self._pNeedEquipTreeNum:setString("/"..self._pFoundryDate.dataInfo.EquipTree)

        --装备的名字 部位 等级 最小战力 最大战力 消耗的金钱
        self._pEquipName:setString(self._pFoundryDate.templeteInfo.Name)
        self._pPartName:setString(kEquipPositionTypeTitle[self._pFoundryDate.dataInfo.Part])
        self._pLvName:setString(self._pFoundryDate.dataInfo.RequiredLevel)
        self._pMainFightPower:setString(self._pFoundryDate.dataInfo.FightingMin)
        self._pMaxFightPower:setString(self._pFoundryDate.dataInfo.FightingMax)
        
       
        local pCostGodRes = self._pFoundryDate.dataInfo.FoundryPrice
        local pCurGodRes = FinanceManager:getInstance()._tCurrency[kFinance.kCoin]
        self._pMoneyNum:setString(pCostGodRes)
        self._pMoneyNum:setColor((pCostGodRes <= pCurGodRes) and cWhite or cRed)
        
        --有锻造的装备中心图片显示
        self._pParticleNode:setVisible(true)
        self._pMoneyNum:setVisible(true)
        self._pDesBg:setVisible(true)
        self._pNotFoundryShowImage:setVisible(false)
        
    else  --如果没有合成的装备 条件不符合
        self._pMentIconQuality:setVisible(false)
        --拥有的碎片数量 需要的碎片数量 拥有的图谱数量 需要的图谱数量
        self._pOwnPiecesNum:setString("")
        self._pNeedPiecesNum:setString("")
        self._pOwnEquipTreeNum:setString("")
        self._pNeedEquipTreeNum:setString("")
        self._pDesBg:setVisible(false)
        self._pEquipName:setString("")                  --装备名称文字
        self._pPartName:setString("")                   --装备部位文字
        self._pLvName:setString("")                     --装备等级文字
        self._pMainFightPower:setString("")             --装备战斗力最小值
        self._pMaxFightPower:setString("")              --装备战斗力最大值
        self._pMoneyNum:setString("0")                   --锻造消耗金钱值
        --有锻造的装备中心图片显示
        self._pParticleNode:setVisible(false)
        self._pNotFoundryShowImage:setVisible(true)

    end

end

--默认传入的装备信息
function EquipmentFoundryPanel:setDataSource(pItemDate,nSmallType)
    self:SetRightScrollViewClickByIndex(pItemDate,nSmallType)
end

--回调函数
function EquipmentFoundryPanel:SetRightScrollViewClickByIndex(pItemInfo ,nSmallType)
    if pItemInfo then
        if pItemInfo.dataInfo.UseType == kItemUseType.kEquipPieces then
            self._pPiecesDate = pItemInfo
        elseif pItemInfo.dataInfo.UseType == kItemUseType.kEquipTree then
            self._pEquipTreeDate = pItemInfo
        end
    end
    self._fEquCallback({ self._pEquipTreeDate, self._pPiecesDate})
    --取出是否有可合成的装备
    if self._pPiecesDate and self._pEquipTreeDate then
        local FoundryId = nil
        local pPiecDate = self._pPiecesDate.dataInfo.Property.AssembleID
        local pTreeDate = self._pEquipTreeDate.dataInfo.Property.AssembleID

        for k,v1 in pairs(pPiecDate) do
            for j,v2 in pairs(pTreeDate) do
                if v1 == v2 then
                    FoundryId = v1
                    break
                end
            end
        end
        if FoundryId then --如果有合成的装备
            self._pFoundryDate = GetCompleteItemInfo({baseType = kItemType.kEquip, id = FoundryId })
        else
            self._pFoundryDate = nil
        end

    end
    self:updateEquipmentFoundryUi() --更新数据

end

--清空页面数据
function EquipmentFoundryPanel:clearResolveUiDateInfo()

    self._pPiecesIconQuality:setVisible(false)
    self._pTreeIconQuality:setVisible(false)
    self._pMentIconQuality:setVisible(false)
    self._pDesBg:setVisible(false)
    self._pEquipName:setString("")                  --装备名称文字
    self._pPartName:setString("")                   --装备部位文字
    self._pLvName:setString("")                     --装备等级文字
    self._pMainFightPower:setString("")             --装备战斗力最小值
    self._pMaxFightPower:setString("")              --装备战斗力最大值
    self._pMoneyNum:setString("0")                  --锻造消耗金钱值
    self._pPiecesDate = nil                         --碎片的信息
    self._pEquipTreeDate =  nil                     --图谱的信息
    self._pFoundryDate = nil                        --要锻造的装备信息
    --有锻造的装备中心图片显示
    self._pParticleNode:setVisible(false)
    self._pNotFoundryShowImage:setVisible(true)

end

--点击屏蔽层
function EquipmentFoundryPanel:setTouchLayerEnabled(func)
    self.touchLayerFunc = func
end

--得到当前界面强化的info
function EquipmentFoundryPanel:getItemInfo()
    local tLocalDate = {}
    if self._pPiecesDate then
        table.insert(tLocalDate,self._pPiecesDate)
    end
    if self._pEquipTreeDate then
        table.insert(tLocalDate,self._pEquipTreeDate)
    end
 
    return tLocalDate
end

-- 退出函数
function EquipmentFoundryPanel:onExitEquipmentFoundryPanel()
    -- release合图资源
    ResPlistManager:getInstance():removeSpriteFrames("EquipmentFoundryPanel.plist")
    --NetRespManager:getInstance():removeEventListenersByHost(self)
end


return EquipmentFoundryPanel
