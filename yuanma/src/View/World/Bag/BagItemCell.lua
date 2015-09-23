--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BagItemCell.lua
-- author:    liyuhang
-- created:   2014/12/16
-- descrip:   背包格子
--===================================================



local BagItemCell = class("BagItemCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function BagItemCell:ctor()
    self._strName = "BagItemCell"        -- 层名称
    self._pBg = nil                --背景
    self._pIconBtn = nil
    self._pUpTipSpr = nil
    self._pGemCanSynsisAniNode = nil
    self._pGemCanSynsisAni = nil
    self._pNameLbl = nil
    self._pItemInfo = nil
    self._nIndex = 0
    self._kCalloutSrcType = nil
    self._pEquipQualityBg = nil
    -- 弹出层需要可选的参数
    self._tCalloutArgs = {} 
    
    --选中特效
    self._pSelectedAni = nil
    -- 战斗力
    self._moveToPoint = cc.p(0,13)
    
    self._bBeEccedMax = false
    self._pTempButtonTexture = nil
    self._pTempEquQuaBgTexture = nil
    
    self._bTouchAble = true
end 

-- 创建函数
function BagItemCell:create(srcType,ars)
    local layer = BagItemCell.new()
    layer:dispose(srcType)
    return layer
end

-- cell选中
function BagItemCell:selectedCellAction(event)
    if event.cell == nil then
        self:setSelected(false)
        return
    end
    
    if self._pItemInfo == nil then
        self:setSelected(false)
    	return
    end

    if  event.cell.baseType  == self._pItemInfo.baseType and
        event.cell.id        == self._pItemInfo.id and
        event.cell.value     == self._pItemInfo.value and
        event.cell.position  == self._pItemInfo.position and
        event.cell.equipment == self._pItemInfo.equipment 
     then
        self:setSelected(true)
    else
        self:setSelected(false)
    end
end

-- 设置触摸屏蔽
function BagItemCell:handleTouchable(event)
    if event[1] == true then
        self._bTouchAble = false
    else
        self._bTouchAble = true
    end
end

-- 处理函数
function BagItemCell:dispose(srcType,args) 

    NetRespManager:getInstance():addEventListener(kNetCmd.kWorldLayerTouch,handler(self, self.handleTouchable))
    -- 加载资源
    ResPlistManager:getInstance():addSpriteFrames("BagPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("BagIconEffect.plist")
    --传入点击详情的回调组
    self._kCalloutSrcType = srcType
    --背景框
    self._pBg = ccui.ImageView:create("BagPanelRes/BagItem.png",ccui.TextureResType.plistType)
    self._pBg:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pBg,-1)
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            
            if self._bTouchAble == false then
            	return
            end
        
            if NewbieManager._pCurNewbieLayer ~= nil then
                print("NewbieManager._pCurNewbieLayer _bEatTouch is "..tostring(NewbieManager._pCurNewbieLayer._bEatTouch)) 
                local pos = NewbieManager._pCurNewbieLayer:getContentSize()
                
            end
        
            local isShowTips = true
            if self._pSelectedAni ~= nil and self._pSelectedAni:isVisible() == true then 
                isShowTips = false
            end 
            NetRespManager:getInstance():dispatchEvent(kNetCmd.kBagSelectedCell, {cell = self._pItemInfo})
            -- 如果物品类型是装备
            if self._pItemInfo.baseType == kItemType.kEquip then
                -- 物品在背包中的数据信息
                local pBagItemInfo = self._kCalloutSrcType == kCalloutSrcType.kCalloutSrcBagCommon and self._pItemInfo or nil
                -- 角色身上穿戴的物品信息
                local pDressItemInfo = nil 
                if  self._kCalloutSrcType == kCalloutSrcType.kCalloutSrcBagCommon then
                  if RolesManager:getInstance():selectHasEquipmentByType(self._pItemInfo.dataInfo.Part) ~= nil then
                        pDressItemInfo = RolesManager:getInstance():selectHasEquipmentByType(self._pItemInfo.dataInfo.Part)
                  end 
                else
                    pDressItemInfo = self._pItemInfo
                end
                if DialogManager:getInstance():getDialogByName("EquipCallOutDialog") ~= nil then
                    isShowTips = DialogManager:getInstance():getDialogByName("EquipCallOutDialog"):isVisible() == false and true or isShowTips
                else
                    isShowTips = true
                end
                if isShowTips == true then
                    DialogManager:getInstance():showDialog("EquipCallOutDialog",{pBagItemInfo,pDressItemInfo,self._kCalloutSrcType,true})
                    DialogManager:getInstance():closeDialogByName("BagCallOutDialog")
                end
            else
                if DialogManager:getInstance():getDialogByName("BagCallOutDialog") ~= nil then
                    isShowTips = DialogManager:getInstance():getDialogByName("BagCallOutDialog"):isVisible() == false and true or isShowTips
                else
                    isShowTips = true
                end
                if isShowTips == true then
                    DialogManager:getInstance():showDialog("BagCallOutDialog",{self._pItemInfo,self._kCalloutSrcType,self._tCalloutArgs,true})
                    DialogManager:getInstance():closeDialogByName("EquipCallOutDialog")
                end
            end
            NewbieManager:showOutAndRemoveWithRunTime()
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            if self._bBeEccedMax == true then
                redNode(self._pIconBtn:getVirtualRenderer():getSprite())
            end
        end
    end

    self._pIconBtn = nil
    self._pIconBtn = ccui.Button:create(
        "BagPanelRes/BagItem.png",
        "BagPanelRes/BagItem.png",
        "BagPanelRes/BagItem.png",
        ccui.TextureResType.plistType)
    self._pIconBtn:setTouchEnabled(true)
    self._pIconBtn:setPosition(0,0)
    self._pIconBtn:setAnchorPoint(cc.p(0, 0))
    self:addChild(self._pIconBtn)
    self._pIconBtn:addTouchEventListener(onTouchButton)
    self._pIconBtn:setVisible(false)
    
    self._pUpTipSpr =  nil
    self._pUpTipSpr = cc.Sprite:createWithSpriteFrameName("BagPanelRes/BagEqiupUpIcon.png")
    self._pUpTipSpr:setPosition(10,50)
    self._pUpTipSpr:setVisible(false)
    self._pUpTipSpr:setAnchorPoint(cc.p(0, 0))
    self:addChild(self._pUpTipSpr)
    
    -- 上下移动动画效果
    local actionMoveBy = cc.MoveBy:create(0.3,self._moveToPoint)
    local actionMoveToBack = actionMoveBy:reverse()
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pUpTipSpr:stopAllActions()
    self._pUpTipSpr:runAction(cc.RepeatForever:create(seq1))

    self._pNewItemSpr =  nil
    self._pNewItemSpr = cc.Sprite:createWithSpriteFrameName("BagPanelRes/BagEqiupUpIcon.png")
    self._pNewItemSpr:setPosition(20,20)
    self._pNewItemSpr:setVisible(false)
    self._pNewItemSpr:setAnchorPoint(cc.p(0, 0))
    
    self:addChild(self._pNewItemSpr)
    
    self._pNameLbllbl = cc.Label:createWithTTF("", strCommonFontName, 21)
    self._pNameLbllbl:setLineHeight(20)
    self._pNameLbllbl:setAdditionalKerning(-2)
    self._pNameLbllbl:setTextColor(cc.c4b(255, 255, 255, 255))
    self._pNameLbllbl:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    self._pNameLbllbl:setPositionX(0)
    self._pNameLbllbl:setPositionY(36)
    self._pNameLbllbl:setWidth(85)
    self._pNameLbllbl:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    --self._pNameLbllbl:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
    self._pNameLbllbl:setAnchorPoint(0,1)
    self:addChild(self._pNameLbllbl)

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()    
        
        
        return false   --可以向下传递事件
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
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        
        if event == "exit" then
            self:onExitBagItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--注册点击回调
function BagItemCell:registerTouchEvent(func)
    if func ~= nil then
        self._pIconBtn:addTouchEventListener(onTouchButton)
    end
end

-- 设置bag内选中特效开启
function BagItemCell:openSelectedState()
    NetRespManager:getInstance():addEventListener(kNetCmd.kBagSelectedCell,handler(self, self.selectedCellAction))
end

-- 重载背景
function BagItemCell:loadBgWithFilename(filename ,textureType )
    if not textureType then
    textureType = ccui.TextureResType.plistType
    end
    self._pBg:loadTexture(filename,textureType)
end

function BagItemCell:setItemInfo(info)
    if not info then
        self._pItemInfo = nil
        self._pUpTipSpr:setVisible(false)
        self._pIconBtn:setVisible(false)
        self._pNameLbllbl:setString("")
        self:setSelected(false)
        if self._pEquipQualityBg then
            self._pEquipQualityBg:setVisible(false)
        end
        if self._pEquipIntenLevel then
            self._pEquipIntenLevel:setVisible(false)
        end
        return
    end
    
    --重置-------------------------
    self._pUpTipSpr:setVisible(false)
    self._pIconBtn:setVisible(false)
    self._pNameLbllbl:setString("")
    self:setSelected(false)
    if self._pEquipQualityBg then
        self._pEquipQualityBg:setVisible(false)
      
    end
    if self._pEquipIntenLevel then
       self._pEquipIntenLevel:setVisible(false)
    end
    ------------------------------
    
  --  print_lua_table(info)
    self._pItemInfo = info
    self._pIconBtn:setVisible(true)
    local ptempIcon = self._pItemInfo.templeteInfo.Icon
    if self._pTempButtonTexture ~= ptempIcon then
        self._pTempButtonTexture = ptempIcon
        self._pIconBtn:loadTextures( ptempIcon..".png",ptempIcon..".png",ptempIcon..".png",ccui.TextureResType.plistType)
    end

    if self._pItemInfo.baseType == kItemType.kEquip or self._pItemInfo.baseType == kItemType.kStone then  --只有装备不可叠加
        --self._pNameLbllbl:setString("lv " ..self._pItemInfo.value)
        self._pNameLbllbl:setString("")
        
        
    else
        self._pNameLbllbl:setString(self._pItemInfo.value)
    end
    if self._pItemInfo.baseType == kItemType.kStone then
        -- 宝石只显示数字
        self._pNameLbllbl:setString(self._pItemInfo.value) 
    end
    
    if self._pItemInfo.dataInfo.Quality ~= nil and self._pItemInfo.dataInfo.Quality ~= 0 then
        if self._pEquipQualityBg == nil then
            self._pEquipQualityBg = ccui.ImageView:create("ccsComRes/qual_1_normal.png",ccui.TextureResType.plistType)
            self._pEquipQualityBg:setAnchorPoint(cc.p(0,0))
            self._pBg:addChild(self._pEquipQualityBg)
        end
        
        local nEquipQuality = self._pItemInfo.dataInfo.Quality
        
        if self._pTempEquQuaBgTexture ~= nEquipQuality then
           self._pTempEquQuaBgTexture = nEquipQuality
           self._pEquipQualityBg:loadTexture("ccsComRes/qual_" ..nEquipQuality.."_normal.png",ccui.TextureResType.plistType)
        end
        

        self._pEquipQualityBg:setVisible(true)
    end
    
    --装备强化等级
    if self._pItemInfo.baseType == kItemType.kEquip then 
        if self._pEquipIntenLevel == nil then --如果强化的lable不存在
            self._pEquipIntenLevel = ccui.TextBMFont:create()
            self._pEquipIntenLevel:setFntFile("fnt_add_blood.fnt")
            self._pEquipIntenLevel:setScale(0.35)
            self._pEquipIntenLevel:setAnchorPoint(cc.p(0.5, 1)) 
            self._pEquipIntenLevel:setPosition(cc.p( self._pEquipQualityBg:getContentSize().width-30,self._pEquipQualityBg:getContentSize().height))
            self:addChild(self._pEquipIntenLevel)
        end
        self._pEquipIntenLevel:setString("")
        if self._pItemInfo.value ~= 0 and self._pItemInfo.value ~= nil then 
           self._pEquipIntenLevel:setString("+"..self._pItemInfo.value)
        end
        
        self._pEquipIntenLevel:setVisible(true)
    end
    
    
    --装备的战斗力上升提示。只有在背包里面才显示 and self._kCalloutSrcType == kCalloutSrcType.kCalloutSrcBagCommon
    if self._pItemInfo.baseType == kItemType.kEquip then
        local tempInfo = RolesManager:getInstance():selectHasEquipmentByType(self._pItemInfo.dataInfo.Part)
        if tempInfo ~= nil and self._pItemInfo.equipment ~= nil then
          if tempInfo.equipment[1].fightingPower < self._pItemInfo.equipment[1].fightingPower then
              self._pUpTipSpr:setVisible(true)
          else
              self._pUpTipSpr:setVisible(false)
          end
        end
        if tempInfo == nil and self._pItemInfo.equipment ~= nil then
            self._pUpTipSpr:setVisible(true)
        end
    end
end

function BagItemCell:setUpTipShow()
    self._pUpTipSpr:setVisible(true)
end

function BagItemCell:setIndex(index)
    self._nIndex = index

    self._pNameLbllbl:setString(tostring(self._nIndex))
end

-- 设置ItemCell 是否可以点击
function BagItemCell:setTouchEnabled(isEnable)
    self._pIconBtn:setTouchEnabled(isEnable)
end

-- 设置ItemCell 点击来源
function BagItemCell:setCalloutSrcType(ksrcType)
    self._kCalloutSrcType = ksrcType
end

-- 设置ItemCell 弹出成需要可选的参数
function BagItemCell:setCalloutArgs (tArgs)
    self._tCalloutArgs = tArgs
end

-- 设置数量标签是否可以显示
function BagItemCell:setNameLabelVisible(isVisible)
    self._pNameLbllbl:setVisible(isVisible)
end

-- 设置选中特效
function BagItemCell:setSelected(beSelected)    
    if beSelected == true then
        if self._pSelectedAni == nil then
            self._pSelectedAni = cc.CSLoader:createNode("BagIconEffect.csb")
           local pSelectedAniTimeLine = cc.CSLoader:createTimeline("BagIconEffect.csb")
            self._pSelectedAni:setPosition(cc.p(52,53))
            self:addChild(self._pSelectedAni,-1)
            pSelectedAniTimeLine:gotoFrameAndPlay(0, pSelectedAniTimeLine:getDuration(), true)
            self._pSelectedAni:runAction(pSelectedAniTimeLine)
        else
            self._pSelectedAni:setVisible(true)
        end
        
    else
        if self._pSelectedAni ~= nil then
            self._pSelectedAni:setVisible(false)
        end
        
    end
end

function BagItemCell:setExceedMax()
    self._bBeEccedMax = true
    redNode(self._pIconBtn:getVirtualRenderer():getSprite())
end

-- 退出函数
function BagItemCell:onExitBagItem()
    --self:onExitLayer()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("BagPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BagIconEffect.plist")
end

-- 循环更新
function BagItemCell:update(dt)
    return
end

function BagItemCell:setEquipDefIconByPart(nPart)
    local pIcon = "equip_icon/Equip"..nPart..".png"
    self._pIconBtn:setVisible(true)
    self._pIconBtn:loadTextures( pIcon,pIcon,pIcon,ccui.TextureResType.plistType)
end

-- 显示结束时的回调
function BagItemCell:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BagItemCell:doWhenCloseOver()
    return
end

return BagItemCell
