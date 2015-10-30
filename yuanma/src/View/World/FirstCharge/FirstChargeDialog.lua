--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FirstChargeDialog.lua
-- author:    wuquandong
-- e-mail:    365667276@qq.com
-- created:   2015/10/10
-- descrip:   首充奖励
--===================================================
local FirstChargeDialog = class("FirstChargeDialog",function ()
	return require("Dialog"):create()
end)

function FirstChargeDialog:ctor()
	self._strName = "FirstChargeDialog"
	self._pCloseButton = nil 
	self._pCCS = nil 
	self._pBg = nil
	self._pGiftScrollview = nil 
	self._pGetGiftBtn = nil 
    self._pWarnIcon = nil 
	--------------------------------

end

function FirstChargeDialog:create()
	local dialog = FirstChargeDialog.new()
	dialog:dispose()
	return dialog
end

function FirstChargeDialog:dispose()
	-- 加载必要的合图资源
	ResPlistManager:getInstance():addSpriteFrames("FirstCharge.plist")
	-- 注册节点事件
	local function onNodeEvent(event)
		if event == "cleanup" then 
			self:onExitFirstChargeDialog()
		end
	end
    self:registerScriptHandler(onNodeEvent)

    self:initUI()

    self:initTouchEvent()
end

function FirstChargeDialog:initUI()
	local params = require("FirstChargeParams"):create()
	self._pCCS = params._pCCS
	self._pBg = params._pBackGround
	self._pCloseButton = params._pCloseButton
	self._pGetGiftBtn = params._pOkButton
	self._pGiftScrollview = params._pCzScrollView
    self._pWarnIcon = params._pTsPic
	self:disposeCSB()
    
    -- 根据首充的不同状态显示不同的文字
    if ActivityManager:getInstance()._nFirstChargeState == 0 then 
        self._pGetGiftBtn:setTitleText("充值领奖")
        self._pWarnIcon:setVisible(false)
    elseif ActivityManager:getInstance()._nFirstChargeState == 1 then 
        self._pGetGiftBtn:setTitleText("领取奖励")
        self._pWarnIcon:setVisible(true)
    end

	-- 领取奖励
    local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.began then
			AudioManager:getInstance():playEffect("ButtonClick")
		elseif eventType == ccui.TouchEventType.ended then 
           if ActivityManager:getInstance()._nFirstChargeState == 0 then 
                self._pGetGiftBtn:setTitleText("充值领奖")
                ShopSystemCGMessage:queryChargeListReq20506() 
           elseif ActivityManager:getInstance()._nFirstChargeState == 1 then 
                self._pGetGiftBtn:setTitleText("领取奖励")
                -- 领取首充奖励
                ActivityMessage:GainFRAwardReq22508()
           end
           
		end	
	end
    self._pGetGiftBtn:addTouchEventListener(touchEvent)

    -- 设置奖励物品
    self:setRewardDataSource(self:initGiftDataInfo())

end

-- 显示奖励物品
function FirstChargeDialog:setRewardDataSource(tData)
	if #tData == 0 then
    	return 
    end
	local nUpAndDownDis = 5                             --装备上下与框的间隔
    local nLeftAndReightDis = 4                         --装备左右与框的间隔
    local nSize = 101                                   --每个cell的宽度和高度        
    local nStartx = 0                      
    local nNum = #tData

    local nViewWidth  = self._pGiftScrollview:getContentSize().width
    local nViewHeight  = self._pGiftScrollview:getContentSize().height
    local pScrInnerWidth = (nViewWidth >(nLeftAndReightDis+nSize)*nNum) and nViewWidth or (nLeftAndReightDis+nSize)*nNum
    self._pGiftScrollview:setInnerContainerSize(cc.size(pScrInnerWidth,nViewHeight))
    if pScrInnerWidth == nViewWidth then
        self._pGiftScrollview:setBounceEnabled(false)
        nStartx = (nViewWidth-(nLeftAndReightDis+nSize)*(nNum-1))/2-nSize/2
    end
    
    for i=1,nNum do
        local pDateInfo = tData[i]
        local pCell =  require("BattleItemCell"):create()
        local nX = (i-1)*(nSize+nLeftAndReightDis)+nStartx
        local nY = (nViewHeight-nSize)/2
        pCell:setPosition(nX,nY)
        pCell:setTouchEnabled(true)
        self._pGiftScrollview:addChild(pCell)
        
        local pName = cc.Label:createWithTTF("", strCommonFontName, 18)
        pName:setLineHeight(20)
        pName:setAdditionalKerning(-2)
        pName:setTextColor(cc.c4b(255, 255, 255, 255))
        pName:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
        pName:setPosition(cc.p(nX+nSize/2,nY+nSize))
        self._pGiftScrollview:addChild(pName)
        
        

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

-- 初始化首充的奖励物品
function FirstChargeDialog:initGiftDataInfo()
	local pArgs = {finances = {}, items = {}}
	for i,pReward in ipairs(TableFirstRecharge[1].Reward) do
		if pReward[1] > kFinance.kNone and pReward[1] < kFinance.kFC then 
			-- 表示金融货币
			table.insert(pArgs.finances,{finance = pReward[1], amount = pReward[2]})
		else -- 物品
			local temp = {id = pReward[1], baseType = pReward[3], value = pReward[2]}
			table.insert(pArgs.items, GetCompleteItemInfo(temp))	
		end
	end
	return self:initScrollViewDate(pArgs)
end

--加载数据
function FirstChargeDialog:initScrollViewDate(args)
  	local temp = {}
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
            table.insert( temp,tTempDate)
  	    end
   end
    if args.items ~= nil and table.getn(args.items) ~= 0 then  --物品
        for k,v in pairs(args.items)do
            v.itemType = 2   --标示Item的类型(1:金钱 2：物品 3：美人图 4：exp)
            table.insert( temp,  GetCompleteItemInfo(v))
       end
    end
    
    if args.exp ~= nil and args.exp ~= 0 then  --exp
         --标示Item的类型(1:金钱 2：物品 3：美人图 4：exp)
    	 table.insert( temp,{fileBigName = "ccsComRes/icon_000.png" ,amount = args.exp,itemType = 4})
    end
   
    return temp
end

function FirstChargeDialog:initTouchEvent()
	-- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("begin ".."x="..location.x.."  y="..location.y)
        return true
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("end ".."x="..location.x.."  y="..location.y)
        -- self:close()     
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)
end

function FirstChargeDialog:onExitFirstChargeDialog()
	self:onExitDialog()
	ResPlistManager:getInstance():removeSpriteFrames("FirstCharge.plist")
end

return FirstChargeDialog