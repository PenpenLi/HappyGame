--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FairyLandDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2014/12/16
-- descrip:   境界系统
--===================================================
local FairyLandDialog = class("FairyLandDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FairyLandDialog:ctor()
    self._strName = "FairyLandDialog"        -- 层名称
    self._pCCS = nil
    self._pBg = nil
    self._pCloseButton = nil
    self._pResultbutton = nil                --境界效果按钮
    self._pAutoDevourButton = nil            --一键吞噬
    self._pUpQualityButton = nil             --升阶按钮
    self._pRefreshButton = nil               --刷新按钮
    self._pDanIcon = nil                     --境界升级丹图标
    self._pOwnDanNumText = nil               --拥有的升阶丹数量
    self._pNeedDanNumText = nil              --需要的升阶丹数量
    self._pOwnFairyLandDanNumText = nil      --境界点数量
    self._pNeedFairyLandDanNumText = nil     --境界点数量
    self._pFairyLandDanLvText  = nil         --显示境界等级
    self._pFairyLandDishBar = nil            --境界系统的进度条
    self._pFairyLandDanLvBg = nil            --境界系统进度条的背景
    self._tFairyLandPillBg = {}              --境界丹的背景图
    self._tFairyLandPillBgPos = {}           --境界丹的背景图pos
    self._pFairyLandDishBarText = nil        --境界盘上的文本 99%
    self._pDanRightScrollView = nil          --右侧的滑动层
    self._tFairyLandInfo = nil
    self._tScrollViewItemArray = {}          --右侧的scrollView
    self._pRotateSprite = nil                --旋转的精灵
    self._pTipsNode = nil                    --隐藏和显示的信息node
    self._pLandName = nil                    --境界丹的名称
    self._pAtrrType = nil                    --境界丹的类型
    self._pAtrrNum = nil                     --境界丹的数值
    self._pAttributeUp = nil                 --提升的button
    self._pUnsnatch = nil                    --卸下的button
    self._pRemindText = nil                  --境界丹没有的时候提示
    

    self._bFirstLoad = false                 --第一次加载
    --各种特效
    self._pFairyLandUnlockEffect = nil       --解锁的特效工程名称
    self._pFairyLandPanLvupEffect = nil      --境界系统盘升阶动画
    self._pFairyLandAutoDevourEffect = nil   --一键吞噬动画
    
    self._nSelectTag = nil                  --默认选中的tag

end

-- 创建函数
function FairyLandDialog:create(tFairyLandInfo)
    local dialog = FairyLandDialog.new()
    dialog:dispose(tFairyLandInfo)
    return dialog
end

-- 处理函数
function FairyLandDialog:dispose(tFairyLandInfo)
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "境界按钮" , value = false})

    self._tFairyLandInfo = tFairyLandInfo
    ResPlistManager:getInstance():addSpriteFrames("FairyLandDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("EquippingEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("FairyLandPanLvupEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("ResolveEqiupEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames("FairyLandUnlock.plist")

    NetRespManager:getInstance():addEventListener(kNetCmd.kInlayFairyPill, handler(self,self.RespInlayFairyPill))
    NetRespManager:getInstance():addEventListener(kNetCmd.kDropFairyPill, handler(self, self.RespDropFairyPill))
    NetRespManager:getInstance():addEventListener(kNetCmd.kDevourFairyPill, handler(self, self.RespDevourFairyPill))
    NetRespManager:getInstance():addEventListener(kNetCmd.kRefreshFairyPill, handler(self, self.RespRefreshFairyPill))
    NetRespManager:getInstance():addEventListener(kNetCmd.kAutoDevour, handler(self, self.RespAutoDevour))
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpgradeFairyDish, handler(self, self.RespUpgradeFairyDish))
    
  
    self:initUi()                     -- 初始化dialog的基础组件
    self:createFairyLandDishBar()     --假如境界系统的进度条
    self:initFaryLandUi()             --初始化界面按钮的点击和ScrollView
    self:setScrollViewDate()          --初始化右边的ScrollView
    self:initFaryDishUi()             --加载境界盘信息
    self:setFairyDishInfo(false)      --加载境界盘下面的等级和进度条
    self:setDefaultSelectState() --卸下时候显示默认

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
        end
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end ".."x="..location.x.."  y="..location.y)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFairyLandDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

--初始化ui
function FairyLandDialog:initUi()
    -- 加载dialog组件
    local params = require("FairyLandDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pResultbutton = params._pResultbutton                      --境界按钮
    self._pAutoDevourButton = params._pDevourButton                  --一键吞噬
    self._pUpQualityButton = params._pUpButton                       --升阶按钮
    self._pRefreshButton = params._pRefreshButton                    --刷新按钮
    self._pDanIcon = params._pDanIcon                                --境界升级丹图标
    self._pOwnDanNumText = params._pDanNumText1                      --拥有的升阶丹数量
    self._pNeedDanNumText = params._pDanNumText2                     --需要的升阶丹数量
    self._pOwnFairyLandDanNumText = params._pFairyLandDanNumText1    --境界点数量
    self._pNeedFairyLandDanNumText = params._pFairyLandDanNumText2   --境界点数量
    self._pFairyLandDanLvText =  params._pFairyLandDanLvText         --显示境界等级
    self._pFairyLandDanLvBg = params._pFairyLandDanLvBg              --境界盘的进度条
    self._pFairyLandDishBarText = params._pPanExpText                --境界盘上的文本 99%
    self._pDanRightScrollView =  params._pDanRightScrollView         --右侧的滑动层
    self._pRotateSprite = params._pTips                              --旋转的精灵
    self._pTipsNode = params._pTipsNode                              --隐藏和显示的信息node
    self._pLandName = params._pFdanName                              --境界丹的名称
    self._pAtrrType =  params._pAtrrType                             --境界丹的类型
    self._pAtrrNum =  params._pAtrrNum                               --境界丹的数值
    self._pAttributeUp = params._pAttribute                          --提升的button
    self._pUnsnatch = params._pUnsnatch                              --卸下的button
    self._pRemindText = params._pRemindText                          --境界丹没有的时候提示

    for i=1,12 do
        table.insert( self._tFairyLandPillBg, params["_p"..i.."Icon"])               --境界丹的背景
        local nX,nY = params["_p"..i.."Icon"]:getPosition()
        table.insert(self._tFairyLandPillBgPos,cc.p(nX,nY))
    end
    self:disposeCSB()
    --self._pFairyLandDishBarText:enableOutline(cc.c4b(0, 0, 0, 255), 2)

    local nDanId = TableFairyLand[self._tFairyLandInfo.dishInfo.level].RequiredDan[1]
    local pDanInfo = {id = nDanId, baseType = kItemType.kCounter, value = 0}
    pDanInfo = GetCompleteItemInfo(pDanInfo)
    -- 境界升阶丹弹tips
    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
            DialogManager:getInstance():showDialog("BagCallOutDialog",{pDanInfo,nil,nil,false})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pDanIcon:setTouchEnabled(true)
    self._pDanIcon:addTouchEventListener(touchEvent)
end


--境界丹镶嵌[回复]
function FairyLandDialog:RespInlayFairyPill(event)

    local nPowerChange = 0
    nPowerChange = event.roleInfo.roleAttrInfo.fightingPower-RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
    RolesManager:getInstance():setMainRole(event.roleInfo)
    local nInlay = 0
    if #self._tFairyLandInfo.dishInfo.pillList ==0 then --说明境界丹没有这时候境界Index为1
        nInlay = 1
    else

        local bTempFag = true
        for i=1, #self._tFairyLandInfo.dishInfo.pillList do
            --如果本地数据跟服务器数据不一样说明 就是镶嵌到第几个位置上了
            if event.dishInfo.pillList[i].index ~= self._tFairyLandInfo.dishInfo.pillList[i].index then
                nInlay = i
                bTempFag = false
                break
            end
        end
        if bTempFag then --如果上面循环的都没找到 可能是在最后一个位置上
            nInlay = #event.dishInfo.pillList
        end
    end
    self._tFairyLandInfo.dishInfo = event.dishInfo
    --删除右侧ScrollView镶嵌的那个item
    self:removeItemDateByIndex(self._tFairyLandInfo.packagePillList,event.argsBody.pillIndex)
    self._tScrollViewItemArray[event.argsBody.pillIndex]:removeAllChildren(true)

    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
            NoticeManager:getInstance():showFightStrengthChange(nPowerChange)
            self:initFaryDishUi()    --加载境界盘信息
            self:setLandSelectStateByTag(nInlay)
            --self:setFairyDishInfo()  --加载境界盘下面的等级和进度条
        end
    end
    --镶嵌境界丹动画
    local pNode = self._tFairyLandPillBg[nInlay] --此处不用移除 因为从新初始化的时候，父节点会执行romve操作
    local pPanIntoEffect = cc.CSLoader:createNode("EquippingEffect.csb")
    pPanIntoEffect:setPosition(cc.p(pNode:getContentSize().width/2,pNode:getContentSize().height/2))
    pNode:addChild(pPanIntoEffect)

    local PanIntoAniAction = cc.CSLoader:createTimeline("EquippingEffect.csb")
    PanIntoAniAction:setFrameEventCallFunc(onFrameEvent)
    pPanIntoEffect:stopAllActions()
    PanIntoAniAction:gotoFrameAndPlay(0,PanIntoAniAction:getDuration(), false)
    pPanIntoEffect:runAction(PanIntoAniAction)

end

--卸下境界丹[回复]
function FairyLandDialog:RespDropFairyPill(event)
    local nPowerChange = 0
    self._tFairyLandInfo.dishInfo = event.dishInfo
    nPowerChange = event.roleInfo.roleAttrInfo.fightingPower-RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
    RolesManager:getInstance():setMainRole(event.roleInfo)
    NoticeManager:getInstance():showFightStrengthChange(nPowerChange)
    self:initFaryDishUi()    --加载境界盘信息
    self:setFairyDishInfo()  --加载境界盘下面的等级和进度条
    self:setDefaultSelectState() --卸下时候显示默认

end

--吞噬境界丹[回复]
function FairyLandDialog:RespDevourFairyPill(event)
    local nPowerChange = 0
    if #event.roleInfo >0 then
        nPowerChange = event.roleInfo[1].roleAttrInfo.fightingPower-RolesManager:getInstance()._pMainRoleInfo.roleAttrInfo.fightingPower
        RolesManager:getInstance():setMainRole(event.roleInfo[1])
    end

    --删除镶嵌的那个item
    self:removeItemDateByIndex(self._tFairyLandInfo.packagePillList,event.packageIndex)
    self._tScrollViewItemArray[event.packageIndex]:removeAllChildren(true)
    self:setDevourFairyInfo(event)
    if nPowerChange ~= 0 then
       NoticeManager:getInstance():showFightStrengthChange(nPowerChange)
    end
   
end

-- 刷新境界丹列表[回复]
function FairyLandDialog:RespRefreshFairyPill(event)
    self._tFairyLandInfo = event
    self:setScrollViewDate() --初始化右边的ScrollView
    self:initFaryDishUi()    --加载境界盘信息
    self:setFairyDishInfo()  --加载境界盘下面的等级和进度条
end

--一键吞噬[回复]
function FairyLandDialog:RespAutoDevour(event)
    self._tFairyLandInfo.dishInfo = event.dishInfo
    self._tFairyLandInfo.packagePillList = {}
    self:setScrollViewDate() --初始化右边的ScrollView

    local function onDevourAniActionEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
            self._pFairyLandAutoDevourEffect:removeFromParent(true)
            self._pFairyLandAutoDevourEffect = nil
            self:initFaryDishUi()    --加载境界盘信息
            self:setFairyDishInfo()  --加载境界盘下面的等级和进度条
        end
    end
    local px,py = self._pTipsNode:getPosition()
    self._pFairyLandAutoDevourEffect = cc.CSLoader:createNode("ResolveEqiupEffect.csb")
    self._pFairyLandAutoDevourEffect:setPosition(cc.p(px,py))
    self._pBg:addChild(self._pFairyLandAutoDevourEffect)

    local pAutoDevourAniAction = cc.CSLoader:createTimeline("ResolveEqiupEffect.csb")
    pAutoDevourAniAction:setFrameEventCallFunc(onDevourAniActionEvent)
    self._pFairyLandAutoDevourEffect:stopAllActions()
    pAutoDevourAniAction:gotoFrameAndPlay(0,pAutoDevourAniAction:getDuration(), false)
    self._pFairyLandAutoDevourEffect:runAction(pAutoDevourAniAction)
end

--境界丹进阶[回复]
function FairyLandDialog:RespUpgradeFairyDish(event)
    self._tFairyLandInfo.dishInfo = event.dishInfo
    --解锁的特效
    local function onUnLockEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
            self._pFairyLandUnlockEffect:removeFromParent(true)
            self._pFairyLandUnlockEffect = nil
            self:initFaryDishUi()    --加载境界盘信息
        end

    end

    --升阶的特效
    local function onFrameEvent(frame)
        if nil == frame then
            return
        end
        local str = frame:getEvent()
        if str == "playOver" then
            --self:setFairyDishInfo()  --加载境界盘下面的等级和进度条
        end

        if str == "playOther" then
            self._pFairyLandPanLvupEffect:removeFromParent(true)
            self._pFairyLandPanLvupEffect = nil
            --self:initFaryDishUi()    --加载境界盘信息
            self:setFairyDishInfo()  --加载境界盘下面的等级和进度条
            --播放完升阶动画，播放解锁动画
            self._pFairyLandUnlockEffect = cc.CSLoader:createNode("FairyLandUnlock.csb")
            self._pFairyLandUnlockEffect:setPosition(mmo.VisibleRect:center())
            self:addChild(self._pFairyLandUnlockEffect)

            local pUnlockAniAction = cc.CSLoader:createTimeline("FairyLandUnlock.csb")
            pUnlockAniAction:setFrameEventCallFunc(onUnLockEvent)
            self._pFairyLandUnlockEffect:stopAllActions()
            pUnlockAniAction:gotoFrameAndPlay(0,pUnlockAniAction:getDuration(), false)
            self._pFairyLandUnlockEffect:runAction(pUnlockAniAction)
        end

    end


    self._pFairyLandPanLvupEffect = cc.CSLoader:createNode("FairyLandPanLvupEffect.csb")
    self._pFairyLandPanLvupEffect:setPosition( self._pFairyLandDishBar:getPosition() )
    self._pFairyLandPanLvupEffect:setScaleX(0.4)
    self._pFairyLandDishBar:addChild(self._pFairyLandPanLvupEffect)
    local pLandPanLvupAniAction = cc.CSLoader:createTimeline("FairyLandPanLvupEffect.csb")
    pLandPanLvupAniAction:setFrameEventCallFunc(onFrameEvent)
    self._pFairyLandPanLvupEffect:stopAllActions()
    pLandPanLvupAniAction:gotoFrameAndPlay(0,pLandPanLvupAniAction:getDuration(), false)
    self._pFairyLandPanLvupEffect:runAction(pLandPanLvupAniAction)


end

--初始化右侧的ScrollView数据
function FairyLandDialog:setScrollViewDate()
    local packagePillList = self._tFairyLandInfo.packagePillList
    if #packagePillList ==0 then --如果为零则说明右侧没有数据需要全部移除
        for i=1,#self._tScrollViewItemArray do
            self._tScrollViewItemArray[i]:removeAllChildren(true)
    end
    end

    local nSize = 101
    for i=1,#packagePillList do
        local pTempItemInfo =  GetCompleteItemInfoById(packagePillList[i],1)
        local pTempBg = self._tScrollViewItemArray[pTempItemInfo.index]
        pTempBg:removeAllChildren(true)
        local  onButtonTouchClicked = function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                print("item Tag is "..sender:getTag())
                local nTag = sender:getTag()
                local nTempInfo =  self:getScrollViewHasDateByIndex(nTag)
                if not nTempInfo then
                    NoticeManager:getInstance():showSystemMessage("该位置没有境界丹")
                    return
                end
                NewbieManager:showOutAndRemoveWithRunTime()
                DialogManager:getInstance():showDialog("FairyLandCellDialog",{nTempInfo,fairyLandTabType.fairyLandTabInlay })
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end

        local nQuality = pTempItemInfo.dataInfo.Quality
        local pQualityBg = ccui.ImageView:create()
        pQualityBg:setAnchorPoint(cc.p(0,0))
        pQualityBg:loadTexture("ccsComRes/qual_" ..nQuality.."_normal.png",ccui.TextureResType.plistType)
        pTempBg:addChild(pQualityBg)

        local pItemButton = ccui.Button:create(pTempItemInfo.templeteInfo.Icon..".png",pTempItemInfo.templeteInfo.Icon..".png",pTempItemInfo.templeteInfo.Icon..".png",ccui.TextureResType.plistType)
        pItemButton:addTouchEventListener(onButtonTouchClicked)
        pItemButton:setTouchEnabled(true)
        pItemButton:setTag(pTempItemInfo.index)
        pItemButton:setPosition(nSize/2,nSize/2)
        pTempBg:addChild(pItemButton)

    end
end

--设置界面的基本点击事件和初始化ui
function FairyLandDialog:initFaryLandUi()
    local touchResultbutton = function( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            --境界按钮 显示所有增加属性
            if #self._tFairyLandInfo.dishInfo.addAttr > 0 then
                -- self:getGameScene():showDialog(require("FairyLandCellDialog"):create())
                DialogManager:getInstance():showDialog("FairyLandCellDialog",{self._tFairyLandInfo.dishInfo.addAttr,fairyLandTabType.fairyLandTabAllAttUp})
            else
                NoticeManager:getInstance():showSystemMessage("未镶嵌任何境界丹")
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    local touchAutoDevourButton = function( sender,eventType )
        if eventType == ccui.TouchEventType.ended then

            --一键吞噬
            if #self._tFairyLandInfo.packagePillList >0 then
                FairyLandCGMessage:sendMessageAutoDevour20610()
            else
                NoticeManager:getInstance():showSystemMessage("没有可吞噬的境界丹")
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    local touchUpQualityButton = function( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            --升阶按钮
            local nDishLevel = self._tFairyLandInfo.dishInfo.level
            if nDishLevel == TableConstants.FairyLandMaxLevel.Value then
                NoticeManager:getInstance():showSystemMessage("境界盘已经升到最高级了")
                return
            end
            FairyLandCGMessage:sendMessageUpgradeFairyDish20612()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    local touchRefreshButton = function( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            --刷新按钮
            local pOwnBp = FinanceManager:getInstance()._tCurrency[kFinance.kBP]
            local pNeedPoint = TableFairyLand[self._tFairyLandInfo.dishInfo.level].RequiredPoint
            if pOwnBp < pNeedPoint then
                NoticeManager:getInstance():showSystemMessage("境界点不足")
                return
            end
            FairyLandCGMessage:sendMessagefreshFairyPill20608()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pResultbutton:addTouchEventListener(touchResultbutton)       --境界按钮 显示所有增加属性
    self._pAutoDevourButton:addTouchEventListener(touchAutoDevourButton)   --一键吞噬
    self._pUpQualityButton:addTouchEventListener(touchUpQualityButton)    --升阶按钮
    self._pRefreshButton:addTouchEventListener(touchRefreshButton)      --刷新按钮

    --self._pAutoDevourButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pAutoDevourButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

    --self._pUpQualityButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pUpQualityButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

    --self._pRefreshButton:getTitleRenderer():enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pRefreshButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    
    --self._pResultbutton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))

    self._pResultbutton:setZoomScale(nButtonZoomScale)
    self._pResultbutton:setPressedActionEnabled(true)
    self._pAutoDevourButton:setZoomScale(nButtonZoomScale)
    self._pAutoDevourButton:setPressedActionEnabled(true)
    self._pUpQualityButton:setZoomScale(nButtonZoomScale)
    self._pUpQualityButton:setPressedActionEnabled(true)
    self._pRefreshButton:setZoomScale(nButtonZoomScale)
    self._pRefreshButton:setPressedActionEnabled(true)

    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101
    local nDateNum = 20
    local nRow ,nRemainder = math.modf(nDateNum/4)
    if nRemainder >0 then --如果有余数就多一行
        nRow = nRow + 1
    end
    local nViewHeight = self._pDanRightScrollView:getContentSize().height
    local nViewWidth  = self._pDanRightScrollView:getContentSize().width
    local pScrInnerHeight =  ((nViewHeight >(nUpAndDownDis+nSize)*nRow)) and nViewHeight or (nUpAndDownDis+nSize)*nRow
    self._pDanRightScrollView:setInnerContainerSize(cc.size(nViewWidth,pScrInnerHeight))
    self._pDanRightScrollView:setBounceEnabled(false)

    for i=1,nDateNum do
        local t1,t2 = math.modf((i-1)/4)
        t2 = t2*4
        local pItemBg = cc.Sprite:createWithSpriteFrameName("ccsComRes/BagItem.png")
        pItemBg:setAnchorPoint(cc.p(0,0))
        pItemBg:setPosition(t2*(nSize+nLeftAndReightDis)+nLeftAndReightDis,pScrInnerHeight-(nSize+nUpAndDownDis)*t1-nSize)
        self._pDanRightScrollView:addChild(pItemBg)
        table.insert(self._tScrollViewItemArray,pItemBg)
    end
    -- self._pDanRightScrollView:setBounceEnabled(false) 设置不滑动

end


--加载境界盘上的信息
function FairyLandDialog:initFaryDishUi()

    local nHoles = TableFairyLand[self._tFairyLandInfo.dishInfo.level].Holes
    for i=1,table.getn(self._tFairyLandPillBg) do
        self._tFairyLandPillBg[i]:removeAllChildren(true)      --先移除所有子节点
        if i> nHoles then
            self._tFairyLandPillBg[i]:addChild(self:createFairyDishItemByInfo(nil,i))
        end
     
    end

    for k,v in pairs(self._tFairyLandInfo.dishInfo.pillList)do
        local pTempItemInfo =  GetCompleteItemInfoById(v,1)
        self._tFairyLandPillBg[pTempItemInfo.index]:addChild(self:createFairyDishItemByInfo(pTempItemInfo))
    end
end

--创建境界盘里面的单个控件
function FairyLandDialog:createFairyDishItemByInfo(pTempItemInfo,tPercent)

    local  onButtonTouchClicked = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("item Tag is "..sender:getTag())
            local nTag = sender:getTag()
            self:setLandSelectStateByTag(nTag)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
   
    local pPosition = cc.p(51,51)
    if not pTempItemInfo then --如果是空则说明是未解锁的
        local pString = {"一","一","二","三","四","五","六","六","七","七","八","八",}
    
        local pItemLable = cc.Label:createWithTTF("", strCommonFontName, 21)
        pItemLable:setString(pString[tPercent].."阶\n开启")
        pItemLable:setPosition(pPosition)
        return pItemLable
    end


    local pExpBarBg = cc.Sprite:createWithSpriteFrameName("FairyLandDialogRes/ExpLittleBg.png")
    pExpBarBg:setPosition(pPosition)

    local pExpSprite = cc.Sprite:createWithSpriteFrameName("FairyLandDialogRes/ExpLittle.png")
    local pExpBar = cc.ProgressTimer:create(pExpSprite)
    pExpBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    pExpBar:setMidpoint(cc.p(0.5,0.5))
    pExpBar:setBarChangeRate(cc.p(0,1))
    pExpBar:setScaleX(-1)
    pExpBar:setPercentage(100)
    pExpBar:setPosition(cc.p(pExpBarBg:getContentSize().width/2,pExpBarBg:getContentSize().height/2))
    pExpBarBg:addChild(pExpBar)


    --品质框
    local nQuality = pTempItemInfo.dataInfo.Quality
    local pQualityBg = ccui.ImageView:create()
    pQualityBg:setPosition(cc.p(pExpBarBg:getContentSize().width/2,pExpBarBg:getContentSize().height/2))
    pQualityBg:loadTexture("ccsComRes/qual_" ..nQuality.."_normal.png",ccui.TextureResType.plistType)
    pExpBarBg:addChild(pQualityBg,2)

    --境界盘的图标
    local pItemButton = ccui.Button:create(pTempItemInfo.templeteInfo.Icon..".png",pTempItemInfo.templeteInfo.Icon..".png",pTempItemInfo.templeteInfo.Icon..".png",ccui.TextureResType.plistType)
    pItemButton:addTouchEventListener(onButtonTouchClicked)
    pItemButton:setTouchEnabled(true)
    pItemButton:setTag(pTempItemInfo.index)
    pItemButton:setPosition(pQualityBg:getContentSize().width/2,pQualityBg:getContentSize().height/2)
    pQualityBg:addChild(pItemButton)

    --境界盘的等级
    local pItemLevel =  cc.Label:createWithTTF("", strCommonFontName, 21)
    pItemLevel:setPosition(cc.p(5,pItemButton:getContentSize().height))
    pItemLevel:setAdditionalKerning(-2)
    --pItemLevel:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    pItemLevel:setAnchorPoint(cc.p(0,1))
    pItemLevel:setColor(cWhite)
    pItemLevel:setString("Lv"..pTempItemInfo.level)
    pItemButton:addChild(pItemLevel)


    local pQuality = pTempItemInfo.dataInfo.Quality
    local ndenominator =  TableFairyLandDanLevel[pTempItemInfo.level]["Quality"..pQuality]
    --如果分母为零，则该宝石达到等级上限
    local nPercent = (ndenominator == 0) and 100 or math.modf((pTempItemInfo.exp/ndenominator)* 100)
    pExpBar:setPercentage(nPercent)
    if tPercent ~= nil and table.getn(tPercent) ~= 0 then
     pExpBar:setPercentage(tPercent[1][1])
     pItemLevel:setString("Lv"..tPercent[1][2])
     self:setLandExpBarPercent(pExpBar,pItemLevel,tPercent) 
    end
    
    return pExpBarBg

end

--设置境界丹的进度条
function FairyLandDialog:setLandExpBarPercent(pbar,plevel,nPercent)
    local nSize = table.getn(nPercent)
    for i=1,nSize do

        local callBack = function()
            plevel:setString("Lv"..nPercent[i][2])
            if i<nSize and nPercent[i+1][1] ~= nil and nPercent[i+1][2]-nPercent[i][2]>0 then --如果下一个action中境界丹升级了。需要先设置进度条为0
                pbar:setPercentage(0)
            end
        end
        pbar:runAction(cc.Sequence:create(cc.DelayTime:create(0.3*i), cc.ProgressTo:create(0.2, nPercent[i][1]),cc.CallFunc:create(callBack)))
    end
end


--加载境界盘下面的数据信息（境界界面的等级和进度条）
function FairyLandDialog:setFairyDishInfo()
    self._pFairyLandDanLvText:loadTexture("FairyLandDialogRes/level" ..self._tFairyLandInfo.dishInfo.level..".png",ccui.TextureResType.plistType)
   -- self._pFairyLandDanLvText:setString()
    --先多乘100 在乘0.01   保留真是数据0.01位
    local nDenominator = TableFairyLand[self._tFairyLandInfo.dishInfo.level].Exp
    local nPercent =  (nDenominator == 0) and 100 or math.modf((self._tFairyLandInfo.dishInfo.exp /nDenominator)*10000)/100
    if nPercent == 0 then
        self._pFairyLandDishBar:setPercentage(0)
    else
        self:setFairyLandDishBarPercent(nPercent)
    end
    --境界盘的进度条
    self._pFairyLandDishBarText:setString(nPercent.."%")           --境界盘上的文本 99%
    if nPercent == 100 and self._tFairyLandInfo.dishInfo.level < TableConstants.FairyLandMaxLevel.Value and self._bFirstLoad then
        --提示100%
        NoticeManager:getInstance():showSystemMessage("境界盘经验已满，请升级境界盘")
    end
    self._bFirstLoad = true
    --境界生阶丹
    local nRequiredDan = TableFairyLand[self._tFairyLandInfo.dishInfo.level].RequiredDan
    local nMolecule = BagCommonManager:getInstance():getItemNumById(nRequiredDan[1])
    self._pOwnDanNumText:setString(nMolecule)
    self._pNeedDanNumText:setString("/"..nRequiredDan[2])
    self._pOwnDanNumText:setColor(nMolecule >= nRequiredDan[2] and cWhite or cRed)

    --初始化境界点
    local pOwnBp = FinanceManager:getInstance()._tCurrency[kFinance.kBP]
    local pNeedPoint = TableFairyLand[self._tFairyLandInfo.dishInfo.level].RequiredPoint
    self._pOwnFairyLandDanNumText:setString(pOwnBp)
    self._pNeedFairyLandDanNumText:setString("/"..pNeedPoint)
    self._pOwnFairyLandDanNumText:setColor(pOwnBp >= pNeedPoint and cWhite or cRed)

end


-- 退出函数
function FairyLandDialog:onExitFairyLandDialog()
    self:onExitDialog()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("FairyLandDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("EquippingEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FairyLandPanLvupEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("ResolveEqiupEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames("FairyLandUnlock.plist")


end

--通过index查询境界盘某个位置是否有境界丹
function FairyLandDialog:getDishFairyLandHasDateByIndex(nIndex)
    for i,v in pairs(self._tFairyLandInfo.dishInfo.pillList) do
        if v.index == nIndex then
            return true ,i
        end
    end
    return false
end

--查询右侧ScrollView某个位置的境界丹信息通过index
function FairyLandDialog:getScrollViewHasDateByIndex(nIndex)
    for i,v in pairs(self._tFairyLandInfo.packagePillList) do
        if v.index == nIndex then
            return v
        end
    end
    return nil


end
--通过index删除数据
function FairyLandDialog:removeItemDateByIndex(tItemArryayDate,nIndex)
    for i=1,#tItemArryayDate do
        if nIndex == tItemArryayDate[i].index then
            table.remove(tItemArryayDate,i)
            return
        end

    end
end

--创建一个境界盘进度条 最下面的
function FairyLandDialog:createFairyLandDishBar()
    -- 进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName("FairyLandDialogRes/FairyLandExp.png")
    self._pFairyLandDishBar = cc.ProgressTimer:create(pSprite)
    self._pFairyLandDishBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pFairyLandDishBar:setMidpoint(cc.p(0, 0))
    self._pFairyLandDishBar:setBarChangeRate(cc.p(1, 0))
    self._pFairyLandDishBar:setPosition(cc.p(self._pFairyLandDanLvBg:getContentSize().width/2,self._pFairyLandDanLvBg:getContentSize().height/2))
    self._pFairyLandDishBar:setPercentage(0)
    self._pFairyLandDanLvBg:addChild(self._pFairyLandDishBar)
end

--设置境界盘的比例
function FairyLandDialog:setFairyLandDishBarPercent(nPercent)
    self._pFairyLandDishBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, nPercent)))
end

--吞噬境界丹的回调方法
function FairyLandDialog:setDevourFairyInfo(args)

    local pOldPillInfo = nil
    local pNewPillInfo = nil
    local tParcent = {}
    local nUiIndex = args.argsBody.dishIndex
    local nP, nIndex = self:getDishFairyLandHasDateByIndex(nUiIndex) --在数据的第几个
    pOldPillInfo = self._tFairyLandInfo.dishInfo.pillList[nIndex]
    local pQuality = pOldPillInfo.dataInfo.Quality
    

    if #args.dishInfo >0 then --如果境界丹升级了
        self._tFairyLandInfo.dishInfo = args.dishInfo[1]
           for k,v in pairs(self._tFairyLandInfo.dishInfo.pillList)do
             v = GetCompleteItemInfoById(v,1)
            end  
        pNewPillInfo =  args.dishInfo[1].pillList[nIndex]
    else
        local pPillInfo = GetCompleteItemInfoById(args.dishPillInfo,1)
        self._tFairyLandInfo.dishInfo.pillList[nIndex] = pPillInfo
        pNewPillInfo = pPillInfo
    end
    
    
    --百分比
    local nOldMaxExp =  TableFairyLandDanLevel[pOldPillInfo.level]["Quality"..pQuality]
    local nPercent = (nOldMaxExp == 0) and 100 or math.modf((pOldPillInfo.exp/nOldMaxExp)* 100)
    table.insert(tParcent,{nPercent,pOldPillInfo.level})

    for i=1,(pNewPillInfo.level-pOldPillInfo.level) do
        table.insert(tParcent,{100,pOldPillInfo.level+(i-1)})
    end

   
    local ndenominator =  TableFairyLandDanLevel[pNewPillInfo.level]["Quality"..pQuality]
    local nPercent = (ndenominator == 0) and 100 or math.modf((pNewPillInfo.exp/ndenominator)* 100)
    table.insert(tParcent,{nPercent,pNewPillInfo.level})


    --删除背景框上的所有子节点
    self._tFairyLandPillBg[nUiIndex]:removeAllChildren(true)
    self._tFairyLandPillBg[nUiIndex]:addChild(self:createFairyDishItemByInfo(pNewPillInfo,tParcent))
    self:setLandSelectStateByTag(nUiIndex)
end

--卸下或者初始化的时候默认的选择
function FairyLandDialog:setDefaultSelectState()
    local nIndex = nil 
    local pList = self._tFairyLandInfo.dishInfo.pillList
        if table.getn(pList) >0 then
        nIndex = pList[1].index
    end
    self:setLandSelectStateByTag(nIndex)
end



--通过tag设置境界丹的选中 详细信息的展示
function FairyLandDialog:setLandSelectStateByTag(nTag)
    if nTag == nil then
        self._pRotateSprite:setVisible(false)
        self._pTipsNode:setVisible(false)
        self._pRemindText:setVisible(true)
        self._nSelectTag = nil
        return 
    end
    self._pRotateSprite:setVisible(true)
    self._pTipsNode:setVisible(true)
    self._pRemindText:setVisible(false)
  local b1,nDateIndex = self:getDishFairyLandHasDateByIndex(nTag)
  local pInfo = self._tFairyLandInfo.dishInfo.pillList[nDateIndex] 
    if pInfo.dataInfo == nil then
  	return
  end
  
  --境界丹的名字
    if pInfo.dataInfo.Quality and pInfo.dataInfo.Quality ~= 0 then
        self._pLandName:setColor(kQualityFontColor3b[pInfo.dataInfo.Quality])
    end
    self._pLandName:setString(pInfo.templeteInfo.Name)
    
    --境界丹的属性
    local strAttrType = ""
    local strAttrNum = ""
    
    for i=1, #pInfo.dataInfo.Property do
        local ptempPro = pInfo.dataInfo.Property[i]                           --取出基础属性 {type ， 值}
        local pLevelUup = pInfo.dataInfo.LevelUp[i]
        local pDate = ptempPro[2]+pLevelUup*pInfo.level
        local pStr = pDate>0 and " +" or " "
        strAttrType = strAttrType..kAttributeNameTypeTitle[ptempPro[1]].."\n" --基础属性
        strAttrNum = strAttrNum..pStr..pDate.."\n"                            --升级的属性*级数
    end
    self._pAtrrType:setString(strAttrType)
    self._pAtrrNum:setString(strAttrNum)
    
    
    --提升的button
    local  onButtonTouchAttributeUp = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
          local nTag = sender:getTag()
            if self:getDishFairyLandHasDateByIndex(nTag) then
                FairyLandCGMessage:sendMessageDevourFairyPill20606(nTag)
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
     end
          
   
    self._pAttributeUp:addTouchEventListener(onButtonTouchAttributeUp)
    --self._pAttributeUp:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pAttributeUp:setZoomScale(nButtonZoomScale)
    self._pAttributeUp:setPressedActionEnabled(true)
    self._pAttributeUp:setTag(nTag)
    
   
    --卸下的button
    local  onButtonTouchUnsnatch = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            
            showConfirmDialog("您确定要卸下已镶嵌的境界丹？\n等级信息将不会保留，已吞噬的经验全部会添加至境界盘中。" , function()
                FairyLandCGMessage:sendMessageDropFairyPill20604(nTag) --确认卸下
            end)  
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
           
        end
    end
    self._pUnsnatch:addTouchEventListener(onButtonTouchUnsnatch)
    --self._pUnsnatch:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pUnsnatch:setZoomScale(nButtonZoomScale)
    self._pUnsnatch:setPressedActionEnabled(true)
    self._pUnsnatch:setTag(nTag)
    
    --设置旋转精灵
    local nX,nY = self._pRotateSprite:getPosition()
    local nRotation = mmo.HelpFunc:gAngleAnalyseForRotation(nX,nY, self._tFairyLandPillBgPos[nTag].x, self._tFairyLandPillBgPos[nTag].y)
    if self._nSelectTag == nil then --说明第一次点击，直接把图片旋转到指定位置就可以了
        self._pRotateSprite:setRotation(45-nRotation)
       self._nSelectTag = nTag
    else
        self._pRotateSprite:stopAllActions()
        --self._pRotateSprite:runAction(cc.Sequence:create(cc.Spawn:create(cc.EaseIn:create(cc.RotateTo:create(0.3,45-nRotation),6), cc.FadeIn:create(0.15))))
       self._pRotateSprite:runAction(cc.Sequence:create(cc.EaseIn:create(cc.RotateTo:create(0.3,45-nRotation),6)))
    end
    
    
end

-- 循环更新
function FairyLandDialog:update(dt)
    return
end

-- 显示结束时的回调
function FairyLandDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function FairyLandDialog:doWhenCloseOver()
    return
end

return FairyLandDialog
