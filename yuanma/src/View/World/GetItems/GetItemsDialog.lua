--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  GetItemsDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/11
-- descrip:   得到物品(仅仅做展现)
--===================================================
local GetItemsDialog = class("GetItemsDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function GetItemsDialog:ctor()
    self._strName = "GetItemsDialog"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pGetItemScrollView = nil
    self._pScrollViewDate = nil
end

-- 创建函数
function GetItemsDialog:create(args)
    local dialog = GetItemsDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function GetItemsDialog:dispose(args)
    ResPlistManager:getInstance():addSpriteFrames("GetItemsDialog.plist")
    local params = require("GetItemsDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pGetItemScrollView = params._pGetItemScrollView

    -- 初始化dialog的基础组件
    self:disposeCSB()
    self:initScrollViewDate(args)
    --加载ScrollView数据
    self:loadScrollViewDate() 
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
        end
        return true   --可以向下传递事件
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
            self:onExitGetItemsDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

--加载数据
 function GetItemsDialog:initScrollViewDate(args)
  self._pScrollViewDate = {}
    if args.finances ~= nil and table.getn(args.finances) ~= 0 then  --金钱
        for k,v in pairs(args.finances)do
            local tTempDate = {}
            local pFinancesType = v.finance
            local pFinancesValue = v.amount
            if v.finance >kFinance.kNone and v.finance  <=kFinance.kFC then 
                tTempDate = FinanceManager:getInstance():getIconByFinanceType(pFinancesType)
                tTempDate.amount = pFinancesValue
                tTempDate.id = pFinancesType
                tTempDate.itemType = 1   --标示Item的类型(1:金钱 2：物品 3：美人图 4：exp)
  		    end
            table.insert( self._pScrollViewDate,tTempDate)
  	    end
   end
    if args.items ~= nil and table.getn(args.items) ~= 0 then  --物品
        for k,v in pairs(args.items)do
            v.itemType = 2   --标示Item的类型(1:金钱 2：物品 3：美人图 4：exp)
            table.insert( self._pScrollViewDate,  GetCompleteItemInfo(v))
       end
    end
    
    if args.beautyList ~= nil and table.getn(args.beautyList)~= 0 then  --美人图
        for k,v in pairs(args.beautyList)do
            v.itemType = 3   --标示Item的类型(1:金钱 2：物品 3：美人图 4：exp)
            table.insert( self._pScrollViewDate,BeautyManager:getInstance():getFullBeautyInfo(v))
        end
    end
    
    if args.exp ~= nil and args.exp ~= 0 then  --exp
         --标示Item的类型(1:金钱 2：物品 3：美人图 4：exp)
    	 table.insert( self._pScrollViewDate,{fileBigName = "ccsComRes/icon_000.png" ,amount = args.exp,itemType = 4})
    end


    if args.reward ~= nil and table.getn(args.reward) ~= 0 then --读取本地表的获得类型
        local pDateInfo = getBoxInfo(args.reward)
        for k,v in pairs(pDateInfo) do
            if v.finance == true then --是货币
                v.itemType = 1    --标示Item的类型(1:金钱 2：物品 3：美人图 4：exp)
            else
                v.itemType = 2
            end
            table.insert( self._pScrollViewDate,v)
        end

    end
    
end
  


--初始化ScrollView界面数据
function GetItemsDialog:loadScrollViewDate()
    if #self._pScrollViewDate == 0 then
    	return 
    end

    local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101                                   --每个cell的宽度和高度        
    local nStartx = 0                      
    local nNum = #self._pScrollViewDate
    local nViewWidth  = self._pGetItemScrollView:getContentSize().width
    local nViewHeight  = self._pGetItemScrollView:getContentSize().height
    local pScrInnerWidth = (nViewWidth >(nLeftAndReightDis+nSize)*nNum) and nViewWidth or (nLeftAndReightDis+nSize)*nNum
    self._pGetItemScrollView:setInnerContainerSize(cc.size(pScrInnerWidth,nViewHeight))
    if pScrInnerWidth == nViewWidth then
        self._pGetItemScrollView:setBounceEnabled(false)
        nStartx = (nViewWidth-(nLeftAndReightDis+nSize)*(nNum-1))/2-nSize/2
    end
    
    for i=1,nNum do
        local pDateInfo =self._pScrollViewDate[i]
        local pCell =  require("BattleItemCell"):create()
        local nX = (i-1)*(nSize+nLeftAndReightDis)+nStartx
        local nY = (nViewHeight-nSize)/2
        pCell:setPosition(nX,nY)
        pCell:setTouchEnabled(false)
        self._pGetItemScrollView:addChild(pCell)
        
        local pName = cc.Label:createWithTTF("", strCommonFontName, 18)
        pName:setLineHeight(20)
        pName:setAdditionalKerning(-2)
        pName:setTextColor(cc.c4b(255, 255, 255, 255))
        pName:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        pName:setPosition(cc.p(nX+nSize/2,nY+nSize))
        --pName:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        --pName:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        self._pGetItemScrollView:addChild(pName)
        
        

        if pDateInfo.itemType == 1 then     --货币
            pCell:setFinanceInfo(pDateInfo)
            pName:setString(kFinanceNameTypeTitle[pDateInfo.id])
        elseif pDateInfo.itemType == 2 then --物品
            pCell:setItemInfo(pDateInfo)
            pName:setString(pDateInfo.templeteInfo.Name) 
        elseif pDateInfo.itemType == 3 then --美人图
            pCell:setItemInfo(pDateInfo)
            pName:setString(pDateInfo.templeteInfo.Name) 
        elseif pDateInfo.itemType == 4 then --exp
            pCell:setFinanceInfo(pDateInfo)
            pName:setString("经验")
        end
   
        
    end
end

-- 退出函数
function GetItemsDialog:onExitGetItemsDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("GetItemsDialog.plist")
    
end

-- 循环更新
function GetItemsDialog:update(dt)
    return
end

-- 显示结束时的回调
function GetItemsDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function GetItemsDialog:doWhenCloseOver()
    return
end

return GetItemsDialog
