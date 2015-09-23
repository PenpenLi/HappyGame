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
    self._pResolveEquipScrollView = nil
    self._pListController = nil              --优化的ScrollView
    self._pBlueImage = nil
    self._pVioletImage = nil
    self._pOrangeImage = nil
    self._pAllImage = nil
    self._pResoloveButton = nil                      --分解按钮
    self._fEquCallback = nil                         --外面的回调函数
    self._tAllSelectEquTypeArray = {}                --选择要分解的类型 蓝色橙色紫色 button
    self._tAllSelectEquImage = {}                    --选择要分解的类型 蓝色橙色紫色 对勾
    self._tAllResolveEquArrayDate = {}               --所有要分解的装备集合
    self._tAllResolveMaterialArray = {}              --材料的Cell
    self._pItemDate = nil                            --点击装备tips的装备数据
    self._tMaterialInfo = {}                         --分解材料的基本信息
    self._pResolveAniNode = nil                      --动画的node
    self._pResolveAniAction =nil                     --动画对应的action
    self._bHasHaveStone = false                      --是否分解的装备有宝石
    self._tAllResolveEquitem = {}                    --分解的item
    self.touchLayerFunc = nil                        --屏蔽点基层
end

-- 创建函数
function EquipmentResolvePanel:create(func)
    local layer = EquipmentResolvePanel.new()
    layer:dispose(func)
    return layer
end

-- 处理函数
function EquipmentResolvePanel:dispose(func)
    -- 注册网络回调事件
    ResPlistManager:getInstance():addSpriteFrames("ResolveEquipPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("ResolveEqiupEffect.plist")
    local params = require("ResolveEquipPanelParams"):create()
    self._pCCS = params._pCCS
    self._pResolveEqiupBg = params._pResolveEqiupBg
    self._pResolveEquipScrollView = params._pResolveEquipScrollView
    self._pBlueButton = params._pBlueButton
    self._pVioletButton = params._pVioletButton
    self._pOrangeButton = params._pOrangeButton
    self._pAllButton = params._pAllButton
    
    self._pBlueSlect = params._pBlueSlect
    self._pVioletSlect = params._pVioleSlect
    self._pOrangeSlect = params._pOrangeSlect
    self._pAllSlect = params._pAllSlect
    
    self._pResoloveButton = params._pResoloveButton
    self:addChild(self._pCCS)
    


    -- 初始化列表管理
    self._pListController = require("ListController"):create(self,self._pResolveEquipScrollView,listLayoutType.LayoutType_rows,100,100)
    self._pListController:setVertiaclDis(6)
    self._pListController:setHorizontalDis(3)
    
    self._fEquCallback = func
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
    --self:initResolveScrollView() --先把全部的ScrollView创建出来

    self:updateScrollViewItem() --更新ScrollView数据

end

function EquipmentResolvePanel:initResolveUi()

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

    --分解材料的回调
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


    --初始化3个材料的位置
    local nViewWidth = self._pResolveEqiupBg:getContentSize().width
    local nLeftAndReightDis = 40
    local nSize = 101
    local nStartX = -(nSize*3/2+nLeftAndReightDis)
    for i=1,3 do
        local pCell = require("BagItemCell"):create()
        pCell:setAnchorPoint(cc.p(0,0))
        pCell:setPosition(nStartX+(i-1)*(nSize+nLeftAndReightDis)-8,-190)
        pCell:setTouchEnabled(false)
        self._pCCS:addChild(pCell)
        table.insert(self._tAllResolveMaterialArray,pCell)
    end


    --选择装备类型的回调
    local onImageViewClicked = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            self._tAllResolveEquArrayDate = {}
            for k,v in pairs(BagCommonManager:getInstance()._tArrayAllResolveEqu[nTag]) do
                if not self._bHasHaveStone then --如果当前分解的装备列表里面没有宝石
                    if #v.equipment[1].stones >0 then  --如果发现有宝石
                        self._bHasHaveStone = true
                end
                end
                table.insert(self._tAllResolveEquArrayDate,v)
            end
            self._fEquCallback(self._tAllResolveEquArrayDate)
            self:updateScrollViewItem()
            self:clearColorEquTypeImageState()
            self._tAllSelectEquImage[nTag]:setVisible(true)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    --下面的装备类型选择 蓝色，紫色 橙色 全部
    self._tAllSelectEquTypeArray = { self._pBlueButton, self._pVioletButton, self._pOrangeButton, self._pAllButton}
    self._tAllSelectEquImage = { self._pBlueSlect, self._pVioletSlect, self._pOrangeSlect, self._pAllSlect}
    for k,v in pairs(self._tAllSelectEquTypeArray) do
        v:setTouchEnabled(true)
        v:setTag(k)
        v:addTouchEventListener(onImageViewClicked)
    end
    --分解材料
    self._pResoloveButton:addTouchEventListener(resoloveButtonCallBack)
    self._pResoloveButton:setZoomScale(nButtonZoomScale)
    self._pResoloveButton:setPressedActionEnabled(true)
    --self._pResoloveButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pResoloveButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

end

--更新左边的ScrollView界面
function EquipmentResolvePanel:updateScrollViewItem()

    local onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:clearColorEquTypeImageState()  --清空下面根据装备颜色筛选的图片状态
            table.remove(self._tAllResolveEquArrayDate, sender:getTag())
            self._fEquCallback(self._tAllResolveEquArrayDate)
            self:updateScrollViewItem()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")   
        end
    end

     self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local pInfo =   self._tAllResolveEquArrayDate[index]
        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("BagItemCell"):create()
        end
        cell:setItemInfo(pInfo)
        cell._pIconBtn:setTag(index)
        cell._pIconBtn:addTouchEventListener(onTouchButton)
        
        return cell
     end
     
    if self._pListController._pDataSource and table.getn(self._pListController._pDataSource) >12 then
        self._pResolveEquipScrollView:scrollToPercentVertical(100,0.1,false)
     end
       
    --获取size的大小
    local nDateNum = table.getn(self._tAllResolveEquArrayDate)
    local nRow  = math.ceil(nDateNum/4)
    nDateNum = 4*nRow
    local nDefNum = 12                                  --默认创建的背景个数 需要填满一屏 4*5 20个
    nDefNum = nDefNum > nDateNum and nDefNum or nDateNum
    
    self._pListController._pNumOfCellDelegateFunc = function ()
        return nDefNum
    end
    self._pListController:setDataSource(self._tAllResolveEquArrayDate)

    if self._pListController._pDataSource and table.getn(self._pListController._pDataSource) >12 then
        self._pResolveEquipScrollView:scrollToPercentVertical(100,0.1,false)
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
            print("this equipment is add already")
            return
        end
    end
    self:clearColorEquTypeImageState()  --清空下面根据装备颜色筛选的图片状态
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
    self._pItemDate = nil                         --点击装备tips的装备数据
    for k,v in pairs(self._tAllResolveMaterialArray) do
        v:setItemInfo(nil)
    end
    
    for k=1,12 do
        local cell = self._pListController:cellWithIndex(k)
        if cell then
            cell:setItemInfo(nil)
        end
    end
    --self:updateScrollViewItem()
    --self._pResolveEquipScrollView:removeAllChildren(true) --清空ScrollView
    self:clearColorEquTypeImageState()  --清空下面根据装备颜色筛选的图片状态
    self._bHasHaveStone = false 
    self:updateScrollViewItem()

end

function EquipmentResolvePanel:clearColorEquTypeImageState()
    for k,v in pairs(self._tAllSelectEquImage) do     --设置下面的单选框图片选择状态
        self._tAllSelectEquImage[k]:setVisible(false)
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
