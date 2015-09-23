--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BagCallOutDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2014/12/22
-- descrip:   物品详情对话框
--===================================================
local BagCallOutDialog = class("BagCallOutDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function BagCallOutDialog:ctor()
    self._strName = "BagCallOutDialog"        -- 层名称
    self._pTextListView = nil                 -- 物品的信息scrollview
    self._pButtonListView = nil               -- 按钮的容器
    self._pTabButton = nil                    -- 标签按钮  
    self._pItemInfo = nil                     -- 显示物品的信息
    self._tAction = {}                        -- 按钮的回调函数
    self._pTextListView = nil                 -- 物品的说明滚动框
    self._pItemName = nil                     -- 物品的名字
    self._pNeedLevelTitle = nil               -- 需要等级的标题
    self._pNeedLevelValue = nil               -- 需要等级的值
    self._pGemAttrTitle = nil                 -- 宝石属性的标题
    self._pGemAttrValue = nil                 -- 宝石属性的值
    self._pSaleNumText = nil                  -- 物品的出售价格标题
    self._pSaleNumValue = nil                 -- 物品的出售价格值
    self._kSrcType = nil                      -- 弹出框的事件来源
    self._tArgs = {}                          -- 弹出层可选的参数
    self._isButtonListVisible = true          -- 按钮层是否可见
    self._pInfBg = nil                        -- 说明标题底板
    self._pTextIntroText  = nil               -- 物品的简介说明
    self._pLinkBg = nil                       -- 物品获取途径的说明底板
    self._pLinkText = nil                     -- 获得路径说明文字
    
    self._pLinkScrollview = nil
    self._pListController = nil
end

-- 创建函数
function BagCallOutDialog:create(args)
    local dialog = BagCallOutDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 设置触摸屏蔽
function BagCallOutDialog:handleTouchable(event)
    self:setTouchEnableInDialog(event[1])
end

-- 处理函数
function BagCallOutDialog:dispose(args)  
    NetRespManager:getInstance():addEventListener(kNetCmd.kWorldLayerTouch,handler(self, self.handleTouchable))
    -- 加载装备tips合图资源
    ResPlistManager:getInstance():addSpriteFrames("ArrangeItemPanel.plist")
    
    
    -- 需要缓存
    self:setNeedCache(true)
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
            return false
        end
        return true   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)


    -- 从背包点击的回调集合
    self._tAction[kCalloutSrcType.kCalloutSrcBagCommon] = {}
    -- 从装备栏（人物身上)点击的回调集合
    self._tAction[kCalloutSrcType.kCalloutSrcEquip] = {}
     -- 背包上的装备
    self._tAction[kCalloutSrcType.kCalloutSrcBagEquipGem] = {}
     -- 身上的装备  
    self._tAction[kCalloutSrcType.kCalloutSrcRoleEquipGem] = {}
    -- 宝石镶嵌界面
    self._tAction[kCalloutSrcType.kCalloutSrcGemSysMosaic] = {}
    -- 从背包中点击的物品为宝石
    self._tAction[kCalloutSrcType.kCalloutSrcBagCommon][kItemType.kStone] = {
        DetailInfosCallbackCMD.kDetailCallbackMosaic,
        DetailInfosCallbackCMD.kDetailCallbackGemSynthesis,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,      
    }
    -- 从背包中点击的物品为补给类
     self._tAction[kCalloutSrcType.kCalloutSrcBagCommon][kItemType.kFeed] = {
        DetailInfosCallbackCMD.kDetailCallbackItemUse,
        DetailInfosCallbackCMD.kDetailCallbackItemBatchUse,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }
    -- 从背包中点击的物品为宝箱美人图
    self._tAction[kCalloutSrcType.kCalloutSrcBagCommon][kItemType.kBox] = {
        DetailInfosCallbackCMD.kDetailCallbackItemUse,
        DetailInfosCallbackCMD.kDetailCallbackItemBatchUse,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }
    -- 从背包中点击的物品为计数类（材料）
    self._tAction[kCalloutSrcType.kCalloutSrcBagCommon][kItemType.kCounter] = {
        --等做到相应的系统再添加
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }
    -- 背包装备上的宝石
    self._tAction[kCalloutSrcType.kCalloutSrcBagEquipGem][kItemType.kStone] = {
        DetailInfosCallbackCMD.kDetailCallbackGemDisboard,
        DetailInfosCallbackCMD.kDetailCallbackGemSynthesis,
    }
    -- 身上装备上的宝石
    self._tAction[kCalloutSrcType.kCalloutSrcRoleEquipGem][kItemType.kStone] = {
        DetailInfosCallbackCMD.kDetailCallbackGemDisboard,
        DetailInfosCallbackCMD.kDetailCallbackGemSynthesis,
    }
    -- 装备镶嵌界面宝石
    self._tAction[kCalloutSrcType.kCalloutSrcGemSysMosaic][kItemType.kStone] = {
        DetailInfosCallbackCMD.kDetailCallbackGemSysMosaic,
    }

    -- 如果点击背包中的剑灵丹
    self._tSpecialAction = {}
    self._tSpecialAction[kItemUseType.kBladeSoul] = {
        DetailInfosCallbackCMD.kDetailCallbackSuccinct,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }
    --  如果点击背包中的装备碎片
    self._tSpecialAction[kItemUseType.kEquipPieces] = {
        DetailInfosCallbackCMD.kDetailCallbackItemForge,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }
    -- 如果点击背包中的图谱
    self._tSpecialAction[kItemUseType.kEquipTree] = {
        DetailInfosCallbackCMD.kDetailCallbackItemForge,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }

    -- 如果点击背包中的宠物食材
    self._tSpecialAction[kItemUseType.kPetFood] = {
        DetailInfosCallbackCMD.kDetailCallbackItemUse,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }

    -- 如果点击背包中的好友礼物
    self._tSpecialAction[kItemUseType.kFriendGift] = {
        DetailInfosCallbackCMD.kDetailCallbackItemUse,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }    
    
    -- 如果点击背包中的丹
    self._tSpecialAction[kItemUseType.kExpPill] = {
        DetailInfosCallbackCMD.kDetailCallbackItemUse,
        DetailInfosCallbackCMD.kDetailCallbackItemSell,
    }
    
    -- 加载dialog组件
    local params = require("ArrageItemPanelParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pItemFrame
    self._pCloseButton = params._pCloseButton
    self._pTextListView = params._pTextListView
    self._pItemName = params._pItemName
    self._pNeedLevelTitle = params._pNeedLevelTitle
    self._pNeedLevelTitle:setVisible(false)
    self._pNeedLevelValue = params._pNeedLevelValue
    self._pNeedLevelValue:setVisible(false)
    self._pGemAttrTitle = params._pGemAttrTitle
    self._pGemAttrTitle:setVisible(false)
    self._pGemAttrValue = params._pGemAttrValue
    self._pGemAttrValue:setVisible(false)
    self._pSaleNumText = params._pSaleNumText
    self._pSaleNumValue = params._pSaleNumValue
    -- 按钮容器默认不显示
    self._pButtonListView = params._pButtonListView
    self:setButtonListVisible(false)
    self._pTabButton = params._pListButtonTab
    self._pButtonListView:setItemModel(self._pTabButton)
    self._pSaleNumText = params._pSaleNumText

    self._pInfBg = params._pInfBg
    self._pTextIntroText = params._pTextIntroText
    self._pTextIntroText:ignoreContentAdaptWithSize(false)
    --self._pTextIntroText:getVirtualRenderer():ignoreContentAdaptWithSize(false)
    self._pTextIntroText:getVirtualRenderer():setMaxLineWidth(self._pTextListView:getContentSize().width)
    self._pTextIntroText:getVirtualRenderer():setWidth(self._pTextListView:getContentSize().width)
    self._pTextIntroText:getVirtualRenderer():setLineBreakWithoutSpace(true)
    self._pLinkBg = params._pLinkBg 
    self._pLinkText = params._pLinkText
    self._pLinkScrollview = params._pLinkScrollView

    -- 初始化dialog的基础组件
    self:disposeCSB()

    -- 根据物品信息初始化界面  
    self:setDataSource(args)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBagCallOutDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end

-- 退出函数
function BagCallOutDialog:onExitBagCallOutDialog()
    self:onExitDialog()
    print(self._strName.." onExit!")
    ResPlistManager:getInstance():removeSpriteFrames("ArrangeItemPanel.plist")
end

-- 循环更新
function BagCallOutDialog:update(dt)
    local cells = self._pListController:getCellSources()
    if cells == nil then
    	return
    end
    
    for i=1,table.getn(cells) do
        cells[i]:update(dt)
    end
    return
end

-- 显示结束时的回调
function BagCallOutDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function BagCallOutDialog:doWhenCloseOver()
    return
end

-- 初始化界面的数据展示 
function BagCallOutDialog:initUI()
    local sizeScrollview = self._pTextListView:getContentSize()
    self._pButtonListView:removeAllChildren(true)
    -- 创建物品名字标签 
    self._pItemName:setString(self._pItemInfo.templeteInfo.Name)
    -- 根据品质设置物品名字字体的颜色
    if self._pItemInfo.dataInfo.Quality and self._pItemInfo.dataInfo.Quality ~= 0 then
        self._pItemName:setColor(kQualityFontColor3b[self._pItemInfo.dataInfo.Quality])       
    end
    -- 如果物品的类型为宝石
    local isStone = self._pItemInfo.baseType == kItemType.kStone 
    -- 有些标签只有宝石的时候才可见
    self._pNeedLevelValue:setVisible(isStone)
    self._pNeedLevelTitle:setVisible(isStone)
    self._pGemAttrTitle:setVisible(isStone)
    self._pGemAttrValue:setVisible(isStone)
    self._pInfBg:setVisible(not isStone)
    self._pTextIntroText:setVisible(not isStone)
    if isStone then 
        self._pNeedLevelValue:setString(self._pItemInfo.dataInfo.RequiredLevel.."级可使用")
        if self._pItemInfo.dataInfo.RequiredLevel > RolesManager:getInstance()._pMainRoleInfo.level then 
            self._pNeedLevelValue:setColor(cRed)
        else
            self._pNeedLevelValue:setColor(cWhite)
        end
        -- 设置宝石的属性信息 
        local msg = "" 
        for k,property in pairs(self._pItemInfo.dataInfo.Property) do
            -- 属性的名称
            msg = msg..getStrAttributeRealValue(property[1],property[2]).."\n\n"
        end
        self._pGemAttrValue:setString(msg)
    end
    -- 物品的描述文本
    self._pTextIntroText:setString(self._pItemInfo.templeteInfo.Instruction) 
    local innerWidth = self._pTextListView:getContentSize().width
    local innerHeight = self._pTextIntroText:getContentSize().height  
    -- 滚动区域的高度必须大于等于实际区域的高度
    innerHeight = math.max(innerHeight,self._pTextListView:getContentSize().height)    
    self._pTextListView:setInnerContainerSize(cc.size(innerWidth, innerHeight))   
    -- 设置文本框的Y坐标
    local nTextIntroY = isStone == true and (self._pGemAttrValue:getPositionY() - self._pGemAttrValue:getContentSize().height/2 - 105) or (self._pNeedLevelValue:getPositionY())
    self._pTextListView:setPositionY(nTextIntroY+20)  
    self._pTextIntroText:setPositionY(innerHeight)
    self._pInfBg:setPositionY(nTextIntroY+50)
    
    
    -- 设置物品的出售价格 
    self._pSaleNumValue:setString(self._pItemInfo.dataInfo.Price)
    -- 设置标签的按钮 
    local tempBtnArry = nil
    if self._tAction[self._kSrcType] ~= nil then
        -- 如果useType 大于 0的话表示（是小类型需要区分对待）
        if self._pItemInfo.dataInfo.UseType ~= nil and self._pItemInfo.dataInfo.UseType > kItemUseType.kNone then
            tempBtnArry =  self._tSpecialAction[self._pItemInfo.dataInfo.UseType]
        else
            tempBtnArry = self._tAction[self._kSrcType][self._pItemInfo.baseType]
        end
    end
    local function touchEvent(sender,eventType)
          if eventType == ccui.TouchEventType.ended then 
            local key = sender:getTag()
            for k,v in pairs(tempBtnArry) do
               if v.key == key then 
                    v.callback(self._pItemInfo,self._kSrcType,self._tArgs)
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
                self._pTabButton:loadTextureNormal("ArrangeItemPanelRes/".. v.normalImg.. ".png",ccui.TextureResType.plistType)
                self._pTabButton:loadTexturePressed("ArrangeItemPanelRes/".. v.selectedImg.. ".png",ccui.TextureResType.plistType)
                --self._pTabButton:setZoomScale(nButtonZoomScale)
                --self._pTabButton:setPressedActionEnabled(true)
                self:setButtonListVisible(true)
                self._pButtonListView:addChild(self._pTabButton)
           end
           if k > 1 then
            local pUseMultiItemBtn = self._pTabButton:clone()
                pUseMultiItemBtn:loadTextureNormal("ArrangeItemPanelRes/".. v.normalImg.. ".png",ccui.TextureResType.plistType)
                pUseMultiItemBtn:loadTexturePressed("ArrangeItemPanelRes/".. v.selectedImg.. ".png",ccui.TextureResType.plistType)
            pUseMultiItemBtn:setTag(v.key)
            --pUseMultiItemBtn:setTitleText(v.name)
            self._pButtonListView:addChild(pUseMultiItemBtn)
           end
      end
    end
    
end

function BagCallOutDialog:updateSourceCells() 
    if self._pItemInfo.dataInfo.GetItem == nil then
        self._pLinkText:setVisible(true)
        self._pLinkText:setString(self._pItemInfo.dataInfo.GetItemText)
        self._pLinkScrollview:setVisible(false)
    else
        self._pLinkText:setVisible(false)
        self._pLinkScrollview:setVisible(true)
        local rowCount = table.getn(self._pItemInfo.dataInfo.GetItem)

        self._pListController._pDataSourceDelegateFunc = function (delegate,controller, index)
            --local info = TableOperateQueues[self.test[index]]

            local cell = controller:dequeueReusableCell()
            if cell == nil then
                cell = require("ItemSourceCell"):create(self._pItemInfo.dataInfo.GetItem[index])
            else
                cell:setQueueId(self._pItemInfo.dataInfo.GetItem[index])
            end
            cell:setDelegate(delegate)

            return cell
        end

        self._pListController._pNumOfCellDelegateFunc = function ()
            return table.getn(self._pItemInfo.dataInfo.GetItem)
        end

        self._pListController:setDataSource(self._pItemInfo.dataInfo.GetItem)
    end
end

-- 设置功能按钮是否可见 
function BagCallOutDialog:setButtonListVisible(isVisible)
     if self._isButtonListVisible == true then
        self._pButtonListView:setVisible(isVisible)
     else
         self._pButtonListView:setVisible(false)
     end
end 

-- 设置物品来源的提示是否显示
function BagCallOutDialog:setLinkItemVisible(isVisible)
    self._pLinkScrollview:setVisible(isVisible)
    self._pLinkBg:setVisible(isVisible)
    self._pLinkText:setVisible(isVisible)
end

-- 设置界面显示需要的数据
function BagCallOutDialog:setDataSource(args)
    self._pItemInfo = args[1]
    if not args[2] then
        self._kSrcType = kCalloutSrcType.kCalloutSrcBagCommon
    else
       self._kSrcType = args[2]
    end
    self._tArgs = args[3]

    if args[4] ~= nil then
        self._isButtonListVisible = args[4]
    end

    -- 更新界面显示
    self:initUI()
    
    self._pListController = require("ListController"):create(self,self._pLinkScrollview,listLayoutType.LayoutType_vertiacl,0,60)
    self._pListController:setVertiaclDis(2)
    self._pListController:setHorizontalDis(3)
    
    self:updateSourceCells()

    self._pButtonListView:refreshView()

    -- 通过第五个参数控制物品来源相关的信息是否显示
    if args[5] ~= nil then 
        self:setLinkItemVisible(args[5])
    end
end

-- 更新缓存数据
function BagCallOutDialog:updateCacheWithData(args)
    self:setDataSource(args)
end

return BagCallOutDialog
