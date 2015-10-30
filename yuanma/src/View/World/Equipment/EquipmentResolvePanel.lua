--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EquipmentResolvePanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/1/6
-- descrip:   装备分解界面
--===================================================

local EquipmentResolvePanel = class("EquipmentResolvePanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function EquipmentResolvePanel:ctor()
    self._strName = "EquipmentResolvePanel"          -- 层名称
    self._pCCS  = nil
    self._pResolveEqiupBg = nil
    self._pResoloveButton = nil                      --分解按钮
    self._fEquCallback = nil                         --外面的回调函数
    self._fResColorBtnCallBack = nil                 --点击(全部，蓝紫橙)装备按钮时候回调
    self._tAllResolveEquArrayDate = {}               --所有要分解的装备集合
    self._tALlResolveItem = {}                       --所有装备的cell
    self._tAllResolveMaterialArray = {}              --材料的Cell
    self._tMaterialInfo = {}                         --分解材料的基本信息
    self._pResolveAniNode = nil                      --动画的node
    self._bHasHaveStone = false                      --是否分解的装备有宝石
    self._tAllResolveEquitem = {}                    --分解的item
    self.touchLayerFunc = nil                        --屏蔽点基层
    self._nColorResBtnIndex = 1                      --全部蓝紫橙 按钮的点击下表
end

-- 创建函数
function EquipmentResolvePanel:create(func,fResColorBtnCallBack)
    local layer = EquipmentResolvePanel.new()
    layer:dispose(func,fResColorBtnCallBack)
    return layer
end

-- 处理函数
function EquipmentResolvePanel:dispose(func,fResColorBtnCallBack)
    -- 注册网络回调事件
    ResPlistManager:getInstance():addSpriteFrames("ResolveEquipPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("ResolveEqiupEffect.plist")
    local params = require("ResolveEquipPanelParams"):create()
    self._pCCS = params._pCCS
    self._pResolveEqiupBg = params._pResolveEqiupBg
    --{所有，蓝，紫，橙}
    self._tColorCanResEquBtn = params._tColorCanResEquBtn
    --可以分解的装备图片挂载
    self._tCanResolveEqu = params._tCanResolveEqu
    --分解按钮
    self._pResoloveButton = params._pResoloveButton
    --一键放入按钮
    self._pAutoPushEquButton = params._pResoloveButton_Copy
    self:addChild(self._pCCS)

    self._fEquCallback = func
    self._fResColorBtnCallBack = fResColorBtnCallBack
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEquipmentResolvePanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end

--默认传入的装备信息
function EquipmentResolvePanel:setDataSource(pItemDate)
    if pItemDate ~=nil then
        table.insert(self._tAllResolveEquArrayDate,pItemDate)
        if not self._bHasHaveStone then --如果当前分解的装备列表里面没有宝石
            if #pItemDate.equipment[1].stones >0 then  --如果发现有宝石
                self._bHasHaveStone = true
        end
        end
    end
    self:initResolveUi() --初始化界面的点击事件和ui
    self:updateScrollViewItem() --更新ScrollView数据
end
function EquipmentResolvePanel:initResolveUi()

    local cellButtonCallBack = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pTag = sender:getTag()
            print("Std:Tag "..pTag)
            if self._tAllResolveEquArrayDate[pTag] == nil then --如果当前位置为空，不计算
                return
            end
            table.remove(self._tAllResolveEquArrayDate,pTag)
            self._fEquCallback()
            self:updateScrollViewItem()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    --初始化9个装备
    for k,v in pairs(self._tCanResolveEqu)do
        local pCell = require("BagItemCell"):create()
        pCell:setAnchorPoint(cc.p(0,0))
        pCell:setPosition(cc.p(0,0))
        pCell._pIconBtn:setTag(k)
        pCell._pIconBtn:addTouchEventListener(cellButtonCallBack)
        v:addChild(pCell)
        table.insert(self._tALlResolveItem,pCell)
    end


    --初始化3个材料的位置
    local nViewWidth = self._pResolveEqiupBg:getContentSize().width
    local nLeftAndReightDis = 30
    local nSize = 90
    local nStartX = -(nSize*3/2+nLeftAndReightDis)
    for i=1,3 do
        local pCell = require("BagItemCell"):create()
        pCell:setAnchorPoint(cc.p(0,0))
        pCell:setPosition(nStartX+(i-1)*(nSize+nLeftAndReightDis)-8,-237)
        pCell:setTouchEnabled(false)
        self._pCCS:addChild(pCell)
        table.insert(self._tAllResolveMaterialArray,pCell)
    end


    local playResolveEffect = function (tArray)
        local function onFrameEvent(frame)
            if nil == frame then
                return
            end
            local str = frame:getEvent()
            if str == "playOver" then
                self.touchLayerFunc(false)
                EquipmentCGMessage:sendMessageResolveEquipment20112(tArray)
            end
        end
        if not self._pResolveAniNode then
            self._pResolveAniNode = cc.CSLoader:createNode("ResolveEqiupEffect.csb")
            self._pResolveAniNode:setPosition(100,100)
            self:addChild( self._pResolveAniNode)
        end
        local pResolveAniAction = cc.CSLoader:createTimeline("ResolveEqiupEffect.csb")
        pResolveAniAction:setFrameEventCallFunc(onFrameEvent)
        pResolveAniAction:gotoFrameAndPlay(0,pResolveAniAction:getDuration(), false)
        self._pResolveAniNode:stopAllActions()
        self._pResolveAniNode:runAction(pResolveAniAction)


    end

    --分解按鈕的回调
    local resoloveButtonCallBack = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if #self._tAllResolveEquArrayDate == 0 then
                NoticeManager:getInstance():showSystemMessage("请选择分解的材料")
                return
            end
            if BagCommonManager:getInstance():isBagItemsEnough() then
                NoticeManager:getInstance():showSystemMessage("背包已满")
                return
            end

            local tresolovesArray = {}
            for i=1,#self._tAllResolveEquArrayDate do
                table.insert(tresolovesArray,self._tAllResolveEquArrayDate[i].position)
            end
            if #tresolovesArray >0 then
                self.touchLayerFunc(true)
                playResolveEffect(tresolovesArray)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pResoloveButton:addTouchEventListener(resoloveButtonCallBack)
    self._pResoloveButton:setZoomScale(nButtonZoomScale)
    self._pResoloveButton:setPressedActionEnabled(true)


    --选择装备类型的按钮回调
    local onImageViewClicked = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            self:updateColorResEquBtnStateByTag(nTag)
            self._fResColorBtnCallBack(nTag)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    --下面的装备类型选择 蓝色，紫色 橙色 全部
    for k,v in pairs(self._tColorCanResEquBtn) do
        v:setTouchEnabled(true)
        v:setTag(k)
        v:addTouchEventListener(onImageViewClicked)
    end

    -----自动放入装备的按钮回调
    local autoPushEquButtonCallBack = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if table.getn(self._tAllResolveEquArrayDate) >= table.getn(self._tCanResolveEqu) then
               NoticeManager:getInstance():showSystemMessage("可分解的装备已经满了")
                return
            end
            for k,v in pairs(BagCommonManager:getInstance()._tArrayAllResolveEqu[self._nColorResBtnIndex]) do
                --如果当前可以分解的装备大于8
                if table.getn(self._tAllResolveEquArrayDate) >= table.getn(self._tCanResolveEqu) then
                    break
                end
                if not self._bHasHaveStone then --如果当前分解的装备列表里面没有宝石
                    if #v.equipment[1].stones >0 then  --如果发现有宝石
                        self._bHasHaveStone = true
                end
                end
                local pHasInclude = false
                for kv,vv in pairs(self._tAllResolveEquArrayDate) do
                   if vv == v then  --此装备已经添加过
                      pHasInclude = true
                      break
                   end
                end
                if pHasInclude == false then
                   table.insert(self._tAllResolveEquArrayDate,v)
                end

            end
            self:_fEquCallback()
            self:updateScrollViewItem()


        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pAutoPushEquButton:addTouchEventListener(autoPushEquButtonCallBack)
    self._pAutoPushEquButton:setZoomScale(nButtonZoomScale)
    self._pAutoPushEquButton:setPressedActionEnabled(true)


end

--更新左边的ScrollView界面
function EquipmentResolvePanel:updateScrollViewItem()

    for k,v in pairs(self._tALlResolveItem) do
        if self._tAllResolveEquArrayDate and self._tAllResolveEquArrayDate[k] ~= nil then
            v:setItemInfo(self._tAllResolveEquArrayDate[k])
        else
            v:setItemInfo(nil)

        end
    end

    self._tMaterialInfo = {}

    --设置分解材料
    for i=1,#self._tAllResolveEquArrayDate do
        --分解的普通材料
        for k,v in pairs(self._tAllResolveEquArrayDate[i].dataInfo.MaterialBasis) do
            local  pTempInfo= {baseType = kItemType.kCounter}
            if self._tMaterialInfo and self._tMaterialInfo[k] then  --如果不是第一次加载
                self._tMaterialInfo[k].value = self._tMaterialInfo[k].value +v[2]
            else
                pTempInfo.id = v[1]
                pTempInfo.value = v[2]
                table.insert(self._tMaterialInfo,pTempInfo)
            end

        end

        -- self._tMaterialInfo[v.[1]] = v[2]
        --分解的强化材料
        for k,v in pairs(self._tAllResolveEquArrayDate[i].dataInfo.MaterialUp) do
            local pTempInfo= {baseType = kItemType.kCounter}
            local bBool = true
            for j=1,#self._tMaterialInfo do
                if self._tMaterialInfo[j].id == v[1] then --前面的三个基本材料里面有这个材料 需要累加
                    self._tMaterialInfo[j].value = self._tMaterialInfo[j].value+v[2]*self._tAllResolveEquArrayDate[i].value
                    bBool = false
                    break
                end
            end
            if bBool then  --如果是基础材料里面没有这个材料
                pTempInfo.id = v[1]
                pTempInfo.value = v[2]*self._tAllResolveEquArrayDate[i].value
                table.insert(self._tMaterialInfo,pTempInfo)

            end

        end
    end
    for k,v in pairs(self._tAllResolveMaterialArray) do
        if #self._tMaterialInfo >0 and self._tMaterialInfo[k]~= nil then --如果有分解材料
            local pInfo = GetCompleteItemInfo(self._tMaterialInfo[k])
            v:setItemInfo(self._tMaterialInfo[k].value>0 and pInfo or nil)
        else
            v:setItemInfo(nil)
        end
    end

end

--回调函数
function EquipmentResolvePanel:SetRightScrollViewClickByIndex(pItemInfo)

    local pResolveEquTempInfo = pItemInfo
    --先检测左侧是否把这个装备添加了

    for i=1,#self._tAllResolveEquArrayDate do
        if pResolveEquTempInfo == self._tAllResolveEquArrayDate[i] then --如果左侧材料的ScrollView已经有这个装备了
           NoticeManager:getInstance():showSystemMessage("装备已经存在了")
            return
        end
    end

    --如果已经够8个了。那就直接返回
    if table.getn(self._tAllResolveEquArrayDate) >= table.getn(self._tCanResolveEqu) then
        NoticeManager:getInstance():showSystemMessage("可分解的装备已经满了")
        return
     end

    table.insert(self._tAllResolveEquArrayDate,pResolveEquTempInfo)
    self:updateScrollViewItem()

    if not self._bHasHaveStone then --如果当前分解的装备列表里面没有宝石
        if #pResolveEquTempInfo.equipment[1].stones >0 then  --如果发现有宝石
            self._bHasHaveStone = true
    end
    end

end

--清空页面数据
function EquipmentResolvePanel:clearResolveUiDateInfo()
    self._tAllResolveEquArrayDate = {}                --所有要分解的装备集合
    for k,v in pairs(self._tAllResolveMaterialArray) do
        v:setItemInfo(nil)
    end

    self._bHasHaveStone = false
    self:updateScrollViewItem()
    --默认选中第一个
    self:updateColorResEquBtnStateByTag(self._nColorResBtnIndex)
end

--更新全部，蓝紫橙按钮的图片状态
function EquipmentResolvePanel:updateColorResEquBtnStateByTag(nTag)
    local tMountingBtnTexture = {{"ResolveEquipPanelRes/qbax.png","ResolveEquipPanelRes/qbct.png"},
        {"ResolveEquipPanelRes/lzax.png","ResolveEquipPanelRes/lzct.png"},
        {"ResolveEquipPanelRes/zzax.png","ResolveEquipPanelRes/zzct.png"},
        {"ResolveEquipPanelRes/czax.png","ResolveEquipPanelRes/czct.png"},}
    self._nColorResBtnIndex = nTag
    --下面的装备类型选择 蓝色，紫色 橙色 全部
    for k,v in pairs(self._tColorCanResEquBtn) do
        if k == nTag then
            v:loadTextures(tMountingBtnTexture[k][2],tMountingBtnTexture[k][2],nil,ccui.TextureResType.plistType)
        else
            v:loadTextures(tMountingBtnTexture[k][1],tMountingBtnTexture[k][2],nil,ccui.TextureResType.plistType)
        end
    end
end


function EquipmentResolvePanel:getItemInfo()
    return self._tAllResolveEquArrayDate
end

--点击屏蔽层
function EquipmentResolvePanel:setTouchLayerEnabled(func)
    self.touchLayerFunc = func
end

-- 退出函数
function EquipmentResolvePanel:onExitEquipmentResolvePanel()
    -- release合图资源
    ResPlistManager:getInstance():removeSpriteFrames("ResolveEquipPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("ResolveEqiupEffect.plist")
end

-- 循环更新
function EquipmentResolvePanel:update(dt)
    return
end

-- 显示结束时的回调
function EquipmentResolvePanel:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function EquipmentResolvePanel:doWhenCloseOver()
    return
end

return EquipmentResolvePanel
