--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EquipmentIntensifyPanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/13
-- descrip:   装备强化界面
--===================================================

local EquipmentIntensifyPanel = class("EquipmentIntensifyPanel",function()
    return require("BasePanel"):create()
end)

-- 构造函数
function EquipmentIntensifyPanel:ctor()
    self._strName = "EquipmentIntensifyPanel" -- 层名称
    self._pCCS  = nil
    self._pIntensifyEquBg = nil               --背景框
    self._pEqiupCellBg = nil                 --要强化的cell背景
    self._pStartlevel = nil                   --开始强化等级
    self._pNextlevel = nil                    --强化后等级
    self._pChangeRes = nil                    --变化后的金钱
    self._pMountNode = nil                    --挂载的node
    self._pEquMaxIcon = nil                   --满级的图片显示
    self._pAutoIntensifyButton = nil          --一键强化
    self._pNomalIntensifyButton = nil         --普通强化
    self._tAllIntensifyMaterialArray = {}     --强化材料的cell
    self._pIntensifyEquInfo = nil             --要强化的装备信息
    self._pIntensifyEquCell = nil             --要强化的装备cell
    self._nSmallType = nil                    --要强化的装备的小type
    self._tTempOwnMetaNum = {}                --默认是0
    self._bHasTempDate = false                --是否是本地算数据
    --self._pIntensifyAniNode = nil             --动画的node
    --self._pIntensifyAniAction =nil            --动画对应的action
    self._pIntensifyAni = nil                 --帧动画
    self._pAniCount = 0                       --强化动画播放的总次数
    self._pAniHasPlayNum = 0                  --强化动画播放的次数 本地做记录缓存
    self._tReqEvent = nil                     --强化回复表
    self.touchLayerFunc = nil
    self._pScheduler = nil

end

-- 创建函数
function EquipmentIntensifyPanel:create(func)
    local layer = EquipmentIntensifyPanel.new()
    layer:dispose(func)
    return layer
end


--播放强化的动画
function EquipmentIntensifyPanel:playAni()
    local actionOverCallBack = function()
        if self._nSmallType ==  kCalloutSrcType.kCalloutSrcEquip then --身上装备的强化
           NoticeManager:getInstance():showFightStrengthChange(self._tReqEvent.UpHistory[self._pAniHasPlayNum],self._tReqEvent.fightingHistory[self._pAniHasPlayNum])
        end
        self._pIntensifyEquInfo.value = self._pIntensifyEquInfo.value+1
        self:updateInstensifyDate()
        if self._pAniCount ==  self._pAniHasPlayNum then --最后一次播放了
        if self._pScheduler then 
           cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pScheduler)
           self._pScheduler = nil     
        end
           
            self._bHasTempDate = false
            self.touchLayerFunc(false)
           
            self:updateEquipmentDateByEvent(self._tReqEvent)
        end
    end
    if not self._pIntensifyAni then

        self._pIntensifyAni = cc.CSLoader:createNode("strequipEffect.csb")
        local x,y = self._pIntensifyEquCell:getPosition()
        self._pIntensifyAni:setPosition(cc.p(x+50,y+50) )
        self._pEqiupCellBg:addChild( self._pIntensifyAni,2)
   

    end
    local pIntensifyAniAction = cc.CSLoader:createTimeline("strequipEffect.csb")
    self._pIntensifyAni:stopAllActions()
    pIntensifyAniAction:gotoFrameAndPlay(0,pIntensifyAniAction:getDuration(), false)
    self._pIntensifyAni:runAction(pIntensifyAniAction)

    self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(actionOverCallBack)))

end


--装备强化[回复]
function EquipmentIntensifyPanel:RespBagEquipmentDate(event)
    self._tReqEvent = event
    if self._nSmallType ==  kCalloutSrcType.kCalloutSrcBagCommon then --背包装备的强化
        self._pAniCount = #event.equipHistory
    elseif self._nSmallType ==  kCalloutSrcType.kCalloutSrcEquip then --身上装备的强化
        self._pAniCount =  #event.fightingHistory

        local tTempFightTable = {}
        for i=1,self._pAniCount do
            if i==1 then
                table.insert(tTempFightTable,event.fightingHistory[i]-RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower)
            else
                table.insert(tTempFightTable,event.fightingHistory[i]-event.fightingHistory[i-1])
            end
        end
        event.UpHistory = tTempFightTable

    end

    self._bHasTempDate = true

    --先播放一次
    self._pAniHasPlayNum = self._pAniHasPlayNum+1
    self:playAni()
    local timeUpdate = function (dt)
        self._pAniHasPlayNum = self._pAniHasPlayNum+1
        self:playAni()
    end
     if self._pAniCount > self._pAniHasPlayNum then 
        self._pScheduler =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(timeUpdate,2,false)
     end


  
end

--动画播放完毕之后刷新本地数据

function EquipmentIntensifyPanel:updateEquipmentDateByEvent(event)
    self._tTempOwnMetaNum = {}
    self._pAniCount = 0
    self._pAniHasPlayNum = 0
    self:setIntenBeforeItemList()
    if self._nSmallType ==  kCalloutSrcType.kCalloutSrcBagCommon then --背包装备的强化
        self._pIntensifyEquInfo = BagCommonManager:getInstance():getItemInfoByIndex(self._pIntensifyEquInfo.position,BagTabType.BagTabTypeAll)
    elseif self._nSmallType ==  kCalloutSrcType.kCalloutSrcEquip then --身上装备的强化
        RolesManager:getInstance():setMainRole(event.roleInfo)  --先更新人物的属性
        --BagCommonManager:getInstance():updateItemArry(event.itemList)
        --NetRespManager:getInstance():dispatchEvent(kNetCmd.kUpdateBagItemList, nil)
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kWareEquipment,event)
        self._pIntensifyEquInfo =  RolesManager:getInstance():selectHasEquipmentByType(self._pIntensifyEquInfo.dataInfo.Part)
    end
    self:updateInstensifyDate() --从新与服务器数据同步，防止本地篡改数据
    self._fEquCallback()


end

-- 处理函数
function EquipmentIntensifyPanel:dispose(func)
    -- 注册网络回调事件
    NetRespManager:getInstance():addEventListener(kNetCmd.kIntensifyyBagEquipment ,handler(self, self.RespBagEquipmentDate))  --强化装备tip
    NetRespManager:getInstance():addEventListener(kNetCmd.kIntensifyyRoleEquipment ,handler(self, self.RespBagEquipmentDate)) --强化装备tip

    ResPlistManager:getInstance():addSpriteFrames("EquipmentIntensifyPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("strequipEffect.plist")

    local params = require("EquipmentIntensifyParams"):create()
    self._pCCS = params._pCCS
    self._pIntensifyEquBg = params._pStrengthenEquipBg                --背景框
    self._pEqiupCellBg = params._pEqiupFrame02                        --要强化的装备背景框
    self._pStartlevel =  params._pStrengthenLvText1                   --开始强化等级
    self._pNextlevel =  params._pStrengthenLvText2                    --强化后等级
    self._pStartAttribute = params._pAttributeText1                   --强化前的属性
    self._pNextAttribute = params._pAttributeText2                    --强化后的属性
    self._pChangeRes =  params._pMoneyNumText                         --变化后的金钱
    self._pMountNode = params._pMountNode                             --挂载的node
    self._pEquMaxIcon = params._pEquMaxIcon                           --满级的显示提示
    self._pAutoIntensifyButton = params._pStrengthenButton2           --一键强化
    self._pNomalIntensifyButton = params._pStrengthenButton1          --普通强化
    self:addChild(self._pCCS)

    self._tAllIntensifyMaterialArray = {params._pStrengMateria1, params._pStrengMateria2, params._pStrengMateria3}
    self._fEquCallback = func

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEquipmentIntensifyPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--初始化界面ui
function EquipmentIntensifyPanel:initIntensifyUi()

    --初始化3个材料的位置
    local nViewSize = self._pEqiupCellBg:getContentSize()
    local nSize = 100

    --强化的装备cell
    self._pIntensifyEquCell =  require("BagItemCell"):create()
    self._pIntensifyEquCell:setTouchEnabled(false)
    self._pIntensifyEquCell:setPosition(cc.p(nViewSize.width/2-nSize/2-8,nViewSize.height/2-55))
    self._pEqiupCellBg:addChild(self._pIntensifyEquCell)

    --材料的cell
    for i=1 ,#self._tAllIntensifyMaterialArray do
        local pSprite = ccui.ImageView:create() --材料
        pSprite:setName("MaterialSpreite")
        pSprite:setContentSize(cc.size(nSize,nSize))
        pSprite:setPosition(nSize/2,nSize/2)
        self._tAllIntensifyMaterialArray[i]:addChild(pSprite)

        local pOwnMateNum = cc.Label:createWithTTF("", strCommonFontName, 19)
        pOwnMateNum:setName("OwnMateNum")
        pOwnMateNum:setString("")
        pOwnMateNum:setAdditionalKerning(-3)
        pOwnMateNum:setColor(cWhite)
        pOwnMateNum:setPosition(cc.p(60,5))
        --pOwnMateNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        --pOwnMateNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        pOwnMateNum:setAnchorPoint(1,0)
        pSprite:addChild(pOwnMateNum)

        local pNeedMateNum = cc.Label:createWithTTF("", strCommonFontName, 19)
        pNeedMateNum:setName("NeedMateNum")
        pNeedMateNum:setAdditionalKerning(-3)
        pNeedMateNum:setString("")
        pNeedMateNum:setTextColor(cc.c4b(255, 255, 255, 255))
        pNeedMateNum:setPosition(cc.p(57,5))
        --pNeedMateNum:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        -- pNeedMateNum:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        pNeedMateNum:setAnchorPoint(0,0)
        pSprite:addChild(pNeedMateNum)

    end

    --强化回调
    local intensifyButtonCallBack = function (sender, eventType)

        if eventType == ccui.TouchEventType.ended then
            if not self._pIntensifyEquInfo then
                NoticeManager:getInstance():showSystemMessage("请放入要强化的装备")
                return
            end

            if self._pIntensifyEquInfo.value == TableConstants.EquipMaxLevel.Value then --如果是强化等级10级的
                NoticeManager:getInstance():showSystemMessage("强化已满")
                return
            end

            local nCoin = FinanceManager:getInstance()._tCurrency[kFinance.kCoin] --得到金币数
            if nCoin < self._pIntensifyEquInfo.dataInfo["GoldRequire"][self._pIntensifyEquInfo.value+1] then --如果拥有的金币小于需要的金币数
                NoticeManager:getInstance():showSystemMessage("金币不足")
                return
            end

            local nTag = sender:getTag()
            local bAuto = (nTag == 1) and true or false  --true是一键强化
            if self._pIntensifyEquInfo and self._pIntensifyEquCell then
                self.touchLayerFunc(true)
                if self._nSmallType ==  kCalloutSrcType.kCalloutSrcBagCommon then --背包装备的强化
                    EquipmentCGMessage:sendMessageBagIntensifyEquipment20124(bAuto,self._pIntensifyEquInfo.position)
                elseif self._nSmallType ==  kCalloutSrcType.kCalloutSrcEquip then --身上装备的强化
                    EquipmentCGMessage:sendMessageRoleIntensifyEquipment20126(bAuto,self._pIntensifyEquInfo.dataInfo.Part)
                end
            end

        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")    
        end
    end

    self._pAutoIntensifyButton:addTouchEventListener(intensifyButtonCallBack)    --一键强化回调
    self._pAutoIntensifyButton:setZoomScale(nButtonZoomScale)
    self._pAutoIntensifyButton:setPressedActionEnabled(true)
    self._pAutoIntensifyButton:setTag(1)
    self._pNomalIntensifyButton:addTouchEventListener(intensifyButtonCallBack)   --普通强化回调
    self._pNomalIntensifyButton:setZoomScale(nButtonZoomScale)
    self._pNomalIntensifyButton:setPressedActionEnabled(true)
    self._pNomalIntensifyButton:setTag(2)


    --self._pAutoIntensifyButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pAutoIntensifyButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    --self._pNomalIntensifyButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pNomalIntensifyButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
end

--更新界面的数据
function EquipmentIntensifyPanel:updateInstensifyDate()

    if self._pIntensifyEquInfo then

        self:clearResolveUiDateInfo(true)
        --设置itemInfo
        self._pIntensifyEquCell:setItemInfo( self._pIntensifyEquInfo)
        --设置要强化的装备cell
        if self._pEquipCell then
            self._pEquipCell:setItemInfo( self._pIntensifyEquInfo)
        end



        --获取人物主属性
        local pMajorAttr = self._pIntensifyEquInfo.equipment[1].majorAttr
        --算出人物的开始主属性
        local nStartValue = 0
        local nEndValue = 0
        if self._bHasTempDate then --如果是一键强化需要自己算出强化数据
            nStartValue = pMajorAttr.attrValue+self._pIntensifyEquInfo.dataInfo.IntensifyPreTime*self._pAniHasPlayNum
        else
            nStartValue =  pMajorAttr.attrValue
        end
        nEndValue = (nStartValue+self._pIntensifyEquInfo.dataInfo.IntensifyPreTime)

        --设置开始等级和主属性
        self._pStartlevel:setString("Lv "..self._pIntensifyEquInfo.value)
        self._pStartAttribute:setString(kAttributeNameTypeTitle[pMajorAttr.attrType]..": "..nStartValue)
        self._pChangeRes:setColor(cWhite)
        --设置下一集的等级和主属性
        if self._pIntensifyEquInfo.value < TableConstants.EquipMaxLevel.Value then
            self._pNextlevel:setString("Lv "..self._pIntensifyEquInfo.value+1)
            self._pNextAttribute:setString(kAttributeNameTypeTitle[pMajorAttr.attrType]..": "..nEndValue)
            self:setHasEquipMaxLevel(false)
        else --如果已经强化最高等级
            self._pNextlevel:setString("Lv "..self._pIntensifyEquInfo.value)
            self._pNextAttribute:setString(kAttributeNameTypeTitle[pMajorAttr.attrType]..": "..nStartValue)
            self._pChangeRes:setString("0")
            self:setHasEquipMaxLevel(true)
            self:setIntensifyMateHasVisible(false)
        end
        --得到强化所需材料的集合 {{200022.0,1},{200023.0,3}}
        local tMetaArrayDate = self._pIntensifyEquInfo.dataInfo["MaterialRequire"..self._pIntensifyEquInfo.value+1]
        for i=1 ,#self._tAllIntensifyMaterialArray do
            if tMetaArrayDate and tMetaArrayDate[i] then --如果强化里面有这个材料
                self._tAllIntensifyMaterialArray[i]:setVisible(true)
                local pSprite = self._tAllIntensifyMaterialArray[i]:getChildByName("MaterialSpreite")
                local pOwnMateNum = pSprite:getChildByName("OwnMateNum")   --拥有的材料数量lable
                local pNeedMateNum = pSprite :getChildByName("NeedMateNum") --需要的材料数量lable
                local pItemInfo =  self:getBeforeItemInfoById(tMetaArrayDate[i][1])
                local filename = pItemInfo.templeteInfo.Icon ..".png"
                pSprite:loadTexture(filename,ccui.TextureResType.plistType) --从新改变图片

                -- 强化材料弹tips 
                local function touchEvent(sender,eventType)
                    if eventType == ccui.TouchEventType.ended then
                        DialogManager:getInstance():showDialog("BagCallOutDialog",{pItemInfo,nil,nil,false})
                    elseif eventType == ccui.TouchEventType.began then
                        AudioManager:getInstance():playEffect("ButtonClick")
                    end
                end
                pSprite:setTouchEnabled(true)
                pSprite:addTouchEventListener(touchEvent)

                local nOwnValue = pItemInfo.value
                pOwnMateNum:setString(nOwnValue)  --拥有的材料数量
                pOwnMateNum:setColor((nOwnValue >= tMetaArrayDate[i][2]) and cWhite or cRed)
                pNeedMateNum:setString("/"..tMetaArrayDate[i][2]) --需要的材料数量
                local pCostGodRes = self._pIntensifyEquInfo.dataInfo["GoldRequire"][self._pIntensifyEquInfo.value+1]
                local pCurGodRes = FinanceManager:getInstance()._tCurrency[kFinance.kCoin]
                self._pChangeRes:setString(pCostGodRes)
                self._pChangeRes:setColor((pCostGodRes <= pCurGodRes) and cWhite or cRed)

                if self._bHasTempDate then  --如果不是正常进来的话 ，比如说强化成功，需要自己算强化假数据
                    if self._tTempOwnMetaNum["k"..tMetaArrayDate[i][1]] then 
                       nOwnValue  = nOwnValue - self._tTempOwnMetaNum["k"..tMetaArrayDate[i][1]]
                    end
                  
                    pOwnMateNum:setString(nOwnValue)  --拥有的材料数量
                    pOwnMateNum:setColor((nOwnValue >= tMetaArrayDate[i][2]) and cWhite or cRed)
                end

                if not self._tTempOwnMetaNum["k"..tMetaArrayDate[i][1]] then
                    self._tTempOwnMetaNum["k"..tMetaArrayDate[i][1]] = tMetaArrayDate[i][2]
                else
                    self._tTempOwnMetaNum["k"..tMetaArrayDate[i][1]] = tMetaArrayDate[i][2]+self._tTempOwnMetaNum["k"..tMetaArrayDate[i][1]]
                end


            else
                local pSprite = self._tAllIntensifyMaterialArray[i]:getChildByName("MaterialSpreite")
                pSprite:setVisible(false)


            end
        end
    else
        self:clearResolveUiDateInfo(false)

    end

end


--默认传入的装备信息
function EquipmentIntensifyPanel:setDataSource(pItemDate,nSmallType)
    self._pIntensifyEquInfo = pItemDate
    self._nSmallType = nSmallType
    --更新界面
    self:setIntenBeforeItemList()
    self:initIntensifyUi()
    self:updateInstensifyDate()

end

--回调函数
function EquipmentIntensifyPanel:SetRightScrollViewClickByIndex(pItemInfo ,nSmallType)

    self._pIntensifyEquInfo = pItemInfo
    self._nSmallType = nSmallType
    self._tTempOwnMetaNum = {}
    self:setIntenBeforeItemList()
    self:updateInstensifyDate()

end

--清空页面数据
function EquipmentIntensifyPanel:clearResolveUiDateInfo(bBool)

    if not bBool then
        bBool = false
    end
    self._pStartlevel:setVisible(bBool)
    self._pNextlevel:setVisible(bBool)
    self._pStartAttribute:setVisible(bBool)
    self._pNextAttribute:setVisible(bBool)
    self._pChangeRes:setString("0")

    if not bBool then
        self._pIntensifyEquInfo = nil
        self._pIntensifyEquCell:setItemInfo(nil)
    end

    self:setIntensifyMateHasVisible(bBool)
    self:setHasEquipMaxLevel(false)

end

--这是材料是否显示

function EquipmentIntensifyPanel:setIntensifyMateHasVisible(bBool)
    for i=1 ,#self._tAllIntensifyMaterialArray do
        local pSprite = self._tAllIntensifyMaterialArray[i]:getChildByName("MaterialSpreite")
        pSprite:setVisible(bBool)
    end
end

--设置右侧的cell
function EquipmentIntensifyPanel:setScrollCellState(pCell)
    self._pEquipCell = pCell
end
--设置装备满级
function EquipmentIntensifyPanel:setHasEquipMaxLevel(bBool)
    bBool =  not bBool
    --设置分解材料是否可显示
    self._pMountNode:setVisible(bBool)
    self._pEquMaxIcon:setVisible(not bBool)

end


--得到当前界面强化的info
function EquipmentIntensifyPanel:getItemInfo()
    return {self._pIntensifyEquInfo}
end

function EquipmentIntensifyPanel:setTouchLayerEnabled(func)
    self.touchLayerFunc = func
end


--得到本地的背包数据（强化前的）
function EquipmentIntensifyPanel:setIntenBeforeItemList()
    self._pBeforeItemList = BagCommonManager:getInstance()._pItemArry
end

--根据id得到强化前的装备数量
function EquipmentIntensifyPanel:getBeforeItemInfoById(pItemId)
    local nItemNum = 0
    for index,pItemInfo in pairs(self._pBeforeItemList) do
        if pItemId == pItemInfo.dataInfo.ID then
           pInfo = pItemInfo
           nItemNum = nItemNum + pItemInfo.value
        end
    end
    local pItemInfo = {id = pItemId, baseType = kItemType.kCounter, value = nItemNum}
    pItemInfo = GetCompleteItemInfo(pItemInfo)
    return pItemInfo
end


-- 退出函数
function EquipmentIntensifyPanel:onExitEquipmentIntensifyPanel()
    
    -- release合图资源
    ResPlistManager:getInstance():removeSpriteFrames("EquipmentIntensifyPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("strequipEffect.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)

end


return EquipmentIntensifyPanel
