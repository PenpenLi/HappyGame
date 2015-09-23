--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  EquipCallOut.lua
-- author:    wuquandong
-- created:   2014/12/29
-- descrip:   装备tips 对话框
--===================================================--===================================================
local EquipCallOutDialog = class("EquipCallOutDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function EquipCallOutDialog:ctor()
    self._strName = "EquipCallOutDialog"      -- 层名称
    self._pEquipInfoScrollView = nil          -- 物品的信息scrollview
    self._pButtonListView = nil               -- 按钮的容器
    self._pTabButton = nil                    -- 标签按钮  
    self._pItemInfo = nil                     -- 显示物品的信息
    self._pDressItemInfo = nil                -- 装备栏物品的信息
    self._tAction = {}                        -- 按钮的回调函数
    self._kCalloutSrcType = nil               -- 事件的来源(用来区分是否显示物品的对比)
    self._pDressEquipDialog = nil             -- 已装备物品的信息 
    self._isButtonListVisible = true          -- 按钮层是否可见
    self._pMainParams = nil                   -- 主容器配置文件
    self._pLeftParams = nil                   -- 左侧对比的配置文件
    self._tGemInlayPanelArry = nil            -- 镶嵌属性面板数组
    self._tScrollViewArry = {}                -- 属性滚动容器
    self._pInlayAttributeNone = nil           
    -- 战斗力
    self._moveToPoint = cc.p(0,13)
end

-- 创建函数
function EquipCallOutDialog:create(args)
    local dialog = EquipCallOutDialog.new()
     dialog:dispose(args)
    return dialog
end

-- 设置触摸屏蔽
function EquipCallOutDialog:handleTouchable(event)
    self:setTouchEnableInDialog(event[1])
end

-- 处理函数
function EquipCallOutDialog:dispose(args)   
    NetRespManager:getInstance():addEventListener(kNetCmd.kWorldLayerTouch,handler(self, self.handleTouchable))
    -- 需要缓存
    self:setNeedCache(true)
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
            return false
        end
        return true    --可以向下传递事件
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


    -- 加载装备tips合图资源
    ResPlistManager:getInstance():addSpriteFrames("ArrangeEqiupPanel.plist")
    -- 从背包中点击装备的回调集合
    self._tAction[kCalloutSrcType.kCalloutSrcBagCommon] = {
        DetailInfosCallbackCMD.kDetailCallbackWear,
        DetailInfosCallbackCMD.kDetailCallbackAnalysis,
        DetailInfosCallbackCMD.kDetailCallbackIntensify,
        DetailInfosCallbackCMD.kDetailCallbackMosaic,
        DetailInfosCallbackCMD.kDetailCallbackSuccinct,
       -- DetailInfosCallbackCMD.kDetailCallbackPass,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }
    -- 从装备栏（人物身上)点击的回调集合
    self._tAction[kCalloutSrcType.kCalloutSrcEquip] = {
        DetailInfosCallbackCMD.kDetailCallbackIntensify,
        DetailInfosCallbackCMD.kDetailCallbackMosaic,
    }
  
    -- 加载dialog组件
    self._pMainParams = require("ArrangeEquipPanelParams"):create()
    self._pCCS = self._pMainParams._pCCS
    self._pBg = self._pMainParams._pEquipTipsBg
    self._pCloseButton = self._pMainParams._pCloseButton
    self._pEquipInfoScrollView = self._pMainParams._pEquipInfoScrollView
    self._pButtonListView = self._pMainParams._pButtonListView
    -- 按钮容器默认不显示
    self:setButtonListVisible(false)
    self._pTabButton = self._pMainParams._pListButton
    self._pButtonListView:setItemModel(self._pTabButton)
    -- 右侧装备的状态默认不显示
    self._pMainParams._pEqiupStateText:setVisible(false)
    -- 初始化dialog的基础组件
    self:disposeCSB()
   
    -- 设置已装备物品的信息 
    self._pLeftParams =  require("ArrangeEquipPanelParams"):create()
    self._pDressEquipDialog = self._pLeftParams._pCCS
    self._pDressEquipDialog:setPositionY(self._pCCS:getPositionY())
    -- 装备栏功能按钮默认不显示
    self._pLeftParams._pButtonListView:setVisible(false)
    -- 装备栏战斗力提升图标不显示
    self._pLeftParams._pChangeIcon:setVisible(false)
    self:addChild(self._pDressEquipDialog)    
    -- 设置已装备物品关闭按钮的事件 
    local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           self._pDressEquipDialog:setVisible(false)
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end  
    self._pLeftParams._pCloseButton:addTouchEventListener(touchEvent)
    self._pLeftParams._pCloseButton:setZoomScale(nButtonZoomScale)
    self._pLeftParams._pCloseButton:setPressedActionEnabled(true)

    -- 上下移动动画效果
    local actionMoveBy = cc.MoveBy:create(0.3,self._moveToPoint)
    local actionMoveToBack = actionMoveBy:reverse()
    local seq1 = cc.Sequence:create(actionMoveBy, actionMoveToBack)
    self._pMainParams._pChangeIcon:stopAllActions()
    self._pMainParams._pChangeIcon:runAction(cc.RepeatForever:create(seq1))
    -- 根据物品信息初始化界面  
    self:setDataSource(args)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitEquipCallOutDialog()
        end
        if event == "enter" then
            self:onEneterEquipCallOutDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function EquipCallOutDialog:onExitEquipCallOutDialog()
    self:onExitDialog()   
    -- 释放掉login合图资源  
    ResPlistManager:getInstance():removeSpriteFrames("ArrangeEqiupPanel.plist")
    print(self._strName.." onExit!")
end

-- Node 进入stage 时
function  EquipCallOutDialog:onEneterEquipCallOutDialog()
    for k,pScrollView in pairs(self._tScrollViewArry) do
        pScrollView:jumpToTop()   
    end
end

-- 循环更新
function EquipCallOutDialog:update(dt)
    return
end

-- 显示结束时的回调
function EquipCallOutDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function EquipCallOutDialog:doWhenCloseOver()
    return
end  


-- 初始化界面的数据展示 
function EquipCallOutDialog:initUI()
    local sizeScrollview = self._pEquipInfoScrollView:getContentSize()
    self._pButtonListView:removeAllItems()
    -- 显示点击物品的tips
    local itemInfo = self._kCalloutSrcType == kCalloutSrcType.kCalloutSrcBagCommon and self._pItemInfo or self._pDressItemInfo
    self:updateEquipInfo(itemInfo,self._pMainParams)
    local sScreen = mmo.VisibleRect:getVisibleSize()
    -- 判断是否需要显示对比框
    if self._kCalloutSrcType ==  kCalloutSrcType.kCalloutSrcEquip 
        or ( not self._pDressItemInfo and self._kCalloutSrcType ==  kCalloutSrcType.kCalloutSrcBagCommon) 
        or self._kCalloutSrcType ==  kCalloutSrcType.KCalloutSrcTypeUnKnow 
       then
         self._pDressEquipDialog:setVisible(false)
         -- 向左偏移半个宽度
        self._pCCS:setPositionX(sScreen.width / 2)
        self._pDressEquipDialog:setPositionX(self._pCCS:getPositionX() - self._pBg:getContentSize().width)
    else
        self._pDressEquipDialog:setVisible(true)
        self:updateEquipInfo(self._pDressItemInfo,self._pLeftParams)
        self._pCCS:setPositionX(sScreen.width / 2 + self._pBg:getContentSize().width / 2)
        self._pDressEquipDialog:setPositionX(self._pCCS:getPositionX() - self._pBg:getContentSize().width)
    end
    -- 设置标签信息 
    local tempBtnArry = self._tAction[self._kCalloutSrcType]
    local function touchEvent(sender,eventType)
          if eventType == ccui.TouchEventType.ended then 
            local key = sender:getTag()
            for k,v in pairs(tempBtnArry) do
               if v.key == key then 
                    local itemInfo = self._kCalloutSrcType == kCalloutSrcType.kCalloutSrcBagCommon and self._pItemInfo or self._pDressItemInfo
                    v.callback(itemInfo,self._kCalloutSrcType)
                    --self:close()
                    break
               end
            end
          elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
         end
    end
    if tempBtnArry ~= nil then 
        for k,v in pairs(tempBtnArry) do
           if k == 1 then
            --self._pTabButton:setTitleText(v.name)
            self._pTabButton:setTitleFontSize(16)
            self._pTabButton:setTitleColor(cc.c3b(255,255,255))
            self._pTabButton:addTouchEventListener(touchEvent)
            self._pTabButton:setTag(v.key)
            --self._pTabButton:setZoomScale(nButtonZoomScale)
            --self._pTabButton:setPressedActionEnabled(true)
            self:setButtonListVisible(true)
            self._pTabButton:loadTextureNormal("ArrangeEqiupPanelRes/".. v.normalImg.. ".png",ccui.TextureResType.plistType)
            self._pTabButton:loadTexturePressed("ArrangeEqiupPanelRes/".. v.selectedImg.. ".png",ccui.TextureResType.plistType)
            self._pButtonListView:addChild(self._pTabButton)
          end
           if k > 1 then
             local pUseMultiItemBtn = self._pTabButton:clone()
             pUseMultiItemBtn:setTag(v.key)
             
             pUseMultiItemBtn:loadTextureNormal("ArrangeEqiupPanelRes/".. v.normalImg.. ".png",ccui.TextureResType.plistType)
             pUseMultiItemBtn:loadTexturePressed("ArrangeEqiupPanelRes/".. v.selectedImg.. ".png",ccui.TextureResType.plistType)
             --pUseMultiItemBtn:setTitleText(v.name)
             self._pButtonListView:addChild(pUseMultiItemBtn)
           end
      end
    end
end

--更新物品展示信息
function EquipCallOutDialog:updateEquipInfo(pItemInfo,params)   
    -- 根据品质设置物品名字字体的颜色
    if pItemInfo.dataInfo.Quality and pItemInfo.dataInfo.Quality ~= 0 then
        params._pEqiupNameText:setColor(kQualityFontColor3b[pItemInfo.dataInfo.Quality])
    end
    -- 设置装备的名字
    params._pEqiupNameText:setString(pItemInfo.templeteInfo.Name)
    -- 设置装备的强化等级
    local strAdvanceLv = pItemInfo.value > 0 and "(+"  ..pItemInfo.value..")" or " "    
    params._pAdvanceLvText:setString(strAdvanceLv)
    -- 设置装备的位置类型
    params._pEquipType:setString("类型: "..kEquipPositionTypeTitle[pItemInfo.dataInfo.Part])
    -- 设置装备的等级 
    params._pEquipLv:setString("等级："..pItemInfo.dataInfo.RequiredLevel)

    if RolesManager:getInstance()._pMainRoleInfo.level < pItemInfo.dataInfo.RequiredLevel then
        params._pEquipLv:setColor(cRed)
    else
        params._pEquipLv:setColor(cWhite)
    end
    -- 设置装备的图标 
    params._pEquipIcon:loadTexture(pItemInfo.templeteInfo.Icon ..".png", ccui.TextureResType.plistType)
    -- 设置装备图标的边框
    params._pEquipIconFrame:loadTexture("ccsComRes/qual_"..pItemInfo.dataInfo.Quality.."_normal.png",ccui.TextureResType.plistType)
    -- 设置装备的战斗力 
    params._pEffectiveBitmapFont:setString(pItemInfo.equipment[1].fightingPower)
    -- 设置装备的升降图标的可见性
    if self._kCalloutSrcType == kCalloutSrcType.kCalloutSrcEquip 
        or self._pDressItemInfo == nil and self._kCalloutSrcType ==  kCalloutSrcType.kCalloutSrcBagCommon 
        or self._kCalloutSrcType ==  kCalloutSrcType.KCalloutSrcTypeUnKnow 
        or self._pItemInfo.equipment[1].fightingPower == self._pDressItemInfo.equipment[1].fightingPower then
        params._pChangeIcon:setVisible(false)
    else
        self._pMainParams._pChangeIcon:setVisible(true)
    end
    -- 设置装备战斗力升降图标的样式
    if self._pItemInfo ~= nil and self._pDressItemInfo ~= nil then
        if self._pItemInfo.equipment[1].fightingPower > self._pDressItemInfo.equipment[1].fightingPower then
            params._pChangeIcon:loadTexture("ArrangeEqiupPanelRes/EquipUp.png",ccui.TextureResType.plistType)
        else
            params._pChangeIcon:loadTexture("ArrangeEqiupPanelRes/EqiupDown.png",ccui.TextureResType.plistType)
        end
    end
    if self._pDressItemInfo == nil and self._kCalloutSrcType ==  kCalloutSrcType.kCalloutSrcBagCommon then
        params._pChangeIcon:loadTexture("ArrangeEqiupPanelRes/EquipUp.png",ccui.TextureResType.plistType)
        self._pMainParams._pChangeIcon:setVisible(true)
    end
     -- 装备强化值(当前强化等级 * 升级系数)
    local attrUpNum =  pItemInfo.value * pItemInfo.dataInfo.IntensifyPreTime
    -- 设置装备的主属性的值
    local msg = getStrAttributeRealValue(pItemInfo.equipment[1].majorAttr.attrType,pItemInfo.equipment[1].majorAttr.attrValue - attrUpNum)
    params._pAttributeText:setString(msg)
    if attrUpNum > 0 then 
        params._pAttributeUpText:setString("(+"..attrUpNum.. ")")
    else
         params._pAttributeUpText:setString("")
    end
    -- 装备的属性显示容器 
    local pListView = params._pEquipInfoScrollView
    table.insert(self._tScrollViewArry,pListView)
    -- 设置附加属性的值
    local strMinorAttrMsg = ""
    for k,v in pairs(pItemInfo.equipment[1].minorAttr) do
       strMinorAttrMsg = strMinorAttrMsg.. getStrAttributeRealValue(v.attrType,v.attrValue).."\n"
    end
    params._pAddAttributeText:setVisible(false)
    -- 测试label 行间距
    if not params._pAddAttributeLbl then
        params._pAddAttributeLbl = cc.Label:createWithTTF(strMinorAttrMsg, strCommonFontName, 18)
        params._pAddAttributeLbl:setLineHeight(24)
        params._pAddAttributeLbl:setAdditionalKerning(2)
        params._pAddAttributeLbl:setColor(cGreen)
        params._pAddAttributeLbl:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        params._pAddAttributeLbl:setPositionX(params._pAddAttributeText:getPositionX())
        params._pAddAttributeLbl:setAnchorPoint(0,1)
        pListView:addChild(params._pAddAttributeLbl)
    else
        params._pAddAttributeLbl:setString(strMinorAttrMsg)
        params._pAddAttributeLbl:setColor(cGreen)
    end
    if strMinorAttrMsg == "" then
        params._pAddAttributeLbl:setString("无")
        params._pAddAttributeLbl:setColor(cRed)
    end
    -- 装备的镶嵌属性
    params._pInlayAttributePanel:getChildByName("InlayAttributeText"):setColor(cWhite)
    -- 装备可镶嵌的宝石数量
    local inlaidHoleNum = pItemInfo.dataInfo.InlaidHole 
    -- 重置镶嵌属性的信息
    if params._tGemInlayPanelArry then
        for k,v in pairs(params._tGemInlayPanelArry) do
            v:removeFromParent(false)   
        end
    end
    -- 镶嵌属性面板数组
    params._tGemInlayPanelArry = {}
    for i = 1,inlaidHoleNum do
        local pGemInfoPanel = params._pInlayAttributePanel:clone()
        pGemInfoPanel:setVisible(true)
        table.insert(params._tGemInlayPanelArry,pGemInfoPanel)
        pListView:addChild(pGemInfoPanel)
    end
    -- 当前已镶嵌宝石信息
    local tGemInfoArry = pItemInfo.equipment[1].stones
    local pGemItemInfo = nil 
    if tGemInfoArry then
        for index,gemId in pairs(tGemInfoArry) do
            --根据宝石Id 获得宝石的详细信息
            pGemItemInfo = BagCommonManager:getInstance():getItemRealInfo(gemId,kItemType.kStone)
            -- 宝石的图标
            local pGemIconImg = params._tGemInlayPanelArry[index]:getChildByName("InlayIcon")
            -- 宝石属性标签
            local pGemInfoText = params._tGemInlayPanelArry[index]:getChildByName("InlayAttributeText")
            if pGemIconImg ~= nil then
                pGemIconImg:loadTexture(pGemItemInfo.templeteInfo.Icon..".png", ccui.TextureResType.plistType)
            end
            -- 设置宝石的属性信息 
            local msg = "" 
            for k,property in pairs(pGemItemInfo.dataInfo.Property) do
                -- 属性的名称
                msg = msg..getStrAttributeRealValue(property[1],property[2])
            end
            if pGemInfoText ~= nil then
                pGemInfoText:setString(msg)
                pGemInfoText:setColor(kQualityFontColor3b[pGemItemInfo.dataInfo.Quality])
            end
            -- 动态更新panel 的高度
            local nMaxHeight = math.max(pGemIconImg:getContentSize().height * pGemIconImg:getScaleY(),pGemInfoText:getContentSize().height)
            params._tGemInlayPanelArry[index]:setContentSize(cc.size(params._tGemInlayPanelArry[index]:getContentSize().width,nMaxHeight))
        end
    end
    -- 计算镶嵌宝石面板的总高度
    local nGemInlayPanelHeight = 0
    for k,v in pairs(params._tGemInlayPanelArry) do
        nGemInlayPanelHeight = nGemInlayPanelHeight + v:getContentSize().height
    end
    params._pInlayAttributePanel:setVisible(false)
    -- 计算滚动框的总高度
    local innerWidth = pListView:getContentSize().width
    local innerHeight = 0
    innerHeight = innerHeight + params._pTextFrameBg1:getContentSize().height
                  + params._pAddAttributeLbl:getContentSize().height
                  + params._pTextFrameBg2:getContentSize().height
                  + nGemInlayPanelHeight +70
    --设置内部实际大小，必须大于等于size  
    --此处设置实际的滚动范围就是图片的大小                  
    innerHeight =  math.max(innerHeight,pListView:getContentSize().height)
    pListView:setInnerContainerSize(cc.size(innerWidth, innerHeight))   
    -- 更新各个标签的位置
    params._pTextFrameBg1:setPositionY(innerHeight)
    params._pAddAttributeLbl:setPositionY(params._pTextFrameBg1:getBottomBoundary() - 10)
    params._pTextFrameBg2:setPositionY(params._pAddAttributeLbl:getPositionY() - params._pAddAttributeLbl:getContentSize().height - 10)
    -- 如果没有宝石空提示无
    if inlaidHoleNum <= 0 then 
        params._pInlayAttributeNone:setVisible(true)
        params._pInlayAttributeNone:setPositionY(params._pTextFrameBg2:getBottomBoundary() - 20)
        params._pInlayAttributeNone:setColor(cRed)
    else
        params._pInlayAttributeNone:setVisible(false)
    end
    if params._tGemInlayPanelArry[1] then
        params._tGemInlayPanelArry[1]:setPositionY(params._pTextFrameBg2:getBottomBoundary() - 10)
    end
    for k,v in pairs(params._tGemInlayPanelArry) do
        if k ~= 1 then
            v:setPositionY(params._tGemInlayPanelArry[k-1]:getBottomBoundary() - 10)
        end
    end
    -- 设置装备出售的价格 
    params._pSaleTextNum:setString(pItemInfo.dataInfo.Price)
end

-- 设置功能按钮是否可见 
function EquipCallOutDialog:setButtonListVisible(isVisible)
    if self._isButtonListVisible == true then
        self._pButtonListView:setVisible(isVisible)
    else
        self._pButtonListView:setVisible(false)
    end
end 

-- 设置界面显示需要的数据
function EquipCallOutDialog:setDataSource(args)
    self._pItemInfo = args[1]
    self._pDressItemInfo = args[2]
    -- 如果事件源参数为空则默认为背包类型
    if not args[3] then
        self._kCalloutSrcType = kCalloutSrcType.kCalloutSrcBagCommon
    else
        self._kCalloutSrcType = args[3]
    end
    if args[4] ~= nil then
        self._isButtonListVisible = args[4]
    end
    -- 更新界面显示
    self:initUI()

    for k,pScrollView in pairs(self._tScrollViewArry) do
        pScrollView:jumpToTop()   
    end

    self._pButtonListView:refreshView()
end

-- 更新缓存数据
function EquipCallOutDialog:updateCacheWithData(args)
    self:setDataSource(args)
end

return EquipCallOutDialog
